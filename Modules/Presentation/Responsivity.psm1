<#
.SYNOPSIS
    Domain: Presentation\Responsivity
    Module: Scape.Presentation.Responsivity
    Architecture: Viewport State Tracker | Resize Watchdog | Smart Pagination
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

function Test-ScapeViewportChanged {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][int]$LastWidth,
        [Parameter(Mandatory = $true)][int]$LastHeight
    )
    process {
        $current = Get-ScapeConsoleDimension -WithMargins
        $widthChanged = $current.Width -ne $LastWidth
        $heightChanged = $current.Height -ne $LastHeight

        if ($widthChanged -or $heightChanged) {
            return @{
                HasResized = $true
                NewWidth = $current.Width
                NewHeight = $current.Height
            }
        }
        return @{ HasResized = $false }
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

function Set-ScapeViewportLocks {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        # Resizing the console is a Host side-effect and should not be done by the View layer.
        # The View must simply adapt to the available size.
    }
}

function Get-ScapeViewportRange {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][int]$TotalItems,
        [Parameter(Mandatory = $true)][int]$CursorIndex,
        [Parameter(Mandatory = $true)][int]$AvailableHeight
    )
    process {
        if ($TotalItems -le 0) { return @{ Start = 0; End = 0; Visible = 0 } }

        $visible = [Math]::Min($TotalItems, $AvailableHeight)

        if ($visible -eq $TotalItems) {
            return @{ Start = 0; End = $TotalItems; Visible = $visible }
        }

        $centerOffset = [Math]::Floor($visible / 2)

        if ($CursorIndex -lt $centerOffset) {
            $start = 0
        }
        elseif ($CursorIndex -gt ($TotalItems - ($visible - $centerOffset))) {
            $start = $TotalItems - $visible
        }
        else {
            $start = $CursorIndex - $centerOffset
        }

        $start = [Math]::Max(0, [Math]::Min($start, $TotalItems - $visible))
        $end = [Math]::Min($start + $visible, $TotalItems)

        return @{ Start = $start; End = $end; Visible = $visible }
    }
}