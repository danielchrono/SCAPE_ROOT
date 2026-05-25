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
    $Script:UICache = Get-ScapeConstant -Path "ui" -Fallback @{}
    $Script:IconCache = Get-ScapeConstant -Path "ui::Icons" -Fallback @{}

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
        if ($null -eq $Script:IconCache) { Initialize-ScapeTheme }

        # Resolve o nível atual (0=Graphic, 1=Unicode, 2=ASCII)
        # O Fallback aqui é o seu detector automático se o ColdState falhar
        $level = Get-ScapeConstant -Path "IconLevel" -Fallback (Get-ScapeDefaultIconLevel)

        if ($Script:IconCache.Contains($IconName)) {
            return $Script:IconCache[$IconName][$level]
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
    $Type = if ($IsBackground) { 48 } else { 38 }
    return "$([char]0x1B)[${Type};2;$($RGB[0]);$($RGB[1]);$($RGB[2])m"
}

function Convert-ScapeAnsiToReset { return "$([char]0x1B)[0m" }

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
    param([int[]]$RGB, [int[]]$BgRGB = @(20, 20, 20))
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
    param()
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    $rand = [Random]::new()
    $baseHue = $rand.NextDouble() * 360
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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][string]$Name, [switch]$Silent)
    if ($PSCmdlet.ShouldProcess("Theme System", "Set Persona $Name")) {
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
            
            # Apply FrameStyle
            if ($persona.Frame) {
                Set-ScapeSettingMutation -Key "FrameStyle" -Value $persona.Frame | Out-Null
            }
            
            # Apply ProgressStyle
            if ($persona.Progress) {
                Set-ScapeSettingMutation -Key "ProgressStyle" -Value $persona.Progress | Out-Null
            }
            
            # Apply Animation setting
            if ($null -ne $persona.Animation) {
                Set-ScapeSettingMutation -Key "AnimationEnabled" -Value [bool]$persona.Animation | Out-Null
            }
            
            # Apply Contrast hint (store for UI to apply)
            if ($persona.Contrast) {
                Set-ScapeSettingMutation -Key "ContrastMode" -Value $persona.Contrast | Out-Null
            }
            
            if (-not $Silent) { Publish-ScapeEvent -Type "THEME_PERSONA_APPLIED" -Severity "INFO" -Payload @{ Persona = $Name } }
        }
    }
}

function Set-ScapeColorMode {
    [CmdletBinding()]
    param([bool]$UseTrueColor, [switch]$Silent)
    if ($UseTrueColor) { $Script:ColorMode = "TrueColor" }
    else { $Script:ColorMode = "ANSI16" }
    if (-not $Silent) { Publish-ScapeEvent -Type "COLOR_MODE_CHANGED" -Severity "INFO" -Payload @{ Mode = $Script:ColorMode } }
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
    return @(120, 120, 120)
}

function Resolve-ScapeThemeColor {
    param([string]$Flag)
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    if ($Script:LiveFlagMap.Contains($Flag)) {
        $rgb = Resolve-ScapeRawRGB -RawValue $Script:LiveFlagMap[$Flag].RGB
        return Get-ScapeSafeColor -RGB $rgb
    }
    return @(120, 120, 120)
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
        "FG.Black" = "$([char]0x1B)[30m"; "FG.Red" = "$([char]0x1B)[31m"; "FG.Green" = "$([char]0x1B)[32m"; "FG.Yellow" = "$([char]0x1B)[33m"
        "FG.Blue" = "$([char]0x1B)[34m"; "FG.Magenta" = "$([char]0x1B)[35m"; "FG.Cyan" = "$([char]0x1B)[36m"; "FG.White" = "$([char]0x1B)[37m"
        "FG.BrightBlack" = "$([char]0x1B)[90m"; "FG.BrightRed" = "$([char]0x1B)[91m"; "FG.BrightGreen" = "$([char]0x1B)[92m"; "FG.BrightYellow" = "$([char]0x1B)[93m"
        "FG.BrightBlue" = "$([char]0x1B)[94m"; "FG.BrightMagenta" = "$([char]0x1B)[95m"; "FG.BrightCyan" = "$([char]0x1B)[96m"; "FG.BrightWhite" = "$([char]0x1B)[97m"
    }
    if ($ansiByToken.ContainsKey($token)) { return $ansiByToken[$token] }
    return "$([char]0x1B)[37m"
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

    $ESC = [char]27
    $reset = "$ESC[0m"
    $prefix = ""
    if ($Bold) { $prefix += "$ESC[1m" }
    if ($Dim) { $prefix += "$ESC[2m" }

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
        if ($null -eq $Script:IconCache) { Initialize-ScapeTheme }

        # 1. Resolve nome semântico via ui::SemanticMap (fonte da verdade)
        $semanticMap = $Script:UICache['SemanticMap']
        $iconName = if ($semanticMap -and $semanticMap.ContainsKey($RouteId)) { $semanticMap[$RouteId] } else { $RouteId }

        # 2. Busca array de ícones no cache do Theme
        $iconArr = $Script:IconCache[$iconName]
        if ($null -eq $iconArr -or $iconArr -isnot [array] -or $iconArr.Count -eq 0) { return "" }

        # MVVM estrito: IconLevel deve ser input read-only
        $level = if ($IconLevel -lt 0) { 0 } else { [int]$IconLevel }
        if ($level -ge $iconArr.Count) { $level = $iconArr.Count -1 }

        return [string]$iconArr[$level]
    }
}