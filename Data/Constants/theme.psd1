@{
    Segment = @{
        Name        = "theme"
        Version     = "1.0.0"
        Description = "Semantic color palettes, VT100 color theory mapping, accessibility matrices, animation curves, and dynamic theming engine for SCAPE TUI"
        Dependencies = @("core")
        HashSHA256  = "PLACEHOLDER_THEME_HASH"
    }

    # ===========================================================================
    # 1. BASE COLOR PALETTES (RGB 0-255) + Comunidade + Acessibilidade
    # ===========================================================================
    Base = @{
        # ---------- Primary Vibrant ----------
        Cyan    = @(  0, 220, 255)
        Green   = @( 80, 255, 120)
        Amber   = @(240, 220,  80)
        Red     = @(255,  80,  80)
        Blue    = @(100, 200, 255)
        Purple  = @(180, 120, 255)
        White   = @(240, 240, 240)
        Gray    = @(120, 120, 120)
        Dim     = @( 90,  90,  90)
        Black   = @(  0,   0,   0)
        Orange  = @(255, 165,   0)
        Pink    = @(255, 105, 180)
        Lime    = @( 50, 205,  50)
        Gold    = @(255, 215,   0)
        Teal    = @(  0, 128, 128)
        Indigo  = @( 75,   0, 130)
        Coral   = @(255, 127,  80)
        Salmon  = @(250, 128, 114)
        Lavender= @(230, 230, 250)
        Mint    = @(170, 240, 200)

        # ---------- Pastel ----------
        Pastel = @{
            Pink     = @(255, 182, 193)
            Blue     = @(173, 216, 230)
            Green    = @(144, 238, 144)
            Yellow   = @(255, 255, 224)
            Lavender = @(230, 230, 250)
            Peach    = @(255, 218, 185)
            Mint     = @(189, 252, 201)
        }

        # ---------- Core Themes ----------
        Dark = @{
            Bg      = @(20, 20, 20)
            Surface = @(40, 40, 40)
            Primary = @(0, 150, 200)
            Secondary = @(150, 150, 200)
            Text    = @(220, 220, 220)
            Muted   = @(100, 100, 100)
        }
        Light = @{
            Bg      = @(250, 250, 250)
            Surface = @(240, 240, 240)
            Primary = @(0, 100, 150)
            Secondary = @(80, 80, 120)
            Text    = @(30, 30, 30)
            Muted   = @(120, 120, 120)
        }
        Solarized = @{
            Base03 = @(0, 43, 54)
            Base02 = @(7, 54, 66)
            Base01 = @(88, 110, 117)
            Base00 = @(101, 123, 131)
            Base0  = @(131, 148, 150)
            Base1  = @(147, 161, 161)
            Base2  = @(238, 232, 213)
            Base3  = @(253, 246, 227)
            Yellow = @(181, 137, 0)
            Orange = @(203, 75, 22)
            Red    = @(220, 50, 47)
            Magenta= @(211, 54, 130)
            Violet = @(108, 113, 196)
            Blue   = @(38, 139, 210)
            Cyan   = @(42, 161, 152)
            Green  = @(133, 153, 0)
        }
        Nord = @{
            PolarNight = @(46, 52, 64)
            SnowStorm  = @(216, 222, 233)
            Frost      = @(129, 161, 193)
            Aurora     = @(163, 190, 140)
            Red        = @(191, 97, 106)
            Orange     = @(208, 135, 112)
            Yellow     = @(235, 203, 139)
            Green      = @(163, 190, 140)
        }

        # ---------- Community Favorites ----------
        Dracula = @{
            Bg      = @(40, 42, 54)
            Surface = @(68, 71, 90)
            Text    = @(248, 248, 242)
            Cyan    = @(139, 233, 253)
            Green   = @(80, 250, 123)
            Red     = @(255, 85, 85)
            Purple  = @(189, 147, 249)
            Yellow  = @(241, 250, 140)
            Pink    = @(255, 121, 198)
        }
        CatppuccinMocha = @{
            Bg      = @(30, 30, 46)
            Surface = @(49, 50, 68)
            Text    = @(205, 214, 244)
            Blue    = @(137, 180, 250)
            Green   = @(166, 227, 161)
            Red     = @(243, 139, 168)
            Mauve   = @(203, 166, 247)
            Peach   = @(250, 179, 135)
        }
        TokyoNight = @{
            Bg      = @(26, 27, 38)
            Surface = @(46, 48, 66)
            Text    = @(192, 202, 245)
            Blue    = @(122, 162, 247)
            Green   = @(158, 206, 106)
            Red     = @(247, 118, 142)
            Purple  = @(187, 154, 247)
            Cyan    = @(86, 182, 194)
        }
        GruvboxDark = @{
            Bg      = @(40, 40, 40)
            Surface = @(60, 56, 54)
            Text    = @(235, 219, 178)
            Red     = @(204, 36, 29)
            Green   = @(152, 151, 26)
            Yellow  = @(215, 153, 33)
            Blue    = @(69, 133, 136)
            Purple  = @(177, 98, 134)
            Cyan    = @(104, 157, 106)
        }
        OneDark = @{
            Bg      = @(35, 39, 46)
            Surface = @(45, 50, 60)
            Text    = @(224, 224, 224)
            Red     = @(224, 108, 117)
            Green   = @(152, 195, 121)
            Yellow  = @(229, 192, 123)
            Blue    = @(97, 175, 239)
            Purple  = @(198, 120, 221)
            Cyan    = @(86, 182, 194)
        }

        # ---------- Accessibility & Contrast ----------
        HighContrast = @{
            Red     = @(255, 0, 0)
            Green   = @(0, 255, 0)
            Blue    = @(0, 0, 255)
            Yellow  = @(255, 255, 0)
            Cyan    = @(0, 255, 255)
            Magenta = @(255, 0, 255)
            White   = @(255, 255, 255)
            Black   = @(0, 0, 0)
        }
        Colorblind = @{
            Blue   = @(0, 114, 178)
            Orange = @(230, 159, 0)
            Red    = @(213, 94, 0)
            Purple = @(204, 121, 167)
            Green  = @(0, 158, 115)
            Yellow = @(240, 228, 66)
            Gray   = @(102, 102, 102)
        }
        Mono = @{
            Black     = @(0, 0, 0)
            DarkGray  = @(64, 64, 64)
            Gray      = @(128, 128, 128)
            LightGray = @(192, 192, 192)
            White     = @(255, 255, 255)
        }
        Neon = @{
            Pink   = @(255, 0, 255)
            Cyan   = @(0, 255, 255)
            Lime   = @(50, 205, 50)
            Yellow = @(255, 255, 0)
            Orange = @(255, 128, 0)
            Purple = @(128, 0, 255)
            Blue   = @(0, 64, 255)
        }
        ANSI16 = @{
            Black        = @(0, 0, 0)
            Red          = @(170, 0, 0)
            Green        = @(0, 170, 0)
            Yellow       = @(170, 170, 0)
            Blue         = @(0, 0, 170)
            Magenta      = @(170, 0, 170)
            Cyan         = @(0, 170, 170)
            White        = @(170, 170, 170)
            BrightBlack  = @(85, 85, 85)
            BrightRed    = @(255, 85, 85)
            BrightGreen  = @(85, 255, 85)
            BrightYellow = @(255, 255, 85)
            BrightBlue   = @(85, 85, 255)
            BrightMagenta= @(255, 85, 255)
            BrightCyan   = @(85, 255, 255)
            BrightWhite  = @(255, 255, 255)
        }
    }

    # ===========================================================================
    # 2. VT100 COLOR THEORY & FALLBACK MAPPING
    # ===========================================================================
    VT100_ColorTheory = @{
        SGR_Foreground4Bit   = @(30, 31, 32, 33, 34, 35, 36, 37)
        SGR_Background4Bit   = @(40, 41, 42, 43, 44, 45, 46, 47)
        SGR_ForegroundBright = @(90, 91, 92, 93, 94, 95, 96, 97)
        SGR_BackgroundBright = @(100, 101, 102, 103, 104, 105, 106, 107)
        SGR_TrueColorFg      = "38;2"
        SGR_TrueColorBg      = "48;2"
        SGR_256Fg            = "38;5"
        SGR_256Bg            = "48;5"
        ApproximationMethod  = "Euclidean"   # "Euclidean", "Luminance", "PaletteClosest"
        ContrastAlgorithm    = "WCAG21"      # "WCAG21", "Weber", "Michelson"
        MinContrastRatio     = 4.5
        LuminanceFormula     = "0.299*R + 0.587*G + 0.114*B"
    }

    # ===========================================================================
    # 3. SEMANTIC FLAG MAP (expandido + PowerShell-aware)
    # ===========================================================================
    FlagMap = @{
        # System & Core
        SYSTEM          = @{ RGB = "Base.Cyan";   Priority = 1 }
        KERNEL          = @{ RGB = "Base.Purple"; Priority = 2 }
        KERNEL_ERR      = @{ RGB = "Base.Red";    Priority = 1 }
        BOOT_SEQ        = @{ RGB = "Base.Cyan";   Priority = 2 }
        SYSTEM_STATE    = @{ RGB = "Base.Blue";   Priority = 3 }
        FIRMWARE        = @{ RGB = "Base.Orange"; Priority = 2 }
        ERR             = @{ RGB = "Base.Red";    Priority = 1 }
        FATAL           = @{ RGB = "Base.Red";    Priority = 1 }
        WARN            = @{ RGB = "Base.Amber";  Priority = 2 }
        STATE_WARN      = @{ RGB = "Base.Amber";  Priority = 2 }
        INPUT_ERR       = @{ RGB = "Base.Red";    Priority = 1 }
        RESTRICTED      = @{ RGB = "Base.Red";    Priority = 1 }
        TIMEOUT         = @{ RGB = "Base.Amber";  Priority = 2 }
        RETRY           = @{ RGB = "Base.Gold";   Priority = 2 }
        STATUS          = @{ RGB = "Base.Green";  Priority = 3 }
        CONFIRM         = @{ RGB = "Base.Green";  Priority = 3 }
        SANCTUARY       = @{ RGB = "Base.Green";  Priority = 2 }
        DEPLOYER_DONE   = @{ RGB = "Base.Green";  Priority = 3 }
        CARVE_HIT       = @{ RGB = "Base.Green";  Priority = 2 }
        DONE            = @{ RGB = "Base.Green";  Priority = 3 }
        UI              = @{ RGB = "Base.Blue";   Priority = 3 }
        MENU            = @{ RGB = "Base.Amber";  Priority = 2 }
        HINT            = @{ RGB = "Base.Blue";   Priority = 3 }
        LOG             = @{ RGB = "Base.Cyan";   Priority = 3 }
        PROMPT          = @{ RGB = "Base.White";  Priority = 3 }
        BANNER          = @{ RGB = "Base.Gold";   Priority = 3 }
        TOOLTIP         = @{ RGB = "Base.Gray";   Priority = 4 }
        LAB             = @{ RGB = "Base.Purple"; Priority = 2 }
        LAB_FATAL       = @{ RGB = "Base.Red";    Priority = 1 }
        LAB_WARN        = @{ RGB = "Base.Amber";  Priority = 2 }
        MAESTRO_ROUTINE = @{ RGB = "Base.Amber";  Priority = 2 }
        DEBUG           = @{ RGB = "Base.Dim";    Priority = 4 }
        TRACE           = @{ RGB = "Base.Gray";   Priority = 4 }
        IO_FATAL        = @{ RGB = "Base.Red";    Priority = 1 }
        IO_STREAM       = @{ RGB = "Base.Cyan";   Priority = 3 }
        IO_RESILIENCE   = @{ RGB = "Base.Green";  Priority = 2 }
        HW_METRICS_CRITICAL = @{ RGB = "Base.Red";    Priority = 1 }
        HW_METRICS_NORMAL   = @{ RGB = "Base.Blue";   Priority = 3 }
        SECTOR_READ     = @{ RGB = "Base.Teal";   Priority = 3 }
        BUFFER_FLUSH    = @{ RGB = "Base.Indigo"; Priority = 2 }
        NETWORK_SECURE  = @{ RGB = "Base.Green";  Priority = 2 }
        SYNC            = @{ RGB = "Base.Blue";   Priority = 3 }
        SMB_CONN        = @{ RGB = "Base.Cyan";   Priority = 2 }
        SMB_ERR         = @{ RGB = "Base.Red";    Priority = 1 }
        CLOUD_SYNC      = @{ RGB = "Base.Purple"; Priority = 2 }
        SQLITE_ENGINE   = @{ RGB = "Base.Purple"; Priority = 2 }
        SQLITE_FATAL    = @{ RGB = "Base.Red";    Priority = 1 }
        ARCHIVE_ENGINE  = @{ RGB = "Base.Cyan";   Priority = 2 }
        DB_QUERY        = @{ RGB = "Base.Blue";   Priority = 3 }
        DB_INDEX        = @{ RGB = "Base.Green";  Priority = 3 }
        PIPELINE_FAILSAFE = @{ RGB = "Base.Red";    Priority = 1 }
        COMPILER        = @{ RGB = "Base.Purple"; Priority = 2 }
        ROUTER_FATAL    = @{ RGB = "Base.Red";    Priority = 1 }
        PARSER          = @{ RGB = "Base.Teal";   Priority = 2 }
        PARSER_RECOVER  = @{ RGB = "Base.Green";  Priority = 2 }
        INVENTORY_MANAGER = @{ RGB = "Base.Cyan";   Priority = 2 }
        TELEMETRY_ALERT = @{ RGB = "Base.Red";    Priority = 1 }
        DEPLOYER_FATAL  = @{ RGB = "Base.Red";    Priority = 1 }
        METRIC_SAMPLE   = @{ RGB = "Base.Gray";   Priority = 4 }
        AUDIT           = @{ RGB = "Base.Gold";   Priority = 2 }
        COMPLIANCE      = @{ RGB = "Base.Blue";   Priority = 2 }
        ENCRYPTION      = @{ RGB = "Base.Purple"; Priority = 2 }
        INTEGRITY_CHECK = @{ RGB = "Base.Green";  Priority = 2 }
        INTEGRITY_FAIL  = @{ RGB = "Base.Red";    Priority = 1 }
        CARVING_START   = @{ RGB = "Base.Cyan";   Priority = 2 }
        CARVING_FRAG    = @{ RGB = "Base.Amber";  Priority = 2 }
        CARVING_HEAL    = @{ RGB = "Base.Green";  Priority = 3 }
        SIGNATURE_HIT   = @{ RGB = "Base.Lime";   Priority = 2 }
        HEALTH_OK       = @{ RGB = "Base.Green";  Priority = 3 }
        HEALTH_WARN     = @{ RGB = "Base.Amber";  Priority = 2 }
        HEALTH_CRITICAL = @{ RGB = "Base.Red";    Priority = 1 }
        PERFORMANCE_HIGH= @{ RGB = "Base.Cyan";   Priority = 2 }
        PERFORMANCE_LOW = @{ RGB = "Base.Orange"; Priority = 2 }
        RESEARCH        = @{ RGB = "Base.Lavender"; Priority = 3 }
        DRAGON          = @{ RGB = "Base.Coral";   Priority = 2 }
        CUSTOM_1        = @{ RGB = "Base.Pink";    Priority = 3 }
        CUSTOM_2        = @{ RGB = "Base.Teal";    Priority = 3 }
        CUSTOM_3        = @{ RGB = "Base.Indigo";  Priority = 3 }

        # PowerShell Context
        PS_PIPELINE     = @{ RGB = "Base.Cyan";   Priority = 2 }
        PS_MODULE       = @{ RGB = "Base.Purple"; Priority = 2 }
        PS_PROFILE      = @{ RGB = "Base.Gold";   Priority = 3 }
        PS_CREDENTIAL   = @{ RGB = "Base.Amber";  Priority = 2 }
        PS_EXECUTION    = @{ RGB = "Base.Red";    Priority = 1 }
        PS_RUNSPACE     = @{ RGB = "Base.Teal";   Priority = 2 }
        PS_AUTOCOMPLETE = @{ RGB = "Base.Green";  Priority = 3 }
        PS_HISTORY      = @{ RGB = "Base.Gray";   Priority = 3 }
    }

    # ===========================================================================
    # 4. PERSONA PRESETS (troca instantânea de perfil)
    # ===========================================================================
    Persona = @{
        Cyber      = @{ Palette = "Neon"; Frame = "Cyber"; Progress = "Spinner"; Animation = $true; Contrast = "Dark" }
        Corporate  = @{ Palette = "Nord"; Frame = "Classic"; Progress = "Default"; Animation = $false; Contrast = "Light" }
        Hacker     = @{ Palette = "Dracula"; Frame = "Thick"; Progress = "BarOnly"; Animation = $true; Contrast = "Dark" }
        Minimal    = @{ Palette = "Mono"; Frame = "Borderless"; Progress = "Compact"; Animation = $false; Contrast = "Auto" }
        Retro      = @{ Palette = "GruvboxDark"; Frame = "Retro"; Progress = "Discrete"; Animation = $true; Contrast = "Dark" }
        HighVis    = @{ Palette = "HighContrast"; Frame = "Heavy"; Progress = "Default"; Animation = $false; Contrast = "Light" }
        PowerShell = @{ Palette = "CatppuccinMocha"; Frame = "Rounded"; Progress = "Default"; Animation = $true; Contrast = "Dark" }
    }

    # ===========================================================================
    # 5. STATE MODIFIERS (com suporte a efeitos avançados)
    # ===========================================================================
    States = @{
        Hover      = @{ Method = "add"; RedAdd = 40; GreenAdd = 40; BlueAdd = 40; Clamp = $true }
        Selected   = @{ Method = "add"; RedAdd = 30; GreenAdd = 30; BlueAdd = 30; Clamp = $true }
        Disabled   = @{ Method = "fixed"; RGB = @(70, 70, 70) }
        Focus      = @{ Method = "multiply"; Factor = 1.2; Clamp = $true }
        Pressed    = @{ Method = "multiply"; Factor = 0.8; Clamp = $true }
        Loading    = @{ Method = "blink"; PeriodMs = 800 }
        ErrorHighlight = @{ Method = "blink"; PeriodMs = 500 }
        Glitch     = @{ Method = "offset"; OffsetX = 1; OffsetY = 0; PeriodMs = 300; Clamp = $true }
        Scanline   = @{ Method = "alpha"; Alpha = 0.85; LineSpacing = 2 }
        Pulse      = @{ Method = "pulse"; FrequencyHz = 2; MinAlpha = 0.6; MaxAlpha = 1.0 }
    }

    # ===========================================================================
    # 6. CONTRAST & ACCESSIBILITY
    # ===========================================================================
    Contrast = @{
        LightThreshold    = 128
        LightFg           = @(30, 30, 30)
        DarkFg            = @(240, 240, 240)
        MinContrastRatio  = 4.5
        PreferredScheme   = "auto"
        BgLight           = @(245, 245, 245)
        BgDark            = @(20, 20, 20)
        OverlayAlpha      = 0.7
        DaltonismFilters  = @{
            Protanopia     = @{ RedFactor = 0.0; GreenFactor = 0.5; BlueFactor = 0.5 }
            Deuteranopia   = @{ RedFactor = 0.5; GreenFactor = 0.0; BlueFactor = 0.5 }
            Tritanopia     = @{ RedFactor = 0.5; GreenFactor = 0.5; BlueFactor = 0.0 }
            Achromatopsia  = @{ RedFactor = 0.299; GreenFactor = 0.587; BlueFactor = 0.114 }
        }
        DyslexiaFriendly  = @{ FontHint = "mono-wide"; LineHeight = 1.6; LetterSpacing = 0.5; HighContrast = $true }
    }

    # ===========================================================================
    # 7. GRADIENT TEMPLATES
    # ===========================================================================
    Gradients = @{
        Sunset   = @(@(255, 80, 80), @(255, 160, 80), @(255, 220, 80))
        Matrix   = @(@(0, 120, 0), @(50, 205, 50), @(120, 255, 120))
        Cyber    = @(@(255, 0, 255), @(0, 255, 255))
        Metal    = @(@(80, 80, 80), @(160, 160, 160), @(240, 240, 240))
        Ocean    = @(@(0, 50, 150), @(0, 150, 200), @(100, 200, 255))
        Fire     = @(@(255, 0, 0), @(255, 165, 0), @(255, 255, 0))
        Aurora   = @(@(0, 100, 0), @(80, 200, 80), @(150, 255, 150))
        Terminal = @(@(40, 44, 52), @(98, 114, 164), @(205, 214, 244))
        Blood    = @(@(139, 0, 0), @(204, 36, 29), @(255, 85, 85))
        Ice      = @(@(176, 224, 230), @(135, 206, 235), @(70, 130, 180))
    }

    # ===========================================================================
    # 8. ANIMATION HINTS
    # ===========================================================================
    Animation = @{
        FadeSteps    = 8
        TransitionMs = 100
        PulseHz      = 2
        Enabled      = $true
        Easing       = "ease-in-out"
        EasingCurves = @{
            Linear     = @(0.0, 0.0, 1.0, 1.0)
            EaseIn     = @(0.42, 0.0, 1.0, 1.0)
            EaseOut    = @(0.0, 0.0, 0.58, 1.0)
            EaseInOut  = @(0.42, 0.0, 0.58, 1.0)
            EaseInQuad = @(0.11, 0.0, 0.5, 0.0)
            EaseOutQuad= @(0.5, 1.0, 0.89, 1.0)
            Bounce     = @(0.25, 0.46, 0.45, 0.94)
        }
        Keyframes = @{
            Pulse   = @(@{ Progress = 0; Scale = 1.0 }, @{ Progress = 50; Scale = 1.1 }, @{ Progress = 100; Scale = 1.0 })
            FadeIn  = @(@{ Progress = 0; Opacity = 0.0 }, @{ Progress = 100; Opacity = 1.0 })
            Typing  = @(@{ Progress = 0; Width = 0 }, @{ Progress = 100; Width = 100 })
            Scanline= @(@{ Progress = 0; Y = 0 }, @{ Progress = 100; Y = 100 })
            SlideIn = @(@{ Progress = 0; X = -100 }, @{ Progress = 100; X = 0 })
        }
        GlitchFrames = @(@{ OffsetX = 0; OffsetY = 0 }, @{ OffsetX = 1; OffsetY = -1 }, @{ OffsetX = -1; OffsetY = 1 })
    }

    # ===========================================================================
    # 9. DYNAMIC THEME & FALLBACKS
    # ===========================================================================
    DynamicTheme = @{
        Enabled         = $true
        PollIntervalSec = 60
        Fallback        = "dark"
        LightMap        = @{ Bg = "Base.Light.Bg"; Surface = "Base.Light.Surface"; Primary = "Base.Light.Primary"; Text = "Base.Light.Text"; Muted = "Base.Light.Muted" }
        DarkMap         = @{ Bg = "Base.Dark.Bg"; Surface = "Base.Dark.Surface"; Primary = "Base.Dark.Primary"; Text = "Base.Dark.Text"; Muted = "Base.Dark.Muted" }
        AutoDetect      = @{ RegistryKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; ValueName = "AppsUseLightTheme" }
    }

    Fallback = @{
        ColorMode256 = $true
        ANSI16Map = @{
            "Base.Red"     = "FG.Red"
            "Base.Green"   = "FG.Green"
            "Base.Blue"    = "FG.Blue"
            "Base.Cyan"    = "FG.Cyan"
            "Base.Amber"   = "FG.Yellow"
            "Base.Purple"  = "FG.Magenta"
            "Base.White"   = "FG.White"
            "Base.Black"   = "FG.Black"
            "Base.Gray"    = "FG.BrightBlack"
            "Base.Dim"     = "FG.BrightBlack"
            "Base.Orange"  = "FG.BrightYellow"
            "Base.Pink"    = "FG.BrightMagenta"
            "Base.Lime"    = "FG.BrightGreen"
            "Base.Gold"    = "FG.BrightYellow"
        }
        UnicodeFallback = @{
            "⠋" = "*"; "⠙" = "*"; "⠹" = "*"; "⠸" = "*"; "⠼" = "*"
            "⠴" = "*"; "⠦" = "*"; "⠧" = "*"; "⠇" = "*"; "⠏" = "*"
        }
        MissingIconChar = "?"
        SGRReset        = "`e[0m"
    }

    Telemetry = @{
        CpuIdle    = @{ RGB = "Base.Green"; ThresholdLow = 20; ThresholdHigh = 80 }
        CpuBusy    = @{ RGB = "Base.Amber"; ThresholdCritical = 95 }
        MemLow     = @{ RGB = "Base.Red"; Threshold = 10 }
        MemOk      = @{ RGB = "Base.Green"; Threshold = 30 }
        TempHot    = @{ RGB = "Base.Red"; Threshold = 75 }
        TempWarm   = @{ RGB = "Base.Amber"; Threshold = 60 }
        TempCool   = @{ RGB = "Base.Cyan"; Threshold = 40 }
        DiskIO     = @{ RGB = "Base.Teal"; ThresholdMBs = 50 }
        NetLatency = @{ RGB = "Base.Lime"; ThresholdMs = 100 }
    }
}