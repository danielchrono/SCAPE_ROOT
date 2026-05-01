<#
.SYNOPSIS
    Domain: Presentation\Renderer
    Module: Scape.Presentation.Renderer
    Architecture: Delta Render | MVVM View | Zero Flicker | Pure Styling
#>
[CmdletBinding()] param()

$Script:R = [PSCustomObject]@{ Cache = $null; LastMenuId = [string]::Empty; LastCursor = -1; BoxCache = $null }

function Initialize-ScapeRenderer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        $Script:R.Cache = [PSCustomObject]@{ UI = Get-ScapeConstant -Path "ui" -Fallback @{}; THEME = Get-ScapeConstant -Path "theme" -Fallback @{} }
    }
}

function Get-ScapeResolvedIcon {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string]$RouteId)
    process {
        $semanticMap = Get-ScapeConstant -Path "ui::SemanticMap" -Fallback @{}
        $semanticKey = if ($semanticMap.ContainsKey($RouteId)) { $semanticMap[$RouteId] } else { "DEFAULT" }

        $iconsMap = Get-ScapeConstant -Path "ui::Icons" -Fallback @{}
        $iconNode = if ($iconsMap.ContainsKey($semanticKey)) { $iconsMap[$semanticKey] } else { $iconsMap["Unknown"] }

        if ($null -eq $iconNode) { return "•" }

        $list = if ($iconNode -is [array]) { $iconNode } else { @($iconNode) }
        $idx = 0
        if ($null -ne $Script:IconLevel) { $idx = [Math]::Min($Script:IconLevel, $list.Count - 1) }
        return $list[$idx]
    }
}

function Format-ScapeFrame {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [Parameter(Mandatory = $true)][int]$Width,
        [Parameter(Mandatory = $true)][int]$Height,
        [Parameter(Mandatory = $true)][string]$StyleKey
    )
    process {
        $frames = Get-ScapeConstant -Path "ui::Frames" -Fallback @{}
        $f = if ($frames.ContainsKey($StyleKey)) { $frames[$StyleKey] } else { $frames["Classic"] }

        $top = $f.TL + ($f.HL * ($Width - 2)) + $f.TR
        $mid = $f.VL + (" " * ($Width - 2)) + $f.VL
        $bot = $f.BL + ($f.HL * ($Width - 2)) + $f.BR

        Set-ScapeCursorPosition -Left $X -Top $Y; Write-Output (Format-ScapeANSIMessage -Text $top -Flag "MENU") -NoNewline
        for ($i = 1; $i -lt ($Height - 1); $i++) {
            Set-ScapeCursorPosition -Left $X -Top ($Y + $i)
            Write-Output (Format-ScapeANSIMessage -Text $mid -Flag "MENU") -NoNewline
        }
        Set-ScapeCursorPosition -Left $X -Top ($Y + $Height - 1)
        Write-Output (Format-ScapeANSIMessage -Text $bot -Flag "MENU") -NoNewline
    }
}

function Format-ScapeArtBlock {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)][string]$VariantKey,
        [Parameter(Mandatory = $true)][int]$ConsoleWidth,
        [Parameter()][string]$ColorFlag = 'BANNER'
    )
    process {
        $artMap = Get-ScapeConstant -Path "ui::Art::Variants" -Fallback @{}
        $artKey = if ($artMap.ContainsKey($VariantKey)) { $artMap[$VariantKey] } else { "SmallLogo" }
        $raw = Get-ScapeConstant -Path "ui::Art::$artKey" -Fallback ''

        if ([string]::IsNullOrWhiteSpace($raw)) { return @() }

        $lines = ($raw -split "`n" | Where-Object { $_.Trim() })
        $out = New-Object System.Collections.Generic.List[string]
        foreach ($l in $lines) {
            $pad = [Math]::Max(0, [Math]::Floor(($ConsoleWidth - $l.Length) / 2))
            $out.Add((Format-ScapeANSIMessage -Text (" " * $pad + $l) -Flag $ColorFlag))
        }
        return $out.ToArray()
    }
}

function Invoke-ScapeMasterRedraw {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter()][string]$MenuId,
        [Parameter()][array]$Options,
        [Parameter()][int]$CursorIndex,
        [Parameter()][string]$TitleKey,
        [switch]$ForceFullRedraw
    )
    process {
        if ($null -eq $Script:R.Cache) { Initialize-ScapeRenderer }
        $dims = Get-ScapeConsoleDimension -WithMargins
        $needsRedraw = $ForceFullRedraw -or ($Script:R.LastMenuId -ne $MenuId)

        if ($needsRedraw) {
            [Console]::Clear()
            $boxH = if ($null -ne $Options) { $Options.Count + 4 } else { 4 }
            $banner = Format-ScapeArtBlock -VariantKey "Standard" -ConsoleWidth $dims.Width
            if (($banner.Count + $boxH) -gt $dims.Height) {
                $banner = Format-ScapeArtBlock -VariantKey "Compact" -ConsoleWidth $dims.Width
            }

            $y = 1
            foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; Write-Output $line -NoNewline; $y++ }

            $safeTitleKey = if ([string]::IsNullOrWhiteSpace($TitleKey)) { "MENU_DEFAULT" } else { $TitleKey }
            $titleNode = Get-ScapeI18NNode -Key $safeTitleKey
            $titleIconNode = Get-ScapeConstant -Path "ui::Icons::Menu" -Fallback @("≡")
            $titleIcon = if ($titleIconNode -is [array]) { $titleIconNode[0] } else { $titleIconNode }
            $titleText = " $titleIcon $($titleNode.Text) "

            $maxTextW = Get-ScapePlainTextLength -Text $titleText
            if ($null -ne $Options) {
                foreach ($o in $Options) {
                    $i18nNode = Get-ScapeI18NNode -Key $o.TitleKey
                    $len = (Get-ScapePlainTextLength -Text $i18nNode.Text) + (Get-ScapePlainTextLength -Text $o.DynamicText) + 8
                    if ($len -gt $maxTextW) { $maxTextW = $len }
                }
            }

            $minW = Get-ScapeConstant -Path "ui::Layout::MinWidth" -Fallback 40
            $Script:R.BoxCache = Get-ScapeMenuLayout -MaxContentWidth $maxTextW -ItemCount ($Options?.Count ?? 0) -ConsoleWidth $dims.Width -ConsoleHeight $dims.Height -HeaderHeight $y -MinWidth $minW

            $box = $Script:R.BoxCache
            $defStyle = Get-ScapeConstant -Path "ui::Defaults::FrameStyle" -Fallback "Classic"

            Format-ScapeFrame -X $box.X -Y $box.Y -Width $box.Width -Height $box.Height -StyleKey $defStyle

            $tLen = Get-ScapePlainTextLength -Text $titleText
            $tX = $box.X + [Math]::Floor(($box.Width - $tLen) / 2)
            Set-ScapeCursorPosition -Left $tX -Top $box.Y
            Write-Output (Format-ScapeANSIMessage -Text $titleText -Flag "BANNER" -Bold) -NoNewline

            $Script:R.LastMenuId = $MenuId
            $Script:R.LastCursor = -1
        }

        $box = $Script:R.BoxCache
        if ($null -eq $box -or $null -eq $Options) { return }

        $usableW = $box.UsableWidth

        $selIconNode = Get-ScapeConstant -Path "ui::Icons::Submenu" -Fallback "▶"
        $selIcon = if ($selIconNode -is [array]) { $selIconNode[0] } else { $selIconNode }

        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($needsRedraw -or $i -eq $CursorIndex -or $i -eq $Script:R.LastCursor) {
                $opt = $Options[$i]
                if ($null -eq $opt) { continue }

                Set-ScapeCursorPosition -Left ($box.X + 2) -Top ($box.Y + 2 + $i)

                $safeOptKey = if ([string]::IsNullOrWhiteSpace($opt.TitleKey)) { "ITEM_DEFAULT" } else { $opt.TitleKey }
                $i18nNode = Get-ScapeI18NNode -Key $safeOptKey
                $icon = Get-ScapeResolvedIcon -RouteId $opt.Id

                $flag = if ($opt.Type -eq 'UI') { 'MENU' } else { $opt.Type }

                $baseText = "$icon $($i18nNode.Text)"
                if ($i -eq $CursorIndex) { $baseText = "$selIcon $baseText" } else { $baseText = "  $baseText" }

                $padSpaces = Get-ScapeJustifiedPadding -LeftText $baseText -RightText $opt.DynamicText -TotalWidth $usableW

                if ($i -eq $CursorIndex) {
                    $leftAnsi = Format-ScapeANSIMessage -Text "$baseText$padSpaces" -Flag $flag -IncludeBackground -Bold
                    $rightAnsi = Format-ScapeANSIMessage -Text $opt.DynamicText -Flag $flag -IncludeBackground -Bold
                    Write-Output "$leftAnsi$rightAnsi" -NoNewline
                }
                else {
                    $leftAnsi = Format-ScapeANSIMessage -Text "$baseText$padSpaces" -Flag "MENU"
                    $rightAnsi = Format-ScapeANSIMessage -Text $opt.DynamicText -Flag "DEBUG"
                    Write-Output "$leftAnsi$rightAnsi" -NoNewline
                }
            }
        }
        $Script:R.LastCursor = $CursorIndex
    }
}