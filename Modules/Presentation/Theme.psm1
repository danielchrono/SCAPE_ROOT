<#
.SYNOPSIS
    Domain: Presentation\Theme
    Module: Scape.Presentation.Theme
    Architecture: Pure Math | HSL Trigonometry | Adaptive Contrast | Immutable Origin
#>

$Script:ThemeCache = $null
$Script:UICache = $null
$Script:ColorMode = "ANSI16"
$Script:LiveFlagMap = @{}

function Initialize-ScapeTheme {
    [CmdletBinding()]
    param()
    $Script:ThemeCache = Get-ScapeConstant -Path "theme" -Fallback @{}
    $Script:UICache = Get-ScapeConstant -Path "ui" -Fallback @{}

    if ($env:WT_SESSION -or $env:TERM_PROGRAM -eq "vscode" -or $env:ConEmuPID -or $env:COLORTERM -eq "truecolor") {
        $Script:ColorMode = "TrueColor"
    }

    $baseMap = if ($Script:ThemeCache.Contains("FlagMap")) { $Script:ThemeCache["FlagMap"] } else { $Script:ThemeCache.FlagMap }
    foreach ($key in $baseMap.Keys) {
        $Script:LiveFlagMap[$key] = @{
            RGB      = $baseMap[$key].RGB
            Priority = $baseMap[$key].Priority
        }
    }
}

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

function Invoke-ScapeProceduralTheme {
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
    $rand = [Random]::new()
    $baseHue = $rand.NextDouble() * 360

    $uiHue = ($baseHue + 30) % 360
    $warnHue = ($baseHue + 180) % 360
    $dangerHue = ($warnHue + 30) % 360

    $S = 0.85; $L = 0.65

    foreach ($key in $Script:LiveFlagMap.Keys) {
        if ($key -match "FATAL|ERR") {
            $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $dangerHue -S 0.9 -L 0.6
        }
        elseif ($key -match "WARN|MENU") {
            $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $warnHue -S $S -L $L
        }
        elseif ($key -match "STATUS|CONFIRM|DONE") {
            $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H (($baseHue + 120) % 360) -S 0.8 -L 0.5
        }
        elseif ($key -match "SYSTEM|UI|HINT") {
            $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $uiHue -S $S -L $L
        }
        else {
            $Script:LiveFlagMap[$key].RGB = Convert-ScapeHSLToRGB -H $baseHue -S 0.2 -L 0.7
        }
    }
}

function Invoke-ScapeDaltonismMatrix {
    param([string]$Type = "Protanopia")
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }

    $filters = if ($Script:ThemeCache.Contrast.Contains("DaltonismFilters")) { $Script:ThemeCache.Contrast["DaltonismFilters"] } else { $Script:ThemeCache.Contrast.DaltonismFilters }

    if ($null -eq $filters -or -not $filters.Contains($Type)) { return }
    $mat = $filters[$Type]

    foreach ($key in $Script:LiveFlagMap.Keys) {
        $rgb = Resolve-ScapeRawRGB -RawValue $Script:LiveFlagMap[$key].RGB
        if ($null -ne $rgb) {
            $r = [int]($rgb[0] * $mat.RedFactor)
            $g = [int]($rgb[1] * $mat.GreenFactor)
            $b = [int]($rgb[2] * $mat.BlueFactor)

            $filtered = @((Get-ScapeClamp -Value $r -Min 0 -Max 255), (Get-ScapeClamp -Value $g -Min 0 -Max 255), (Get-ScapeClamp -Value $b -Min 0 -Max 255))
            $Script:LiveFlagMap[$key].RGB = Invoke-ScapeLightfy -RGB $filtered -Factor 0.3
        }
    }
}

function Set-ScapePersona {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][string]$Name)
    if ($PSCmdlet.ShouldProcess("Theme System", "Set Persona $Name")) {
        if (-not $Script:ThemeCache) { Initialize-ScapeTheme }
        Initialize-ScapeTheme
    }
}

function Resolve-ScapeRawRGB {
    param($RawValue)
    if ($RawValue -is [array]) { return $RawValue }

    if ($RawValue -is [string] -and $RawValue -match '^Base\.(\w+)$') {
        $colorName = $matches[1]
        $base = if ($Script:ThemeCache.Contains("Base")) { $Script:ThemeCache["Base"] } else { $Script:ThemeCache.Base }
        if ($base.Contains($colorName)) { return $base[$colorName] }
    }
    return @(120, 120, 120)
}

function Resolve-ScapeThemeColor {
    param([string]$Flag)
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }

    if ($Script:LiveFlagMap.Contains($Flag)) {
        $raw = $Script:LiveFlagMap[$Flag].RGB
        $rgb = Resolve-ScapeRawRGB -RawValue $raw
        return Get-ScapeSafeColor -RGB $rgb
    }
    return @(120, 120, 120)
}

function Convert-ScapeRGBToAnsi {
    param([int[]]$RGB, [switch]$IsBackground)
    $Type = if ($IsBackground) { 48 } else { 38 }
    $Esc = [char]0x1B
    return "${Esc}[${Type};2;$($RGB[0]);$($RGB[1]);$($RGB[2])m"
}

function Convert-ScapeAnsiToReset { return "$([char]0x1B)[0m" }

function Format-ScapeANSIMessage {
    param(
        [AllowEmptyString()][string]$Text = "",
        [string]$Flag,
        [switch]$IncludeBackground,
        [switch]$Bold,
        [switch]$Dim
    )
    if (-not $Script:ThemeCache) { Initialize-ScapeTheme }

    $reset = Convert-ScapeAnsiToReset
    $prefix = ""
    if ($Bold) { $prefix += "$([char]0x1B)[1m" }
    if ($Dim) { $prefix += "$([char]0x1B)[2m" }

    if ($Script:ColorMode -eq "TrueColor") {
        $rgb = Resolve-ScapeThemeColor -Flag $Flag
        $fgAnsi = Convert-ScapeRGBToAnsi -RGB $rgb

        if ($IncludeBackground) {
            $lum = Get-ScapeLuminance -R $rgb[0] -G $rgb[1] -B $rgb[2]
            $bgRgb = if ($lum -lt 128) { @(240, 240, 240) } else { @(30, 30, 30) }
            $bgAnsi = Convert-ScapeRGBToAnsi -RGB $bgRgb -IsBackground
            return "${prefix}${bgAnsi}${fgAnsi}${Text}${reset}"
        }
        return "${prefix}${fgAnsi}${Text}${reset}"
    }

    $ui = $Script:UICache
    $fgMap = if ($ui.ContainsKey("ANSI")) { $ui["ANSI"]["FG"] } else { $ui.ANSI.FG }

    $fgAnsi16 = if ($Flag -match "FATAL|ERR") { $fgMap.BrightRed }
    elseif ($Flag -match "WARN|MENU") { $fgMap.BrightYellow }
    elseif ($Flag -match "STATUS|CONFIRM|DONE") { $fgMap.BrightGreen }
    elseif ($Flag -match "SYSTEM|UI|HINT") { $fgMap.BrightCyan }
    else { $fgMap.White }

    return "${prefix}${fgAnsi16}${Text}${reset}"
}