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
            $minWidth = $layout.MinWidth
            $minHeight = $layout.MinHeight

            $raw = $Host.UI.RawUI
            $curW = $raw.WindowSize.Width
            $curH = $raw.WindowSize.Height

            $needsFix = $false
            $newW = $curW
            $newH = $curH

            if ($curW -lt $minWidth) { $newW = $minWidth; $needsFix = $true }
            if ($curH -lt $minHeight) { $newH = $minHeight; $needsFix = $true }

            if ($needsFix) {
                $size = New-Object System.Management.Automation.Host.Size($newW, $newH)
                $raw.WindowSize = $size
                $raw.BufferSize = New-Object System.Management.Automation.Host.Size($newW, 9000)
            }
        }
        catch { }
    }
}
