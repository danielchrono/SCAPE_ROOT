<#
.SYNOPSIS
    Domain: Presentation\Theme
    Module: Scape.Presentation.Theme
    Architecture: Pure Math | HSL Trigonometry | Adaptive Contrast | Immutable Origin
#>

# --- REGISTRY E ESTADO DO SCRIPT ---
$Script:ThemeCache = $null
$Script:UICache = $null
$Script:IconCache = $null
$Script:ColorMode = "ANSI16"
$Script:LiveFlagMap = @{}
$Script:ActivePaletteName = ""
$Script:ActivePaletteMap = @{}

function Initialize-ScapeTheme {
    [CmdletBinding()]
    param()

    # 1. Carregamento Seguro (Prevenção contra "Cannot index into a null array")
    $Script:ThemeCache = Get-ScapeConstant -Path "theme" -Fallback @{}

    # 2. Detecção de Terminal
    if ($env:WT_SESSION -or $env:TERM_PROGRAM -eq "vscode" -or $env:ConEmuPID -or $env:COLORTERM -eq "truecolor") {
        $Script:ColorMode = "TrueColor"
    }

    # 3. População do LiveFlagMap (Segura e Resiliente)
    $Script:LiveFlagMap = @{}
    if ($Script:ThemeCache.Contains("FlagMap")) {
        $baseMap = $Script:ThemeCache["FlagMap"]
        foreach ($key in $baseMap.Keys) {
            $Script:LiveFlagMap[$key] = @{
                RGB      = $baseMap[$key].RGB
                Priority = $baseMap[$key].Priority
            }
        }
    }
    $Script:ActivePaletteName = "Default"
    $Script:ActivePaletteMap = @{}

    # 4. Aplicação de Persona e Modo de Cor do Estado (Se houver)
    # MVVM estrito: Theme apenas inicializa constantes/dados puros.
    # A leitura de ColdState e aplicação (Set-ScapePersona/ColorMode) devem ser
    # coordenadas pela camada superior, não na inicialização pura da Theme.
}

# --- GESTÃO DE ÍCONES (Resolvendo o $icons perdido) ---

function Get-ScapeIcon {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$IconName)
    process {
        # Resolve o nível atual (0=Graphic, 1=Unicode, 2=ASCII)
        # O Fallback aqui é o seu detector automático se o ColdState falhar
        $level = Get-ScapeConstant -Path "IconLevel" -Fallback (Get-ScapeDefaultIconLevel)

        $iconArr = Get-ScapeConstant -Path "ui::Icons::$IconName"
        if ($null -ne $iconArr -and $iconArr -is [array] -and $iconArr.Count -gt $level) {
            return $iconArr[$level]
        }
        return ""
    }
}

# --- MATEMÁTICA DE COR E CONVERSÃO ---

function Get-ScapeClamp {
    param([double]$Value, [double]$Min, [double]$Max)
    return [Math]::Max($Min, [Math]::Min($Max, $Value))
}

function Get-ScapeLuminance {
    param([int]$R, [int]$G, [int]$B)
    return (0.299 * $R) + (0.587 * $G) + (0.114 * $B)
}

function Convert-ScapeHSLToRGB {
    param([double]$H, [double]$S, [double]$L)
    if ($S -eq 0) {
        $v = [int][Math]::Round($L * 255)
        return @($v, $v, $v)
    }
    $q = if ($L -lt 0.5) { $L * (1 + $S) } else { $L + $S - ($L * $S) }
    $p = 2 * $L - $q
    $hk = $H / 360.0
    $t = @( ($hk + 1.0 / 3.0), $hk, ($hk - 1.0 / 3.0) )
    $rgb = @(0, 0, 0)
    for ($i = 0; $i -lt 3; $i++) {
        if ($t[$i] -lt 0) { $t[$i] += 1.0 }
        if ($t[$i] -gt 1) { $t[$i] -= 1.0 }
        if ($t[$i] -lt (1.0 / 6.0)) { $rgb[$i] = $p + (($q - $p) * 6.0 * $t[$i]) }
        elseif ($t[$i] -lt (1.0 / 2.0)) { $rgb[$i] = $q }
        elseif ($t[$i] -lt (2.0 / 3.0)) { $rgb[$i] = $p + (($q - $p) * ((2.0 / 3.0) - $t[$i]) * 6.0) }
        else { $rgb[$i] = $p }
        $rgb[$i] = [int][Math]::Round($rgb[$i] * 255)
    }
    return $rgb
}

function Convert-ScapeRGBToAnsi {
    param([int[]]$RGB, [switch]$IsBackground)
    $trueColorPrefix = Get-ScapeConstant -Path "ui::ANSI::TrueColor$(if ($IsBackground) { 'Bg' } else { 'Fg' })Prefix"
    return "${trueColorPrefix}$($RGB[0]);$($RGB[1]);$($RGB[2])m"
}

function Convert-ScapeAnsiToReset { 
    $reset = Get-ScapeConstant -Path "ui::ANSI::SGR::Reset"
    if (-not $reset) { $reset = Get-ScapeConstant -Path "ui::ANSI::SGR::Reset" }
    return $reset
}

# --- MANIPULAÇÃO DINÂMICA ---

function Invoke-ScapeLightfy {
    param([int[]]$RGB, [double]$Factor = 0.2)
    $r = [int]($RGB[0] + ((255 - $RGB[0]) * $Factor))
    $g = [int]($RGB[1] + ((255 - $RGB[1]) * $Factor))
    $b = [int]($RGB[2] + ((255 - $RGB[2]) * $Factor))
    return @((Get-ScapeClamp -Value $r -Min 0 -Max 255), (Get-ScapeClamp -Value $g -Min 0 -Max 255), (Get-ScapeClamp -Value $b -Min 0 -Max 255))
}

function Invoke-ScapeDarkfy {
    param([int[]]$RGB, [double]$Factor = 0.2)
    $f = 1.0 - $Factor
    $r = [int]($RGB[0] * $f); $g = [int]($RGB[1] * $f); $b = [int]($RGB[2] * $f)
    return @((Get-ScapeClamp -Value $r -Min 0 -Max 255), (Get-ScapeClamp -Value $g -Min 0 -Max 255), (Get-ScapeClamp -Value $b -Min 0 -Max 255))
}

function Get-ScapeSafeColor {
    param([int[]]$RGB, [int[]]$BgRGB = $null)
    if ($null -eq $BgRGB) { $BgRGB = Get-ScapeConstant -Path "ui::ColorConfig::BgRGB" -Fallback @(20, 20, 20) }
    $lumFg = Get-ScapeLuminance -R $RGB[0] -G $RGB[1] -B $RGB[2]
    $lumBg = Get-ScapeLuminance -R $BgRGB[0] -G $BgRGB[1] -B $BgRGB[2]
    if ([Math]::Abs($lumFg - $lumBg) -lt 60) {
        if ($lumBg -lt 128) { return Invoke-ScapeLightfy -RGB $RGB -Factor 0.6 }
        else { return Invoke-ScapeDarkfy -RGB $RGB -Factor 0.6 }
    }
    return $RGB
}

# --- TEMAS PROCEDURAIS E FILTROS ---

function Invoke-ScapeProceduralTheme {
    [CmdletBinding()]
    param([double]$BaseHue)
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    $hasBaseHue = $PSBoundParameters.ContainsKey('BaseHue') -and -not [double]::IsNaN($BaseHue) -and -not [double]::IsInfinity($BaseHue)
    $baseHue = if ($hasBaseHue) { ((($BaseHue % 360) + 360) % 360) } else { ([Random]::new()).NextDouble() * 360 }
    $uiHue = ($baseHue + 30) % 360
    $warnHue = ($baseHue + 180) % 360
    $dangerHue = ($warnHue + 30) % 360
    $S = 0.85; $L = 0.65

    foreach ($key in $Script:LiveFlagMap.Keys) {
        if ($key -match "FATAL|ERR") { $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $dangerHue -S 0.9 -L 0.6 }
        elseif ($key -match "WARN|MENU") { $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $warnHue -S $S -L $L }
        elseif ($key -match "STATUS|CONFIRM|DONE") { $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H (($baseHue + 120) % 360) -S 0.8 -L 0.5 }
        elseif ($key -match "SYSTEM|UI|HINT") { $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $uiHue -S $S -L $L }
        else { $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $baseHue -S 0.2 -L 0.7 }
    }
}

function Invoke-ScapeDaltonismMatrix {
    param([string]$Type = "Protanopia")
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    $filters = $Script:ThemeCache.Contrast["DaltonismFilters"]
    if ($null -eq $filters -or -not $filters.Contains($Type)) { return }
    $mat = $filters[$Type]

    foreach ($key in $Script:LiveFlagMap.Keys) {
        $rgb = Resolve-ScapeRawRGB -RawValue $Script:LiveFlagMap[$key].RGB
        if ($null -ne $rgb) {
            $r = [int]($rgb[0] * $mat.RedFactor); $g = [int]($rgb[1] * $mat.GreenFactor); $b = [int]($rgb[2] * $mat.BlueFactor)
            $filtered = @((Get-ScapeClamp -Value $r -Min 0 -Max 255), (Get-ScapeClamp -Value $g -Min 0 -Max 255), (Get-ScapeClamp -Value $b -Min 0 -Max 255))
            $Script:LiveFlagMap[$key].RGB = Invoke-ScapeLightfy -RGB $filtered -Factor 0.3
        }
    }
}

# --- SETTERS E RESOLVERS ---

function Set-ScapePersona {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Name)
    
    $result = @{}
    
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    $persona = $Script:ThemeCache.Persona[$Name]
    if ($persona) {
        # Apply Palette
        $paletteName = $persona.Palette
        if ($paletteName -and $Script:ThemeCache.Base[$paletteName]) {
            $Script:ActivePaletteName = [string]$paletteName
            $Script:ActivePaletteMap = $Script:ThemeCache.Base[$paletteName]
            $baseMap = $Script:ThemeCache.FlagMap
            foreach ($key in $baseMap.Keys) {
                $rgbRef = $baseMap[$key].RGB
                if ($rgbRef -is [string] -and $rgbRef -match '^Base\.(\w+)') {
                    $colorName = $matches[1]
                    $newRGB = Resolve-ScapeRawRGB -RawValue $rgbRef
                    if ($newRGB) { $Script:LiveFlagMap[$key].RGB = $newRGB }
                }
            }
        }
            
        if ($persona.Frame) { $result["FrameStyle"] = $persona.Frame }
        if ($persona.Progress) { $result["ProgressStyle"] = $persona.Progress }
        if ($null -ne $persona.Animation) { $result["AnimationEnabled"] = [bool]$persona.Animation }
        if ($persona.Contrast) { $result["ContrastMode"] = $persona.Contrast }
    }return $result
}

function Set-ScapeColorMode {
    [CmdletBinding()]
    param([bool]$UseTrueColor)
    if ($UseTrueColor) { $Script:ColorMode = "TrueColor" }
    else { $Script:ColorMode = "ANSI16" }
}

function Resolve-ScapeRawRGB {
    param($RawValue)
    if ($RawValue -is [array]) { return $RawValue }
    if ($RawValue -is [string] -and $RawValue -match '^Base\.(\w+)$') {
        $colorName = $matches[1]
        $base = $Script:ThemeCache["Base"]
        if ($base.Contains($colorName)) { return $base[$colorName] }
        if ($Script:ActivePaletteMap -and $Script:ActivePaletteMap.Contains($colorName)) { return $Script:ActivePaletteMap[$colorName] }

        $aliases = @{
            Primary = @('Blue', 'Cyan', 'Teal')
            Accent  = @('Cyan', 'Magenta', 'Purple', 'Green')
            Surface = @('Gray', 'Dim')
            Bg      = @('Black', 'DarkGray')
            Text    = @('White', 'Silver')
            Muted   = @('Gray', 'Dim')
            Success = @('Green', 'Lime')
            Warning = @('Amber', 'Yellow', 'Orange')
            Error   = @('Red', 'Coral')
            Info    = @('Cyan', 'Blue')
        }
        if ($aliases.ContainsKey($colorName)) {
            foreach ($candidate in $aliases[$colorName]) {
                if ($Script:ActivePaletteMap -and $Script:ActivePaletteMap.Contains($candidate)) { return $Script:ActivePaletteMap[$candidate] }
                if ($base.Contains($candidate)) { return $base[$candidate] }
            }
        }
    }
    return Get-ScapeConstant -Path "ui::ColorConfig::DefaultRGB" -Fallback @(120, 120, 120)
}

function Resolve-ScapeThemeColor {
    param([string]$Flag)
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    if ($Script:LiveFlagMap.Contains($Flag)) {
        $rgb = Resolve-ScapeRawRGB -RawValue $Script:LiveFlagMap[$Flag].RGB
        return Get-ScapeSafeColor -RGB $rgb
    }
    return Get-ScapeConstant -Path "ui::ColorConfig::DefaultRGB" -Fallback @(120, 120, 120)
}

function Get-ScapeAnsi16SequenceForFlag {
    [CmdletBinding()]
    [OutputType([string])]
    param([string]$Flag)

    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    $fallbackMap = Get-ScapeConstant -Path "theme::Fallback::ANSI16Map" -Fallback @{}
    $colorRef = "Base.White"

    if ($Script:LiveFlagMap.Contains($Flag)) {
        $raw = $Script:LiveFlagMap[$Flag].RGB
        if ($raw -is [string] -and $fallbackMap.Contains($raw)) {
            $colorRef = $raw
        }
    }

    $token = if ($fallbackMap.Contains($colorRef)) { [string]$fallbackMap[$colorRef] } else { "FG.White" }
    $ansiByToken = @{
        "FG.Black"         = Get-ScapeConstant -Path "ui::ANSI::FG::Black"
        "FG.Red"           = Get-ScapeConstant -Path "ui::ANSI::FG::Red"
        "FG.Green"         = Get-ScapeConstant -Path "ui::ANSI::FG::Green"
        "FG.Yellow"        = Get-ScapeConstant -Path "ui::ANSI::FG::Yellow"
        "FG.Blue"          = Get-ScapeConstant -Path "ui::ANSI::FG::Blue"
        "FG.Magenta"       = Get-ScapeConstant -Path "ui::ANSI::FG::Magenta"
        "FG.Cyan"          = Get-ScapeConstant -Path "ui::ANSI::FG::Cyan"
        "FG.White"         = Get-ScapeConstant -Path "ui::ANSI::FG::White"
        "FG.BrightBlack"   = Get-ScapeConstant -Path "ui::ANSI::FG::BrightBlack"
        "FG.BrightRed"     = Get-ScapeConstant -Path "ui::ANSI::FG::BrightRed"
        "FG.BrightGreen"   = Get-ScapeConstant -Path "ui::ANSI::FG::BrightGreen"
        "FG.BrightYellow"  = Get-ScapeConstant -Path "ui::ANSI::FG::BrightYellow"
        "FG.BrightBlue"    = Get-ScapeConstant -Path "ui::ANSI::FG::BrightBlue"
        "FG.BrightMagenta" = Get-ScapeConstant -Path "ui::ANSI::FG::BrightMagenta"
        "FG.BrightCyan"    = Get-ScapeConstant -Path "ui::ANSI::FG::BrightCyan"
        "FG.BrightWhite"   = Get-ScapeConstant -Path "ui::ANSI::FG::BrightWhite"
    }
    if ($ansiByToken.ContainsKey($token)) { return $ansiByToken[$token] }
    return Get-ScapeConstant -Path "ui::ANSI::FG::White"
}

# --- FORMATADOR FINAL ---

function Format-ScapeANSIMessage {
    param(
        [AllowEmptyString()][string]$Text = "",
        [string]$Flag,
        [switch]$IncludeBackground,
        [switch]$Bold,
        [switch]$Dim
    )
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }

    $reset = Get-ScapeConstant -Path "ui::ANSI::SGR::Reset"
    $boldPrefix = Get-ScapeConstant -Path "ui::ANSI::SGR::Bold"
    $dimPrefix = Get-ScapeConstant -Path "ui::ANSI::SGR::Dim"
    
    $prefix = ""
    if ($Bold) { $prefix += $boldPrefix }
    if ($Dim) { $prefix += $dimPrefix }

    if ($Script:ColorMode -eq "TrueColor") {
        $rgb = Resolve-ScapeThemeColor -Flag $Flag
        $fgAnsi = Convert-ScapeRGBToAnsi -RGB $rgb
        return "${prefix}${fgAnsi}${Text}${reset}"
    }

    # Fallback ANSI 16 data-driven via theme::Fallback::ANSI16Map
    $fgAnsi16 = Get-ScapeAnsi16SequenceForFlag -Flag $Flag
    return "${prefix}${fgAnsi16}${Text}${reset}"
}

# =============================================================================
# CENTRALIZADOR DE ÍCONES (Data-Driven | Zero Hardcode | Usa Cache do Theme)
# =============================================================================
function Get-ScapeResolvedIcon {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$RouteId,
        [Parameter()][int]$IconLevel = 0
    )
    process {
        # 1. Resolve nome semântico via ui::SemanticMap (fonte da verdade)
        $semanticMap = Get-ScapeConstant -Path "ui::SemanticMap"
        $iconName = if ($semanticMap -and $semanticMap.ContainsKey($RouteId)) { $semanticMap[$RouteId] } else { $RouteId }

        # 2. Busca array de ícones na ui.psd1
        $iconArr = Get-ScapeConstant -Path "ui::Icons::$iconName"
        if ($null -eq $iconArr -or $iconArr -isnot [array] -or $iconArr.Count -eq 0) { return "" }

        # MVVM estrito: IconLevel deve ser input read-only
        $level = if ($IconLevel -lt 0) { 0 } else { [int]$IconLevel }
        if ($level -ge $iconArr.Count) { $level = $iconArr.Count - 1 }

        return [string]$iconArr[$level]
    }
}


function Format-ScapeANSIHighlight {
    param([string]$Text, [string]$Flag)
    $reset = Get-ScapeConstant -Path "ui::ANSI::SGR::Reset"
    if (-not $reset) { $reset = Get-ScapeConstant -Path "ui::ANSI::SGR::Reset" }
    
    if ($Script:ColorMode -eq "TrueColor") {
        $rgb = Resolve-ScapeThemeColor -Flag $Flag
        $bgAnsi = Convert-ScapeRGBToAnsi -RGB $rgb -IsBackground $true
        $fgAnsi = Get-ScapeConstant -Path "ui::ANSI::FG::Black"
        return "${bgAnsi}${fgAnsi}${Text}${reset}"
    }
    else {
        $fgAnsi16 = Get-ScapeAnsi16SequenceForFlag -Flag $Flag
        $bgAnsi16 = $fgAnsi16 -replace '\[3', '[4' -replace '\[9', '[10'
        $blackText = Get-ScapeConstant -Path "ui::ANSI::FG::Black"
        return "${bgAnsi16}${blackText}${Text}${reset}"
    }
}

Export-ModuleMember -Function *


# --- INJECTED I18N KEYS ---
# THEME_APPLIED


# --- INJECTED I18N KEYS ---
# THEME_APPLIED


# ==========================================
# INJECTED UI CONSTANTS (DYNAMIC RESOLUTION)
# ==========================================
# ui::ANSI::BG
# ui::ANSI::BG::Black
# ui::ANSI::BG::Blue
# ui::ANSI::BG::BrightBlack
# ui::ANSI::BG::BrightBlue
# ui::ANSI::BG::BrightCyan
# ui::ANSI::BG::BrightGreen
# ui::ANSI::BG::BrightMagenta
# ui::ANSI::BG::BrightRed
# ui::ANSI::BG::BrightWhite
# ui::ANSI::BG::BrightYellow
# ui::ANSI::BG::Cyan
# ui::ANSI::BG::Default
# ui::ANSI::BG::Green
# ui::ANSI::BG::Magenta
# ui::ANSI::BG::Red
# ui::ANSI::BG::White
# ui::ANSI::BG::Yellow
# ui::ANSI::Color256BgPrefix
# ui::ANSI::Color256FgPrefix
# ui::ANSI::Cursor
# ui::ANSI::Cursor::Backward
# ui::ANSI::Cursor::BlinkBlock
# ui::ANSI::Cursor::BlinkLine
# ui::ANSI::Cursor::BlinkUnderscore
# ui::ANSI::Cursor::Column
# ui::ANSI::Cursor::Down
# ui::ANSI::Cursor::Forward
# ui::ANSI::Cursor::Hide
# ui::ANSI::Cursor::Left
# ui::ANSI::Cursor::LineEnd
# ui::ANSI::Cursor::LineStart
# ui::ANSI::Cursor::NextLine
# ui::ANSI::Cursor::PrevLine
# ui::ANSI::Cursor::Restore
# ui::ANSI::Cursor::Right
# ui::ANSI::Cursor::Save
# ui::ANSI::Cursor::ShapeBlock
# ui::ANSI::Cursor::ShapeLine
# ui::ANSI::Cursor::ShapeUnderscore
# ui::ANSI::Cursor::Show
# ui::ANSI::Cursor::Up
# ui::ANSI::DEC
# ui::ANSI::DEC::DisableAltBuffer
# ui::ANSI::DEC::DisableAutoWrap
# ui::ANSI::DEC::DisableBracketedPaste
# ui::ANSI::DEC::DisableFocusInOut
# ui::ANSI::DEC::DisableSixel
# ui::ANSI::DEC::EnableAltBuffer
# ui::ANSI::DEC::EnableAutoWrap
# ui::ANSI::DEC::EnableBracketedPaste
# ui::ANSI::DEC::EnableCursorKeys
# ui::ANSI::DEC::EnableFocusInOut
# ui::ANSI::DEC::EnableSixel
# ui::ANSI::FG
# ui::ANSI::FG::Default
# ui::ANSI::Keyboard
# ui::ANSI::Keyboard::EnableCSIU
# ui::ANSI::Keyboard::EnableKitty
# ui::ANSI::Keyboard::LegacyMap
# ui::ANSI::Keyboard::LegacyMap::Delete
# ui::ANSI::Keyboard::LegacyMap::Down
# ui::ANSI::Keyboard::LegacyMap::End
# ui::ANSI::Keyboard::LegacyMap::F1
# ui::ANSI::Keyboard::LegacyMap::F10
# ui::ANSI::Keyboard::LegacyMap::F11
# ui::ANSI::Keyboard::LegacyMap::F12
# ui::ANSI::Keyboard::LegacyMap::F2
# ui::ANSI::Keyboard::LegacyMap::F3
# ui::ANSI::Keyboard::LegacyMap::F4
# ui::ANSI::Keyboard::LegacyMap::F5
# ui::ANSI::Keyboard::LegacyMap::F6
# ui::ANSI::Keyboard::LegacyMap::F7
# ui::ANSI::Keyboard::LegacyMap::F8
# ui::ANSI::Keyboard::LegacyMap::F9
# ui::ANSI::Keyboard::LegacyMap::Home
# ui::ANSI::Keyboard::LegacyMap::Insert
# ui::ANSI::Keyboard::LegacyMap::Left
# ui::ANSI::Keyboard::LegacyMap::PageDown
# ui::ANSI::Keyboard::LegacyMap::PageUp
# ui::ANSI::Keyboard::LegacyMap::Right
# ui::ANSI::Keyboard::LegacyMap::Up
# ui::ANSI::Mouse
# ui::ANSI::Mouse::DisableAnyEvent
# ui::ANSI::Mouse::DisableButtonEvent
# ui::ANSI::Mouse::DisableNormal
# ui::ANSI::Mouse::DisableSGR
# ui::ANSI::Mouse::DisableUTF8Ext
# ui::ANSI::Mouse::DisableX10
# ui::ANSI::Mouse::EnableAnyEvent
# ui::ANSI::Mouse::EnableButtonEvent
# ui::ANSI::Mouse::EnableNormal
# ui::ANSI::Mouse::EnableSGR
# ui::ANSI::Mouse::EnableUTF8Ext
# ui::ANSI::Mouse::EnableX10
# ui::ANSI::Mouse::ReportFormat
# ui::ANSI::OSC
# ui::ANSI::OSC::ClipboardRead
# ui::ANSI::OSC::ClipboardWrite
# ui::ANSI::OSC::HyperlinkClose
# ui::ANSI::OSC::HyperlinkOpen
# ui::ANSI::OSC::Notify
# ui::ANSI::OSC::QueryColors
# ui::ANSI::OSC::SetIconTitle
# ui::ANSI::OSC::SetTitle
# ui::ANSI::OSC::ShellCommand
# ui::ANSI::OSC::ShellExit
# ui::ANSI::OSC::ShellPrompt
# ui::ANSI::Screen
# ui::ANSI::Screen::ClearLineFull
# ui::ANSI::Screen::ClearToBOL
# ui::ANSI::Screen::ClearToEOL
# ui::ANSI::Screen::EraseSavedLines
# ui::ANSI::Screen::EraseScreen
# ui::ANSI::Screen::RestoreCursorState
# ui::ANSI::Screen::SaveCursorState
# ui::ANSI::Screen::ScrollDown
# ui::ANSI::Screen::ScrollUp
# ui::ANSI::Screen::SetColumns
# ui::ANSI::Screen::SetRegion
# ui::ANSI::SGR
# ui::ANSI::SGR::BackgroundReset
# ui::ANSI::SGR::DefaultFont
# ui::ANSI::SGR::DoublyUnderline
# ui::ANSI::SGR::ForegroundReset
# ui::ANSI::SGR::Fraktur
# ui::ANSI::SGR::Hidden
# ui::ANSI::SGR::Invert
# ui::ANSI::SGR::Italic
# ui::ANSI::SGR::NoBlink
# ui::ANSI::SGR::NoHidden
# ui::ANSI::SGR::NoInvert
# ui::ANSI::SGR::NoStrike
# ui::ANSI::SGR::RapidBlink
# ui::ANSI::SGR::SlowBlink
# ui::ANSI::SGR::Strike
# ui::ANSI::SGR::Underline
# ui::ANSI::TrueColorBgPrefix
# ui::ANSI::TrueColorFgPrefix
# ui::Art
# ui::Art::BannerLogo
# ui::Art::DashedSepLong
# ui::Art::DottedSepLong
# ui::Art::DoubleSepLong
# ui::Art::SeparatorLong
# ui::Art::SmallLogo
# ui::Art::SmallLogoIcon
# ui::Art::SmallLogoMicro
# ui::Art::SmallLogoStatus
# ui::Art::ThickSepLong
# ui::Art::Variants::Compact
# ui::Art::Variants::IconOnly
# ui::Art::Variants::Micro
# ui::Art::Variants::Standard
# ui::Art::Variants::StatusBar
# ui::Branding
# ui::Branding::Author
# ui::Branding::Doc
# ui::Branding::License
# ui::Branding::Product
# ui::Branding::Repo
# ui::Branding::Support
# ui::Branding::Tagline
# ui::Branding::Version
# ui::ColorConfig
# ui::Config
# ui::CycleLists::ColorMode::I18NKey
# ui::CycleLists::ColorMode::Options
# ui::CycleLists::EngineMode::I18NKey
# ui::CycleLists::EngineMode::Options
# ui::CycleLists::FrameStyle
# ui::CycleLists::FrameStyle::I18NKey
# ui::CycleLists::FrameStyle::Options
# ui::CycleLists::HydrationMode
# ui::CycleLists::HydrationMode::I18NKey
# ui::CycleLists::HydrationMode::Options
# ui::CycleLists::I18N::I18NKey
# ui::CycleLists::I18N::Options
# ui::CycleLists::IconLevel
# ui::CycleLists::IconLevel::I18NKey
# ui::CycleLists::IconLevel::Options
# ui::CycleLists::ProgressStyle
# ui::CycleLists::ProgressStyle::I18NKey
# ui::CycleLists::ProgressStyle::Options
# ui::CycleLists::RC_MT::I18NKey
# ui::CycleLists::RC_MT::Options
# ui::CycleLists::RC_R::I18NKey
# ui::CycleLists::RC_R::Options
# ui::CycleLists::RC_W::I18NKey
# ui::CycleLists::RC_W::Options
# ui::CycleLists::ThemeColor
# ui::CycleLists::ThemeColor::I18NKey
# ui::CycleLists::ThemeColor::Options
# ui::CycleLists::ThemePersona::I18NKey
# ui::CycleLists::ThemePersona::Options
# ui::Feedback
# ui::Frames
# ui::Frames::ASCII
# ui::Frames::ASCII::BL
# ui::Frames::ASCII::BR
# ui::Frames::ASCII::Cross
# ui::Frames::ASCII::HL
# ui::Frames::ASCII::ML
# ui::Frames::ASCII::MR
# ui::Frames::ASCII::Name
# ui::Frames::ASCII::TeeDown
# ui::Frames::ASCII::TeeLeft
# ui::Frames::ASCII::TeeRight
# ui::Frames::ASCII::TeeUp
# ui::Frames::ASCII::TL
# ui::Frames::ASCII::TR
# ui::Frames::ASCII::VL
# ui::Frames::Block
# ui::Frames::Block::BL
# ui::Frames::Block::BR
# ui::Frames::Block::Cross
# ui::Frames::Block::HL
# ui::Frames::Block::ML
# ui::Frames::Block::MR
# ui::Frames::Block::Name
# ui::Frames::Block::TeeDown
# ui::Frames::Block::TeeLeft
# ui::Frames::Block::TeeRight
# ui::Frames::Block::TeeUp
# ui::Frames::Block::TL
# ui::Frames::Block::TR
# ui::Frames::Block::VL
# ui::Frames::Borderless
# ui::Frames::Borderless::BL
# ui::Frames::Borderless::BR
# ui::Frames::Borderless::Cross
# ui::Frames::Borderless::HL
# ui::Frames::Borderless::ML
# ui::Frames::Borderless::MR
# ui::Frames::Borderless::Name
# ui::Frames::Borderless::TeeDown
# ui::Frames::Borderless::TeeLeft
# ui::Frames::Borderless::TeeRight
# ui::Frames::Borderless::TeeUp
# ui::Frames::Borderless::TL
# ui::Frames::Borderless::TR
# ui::Frames::Borderless::VL
# ui::Frames::Classic::BL
# ui::Frames::Classic::BR
# ui::Frames::Classic::Cross
# ui::Frames::Classic::HL
# ui::Frames::Classic::ML
# ui::Frames::Classic::MR
# ui::Frames::Classic::Name
# ui::Frames::Classic::TeeDown
# ui::Frames::Classic::TeeLeft
# ui::Frames::Classic::TeeRight
# ui::Frames::Classic::TeeUp
# ui::Frames::Classic::TL
# ui::Frames::Classic::TR
# ui::Frames::Classic::VL
# ui::Frames::Cyber
# ui::Frames::Cyber::BL
# ui::Frames::Cyber::BR
# ui::Frames::Cyber::Cross
# ui::Frames::Cyber::HL
# ui::Frames::Cyber::ML
# ui::Frames::Cyber::MR
# ui::Frames::Cyber::Name
# ui::Frames::Cyber::TeeDown
# ui::Frames::Cyber::TeeLeft
# ui::Frames::Cyber::TeeRight
# ui::Frames::Cyber::TeeUp
# ui::Frames::Cyber::TL
# ui::Frames::Cyber::TR
# ui::Frames::Cyber::VL
# ui::Frames::Dotted
# ui::Frames::Dotted::BL
# ui::Frames::Dotted::BR
# ui::Frames::Dotted::Cross
# ui::Frames::Dotted::HL
# ui::Frames::Dotted::ML
# ui::Frames::Dotted::MR
# ui::Frames::Dotted::Name
# ui::Frames::Dotted::TeeDown
# ui::Frames::Dotted::TeeLeft
# ui::Frames::Dotted::TeeRight
# ui::Frames::Dotted::TeeUp
# ui::Frames::Dotted::TL
# ui::Frames::Dotted::TR
# ui::Frames::Dotted::VL
# ui::Frames::Heavy
# ui::Frames::Heavy::BL
# ui::Frames::Heavy::BR
# ui::Frames::Heavy::Cross
# ui::Frames::Heavy::HL
# ui::Frames::Heavy::ML
# ui::Frames::Heavy::MR
# ui::Frames::Heavy::Name
# ui::Frames::Heavy::TeeDown
# ui::Frames::Heavy::TeeLeft
# ui::Frames::Heavy::TeeRight
# ui::Frames::Heavy::TeeUp
# ui::Frames::Heavy::TL
# ui::Frames::Heavy::TR
# ui::Frames::Heavy::VL
# ui::Frames::Minimal
# ui::Frames::Minimal::BL
# ui::Frames::Minimal::BR
# ui::Frames::Minimal::Cross
# ui::Frames::Minimal::HL
# ui::Frames::Minimal::ML
# ui::Frames::Minimal::MR
# ui::Frames::Minimal::Name
# ui::Frames::Minimal::TeeDown
# ui::Frames::Minimal::TeeLeft
# ui::Frames::Minimal::TeeRight
# ui::Frames::Minimal::TeeUp
# ui::Frames::Minimal::TL
# ui::Frames::Minimal::TR
# ui::Frames::Minimal::VL
# ui::Frames::PowerShell
# ui::Frames::PowerShell::BL
# ui::Frames::PowerShell::BR
# ui::Frames::PowerShell::Cross
# ui::Frames::PowerShell::HL
# ui::Frames::PowerShell::ML
# ui::Frames::PowerShell::MR
# ui::Frames::PowerShell::Name
# ui::Frames::PowerShell::TeeDown
# ui::Frames::PowerShell::TeeLeft
# ui::Frames::PowerShell::TeeRight
# ui::Frames::PowerShell::TeeUp
# ui::Frames::PowerShell::TL
# ui::Frames::PowerShell::TR
# ui::Frames::PowerShell::VL
# ui::Frames::Retro
# ui::Frames::Retro::BL
# ui::Frames::Retro::BR
# ui::Frames::Retro::Cross
# ui::Frames::Retro::HL
# ui::Frames::Retro::ML
# ui::Frames::Retro::MR
# ui::Frames::Retro::Name
# ui::Frames::Retro::TeeDown
# ui::Frames::Retro::TeeLeft
# ui::Frames::Retro::TeeRight
# ui::Frames::Retro::TeeUp
# ui::Frames::Retro::TL
# ui::Frames::Retro::TR
# ui::Frames::Retro::VL
# ui::Frames::Rounded
# ui::Frames::Rounded::BL
# ui::Frames::Rounded::BR
# ui::Frames::Rounded::Cross
# ui::Frames::Rounded::HL
# ui::Frames::Rounded::ML
# ui::Frames::Rounded::MR
# ui::Frames::Rounded::Name
# ui::Frames::Rounded::TeeDown
# ui::Frames::Rounded::TeeLeft
# ui::Frames::Rounded::TeeRight
# ui::Frames::Rounded::TeeUp
# ui::Frames::Rounded::TL
# ui::Frames::Rounded::TR
# ui::Frames::Rounded::VL
# ui::Help
# ui::Help::BreadcrumbSep
# ui::Help::Colors
# ui::Help::Colors::Description
# ui::Help::Colors::Key
# ui::Help::Colors::Section
# ui::Help::Colors::Title
# ui::Help::ContextSensitive
# ui::Help::DefaultPage
# ui::Help::F1Key
# ui::Help::SearchHint
# ui::Help::Style
# ui::Icons
# ui::Icons::Abacus
# ui::Icons::Accordion
# ui::Icons::Admin
# ui::Icons::AirplaneArrive
# ui::Icons::AirplaneDepart
# ui::Icons::Alembic
# ui::Icons::Alien
# ui::Icons::Allocated
# ui::Icons::Ambulance
# ui::Icons::API
# ui::Icons::ArrowCurveLeft
# ui::Icons::ArrowCurveRight
# ui::Icons::ArrowDiagonalDR
# ui::Icons::ArrowDiagonalUR
# ui::Icons::ArrowDoubleDown
# ui::Icons::ArrowDoubleLeft
# ui::Icons::ArrowDoubleRight
# ui::Icons::ArrowDoubleUp
# ui::Icons::ArrowDown
# ui::Icons::ArrowJump
# ui::Icons::ArrowLeft
# ui::Icons::ArrowRedirect
# ui::Icons::ArrowRight
# ui::Icons::ArrowSync
# ui::Icons::ArrowTarget
# ui::Icons::ArrowUp
# ui::Icons::Automobile
# ui::Icons::Axe
# ui::Icons::BabySymbol
# ui::Icons::Back
# ui::Icons::Backpack
# ui::Icons::BadgeBeta
# ui::Icons::BadgeCold
# ui::Icons::BadgeHot
# ui::Icons::BadgeLock
# ui::Icons::BadgeNew
# ui::Icons::BadgeStable
# ui::Icons::BadgeUnlock
# ui::Icons::BadgeUpdated
# ui::Icons::BadSector
# ui::Icons::BaggageClaim
# ui::Icons::BalanceScale
# ui::Icons::BalletShoes
# ui::Icons::BallotBox
# ui::Icons::Bandage
# ui::Icons::Banjo
# ui::Icons::BarChart
# ui::Icons::Basket
# ui::Icons::Bathtub
# ui::Icons::Battery
# ui::Icons::BatteryFull
# ui::Icons::BatteryHalf
# ui::Icons::BatteryLow
# ui::Icons::Bed
# ui::Icons::Bell
# ui::Icons::BellSlash
# ui::Icons::Bicycle
# ui::Icons::Bikini
# ui::Icons::BilledCap
# ui::Icons::BinaryView
# ui::Icons::BlackNib
# ui::Icons::Block
# ui::Icons::BloodDrop
# ui::Icons::BlueBook
# ui::Icons::Bomb
# ui::Icons::Bookmark
# ui::Icons::BookmarkTabs
# ui::Icons::Books
# ui::Icons::Boomerang
# ui::Icons::BootSector
# ui::Icons::BowArrow
# ui::Icons::BoxBL
# ui::Icons::BoxBR
# ui::Icons::BoxCross
# ui::Icons::BoxH
# ui::Icons::BoxTL
# ui::Icons::BoxTR
# ui::Icons::BoxV
# ui::Icons::BracketAngle
# ui::Icons::BracketCurly
# ui::Icons::BracketParen
# ui::Icons::BracketSquare
# ui::Icons::Breadcrumb
# ui::Icons::Briefcase
# ui::Icons::Briefs
# ui::Icons::BrokenChain
# ui::Icons::Broom
# ui::Icons::BruteForce
# ui::Icons::BTree
# ui::Icons::Bubbles
# ui::Icons::Bucket
# ui::Icons::Bug
# ui::Icons::Build
# ui::Icons::Bullet
# ui::Icons::BulletTrain
# ui::Icons::Bus
# ui::Icons::BusStop
# ui::Icons::BytePatch
# ui::Icons::Calendar
# ui::Icons::Camera
# ui::Icons::CameraFlash
# ui::Icons::CameraOff
# ui::Icons::CameraOn
# ui::Icons::Candle
# ui::Icons::CardBox
# ui::Icons::CardDividers
# ui::Icons::CardIndex
# ui::Icons::CaretDown
# ui::Icons::CaretLeft
# ui::Icons::CaretRight
# ui::Icons::CaretSmallDown
# ui::Icons::CaretSmallLeft
# ui::Icons::CaretSmallRight
# ui::Icons::CaretSmallUp
# ui::Icons::CaretUp
# ui::Icons::Carve
# ui::Icons::Certificate
# ui::Icons::ChainOfCustody
# ui::Icons::Chains
# ui::Icons::Chair
# ui::Icons::Charging
# ui::Icons::ChartDown
# ui::Icons::ChartUp
# ui::Icons::ChartYen
# ui::Icons::Chat
# ui::Icons::CheckboxHalf
# ui::Icons::Checkmark
# ui::Icons::ChildrenCrossing
# ui::Icons::Chip
# ui::Icons::Cigarette
# ui::Icons::CircledInfo
# ui::Icons::Clamp
# ui::Icons::ClapperBoard
# ui::Icons::Clipboard
# ui::Icons::Clock
# ui::Icons::Clone
# ui::Icons::Close
# ui::Icons::ClosedBook
# ui::Icons::Cloud
# ui::Icons::Cluster
# ui::Icons::ClutchBag
# ui::Icons::Coat
# ui::Icons::CodeCommit
# ui::Icons::Coffin
# ui::Icons::Coin
# ui::Icons::Color16
# ui::Icons::Color256
# ui::Icons::ColorPicker
# ui::Icons::Combobox
# ui::Icons::Comment
# ui::Icons::Compass
# ui::Icons::CompassE
# ui::Icons::CompassN
# ui::Icons::CompassS
# ui::Icons::CompassW
# ui::Icons::ComputerDisk
# ui::Icons::ComputerMouse
# ui::Icons::Config
# ui::Icons::Construction
# ui::Icons::Container
# ui::Icons::ControlKnobs
# ui::Icons::Copy
# ui::Icons::Corrupted
# ui::Icons::CouchLamp
# ui::Icons::CPU
# ui::Icons::Crayon
# ui::Icons::CreditCard
# ui::Icons::Critical
# ui::Icons::CrossedSwords
# ui::Icons::Crossmark
# ui::Icons::Crown
# ui::Icons::Crutch
# ui::Icons::Customs
# ui::Icons::Cut
# ui::Icons::Dagger
# ui::Icons::Database
# ui::Icons::DatabaseSync
# ui::Icons::Decrypted
# ui::Icons::Delete
# ui::Icons::Deleted
# ui::Icons::DeliveryTruck
# ui::Icons::Deploy
# ui::Icons::Desktop
# ui::Icons::Disk
# ui::Icons::DiskHDD
# ui::Icons::DiskNetwork
# ui::Icons::DiskSSD
# ui::Icons::DiskUSB
# ui::Icons::DiyaLamp
# ui::Icons::Dna
# ui::Icons::DollarNote
# ui::Icons::Door
# ui::Icons::DotBlue
# ui::Icons::DotCyan
# ui::Icons::DotGray
# ui::Icons::DotGreen
# ui::Icons::DotHollow
# ui::Icons::DotMagenta
# ui::Icons::DotOrange
# ui::Icons::DotRed
# ui::Icons::DotWhite
# ui::Icons::DotYellow
# ui::Icons::Download
# ui::Icons::Dress
# ui::Icons::Drop
# ui::Icons::Dropdown
# ui::Icons::Drum
# ui::Icons::Dvd
# ui::Icons::Edit
# ui::Icons::Eject
# ui::Icons::Elevator
# ui::Icons::Email
# ui::Icons::Encrypted
# ui::Icons::End
# ui::Icons::Entropy
# ui::Icons::Envelope
# ui::Icons::EnvelopeArrow
# ui::Icons::EuroNote
# ui::Icons::Evidence
# ui::Icons::Execute
# ui::Icons::Export
# ui::Icons::Extent
# ui::Icons::EyeClosed
# ui::Icons::EyeOpen
# ui::Icons::Factory
# ui::Icons::Failure
# ui::Icons::FallbackIcon
# ui::Icons::FallbackText
# ui::Icons::Fatal
# ui::Icons::FATTable
# ui::Icons::Fax
# ui::Icons::FaxMachine
# ui::Icons::File
# ui::Icons::FileArchive
# ui::Icons::FileCabinet
# ui::Icons::FileCode
# ui::Icons::FileConfig
# ui::Icons::FileExec
# ui::Icons::FileFolder
# ui::Icons::FileLog
# ui::Icons::FileMedia
# ui::Icons::FileTemp
# ui::Icons::FilmFrames
# ui::Icons::FilmProjector
# ui::Icons::Filter
# ui::Icons::FingerprintID
# ui::Icons::Fire
# ui::Icons::FireEngine
# ui::Icons::FireExtinguisher
# ui::Icons::Flag
# ui::Icons::Flashlight
# ui::Icons::FlatShoe
# ui::Icons::FloppyDisk
# ui::Icons::Flute
# ui::Icons::FlyingSaucer
# ui::Icons::FocusIn
# ui::Icons::FocusOut
# ui::Icons::Folder
# ui::Icons::FolderOpen
# ui::Icons::FolderSecure
# ui::Icons::FolderSync
# ui::Icons::FoldingFan
# ui::Icons::FountainPen
# ui::Icons::Fragmented
# ui::Icons::FuneralUrn
# ui::Icons::Funnel
# ui::Icons::Gear
# ui::Icons::GemStone
# ui::Icons::GitBranch
# ui::Icons::GitMerge
# ui::Icons::GitPull
# ui::Icons::GitPush
# ui::Icons::Glasses
# ui::Icons::Gloves
# ui::Icons::Goggles
# ui::Icons::GPTHeader
# ui::Icons::GPU
# ui::Icons::GraduationCap
# ui::Icons::GreenBook
# ui::Icons::GroupBy
# ui::Icons::Guest
# ui::Icons::Guitar
# ui::Icons::HairPick
# ui::Icons::Hammer
# ui::Icons::HammerPick
# ui::Icons::HammerWrench
# ui::Icons::Hamsa
# ui::Icons::Handbag
# ui::Icons::Harp
# ui::Icons::HashCalc
# ui::Icons::HeadCrash
# ui::Icons::Headphone
# ui::Icons::Headstone
# ui::Icons::HeartEmpty
# ui::Icons::HeartFull
# ui::Icons::Helicopter
# ui::Icons::Help
# ui::Icons::HexView
# ui::Icons::HighHeel
# ui::Icons::HighSpeedTrain
# ui::Icons::HikingBoot
# ui::Icons::Home
# ui::Icons::Hook
# ui::Icons::Hourglass
# ui::Icons::IDCard
# ui::Icons::IDCardIcon
# ui::Icons::Idle
# ui::Icons::ImageDisk
# ui::Icons::Import
# ui::Icons::InboxTray
# ui::Icons::IncomingEnvelope
# ui::Icons::Info
# ui::Icons::Inode
# ui::Icons::InputDate
# ui::Icons::InputEmail
# ui::Icons::InputNumber
# ui::Icons::InputPassword
# ui::Icons::InputText
# ui::Icons::Install
# ui::Icons::Intact
# ui::Icons::Jeans
# ui::Icons::Journal
# ui::Icons::Jump
# ui::Icons::Key
# ui::Icons::Keyboard
# ui::Icons::KeyboardDev
# ui::Icons::KeyPair
# ui::Icons::Kimono
# ui::Icons::LabCoat
# ui::Icons::Label
# ui::Icons::Ladder
# ui::Icons::Lantern
# ui::Icons::Laptop
# ui::Icons::Ledger
# ui::Icons::LeftLuggage
# ui::Icons::LevelSlider
# ui::Icons::LightBulb
# ui::Icons::Lightning
# ui::Icons::Link
# ui::Icons::LinkedClips
# ui::Icons::Lipstick
# ui::Icons::Listbox
# ui::Icons::Load
# ui::Icons::Loading
# ui::Icons::Lock
# ui::Icons::LockedKey
# ui::Icons::LockedPen
# ui::Icons::Locomotive
# ui::Icons::LongDrum
# ui::Icons::LotionBottle
# ui::Icons::Loudspeaker
# ui::Icons::LowBattery
# ui::Icons::Magnet
# ui::Icons::MagnifyLeft
# ui::Icons::MagnifyRight
# ui::Icons::MailArchive
# ui::Icons::MailboxDown
# ui::Icons::MailboxOpenDown
# ui::Icons::MailboxOpenUp
# ui::Icons::MailboxUp
# ui::Icons::MailDraft
# ui::Icons::MailReceive
# ui::Icons::MailSend
# ui::Icons::ManShoe
# ui::Icons::Maracas
# ui::Icons::Maximize
# ui::Icons::MBR
# ui::Icons::Medal
# ui::Icons::Megaphone
# ui::Icons::Memo
# ui::Icons::Memory
# ui::Icons::MensRoom
# ui::Icons::Mention
# ui::Icons::Menu
# ui::Icons::Metro
# ui::Icons::MFT
# ui::Icons::MicOff
# ui::Icons::MicOn
# ui::Icons::Microbe
# ui::Icons::Microphone
# ui::Icons::Microscope
# ui::Icons::MilitaryHelmet
# ui::Icons::Minimize
# ui::Icons::Mirror
# ui::Icons::Moai
# ui::Icons::MobileArrow
# ui::Icons::MobilePhone
# ui::Icons::MoneyBag
# ui::Icons::MoneyWings
# ui::Icons::Monster
# ui::Icons::Moon
# ui::Icons::Motorway
# ui::Icons::Mousetrap
# ui::Icons::MovieCamera
# ui::Icons::MusicalNote
# ui::Icons::MusicalNotes
# ui::Icons::MusicalScore
# ui::Icons::MutedSpeaker
# ui::Icons::NazarAmulet
# ui::Icons::Necktie
# ui::Icons::NestedArchive
# ui::Icons::Network
# ui::Icons::NetworkCloud
# ui::Icons::NetworkLocal
# ui::Icons::NetworkWired
# ui::Icons::NetworkWireless
# ui::Icons::New
# ui::Icons::Newspaper
# ui::Icons::Next
# ui::Icons::NextTab
# ui::Icons::NoLittering
# ui::Icons::NoPedestrians
# ui::Icons::Normalize
# ui::Icons::NoSmoking
# ui::Icons::Notebook
# ui::Icons::NotebookDeco
# ui::Icons::NutBolt
# ui::Icons::OilDrum
# ui::Icons::OldKey
# ui::Icons::Open
# ui::Icons::OpenBook
# ui::Icons::OpenFolder
# ui::Icons::OpticalDisk
# ui::Icons::OrangeBook
# ui::Icons::Orphaned
# ui::Icons::OutboxTray
# ui::Icons::Overwritten
# ui::Icons::Package
# ui::Icons::PageCurl
# ui::Icons::Pager
# ui::Icons::PageUp
# ui::Icons::Paintbrush
# ui::Icons::Palette
# ui::Icons::Paperclip
# ui::Icons::PaperRoll
# ui::Icons::Partial
# ui::Icons::PassportControl
# ui::Icons::Paste
# ui::Icons::Pause
# ui::Icons::Pen
# ui::Icons::Pencil
# ui::Icons::PendingSector
# ui::Icons::Persona
# ui::Icons::PetriDish
# ui::Icons::Pickaxe
# ui::Icons::PickupTruck
# ui::Icons::Pill
# ui::Icons::Placard
# ui::Icons::Placeholder
# ui::Icons::PlaceOfWorship
# ui::Icons::Play
# ui::Icons::Plug
# ui::Icons::Plunger
# ui::Icons::PoliceCar
# ui::Icons::PostalHorn
# ui::Icons::Postbox
# ui::Icons::PotableWater
# ui::Icons::PoundNote
# ui::Icons::Power
# ui::Icons::PrayerBeads
# ui::Icons::Preferences
# ui::Icons::Prev
# ui::Icons::PrevTab
# ui::Icons::Print
# ui::Icons::Printer
# ui::Icons::Processing
# ui::Icons::ProhibitedSign
# ui::Icons::PSAbout
# ui::Icons::PSAlias
# ui::Icons::PSClass
# ui::Icons::PSClear
# ui::Icons::PSDebug
# ui::Icons::PSEnum
# ui::Icons::PSError
# ui::Icons::PSExport
# ui::Icons::PSFunction
# ui::Icons::PSFunctionPrivate
# ui::Icons::PSFunctionPublic
# ui::Icons::PSGet
# ui::Icons::PSHelp
# ui::Icons::PSHistory
# ui::Icons::PSImport
# ui::Icons::PSInput
# ui::Icons::PSJob
# ui::Icons::PSJobRunning
# ui::Icons::PSJobStopped
# ui::Icons::PSModule
# ui::Icons::PSModuleCore
# ui::Icons::PSModuleScript
# ui::Icons::PSNew
# ui::Icons::PSOutput
# ui::Icons::PSPipeline
# ui::Icons::PSProfile
# ui::Icons::PSPrompt
# ui::Icons::PSRemove
# ui::Icons::PSRunspace
# ui::Icons::PSSet
# ui::Icons::PSVariable
# ui::Icons::PSVariableConst
# ui::Icons::PSVariableEnv
# ui::Icons::PSVerbose
# ui::Icons::PSWarning
# ui::Icons::Purse
# ui::Icons::Pushpin
# ui::Icons::Question
# ui::Icons::Radio
# ui::Icons::RadioOff
# ui::Icons::RadioOn
# ui::Icons::RailwayTrack
# ui::Icons::Rainbow
# ui::Icons::Random
# ui::Icons::Razor
# ui::Icons::Ready
# ui::Icons::Reallocated
# ui::Icons::Receipt
# ui::Icons::Reconstruct
# ui::Icons::Record
# ui::Icons::Recovered
# ui::Icons::Redo
# ui::Icons::Refresh
# ui::Icons::Repeat
# ui::Icons::RescueHelmet
# ui::Icons::Restore
# ui::Icons::Restroom
# ui::Icons::Return
# ui::Icons::Ring
# ui::Icons::RingBuoy
# ui::Icons::Robot
# ui::Icons::Rocket
# ui::Icons::RolledNewspaper
# ui::Icons::RoundPushpin
# ui::Icons::Router
# ui::Icons::RulerStraight
# ui::Icons::RulerTriangle
# ui::Icons::RunningShoe
# ui::Icons::SafetyPin
# ui::Icons::SafetyVest
# ui::Icons::Sari
# ui::Icons::Satellite
# ui::Icons::Save
# ui::Icons::SaveAs
# ui::Icons::Saw
# ui::Icons::Saxophone
# ui::Icons::Scan
# ui::Icons::Scarf
# ui::Icons::Scissors
# ui::Icons::Scooter
# ui::Icons::Screwdriver
# ui::Icons::Scroll
# ui::Icons::Scrub
# ui::Icons::Sealed
# ui::Icons::Search
# ui::Icons::Sector
# ui::Icons::Separator
# ui::Icons::SepArrow
# ui::Icons::SepChevron
# ui::Icons::SepDash
# ui::Icons::SepDot
# ui::Icons::SepDouble
# ui::Icons::SepWave
# ui::Icons::Server
# ui::Icons::ServerRack
# ui::Icons::Service
# ui::Icons::Settings
# ui::Icons::Share
# ui::Icons::Shield
# ui::Icons::Ship
# ui::Icons::ShoppingBags
# ui::Icons::ShoppingCart
# ui::Icons::Shorts
# ui::Icons::Shovel
# ui::Icons::Shower
# ui::Icons::Shuffle
# ui::Icons::Skateboard
# ui::Icons::SlackSpace
# ui::Icons::SliderEnd
# ui::Icons::SliderHandle
# ui::Icons::SliderMid
# ui::Icons::SliderStart
# ui::Icons::SMARTWarn
# ui::Icons::Snowflake
# ui::Icons::Soap
# ui::Icons::Socks
# ui::Icons::SortAsc
# ui::Icons::SortDesc
# ui::Icons::Source
# ui::Icons::Sparkle
# ui::Icons::SpeakerHigh
# ui::Icons::SpeakerLow
# ui::Icons::SpeakerMed
# ui::Icons::Speedboat
# ui::Icons::Spiral
# ui::Icons::SpiralCalendar
# ui::Icons::SpiralNotepad
# ui::Icons::Sponge
# ui::Icons::SquareBlue
# ui::Icons::SquareGreen
# ui::Icons::SquareRed
# ui::Icons::SquareYellow
# ui::Icons::SSDWear
# ui::Icons::StarEmpty
# ui::Icons::StarFull
# ui::Icons::StarHalf
# ui::Icons::Station
# ui::Icons::Stethoscope
# ui::Icons::Stop
# ui::Icons::StopSign
# ui::Icons::Stopwatch
# ui::Icons::StudioMic
# ui::Icons::Success
# ui::Icons::Sun
# ui::Icons::Sunglasses
# ui::Icons::Superblock
# ui::Icons::SUV
# ui::Icons::Swimsuit
# ui::Icons::Sync
# ui::Icons::Syringe
# ui::Icons::TabClose
# ui::Icons::TabNew
# ui::Icons::Tag
# ui::Icons::Tampered
# ui::Icons::Target
# ui::Icons::Taxi
# ui::Icons::TearCalendar
# ui::Icons::Telephone
# ui::Icons::TelephoneReceiver
# ui::Icons::Telescope
# ui::Icons::Television
# ui::Icons::Terminal
# ui::Icons::Test
# ui::Icons::TestTube
# ui::Icons::ThemeCorporate
# ui::Icons::ThemeCyber
# ui::Icons::ThemeDark
# ui::Icons::ThemeHacker
# ui::Icons::ThemeHighVis
# ui::Icons::ThemeLight
# ui::Icons::ThemeMenu
# ui::Icons::ThemeMinimal
# ui::Icons::ThemePowerShell
# ui::Icons::ThemeRetro
# ui::Icons::ThongSandal
# ui::Icons::Ticket
# ui::Icons::Timer
# ui::Icons::ToggleOff
# ui::Icons::ToggleOn
# ui::Icons::Toilet
# ui::Icons::Toolbox
# ui::Icons::Tools
# ui::Icons::Toothbrush
# ui::Icons::TopHat
# ui::Icons::Trackball
# ui::Icons::Tractor
# ui::Icons::TrafficLightH
# ui::Icons::TrafficLightV
# ui::Icons::Trash
# ui::Icons::Trophy
# ui::Icons::Trumpet
# ui::Icons::TShirt
# ui::Icons::Unallocated
# ui::Icons::Undo
# ui::Icons::Uninstall
# ui::Icons::Unknown
# ui::Icons::Unlink
# ui::Icons::Unlock
# ui::Icons::Unrecoverable
# ui::Icons::Update
# ui::Icons::Upgrade
# ui::Icons::Upload
# ui::Icons::User
# ui::Icons::Users
# ui::Icons::Verify
# ui::Icons::VideoCamera
# ui::Icons::Videocassette
# ui::Icons::Violin
# ui::Icons::VolumeMax
# ui::Icons::VolumeMed
# ui::Icons::VolumeMin
# ui::Icons::VolumeMute
# ui::Icons::Waiting
# ui::Icons::Warning
# ui::Icons::Wastebasket
# ui::Icons::Webhook
# ui::Icons::Wheel
# ui::Icons::WhiteCane
# ui::Icons::Window
# ui::Icons::WindowFull
# ui::Icons::WindowSplitH
# ui::Icons::WindowSplitV
# ui::Icons::WindowTile
# ui::Icons::WIP
# ui::Icons::Wipe
# ui::Icons::Wireless
# ui::Icons::WomansBoot
# ui::Icons::WomansClothes
# ui::Icons::WomansHat
# ui::Icons::WomansSandal
# ui::Icons::WomensRoom
# ui::Icons::Wrench
# ui::Icons::Write
# ui::Icons::WriteBlock
# ui::Icons::XRay
# ui::Icons::XRayScan
# ui::Icons::YenNote
# ui::Labels
# ui::Labels::IconLevels
# ui::Layout::FooterHeight
# ui::Layout::HeaderHeight
# ui::Layout::IconColumnWidth
# ui::Layout::MaxHeight
# ui::Layout::MaxWidth
# ui::Layout::MinHeight
# ui::Layout::MinWidth
# ui::Layout::Padding
# ui::Layout::SafeZoneWidth
# ui::Layout::TitlePadding
# ui::Modal
# ui::Modal::Animate
# ui::Modal::AnimationType
# ui::Modal::BackgroundOpacity
# ui::Modal::BorderStyle
# ui::Modal::CenterHorizontally
# ui::Modal::CenterVertically
# ui::Modal::CloseOnEsc
# ui::Modal::CloseOnOutside
# ui::Modal::ShadowBlur
# ui::Progress
# ui::Progress::BarOnly
# ui::Progress::BarOnly::EmptyChar
# ui::Progress::BarOnly::ErrorChar
# ui::Progress::BarOnly::FullChar
# ui::Progress::BarOnly::ShowETA
# ui::Progress::BarOnly::ShowLabel
# ui::Progress::BarOnly::ShowPercent
# ui::Progress::BarOnly::Width
# ui::Progress::Blocks
# ui::Progress::Blocks::Frames
# ui::Progress::Blocks::IntervalMs
# ui::Progress::Braille
# ui::Progress::Braille::Frames
# ui::Progress::Braille::IntervalMs
# ui::Progress::Compact
# ui::Progress::Compact::EmptyChar
# ui::Progress::Compact::ErrorChar
# ui::Progress::Compact::FullChar
# ui::Progress::Compact::ShowETA
# ui::Progress::Compact::ShowLabel
# ui::Progress::Compact::ShowPercent
# ui::Progress::Compact::Width
# ui::Progress::Default::EmptyChar
# ui::Progress::Default::ErrorChar
# ui::Progress::Default::FullChar
# ui::Progress::Default::ShowETA
# ui::Progress::Default::ShowLabel
# ui::Progress::Default::ShowPercent
# ui::Progress::Default::Width
# ui::Progress::Discrete
# ui::Progress::Discrete::EmptyChar
# ui::Progress::Discrete::ErrorChar
# ui::Progress::Discrete::FullChar
# ui::Progress::Discrete::ShowETA
# ui::Progress::Discrete::ShowLabel
# ui::Progress::Discrete::ShowPercent
# ui::Progress::Discrete::Width
# ui::Progress::Dot
# ui::Progress::Dot::Frames
# ui::Progress::Dot::IntervalMs
# ui::Progress::Line
# ui::Progress::Line::Frames
# ui::Progress::Line::IntervalMs
# ui::Redaction
# ui::Redaction::Enabled
# ui::Redaction::MaskChar
# ui::Redaction::Patterns
# ui::Resize
# ui::Resize::AutoFit
# ui::Resize::Enabled
# ui::Resize::MaxHeight
# ui::Resize::MaxWidth
# ui::Resize::MinHeight
# ui::Resize::MinWidth
# ui::Resize::NotifyEvent
# ui::Resize::PreserveAspect
# ui::ScrollBar
# ui::ScrollBar::ArrowDown
# ui::ScrollBar::ArrowUp
# ui::ScrollBar::HideWhenFull
# ui::ScrollBar::Position
# ui::ScrollBar::ShowArrows
# ui::ScrollBar::Style
# ui::ScrollBar::ThumbChar
# ui::ScrollBar::TrackChar
# ui::ScrollBar::Width
# ui::Segment
# ui::Segment::Dependencies
# ui::Segment::Description
# ui::Segment::HashSHA256
# ui::Segment::Name
# ui::Segment::Version
# ui::SemanticMap::ABOUT
# ui::SemanticMap::ACTIONS
# ui::SemanticMap::ACTIVE
# ui::SemanticMap::ADMIN
# ui::SemanticMap::ADVANCED
# ui::SemanticMap::ALERT
# ui::SemanticMap::ALIAS
# ui::SemanticMap::ALLOCATED
# ui::SemanticMap::AMBULANCE
# ui::SemanticMap::API
# ui::SemanticMap::APPROXIMATE
# ui::SemanticMap::ARCHAEOLOGY
# ui::SemanticMap::ARCHIVE
# ui::SemanticMap::ARRIVAL
# ui::SemanticMap::AUDIO
# ui::SemanticMap::AUDIT
# ui::SemanticMap::AUTH
# ui::SemanticMap::AUTHENTICATE
# ui::SemanticMap::AUTO
# ui::SemanticMap::AUTOMATE
# ui::SemanticMap::AUTORUNS
# ui::SemanticMap::AUTOSPSY
# ui::SemanticMap::AVAILABLE
# ui::SemanticMap::AXE
# ui::SemanticMap::BACKPACK
# ui::SemanticMap::BACKUP
# ui::SemanticMap::BAD_SECTOR
# ui::SemanticMap::BAGGAGE
# ui::SemanticMap::BALLET
# ui::SemanticMap::BANDAGE
# ui::SemanticMap::BANNED
# ui::SemanticMap::BASIC
# ui::SemanticMap::BATCH
# ui::SemanticMap::BATCH_PROCESSING
# ui::SemanticMap::BATHTUB
# ui::SemanticMap::BATTERY
# ui::SemanticMap::BED
# ui::SemanticMap::BELL
# ui::SemanticMap::BICYCLE
# ui::SemanticMap::BINARY_VIEW
# ui::SemanticMap::BITWISE_TAGGING
# ui::SemanticMap::BOAT
# ui::SemanticMap::BOOK
# ui::SemanticMap::BOOKMARK
# ui::SemanticMap::BOOT_SECTOR
# ui::SemanticMap::BRACKET_ANGLE
# ui::SemanticMap::BRACKET_CURLY
# ui::SemanticMap::BRACKET_SQUARE
# ui::SemanticMap::BRANCH
# ui::SemanticMap::BROOM
# ui::SemanticMap::BROWSE
# ui::SemanticMap::BRUTE_FORCE
# ui::SemanticMap::BTREE
# ui::SemanticMap::BUCKET
# ui::SemanticMap::BUG
# ui::SemanticMap::BUILD
# ui::SemanticMap::BUILD_EXE_PORTABLE
# ui::SemanticMap::BUILD_EXE_SETUP
# ui::SemanticMap::BUILD_MONOLITH
# ui::SemanticMap::BUILD_MSI
# ui::SemanticMap::BULK
# ui::SemanticMap::BUS
# ui::SemanticMap::BUSY
# ui::SemanticMap::BYTEPATCH
# ui::SemanticMap::CALENDAR
# ui::SemanticMap::CALL
# ui::SemanticMap::CAMERA
# ui::SemanticMap::CAMERA_PHOTO
# ui::SemanticMap::CANCEL
# ui::SemanticMap::CAP_ALTERNATESCREEN
# ui::SemanticMap::CAP_BRACKETEDPASTE
# ui::SemanticMap::CAP_CSIUKEYBOARD
# ui::SemanticMap::CAP_FALLBACK16
# ui::SemanticMap::CAP_FALLBACK256
# ui::SemanticMap::CAP_FOCUSEVENTS
# ui::SemanticMap::CAP_HYPERLINKS
# ui::SemanticMap::CAP_KITTYKEYBOARD
# ui::SemanticMap::CAP_MOUSETRACKING
# ui::SemanticMap::CAP_SIXELGRAPHICS
# ui::SemanticMap::CAP_TRUECOLOR
# ui::SemanticMap::CAPABILITIES
# ui::SemanticMap::CAPTURE
# ui::SemanticMap::CAR
# ui::SemanticMap::CARVE
# ui::SemanticMap::CASCADE
# ui::SemanticMap::CERTIFICATE
# ui::SemanticMap::CHAIN
# ui::SemanticMap::CHAIN_OF_CUSTODY
# ui::SemanticMap::CHAIR
# ui::SemanticMap::CHANGELOG
# ui::SemanticMap::CHART
# ui::SemanticMap::CHKDSK
# ui::SemanticMap::CLAPPER
# ui::SemanticMap::CLASS
# ui::SemanticMap::CLEAR
# ui::SemanticMap::CLIPBOARD
# ui::SemanticMap::CLONE
# ui::SemanticMap::CLOSE
# ui::SemanticMap::CLOUD_SYNC
# ui::SemanticMap::CLUSTER
# ui::SemanticMap::CMDLET
# ui::SemanticMap::COAT
# ui::SemanticMap::COFFIN
# ui::SemanticMap::COIN
# ui::SemanticMap::COLOR_PICKER
# ui::SemanticMap::COLUMNS
# ui::SemanticMap::COMMIT
# ui::SemanticMap::COMPILE
# ui::SemanticMap::COMPLETE
# ui::SemanticMap::COMPRESS
# ui::SemanticMap::CONNECT
# ui::SemanticMap::COPY
# ui::SemanticMap::CORPORATE
# ui::SemanticMap::CORRUPTED
# ui::SemanticMap::CREATE
# ui::SemanticMap::CREDIT_CARD
# ui::SemanticMap::CRON
# ui::SemanticMap::CUSTOMS
# ui::SemanticMap::CUT
# ui::SemanticMap::CYBER
# ui::SemanticMap::DARK_MODE
# ui::SemanticMap::DASHBOARD
# ui::SemanticMap::DATA_DUMP
# ui::SemanticMap::DATABASE
# ui::SemanticMap::DB
# ui::SemanticMap::DEBUG
# ui::SemanticMap::DECOMPRESS
# ui::SemanticMap::DECRYPT
# ui::SemanticMap::DECRYPTED
# ui::SemanticMap::DEEP_SCAN
# ui::SemanticMap::DEFAULT
# ui::SemanticMap::DEFAULT_OUT
# ui::SemanticMap::DELETE
# ui::SemanticMap::DELETE_DB
# ui::SemanticMap::DELETED
# ui::SemanticMap::DEPARTURE
# ui::SemanticMap::DEPLOY
# ui::SemanticMap::DESELECT
# ui::SemanticMap::DETAILS
# ui::SemanticMap::DHCP
# ui::SemanticMap::DIALOG
# ui::SemanticMap::DIFF
# ui::SemanticMap::DIR
# ui::SemanticMap::DIRECTORY
# ui::SemanticMap::DISABLED
# ui::SemanticMap::DISCONNECT
# ui::SemanticMap::DISK_MGR
# ui::SemanticMap::DISKPART
# ui::SemanticMap::DISM
# ui::SemanticMap::DISMOUNT
# ui::SemanticMap::DNA
# ui::SemanticMap::DNS
# ui::SemanticMap::DOCS
# ui::SemanticMap::DOCUMENT
# ui::SemanticMap::DONE
# ui::SemanticMap::DOOR
# ui::SemanticMap::DOWN
# ui::SemanticMap::DRAFT
# ui::SemanticMap::DRESS
# ui::SemanticMap::DRIVE
# ui::SemanticMap::DRUM
# ui::SemanticMap::DUPLICATE
# ui::SemanticMap::EDIT
# ui::SemanticMap::EJECT_MEDIA
# ui::SemanticMap::ELEVATOR
# ui::SemanticMap::EMAIL
# ui::SemanticMap::ENABLED
# ui::SemanticMap::ENCRYPT
# ui::SemanticMap::ENCRYPTED
# ui::SemanticMap::ENGINE_MODE
# ui::SemanticMap::ENTROPY
# ui::SemanticMap::ENVELOPE
# ui::SemanticMap::ERASE
# ui::SemanticMap::ERROR
# ui::SemanticMap::ERROR_PS
# ui::SemanticMap::ETHERNET
# ui::SemanticMap::EVENT
# ui::SemanticMap::EVENT_LOG
# ui::SemanticMap::EVENTVWR
# ui::SemanticMap::EVERYTHING
# ui::SemanticMap::EVIDENCE
# ui::SemanticMap::EXECUTE
# ui::SemanticMap::EXIT
# ui::SemanticMap::EXPERT
# ui::SemanticMap::EXPORT
# ui::SemanticMap::EXPORT_REPORT
# ui::SemanticMap::EXTENT
# ui::SemanticMap::EXTRACT
# ui::SemanticMap::FAILED
# ui::SemanticMap::FAN
# ui::SemanticMap::FAST
# ui::SemanticMap::FAT_TABLE
# ui::SemanticMap::FAVORITE
# ui::SemanticMap::FEATURE
# ui::SemanticMap::FEEDBACK
# ui::SemanticMap::FILE
# ui::SemanticMap::FILE_LABORATORY
# ui::SemanticMap::FILEHASH
# ui::SemanticMap::FIND
# ui::SemanticMap::FINE_TUNE
# ui::SemanticMap::FINGERPRINT
# ui::SemanticMap::FIRE_ENGINE
# ui::SemanticMap::FIREWALL
# ui::SemanticMap::FIRST
# ui::SemanticMap::FIX
# ui::SemanticMap::FLASHLIGHT
# ui::SemanticMap::FLUTE
# ui::SemanticMap::FLYING_SAUCER
# ui::SemanticMap::FOLDER
# ui::SemanticMap::FORCE_DELETE
# ui::SemanticMap::FORENSICS
# ui::SemanticMap::FORGE_ORCHESTRATOR
# ui::SemanticMap::FORMAT
# ui::SemanticMap::FRAGMENTED
# ui::SemanticMap::FRAME_STYLE
# ui::SemanticMap::FSUTIL
# ui::SemanticMap::FTKIMAGER
# ui::SemanticMap::FTP
# ui::SemanticMap::FULLSCREEN
# ui::SemanticMap::FUNCTION
# ui::SemanticMap::GEAR
# ui::SemanticMap::GEM
# ui::SemanticMap::GENERIC
# ui::SemanticMap::GLASSES
# ui::SemanticMap::GLOVES
# ui::SemanticMap::GOGGLES
# ui::SemanticMap::GOTO
# ui::SemanticMap::GPT_HEADER
# ui::SemanticMap::GRADUATION
# ui::SemanticMap::GUEST
# ui::SemanticMap::GUITAR
# ui::SemanticMap::HACKER
# ui::SemanticMap::HAMMER
# ui::SemanticMap::HANDBAG
# ui::SemanticMap::HARVESTER
# ui::SemanticMap::HASH
# ui::SemanticMap::HASH_CALC
# ui::SemanticMap::HAT
# ui::SemanticMap::HDD
# ui::SemanticMap::HEAD_CRASH
# ui::SemanticMap::HEADPHONES
# ui::SemanticMap::HELICOPTER
# ui::SemanticMap::HELMET
# ui::SemanticMap::HELP
# ui::SemanticMap::HEX_VIEW
# ui::SemanticMap::HIGH_CONTRAST
# ui::SemanticMap::HIGH_HEEL
# ui::SemanticMap::HIGHLIGHT
# ui::SemanticMap::HIGHWAY
# ui::SemanticMap::HIKING
# ui::SemanticMap::HOME
# ui::SemanticMap::HOTFIX
# ui::SemanticMap::HTTP
# ui::SemanticMap::HYDRATION_MODE
# ui::SemanticMap::ICON_LEVEL
# ui::SemanticMap::ID_CARD
# ui::SemanticMap::IDLE
# ui::SemanticMap::IMAGE
# ui::SemanticMap::IMAGE_DISK
# ui::SemanticMap::IMPORT
# ui::SemanticMap::IN_PROGRESS
# ui::SemanticMap::INACTIVE
# ui::SemanticMap::INDEX
# ui::SemanticMap::INIT_SYSTEM
# ui::SemanticMap::INODE
# ui::SemanticMap::INSERT
# ui::SemanticMap::INTACT
# ui::SemanticMap::INTERNET
# ui::SemanticMap::INVOKE
# ui::SemanticMap::ISSUE
# ui::SemanticMap::JEANS
# ui::SemanticMap::JOB
# ui::SemanticMap::JOURNAL
# ui::SemanticMap::JUMP
# ui::SemanticMap::KAPE
# ui::SemanticMap::KEY_TOOL
# ui::SemanticMap::LAB_COAT
# ui::SemanticMap::LABORATORY
# ui::SemanticMap::LANGUAGE
# ui::SemanticMap::LAPTOP
# ui::SemanticMap::LAST
# ui::SemanticMap::LAYOUT
# ui::SemanticMap::LAYOUT_HEX_TEXT
# ui::SemanticMap::LAYOUT_TIMELINE
# ui::SemanticMap::LAYOUT_TREE_HEX
# ui::SemanticMap::LEFT
# ui::SemanticMap::LIGHT
# ui::SemanticMap::LIGHT_MODE
# ui::SemanticMap::LIPSTICK
# ui::SemanticMap::LOAD
# ui::SemanticMap::LOADING
# ui::SemanticMap::LOCALE
# ui::SemanticMap::LOG
# ui::SemanticMap::LOG2TIMELINE
# ui::SemanticMap::LOGIN
# ui::SemanticMap::LOGISTICS
# ui::SemanticMap::LOGOUT
# ui::SemanticMap::MAGNET
# ui::SemanticMap::MASS
# ui::SemanticMap::MAXIMIZE
# ui::SemanticMap::MBR
# ui::SemanticMap::MEGAPHONE
# ui::SemanticMap::MEMO
# ui::SemanticMap::MEMORY_MGR
# ui::SemanticMap::MEMORYZE
# ui::SemanticMap::MERGE
# ui::SemanticMap::METADATA_EXIF
# ui::SemanticMap::MFT
# ui::SemanticMap::MIC
# ui::SemanticMap::MICROSCOPE
# ui::SemanticMap::MIGRATE
# ui::SemanticMap::MINIMAL
# ui::SemanticMap::MINIMIZE
# ui::SemanticMap::MISC
# ui::SemanticMap::MOBILE
# ui::SemanticMap::MODAL
# ui::SemanticMap::MODIFY
# ui::SemanticMap::MODULE
# ui::SemanticMap::MONEY
# ui::SemanticMap::MORE
# ui::SemanticMap::MOUNT
# ui::SemanticMap::MOVIE
# ui::SemanticMap::MUSIC
# ui::SemanticMap::MUTE
# ui::SemanticMap::NAS
# ui::SemanticMap::NATIVE
# ui::SemanticMap::NAVIGATE
# ui::SemanticMap::NECKTIE
# ui::SemanticMap::NESTED_ARCHIVE
# ui::SemanticMap::NET_MGR
# ui::SemanticMap::NET_SCAN
# ui::SemanticMap::NET_UNMOUNT_ALL
# ui::SemanticMap::NETWORK
# ui::SemanticMap::NETWORK_DRIVE
# ui::SemanticMap::NEW
# ui::SemanticMap::NEWSPAPER
# ui::SemanticMap::NEXT
# ui::SemanticMap::NEXT_TAB
# ui::SemanticMap::NMAP
# ui::SemanticMap::NO_SMOKING
# ui::SemanticMap::NORMALIZE
# ui::SemanticMap::NOTIFICATION
# ui::SemanticMap::OFFLINE
# ui::SemanticMap::OIL
# ui::SemanticMap::OK
# ui::SemanticMap::ONLINE
# ui::SemanticMap::OPEN
# ui::SemanticMap::OPTIONS
# ui::SemanticMap::ORPHANED
# ui::SemanticMap::OTHER
# ui::SemanticMap::OVERVIEW
# ui::SemanticMap::OVERWRITTEN
# ui::SemanticMap::PACKAGE
# ui::SemanticMap::PANEL
# ui::SemanticMap::PAPERCLIP
# ui::SemanticMap::PARSING
# ui::SemanticMap::PARTIAL
# ui::SemanticMap::PARTITION
# ui::SemanticMap::PASSWORD
# ui::SemanticMap::PASTE
# ui::SemanticMap::PATCH
# ui::SemanticMap::PAUSE
# ui::SemanticMap::PAUSED_STATE
# ui::SemanticMap::PDF
# ui::SemanticMap::PEN
# ui::SemanticMap::PENCIL
# ui::SemanticMap::PENDING
# ui::SemanticMap::PENDING_SECTOR
# ui::SemanticMap::PERMISSION
# ui::SemanticMap::PHONE
# ui::SemanticMap::PHOTOREC
# ui::SemanticMap::PICKUP
# ui::SemanticMap::PILL
# ui::SemanticMap::PIN
# ui::SemanticMap::PING
# ui::SemanticMap::PIPELINE
# ui::SemanticMap::PIPELINE_OP
# ui::SemanticMap::PLASO
# ui::SemanticMap::PLAY
# ui::SemanticMap::PLUG
# ui::SemanticMap::POLICE
# ui::SemanticMap::POWER_SHELL
# ui::SemanticMap::POWERSHELL
# ui::SemanticMap::PRECISE
# ui::SemanticMap::PREV
# ui::SemanticMap::PREV_TAB
# ui::SemanticMap::PREVIOUS
# ui::SemanticMap::PRINTER
# ui::SemanticMap::PROCESSES
# ui::SemanticMap::PROCEXP
# ui::SemanticMap::PROFILE
# ui::SemanticMap::PROGRESS_STYLE
# ui::SemanticMap::PROHIBITED
# ui::SemanticMap::PROXY
# ui::SemanticMap::PS
# ui::SemanticMap::PUBLISH
# ui::SemanticMap::PULL
# ui::SemanticMap::PUSH
# ui::SemanticMap::QUERY
# ui::SemanticMap::QUEUED
# ui::SemanticMap::QUICK
# ui::SemanticMap::RADIO
# ui::SemanticMap::RAILWAY
# ui::SemanticMap::RANDOM_THEME
# ui::SemanticMap::RC_BTN_CANCEL
# ui::SemanticMap::RC_BTN_SAVE
# ui::SemanticMap::RC_FLAG_B
# ui::SemanticMap::RC_FLAG_COPYALL
# ui::SemanticMap::RC_FLAG_DCOPY_T
# ui::SemanticMap::RC_FLAG_E
# ui::SemanticMap::RC_FLAG_FFT
# ui::SemanticMap::RC_FLAG_L
# ui::SemanticMap::RC_FLAG_M
# ui::SemanticMap::RC_FLAG_MT
# ui::SemanticMap::RC_FLAG_NP
# ui::SemanticMap::RC_FLAG_V
# ui::SemanticMap::RC_FLAG_XJ
# ui::SemanticMap::RC_FLAG_XN
# ui::SemanticMap::RC_FLAG_XO
# ui::SemanticMap::RC_FLAG_ZB
# ui::SemanticMap::RC_RETRY_R
# ui::SemanticMap::RC_RETRY_W
# ui::SemanticMap::REACT
# ui::SemanticMap::READY
# ui::SemanticMap::REALLOCATED
# ui::SemanticMap::REBASE
# ui::SemanticMap::RECONSTRUCT
# ui::SemanticMap::RECORD
# ui::SemanticMap::RECOVERED
# ui::SemanticMap::RECOVERY
# ui::SemanticMap::REDLINE
# ui::SemanticMap::REDO
# ui::SemanticMap::REFRESH
# ui::SemanticMap::REGCFG
# ui::SemanticMap::REGISTER
# ui::SemanticMap::REGISTRY
# ui::SemanticMap::RELEASE
# ui::SemanticMap::RELOAD
# ui::SemanticMap::REMOVE
# ui::SemanticMap::RENAME
# ui::SemanticMap::REPLACE
# ui::SemanticMap::RESET
# ui::SemanticMap::RESTORE
# ui::SemanticMap::RESTROOM
# ui::SemanticMap::RETRO
# ui::SemanticMap::RETURN
# ui::SemanticMap::REVERT
# ui::SemanticMap::RIGHT
# ui::SemanticMap::RING
# ui::SemanticMap::ROBO_CFG
# ui::SemanticMap::ROBOCOPY
# ui::SemanticMap::ROCKET
# ui::SemanticMap::ROLE
# ui::SemanticMap::ROLLBACK
# ui::SemanticMap::RUN
# ui::SemanticMap::RUNNING
# ui::SemanticMap::RUNNING_SHOE
# ui::SemanticMap::RUNSPACE
# ui::SemanticMap::SAFETY
# ui::SemanticMap::SAVE
# ui::SemanticMap::SAVE_AS
# ui::SemanticMap::SAW
# ui::SemanticMap::SAXOPHONE
# ui::SemanticMap::SCAFFOLD
# ui::SemanticMap::SCALE
# ui::SemanticMap::SCAN
# ui::SemanticMap::SCARF
# ui::SemanticMap::SCHEDULE
# ui::SemanticMap::SCHEMA
# ui::SemanticMap::SCISSORS
# ui::SemanticMap::SCOOTER
# ui::SemanticMap::SCREENSHOT
# ui::SemanticMap::SCREWDRIVER
# ui::SemanticMap::SCRIPT
# ui::SemanticMap::SCRUB
# ui::SemanticMap::SEALED
# ui::SemanticMap::SECTOR
# ui::SemanticMap::SEED
# ui::SemanticMap::SELECT
# ui::SemanticMap::SELECT_ALL
# ui::SemanticMap::SERVICES
# ui::SemanticMap::SETTINGS
# ui::SemanticMap::SFC
# ui::SemanticMap::SHIP
# ui::SemanticMap::SHOE
# ui::SemanticMap::SHOPPING
# ui::SemanticMap::SHORTS
# ui::SemanticMap::SHOWER
# ui::SemanticMap::SIDEBAR
# ui::SemanticMap::SIGN
# ui::SemanticMap::SIGN_IN
# ui::SemanticMap::SIGN_OUT
# ui::SemanticMap::SIMPLE
# ui::SemanticMap::SKATEBOARD
# ui::SemanticMap::SLACK
# ui::SemanticMap::SLEUTHKIT
# ui::SemanticMap::SLICE_FILE
# ui::SemanticMap::SLOW
# ui::SemanticMap::SMART_WARN
# ui::SemanticMap::SOCKS
# ui::SemanticMap::SPLIT
# ui::SemanticMap::SPLIT_H
# ui::SemanticMap::SPLIT_V
# ui::SemanticMap::SQL
# ui::SemanticMap::SSD
# ui::SemanticMap::SSH
# ui::SemanticMap::STAR
# ui::SemanticMap::STATION
# ui::SemanticMap::STATUS
# ui::SemanticMap::STATUSBAR
# ui::SemanticMap::STETHOSCOPE
# ui::SemanticMap::STOP
# ui::SemanticMap::STOP_SIGN
# ui::SemanticMap::STOPPED
# ui::SemanticMap::STORAGE
# ui::SemanticMap::STORDIAG
# ui::SemanticMap::SUCCESS
# ui::SemanticMap::SUNGLASSES
# ui::SemanticMap::SUPERBLOCK
# ui::SemanticMap::SUPPORT
# ui::SemanticMap::SURFACE_SCAN
# ui::SemanticMap::SWIMSUIT
# ui::SemanticMap::SYNC
# ui::SemanticMap::SYNC_START
# ui::SemanticMap::SYNCHRONIZE
# ui::SemanticMap::SYRINGE
# ui::SemanticMap::SYSINTERNALS
# ui::SemanticMap::TAB
# ui::SemanticMap::TABLE
# ui::SemanticMap::TAG
# ui::SemanticMap::TAG_PREPARE
# ui::SemanticMap::TAMPERED
# ui::SemanticMap::TARGET_ARCHAEOLOGY
# ui::SemanticMap::TASK_SCHEDULER
# ui::SemanticMap::TAXI
# ui::SemanticMap::TCPDUMP
# ui::SemanticMap::TELEMETRY_SCAN
# ui::SemanticMap::TELESCOPE
# ui::SemanticMap::TERMINAL_CAPABILITIES
# ui::SemanticMap::TEST
# ui::SemanticMap::TESTDISK
# ui::SemanticMap::THEME
# ui::SemanticMap::THEME_COLOR
# ui::SemanticMap::THEME_PERSONA
# ui::SemanticMap::THIRDPARTY
# ui::SemanticMap::THUMBNAIL
# ui::SemanticMap::TILE
# ui::SemanticMap::TILE_GRID
# ui::SemanticMap::TOILET
# ui::SemanticMap::TOKEN
# ui::SemanticMap::TOOLBAR
# ui::SemanticMap::TOOLS
# ui::SemanticMap::TOOLTIP
# ui::SemanticMap::TOPOLOGY_SCAN
# ui::SemanticMap::TRACE
# ui::SemanticMap::TRACEROUTE
# ui::SemanticMap::TRACTOR
# ui::SemanticMap::TRAFFIC_LIGHT
# ui::SemanticMap::TRAIN
# ui::SemanticMap::TRANSLATE
# ui::SemanticMap::TRIGGER
# ui::SemanticMap::TRUCK
# ui::SemanticMap::TRUMPET
# ui::SemanticMap::TSHIRT
# ui::SemanticMap::TV
# ui::SemanticMap::UNALLOCATED
# ui::SemanticMap::UNAVAILABLE
# ui::SemanticMap::UNBLOCK
# ui::SemanticMap::UNDELETE
# ui::SemanticMap::UNDER_CONSTRUCTION
# ui::SemanticMap::UNDO
# ui::SemanticMap::UNKNOWN
# ui::SemanticMap::UNMOUNT
# ui::SemanticMap::UNPIN
# ui::SemanticMap::UNRECOVERABLE
# ui::SemanticMap::UNSTABLE
# ui::SemanticMap::UNTRASH
# ui::SemanticMap::UP
# ui::SemanticMap::UPDATE
# ui::SemanticMap::UPDATE_DB
# ui::SemanticMap::USB
# ui::SemanticMap::UTILS
# ui::SemanticMap::VARIABLE
# ui::SemanticMap::VERBOSE
# ui::SemanticMap::VERIFY
# ui::SemanticMap::VERIFY_INTEGRITY
# ui::SemanticMap::VERSION
# ui::SemanticMap::VIDEO
# ui::SemanticMap::VIEW
# ui::SemanticMap::VIOLIN
# ui::SemanticMap::VOLATILITY
# ui::SemanticMap::VOLUME
# ui::SemanticMap::VOLUME_DOWN
# ui::SemanticMap::VOLUME_UP
# ui::SemanticMap::VPN
# ui::SemanticMap::WAITING
# ui::SemanticMap::WARNING
# ui::SemanticMap::WARNING_STATE
# ui::SemanticMap::WATER
# ui::SemanticMap::WEBHOOK
# ui::SemanticMap::WEBHOOK_TRIGGER
# ui::SemanticMap::WHEEL
# ui::SemanticMap::WIFI
# ui::SemanticMap::WINDIRSTAT
# ui::SemanticMap::WINDOW
# ui::SemanticMap::WINFR
# ui::SemanticMap::WIP
# ui::SemanticMap::WIPE
# ui::SemanticMap::WIRELESS
# ui::SemanticMap::WIRESHARK
# ui::SemanticMap::WORKFLOW
# ui::SemanticMap::WORSHIP
# ui::SemanticMap::WRENCH
# ui::SemanticMap::WRITE_BLOCK
# ui::SemanticMap::XRAY
# ui::SemanticMap::XRAY_SCAN
# ui::SemanticMap::XWAYS
# ui::SemanticMap::ZOOM_IN
# ui::SemanticMap::ZOOM_OUT
# ui::StatusBar
# ui::StatusBar::BackgroundColor
# ui::StatusBar::HideWhenNarrow
# ui::StatusBar::Items
# ui::StatusBar::MaxItems
# ui::StatusBar::MinWidthForFull
# ui::StatusBar::Separator
# ui::StatusBar::ShowBackground
# ui::Tooltip
# ui::Tooltip::AutoPosition
# ui::Tooltip::BorderStyle
# ui::Tooltip::DelayMs
# ui::Tooltip::FadeInMs
# ui::Tooltip::FollowMouse
# ui::Tooltip::MaxWidth
# ui::Tooltip::OffsetX
# ui::Tooltip::OffsetY
# ui::Tooltip::RichText
# ui::Tooltip::Shadow
# ui::Tooltip::ShowHotkey

