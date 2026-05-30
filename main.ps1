<# SCAPE OPERATIONAL MAIN #>
param([switch]$SimulateUX)
$ErrorActionPreference = "Stop"
Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue

$Global:AppRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = (Get-Location).Path }
$Global:BootRoot = $Global:AppRoot
$workspaceRootName = "Workspace"; $workspaceLogsName = "Logs"; $workspaceTempName = "Temp"; $workspaceDeployName = "Build"
$systemConstPath = Join-Path $Global:AppRoot "Data\Constants\system.psd1"
$forgeConstPath = Join-Path $Global:AppRoot "Data\Constants\forge.psd1"
if (Test-Path -LiteralPath $systemConstPath) {
    $rawSystem = [System.IO.File]::ReadAllText($systemConstPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
    if (-not [string]::IsNullOrWhiteSpace($rawSystem)) {
        $systemConst = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawSystem))
        if ($systemConst -and $systemConst.Workspace) {
            $workspaceRootName = if ($systemConst.Workspace.ROOT) { [string]$systemConst.Workspace.ROOT } else { $workspaceRootName }
            $workspaceLogsName = if ($systemConst.Workspace.LOGS) { [string]$systemConst.Workspace.LOGS } else { $workspaceLogsName }
            $workspaceTempName = if ($systemConst.Workspace.TEMP) { [string]$systemConst.Workspace.TEMP } else { $workspaceTempName }
            $workspaceDeployName = if ($systemConst.Workspace.DEPLOY) { [string]$systemConst.Workspace.DEPLOY } else { $workspaceDeployName }
        }
    }
}
if (Test-Path -LiteralPath $forgeConstPath) {
    $rawForge = [System.IO.File]::ReadAllText($forgeConstPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
    if (-not [string]::IsNullOrWhiteSpace($rawForge)) {
        $forgeConst = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawForge))
        if ($forgeConst -and $forgeConst.Paths -and $forgeConst.Paths.DeployWorkspaceDir) { $workspaceDeployName = [string]$forgeConst.Paths.DeployWorkspaceDir }
    }
}
$workspaceRoot = Join-Path $Global:AppRoot $workspaceRootName
$preferredWorkspace = Join-Path $Global:AppRoot "Workspace"
if (Test-Path -LiteralPath $preferredWorkspace) { $workspaceRoot = $preferredWorkspace }
$workspaceLogs = Join-Path $workspaceRoot $workspaceLogsName
$workspaceTemp = Join-Path $workspaceRoot $workspaceTempName
$workspaceDeploy = Join-Path $workspaceRoot $workspaceDeployName
@($workspaceRoot, $workspaceLogs, $workspaceTemp, $workspaceDeploy) | ForEach-Object { if (-not (Test-Path -LiteralPath $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null } }
if (Get-Module PSReadLine -ErrorAction SilentlyContinue) { Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue }
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Enable VT100 and graphic mode from parent session or dynamically
if ([string]::IsNullOrWhiteSpace($env:SCAPE_GRAPHIC_MODE)) { $env:SCAPE_GRAPHIC_MODE = "1" }

$topoPath = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Topology.psd1"
$regPath  = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Registry.psd1"
if (-not (Test-Path $topoPath)) { throw "HANDOFF_FATAL: Topology.psd1 not found at $topoPath" }
if (-not (Test-Path $regPath)) { throw "HANDOFF_FATAL: Registry.psd1 not found at $regPath" }
$rawTopo = [System.IO.File]::ReadAllText($topoPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
$rawReg  = [System.IO.File]::ReadAllText($regPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
$manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawTopo))
$registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawReg))
if ($null -eq $manifest) { throw "HANDOFF_FATAL: Failed to parse Topology.psd1." }

function Resolve-ScapeModulePath {
    param([string]$ModuleName)
    $parts = $ModuleName -split "\."
    if ($parts.Count -lt 3) { return $null }
    $domain = $parts[1]
    $leaf = (($parts[2..($parts.Count - 1)] -join "\") + ".psm1")
    $candidate = Join-Path -Path $Global:AppRoot -ChildPath ("Modules\" + $domain + "\" + $leaf)
    if (Test-Path -LiteralPath $candidate) { return $candidate }
    return $null
}

$coreMods = $manifest["Core"] | Sort-Object LoadOrder
$loadedCore = [System.Collections.Generic.List[string]]::new()
foreach ($mod in $coreMods) {
    $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }
    $foundPath = Resolve-ScapeModulePath -ModuleName $modName
    if ($foundPath) { Import-Module $foundPath -Global -Force; $loadedCore.Add($modName) }
}

Initialize-ScapeState | Out-Null
if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) { Initialize-ScapeInterop | Out-Null }
Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot; Registry = $registry; MANIFEST = $manifest; LoadedLayers = $loadedCore; WORKSPACE_ROOT = $workspaceRoot; WORKSPACE_LOGS = $workspaceLogs; WORKSPACE_TEMP = $workspaceTemp; WORKSPACE_DEPLOY = $workspaceDeploy } -Confirm:$false | Out-Null

if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
    $state = Get-ScapeColdState
    if (-not $state.ContainsKey("Assets")) { $state["Assets"] = @{} }
    foreach ($key in $registry.Segments.Keys) {
        if ($key -eq "__Meta__") { continue }
        $seg = $registry.Segments[$key]
        $isLazy = if ($seg -is [hashtable]) { $seg["IsLazy"] } else { $seg.IsLazy }
        if ($isLazy -eq $false) {
            $file = if ($seg -is [hashtable]) { $seg["File"] } else { $seg.File }
            $cat  = if ($seg -is [hashtable]) { $seg["Category"] } else { $seg.Category }
            $assetPath = Join-Path -Path $Global:AppRoot -ChildPath $file
            if (Test-Path -LiteralPath $assetPath) {
                $rawAsset = [System.IO.File]::ReadAllText($assetPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
                $parsedAsset = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawAsset))
                if (-not $state["Assets"].ContainsKey($cat)) { $state["Assets"][$cat] = @{} }
                $state["Assets"][$cat][$key] = $parsedAsset
            }
        }
    }
}

if (Get-Command Initialize-ScapeSetting -ErrorAction SilentlyContinue) { Initialize-ScapeSetting -ForceReset:$false | Out-Null }
if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }
if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }
if (Get-Command Initialize-ScapeTheme -ErrorAction SilentlyContinue) { Initialize-ScapeTheme | Out-Null }
if (Get-Command Initialize-ScapeRenderer -ErrorAction SilentlyContinue) { Initialize-ScapeRenderer | Out-Null }

if (Get-Command Resolve-ScapeManifestLayer -ErrorAction SilentlyContinue) { Resolve-ScapeManifestLayer -LayerKey "Presentation" | Out-Null }
if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) { Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null }
$defaultLang = Get-ScapeConstant -Path "system::Defaults::LANG" -Fallback "en-US"
Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = $defaultLang }

$navCheck = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
if ($null -eq $navCheck) { throw "HANDOFF_FATAL: Navigation manifest failed to mount in RAM." }

try {
    if ($SimulateUX) {
        if (Get-Command Resolve-ScapeManifestLayer -ErrorAction SilentlyContinue) { Resolve-ScapeManifestLayer -LayerKey "Diagnostics" | Out-Null }
        if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) { Invoke-ScapeWakeAssets -Domain "Diagnostics" | Out-Null }
        if (Get-Command Start-ScapeUXSimulation -ErrorAction SilentlyContinue) {
            Start-ScapeUXSimulation -Steps 20 -DelayMs 250
        }
    }
    Start-ScapeRouter -InitialMenu "MainMenu"
}
catch {
    $errText = $_.ToString() + " " + $_.Exception.Message
    if ($errText -match "SCAPE_HANDOVER") {
        # Handover to another menu/session - logger continues
        exit 0
    }
    # Any other error - log and exit
    throw
}
finally {
    # Close logger only on real exit, not on handover
    if (Get-Command Close-ScapeLogStream -ErrorAction SilentlyContinue) { Close-ScapeLogStream }
}

