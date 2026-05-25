$root = 'c:\Users\danie\SCAPE_ROOT'
Set-Location $root
$topo = Get-Content -LiteralPath 'Data\Manifests\Topology.psd1' -Raw
$reg = Get-Content -LiteralPath 'Data\Manifests\Registry.psd1' -Raw
$manifest = [scriptblock]::Create($topo).Invoke()
$registry = [scriptblock]::Create($reg).Invoke()
foreach ($key in $registry.Segments.Keys) {
    if ($key -eq '__Meta__') { continue }
    $seg = $registry.Segments[$key]
    $file = if ($seg -is [hashtable]) { $seg['File'] } else { $seg.File }
    $assetPath = Join-Path -Path $root -ChildPath $file
    if (-not (Test-Path -LiteralPath $assetPath)) { Write-Output "MISSING: $assetPath"; continue }
    try {
        $raw = [System.IO.File]::ReadAllText($assetPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
        [scriptblock]::Create($raw) | Out-Null
    } catch {
        Write-Output "ERROR parsing: $assetPath -> $($_.Exception.Message)"
    }
}
Write-Output 'Done.'
