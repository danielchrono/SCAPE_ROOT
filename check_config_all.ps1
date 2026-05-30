$ErrorActionPreference = 'SilentlyContinue'

$constantsPath = "c:\Users\danie\SCAPE_ROOT\Data\Constants"
$modulesPath = "c:\Users\danie\SCAPE_ROOT\Modules"

function Get-HashByPath($hash, $path) {
    if (!$hash -or !$path) { return $null }
    $parts = $path -split '::'
    $curr = $hash
    foreach ($p in $parts) {
        if ($curr -is [System.Collections.Hashtable] -and $curr.ContainsKey($p)) {
            $curr = $curr[$p]
        } elseif ($curr -is [System.Management.Automation.PSCustomObject]) {
            # in case it evaluates to object
            if ($null -ne $curr.$p) {
                $curr = $curr.$p
            } else { return $null }
        } else {
            return $null
        }
    }
    return $curr
}

$files = Get-ChildItem "$constantsPath\*.psd1" | Select-Object -ExpandProperty Name
$Hashes = @{}
foreach ($f in $files) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($f)
    $Hashes[$name] = Invoke-Expression (Get-Content "$constantsPath\$f" -Raw -Encoding UTF8)
}

# Find all paths
$paths = @()
$psm1Files = Get-ChildItem -Path $modulesPath -Include *.psm1,*.ps1 -Recurse
foreach ($file in $psm1Files) {
    $content = Get-Content $file.FullName -Raw
    $matches = [regex]::Matches($content, 'Get-ScapeConstant\s+-Path\s+"([^"]+)"')
    foreach ($m in $matches) {
        $paths += $m.Groups[1].Value
    }
}

$paths = $paths | Select-Object -Unique

Write-Output "### All Missing Configurations"
foreach ($k in $paths) {
    if ($k -match '\$') { continue } # skip dynamic paths
    $root = ($k -split '::')[0]
    if ($Hashes.ContainsKey($root)) {
        $val = Get-HashByPath $Hashes[$root] ($k -replace "^$root::", "")
        if ($null -eq $val) {
            Write-Output "MISSING IN FILE: $k"
        }
    } else {
        Write-Output "MISSING ROOT FILE: $k"
    }
}
