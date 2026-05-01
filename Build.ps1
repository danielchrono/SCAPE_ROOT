<#
.SYNOPSIS
    Build.ps1 - Gera o monolito SCAPE_DEPLOY.ps1 contendo todos os payloads.
    O monolito define as variáveis globais e depois executa o Ignite.ps1 (centelha).
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = $PSScriptRoot,
    [string]$OutputPath = (Join-Path $ProjectRoot 'SCAPE_DEPLOY.ps1')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# =============================================================================
# BootloaderTemplate (embutido, como no seu código legado)
# =============================================================================
$BootloaderTemplate = @'
# SCAPE Bootloader Maestro - Industrial Monolith v1.0.0
# MVVM Strict | SOC Compliant | DRY Optimized | Functional Paradigm
$ErrorActionPreference = "Stop"

# 1. Console & VT100 Initialization
try {
    [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Set-ItemProperty -Path "HKCU:\Console" -Name "VirtualTerminalLevel" -Value 1 -ErrorAction SilentlyContinue
    $VT100Code = "using System; using System.Runtime.InteropServices; public static class VT100 { [DllImport(`"kernel32.dll`", SetLastError=true)] public static extern IntPtr GetStdHandle(int nStdHandle); [DllImport(`"kernel32.dll`")] public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode); [DllImport(`"kernel32.dll`")] public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode); public static void Enable() { IntPtr hOut = GetStdHandle(-11); if (GetConsoleMode(hOut, out uint mode)) { SetConsoleMode(hOut, mode | 0x0004); } } }"
    Add-Type -TypeDefinition $VT100Code -ErrorAction SilentlyContinue
    [VT100]::Enable()
} catch {}

try {
    # 2. Resolve Application Root
    $Global:AppRoot = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) {
        $Global:AppRoot = [AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')
    }
    $ModulesDir = Join-Path $Global:AppRoot "Modules"
    if (-not (Test-Path $ModulesDir)) { throw "Modules directory not found. Deployment integrity compromised." }

    # 3. Load Manifest (Source of Truth)
    $ManifestPath = Get-ChildItem -Path $ModulesDir -Filter "Manifest.psm1" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ManifestPath) {
        . ([ScriptBlock]::Create([System.IO.File]::ReadAllText($ManifestPath.FullName)))
    } else {
        throw "Manifesto ausente. Abortando inicialização."
    }

    # 4. Deterministic Module Loading (Based on Manifest LoadOrder)
    $AllModules = New-Object System.Collections.Generic.List[PSObject]
    foreach ($Domain in $Global:SCAPE_Manifest.Keys) {
        foreach ($Mod in $Global:SCAPE_Manifest[$Domain]) { $AllModules.Add($Mod) }
    }
    $SortedModules = $AllModules | Sort-Object LoadOrder

    foreach ($Mod in $SortedModules) {
        # Skip system/deployer modules that are already handled or not needed at runtime
        if ($Mod.Name -match "^(Deployer|CompilerPS2EXE|CompilerWiX|ForgeUtils|BootloaderTemplate)$") { continue }

        $ModuleFile = Get-ChildItem -Path $ModulesDir -Filter "$($Mod.Name).psm1" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($ModuleFile) {
            try {
                . ([ScriptBlock]::Create([System.IO.File]::ReadAllText($ModuleFile.FullName)))
            } catch {
                if ($Mod.IsVital) { throw "FALHA VITAL: Módulo '$($Mod.Name)' - $($_.Exception.Message)" }
            }
        } elseif ($Mod.IsVital) {
            throw "MÓDULO VITAL AUSENTE: $($Mod.Name)"
        }
    }

    # 5. Initialize Core Infrastructure
    if (Get-Command "Init-SCAPE-EventBus" -ErrorAction SilentlyContinue) { Init-SCAPE-EventBus }
    if (Get-Command "Init-SCAPE-AtomicState" -ErrorAction SilentlyContinue) { Init-SCAPE-AtomicState }
    if (Get-Command "Initialize-SCAPE-Theme" -ErrorAction SilentlyContinue) { Initialize-SCAPE-Theme }
    if (Get-Command "Register-SCAPE-UIRenderers" -ErrorAction SilentlyContinue) { Register-SCAPE-UIRenderers }
    if (Get-Command "Initialize-SCAPE-Controller" -ErrorAction SilentlyContinue) { Initialize-SCAPE-Controller }

    # 6. Load Dependencies & Persistence
    if (Get-Command "Install-SCAPE-Dependencies" -ErrorAction SilentlyContinue) {
        $EnvDir = Join-Path $ModulesDir "1_System\Environment"
        if (Test-Path $EnvDir) {
            Install-SCAPE-Dependencies -CorePath $EnvDir | Out-Null
            if (Get-Command "Load-SCAPE-SQLiteEngine" -ErrorAction SilentlyContinue) {
                $DllPath = Join-Path $EnvDir "System.Data.SQLite.dll"
                if (Test-Path $DllPath) { Load-SCAPE-SQLiteEngine -DllPath $DllPath | Out-Null }
            }
        }
    }

    # 7. Boot Sequence & Router Activation
    Publish-SCAPE-Event -Type "Status" -Payload ([PSCustomObject]@{ Key="CORE_ENGINE_START"; Flag="SYSTEM" })

    if (Get-Command "Start-SCAPE-Router" -ErrorAction SilentlyContinue) {
        Start-SCAPE-Router -InitialMenu "MainMenu"
    } else {
        $Msg = if (Get-Command "I18N" -ErrorAction SilentlyContinue) { I18N 'BOOT_FATAL_MATRIX' -MsgArgs @("Router Engine Not Found") } else { "FATAL: Router Engine Not Found" }
        throw $Msg
    }
} catch {
    $errRaw = $_.Exception.Message
    $crashMsg = if (Get-Command "I18N" -ErrorAction SilentlyContinue) { I18N 'BOOT_FATAL_MATRIX' -MsgArgs @(,$errRaw) } else { "FATAL CRASH: $errRaw" }
    $promptMsg = if (Get-Command "I18N" -ErrorAction SilentlyContinue) { I18N 'MISC_PRESS_ENTER_TERMINAL' } else { "Press ENTER to exit..." }

    Write-Host "`n  $([char]27)[1;31m[!] $crashMsg$([char]27)[0m" -NoNewline
    Read-Host "`n  $promptMsg" | Out-Null
} finally {
    if (Get-Command "Close-SCAPE-AllHandles" -ErrorAction SilentlyContinue) { Close-SCAPE-AllHandles }
    Publish-SCAPE-Event -Type "Status" -Payload ([PSCustomObject]@{ Key="CORE_ENGINE_STOP"; Flag="SYSTEM" })
    [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()
}
'@

# =============================================================================
# Funções auxiliares
# =============================================================================
function Get-FileContent($Path) {
    $raw = Get-Content -Path $Path -Raw -Encoding UTF8
    if ($raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
    return $raw.Trim()
}

function Get-ModulePayloads($ModulesDir) {
    $list = @()
    Get-ChildItem -Path $ModulesDir -Recurse -File -Filter '*.psm1' | ForEach-Object {
        $rel = $_.FullName.Substring($ModulesDir.Length + 1)
        $name = ($rel -replace '\\|/', '_' -replace '\.psm1$', '')
        $list += [PSCustomObject]@{
            Name    = $name
            Content = Get-FileContent -Path $_.FullName
        }
    }
    return $list
}

function Get-DataAssets($DataDir) {
    $assets = @()
    Get-ChildItem -Path $DataDir -Recurse -File -Include '*.psd1', '*.json' | ForEach-Object {
        $rel = $_.FullName.Substring($DataDir.Length + 1)
        $assets += [PSCustomObject]@{
            Name    = "Asset_$($rel -replace '\\|/', '_' -replace '[^\w]', '_')"
            Content = Get-FileContent -Path $_.FullName
        }
    }
    return $assets
}

# =============================================================================
# Árvore de módulos (baseada na Topology, mas sem interferir na coleta)
# =============================================================================
function Show-TopologyTree {
    param($TopologyObject, [string]$ModulesDir)
    Write-Host "`nEstrutura de módulos encontrados:" -ForegroundColor Cyan
    $domains = @($TopologyObject.Keys)  # força array
    $domainCount = $domains.Count
    for ($d = 0; $d -lt $domainCount; $d++) {
        $domain = $domains[$d]
        $prefix = if ($d -eq $domainCount - 1) { "└── " } else { "├── " }
        Write-Host "$prefix$domain" -ForegroundColor Yellow
        $modules = $TopologyObject[$domain]
        if ($null -eq $modules) { $modules = @() }
        $modCount = @($modules).Count
        for ($m = 0; $m -lt $modCount; $m++) {
            $mod = $modules[$m]
            $subPrefix = if ($m -eq $modCount - 1) { "    └── " } else { "    ├── " }
            $fileName = ($mod.Name -split '\.')[-1] + ".psm1"
            $found = Get-ChildItem -Path (Join-Path $ModulesDir $domain) -Filter $fileName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
            $status = if ($found) { "✓" } else { "✗" }
            $color = if ($found) { "Green" } else { "Red" }
            Write-Host "$subPrefix$status $($mod.Name) [$($mod.LoadOrder)]" -ForegroundColor $color
            if (-not $found -and $mod.IsVital) {
                Write-Host "         (FALHA VITAL: arquivo não encontrado)" -ForegroundColor Red
            }
        }
    }
    Write-Host ""
}

# =============================================================================
# Escrita do monolito
# =============================================================================
function Write-Monolith($OutFile, $ModulePayloads, $DataAssets, $TopologyContent, $RegistryContent, $BootloaderTemplate) {
    $sb = [System.Text.StringBuilder]::new()
    $sb.AppendLine("# SCAPE DEPLOY MONOLITH - Gerado em $(Get-Date -Format o)").AppendLine()
    $sb.AppendLine('$ErrorActionPreference = "Stop"').AppendLine()
    $sb.AppendLine('# ============================================================')
    $sb.AppendLine('# 1. DEFINIÇÃO DAS VARIÁVEIS GLOBAIS (ASSETS E PAYLOADS)')
    $sb.AppendLine('# ============================================================')
    foreach ($a in $DataAssets) {
        $sb.AppendLine("`$Global:$($a.Name) = @'").AppendLine($a.Content).AppendLine("'@").AppendLine()
    }
    foreach ($m in $ModulePayloads) {
        $sb.AppendLine("`$Global:$($m.Name)Payload = @'").AppendLine($m.Content).AppendLine("'@").AppendLine()
    }
    $sb.AppendLine("`$Global:Asset_Topology_Payload = @'").AppendLine($TopologyContent).AppendLine("'@").AppendLine()
    $sb.AppendLine("`$Global:Asset_Registry_Payload = @'").AppendLine($RegistryContent).AppendLine("'@").AppendLine()

    # Inclui o BootloaderTemplate como variável global
    $sb.AppendLine('# BootloaderTemplate usado pelo Deployer para gerar main.ps1')
    $sb.AppendLine("`$Global:BootloaderTemplate = @'")
    $sb.AppendLine($BootloaderTemplate)
    $sb.AppendLine("'@").AppendLine()

    $sb.AppendLine('# ============================================================')
    $sb.AppendLine('# 2. DEFINIÇÃO DO ROOT DIRETÓRIO')
    $sb.AppendLine('# ============================================================')
    $sb.AppendLine('$global:BootRoot = $PSScriptRoot')
    $sb.AppendLine('$script:BootRoot = $PSScriptRoot')
    $sb.AppendLine('Set-Variable -Name "BootRoot" -Value $PSScriptRoot -Scope Global -Force')
    $sb.AppendLine()

    $sb.AppendLine('# ============================================================')
    $sb.AppendLine('# 3. CARREGAMENTO DO SCRIPT IGNITE (CENTELHA)')
    $sb.AppendLine('# ============================================================')
    $igniteContent = Get-FileContent -Path (Join-Path $ProjectRoot 'Ignite.ps1')
    $sb.AppendLine("`$Global:IgniteScriptContent = @'")
    $sb.AppendLine($igniteContent)
    $sb.AppendLine("'@")
    $sb.AppendLine()
    $sb.AppendLine('. ([ScriptBlock]::Create($IgniteScriptContent))')

    [System.IO.File]::WriteAllText($OutFile, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
    return $OutFile
}

# =============================================================================
# Execução principal
# =============================================================================
$dataDir = Join-Path $ProjectRoot 'Data'
$modulesDir = Join-Path $ProjectRoot 'Modules'
$topoPath = Join-Path $dataDir 'Manifests\Topology.psd1'
$regPath = Join-Path $dataDir 'Registry.psd1'

if (-not (Test-Path $topoPath)) { throw "Topology missing: $topoPath" }
if (-not (Test-Path $regPath)) { throw "Registry missing: $regPath" }
if (-not (Test-Path $modulesDir)) { throw "Modules directory missing: $modulesDir" }

# Carrega a Topology apenas para exibir a árvore e para incluir como asset
$topology = Import-PowerShellDataFile -Path $topoPath
Show-TopologyTree -TopologyObject $topology -ModulesDir $modulesDir

$modulePayloads = Get-ModulePayloads -ModulesDir $modulesDir
$dataAssets = Get-DataAssets -DataDir $dataDir
$topologyContent = Get-FileContent -Path $topoPath
$registryContent = Get-FileContent -Path $regPath

$result = Write-Monolith -OutFile $OutputPath -ModulePayloads $modulePayloads -DataAssets $dataAssets `
    -TopologyContent $topologyContent -RegistryContent $registryContent `
    -BootloaderTemplate $BootloaderTemplate

Write-Host "BUILD COMPLETE: $result" -ForegroundColor Green