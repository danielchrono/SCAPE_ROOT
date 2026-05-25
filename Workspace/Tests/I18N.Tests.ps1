$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue

$Global:AppRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
$Global:BootRoot = $Global:AppRoot

$topoPath = Join-Path $Global:AppRoot "Data\Manifests\Topology.psd1"
$regPath  = Join-Path $Global:AppRoot "Data\Manifests\Registry.psd1"
$rawTopo  = [System.IO.File]::ReadAllText($topoPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF)," "))
$rawReg   = [System.IO.File]::ReadAllText($regPath,  [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF)," "))
$manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawTopo))
$registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawReg))

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

# Load vital modules from Core domain only
$vitalMods = @()
foreach ($domain in $manifest.Keys) {
    if ($domain -eq "__Meta__") { continue }
    $vitalMods += @($manifest[$domain] | Where-Object {
        $isVital = if ($_ -is [hashtable]) { $_["IsVital"] } else { $_.IsVital }
        $isBuildOnly = if ($_ -is [hashtable]) { $_["BuildTimeOnly"] } else { $_.BuildTimeOnly }
        $isVital -eq $true -and (-not $isBuildOnly)
    })
}
foreach ($mod in ($vitalMods | Sort-Object LoadOrder)) {
    $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }
    $foundPath = Resolve-ScapeModulePath -ModuleName $modName
    if ($foundPath) {
        try { Import-Module $foundPath -Global -Force }
        catch { Write-Host "  WARN: Could not load $modName - $($_.Exception.Message)" -ForegroundColor DarkYellow }
    }
}

Initialize-ScapeState | Out-Null
if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) {
    try { Initialize-ScapeInterop | Out-Null } catch {}
}

$workspaceRoot = Join-Path $Global:AppRoot "Workspace"
$workspaceLogs = Join-Path $workspaceRoot "Logs"
$workspaceTemp = Join-Path $workspaceRoot "Temp"
$workspaceDeploy = Join-Path $workspaceRoot "Build"
@($workspaceRoot, $workspaceLogs, $workspaceTemp, $workspaceDeploy) | ForEach-Object {
    if (-not (Test-Path -LiteralPath $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

Update-ScapeColdState -NewProperties @{
    ROOT            = $Global:AppRoot
    Registry        = $registry
    MANIFEST        = $manifest
    LoadedLayers    = @()
    WORKSPACE_ROOT  = $workspaceRoot
    WORKSPACE_LOGS  = $workspaceLogs
    WORKSPACE_TEMP  = $workspaceTemp
    WORKSPACE_DEPLOY = $workspaceDeploy
    DEV_MODE        = $true
} -Confirm:$false | Out-Null

# Load ALL non-lazy assets (constants + i18n en-US)
foreach ($key in $registry.Segments.Keys) {
    if ($key -eq "__Meta__") { continue }
    $seg = $registry.Segments[$key]
    $isLazy = if ($seg -is [hashtable]) { $seg["IsLazy"] } else { $seg.IsLazy }
    if ($isLazy -eq $false) {
        $file = if ($seg -is [hashtable]) { $seg["File"] } else { $seg.File }
        $cat  = if ($seg -is [hashtable]) { $seg["Category"] } else { $seg.Category }
        $assetPath = Join-Path -Path $Global:AppRoot -ChildPath $file
        if (Test-Path -LiteralPath $assetPath) {
            Invoke-ScapeLoadAsset -Category $cat -AssetId $key -FilePath $assetPath -Silent | Out-Null
        }
    }
}

# Init subsystems (skip what fails)
try { if (Get-Command Initialize-ScapeSetting -ErrorAction SilentlyContinue) { Initialize-ScapeSetting -ForceReset:$false | Out-Null } } catch { Write-Host "  NOTE: Settings init skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow }
try { if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null } } catch {}
try { if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null } } catch { Write-Host "  NOTE: Resolver init skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow }

# Set default language manually if settings init failed
$state = Get-ScapeColdState
if (-not $state.ContainsKey("CurrentLanguage") -or [string]::IsNullOrWhiteSpace($state["CurrentLanguage"])) {
    Update-ScapeColdState -NewProperties @{ CurrentLanguage = "en-US" } | Out-Null
}

# Drain any startup events
try { Invoke-ScapeIdlePump | Out-Null } catch {}

Write-Host ""
Write-Host "========== SCAPE I18N INTEGRATION TEST ==========" -ForegroundColor Cyan
Write-Host ""

# TEST 1: Default language
$state = Get-ScapeColdState
$currentLang = $state["CurrentLanguage"]
Write-Host "[TEST 1] Default language check..." -ForegroundColor Yellow
Write-Host "  CurrentLanguage = $currentLang"
if ($currentLang -eq "en-US") {
    Write-Host "  PASS: Default language is en-US" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Expected en-US, got $currentLang" -ForegroundColor Red
}

# TEST 2: Lazy loading check
Write-Host ""
Write-Host "[TEST 2] Lazy loading check..." -ForegroundColor Yellow
$i18nBucket = $state["Assets"]["I18N"]
$enLoaded = $i18nBucket.ContainsKey("en-US")
$ptLoaded = $i18nBucket.ContainsKey("pt-BR")
Write-Host "  en-US loaded: $enLoaded"
Write-Host "  pt-BR loaded: $ptLoaded"
if ($enLoaded -and -not $ptLoaded) {
    Write-Host "  PASS: en-US eager, pt-BR lazy (not in RAM)" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Expected en-US=True, pt-BR=False" -ForegroundColor Red
}

# TEST 3: I18N resolution en-US
Write-Host ""
Write-Host "[TEST 3] I18N resolution (en-US)..." -ForegroundColor Yellow
$node = Get-ScapeI18NNode -Key "MENU_MAIN_TITLE"
Write-Host "  MENU_MAIN_TITLE = $($node.Text)"
if (($node.Text -ne "MENU_MAIN_TITLE") -and ($node.Text.Length -gt 0)) {
    Write-Host "  PASS: Key resolved" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Key not resolved" -ForegroundColor Red
}

# TEST 4: Switch to pt-BR
Write-Host ""
Write-Host "[TEST 4] LANG_SWITCH to pt-BR..." -ForegroundColor Yellow
Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = "pt-BR" }
try { Invoke-ScapeIdlePump | Out-Null } catch { Write-Host "  IdlePump error: $($_.Exception.Message)" }

$state = Get-ScapeColdState
$currentLang = $state["CurrentLanguage"]
$i18nBucket = $state["Assets"]["I18N"]
$ptLoaded = $i18nBucket.ContainsKey("pt-BR")
$enStillLoaded = $i18nBucket.ContainsKey("en-US")

Write-Host "  CurrentLanguage = $currentLang"
Write-Host "  pt-BR loaded: $ptLoaded"
Write-Host "  en-US still loaded: $enStillLoaded"

if (($currentLang -eq "pt-BR") -and $ptLoaded) {
    Write-Host "  PASS: Switched to pt-BR" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Language switch failed" -ForegroundColor Red
}
if (-not $enStillLoaded) {
    Write-Host "  PASS: en-US removed from RAM (GC)" -ForegroundColor Green
} else {
    Write-Host "  WARN: en-US still in RAM" -ForegroundColor Yellow
}

# TEST 5: I18N resolution pt-BR
Write-Host ""
Write-Host "[TEST 5] I18N resolution (pt-BR)..." -ForegroundColor Yellow
$node = Get-ScapeI18NNode -Key "MENU_MAIN_TITLE"
Write-Host "  MENU_MAIN_TITLE = $($node.Text)"
if (($node.Text -ne "MENU_MAIN_TITLE") -and ($node.Text.Length -gt 0)) {
    Write-Host "  PASS: Key resolved in pt-BR" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Key not resolved in pt-BR" -ForegroundColor Red
}

# TEST 6: Switch back to en-US
Write-Host ""
Write-Host "[TEST 6] LANG_SWITCH back to en-US..." -ForegroundColor Yellow
Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = "en-US" }
try { Invoke-ScapeIdlePump | Out-Null } catch { Write-Host "  IdlePump error: $($_.Exception.Message)" }

$state = Get-ScapeColdState
$currentLang = $state["CurrentLanguage"]
$i18nBucket = $state["Assets"]["I18N"]
$enLoaded = $i18nBucket.ContainsKey("en-US")
$ptStillLoaded = $i18nBucket.ContainsKey("pt-BR")

Write-Host "  CurrentLanguage = $currentLang"
Write-Host "  en-US loaded: $enLoaded"
Write-Host "  pt-BR still loaded: $ptStillLoaded"

if (($currentLang -eq "en-US") -and $enLoaded) {
    Write-Host "  PASS: Switched back to en-US" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Switch back failed" -ForegroundColor Red
}
if (-not $ptStillLoaded) {
    Write-Host "  PASS: pt-BR removed from RAM (GC)" -ForegroundColor Green
} else {
    Write-Host "  WARN: pt-BR still in RAM" -ForegroundColor Yellow
}

# TEST 7: I18N resolution after round-trip
Write-Host ""
Write-Host "[TEST 7] I18N after round-trip..." -ForegroundColor Yellow
$node = Get-ScapeI18NNode -Key "MENU_MAIN_TITLE"
Write-Host "  MENU_MAIN_TITLE = $($node.Text)"
if (($node.Text -ne "MENU_MAIN_TITLE") -and ($node.Text.Length -gt 0)) {
    Write-Host "  PASS: Key resolved after round-trip" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Key not resolved after round-trip" -ForegroundColor Red
}

# TEST 8: Check UI_REDRAW_REQUEST payload from LANG_SWITCH listener
Write-Host ""
Write-Host "[TEST 8] UI_REDRAW_REQUEST payload check..." -ForegroundColor Yellow

$Script:CapturedRedrawEvents = @()
Register-ScapeEventListener -EventMatch "UI_REDRAW_REQUEST" -Action {
    param($evt)
    $Script:CapturedRedrawEvents += @($evt)
}

# Set CurrentMenu so the redraw can reference it
Update-ScapeColdState -NewProperties @{ CurrentMenu = "SettingsMenu" } | Out-Null

Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = "pt-BR" }
try { Invoke-ScapeIdlePump | Out-Null } catch { Write-Host "  IdlePump error: $($_.Exception.Message)" }

$hasMenuId = $false
$hasType = $false
$capturedCount = 0
foreach ($evt in $Script:CapturedRedrawEvents) {
    $p = $evt.Payload
    if ($null -ne $p) {
        $capturedCount++
        $mid = if ($p -is [hashtable]) { $p["MenuId"] } else { $null }
        $typ = if ($p -is [hashtable]) { $p["Type"] } else { $null }
        if (-not [string]::IsNullOrWhiteSpace($mid)) { $hasMenuId = $true }
        if (-not [string]::IsNullOrWhiteSpace($typ)) { $hasType = $true }
        Write-Host "  Captured UI_REDRAW_REQUEST #$capturedCount : MenuId=$mid, Type=$typ, Keys=$($p.Keys -join ',')"
    }
}

Write-Host "  Total captured: $capturedCount"
if ($hasMenuId -and $hasType) {
    Write-Host "  PASS: UI_REDRAW_REQUEST has proper MenuId and Type" -ForegroundColor Green
} else {
    Write-Host "  FAIL: UI_REDRAW_REQUEST missing MenuId=$hasMenuId Type=$hasType" -ForegroundColor Red
    Write-Host "  -> Root cause: view cannot re-render on lang switch!" -ForegroundColor Red
}

Write-Host ""
Write-Host "========== TEST COMPLETE ==========" -ForegroundColor Cyan
