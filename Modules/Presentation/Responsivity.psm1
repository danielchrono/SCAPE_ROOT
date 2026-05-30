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

function Set-ScapeViewportLocks {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        try {
            $layout = Get-ScapeConstant -Path "ui::Layout"
            $minWidth = if ($layout.MinWidth) { $layout.MinWidth } else { 80 }
            $minHeight = if ($layout.MinHeight) { $layout.MinHeight } else { 24 }

            $raw = $Host.UI.RawUI
            $curW = $raw.WindowSize.Width
            $curH = $raw.WindowSize.Height

            $newW = [Math]::Max($curW, $minWidth)
            $newH = [Math]::Max($curH, $minHeight)

            if ($curW -lt $newW -or $curH -lt $newH) {
                # Se precisa crescer, ajusta o Buffer primeiro para comportar a nova Window
                $bSize = $raw.BufferSize
                if ($newW -gt $bSize.Width) { $bSize.Width = $newW }
                if ($newH -gt $bSize.Height) { $bSize.Height = $newH }
                $raw.BufferSize = $bSize

                $wSize = $raw.WindowSize
                $wSize.Width = $newW
                $wSize.Height = $newH
                $raw.WindowSize = $wSize
            }
        }
        catch { }
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