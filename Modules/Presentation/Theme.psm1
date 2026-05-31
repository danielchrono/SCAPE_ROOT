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

    # 1. Carregamento Seguro (PrevenÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o contra "Cannot index into a null array")
    $Script:ThemeCache = Get-ScapeConstant -Path "theme" -Fallback @{}

    # 2. DetecÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o de Terminal
    if ($env:WT_SESSION -or $env:TERM_PROGRAM -eq "vscode" -or $env:ConEmuPID -or $env:COLORTERM -eq "truecolor") {
        $Script:ColorMode = "TrueColor"
    }

    # 3. PopulaÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o do LiveFlagMap (Segura e Resiliente)
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

    # 4. AplicaÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o de Persona e Modo de Cor do Estado (Se houver)
    # MVVM estrito: Theme apenas inicializa constantes/dados puros.
    # A leitura de ColdState e aplicaÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o (Set-ScapePersona/ColorMode) devem ser
    # coordenadas pela camada superior, nÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o na inicializaÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o pura da Theme.
}

# --- GESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢O DE ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂCONES (Resolvendo o $icons perdido) ---

function Get-ScapeIcon {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$IconName)
    process {
        # Resolve o nÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­vel atual (0=Graphic, 1=Unicode, 2=ASCII)
        # O Fallback aqui ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â© o seu detector automÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡tico se o ColdState falhar
        $level = Get-ScapeConstant -Path "IconLevel" -Fallback (Get-ScapeDefaultIconLevel)

        $iconArr = Get-ScapeConstant -Path "ui::Icons::$IconName"
        if ($null -ne $iconArr -and $iconArr -is [array] -and $iconArr.Count -gt $level) {
            return $iconArr[$level]
        }
        return ""
    }
}

# --- MATEMÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂTICA DE COR E CONVERSÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢O ---

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

# --- MANIPULAÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢O DINÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡MICA ---

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
                    [void]$colorName
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
    [void]$IncludeBackground
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
# CENTRALIZADOR DE ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂCONES (Data-Driven | Zero Hardcode | Usa Cache do Theme)
# =============================================================================
function Get-ScapeResolvedIcon {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$RouteId,
        [Parameter()][int]$IconLevel = 0
    )
    process {
        [void]$IncludeBackground
        [void]$IncludeBackground
        # 1. Resolve nome semÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ntico via ui::SemanticMap (fonte da verdade)
        $semanticMap = Get-ScapeConstant -Path "ui::SemanticMap"
        $iconName = if ($semanticMap -and $semanticMap.ContainsKey($RouteId)) { $semanticMap[$RouteId] } else { $RouteId }

        # 2. Busca array de ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­cones na ui.psd1
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

Export-ModuleMember -Function *,
    'Format-ScapeANSIHighlight',
    'Invoke-ScapeDaltonismMatrix',
    'Convert-ScapeAnsiToReset',
    'Get-ScapeIcon'
