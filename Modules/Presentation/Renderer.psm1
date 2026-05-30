<#
.SYNOPSIS
    Domain: Presentation\Renderer
    Module: Scape.Presentation.Renderer
    Architecture: Stateless Rendering | Geometry-Driven Coordinates | Zero Publishing | FP & MVVM
    [FIX] Merged critical/high fixes: menuHash quoting, viewport clipping, scroll indicators,
          tree view scrolling, icon cache, transient view ANSI-safe measurement, etc.
    [REFACTOR] Decomposed Write-ScapeMenuBuffer into specialized SRP functions.
#>
[CmdletBinding()] param()

# ANSI strip pattern — definido uma vez, reusado em todo o módulo (DRY)
$Script:AnsiStrip = [regex]"$([char]27)\[[0-9;]*[a-zA-Z]"

$Script:IconResolveCache = @{}
$Script:MenuLineCache = @{}
$Script:R_BoxCache = $null

$Script:RenderCache = @{
    LastMenuHash      = ""
    LastOptions       = @()
    LastCursor        = -1
    BoxWidth          = 0
    BoxHeight         = 0
    LastViewportStart = -1
    LastViewportEnd   = -1
    LastDynamicHash   = ""
}

# ==============================================================================
# CORE INITIALIZATION
# ==============================================================================

function Initialize-ScapeRenderer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        try {
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            [Console]::CursorVisible = $false
        } catch {}

        if (Get-Command Initialize-ScapeGeometry -ErrorAction SilentlyContinue) {
            try { Initialize-ScapeGeometry | Out-Null }
            catch { Write-Verbose "Geometry init failed: $_" }
        }

        if (-not ("Scape.Core.Native.VT100Enabler" -as [type])) {
            if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) {
                try { Initialize-ScapeInterop | Out-Null }
                catch { Write-Verbose "Interop init failed: $_" }
            }
        }
        if ("Scape.Core.Native.VT100Enabler" -as [type]) {
            try { [Scape.Core.Native.VT100Enabler]::Enable() } catch { Write-Verbose "VT100 enable failed: $_" }
        }
    }
}

function Close-ScapeRenderer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        try {
            [Console]::CursorVisible = $true
            [Console]::Clear()
        } catch {}
       if ($Script:RenderCache) {
        $Script:RenderCache.LastTransientConfig = $null
    }
        $Script:IconResolveCache.Clear()
        $Script:MenuLineCache.Clear()
        $Script:RenderCache.LastMenuHash = ""
        $Script:RenderCache.BoxWidth = 0
        $Script:RenderCache.BoxHeight = 0
        $Script:RenderCache.LastViewportStart = -1
        $Script:RenderCache.LastViewportEnd = -1
        $Script:RenderCache.LastDynamicHash = ""
        $Script:R_BoxCache = $null
    }
}

# ==============================================================================
# HELPERS & UTILITIES (Pure-ish Functions)
# ==============================================================================

function _GetCachedResolvedIcon {
    param(
        [Parameter(Mandatory = $true)][string]$RouteId,
        [Parameter(Mandatory = $true)][int]$IconLevel
    )
    process {
        $cacheKey = "${RouteId}:${IconLevel}"

        if ($Script:IconResolveCache.ContainsKey($cacheKey)) {
            return $Script:IconResolveCache[$cacheKey]
        }

        $icon = Get-ScapeResolvedIcon -RouteId $RouteId -IconLevel $IconLevel

        if ($null -ne $icon) {
            $Script:IconResolveCache[$cacheKey] = $icon
        }
        return $icon
    }
}
function Format-ScapeArtBlock {
    [CmdletBinding()]
    [OutputType([array])]
    param([string]$VariantKey, [int]$ConsoleWidth, [string]$ColorFlag = 'BANNER')
    process {
        $artMap = Get-ScapeConstant -Path "ui::Art::Variants"
        $artKey = 'SmallLogo'
        if ($artMap.ContainsKey($VariantKey)) { $artKey = $artMap[$VariantKey] }

        $raw = Get-ScapeConstant -Path "ui::Art::$artKey"
        if ([string]::IsNullOrWhiteSpace($raw)) { return @() }

        $lines = ($raw -split '\r?\n' | Where-Object { $_.Trim() })
        return @($lines | ForEach-Object {
                $plain = $Script:AnsiStrip.Replace($_, '')
                $pad = [Math]::Max(0, [Math]::Floor(($ConsoleWidth - $plain.Length) / 2))
                Format-ScapeANSIMessage -Text (" " * $pad + $plain) -Flag $ColorFlag
            })
    }
}

function Write-ScapeScrollIndicator {
    param([string]$Direction, [int]$X, [int]$Y, [string]$Flag)
    process {
        if (-not (Get-Command Format-ScapeANSIMessage -ErrorAction SilentlyContinue)) { return }
        if (-not (Get-Command Set-ScapeCursorPosition -ErrorAction SilentlyContinue)) { return }

        $arrow = if ($Direction -eq 'up') { '▲' } else { '▼' }
        $dimPrefix = "$([char]27)[2m"
        Set-ScapeCursorPosition -Left $X -Top $Y
        $formatted = Format-ScapeANSIMessage -Text $arrow -Flag $Flag
        [Console]::Write("${dimPrefix}${formatted}$([char]27)[0m")
    }
}

# ==============================================================================
# MENU RENDERER COMPONENTS (SRP Separated)
# ==============================================================================

function Write-ScapeMenuLayout {
    param(
        $Dims,
        $ItemCount,
        $VisibleItems,
        $TitleKey,
        $FrameStyle,
        $HeaderHeight
    )

    $clearSeq = Get-ScapeConstant -Path "ui::ANSI::Screen::ClearFull"
    if ($clearSeq) { [Console]::Write($clearSeq) } else { [Console]::Write("$([char]27)[H$([char]27)[2J") }

    $bannerMode = if (Get-Command Get-ScapeBannerVariant -ErrorAction SilentlyContinue) {
        Get-ScapeBannerVariant -ConsoleHeight $Dims.Height -ItemCount $ItemCount -HeaderHeight $HeaderHeight
    } else {
        if (($ItemCount + $HeaderHeight) -gt $Dims.Height) { 'Compact' } else { 'Standard' }
    }
    $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $Dims.Width
    $y = 1
    foreach ($line in $banner) {
        Set-ScapeCursorPosition -Left 0 -Top $y
        [Console]::Write($line)
        $y++
    }

    $titleNode = Get-ScapeI18NNode -Key $TitleKey
    $cleanTitle = $titleNode.Text -replace '^\[\s*|\s*\]$', ''

    $box = Get-ScapeMenuLayout -MaxContentWidth 45 -ItemCount $VisibleItems -ConsoleWidth $Dims.Width -ConsoleHeight $Dims.Height -HeaderHeight $y
    $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box

    $effectiveFrameStyle = if (-not [string]::IsNullOrWhiteSpace($FrameStyle)) { $FrameStyle } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
    $frame = Get-ScapeConstant -Path "ui::Frames::$effectiveFrameStyle"
    $roofWidth = [Math]::Max(1, $box.Width - 2)

    Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $frameCoords.TitleY
    [Console]::Write((Format-ScapeANSIMessage -Text ($frame.TL + ($frame.HL * $roofWidth) + $frame.TR) -Flag "MENU"))

    Set-ScapeCursorPosition -Left $frameCoords.TitleX -Top $frameCoords.TitleY
    [Console]::Write((Format-ScapeANSIMessage -Text "$cleanTitle" -Flag 'BANNER'))

    $vlStr = Format-ScapeANSIMessage -Text $frame.VL -Flag "MENU"
    $emptySpace = " " * $roofWidth
    $midLine = "${vlStr}${emptySpace}${vlStr}"

    for ($h = 1; $h -le $box.Height; $h++) {
        Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top ($frameCoords.TitleY + $h)
        [Console]::Write($midLine)
    }

    Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $frameCoords.BottomY
    [Console]::Write((Format-ScapeANSIMessage -Text ($frame.BL + ($frame.HL * $roofWidth) + $frame.BR) -Flag "MENU"))

    return $box
}

function Write-ScapeScrollIndicatorsView {
    param(
        $ViewportStart,
        $ViewportEnd,
        $ItemCount,
        $FrameCoords,
        [string]$FrameStyle = $null
    )

    $effectiveFrameStyle = if (-not [string]::IsNullOrWhiteSpace($FrameStyle)) { $FrameStyle } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
    $frame = Get-ScapeConstant -Path "ui::Frames::$effectiveFrameStyle"
    $wallChar = if ($frame -and $frame.VL) { $frame.VL } else { '|' }

    if ($ViewportStart -gt 0) {
        Write-ScapeScrollIndicator -Direction 'up' -X $FrameCoords.RightWallX -Y ($FrameCoords.TitleY + 1) -Flag 'HINT'
    }
    else {
        Set-ScapeCursorPosition -Left $FrameCoords.RightWallX -Top ($FrameCoords.TitleY + 1)
        [Console]::Write((Format-ScapeANSIMessage -Text $wallChar -Flag "MENU"))
    }

    if ($ViewportEnd -lt $ItemCount) {
        Write-ScapeScrollIndicator -Direction 'down' -X $FrameCoords.RightWallX -Y ($FrameCoords.BottomY - 1) -Flag 'HINT'
    }
    else {
        Set-ScapeCursorPosition -Left $FrameCoords.RightWallX -Top ($FrameCoords.BottomY - 1)
        [Console]::Write((Format-ScapeANSIMessage -Text $wallChar -Flag "MENU"))
    }
}

function Write-ScapeMenuRows {
    param(
        $Box,
        $Dims,
        $Options,
        $CursorIndex,
        $LastCursorIndex,
        $ViewportStart,
        $ViewportEnd,
        $IconLevel,
        $ForceRedrawItems,
        [string]$FrameStyle = $null
    )

    $rawSelIcon = Get-ScapeConstant -Path "ui::Icons::Submenu"
    if ($rawSelIcon -is [array]) {
        $safeLevel = [Math]::Max(0, [Math]::Min([int]$IconLevel, $rawSelIcon.Count - 1))
        $selIcon = $rawSelIcon[$safeLevel]
    }
    else {
        $selIcon = $rawSelIcon
    }
    $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $Box
    
    $effectiveFrameStyle = if (-not [string]::IsNullOrWhiteSpace($FrameStyle)) { $FrameStyle } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
    $frame = Get-ScapeConstant -Path "ui::Frames::$effectiveFrameStyle"
    $wallChar = if ($frame -and $frame.VL) { $frame.VL } else { '|' }

    for ($i = $ViewportStart; $i -lt $ViewportEnd; $i++) {
        $displayIndex = $i - $ViewportStart
        $isCurrent = ($i -eq $CursorIndex)

        if ($ForceRedrawItems -or $isCurrent -or ($i -eq $LastCursorIndex)) {
            $opt = $Options[$i]
            $i18nStr = $opt.Text
            $hintStr = $opt.Hint
            $icon = $opt.Icon
            $flag = if ($opt.Type -eq 'UI') { 'MENU' } else { $opt.Type }

            $coords = Get-ScapeGridCoordinates -BoxLayout $Box -ActiveIcon $icon -Index $displayIndex -ViewportOffset $ViewportStart

            $strSel = if ($isCurrent) { $selIcon } else { " " }
            $strIcon = $icon
            
            $dynLen = if ($opt.PSObject.Properties['DynWidth']) { $opt.DynWidth } else { 0 }
            $visStrW = if ($opt.PSObject.Properties['TextWidth']) { $opt.TextWidth } else { $i18nStr.Length }
            $formattedDynText = $opt.DynamicText
            
            $maxTextW = $coords.RightEdge - $coords.TextX - $dynLen
            if ($maxTextW -lt 0) { $maxTextW = 0 }
            
            $clippedText = if ($visStrW -gt $maxTextW) { Invoke-ScapeStringClip -Text $i18nStr -MaxWidth $maxTextW } else { $i18nStr }
            $finalVisW = if ($visStrW -gt $maxTextW) { $maxTextW } else { $visStrW }
            $padText = [Math]::Max(0, $maxTextW - $finalVisW)

            $fmtSel = Format-ScapeANSIMessage -Text $strSel -Flag $flag -Bold:$isCurrent
            $fmtIcon = Format-ScapeANSIMessage -Text $strIcon -Flag $flag
            $fmtText = Format-ScapeANSIMessage -Text $clippedText -Flag $flag -Bold:$isCurrent -IncludeBackground:$isCurrent
            $fmtDyn = if ($formattedDynText) { Format-ScapeANSIMessage -Text $formattedDynText -Flag $flag -Bold:$isCurrent -IncludeBackground:$isCurrent } else { "" }

            $usableClearWidth = [Math]::Min($Box.UsableWidth, [Math]::Max(1, [Console]::WindowWidth - $coords.SelectorX - 1))

            if (Get-Command Clear-ScapeRegion -ErrorAction SilentlyContinue) {
                Clear-ScapeRegion -Left $coords.SelectorX -Top $coords.Y -Width $usableClearWidth -Height 1
            } else {
                Set-ScapeCursorPosition -Left $coords.SelectorX -Top $coords.Y
                [Console]::Write(" " * $usableClearWidth)
            }

            Set-ScapeCursorPosition -Left $coords.SelectorX -Top $coords.Y
            $padIcon = [Math]::Max(1, $coords.IconX - $coords.SelectorX - $(if (Get-Command Get-ScapeVisualWidth -ErrorAction SilentlyContinue) { Get-ScapeVisualWidth $strSel } else { 1 }))
            $padTextSpace = [Math]::Max(1, $coords.TextX - $coords.IconX - $(if (Get-Command Get-ScapeVisualWidth -ErrorAction SilentlyContinue) { Get-ScapeVisualWidth $strIcon } else { 1 }))
            
            $fullLine = "${fmtSel}$(" " * $padIcon)${fmtIcon}$(" " * $padTextSpace)${fmtText}$(" " * $padText)${fmtDyn}"
            [Console]::Write($fullLine)

            if ($isCurrent -and $hintStr) {
                $hintY = $frameCoords.BottomY + 2
                if ($hintY -lt $Dims.Height) {
                    $rawWidth = [Math]::Max($Dims.Width, [Console]::WindowWidth)
                    $maxHintWidth = [Math]::Max(1, $rawWidth - 1)
                    $cleanHint = $Script:AnsiStrip.Replace($hintStr, '')
                    $clipHint = Invoke-ScapeStringClip -Text $cleanHint -MaxWidth $maxHintWidth
                    Set-ScapeCursorPosition -Left 0 -Top $hintY
                    [Console]::Write(" " * $maxHintWidth)
                    Set-ScapeCursorPosition -Left $Box.X -Top $hintY
                    [Console]::Write((Format-ScapeANSIMessage -Text $clipHint -Flag "HINT"))
                }
            }
        }
    }
}

# ==============================================================================
# MAIN RENDER ORCHESTRATOR
# ==============================================================================
function Write-ScapeMenuBuffer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [array] $Options,
        [Parameter()] [int] $CursorIndex = 0,
        [Parameter()] [int] $LastCursorIndex = -1,
        [Parameter()] [int] $ViewportStart = 0,
        [Parameter()] [int] $ViewportEnd = 0,
        [Parameter()] [string] $TitleKey,
        [Parameter()] [bool] $FullRedraw = $false,
        [Parameter()] [bool] $ForceRowRedraw = $false,
        [Parameter()] [string] $FrameStyle = $null,
        [Parameter()] [int] $IconLevel = 0
    )
    process {
        if ($null -eq $CursorIndex) { $CursorIndex = 0 }
        if ($null -eq $LastCursorIndex) { $LastCursorIndex = -1 }
        
        $ForceRowRedraw = ($FullRedraw -or $ForceRowRedraw)

        $dims = Get-ScapeConsoleDimension -WithMargins
        $layout = Get-ScapeConstant -Path "ui::Layout"
        $itemCount = @($Options).Count

        $safeDimsHeight = [Math]::Max(10, $dims.Height - 1)
        $safeDims = @{ Width = $dims.Width; Height = $safeDimsHeight }

        $visibleItems = $ViewportEnd - $ViewportStart

        if ($FullRedraw) {
            $box = Write-ScapeMenuLayout -Dims $safeDims -ItemCount $itemCount -VisibleItems $visibleItems -TitleKey $TitleKey -FrameStyle $FrameStyle -HeaderHeight $layout.HeaderHeight
        } else {
            $bannerMode = if (Get-Command Get-ScapeBannerVariant -ErrorAction SilentlyContinue) {
                Get-ScapeBannerVariant -ConsoleHeight $safeDims.Height -ItemCount $itemCount -HeaderHeight $layout.HeaderHeight
            } else {
                if (($itemCount + $layout.HeaderHeight) -gt $safeDims.Height) { 'Compact' } else { 'Standard' }
            }
            $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $safeDims.Width
            $y = 1 + $banner.Count
            $box = Get-ScapeMenuLayout -MaxContentWidth 45 -ItemCount $visibleItems -ConsoleWidth $safeDims.Width -ConsoleHeight $safeDims.Height -HeaderHeight $y
        }

        $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box

        # 4. Indicators Rendering
        Write-ScapeScrollIndicatorsView -ViewportStart $ViewportStart -ViewportEnd $ViewportEnd -ItemCount $itemCount -FrameCoords $frameCoords -FrameStyle $FrameStyle

        # 5. Rows Rendering (Dynamic Content)
        Write-ScapeMenuRows -Box $box -Dims $dims -Options $Options -CursorIndex $CursorIndex -LastCursorIndex $LastCursorIndex -ViewportStart $ViewportStart -ViewportEnd $ViewportEnd -IconLevel $IconLevel -ForceRedrawItems $ForceRowRedraw -FrameStyle $FrameStyle
    }
}

# ==============================================================================
# OTHER VIEWS
# ==============================================================================

function Write-ScapeTransientView {
    [CmdletBinding()]
    [OutputType([void])]
    param([Parameter(Mandatory = $true)][hashtable]$RenderConfig)

    if (-not $RenderConfig.ShouldRender) { return }

    if ($RenderConfig.Type -eq 'TreeView') {
        Write-ScapeTreeView -RenderConfig $RenderConfig
        return
    }

    $dims = Get-ScapeConsoleDimension -WithMargins
    $layout = Get-ScapeConstant -Path "ui::Layout"

    $rawWidth = [Math]::Max($dims.Width, [Console]::WindowWidth)
    $usableWidth = [Math]::Max(1, $rawWidth - 1)
    $cleanText = $Script:AnsiStrip.Replace($RenderConfig.Text, '')
    $clippedClean = Invoke-ScapeStringClip -Text $cleanText -MaxWidth $usableWidth
    $plainText = ($Script:AnsiStrip.Replace($clippedClean, ''))
    $x = [Math]::Max(0, [Math]::Floor(($rawWidth - $plainText.Length) / 2))

    if ($RenderConfig.Type -eq 'StatusBar') {
        $y = $dims.Height - 2
        if ($y -ge $layout.HeaderHeight -and $y -lt $dims.Height) {
            Set-ScapeCursorPosition -Left 0 -Top $y
            [Console]::Write(" " * $usableWidth)
            Set-ScapeCursorPosition -Left $x -Top $y
            [Console]::Write((Format-ScapeANSIMessage -Text $clippedClean -Flag $RenderConfig.Flag))
        }
    }
    elseif ($RenderConfig.Type -eq 'Transient') {
        $Script:RenderCache.LastTransientConfig = $RenderConfig
        $y = $dims.Height - 1
        if ($y -ge $layout.HeaderHeight -and $y -lt $dims.Height) {
            Set-ScapeCursorPosition -Left 0 -Top $y
            [Console]::Write(" " * $usableWidth)
            Set-ScapeCursorPosition -Left $x -Top $y
            [Console]::Write((Format-ScapeANSIMessage -Text $clippedClean -Flag $RenderConfig.Flag))
        }
    }
}

function Write-ScapeTreeView {
    [CmdletBinding()]
    param(
        [hashtable]$RenderConfig,
        [string]$FrameStyle = $null
    )
    if (-not $RenderConfig.ShouldRender) { return }

    $dims = Get-ScapeConsoleDimension -WithMargins
    $title = Get-ScapeI18NNode -Key $RenderConfig.Config.TitleKey
    $cleanTitle = $title.Text -replace '^\[\s*|\s*\]$', ''

    $items = $RenderConfig.Config.Items
    $totalItems = @($items).Count

    $bannerMode = if (Get-Command Get-ScapeBannerVariant -ErrorAction SilentlyContinue) { Get-ScapeBannerVariant -ConsoleHeight $dims.Height -ItemCount $totalItems -HeaderHeight 1 } else { 'SmallLogo' }
    $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $dims.Width
    $y = 1
    foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; [Console]::Write($line); $y++ }
    $maxAvailableHeight = $dims.Height - $y - 2
    $visibleItems = [Math]::Min($totalItems, $maxAvailableHeight)

    $cursorIndex = if ($RenderConfig.Config.CursorIndex) { $RenderConfig.Config.CursorIndex } else { 0 }

    $viewportRange = if (Get-Command Get-ScapeViewportRange -ErrorAction SilentlyContinue) {
        Get-ScapeViewportRange -TotalItems $totalItems -CursorIndex $cursorIndex -AvailableHeight $maxAvailableHeight
    }
    else {
        @{ Start = 0; End = $visibleItems }
    }

    $visibleSlice = @()
    if ($viewportRange.End -gt $viewportRange.Start -and $totalItems -gt 0) {
        $visibleSlice = @($items[$viewportRange.Start..($viewportRange.End - 1)])
    }
    $box = Get-ScapeMenuLayout -MaxContentWidth 80 -ItemCount $visibleItems -ConsoleWidth $dims.Width -ConsoleHeight $dims.Height -HeaderHeight $y

    $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box

    $effectiveFrameStyle = if (-not [string]::IsNullOrWhiteSpace($FrameStyle)) { $FrameStyle } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
    $frame = Get-ScapeConstant -Path "ui::Frames::$effectiveFrameStyle"
    $roofWidth = [Math]::Max(1, $box.Width - 2)

    Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $frameCoords.TitleY
    [Console]::Write((Format-ScapeANSIMessage -Text ($frame.TL + ($frame.HL * $roofWidth) + $frame.TR) -Flag "MENU"))
    Set-ScapeCursorPosition -Left $frameCoords.TitleX -Top $frameCoords.TitleY
    [Console]::Write((Format-ScapeANSIMessage -Text "$cleanTitle" -Flag 'BANNER'))

    for ($h = 1; $h -le $box.Height; $h++) {
        Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top ($frameCoords.TitleY + $h)
        [Console]::Write((Format-ScapeANSIMessage -Text $frame.VL -Flag "MENU"))
        Set-ScapeCursorPosition -Left $frameCoords.RightWallX -Top ($frameCoords.TitleY + $h)
        [Console]::Write((Format-ScapeANSIMessage -Text $frame.VL -Flag "MENU"))
    }
    Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $frameCoords.BottomY
    [Console]::Write((Format-ScapeANSIMessage -Text ($frame.BL + ($frame.HL * $roofWidth) + $frame.BR) -Flag "MENU"))

    if ($viewportRange.Start -gt 0) {
        Write-ScapeScrollIndicator -Direction 'up' -X $frameCoords.RightWallX -Y ($frameCoords.TitleY + 1) -Flag 'HINT'
    }
    if ($viewportRange.End -lt $totalItems) {
        Write-ScapeScrollIndicator -Direction 'down' -X $frameCoords.RightWallX -Y ($frameCoords.BottomY - 1) -Flag 'HINT'
    }

    $yOffset = $frameCoords.ContentY
    foreach ($item in $visibleSlice) {
        if ($yOffset -ge $frameCoords.BottomY -or $yOffset -ge $dims.Height) { break }

        $indent = "  " * ($item.Depth)
        $rawLine = "$indent$($item.Text)"
        $clippedLine = Invoke-ScapeStringClip -Text $rawLine -MaxWidth ($box.Width - 4)
        $padding = Get-ScapeJustifiedPadding -LeftText $clippedLine -RightText "" -TotalWidth ($box.Width - 4)

        Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
        [Console]::Write((Format-ScapeANSIMessage -Text ($clippedLine + $padding) -Flag $item.StatusFlag))
        $yOffset++
    }
}

function Write-ScapeActionScreen {
    [CmdletBinding()]
    param([hashtable]$RenderConfig, [string]$FrameStyle = $null)
    if (-not $RenderConfig.ShouldRender) { return }

    $dims = Get-ScapeConsoleDimension -WithMargins
    $title = Get-ScapeI18NNode -Key $RenderConfig.Config.TitleKey
    $cleanTitle = if ($title -and $title.Text) { $title.Text -replace '^\[\s*|\s*\]$', '' } else { $RenderConfig.Config.TitleKey }
    
    $rows = $RenderConfig.Config.Rows
    $totalItems = @($rows).Count
    
    $runProgress = $RenderConfig.Config.RunProgress
    $stepProgress = $RenderConfig.Config.StepProgress
    
    $hasRun = ($null -ne $runProgress -and $runProgress -ge 0 -and $runProgress -le 100)
    $hasStep = ($null -ne $stepProgress -and $stepProgress -ge 0 -and $stepProgress -le 100)
    
    $progressRows = 0
    if ($hasRun) { $progressRows += 2 }
    if ($hasStep) { $progressRows += 2 }
    if ($progressRows -gt 0) { $progressRows += 1 }

    $bannerMode = if (Get-Command Get-ScapeBannerVariant -ErrorAction SilentlyContinue) { Get-ScapeBannerVariant -ConsoleHeight $dims.Height -ItemCount ($totalItems + $progressRows) -HeaderHeight 1 } else { 'SmallLogo' }
    $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $dims.Width
    $y = 1
    foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; [Console]::Write($line); $y++ }
    $box = Get-ScapeMenuLayout -MaxContentWidth 80 -ItemCount ($totalItems + $progressRows) -ConsoleWidth $dims.Width -ConsoleHeight $dims.Height -HeaderHeight $y
    $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box

    $effectiveFrameStyle = if (-not [string]::IsNullOrWhiteSpace($FrameStyle)) { $FrameStyle } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
    $frame = Get-ScapeConstant -Path "ui::Frames::$effectiveFrameStyle"
    $roofWidth = [Math]::Max(1, $box.Width - 2)

    Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $frameCoords.TitleY
    [Console]::Write((Format-ScapeANSIMessage -Text ($frame.TL + ($frame.HL * $roofWidth) + $frame.TR) -Flag "MENU"))
    Set-ScapeCursorPosition -Left $frameCoords.TitleX -Top $frameCoords.TitleY
    [Console]::Write((Format-ScapeANSIMessage -Text "$cleanTitle" -Flag 'BANNER'))

    $vlStr = Format-ScapeANSIMessage -Text $frame.VL -Flag "MENU"
    $emptySpace = " " * $roofWidth
    $midLine = "${vlStr}${emptySpace}${vlStr}"

    for ($h = 1; $h -le $box.Height; $h++) {
        Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top ($frameCoords.TitleY + $h)
        [Console]::Write($midLine)
    }
    Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $frameCoords.BottomY
    [Console]::Write((Format-ScapeANSIMessage -Text ($frame.BL + ($frame.HL * $roofWidth) + $frame.BR) -Flag "MENU"))

    $yOffset = $frameCoords.ContentY
    foreach ($row in $rows) {
        $left = $row.LeftText
        $right = $row.RightText
        if (-not $left) { $left = "" }
        if (-not $right) { $right = "" }

        $padding = Get-ScapeJustifiedPadding -LeftText $left -RightText $right -TotalWidth ($box.Width - 4)
        
        Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
        
        $leftFmt = Format-ScapeANSIMessage -Text $left -Flag $row.Flag
        $rightFmt = Format-ScapeANSIMessage -Text $right -Flag $row.RightFlag
        
        [Console]::Write("${leftFmt}${padding}${rightFmt}")
        $yOffset++
    }

    $effectiveProgressStyle = if (-not [string]::IsNullOrWhiteSpace($RenderConfig.Config.ProgressStyle)) { $RenderConfig.Config.ProgressStyle } else { Get-ScapeConstant -Path "ui::Defaults::ProgressStyle" -Fallback "Default" }
    $progressDef = Get-ScapeConstant -Path "ui::Progress::$effectiveProgressStyle"
    if ($null -eq $progressDef -or -not $progressDef.ContainsKey("FullChar")) { 
        $progressDef = Get-ScapeConstant -Path "ui::Progress::Default" 
    }
    
    $fullC = if ($progressDef) { $progressDef.FullChar } else { "█" }
    $emptyC = if ($progressDef) { $progressDef.EmptyChar } else { "░" }

    if ($progressRows -gt 0) {
        $yOffset++ # Padding row
        $barWidth = $box.Width - 4
        
        if ($hasRun) {
            Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
            $pctStr = " [$runProgress%]"
            $padTxt = Get-ScapeJustifiedPadding -LeftText "OVERALL RUN PROGRESS" -RightText $pctStr -TotalWidth $barWidth
            [Console]::Write((Format-ScapeANSIMessage -Text ("OVERALL RUN PROGRESS" + $padTxt + $pctStr) -Flag "HINT"))
            $yOffset++
            
            $filledChars = [Math]::Floor(($runProgress / 100.0) * $barWidth)
            $emptyChars = [Math]::Max(0, $barWidth - $filledChars)
            $barStr = ("$fullC" * $filledChars) + ("$emptyC" * $emptyChars)
            
            Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
            [Console]::Write((Format-ScapeANSIMessage -Text $barStr -Flag "SUCCESS"))
            $yOffset++
        }
        
        if ($hasStep) {
            Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
            $pctStr = " [$stepProgress%]"
            $padTxt = Get-ScapeJustifiedPadding -LeftText "CURRENT TASK PROGRESS" -RightText $pctStr -TotalWidth $barWidth
            [Console]::Write((Format-ScapeANSIMessage -Text ("CURRENT TASK PROGRESS" + $padTxt + $pctStr) -Flag "HINT"))
            $yOffset++
            
            $filledChars = [Math]::Floor(($stepProgress / 100.0) * $barWidth)
            $emptyChars = [Math]::Max(0, $barWidth - $filledChars)
            $barStr = ("$fullC" * $filledChars) + ("$emptyC" * $emptyChars)
            
            Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
            [Console]::Write((Format-ScapeANSIMessage -Text $barStr -Flag "WARN"))
            $yOffset++
        }
    }
}

function Format-ScapeGridLayout {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][array]$GridRows,
        [int]$Columns = 2,
        [int]$ColumnWidth = 30,
        [string]$FrameStyle = 'Classic',
        [switch]$WithBorder
    )
    process {
        if ($null -eq $GridRows -or $GridRows.Count -eq 0) { return "" }

        $ESC = [char]27
        $reset = "$ESC[0m"
        $sb = [System.Text.StringBuilder]::new()

        $frame = Get-ScapeConstant -Path "ui::Frames::$FrameStyle"
        if ($null -eq $frame) { $frame = Get-ScapeConstant -Path "ui::Frames::Classic" }

        if ($WithBorder) {
            $borderTop = $frame.TL + ($frame.HL * (($ColumnWidth * $Columns) + ($Columns - 1))) + $frame.TR
            [void]$sb.AppendLine((Format-ScapeANSIMessage -Text $borderTop -Flag 'MENU'))
        }

        $cellCount = 0
        $rowContent = ""

        foreach ($item in $GridRows) {
            $itemText = if ($item -is [string]) { $item } else { [string]$item }
            $cleanText = $Script:AnsiStrip.Replace($itemText, '')
            $visW = if (Get-Command Get-ScapeVisualWidth -ErrorAction SilentlyContinue) { Get-ScapeVisualWidth $cleanText } else { $cleanText.Length }
            $padded = if ($visW -gt $ColumnWidth) { Invoke-ScapeStringClip -Text $itemText -MaxWidth $ColumnWidth } else { $itemText + (" " * ($ColumnWidth - $visW)) }

            $formatted = if ($item.PSObject.Properties['ThemeFlag']) {
                Format-ScapeANSIMessage -Text $padded -Flag $item.ThemeFlag
            } else {
                Format-ScapeANSIMessage -Text $padded -Flag 'MENU'
            }

            $rowContent += $formatted

            if ($WithBorder -and $cellCount -lt ($Columns - 1)) {
                $rowContent += (Format-ScapeANSIMessage -Text " | " -Flag 'HINT')
            }

            $cellCount++
            if ($cellCount -ge $Columns) {
                [void]$sb.AppendLine($rowContent)
                $rowContent = ""
                $cellCount = 0
            }
        }

        if ($rowContent.Length -gt 0) {
            [void]$sb.AppendLine($rowContent)
        }

        if ($WithBorder) {
            $borderBottom = $frame.BL + ($frame.HL * (($ColumnWidth * $Columns) + ($Columns - 1))) + $frame.BR
            [void]$sb.AppendLine((Format-ScapeANSIMessage -Text $borderBottom -Flag 'MENU'))
        }

        return $sb.ToString()
    }
}

function Format-ScapeThemifiedMenuBuffer {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $true)][array]$HydratedOptions,
        [int]$CursorIndex = 0,
        [string]$TitleKey,
        [string]$FrameStyle = 'Classic'
    )
    process {
        if ($null -eq $HydratedOptions -or $HydratedOptions.Count -eq 0) { return "" }

        $ESC = [char]27
        $reset = "$ESC[0m"
        $sb = [System.Text.StringBuilder]::new()

        $frame = Get-ScapeConstant -Path "ui::Frames::$FrameStyle"
        if ($null -eq $frame) { $frame = Get-ScapeConstant -Path "ui::Frames::Classic" }

        if ($null -ne $TitleKey) {
            $titleNode = Get-ScapeI18NNode -Key $TitleKey
            $title = $titleNode.Text -replace '^\[\s*|\s*\]$', ''
            $titleLine = $frame.TL + $title.PadRight(45, $frame.HL) + $frame.TR
            [void]$sb.AppendLine((Format-ScapeANSIMessage -Text $titleLine -Flag 'BANNER'))
        }

        for ($i = 0; $i -lt $HydratedOptions.Count; $i++) {
            $opt = $HydratedOptions[$i]
            $isSelected = ($i -eq $CursorIndex)

            $icon = if ($opt.PSObject.Properties['Icon']) { $opt.Icon } else { "" }
            $text = if ($opt.PSObject.Properties['Text']) { $opt.Text } else { $opt.TitleKey }
            $dynText = if ($opt.PSObject.Properties['DynamicText']) { $opt.DynamicText } else { "" }

            $selector = if ($isSelected) { "▶ " } else { "  " }
            $line = "$selector$icon $text"

            if ($dynText) { $line += " $dynText" }

            $flag = if ($opt.PSObject.Properties['ThemeFlag']) { $opt.ThemeFlag } else { 'MENU' }
            $formatted = Format-ScapeANSIMessage -Text $line -Flag $flag -Bold:$isSelected -IncludeBackground:$isSelected

            [void]$sb.AppendLine($formatted)
        }

        return $sb.ToString()
    }
}

Export-ModuleMember -Function 'Initialize-ScapeRenderer',
                              'Close-ScapeRenderer',
                              'Write-ScapeMenuBuffer',
                              'Write-ScapeTransientView',
                              'Write-ScapeTreeView',
                              'Write-ScapeActionScreen',
                              'Format-ScapeGridLayout',
                              'Format-ScapeThemifiedMenuBuffer'
