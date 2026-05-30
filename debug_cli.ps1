<# SCAPE DEBUG CLI #>
$ErrorActionPreference = "Stop"
Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue

$Global:AppRoot = $PSScriptRoot
$topoPath = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Topology.psd1"
$regPath  = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Registry.psd1"

$rawTopo = [System.IO.File]::ReadAllText($topoPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
$rawReg  = [System.IO.File]::ReadAllText($regPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
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

$coreMods = $manifest["Core"] | Sort-Object LoadOrder
$loadedCore = [System.Collections.Generic.List[string]]::new()
foreach ($mod in $coreMods) {
    $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }
    $foundPath = Resolve-ScapeModulePath -ModuleName $modName
    if ($foundPath) { Import-Module $foundPath -Global -Force; $loadedCore.Add($modName) }
}

Initialize-ScapeState | Out-Null
Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot; Registry = $registry; MANIFEST = $manifest; LoadedLayers = $loadedCore } -Confirm:$false | Out-Null

if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }
if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }

Write-Host "[DEBUG] SCAPE Core Engine Loaded Successfully" -ForegroundColor Green
Write-Host "Available Global Variables:"
Write-Host " - `$manifest : Topology"
Write-Host " - `$registry : Registry"
Write-Host ""
Write-Host "Useful Debug Commands:"
Write-Host " > Get-ScapeColdState"
Write-Host " > Get-ScapeConstant -Path 'system::Behavior::WATCHDOG_TIMEOUT_SEC'"
Write-Host " > Publish-ScapeEvent -Type 'MY_TEST' -Severity 'INFO' -Payload 'Hello'"
Write-Host " > Resolve-ScapeManifestLayer -LayerKey 'Infrastructure'"
Write-Host "======================================================="

# Enter interactive mode for the user
$host.EnterNestedPrompt()
