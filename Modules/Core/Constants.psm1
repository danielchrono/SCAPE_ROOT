<#
.SYNOPSIS
    Domain: Core
    Module: Scape.Core.Constants
    Description: Pure constant resolver. PASSIVE MODE. Strict-Safe.
#>

$Script:IconLevel = 2

function Initialize-ScapeIconLevel {
    try {
        $codePage = [Console]::OutputEncoding.CodePage
        if ($codePage -eq 65001) { $Script:IconLevel = 0 }
        elseif ($codePage -eq 437 -or $codePage -eq 850) { $Script:IconLevel = 1 }
        else { $Script:IconLevel = 2 }
    } catch {
        $Script:IconLevel = 2
    }
}
Initialize-ScapeIconLevel

function Get-ScapeConstant {
    param([Parameter(Mandatory=$true)][string]$Path, $Fallback = $null)
    process {
        $state = Get-ScapeColdState
        if (-not $state.Assets) { return $Fallback }

        $parts = $Path -split "::"
        $root = $parts[0].ToLower()

        # Busca funcional no Graal de Assets
        $asset = $null
        foreach ($cat in $state.Assets.Keys) {
            if ($state.Assets[$cat].ContainsKey($root)) {
                $asset = $state.Assets[$cat][$root]
                break
            }
        }
        if ($null -eq $asset) { return $Fallback }

        # Navegação de profundidade pura
        $current = $asset
        for ($i = 1; $i -lt $parts.Count; $i++) {
            $key = $parts[$i]
            $next = Get-ScapeProperty -Object $current -PropertyName $key -Fallback $null
            if ($null -eq $next) { return $Fallback }
            $current = $next
        }
        return $current
    }
}