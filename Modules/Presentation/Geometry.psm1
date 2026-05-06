<#
.SYNOPSIS
    Domain: Presentation\Geometry
    Module: Scape.Presentation.Geometry
    Architecture: Pure Math | Immutable Bounds | String Clipping | Zero Hardcode (Reads ui.psd1)
#>
[CmdletBinding()] param()

function Get-ScapeConsoleDimension {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([switch]$WithMargins)
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        try {
            $raw = $Host.UI.RawUI
            $w = $raw.WindowSize.Width
            $h = $raw.WindowSize.Height
            $margin = if ($WithMargins) { $layout.Margin * 2 } else { 0 }

            return @{
                Width  = [Math]::Max($layout.MinWidth, [Math]::Min($w - $margin, $layout.MaxWidth))
                Height = [Math]::Max($layout.MinHeight, $h - $layout.HeaderHeight)
            }
        }
        catch {
            throw "Unable to obtain console dimensions"
        }
    }
}

function Get-ScapeMenuLayout {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)][int]$MaxContentWidth,
        [Parameter(Mandatory = $true)][int]$ItemCount,
        [Parameter(Mandatory = $true)][int]$ConsoleWidth,
        [Parameter(Mandatory = $true)][int]$ConsoleHeight,
        [int]$HeaderHeight = 0
    )
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"

        $boxW = [Math]::Min($ConsoleWidth - ($layout.Margin * 2), [Math]::Max($layout.MinWidth, $MaxContentWidth + 6))
        $boxH = $ItemCount

        $x = [Math]::Max(0, [Math]::Floor(($ConsoleWidth - $boxW) / 2))
        $y = [Math]::Max($HeaderHeight + $layout.Padding, [Math]::Floor(($ConsoleHeight - ($boxH + ($layout.Padding * 2))) / 2))

        return [PSCustomObject]@{
            X = [int]$x; Y = [int]$y
            Width = [int]$boxW; Height = [int]$boxH
            UsableWidth = [int]($boxW - ($layout.Margin * 2))
        }
    }
}

function Get-ScapeFrameCoordinates {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][psobject]$BoxLayout)
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        return @{
            TitleX     = $BoxLayout.X + $layout.TitlePadding
            TitleY     = $BoxLayout.Y
            LeftWallX  = $BoxLayout.X
            RightWallX = $BoxLayout.X + $BoxLayout.Width - 1
            BottomY    = $BoxLayout.Y + $BoxLayout.Height + 1
            ContentX   = $BoxLayout.X + $layout.TitlePadding
            ContentY   = $BoxLayout.Y + 1
        }
    }
}

function Get-ScapeGridCoordinates {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][psobject]$BoxLayout,
        [Parameter(Mandatory = $false)][string]$ActiveIcon = '',
        [Parameter(Mandatory = $false)][int]$Index = 0
    )
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        $baseX = $BoxLayout.X
        $iconX = $baseX + 1 + $layout.Padding

        if (-not [string]::IsNullOrWhiteSpace($ActiveIcon)) {
            $plainIconLen = Get-ScapePlainTextLength -Text $ActiveIcon
            $textX = $iconX + [Math]::Max($plainIconLen + 1, 4)
        }
        else {
            $textX = $iconX + 2
        }

        return @{
            SelectorX = $baseX + 1
            IconX     = $iconX
            TextX     = $textX
            RightEdge = $baseX + $BoxLayout.Width - 1 - $layout.Padding
            Y         = $BoxLayout.Y + 1 + $Index
        }
    }
}

function Invoke-ScapeStringClip {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$MaxWidth,
        [switch]$CenterClip
    )
    process {
        $plain = $Text -replace '\x1B\[[0-9;]*[a-zA-Z]', ''
        $len = $plain.Length

        if ($len -le $MaxWidth) { return $Text }

        if ($CenterClip) {
            $cut = [Math]::Floor(($len - $MaxWidth) / 2)
            return $Text.Substring($cut, $MaxWidth)
        }
        else {
            if ($MaxWidth -le 5) { return "..." }
            $overflow = $len - $MaxWidth
            return "..." + $Text.Substring($overflow + 3)
        }
    }
}
