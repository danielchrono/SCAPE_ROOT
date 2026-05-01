<#
.SYNOPSIS
    Domain: Presentation\Responsivity
    Module: Scape.Presentation.Responsivity
    Architecture: Viewport State Tracker | Resize Watchdog | Pure Detection
#>
[CmdletBinding()] param()

function Initialize-ScapeViewportState {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    process {
        $current = Get-ScapeConsoleDimension -WithMargins
        return @{
            Width      = $current.Width
            Height     = $current.Height
            LastWidth  = $current.Width
            LastHeight = $current.Height
            HasResized = $false
        }
    }
}

function Get-ScapeConsoleDimension {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $false)][switch]$WithMargins)
    process {
        try {
            $raw = $Host.UI.RawUI
            $w = $raw.WindowSize.Width
            $h = $raw.WindowSize.Height
            $margin = if ($WithMargins) { 4 } else { 0 }

            return @{
                Width  = [Math]::Max(60, [Math]::Min($w - $margin, 140))
                Height = [Math]::Max(15, $h - 5)
            }
        }
        catch {
            $null = $_ # PSScriptAnalyzer Fix
            return @{ Width = 80; Height = 25 }
        }
    }
}

function Test-ScapeViewportChanged {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)][hashtable]$ViewportState)
    process {
        $current = Get-ScapeConsoleDimension -WithMargins
        $widthChanged = $current.Width -ne $ViewportState.LastWidth
        $heightChanged = $current.Height -ne $ViewportState.LastHeight

        if ($widthChanged -or $heightChanged) {
            $ViewportState.LastWidth = $current.Width
            $ViewportState.LastHeight = $current.Height
            $ViewportState.HasResized = $true
            return $true
        }
        $ViewportState.HasResized = $false
        return $false
    }
}

function Get-ScapeSafeCoordinate {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][int]$Left,
        [Parameter(Mandatory = $true)][int]$Top
    )
    process {
        $dims = Get-ScapeConsoleDimension
        return @{
            Left = [Math]::Max(0, [Math]::Min($Left, $dims.Width - 1))
            Top  = [Math]::Max(0, [Math]::Min($Top, $dims.Height - 1))
        }
    }
}