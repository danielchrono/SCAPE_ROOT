<#
.SYNOPSIS
    Domain: Forge\Ignite
    Module: Scape.Forge.Ignite
    Architecture: Passive Bootstrapper | Memory-Mapped Asset Loader
#>
[CmdletBinding()] param()

$ErrorActionPreference = "Stop"

function global:Read-ScapeAssetFile($Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "File not found: $Path" }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $raw = $utf8.GetString($bytes).Trim()
    if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
    return $raw
}

function Resolve-ScapeForgeModulePath {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$ModuleName
    )

    $parts = $ModuleName -split '\.'
    if ($parts.Count -lt 3) { return $null }

    $domain = $parts[1]
    $leaf = (($parts[2..($parts.Count - 1)] -join '\') + '.psm1')
    $candidate = Join-Path $ProjectRoot ("Modules\$domain\$leaf")
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        return $candidate
    }
    return $null
}

if (Get-Variable SCAPE_MEM -Scope Global -ErrorAction SilentlyContinue) {
    Remove-Variable SCAPE_MEM -Scope Global -Force
}
$Global:SCAPE_MEM = @{}

$AppRoot = $null
if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $AppRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
}
if ([string]::IsNullOrWhiteSpace($AppRoot) -and -not [string]::IsNullOrWhiteSpace($Global:AppRoot)) {
    $AppRoot = $Global:AppRoot
}
if ([string]::IsNullOrWhiteSpace($AppRoot)) {
    $AppRoot = (Get-Location).Path
}

$topoPath = Join-Path $AppRoot 'Data\Manifests\Topology.psd1'
$regPath = Join-Path $AppRoot 'Data\Manifests\Registry.psd1'

if (-not (Test-Path $topoPath)) { throw "IGNITE_FATAL: Topology.psd1 not found at $topoPath" }

$Global:SCAPE_MEM['Asset_Topology'] = Read-ScapeAssetFile -Path $topoPath
$Global:SCAPE_MEM['Asset_Registry'] = Read-ScapeAssetFile -Path $regPath

$reg = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Registry']))
foreach ($key in $reg.Segments.Keys) {
    if ($key -eq '__Meta__') { continue }
    $seg = $reg.Segments[$key]
    $relFile = if ($seg -is [hashtable]) { $seg['File'] } else { $seg.File }
    if ([string]::IsNullOrWhiteSpace($relFile)) { continue }

    $assetPath = Join-Path $AppRoot $relFile
    if (Test-Path $assetPath) {
        $safeName = $relFile -replace '^[Dd]ata[/\\]', '' -replace '[/\\]', '_'
        $Global:SCAPE_MEM["Asset_$safeName"] = Read-ScapeAssetFile -Path $assetPath
    }
}

$topo = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Topology']))
foreach ($domain in $topo.Keys) {
    if ($domain -eq '__Meta__') { continue }
    foreach ($mod in $topo[$domain]) {
        $modName = if ($mod -is [hashtable]) { $mod['Name'] } elseif ($null -ne $mod.PSObject) { $mod.Name } else { '' }
        if ([string]::IsNullOrWhiteSpace($modName)) { continue }

        $path = Resolve-ScapeForgeModulePath -ProjectRoot $AppRoot -ModuleName $modName
        if ($path) {
            $Global:SCAPE_MEM[$modName] = Read-ScapeAssetFile -Path $path
        }
    }
}

Export-ModuleMember -Function 'Read-ScapeAssetFile',
    'Resolve-ScapeForgeModulePath'
