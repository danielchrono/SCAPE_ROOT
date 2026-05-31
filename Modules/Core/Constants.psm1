<#
.SYNOPSIS
    Domain: Core
    Module: Scape.Core.Constants
    Description: Pure constant resolver. PASSIVE MODE. Strict-Safe.
#>

function Initialize-ScapeIconLevel {
    # System enforces UTF-8. Safe to assume Level 0.
    Get-ScapeDefaultIconLevel
}

function Get-ScapeDefaultIconLevel {
    [CmdletBinding()]
    param()
    process {
        return 0
    }
}

$Script:ConstantsCache = $null

function Get-ScapeConstant {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path, $Fallback = $null)
    process {
        if ($null -eq $Script:ConstantsCache) {
            $state = Get-ScapeColdState
            if (-not $state.Assets) { return $Path }
            $Script:ConstantsCache = $state.Assets
        }
        $assets = $Script:ConstantsCache

        $parts = $Path -split "::"
        $root = $parts[0]
        $asset = $null

        foreach ($cat in $assets.Keys) {
            $catHash = $assets[$cat]
            if ($catHash.ContainsKey($root)) {
                $asset = $catHash[$root]
                break
            }
            # Fallback case-insensitive
            foreach ($k in $catHash.Keys) {
                if ($k -ieq $root) {
                    $asset = $catHash[$k]
                    break
                }
            }
            if ($null -ne $asset) { break }
        }
        if ($null -eq $asset) { return $Fallback }

        # Navegação robusta em profundidade (Hashtables e PSObjects)
        $current = $asset
        for ($i = 1; $i -lt $parts.Count; $i++) {
            $key = $parts[$i]
            $next = $null

            if ($current -is [System.Collections.IDictionary]) {
                if ($current.ContainsKey($key)) {
                    $next = $current[$key]
                } else {
                    foreach ($k in $current.Keys) {
                        if ($k -ieq $key) { $next = $current[$k]; break }
                    }
                }
            }
            elseif ($null -ne $current.PSObject) {
                $prop = $current.PSObject.Properties[$key]
                if ($null -ne $prop) {
                    $next = $prop.Value
                } else {
                    foreach ($p in $current.PSObject.Properties) {
                        if ($p.Name -ieq $key) { $next = $p.Value; break }
                    }
                }
            }

            if ($null -eq $next) { return $Fallback }
            $current = $next
        }
        if ($current -is [string] -and $current -match '\$\(\[char\]27\)') {
            return $current.Replace('$([char]27)', [char]27)
        }
        return $current
    }
}

Initialize-ScapeIconLevel

Export-ModuleMember -Function 'Initialize-ScapeIconLevel',
    'Get-ScapeDefaultIconLevel',
    'Get-ScapeConstant'
