<#
.SYNOPSIS
    Domain: Presentation\Geometry
    Module: Scape.Presentation.Geometry
    Architecture: Pure Math Functions | Immutable Bounds | Zero Hardcode
#>
[CmdletBinding()] param()

function Get-ScapeMenuLayout {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)][int]$MaxContentWidth,
        [Parameter(Mandatory = $true)][int]$ItemCount,
        [Parameter(Mandatory = $true)][int]$ConsoleWidth,
        [Parameter(Mandatory = $true)][int]$ConsoleHeight,
        [int]$HeaderHeight = 0,
        [int]$MinWidth = 40
    )
    process {
        $boxW = [Math]::Min($ConsoleWidth - 4, [Math]::Max($MinWidth, $MaxContentWidth + 6))
        $boxH = $ItemCount + 4

        $x = [Math]::Floor(($ConsoleWidth - $boxW) / 2)
        $y = [Math]::Max($HeaderHeight + 1, [Math]::Floor(($ConsoleHeight - $boxH) / 2))

        return [PSCustomObject]@{
            X = [int]$x; Y = [int]$y
            Width = [int]$boxW; Height = [int]$boxH
            UsableWidth = [int]($boxW - 4)
        }
    }
}

function Get-ScapeScrollViewport {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)][int]$TotalItems,
        [Parameter(Mandatory = $true)][int]$MaxVisibleItems,
        [Parameter(Mandatory = $true)][int]$CursorIndex
    )
    process {
        if ($TotalItems -le $MaxVisibleItems) { return [PSCustomObject]@{ StartIndex = 0; EndIndex = $TotalItems - 1; NeedsScroll = $false } }

        $halfView = [Math]::Floor($MaxVisibleItems / 2)
        $start = [Math]::Max(0, $CursorIndex - $halfView)
        $end = $start + $MaxVisibleItems - 1

        if ($end -ge $TotalItems) {
            $end = $TotalItems - 1
            $start = [Math]::Max(0, $end - $MaxVisibleItems + 1)
        }

        return [PSCustomObject]@{
            StartIndex = $start; EndIndex = $end; NeedsScroll = $true
            ScrollPercent = [Math]::Round(($CursorIndex / ($TotalItems - 1)) * 100, 2)
        }
    }
}

function Get-ScapeDialogLayout {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)][int]$ConsoleWidth,
        [Parameter(Mandatory = $true)][int]$ConsoleHeight,
        [Parameter(Mandatory = $true)][int]$DialogWidth,
        [Parameter(Mandatory = $true)][int]$DialogHeight
    )
    process {
        $w = [Math]::Min($ConsoleWidth - 4, $DialogWidth)
        $h = [Math]::Min($ConsoleHeight - 4, $DialogHeight)

        $x = [Math]::Floor(($ConsoleWidth - $w) / 2)
        $y = [Math]::Floor(($ConsoleHeight - $h) / 2)

        return [PSCustomObject]@{
            X = [int]$x; Y = [int]$y
            Width = [int]$w; Height = [int]$h
            UsableWidth = [int]($w - 4); IsClipped = ($DialogWidth -gt $w -or $DialogHeight -gt $h)
        }
    }
}

function Get-ScapeJustifiedPadding {
    [CmdletBinding()]
    [OutputType([string])]
    param([string]$LeftText, [string]$RightText, [int]$TotalWidth)
    process {
        $needed = [Math]::Max(0, $TotalWidth - ($LeftText.Length + $RightText.Length))
        return (' ' * $needed)
    }
}

function Get-ScapeFrameCoordinate {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([int]$X, [int]$Y, [int]$Width, [int]$Height)
    process {
        return [PSCustomObject]@{
            TopLeft     = @{ X = $X; Y = $Y }
            Inner       = @{ X = $X + 1; Y = $Y + 1; W = $Width - 2; H = $Height - 2 }
            BottomRight = @{ X = $X + $Width - 1; Y = $Y + $Height - 1 }
        }
    }
}

function Get-ScapeProgressMath {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([double]$Current, [double]$Total, [int]$AvailableWidth)
    process {
        if ($Total -le 0) { return [PSCustomObject]@{ Filled = 0; Empty = $AvailableWidth; Percent = 0 } }

        $percent = [Math]::Min(100, [Math]::Max(0, ($Current / $Total) * 100))
        $filledChars = [Math]::Floor(($percent / 100) * $AvailableWidth)

        return [PSCustomObject]@{
            Filled  = [int]$filledChars
            Empty   = [int]($AvailableWidth - $filledChars)
            Percent = [Math]::Round($percent, 1)
        }
    }
}

function Get-ScapeClampedValue {
    [CmdletBinding()]
    [OutputType([int])]
    param([int]$Value, [int]$Minimum, [int]$Maximum)
    process { return [Math]::Max($Minimum, [Math]::Min($Maximum, $Value)) }
}