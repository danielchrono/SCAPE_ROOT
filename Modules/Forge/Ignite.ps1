<#
.SYNOPSIS
    Ignite.ps1 - Bootstrapper Passivo (Loader)
#>
$ErrorActionPreference = "Stop"

# Define a função no escopo GLOBAL para que o AssetManager a encontre
function global:Read-ScapeAssetFile($Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "File not found: $Path" }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $raw = $utf8.GetString($bytes).Trim()
    if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
    return $raw
}

# 1. GARANTIA ABSOLUTA DE MEMÓRIA
if (Get-Variable SCAPE_MEM -Scope Global -ErrorAction SilentlyContinue) {
    Remove-Variable SCAPE_MEM -Scope Global -Force
}
$Global:SCAPE_MEM = @{}

# 2. RESOLUÇÃO DE CAMINHO
$AppRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

$topoPath = Join-Path $AppRoot 'Data\Manifests\Topology.psd1'
$regPath = Join-Path $AppRoot 'Data\Manifests\Registry.psd1'

if (-not (Test-Path $topoPath)) { throw "IGNITE_FATAL: Topology.psd1 não encontrado em $topoPath" }

# 3. HIDRATAÇÃO DOS MANIFESTOS
$Global:SCAPE_MEM['Asset_Topology'] = Read-ScapeAssetFile -Path $topoPath
$Global:SCAPE_MEM['Asset_Registry'] = Read-ScapeAssetFile -Path $regPath

# 4. INJEÇÃO DOS ASSETS NA MATRIZ (Lê Registry)
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

# 5. INJEÇÃO DOS MÓDULOS NA MATRIZ (Lê Topologia)
$topo = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Topology']))
foreach ($domain in $topo.Keys) {
    if ($domain -eq '__Meta__') { continue }
    foreach ($mod in $topo[$domain]) {
        $modName = if ($mod -is [hashtable]) { $mod['Name'] } elseif ($null -ne $mod.PSObject) { $mod.Name } else { '' }
        if ([string]::IsNullOrWhiteSpace($modName)) { continue }

        $fileName = ($modName -split '\.')[-1] + ".psm1"
        $path = Get-ChildItem -Path (Join-Path $AppRoot 'Modules') -Filter $fileName -Recurse -File | Select-Object -First 1

        if ($path) {
            $Global:SCAPE_MEM[$modName] = Read-ScapeAssetFile -Path $path.FullName
        }
    }
}
