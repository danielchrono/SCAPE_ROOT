<#
.SYNOPSIS
    Domain: Core
    Module: Scape.Core.Constants
    Description: Pure constant resolver. PASSIVE MODE. Strict-Safe.
#>

function Initialize-ScapeIconLevel {
    try {
        $codePage = [Console]::OutputEncoding.CodePage
        if ($codePage -eq 65001) { Get-ScapeDefaultIconLevel }
        elseif ($codePage -eq 437 -or $codePage -eq 850) { Get-ScapeDefaultIconLevel }
        else { Get-ScapeDefaultIconLevel }
    }
    catch {
        Get-ScapeDefaultIconLevel
    }
}

function Get-ScapeDefaultIconLevel {
    [CmdletBinding()]
    param() # Agora com param() para aceitar o CmdletBinding
    process {
        try {
            $codePage = [Console]::OutputEncoding.CodePage
            # 0: Graphic (UTF8/65001), 1: Unicode (Legacy), 2: ASCII
            if ($codePage -eq 65001) { return 0 }
            if ($codePage -eq 437 -or $codePage -eq 850) { return 1 }
            return 2
        }
        catch { return 2 }
    }
}

function Get-ScapeConstant {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path, $Fallback = $null)
    process {
        $state = Get-ScapeColdState
        if (-not $state.Assets) { return $Path }

        $parts = $Path -split "::"
        $root = $parts[0]
        $asset = $null

        foreach ($cat in $state.Assets.Keys) {
            $foundKey = $state.Assets[$cat].Keys | Where-Object { $_ -ieq $root } | Select-Object -First 1
            if ($foundKey) {
                $asset = $state.Assets[$cat][$foundKey]
                break
            }
        }
        if ($null -eq $asset) { return $Fallback }

        # Navegação robusta em profundidade (Hashtables e PSObjects)
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
