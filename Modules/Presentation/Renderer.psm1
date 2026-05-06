<#
.SYNOPSIS
    Domain: Presentation\Renderer
    Module: Scape.Presentation.Renderer
    Architecture: Stateless Rendering | Absolute Grid Positioning | Zero Publishing | Receives Pre-Resolved Icons
#>
[CmdletBinding()] param()

# Cache de ícones resolvidos: "RouteId:IconLevel" => ícone
$Script:IconResolveCache = @{}
# Cache de linhas de menu pré-formatadas
$Script:MenuLineCache = @{}
# Cache de dimensões (já definido no TUI, mas reforçado aqui)
$Script:RenderCache = @{
    LastMenuHash = ""
    LastOptions  = @()
    LastCursor   = -1
}

function Initialize-ScapeRenderer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::CursorVisible = $false

        # VT100 já foi habilitado em Initialize-ScapeInterop (Core)
        # Apenas valida se está disponível para fail-fast explícito
        if (-not ("Scape.Core.Native.VT100Enabler" -as [type])) {
            if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) {
                Initialize-ScapeInterop | Out-Null
            }
            else {
                Publish-ScapeEvent -Type "RENDERER_INIT_WARN" -Severity "WARN" -Payload "VT100Enabler not available. Console may lack ANSI support."
            }
        }
    }
}

function Close-ScapeRenderer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        [Console]::CursorVisible = $true
        [Console]::Clear()
        # Limpa caches ao fechar
        $Script:IconResolveCache.Clear()
        $Script:MenuLineCache.Clear()
        $Script:RenderCache.LastMenuHash = ""
    }
}

# Memoization: Resolve ícone uma vez por RouteId+IconLevel
function _GetCachedResolvedIcon {
    param([string]$RouteId)
    process {
        $state = Get-ScapeColdState
        $level = if ($state.ContainsKey('IconLevel')) { [int]$state['IconLevel'] } else { 0 }
        $cacheKey = "${RouteId}:${level}"

        if ($Script:IconResolveCache.ContainsKey($cacheKey)) {
            return $Script:IconResolveCache[$cacheKey]
        }

        $icon = Get-ScapeResolvedIcon -RouteId $RouteId
        $Script:IconResolveCache[$cacheKey] = $icon
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
        $lines = ($raw -split "`n" | Where-Object { $_.Trim() })
        return @($lines | ForEach-Object {
                $clipped = Invoke-ScapeStringClip -Text $_ -MaxWidth $ConsoleWidth -CenterClip
                $pad = [Math]::Max(0, [Math]::Floor(($ConsoleWidth - $clipped.Length) / 2))
                Format-ScapeANSIMessage -Text (" " * $pad + $clipped) -Flag $ColorFlag
            })
    }
}

function Write-ScapeMenuBuffer {
    param($Options, $CursorIndex, $LastCursorIndex = -1, $TitleKey, $FullRedraw)

    # Memoization: pula render se nada mudou
    $menuHash = "${TitleKey}:${CursorIndex}:${($Options | ForEach-Object `{ $_.Id } | Sort-Object) -join ','}"
    if (-not $FullRedraw -and $Script:RenderCache.LastMenuHash -eq $menuHash) {
        return
    }
    $Script:RenderCache.LastMenuHash = $menuHash

    $dims = Get-ScapeConsoleDimension -WithMargins
    $itemCount = @($Options).Count

    $layout = Get-ScapeConstant -Path "ui::Layout"
    $bannerThreshold = $layout.HeaderHeight
    $bannerMode = 'Standard'
    if (($itemCount + $bannerThreshold) -gt $dims.Height) { $bannerMode = 'Compact' }

    if ($FullRedraw) {
        [Console]::Clear()
        $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $dims.Width
        $y = 1
        foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; [Console]::Write($line); $y++ }

        $titleNode = Get-ScapeI18NNode -Key $TitleKey
        $cleanTitle = $titleNode.Text -replace '^\[\s*|\s*\]$', ''

        $box = Get-ScapeMenuLayout -MaxContentWidth 45 -ItemCount $itemCount -ConsoleWidth $dims.Width -ConsoleHeight $dims.Height -HeaderHeight $y
        $Script:R_BoxCache = $box

        $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box

        $state = Get-ScapeColdState
        $frameStyle = if ($state.ContainsKey('FrameStyle')) { $state['FrameStyle'] } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
        $frame = Get-ScapeConstant -Path "ui::Frames::$frameStyle"

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
    }

    $box = $Script:R_BoxCache
    $rawSelIcon = Get-ScapeConstant -Path "ui::Icons::Submenu"
    $selIcon = if ($rawSelIcon -is [array]) { $rawSelIcon[0] } else { $rawSelIcon }

    for ($i = 0; $i -lt $itemCount; $i++) {
        $isCurrent = ($i -eq $CursorIndex)
        if ($FullRedraw -or $isCurrent -or ($i -eq $LastCursorIndex)) {
            $opt = $Options[$i]

            $i18nNode = Get-ScapeI18NNode -Key $opt.TitleKey
            $i18nStr = $i18nNode.Text
            $hintStr = $opt.Hint

            # Usa cache de ícone
            $icon = _GetCachedResolvedIcon -RouteId $opt.Id

            $flag = if ($opt.Type -eq 'UI') { 'MENU' } else { $opt.Type }
            $coords = Get-ScapeGridCoordinates -BoxLayout $box -ActiveIcon $icon -Index $i

            Set-ScapeCursorPosition -Left $coords.SelectorX -Top $coords.Y
            [Console]::Write(" " * $box.UsableWidth)

            if ($isCurrent) {
                Set-ScapeCursorPosition -Left $coords.SelectorX -Top $coords.Y
                [Console]::Write((Format-ScapeANSIMessage -Text $selIcon -Flag $flag -Bold))
            }

            Set-ScapeCursorPosition -Left $coords.IconX -Top $coords.Y
            [Console]::Write((Format-ScapeANSIMessage -Text $icon -Flag $flag))

            Set-ScapeCursorPosition -Left $coords.TextX -Top $coords.Y
            $displayText = $i18nStr
            if ($opt.DynamicText) { $displayText += $opt.DynamicText }
            $msg = Format-ScapeANSIMessage -Text $displayText -Flag $flag -Bold:$isCurrent -IncludeBackground:$isCurrent
            [Console]::Write($msg)

            if ($isCurrent -and $hintStr) {
                $hintY = $frameCoords.BottomY + 2
                Set-ScapeCursorPosition -Left $box.X -Top $hintY
                [Console]::Write(" " * $dims.Width)
                Set-ScapeCursorPosition -Left $box.X -Top $hintY
                [Console]::Write((Format-ScapeANSIMessage -Text $hintStr -Flag "HINT"))
            }
        }
    }
}

function Write-ScapeTransientView {
    [CmdletBinding()]
    [OutputType([void])]
    param([Parameter(Mandatory = $true)][hashtable]$RenderConfig)

    if (-not $RenderConfig.ShouldRender) { return }

    if ($RenderConfig.Type -eq 'TreeView') {
        Write-ScapeTreeView -RenderConfig $RenderConfig
        # Memoization: pula render se nada mudou
        $menuHash = "${TitleKey}:${CursorIndex}:${($Options | ForEach-Object `{ $_.Id } | Sort-Object) -join ','}"
        if (-not $FullRedraw -and $Script:RenderCache.LastMenuHash -eq $menuHash) {
            return
        }
        $Script:RenderCache.LastMenuHash = $menuHash
        return
    }
    $dims = Get-ScapeConsoleDimension -WithMargins
    $clippedText = Invoke-ScapeStringClip -Text $RenderConfig.Text -MaxWidth ($dims.Width - 2)
    $plainText = ($clippedText -replace '\x1B\[[0-9;]*[a-zA-Z]', '')
    $x = [Math]::Max(0, [Math]::Floor(($dims.Width - $plainText.Length) / 2))
    $safeWidth = $dims.Width - 2

    if ($RenderConfig.Type -eq 'StatusBar') {
        $y = $dims.Height - 2
        Set-ScapeCursorPosition -Left 1 -Top $y
        [Console]::Write((Format-ScapeANSIMessage -Text (" " * $safeWidth) -Flag "MENU"))
        Set-ScapeCursorPosition -Left $x -Top $y
        [Console]::Write((Format-ScapeANSIMessage -Text $clippedText -Flag $RenderConfig.Flag))
    }
    elseif ($RenderConfig.Type -eq 'Transient') {
        $y = $dims.Height - 1
        Set-ScapeCursorPosition -Left 1 -Top $y
        [Console]::Write((Format-ScapeANSIMessage -Text (" " * $safeWidth) -Flag "MENU"))
        Set-ScapeCursorPosition -Left $x -Top $y
        [Console]::Write((Format-ScapeANSIMessage -Text $clippedText -Flag $RenderConfig.Flag))
    }
}

function Write-ScapeTreeView {
    [CmdletBinding()]
    param([hashtable]$RenderConfig)
    if (-not $RenderConfig.ShouldRender) { return }

    $dims = Get-ScapeConsoleDimension -WithMargins
    $title = Get-ScapeI18NNode -Key $RenderConfig.Config.TitleKey
    $cleanTitle = $title.Text -replace '^\[\s*|\s*\]$', ''

    $bannerMode = 'SmallLogo'
    $banner = Format-ScapeArtBlock -VariantKey $bannerMode -ConsoleWidth $dims.Width
    $y = 1
    foreach ($line in $banner) { Set-ScapeCursorPosition -Left 0 -Top $y; [Console]::Write($line); $y++ }

    $box = Get-ScapeMenuLayout -MaxContentWidth 80 -ItemCount $RenderConfig.Config.Items.Count -ConsoleWidth $dims.Width -ConsoleHeight $dims.Height -HeaderHeight $y

    $frameCoords = Get-ScapeFrameCoordinates -BoxLayout $box
    $state = Get-ScapeColdState
    $frameStyle = if ($state.ContainsKey('FrameStyle')) { $state['FrameStyle'] } else { Get-ScapeConstant -Path "ui::Defaults::FrameStyle" }
    $frame = Get-ScapeConstant -Path "ui::Frames::$frameStyle"
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
    foreach ($item in $RenderConfig.Config.Items) {
        if ($yOffset -ge ($frameCoords.BottomY)) { break }

        $indent = "  " * $item.Depth
        $rawLine = "$indent$($item.Text)"

        $clippedLine = Invoke-ScapeStringClip -Text $rawLine -MaxWidth ($box.Width - 4)
        $padding = Get-ScapeJustifiedPadding -LeftText $clippedLine -RightText "" -TotalWidth ($box.Width - 4)

        Set-ScapeCursorPosition -Left $frameCoords.ContentX -Top $yOffset
        [Console]::Write((Format-ScapeANSIMessage -Text ($clippedLine + $padding) -Flag $item.StatusFlag))
        $yOffset++
    }
}
