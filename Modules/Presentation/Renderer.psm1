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
        $Script:IconResolveCache.Clear()
        $Script:MenuLineCache.Clear()
        $Script:RenderCache.LastMenuHash = ""
        $Script:RenderCache.BoxWidth = 0
        $Script:RenderCache.BoxHeight = 0
        $Script:RenderCache.LastViewportStart = -1
        $Script:RenderCache.LastViewportEnd = -1
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

    $bannerMode = if (($ItemCount + $HeaderHeight) -gt $Dims.Height) { 'Compact' } else { 'Standard' }
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

    for ($h = 1; $h -le $box.Height; $h++) {
        Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top ($frameCoords.TitleY + $h)
        [Console]::Write((Format-ScapeANSIMessage -Text $frame.VL -Flag "MENU"))
        Set-ScapeCursorPosition -Left $frameCoords.RightWallX -Top ($frameCoords.TitleY + $h)
        [Console]::Write((Format-ScapeANSIMessage -Text $frame.VL -Flag "MENU"))
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
            $i18nStr = if ($opt.PSObject.Properties['Text']) { $opt.Text } else { (Get-ScapeI18NNode -Key $opt.TitleKey).Text }
            $hintStr = $opt.Hint
            $icon = if ($opt.PSObject.Properties['Icon'] -and $opt.Icon) { $opt.Icon } else { _GetCachedResolvedIcon -RouteId $opt.Id -IconLevel $IconLevel }
            $flag = if ($opt.Type -eq 'UI') { 'MENU' } else { $opt.Type }

            $coords = Get-ScapeGridCoordinates -BoxLayout $Box -ActiveIcon $icon -Index $displayIndex -ViewportOffset 0

            $clearLineSeq = Get-ScapeConstant -Path "ui::ANSI::Screen::ClearLineFull"
            if ($clearLineSeq) {
                Set-ScapeCursorPosition -Left 0 -Top $coords.Y
                [Console]::Write($clearLineSeq)
                Set-ScapeCursorPosition -Left $frameCoords.LeftWallX -Top $coords.Y
                [Console]::Write((Format-ScapeANSIMessage -Text $wallChar -Flag "MENU"))
                Set-ScapeCursorPosition -Left $frameCoords.RightWallX -Top $coords.Y
                [Console]::Write((Format-ScapeANSIMessage -Text $wallChar -Flag "MENU"))
            } else {
                Set-ScapeCursorPosition -Left $coords.SelectorX -Top $coords.Y
                [Console]::Write(" " * $Box.UsableWidth)
            }

            if ($isCurrent) {
                Set-ScapeCursorPosition -Left $coords.SelectorX -Top $coords.Y
                [Console]::Write((Format-ScapeANSIMessage -Text $selIcon -Flag $flag -Bold))
            }

            Set-ScapeCursorPosition -Left $coords.IconX -Top $coords.Y
            [Console]::Write((Format-ScapeANSIMessage -Text $icon -Flag $flag))

            Set-ScapeCursorPosition -Left $coords.TextX -Top $coords.Y
            [Console]::Write((Format-ScapeANSIMessage -Text $i18nStr -Flag $flag -Bold:$isCurrent -IncludeBackground:$isCurrent))

            if ($opt.DynamicText) {
                if (Get-Command Get-ScapePlainTextLength -ErrorAction SilentlyContinue) {
                    $dynLen = Get-ScapePlainTextLength -Text $opt.DynamicText
                }
                else {
                    $dynLen = ($Script:AnsiStrip.Replace($opt.DynamicText, '')).Length
                }

                $rightPos = $coords.RightEdge - $dynLen
                if ($rightPos -gt $coords.TextX + 2) {
                    Set-ScapeCursorPosition -Left $rightPos -Top $coords.Y
                    [Console]::Write((Format-ScapeANSIMessage -Text $opt.DynamicText -Flag $flag -Bold:$isCurrent -IncludeBackground:$isCurrent))
                }
            }

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
    param(
        $Options,
        $CursorIndex,
        $LastCursorIndex = -1,
        $TitleKey,
        $FullRedraw,
        [string]$FrameStyle = $null,
        [int]$IconLevel = 0
    )

    $dims = Get-ScapeConsoleDimension -WithMargins
    $layout = Get-ScapeConstant -Path "ui::Layout"
    $itemCount = @($Options).Count

    # 1. State Resolution & Invalidation Check
    if ($FullRedraw -or $Script:RenderCache.BoxWidth -ne $dims.Width -or $Script:RenderCache.BoxHeight -ne $dims.Height) {
        $FullRedraw = $true
        $Script:RenderCache.BoxWidth = $dims.Width
        $Script:RenderCache.BoxHeight = $dims.Height
        $Script:RenderCache.LastMenuHash = ""
    }

    $menuHash = "$TitleKey|$CursorIndex|$(@($Options).ForEach({ $_.Id }) -join ',')"
    if (-not $FullRedraw -and $Script:RenderCache.LastMenuHash -eq $menuHash) {
        return
    }
    $Script:RenderCache.LastMenuHash = $menuHash

    # 2. Viewport Calculation
    $bannerThreshold = $layout.HeaderHeight
    $verticalPadding = if ($layout.Padding) { $layout.Padding } else { 0 }
    $availableHeight = if ($Script:R_BoxCache -and -not $FullRedraw) { [int]$Script:R_BoxCache.Height } else { [Math]::Max(1, $dims.Height - $bannerThreshold - $verticalPadding - 3) }

    $viewportRange = $null
    if (Get-Command Get-ScapeViewportRange -ErrorAction SilentlyContinue) {
        $viewportRange = Get-ScapeViewportRange -TotalItems $itemCount -CursorIndex $CursorIndex -AvailableHeight $availableHeight
    }
    if ($null -eq $viewportRange) {
        $viewportRange = @{ Start = 0; End = [Math]::Min($itemCount, $availableHeight) }
    }

    $viewportStart = $viewportRange.Start
    $viewportEnd = $viewportRange.End

    if (-not $FullRedraw -and (($Script:RenderCache.LastViewportStart -ne $viewportStart) -or ($Script:RenderCache.LastViewportEnd -ne $viewportEnd))) {
        $FullRedraw = $true
    }

    # 3. Layout Rendering (Static Box)
    if ($FullRedraw) {
        $visibleItems = $viewportEnd - $viewportStart
        $Script:R_BoxCache = Write-ScapeMenuLayout -Dims $dims -ItemCount $itemCount -VisibleItems $visibleItems -TitleKey $TitleKey -FrameStyle $FrameStyle -HeaderHeight $bannerThreshold
    }
    $box = $Script:R_BoxCache
    $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box

    # 4. Indicators Rendering
    Write-ScapeScrollIndicatorsView -ViewportStart $viewportStart -ViewportEnd $viewportEnd -ItemCount $itemCount -FrameCoords $frameCoords -FrameStyle $FrameStyle

    # 5. Rows Rendering (Dynamic Content)
    Write-ScapeMenuRows -Box $box -Dims $dims -Options $Options -CursorIndex $CursorIndex -LastCursorIndex $LastCursorIndex -ViewportStart $viewportStart -ViewportEnd $viewportEnd -IconLevel $IconLevel -ForceRedrawItems $FullRedraw -FrameStyle $FrameStyle

    # 6. Restore Transient View if it exists and is not expired
    if ($Script:RenderCache.LastTransientConfig) {
        $hold = $Script:RenderCache.LastTransientConfig.HoldUntil
        if ($hold -and ([DateTime]::Now -lt $hold)) {
            Write-ScapeTransientView -RenderConfig $Script:RenderCache.LastTransientConfig
        }
    }

    # 7. Final State Commit
    $Script:RenderCache.LastViewportStart = $viewportStart
    $Script:RenderCache.LastViewportEnd = $viewportEnd
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

    $bannerMode = 'SmallLogo'
    $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $dims.Width
    $y = 1
    foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; [Console]::Write($line); $y++ }

    $items = $RenderConfig.Config.Items
    $totalItems = @($items).Count
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
    
    $bannerMode = 'SmallLogo'
    $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $dims.Width
    $y = 1
    foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; [Console]::Write($line); $y++ }

    $rows = $RenderConfig.Config.Rows
    $totalItems = @($rows).Count
    $box = Get-ScapeMenuLayout -MaxContentWidth 80 -ItemCount $totalItems -ConsoleWidth $dims.Width -ConsoleHeight $dims.Height -HeaderHeight $y
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
}

Export-ModuleMember -Function 'Initialize-ScapeRenderer',
                              'Close-ScapeRenderer',
                              'Write-ScapeMenuBuffer',
                              'Write-ScapeTransientView',
                              'Write-ScapeTreeView',
                              'Write-ScapeActionScreen'