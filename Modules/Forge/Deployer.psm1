<#
.SYNOPSIS
    Domain: Forge | Module: Scape.Forge.Deployer
.DESCRIPTION
    Monolith Extraction | Entry Point (main.ps1) Generation | Execution Flow
    PRESERVED LEGACY: PSReadLine cleanup, Console encoding, Core/Interop/Settings/Logger init,
                      explicit lazy-load registration, Test-Path asset safety, SCAPE_HANDOVER flow.
    IMPROVEMENTS: $OutDir creation safety, cleaner switch syntax, robust StringBuilder generation,
                  $Global:SCAPE_MEM validation, and standardized event payloads.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Expand-MonolithToDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$TargetDir,
        [hashtable]$Topology,
        [hashtable]$Registry
    )

    if ($null -eq $Global:SCAPE_MEM -or $Global:SCAPE_MEM -isnot [hashtable]) {
        throw "EXPAND_FATAL: Global memory matrix (SCAPE_MEM) is not initialized."
    }

    # 1. Extrai Módulos respeitando a Topologia
    foreach ($domain in $Topology.Keys) {
        if ($domain -eq '__Meta__' -or $domain -eq 'Root') { continue }
        foreach ($mod in $Topology[$domain]) {
            $memKey = $mod.Name
            if ($Global:SCAPE_MEM.ContainsKey($memKey)) {
                $fileName = ($mod.Name -split '\.')[-1] + ".psm1"
                $dest = Join-ScapePath $TargetDir "Modules\$domain\$fileName"
                $dir = Split-Path $dest -Parent
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                Set-Content -Path $dest -Value $Global:SCAPE_MEM[$memKey] -Encoding UTF8 -NoNewline
            }
        }
    }

    # 2. Extrai Assets do Registry
    foreach ($key in $Registry.Segments.Keys) {
        if ($key -eq '__Meta__') { continue }
        $seg = $Registry.Segments[$key]
        $safeName = $seg.File -replace '^[Dd]ata\\', '' -replace '\\', '_'
        $memKey = "Asset_$safeName"

        if ($Global:SCAPE_MEM.ContainsKey($memKey)) {
            $dest = Join-ScapePath $TargetDir $seg.File
            $dir = Split-Path $dest -Parent
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            Set-Content -Path $dest -Value $Global:SCAPE_MEM[$memKey] -Encoding UTF8 -NoNewline
        }
    }

    # 3. Grava os Manifestos
    $topoDest = Join-ScapePath $TargetDir "Data\Manifests\Topology.psd1"
    $regDest = Join-ScapePath $TargetDir "Data\Manifests\Registry.psd1"
    if ($Global:SCAPE_MEM.ContainsKey('Asset_Topology')) {
        Set-Content -Path $topoDest -Value $Global:SCAPE_MEM['Asset_Topology'] -Encoding UTF8 -NoNewline
    }
    if ($Global:SCAPE_MEM.ContainsKey('Asset_Registry')) {
        Set-Content -Path $regDest -Value $Global:SCAPE_MEM['Asset_Registry'] -Encoding UTF8 -NoNewline
    }
}

function Set-MainScript {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$TargetDir, [hashtable]$Topology)

    $mainPath = Join-Path $TargetDir 'main.ps1'
    if (Test-Path $mainPath) { Remove-Item $mainPath -Force -ErrorAction SilentlyContinue }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('<# SCAPE OPERATIONAL MAIN #>')
    [void]$sb.AppendLine('$ErrorActionPreference = "Stop"')
    [void]$sb.AppendLine('Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue')
    [void]$sb.AppendLine('')

    [void]$sb.AppendLine('$Global:AppRoot = $PSScriptRoot')
    [void]$sb.AppendLine('if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }')
    [void]$sb.AppendLine('if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = (Get-Location).Path }')
    [void]$sb.AppendLine('$Global:BootRoot = $Global:AppRoot')

    [void]$sb.AppendLine('if (Get-Module PSReadLine -ErrorAction SilentlyContinue) { Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue }')
    [void]$sb.AppendLine('[Console]::OutputEncoding = [System.Text.Encoding]::UTF8')
    [void]$sb.AppendLine('')

    [void]$sb.AppendLine('$topoPath = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Topology.psd1"')
    [void]$sb.AppendLine('$regPath  = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Registry.psd1"')
    [void]$sb.AppendLine('if (-not (Test-Path $topoPath)) { throw "HANDOFF_FATAL: Topology.psd1 not found at $topoPath" }')
    [void]$sb.AppendLine('if (-not (Test-Path $regPath)) { throw "HANDOFF_FATAL: Registry.psd1 not found at $regPath" }')
    [void]$sb.AppendLine('$rawTopo = [System.IO.File]::ReadAllText($topoPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('$rawReg  = [System.IO.File]::ReadAllText($regPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('$manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawTopo))')
    [void]$sb.AppendLine('$registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawReg))')
    [void]$sb.AppendLine('if ($null -eq $manifest) { throw "HANDOFF_FATAL: Failed to parse Topology.psd1." }')
    [void]$sb.AppendLine('')

    [void]$sb.AppendLine('$coreMods = $manifest["Core"] | Sort-Object LoadOrder')
    [void]$sb.AppendLine('$loadedCore = [System.Collections.Generic.List[string]]::new()')
    [void]$sb.AppendLine('foreach ($mod in $coreMods) {')
    [void]$sb.AppendLine('    $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }')
    [void]$sb.AppendLine('    $fileName = ($modName -split "\.")[-1] + ".psm1"')
    [void]$sb.AppendLine('    $searchPath = Join-Path -Path $Global:AppRoot -ChildPath "Modules"')
    [void]$sb.AppendLine('    $found = Get-ChildItem -Path $searchPath -Filter $fileName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1')
    [void]$sb.AppendLine('    if ($found) { Import-Module $found.FullName -Global -Force; $loadedCore.Add($modName) }')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('')

    # 1. INICIALIZAÇÃO EXPLÍCITA DO ESTADO
    [void]$sb.AppendLine('Initialize-ScapeState | Out-Null')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) { Initialize-ScapeInterop | Out-Null }')
    [void]$sb.AppendLine('Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot; Registry = $registry; MANIFEST = $manifest; LoadedLayers = $loadedCore } -Confirm:$false | Out-Null')
    [void]$sb.AppendLine('')

    # 2. CARGA DE ASSETS (AGORA O STATE JÁ EXISTE)
    [void]$sb.AppendLine('if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {')
    [void]$sb.AppendLine('    $state = Get-ScapeColdState')
    [void]$sb.AppendLine('    if (-not $state.ContainsKey("Assets")) { $state["Assets"] = @{} }')
    [void]$sb.AppendLine('    foreach ($key in $registry.Segments.Keys) {')
    [void]$sb.AppendLine('        if ($key -eq "__Meta__") { continue }')
    [void]$sb.AppendLine('        $seg = $registry.Segments[$key]')
    [void]$sb.AppendLine('        $isLazy = if ($seg -is [hashtable]) { $seg["IsLazy"] } else { $seg.IsLazy }')
    [void]$sb.AppendLine('        if ($isLazy -eq $false) {')
    [void]$sb.AppendLine('            $file = if ($seg -is [hashtable]) { $seg["File"] } else { $seg.File }')
    [void]$sb.AppendLine('            $cat  = if ($seg -is [hashtable]) { $seg["Category"] } else { $seg.Category }')
    [void]$sb.AppendLine('            $assetPath = Join-Path -Path $Global:AppRoot -ChildPath $file')
    [void]$sb.AppendLine('            if (Test-Path -LiteralPath $assetPath) {')
    [void]$sb.AppendLine('                $rawAsset = [System.IO.File]::ReadAllText($assetPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('                $parsedAsset = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawAsset))')
    [void]$sb.AppendLine('                if (-not $state["Assets"].ContainsKey($cat)) { $state["Assets"][$cat] = @{} }')
    [void]$sb.AppendLine('                $state["Assets"][$cat][$key] = $parsedAsset')
    [void]$sb.AppendLine('            }')
    [void]$sb.AppendLine('        }')
    [void]$sb.AppendLine('    }')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('')

    # 3. SETTINGS & LOGGER
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeSetting -ErrorAction SilentlyContinue) { Initialize-ScapeSetting -ForceReset:$false | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }')
    [void]$sb.AppendLine('')

    # 4. PREPARA A UI E INICIA O ROTEADOR
    [void]$sb.AppendLine('if (Get-Command Resolve-ScapeManifestLayer -ErrorAction SilentlyContinue) { Resolve-ScapeManifestLayer -LayerKey "Presentation" | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) { Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null }')
    [void]$sb.AppendLine('Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = "pt-BR" }')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('$navCheck = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"')
    [void]$sb.AppendLine('if ($null -eq $navCheck) { throw "HANDOFF_FATAL: Navigation manifest failed to mount in RAM." }')
    [void]$sb.AppendLine('Start-ScapeRouter -InitialMenu "MainMenu"')

    Set-Content -Path $mainPath -Value $sb.ToString() -Encoding UTF8 -Force
    return $mainPath
}

function Invoke-ScapeDeployWorkflow {
    [CmdletBinding()]
    param(
        [ValidateSet('INIT_AND_EXIT', 'BUILD_AND_LAUNCH_MONOLITH', 'EXE_PORTABLE', 'EXE_SETUP', 'MSI')]
        [string]$Task,
        [string]$IconPath = ''
    )

    $state = Get-ScapeColdState
    if (-not $state.ContainsKey("ROOT") -or [string]::IsNullOrWhiteSpace($state["ROOT"])) {
        Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot } -Confirm:$false | Out-Null
    }
    if (-not $state.ContainsKey("DEV_MODE")) {
        Update-ScapeColdState -NewProperties @{ DEV_MODE = $true } -Confirm:$false | Out-Null
    }

    $navLoaded = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
    if ($null -eq $navLoaded) {
        Publish-ScapeEvent -Type "BOOT_FATAL" -Severity "FATAL" -Payload "Navigation manifest failed to load. Router cannot start."
        throw "ROUTER_PRECONDITION_FAIL: Navigation asset missing"
    }

    # ========================================================
    # CORREÇÃO: Variável $root declarada a partir do estado
    # ========================================================
    $root = $state["ROOT"]

    $topology = $state["MANIFEST"]
    $registry = $state["Registry"]
    $targetBase = $state["WORKSPACE_TEMP"]
    $outDir = Join-ScapePath $root "workspace\release"
    $pwsh = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }

    switch ($Task) {
        'INIT_AND_EXIT' {
            $mainPath = Set-MainScript -TargetDir $root -Topology $topology
            Start-Process $pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$mainPath`""
            throw "SCAPE_HANDOVER"
        }
        'BUILD_AND_LAUNCH_MONOLITH' {
            & (Join-ScapePath $root 'Modules\Forge\Build.psm1') -ProjectRoot $root
            $monolithPath = Join-ScapePath $root "Output\SCAPE_DEPLOY.ps1"
            Start-Process $pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$monolithPath`" -InitialMenu ForgeMenu"
            throw "SCAPE_HANDOVER"
        }
        'EXE_PORTABLE' { _ExecuteAtomicBuild -Task $Task -TargetBase $targetBase -Topology $topology -Registry $registry -OutDir $outDir -IconPath $IconPath }
        'EXE_SETUP' { _ExecuteAtomicBuild -Task $Task -TargetBase $targetBase -Topology $topology -Registry $registry -OutDir $outDir -IconPath $IconPath }
        'MSI' { _ExecuteAtomicBuild -Task $Task -TargetBase $targetBase -Topology $topology -Registry $registry -OutDir $outDir -IconPath $IconPath }
    }
}

function _ExecuteAtomicBuild {
    [CmdletBinding()]
    param(
        [string]$Task,
        [string]$TargetBase,
        [hashtable]$Topology,
        [hashtable]$Registry,
        [string]$OutDir,
        [string]$IconPath
    )

    $atomicDir = Join-ScapePath $TargetBase ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $atomicDir -Force | Out-Null

    try {
        Expand-MonolithToDirectory -TargetDir $atomicDir -Topology $Topology -Registry $Registry
        $tempMain = Set-MainScript -TargetDir $atomicDir -Topology $Topology

        # Garante diretório de saída (IMPROVEMENT PRESERVED)
        if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

        switch ($Task) {
            'EXE_PORTABLE' { Invoke-ScapeCompileExe -MainScriptPath $tempMain -OutputDir $OutDir -IconPath $IconPath | Out-Null }
            'EXE_SETUP' { Invoke-ScapeCompileInno -MainScriptPath $tempMain -OutputDir $OutDir -IconPath $IconPath | Out-Null }
            'MSI' {
                $deps = Invoke-ScapeFetchDependencies -TargetDir $atomicDir
                Invoke-ScapeCompileMsi -MainScriptPath $tempMain -OutputDir $OutDir -IconPath $IconPath -WixBinDir $deps.WixDir | Out-Null
            }
        }

        Publish-ScapeEvent -Type "BUILD_COMPLETED" -Severity "INFO" -Payload @{ Task = $Task; OutDir = $OutDir }
    }
    finally {
        # LEGACY PRESERVED: Limpeza atômica
        Remove-Item $atomicDir -Recurse -Force -ErrorAction SilentlyContinue
        if ($PSCommandPath -match 'SCAPE_DEPLOY\.ps1$') { Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue }
    }
}
