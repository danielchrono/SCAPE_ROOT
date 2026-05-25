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
        # chamados pela orquestração principal (Controller), não aqui.
    }
}

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

            $calcW = $w - $margin
            $calcH = $h # Do not subtract HeaderHeight here, Renderer handles actual banner height

            # Se MaxWidth for 0, deixa usar a largura infinita da tela
            $finalW = if ($layout.MaxWidth -gt 0) { [Math]::Min($calcW, $layout.MaxWidth) } else { $calcW }
            $finalH = if ($layout.MaxHeight -gt 0) { [Math]::Min($calcH, $layout.MaxHeight) } else { $calcH }

            # Safe constraints: Never exceed physical window size!
            $safeW = [Math]::Max($layout.MinWidth, $finalW)
            $safeW = [Math]::Min($safeW, $w)

            $safeH = [Math]::Max($layout.MinHeight, $finalH)
            $safeH = [Math]::Min($safeH, $h)

            return @{
                Width  = $safeW
                Height = $safeH
            }
        }
        catch {
            # Fallback seguro
            return @{ Width = 80; Height = 20; ViewportStart = 0; ViewportEnd = 20 }
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

        # Expand box width slightly to safely accommodate icons and 3 columns
        $minBoxW = [Math]::Max($layout.MinWidth, $MaxContentWidth + ($layout.Padding * 2) + ($layout.Margin * 2))
        $boxW = [Math]::Min($ConsoleWidth - ($layout.Margin * 2), [Math]::Max($minBoxW, $MaxContentWidth + 10))
        $boxH = [Math]::Max(1, $ItemCount)

        $x = [Math]::Max($layout.Margin, [Math]::Floor(($ConsoleWidth - $boxW) / 2))
        $y = [Math]::Max($HeaderHeight + $layout.Padding, [Math]::Floor(($ConsoleHeight - ($boxH + ($layout.Padding * 2))) / 2))

        $usable = [int]($boxW - ($layout.Margin * 2))
        if ($usable -lt 10) { $usable = 10 }

        return [PSCustomObject]@{
            X = [int]$x; Y = [int]$y
            Width = [int]$boxW; Height = [int]$boxH
            UsableWidth = $usable
            MarginLeft  = $layout.Margin
            MarginRight = $layout.Margin
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

function Get-ScapeGridCoordinates {
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
        $iconColWidth = 5

        $plainIconLen = 0
        if (-not [string]::IsNullOrWhiteSpace($ActiveIcon)) {
            if (Get-Command Get-ScapePlainTextLength -ErrorAction SilentlyContinue) {
                $plainIconLen = Get-ScapePlainTextLength -Text $ActiveIcon
            } else {
                $plainIconLen = ($ActiveIcon -replace '\x1B\[[0-9;]*[a-zA-Z]', '').Length
            }
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

# [RESPONSIVITY] Função helper para clamping de coordenadas
function Get-ScapeClampedCoordinate {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][int]$Left,
        [Parameter(Mandatory = $true)][int]$Top,
        [Parameter(Mandatory = $false)][int]$MinWidth = 0,
        [Parameter(Mandatory = $false)][int]$MinHeight = 0
    )
    process {
        $dims = Get-ScapeConsoleDimension
        $layout = Get-ScapeConstant -Path "ui::Layout"

        return @{
            Left = [Math]::Max($layout.Margin, [Math]::Min($Left, $dims.Width - $layout.Margin - 1))
            Top  = [Math]::Max($layout.HeaderHeight, [Math]::Min($Top, $dims.Height - 1))
        }
    }
}