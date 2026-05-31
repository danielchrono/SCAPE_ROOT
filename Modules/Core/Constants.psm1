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
            $foundKey = $assets[$cat].Keys | Where-Object { $_ -ieq $root } | Select-Object -First 1
            if ($foundKey) {
                $asset = $assets[$cat][$foundKey]
                break
            }
        }
        if ($null -eq $asset) { return $Fallback }

        # NavegaÃ§Ã£o robusta em profundidade (Hashtables e PSObjects)
        $current = $asset
        for ($i = 1; $i -lt $parts.Count; $i++) {
            $key = $parts[$i]
            $next = $null

            if ($current -is [System.Collections.IDictionary]) {
                $match = $current.Keys | Where-Object { $_ -ieq $key } | Select-Object -First 1
                if ($match) { $next = $current[$match] }
            }
            elseif ($null -ne $current.PSObject) {
                $match = $current.PSObject.Properties | Where-Object { $_.Name -ieq $key } | Select-Object -First 1
                if ($match) { $next = $match.Value }
            }

            if ($null -eq $next) { return $Fallback }
            $current = $next
        }
        return $current
    }
}

Initialize-ScapeIconLevel
