<#
.SYNOPSIS
    Domain: Presentation\Geometry
    Module: Scape.Presentation.Geometry
    Architecture: Pure Math | Immutable Bounds | Responsivity-Integrated | Zero Hardcode
    [PATCH] Geometry now consumes Responsivity automatically; added viewport locks
#>
[CmdletBinding()] param()

function Initialize-ScapeGeometry {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        # Geometry agora é Math-only. Locks/Viewport estatais devem ser
        # chamados pela orquestração principal (ViewModel), não aqui.
    }
}

function Get-ScapeMenuLayout {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $false)][int]$MaxContentWidth = 0,
        [Parameter(Mandatory = $true)][int]$ItemCount,
        [Parameter(Mandatory = $true)][int]$ConsoleWidth,
        [Parameter(Mandatory = $true)][int]$ConsoleHeight,
        [int]$HeaderHeight = 0
    )
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"

        if ($MaxContentWidth -le 0) {
            $MaxContentWidth = Get-ScapeConstant -Path "ui::Config::DefaultWidth" -Fallback 80
        }

        # Expand box width slightly to safely accommodate icons and 3 columns
        $minBoxW = [Math]::Max($layout.MinWidth, $MaxContentWidth + ($layout.Padding * 2) + ($layout.Margin * 2))
        $safeZone = if ($layout.SafeZoneWidth) { $layout.SafeZoneWidth } else { 10 }
        $boxW = [Math]::Min($ConsoleWidth - ($layout.Margin * 2), [Math]::Max($minBoxW, $MaxContentWidth + $safeZone))
        $boxH = [Math]::Max(1, $ItemCount)

        $x = [Math]::Max($layout.Margin, [Math]::Floor(($ConsoleWidth - $boxW) / 2))
        $y = [Math]::Max($HeaderHeight + $layout.Padding, [Math]::Floor(($ConsoleHeight - ($boxH + ($layout.Padding * 2))) / 2))

        $usable = [int]($boxW - ($layout.Margin * 2))
        if ($usable -lt $safeZone) { $usable = $safeZone }

        return [PSCustomObject]@{
            X = [int]$x; Y = [int]$y
            Width = [int]$boxW; Height = [int]$boxH
            UsableWidth = $usable
            MarginLeft = $layout.Margin
            MarginRight = $layout.Margin
        }
    }
}

function Get-ScapeFrameCoordinate {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][psobject]$BoxLayout)
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        return @{
            TitleX            = $BoxLayout.X + $layout.TitlePadding
            TitleY            = $BoxLayout.Y
            LeftWallX         = $BoxLayout.X
            RightWallX        = $BoxLayout.X + $BoxLayout.Width - 1
            BottomY           = $BoxLayout.Y + $BoxLayout.Height + 1
            ContentX          = $BoxLayout.X + $layout.TitlePadding
            ContentY          = $BoxLayout.Y + 1
            SafeContentTop    = $BoxLayout.Y + 1
            SafeContentBottom = $BoxLayout.Y + $BoxLayout.Height
        }
    }
}

function Get-ScapeGridCoordinate {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][psobject]$BoxLayout,
        [Parameter(Mandatory = $false)][string]$ActiveIcon = '',
        [Parameter(Mandatory = $false)][int]$Index = 0,
        [Parameter(Mandatory = $false)][int]$ViewportOffset = 0
    )
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        $baseX = $BoxLayout.X

        $selectorX = $baseX + 1
        $iconColStart = $selectorX + 2
        $iconColWidth = if ($layout.IconColumnWidth) { $layout.IconColumnWidth } else { 5 }

        $plainIconLen = 0
        if (-not [string]::IsNullOrWhiteSpace($ActiveIcon)) {
            $plainIconLen = Get-ScapeVisualWidth -Text $ActiveIcon
        }

        # Centro do ícone no espaço de 5 colunas
        $iconPad = [Math]::Max(0, [Math]::Floor(($iconColWidth - $plainIconLen) / 2))
        $iconX = $iconColStart + $iconPad

        $textX = $iconColStart + $iconColWidth + 1

        # Clamp text column to remain inside usable box area
        $rightEdgeCalc = $baseX + $BoxLayout.Width - 2 - $layout.Padding
        if ($textX -ge $rightEdgeCalc) { $textX = [Math]::Max($selectorX + 4, $rightEdgeCalc - 1) }

        $rawY = $BoxLayout.Y + 1 + $Index
        $adjustedY = $rawY - $ViewportOffset

        return @{
            SelectorX = $selectorX
            IconX     = $iconX
            TextX     = $textX
            RightEdge = $rightEdgeCalc
            Y         = $adjustedY
            SafeLeft  = $baseX + $layout.Margin
            SafeRight = $baseX + $BoxLayout.Width - 1 - $layout.Margin
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
        $plain = $Text -replace (Get-ScapeConstant -Path "ui::ANSI::AnsiStripRegex"), ''
        $len = $plain.Length

        if ($len -le $MaxWidth) { return $Text }

        if ($CenterClip) {
            $cut = [Math]::Floor(($len - $MaxWidth) / 2)
            return $plain.Substring($cut, $MaxWidth)
        }
        else {
            if ($MaxWidth -le 5) { return (Get-ScapeConstant -Path "ui::Icons::Ellipsis" -Fallback "...") }
            $overflow = $len - $MaxWidth
            return (Get-ScapeConstant -Path "ui::Icons::Ellipsis" -Fallback "...") + $plain.Substring($overflow + 3)
        }
    }
}

# [RESPONSIVITY] Função helper para clamping de coordenadas
function Get-ScapeClampedCoordinate {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][int]$Left,
        [Parameter(Mandatory = $true)][int]$Top,
        [Parameter(Mandatory = $true)][int]$ConsoleWidth,
        [Parameter(Mandatory = $true)][int]$ConsoleHeight
    )
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        return @{
            Left = [Math]::Max($layout.Margin, [Math]::Min($Left, $ConsoleWidth - $layout.Margin - 1))
            Top  = [Math]::Max($layout.HeaderHeight, [Math]::Min($Top, $ConsoleHeight - 1))
        }
    }
}
function Get-ScapePlainTextLength {
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowEmptyString()][string]$Text = '')
    process {
        if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
        return ($Text -replace (Get-ScapeConstant -Path "ui::ANSI::AnsiStripRegex"), '').Length
    }
}

function Get-ScapeVisualWidth {
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)][string]$Text)
    process {
        if ([string]::IsNullOrEmpty($Text)) { return 0 }
        $clean = $Text -replace (Get-ScapeConstant -Path "ui::ANSI::AnsiStripRegex"), ''
        if ([string]::IsNullOrEmpty($clean)) { return 0 }

        $len = $clean.Length
        # Match wide characters in common CJK ranges and others
        $wideCount = [regex]::Matches($clean, '[\u2E80-\u9FFF\uAC00-\uD7AF\uF900-\uFAFF]').Count
        return $len + $wideCount
    }
}

function Get-ScapeJustifiedPadding {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$LeftText,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$RightText,
        [Parameter(Mandatory = $true)][int]$TotalWidth
    )
    process {
        $lenL = Get-ScapePlainTextLength -Text $LeftText
        $lenR = Get-ScapePlainTextLength -Text $RightText
        $padCount = $TotalWidth - ($lenL + $lenR)
        if ($padCount -le 0) { return " " }
        return " " * $padCount
    }
}

function Get-ScapeBannerVariant {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][int]$ConsoleHeight,
        [Parameter(Mandatory = $true)][int]$ItemCount,
        [Parameter(Mandatory = $true)][int]$HeaderHeight
    )
    process {
        $layout = Get-ScapeConstant -Path "ui::Layout"
        $threshold = if ($layout -and $null -ne $layout.BannerBreakpoint) { $layout.BannerBreakpoint } else { (Get-ScapeConstant -Path "system::ANALYSIS::BANNER_BREAKPOINT") }
        if ($ItemCount -ge 5 -or ($ItemCount + $HeaderHeight + 10) -ge $ConsoleHeight -or $ConsoleHeight -le $threshold) {
            return 'Compact'
        }
        return 'Standard'
    }
}

Export-ModuleMember -Function 'Initialize-ScapeGeometry',
'Get-ScapeMenuLayout',
'Get-ScapeFrameCoordinate',
'Get-ScapeGridCoordinate',
'Invoke-ScapeStringClip',
'Get-ScapeClampedCoordinate',
'Get-ScapePlainTextLength',
'Get-ScapeVisualWidth',
'Get-ScapeJustifiedPadding',
'Get-ScapeBannerVariant'
