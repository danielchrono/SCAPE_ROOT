<#
.SYNOPSIS
    deploy.ps1 - SCAPE bootstrap entrypoint
#>
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Resolve-ScapeAppRoot {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) { return $PSScriptRoot }
    if ($MyInvocation.MyCommand.Path) { return (Split-Path -Parent $MyInvocation.MyCommand.Path) }
    return (Get-Location).Path
}

function Read-ScapeDataFile {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "MANIFEST_NOT_FOUND: $Path" }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $raw = $utf8NoBom.GetString($bytes).Trim()
    if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
    return (Invoke-Command -ScriptBlock ([scriptblock]::Create($raw)))
}

function Resolve-ScapeMsg {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [array]$MsgArgs = @()
    )
    if (Get-Command Get-ScapeLogMsg -ErrorAction SilentlyContinue) {
        return (Get-ScapeLogMsg -Key $Key -MsgArgs $MsgArgs)
    }
    return $Key
}

function Publish-ScapeBootDebug {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [array]$MsgArgs = @(),
        [string]$Type = "SYSTEM_INFO",
        [string]$Severity = "LOG_INFO"
    )
    if (-not (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue)) { return }
    $msg = Resolve-ScapeMsg -Key $Key -MsgArgs $MsgArgs
    Publish-ScapeEvent -Type $Type -Severity $Severity -Payload @{
        Key     = $Key
        Tokens  = $MsgArgs
        Message = $msg
    }
}

# 0. Clean previous runtime
Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue
[System.GC]::Collect()

# 1. Root + static constants
$Global:AppRoot = Resolve-ScapeAppRoot
$Global:BootRoot = $Global:AppRoot

$systemConstPath = Join-Path $Global:AppRoot "Data\Constants\system.psd1"
$forgeConstPath = Join-Path $Global:AppRoot "Data\Constants\forge.psd1"
$systemConstants = Read-ScapeDataFile -Path $systemConstPath
$forgeConstants = Read-ScapeDataFile -Path $forgeConstPath

$workspaceRootName = $systemConstants.Workspace.ROOT
$workspaceLogsName = $systemConstants.Workspace.LOGS
$workspaceTempName = $systemConstants.Workspace.TEMP
$workspaceDeployName = $systemConstants.Workspace.DEPLOY

if ($forgeConstants.Paths.DeployWorkspaceDir) { $workspaceDeployName = $forgeConstants.Paths.DeployWorkspaceDir }
$mainScriptFile = if ($forgeConstants.Paths.MainScriptFile) { [string]$forgeConstants.Paths.MainScriptFile } else { "main.ps1" }

$workspaceRoot = Join-Path $Global:AppRoot $workspaceRootName
$workspaceLogs = Join-Path $workspaceRoot $workspaceLogsName

# Prefer an existing developer workspace folder if present (ensure logs go to Workspace/Logs)
$preferredWorkspace = Join-Path $Global:AppRoot "Workspace"
if (Test-Path -LiteralPath $preferredWorkspace) {
    $workspaceRoot = $preferredWorkspace
    $workspaceLogs = Join-Path $workspaceRoot $workspaceLogsName
}
$workspaceTemp = Join-Path $workspaceRoot $workspaceTempName
$workspaceDeploy = Join-Path $workspaceRoot $workspaceDeployName

@($workspaceRoot, $workspaceLogs, $workspaceTemp, $workspaceDeploy) | ForEach-Object {
    if (-not (Test-Path -LiteralPath $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

$mainScriptPath = Join-Path $Global:AppRoot $mainScriptFile
if (Test-Path -LiteralPath $mainScriptPath) {
    Remove-Item -LiteralPath $mainScriptPath -Force -ErrorAction SilentlyContinue
}

# 2. Hydrate memory payloads
$Global:SCAPE_MEM = @{}
$ignitePath = Join-Path $Global:AppRoot "Modules\Forge\Ignite.ps1"
if (-not (Test-Path -LiteralPath $ignitePath)) {
    throw (Resolve-ScapeMsg -Key "IGNITE_DEPLOYER_MISSING")
}
. $ignitePath | Out-Null

# 3. Parse manifests from memory
if (-not $Global:SCAPE_MEM.ContainsKey('Asset_Topology')) { throw (Resolve-ScapeMsg -Key "BOOT_FATAL_MATRIX" -MsgArgs @("Asset_Topology")) }
if (-not $Global:SCAPE_MEM.ContainsKey('Asset_Registry')) { throw (Resolve-ScapeMsg -Key "BOOT_FATAL_MATRIX" -MsgArgs @("Asset_Registry")) }

$manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Topology']))
$registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Registry']))
$navigationFile = if ($registry -and $registry.Segments -and $registry.Segments.ContainsKey("navigation")) { $registry.Segments["navigation"].File } else { $null }
if ([string]::IsNullOrWhiteSpace($navigationFile)) {
    throw (Resolve-ScapeMsg -Key "BOOT_FATAL_MATRIX" -MsgArgs @("navigation manifest path"))
}
$navigationMemKey = "Asset_{0}" -f (($navigationFile -replace '^.*?[Dd]ata[/\\]', '' -replace '^[Dd]ata[/\\]', '' -replace '[/\\]', '_'))
if ($Global:SCAPE_MEM.ContainsKey($navigationMemKey)) {
    $navigation = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM[$navigationMemKey]))
}
else {
    $navigation = Read-ScapeDataFile -Path (Join-Path $Global:AppRoot $navigationFile)
}

# 4. Dynamic module injection (vital + core + forge)
$modulesToLoad = @()
$loadedLayers = [System.Collections.Generic.List[string]]::new()
foreach ($domain in $manifest.Keys) {
    if ($domain -eq '__Meta__') { continue }
    $modulesToLoad += @(
        $manifest[$domain] | Where-Object {
            $isVital = if ($_ -is [hashtable]) { $_['IsVital'] } else { $_.IsVital }
            $isBuildOnly = if ($_ -is [hashtable]) { $_['BuildTimeOnly'] } else { $_.BuildTimeOnly }
            $dom = if ($_ -is [hashtable]) { $_['Domain'] } else { $_.Domain }
            ($isVital -eq $true -or $dom -in @('Core', 'Forge')) -and (-not $isBuildOnly)
        }
    )
}

foreach ($mod in ($modulesToLoad | Sort-Object LoadOrder)) {
    $modName = if ($mod -is [hashtable]) { $mod['Name'] } else { $mod.Name }
    if (-not $Global:SCAPE_MEM.ContainsKey($modName)) { continue }
    $payload = $Global:SCAPE_MEM[$modName]
    Import-Module (New-Module -Name $modName -ScriptBlock ([scriptblock]::Create($payload))) -Global -Force
    $loadedLayers.Add($modName)
}

# 5. Initialize state and bind root context
Initialize-ScapeState | Out-Null
Initialize-ScapeInterop | Out-Null

$defaultLang = $systemConstants.Defaults.LANG
Update-ScapeColdState -NewProperties @{
    ROOT             = $Global:AppRoot
    Registry         = $registry
    Manifest         = $manifest
    Navigation       = $navigation
    WORKSPACE_ROOT   = $workspaceRoot
    WORKSPACE_TEMP   = $workspaceTemp
    WORKSPACE_LOGS   = $workspaceLogs
    WORKSPACE_DEPLOY = $workspaceDeploy
    LoadedLayers     = $loadedLayers
    DEV_MODE         = $false
    CurrentLanguage  = $defaultLang
} -Confirm:$false | Out-Null

# 6. Load required assets (non-lazy + critical)
$criticalAssets = @('system', 'forge', 'infrastructure', 'ui', 'theme', 'navigation', 'registry', 'topology', $defaultLang)
if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
    foreach ($key in $registry.Segments.Keys) {
        if ($key -eq '__Meta__') { continue }
        $seg = $registry.Segments[$key]
        $isLazy = if ($seg -is [hashtable]) { $seg['IsLazy'] } else { $seg.IsLazy }
        if (-not $isLazy -or $key -in $criticalAssets) {
            $file = if ($seg -is [hashtable]) { $seg['File'] } else { $seg.File }
            $category = if ($seg -is [hashtable]) { $seg['Category'] } else { $seg.Category }
            $assetPath = Join-Path $Global:AppRoot $file
            if (Test-Path -LiteralPath $assetPath) {
                Invoke-ScapeLoadAsset -Category $category -AssetId $key -FilePath $assetPath -Silent | Out-Null
            }
        }
    }
}

# 7. Runtime components
Publish-ScapeBootDebug -Key "IGNITE_INIT"
if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }
if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
Initialize-ScapeSetting -ForceReset:$false | Out-Null
if (Get-Command Initialize-ScapeTheme -ErrorAction SilentlyContinue) { Initialize-ScapeTheme | Out-Null }
if (Get-Command Initialize-ScapeRenderer -ErrorAction SilentlyContinue) { Initialize-ScapeRenderer | Out-Null }
if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }
if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) { Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null }
if (Get-Command Initialize-ScapeStateObserver -ErrorAction SilentlyContinue) { Initialize-ScapeStateObserver -AutoRegister -Confirm:$false | Out-Null }

# 8. Start deploy router integrated with Forge workflow
$navAsset = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
if ($null -eq $navAsset -or -not $navAsset.ContainsKey("DeployMenu")) {
    $msg = Resolve-ScapeMsg -Key "ROUTER_FATAL" -MsgArgs @("DeployMenu missing")
    throw $msg
}

try {
    Start-ScapeRouter -InitialMenu 'DeployMenu'
}
catch {
    $errText = $_.ToString() + " " + $_.Exception.Message
    if ($errText -match "SCAPE_HANDOVER") {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SCAPE_HANDOVER" -Severity "LOG_INFO" -Payload @{
                Message = "Deploy handover requested. Parent session exiting after child launch."
            }
            if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
        }
        Write-Host (Resolve-ScapeMsg -Key "DEPLOYER_LAUNCH_SCAPE") -ForegroundColor Cyan
        Start-Sleep -Seconds 1
        # DO NOT CLOSE LOGGER - let child session continue with same log file via SCAPE_LOG_PARENT_FILE env var
        exit 0
    }

    $fatalMsg = Resolve-ScapeMsg -Key "BOOT_FATAL_MATRIX" -MsgArgs @($_.Exception.Message)
    Write-Host ("`n{0}" -f $fatalMsg) -ForegroundColor Red
    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_CRASH" -Severity "LOG_FATAL" -Payload @{
            Key     = "BOOT_FATAL_MATRIX"
            Message = $fatalMsg
            Stack   = $_.ScriptStackTrace
        }
        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
    }
    # Close logger only on fatal error, not on successful handover
    if (Get-Command Close-ScapeLogStream -ErrorAction SilentlyContinue) { Close-ScapeLogStream }
}
finally {
    [System.GC]::Collect()
}

Read-Host (Resolve-ScapeMsg -Key "BOOT_PRESS_ENTER_EXIT")
