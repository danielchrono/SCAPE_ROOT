$uiData = Import-PowerShellDataFile -Path "C:\Users\danie\SCAPE_ROOT\Data\Constants\ui.psd1"

$allPaths = @()

function Get-Paths {
    param($hashtable, $currentPath)
    foreach ($key in $hashtable.Keys) {
        $val = $hashtable[$key]
        $newPath = if ($currentPath) { "$currentPath`::$key" } else { "ui::$key" }
        if ($val -is [hashtable]) {
            $allPaths += $newPath
            Get-Paths -hashtable $val -currentPath $newPath
        } else {
            $allPaths += $newPath
        }
    }
}

Get-Paths -hashtable $uiData -currentPath ""

$unused = @()
$usedCount = 0

$codebaseFiles = Get-ChildItem -Path "C:\Users\danie\SCAPE_ROOT\Modules" -Recurse -Include *.psm1, *.ps1 | Where-Object { $_.FullName -notmatch "\\tests\\" -and $_.FullName -notmatch "\\scratch\\" }

foreach ($path in $allPaths) {
    # Skip the "ui" path itself if present as it's the root
    if ($path -eq "ui") { continue }
    
    $regex = "Get-ScapeConstant.*['""]" + [regex]::Escape($path) + "['""]"
    $found = $false
    foreach ($file in $codebaseFiles) {
        if (Select-String -Path $file.FullName -Pattern $regex -Quiet) {
            $found = $true
            break
        }
    }
    
    # Also we should check if they fetch the parent hashtable and then access the property.
    # Like Get-ScapeConstant -Path "ui::ANSI" ... .ESC
    if (-not $found) {
        # check parent access
        $parts = $path -split "::"
        if ($parts.Count -gt 2) {
            $parentPath = $parts[0..($parts.Count-2)] -join "::"
            $leaf = $parts[-1]
            $parentRegex = "Get-ScapeConstant.*['""]" + [regex]::Escape($parentPath) + "['""]"
            # It's tricky to statically check parent access, let's just do a simple search for the leaf property
            foreach ($file in $codebaseFiles) {
                if (Select-String -Path $file.FullName -Pattern $parentRegex -Quiet) {
                    if (Select-String -Path $file.FullName -Pattern "\.$leaf\b" -Quiet) {
                        $found = $true
                        break
                    }
                }
            }
        }
    }

    if ($found) {
        $usedCount++
    } else {
        $unused += $path
    }
}

Write-Host "Total Constants: $($allPaths.Count)"
Write-Host "Used Constants: $usedCount"
Write-Host "Unused Constants: $($unused.Count)"
$unused | Out-File "C:\Users\danie\SCAPE_ROOT\scratch\unused_constants.txt"

# Also scan for hardcoded integers in presentation layer
Write-Host "`nScanning for hardcoded integers > 10..."
$presentationFiles = Get-ChildItem -Path "C:\Users\danie\SCAPE_ROOT\Modules\Presentation" -Recurse -Include *.psm1, *.ps1
foreach ($file in $presentationFiles) {
    $matches = Select-String -Path $file.FullName -Pattern "(?<!\w|\$|\#|\-|\.|\[|\@|\w+::)(?<!\d)(1[1-9]|[2-9]\d|\d{3,})(?!\d|\w)" -AllMatches
    if ($matches) {
        foreach ($match in $matches.Matches) {
             # Output file, line, and value
             # Wait, Select-String with -AllMatches returns MatchInfo objects.
        }
    }
}
