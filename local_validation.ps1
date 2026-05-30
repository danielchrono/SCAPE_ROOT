$ErrorActionPreference = "Continue"

$Global:AppRoot = "c:\Users\danie\SCAPE_ROOT"
$Global:BootRoot = $Global:AppRoot

$script:results = @()
function Log-Result {
    param([string]$Phase, [string]$Status, [string]$Message)
    $script:results += [PSCustomObject]@{
        Phase = $Phase
        Status = $Status
        Message = $Message
    }
}

try {
    # Emulate Workspace setup
    $workspaceRoot = Join-Path $Global:AppRoot "Workspace"
    $workspaceLogs = Join-Path $workspaceRoot "Logs"
    $workspaceTemp = Join-Path $workspaceRoot "Temp"
    $workspaceDeploy = Join-Path $workspaceRoot "Build"
    @($workspaceRoot, $workspaceLogs, $workspaceTemp, $workspaceDeploy) | ForEach-Object { if (-not (Test-Path -LiteralPath $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null } }

    $topoPath = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Topology.psd1"
    $regPath  = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Registry.psd1"
    
    $rawTopo = [System.IO.File]::ReadAllText($topoPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
    $manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawTopo))
    
    $rawReg  = [System.IO.File]::ReadAllText($regPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
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

    # Load Core
    $coreMods = $manifest["Core"] | Sort-Object LoadOrder
    $loadedCore = [System.Collections.Generic.List[string]]::new()
    foreach ($mod in $coreMods) {
        $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }
        $foundPath = Resolve-ScapeModulePath -ModuleName $modName
        if ($foundPath) { 
            try { Import-Module $foundPath -Global -Force -ErrorAction Stop; $loadedCore.Add($modName); Log-Result "Import $modName" "Pass" "Success" }
            catch { Log-Result "Import $modName" "Fail" $_.Exception.Message }
        } else { Log-Result "Import $modName" "Fail" "Not found" }
    }

    # Initialize State
    try { Initialize-ScapeState | Out-Null; Log-Result "Init State" "Pass" "" } catch { Log-Result "Init State" "Fail" $_.Exception.Message }
    if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) {
        try { Initialize-ScapeInterop | Out-Null; Log-Result "Init Interop" "Pass" "" } catch { Log-Result "Init Interop" "Fail" $_.Exception.Message }
    }
    
    try {
        Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot; Registry = $registry; MANIFEST = $manifest; LoadedLayers = $loadedCore; WORKSPACE_ROOT = $workspaceRoot; WORKSPACE_LOGS = $workspaceLogs; WORKSPACE_TEMP = $workspaceTemp; WORKSPACE_DEPLOY = $workspaceDeploy } -Confirm:$false | Out-Null
        Log-Result "Update Cold State" "Pass" ""
    } catch { Log-Result "Update Cold State" "Fail" $_.Exception.Message }

    # Load Assets (from main.ps1)
    if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
        try {
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
            Log-Result "Load Assets" "Pass" ""
        } catch { Log-Result "Load Assets" "Fail" $_.Exception.Message }
    }

    # Initialize Setting
    if (Get-Command Initialize-ScapeSetting -ErrorAction SilentlyContinue) {
        try { Initialize-ScapeSetting -ForceReset:$false | Out-Null; Log-Result "Init Setting" "Pass" "" } catch { Log-Result "Init Setting" "Fail" $_.Exception.Message }
    }
    if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) {
        try { Initialize-ScapeResolver | Out-Null; Log-Result "Init Resolver" "Pass" "" } catch { Log-Result "Init Resolver" "Fail" $_.Exception.Message }
    }
    
    # Let's also try to load Infrastructure and Presentation so we can test Logger/Theme/Renderer/Router
    $infraMods = $manifest["Infrastructure"] | Sort-Object LoadOrder
    foreach ($mod in $infraMods) {
        $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }
        $foundPath = Resolve-ScapeModulePath -ModuleName $modName
        if ($foundPath) { 
            try { Import-Module $foundPath -Global -Force -ErrorAction Stop; Log-Result "Import $modName" "Pass" "Success" }
            catch { Log-Result "Import $modName" "Fail" $_.Exception.Message }
        }
    }

    $presMods = $manifest["Presentation"] | Sort-Object LoadOrder
    foreach ($mod in $presMods) {
        $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }
        $foundPath = Resolve-ScapeModulePath -ModuleName $modName
        if ($foundPath) { 
            try { Import-Module $foundPath -Global -Force -ErrorAction Stop; Log-Result "Import $modName" "Pass" "Success" }
            catch { Log-Result "Import $modName" "Fail" $_.Exception.Message }
        }
    }
    
    if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) {
        try { Initialize-ScapeLogger | Out-Null; Log-Result "Init Logger" "Pass" "" } catch { Log-Result "Init Logger" "Fail" $_.Exception.Message }
    }
    if (Get-Command Initialize-ScapeTheme -ErrorAction SilentlyContinue) {
        try { Initialize-ScapeTheme | Out-Null; Log-Result "Init Theme" "Pass" "" } catch { Log-Result "Init Theme" "Fail" $_.Exception.Message }
    }
    if (Get-Command Initialize-ScapeRenderer -ErrorAction SilentlyContinue) {
        try { Initialize-ScapeRenderer | Out-Null; Log-Result "Init Renderer" "Pass" "" } catch { Log-Result "Init Renderer" "Fail" $_.Exception.Message }
    }

} catch {
    Log-Result "Global Execution" "Fail" $_.Exception.Message
}

$script:results | ConvertTo-Json -Depth 3 | Out-File (Join-Path $Global:AppRoot "validation_output.json") -Encoding utf8
