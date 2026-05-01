<#
.SYNOPSIS
    Deployer.psm1 - Expande monolito, gera main.ps1 e chama compiladores.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Expand-MonolithToDirectory {
    param([string]$TargetDir, [hashtable]$Topology)
    # Payloads dos módulos (globais)
    $payloadVars = Get-Variable -Scope Global | Where-Object { $_.Name -match '_Payload$' -and $_.Name -notin @('Asset_Topology_Payload', 'Asset_Registry_Payload') }
    # Mapeia nome do payload para módulo da Topology
    $moduleMap = @{}
    $Topology.Keys | ForEach-Object {
        $Topology[$_] | ForEach-Object {
            $name = $_.Name -replace '\.', '_' + "_Payload"
            $moduleMap[$name] = $_
        }
    }

    foreach ($var in $payloadVars) {
        $mod = $moduleMap[$var.Name]
        if (-not $mod) { continue }
        $domain = $mod.Domain
        $fileName = ($mod.Name -split '\.')[-1] + ".psm1"
        # Para domínios com subpastas (ex: Analysis\FS), precisamos localizar o caminho original
        # Como não temos esse dado, vamos usar o mesmo método de busca recursiva do Build
        $modulesBase = Join-Path $TargetDir "Modules"
        $domainPath = Join-Path $modulesBase $domain
        $found = Get-ChildItem -Path $domainPath -Filter $fileName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $found) {
            Write-Warning "Não foi possível localizar o módulo $($mod.Name) em $domainPath. Será colocado diretamente em Modules\$domain"
            $dest = Join-Path $modulesBase "$domain\$fileName"
        }
        else {
            $rel = $found.FullName.Substring($modulesBase.Length + 1)
            $dest = Join-Path $modulesBase $rel
        }
        $dir = Split-Path $dest -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $dest -Value $var.Value -Encoding UTF8 -NoNewline
    }

    # Expande assets (Data)
    $assetVars = Get-Variable -Scope Global | Where-Object { $_.Name -match '^Asset_' -and $_.Name -notin @('Asset_Topology_Payload', 'Asset_Registry_Payload') }
    foreach ($var in $assetVars) {
        $rel = $var.Name -replace '^Asset_', '' -replace '_', '\'
        $dest = Join-Path $TargetDir "Data\$rel"
        $dir = Split-Path $dest -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $dest -Value $var.Value -Encoding UTF8 -NoNewline
    }

    # Topology e Registry como arquivos
    $topoDest = Join-Path $TargetDir "Data\Manifests\Topology.psd1"
    $regDest = Join-Path $TargetDir "Data\Registry.psd1"
    $dir = Split-Path $topoDest -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $topoDest -Value $Global:Asset_Topology_Payload -Encoding UTF8 -NoNewline
    Set-Content -Path $regDest -Value $Global:Asset_Registry_Payload -Encoding UTF8 -NoNewline
}

function Add-ExportToModule {
    param([string]$Psm1Path)
    $content = Get-Content -Path $Psm1Path -Raw -Encoding UTF8
    $funcs = [regex]::Matches($content, '(?<=^|\n)function\s+([a-zA-Z0-9_-]+)\s*\{') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    if ($funcs.Count -eq 0) { return }
    $exportLine = "`nExport-ModuleMember -Function $($funcs -join ', ')"
    if ($content -match '(?<=^|\n)Export-ModuleMember') {
        $content = $content -replace '(?<=^|\n)Export-ModuleMember[^\n]*', $exportLine
    }
    else {
        $content = $content.TrimEnd() + $exportLine
    }
    Set-Content -Path $Psm1Path -Value $content -Encoding UTF8 -NoNewline
}

function Set-MainScript {
    param($TargetDir, $Topology, $Registry)
    $allModules = @()
    $Topology.Keys | ForEach-Object { $allModules += $Topology[$_] }
    $sorted = $allModules | Sort-Object LoadOrder

    $importLines = @()
    foreach ($mod in $sorted) {
        $shortName = ($mod.Name -split '\.')[-1]
        # O caminho pode estar em subpasta; vamos procurar recursivamente
        $modulesBase = Join-Path $TargetDir "Modules"
        $found = Get-ChildItem -Path $modulesBase -Filter "$shortName.psm1" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $relPath = $found.FullName.Substring($modulesBase.Length + 1)
            $importLines += "Import-Module `"`$PSScriptRoot\Modules\$relPath`" -Force -ErrorAction Stop"
        }
        else {
            $importLines += "# Módulo $($mod.Name) não encontrado no sistema expandido"
        }
    }
    $importBlock = $importLines -join "`n"

    $priorityKeys = $Registry.Segments.Keys | Where-Object { $Registry.Segments[$_].Category -in @('Constants', 'I18N') }
    $priorityLoad = @()
    foreach ($key in $priorityKeys) {
        $seg = $Registry.Segments[$key]
        $priorityLoad += "`$null = Invoke-ScapeLoadAsset -Category '$($seg.Category)' -AssetId '$key' -FilePath `"`$PSScriptRoot\$($seg.File)`" -Silent"
    }
    $priorityBlock = $priorityLoad -join "`n    "

    $otherKeys = $Registry.Segments.Keys | Where-Object { $Registry.Segments[$_].Category -notin @('Constants', 'I18N') }
    $otherLoad = @()
    foreach ($key in $otherKeys) {
        $seg = $Registry.Segments[$key]
        $otherLoad += "if (Test-Path `"`$PSScriptRoot\$($seg.File)`") { `$null = Invoke-ScapeLoadAsset -Category '$($seg.Category)' -AssetId '$key' -FilePath `"`$PSScriptRoot\$($seg.File)`" -Silent }"
    }
    $otherBlock = $otherLoad -join "`n    "

    $mainContent = @"
# main.ps1 - Gerado automaticamente
`$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$importBlock

`$null = Initialize-ScapeState
Update-ScapeColdState -NewProperties @{ ROOT = `$PSScriptRoot; DEV_MODE = `$true } -Confirm:`$false

# Prioritários
$priorityBlock

`$targetLang = Get-ScapeConstant -Path "dir::DEFAULTS::LANG" -Fallback "en-US"
Update-ScapeColdState -NewProperties @{ CurrentLanguage = `$targetLang; Config = @{ Language = `$targetLang } } -Confirm:`$false

# Demais assets
$otherBlock

Update-ScapeColdState -NewProperties @{
    LazyLoadingEnabled = `$true
    ModuleStackPolicy = "UnloadOnReturn"
    MaxMemoryFootprintMB = 128
} -Confirm:`$false

if (-not (Get-Command Start-ScapeRouter -ErrorAction SilentlyContinue)) { throw "ROUTER_MISSING" }
[Console]::Clear()
[Console]::SetCursorPosition(0,0)
Start-ScapeRouter -InitialMenu "MainMenu"
"@
    $mainPath = Join-Path $TargetDir 'main.ps1'
    Set-Content -Path $mainPath -Value $mainContent -Encoding UTF8 -NoNewline
    return $mainPath
}

function Start-ScapeDeployment {
    [CmdletBinding()]
    param(
        [string]$WorkspacePath = $PSScriptRoot,
        [string]$OutputBase = (Join-Path $WorkspacePath 'SCAPE_RELEASE'),
        [string]$IconPath = '',
        [ValidateSet('None', 'StandaloneExe', 'SetupExe', 'SetupMsi', 'All')][string]$BuildType = 'None'
    )
    $isDevMode = Test-Path (Join-Path $WorkspacePath 'Modules')
    if ($isDevMode) {
        Write-Host "Modo Desenvolvimento" -ForegroundColor Cyan
        $targetDir = $WorkspacePath
        Get-ChildItem -Path (Join-Path $targetDir 'Modules') -Recurse -Filter '*.psm1' | ForEach-Object {
            Add-ExportToModule -Psm1Path $_.FullName
        }
        $topology = Import-PowerShellDataFile (Join-Path $targetDir 'Data\Manifests\Topology.psd1')
        $registry = Import-PowerShellDataFile (Join-Path $targetDir 'Data\Registry.psd1')
        $mainScript = Set-MainScript -TargetDir $targetDir -Topology $topology -Registry $registry
    }
    else {
        Write-Host "Modo Monolito - expandindo" -ForegroundColor Cyan
        $targetDir = Join-Path $WorkspacePath 'SCAPE_EXPANDED'
        if (Test-Path $targetDir) { Remove-Item $targetDir -Recurse -Force }
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        $topoContent = $Global:Asset_Topology_Payload
        $regContent = $Global:Asset_Registry_Payload
        $topoAst = [System.Management.Automation.Language.Parser]::ParseInput($topoContent, [ref]$null, [ref]$null)
        $regAst = [System.Management.Automation.Language.Parser]::ParseInput($regContent, [ref]$null, [ref]$null)
        $topology = $topoAst.FindAll({ $args[0] -is [hashtable] }, $true)[0].SafeGetValue()
        $registry = $regAst.FindAll({ $args[0] -is [hashtable] }, $true)[0].SafeGetValue()

        Expand-MonolithToDirectory -TargetDir $targetDir -Topology $topology

        # Adiciona Export-ModuleMember nos módulos extraídos
        Get-ChildItem -Path (Join-Path $targetDir 'Modules') -Recurse -Filter '*.psm1' | ForEach-Object {
            Add-ExportToModule -Psm1Path $_.FullName
        }

        $mainScript = Set-MainScript -TargetDir $targetDir -Topology $topology -Registry $registry
    }

    if ($BuildType -eq 'None') {
        Write-Host "Deploy concluído. main.ps1 em $mainScript" -ForegroundColor Green
        return
    }

    if (-not (Test-Path $OutputBase)) { New-Item -ItemType Directory -Path $OutputBase -Force | Out-Null }

    switch ($BuildType) {
        'StandaloneExe' {
            $exe = Invoke-ScapePs2Exe -MainScriptPath $mainScript -OutputDir $OutputBase -IconPath $IconPath
            Write-Host "Standalone EXE: $exe" -ForegroundColor Green
        }
        'SetupExe' {
            $exe = Invoke-ScapeInnoSetup -MainScriptPath $mainScript -OutputDir $OutputBase -IconPath $IconPath
            Write-Host "Setup.exe: $exe" -ForegroundColor Green
        }
        'SetupMsi' {
            $msi = Invoke-ScapeWiXBuild -MainScriptPath $mainScript -OutputDir $OutputBase -IconPath $IconPath
            Write-Host "Setup.msi: $msi" -ForegroundColor Green
        }
        'All' {
            $e1 = Invoke-ScapePs2Exe -MainScriptPath $mainScript -OutputDir $OutputBase -IconPath $IconPath
            $e2 = Invoke-ScapeInnoSetup -MainScriptPath $mainScript -OutputDir $OutputBase -IconPath $IconPath
            $m = Invoke-ScapeWiXBuild -MainScriptPath $mainScript -OutputDir $OutputBase -IconPath $IconPath
            Write-Host "Todos os artefatos gerados:`n Standalone: $e1`n Setup.exe: $e2`n Setup.msi: $m" -ForegroundColor Green
        }
    }
}