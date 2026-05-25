@{
    Segment              = @{
        Name         = "ui"
        Version      = "1.0.0"
        Description  = "VT100/ANSI reference, layout constants, input protocols, frame presets, progress engines, window management & PowerShell TUI extensions"
        Dependencies = @("system", "theme")
        HashSHA256   = "PLACEHOLDER_UI_HASH"
    }

    # ===========================================================================
    # 1. ANSI / VT100 REFERENCE COMPLETO (COMPATÍVEL COM PS 5.1)
    # ===========================================================================
    ANSI                 = @{
        SGR               = @{
            Reset = "$([char]27)[0m"; Bold = "$([char]27)[1m"; Dim = "$([char]27)[2m"
            Italic = "$([char]27)[3m"; Underline = "$([char]27)[4m"; SlowBlink = "$([char]27)[5m"
            RapidBlink = "$([char]27)[6m"; Invert = "$([char]27)[7m"; Hidden = "$([char]27)[8m"
            Strike = "$([char]27)[9m"; DefaultFont = "$([char]27)[10m"; Fraktur = "$([char]27)[20m"
            DoublyUnderline = "$([char]27)[21m"; NoBlink = "$([char]27)[25m"; NoInvert = "$([char]27)[27m"
            NoHidden = "$([char]27)[28m"; NoStrike = "$([char]27)[29m"; ForegroundReset = "$([char]27)[39m"
            BackgroundReset = "$([char]27)[49m"
        }
        FG                = @{
            Black = "$([char]27)[30m"; Red = "$([char]27)[31m"; Green = "$([char]27)[32m"
            Yellow = "$([char]27)[33m"; Blue = "$([char]27)[34m"; Magenta = "$([char]27)[35m"
            Cyan = "$([char]27)[36m"; White = "$([char]27)[37m"; Default = "$([char]27)[39m"
            BrightBlack = "$([char]27)[90m"; BrightRed = "$([char]27)[91m"
            BrightGreen = "$([char]27)[92m"; BrightYellow = "$([char]27)[93m"
            BrightBlue = "$([char]27)[94m"; BrightMagenta = "$([char]27)[95m"
            BrightCyan = "$([char]27)[96m"; BrightWhite = "$([char]27)[97m"
        }
        BG                = @{
            Black = "$([char]27)[40m"; Red = "$([char]27)[41m"; Green = "$([char]27)[42m"
            Yellow = "$([char]27)[43m"; Blue = "$([char]27)[44m"; Magenta = "$([char]27)[45m"
            Cyan = "$([char]27)[46m"; White = "$([char]27)[47m"; Default = "$([char]27)[49m"
            BrightBlack = "$([char]27)[100m"; BrightRed = "$([char]27)[101m"
            BrightGreen = "$([char]27)[102m"; BrightYellow = "$([char]27)[103m"
            BrightBlue = "$([char]27)[104m"; BrightMagenta = "$([char]27)[105m"
            BrightCyan = "$([char]27)[106m"; BrightWhite = "$([char]27)[107m"
        }
        Color256FgPrefix  = "$([char]27)[38;5;"
        Color256BgPrefix  = "$([char]27)[48;5;"
        TrueColorFgPrefix = "$([char]27)[38;2;"
        TrueColorBgPrefix = "$([char]27)[48;2;"
        Cursor            = @{
            Hide = "$([char]27)[?25l"; Show = "$([char]27)[?25h"; Save = "$([char]27)[s"
            Restore = "$([char]27)[u"; Up = "$([char]27)[{0}A"; Down = "$([char]27)[{0}B"
            Right = "$([char]27)[{0}C"; Left = "$([char]27)[{0}D"; NextLine = "$([char]27)[{0}E"
            PrevLine = "$([char]27)[{0}F"; Column = "$([char]27)[{0}G"; Position = "$([char]27)[{0};{1}H"
            Forward = "$([char]27)[{0}C"; Backward = "$([char]27)[{0}D"; LineStart = "$([char]27)[G"
            LineEnd = "$([char]27)[9999C"; ShapeBlock = "$([char]27)[2 q"; ShapeLine = "$([char]27)[6 q"
            ShapeUnderscore = "$([char]27)[4 q"; BlinkBlock = "$([char]27)[1 q"; BlinkLine = "$([char]27)[5 q"
            BlinkUnderscore = "$([char]27)[3 q"
        }
        Screen            = @{
            ClearFull = "$([char]27)[2J$([char]27)[H"; ClearToEOL = "$([char]27)[0K"; ClearToBOL = "$([char]27)[1K"
            ClearLineFull = "$([char]27)[2K"; EraseScreen = "$([char]27)[2J"; EraseSavedLines = "$([char]27)[3J"
            ScrollUp = "$([char]27)[{0}S"; ScrollDown = "$([char]27)[{0}T"; SetRegion = "$([char]27)[{0};{1}r"
            SetColumns = "$([char]27)[?3h$([char]27)[?3l"; SaveCursorState = "$([char]27)[s"; RestoreCursorState = "$([char]27)[u"
        }
        Mouse             = @{
            EnableX10 = "$([char]27)[?9h"; DisableX10 = "$([char]27)[?9l"; EnableNormal = "$([char]27)[?1000h"
            DisableNormal = "$([char]27)[?1000l"; EnableButtonEvent = "$([char]27)[?1002h"; DisableButtonEvent = "$([char]27)[?1002l"
            EnableAnyEvent = "$([char]27)[?1003h"; DisableAnyEvent = "$([char]27)[?1003l"; EnableSGR = "$([char]27)[?1006h"
            DisableSGR = "$([char]27)[?1006l"; EnableUTF8Ext = "$([char]27)[?1005h"; DisableUTF8Ext = "$([char]27)[?1005l"
            ReportFormat = "$([char]27)[<{0};{1};{2}{3}"
        }
        Keyboard          = @{
            EnableCSIU = "$([char]27)[>1u"; EnableKitty = "$([char]27)[>u"
            LegacyMap = @{
                Up = "$([char]27)[A"; Down = "$([char]27)[B"; Right = "$([char]27)[C"; Left = "$([char]27)[D"
                Home = "$([char]27)[H"; End = "$([char]27)[F"; PageUp = "$([char]27)[5~"; PageDown = "$([char]27)[6~"
                Insert = "$([char]27)[2~"; Delete = "$([char]27)[3~"; F1 = "$([char]27)OP"; F2 = "$([char]27)OQ"
                F3 = "$([char]27)OR"; F4 = "$([char]27)OS"; F5 = "$([char]27)[15~"; F6 = "$([char]27)[17~"
                F7 = "$([char]27)[18~"; F8 = "$([char]27)[19~"; F9 = "$([char]27)[20~"; F10 = "$([char]27)[21~"
                F11 = "$([char]27)[23~"; F12 = "$([char]27)[24~"
            }
        }
        OSC               = @{
            SetTitle = "$([char]27)]0;{0}`a"; SetIconTitle = "$([char]27)]1;{0}`a"
            HyperlinkOpen = "$([char]27)]8;;{0}$([char]27)\\"; HyperlinkClose = "$([char]27)]8;;`a$([char]27)\\"
            Notify = "$([char]27)]9;{0};{1}`a"; QueryColors = "$([char]27)]10;?`a$([char]27)]11;?`a$([char]27)]12;?`a"
            ClipboardRead = "$([char]27)]52;{0};?`a"; ClipboardWrite = "$([char]27)]52;{0};{1}`a"
            ShellPrompt = "$([char]27)]133;A`a"; ShellCommand = "$([char]27)]133;B`a"; ShellExit = "$([char]27)]133;C;{0}`a"
        }
        DEC               = @{
            EnableAltBuffer = "$([char]27)[?1049h"; DisableAltBuffer = "$([char]27)[?1049l"
            EnableAutoWrap = "$([char]27)[?7h"; DisableAutoWrap = "$([char]27)[?7l"
            EnableCursorKeys = "$([char]27)[?1h$([char]27)[?1l"; EnableFocusInOut = "$([char]27)[?1004h"; DisableFocusInOut = "$([char]27)[?1004l"
            EnableBracketedPaste = "$([char]27)[?2004h"; DisableBracketedPaste = "$([char]27)[?2004l"
            EnableSixel = "$([char]27)[?80h"; DisableSixel = "$([char]27)[?80l"
        }
    }

    # ===========================================================================
    # 2. BRANDING & IDENTIDADE VISUAL
    # ===========================================================================
    Branding             = @{
        Product = "SCAPE"
        Tagline = "Systematic Container & Asset Processing Engine"
        Author  = "Terminal Architect"
        Version = "1.0.0"
        License = "MIT"
        Repo    = "https://github.com/namespace/scape"
        Doc     = "https://scape.docs"
        Support = "Discord: #scape-support | Email: support@scape.dev"
    }

    # ===========================================================================
    # 3. ASCII / ANSI ART
    # ===========================================================================
    Art                  = @{
        BannerLogo      = @"
  ███████╗ ██████╗ █████╗ ██████╗ ███████╗
  ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝
███████╗██║     ███████║██████╔╝█████╗
╚════██║██║     ██╔══██║██╔═══╝ ██╔══╝
  ███████║╚██████╗██║  ██║██║     ███████╗
  ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝
"@

        SmallLogo       = @"
 ╔═╗╔═╗╔═╗╔═╗╔═╗
╚═╗║  ╠═╣╠═╝║═
 ╚═╝╚═╝╩ ╩╩  ╚═╝
"@

        SmallLogoMicro  = "◆ SCAPE v1.0 ◆"
        SmallLogoStatus = "[ SCAPE TUI ]"
        SmallLogoIcon   = "◆"

        Variants        = @{
            Standard  = "BannerLogo"
            Compact   = "SmallLogo"
            Micro     = "SmallLogoMicro"
            StatusBar = "SmallLogoStatus"
            IconOnly  = "SmallLogoIcon"
        }

        # Separadores estruturais (longos)
        SeparatorLong   = "─────────────────────────────────────────────────────────────────"
        DoubleSepLong   = "═════════════════════════════════════════════════════════════════"
        ThickSepLong    = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        DottedSepLong   = "·································································"
        DashedSepLong   = "  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -  "
    }

    # ===========================================================================
    # 4. LAYOUT & DIMENSÕES
    # ===========================================================================
    Layout               = @{
        MinWidth     = 70       # Aumentei um pouco para dar respiro aos submenus
        MaxWidth     = 0        # 0 = Dinâmico (Expande até o fim da tela 4k/8k)
        MinHeight    = 20
        MaxHeight    = 0       # 0 = Dinâmico
        Margin       = 2
        Padding      = 1
        TitlePadding = 2
        HeaderHeight = 5    # Altura do banner (importante bater com o tamanho da logo)
        FooterHeight = 3
    }

    # ===========================================================================
    # 5. INPUT HANDLING (PS-aware + protocolos modernos)
    # ===========================================================================
    Input                = @{
        PollMs = 30; MenuWrap = $true; DebounceMs = 50
        HoldThresholdMs = 500; RepeatDelayMs = 200; RepeatRateMs = 50
        AltKeyModifier = $true; CtrlKeyModifier = $true; WinKeyModifier = $false
        MouseSupport = "auto"; PasteTimeoutMs = 2000; KeyEscapeTimeoutMs = 100
        Protocol = "CSIu"  # "Legacy", "CSIu", "Kitty"

        KeyMap = @{
            Up = "$([char]27)[A"; Down = "$([char]27)[B"; Right = "$([char]27)[C"; Left = "$([char]27)[D"
            Home = "$([char]27)[H"; End = "$([char]27)[F"; PageUp = "$([char]27)[5~"; PageDown = "$([char]27)[6~"
            Insert = "$([char]27)[2~"; Delete = "$([char]27)[3~"; F1 = "$([char]27)OP"; F2 = "$([char]27)OQ"
            F3 = "$([char]27)OR"; F4 = "$([char]27)OS"; F5 = "$([char]27)[15~"; F6 = "$([char]27)[17~"
            F7 = "$([char]27)[18~"; F8 = "$([char]27)[19~"; F9 = "$([char]27)[20~"; F10 = "$([char]27)[21~"
            F11 = "$([char]27)[23~"; F12 = "$([char]27)[24~"
        }
        VirtualKeyMap = @{
            38 = "UpArrow"; 40 = "DownArrow"; 37 = "LeftArrow"; 39 = "RightArrow";
            13 = "Enter"; 27 = "Escape"; 32 = "Spacebar"; 8 = "Backspace"; 9 = "Tab";
            46 = "Delete"; 45 = "Insert"; 36 = "Home"; 35 = "End"; 33 = "PageUp"; 34 = "PageDown";
            112 = "F1"; 113 = "F2"; 114 = "F3"; 115 = "F4"; 116 = "F5"; 117 = "F6";
            118 = "F7"; 119 = "F8"; 120 = "F9"; 121 = "F10"; 122 = "F11"; 123 = "F12"
        }
        PSCombos = @{
            Accept = "Enter"; Cancel = "Escape"
            SecondaryAccept = "Spacebar"; SecondaryCancel = "Backspace"
            HistoryPrev = "UpArrow"; HistoryNext = "DownArrow"
            AutoComplete = "Ctrl+Space"; KillLine = "Ctrl+K"
            Undo = "Ctrl+Z"; SearchHistory = "Ctrl+R"
            RunspaceSwitch = "Ctrl+Tab"; QuickExit = "Alt+F4"
        }
    }

    # ===========================================================================
    # 6. FRAME PRESETS
    # ===========================================================================
    Frames               = @{
        Classic    = @{ TL = "╔"; TR = "╗"; BL = "╚"; BR = "╝"; HL = "═"; VL = "║"; ML = "╠"; MR = "╣"; Cross = "╬"; TeeUp = "╩"; TeeDown = "╦"; TeeLeft = "╣"; TeeRight = "╠"; Name = "Classic Double-Line" }
        Rounded    = @{ TL = "╭"; TR = "╮"; BL = "╰"; BR = "╯"; HL = "─"; VL = "│"; ML = "├"; MR = "┤"; Cross = "┼"; TeeUp = "┴"; TeeDown = "┬"; TeeLeft = "┤"; TeeRight = "├"; Name = "Rounded Soft" }
        Minimal    = @{ TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; HL = "─"; VL = "│"; ML = "├"; MR = "┤"; Cross = "┼"; TeeUp = "┴"; TeeDown = "┬"; TeeLeft = "┤"; TeeRight = "├"; Name = "Minimal Single" }
        ASCII      = @{ TL = "+"; TR = "+"; BL = "+"; BR = "+"; HL = "-"; VL = "|"; ML = "+"; MR = "+"; Cross = "+"; TeeUp = "+"; TeeDown = "+"; TeeLeft = "+"; TeeRight = "+"; Name = "ASCII Fallback" }
        Block      = @{ TL = "█"; TR = "█"; BL = "█"; BR = "█"; HL = "█"; VL = "█"; ML = "█"; MR = "█"; Cross = "█"; TeeUp = "█"; TeeDown = "█"; TeeLeft = "█"; TeeRight = "█"; Name = "Block Heavy" }
        Retro      = @{ TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; HL = "─"; VL = "│"; ML = "├"; MR = "┤"; Cross = "┼"; TeeUp = "┴"; TeeDown = "┬"; TeeLeft = "┤"; TeeRight = "├"; Name = "Retro Terminal" }
        Cyber      = @{ TL = "┏"; TR = "┓"; BL = "┗"; BR = "┛"; HL = "━"; VL = "┃"; ML = "┣"; MR = "┫"; Cross = "╋"; TeeUp = "┻"; TeeDown = "┳"; TeeLeft = "┫"; TeeRight = "┣"; Name = "Cyberpunk" }
        Heavy      = @{ TL = "┏"; TR = "┓"; BL = "┗"; BR = "┛"; HL = "━"; VL = "┃"; ML = "┣"; MR = "┫"; Cross = "╋"; TeeUp = "┻"; TeeDown = "┳"; TeeLeft = "┫"; TeeRight = "┣"; Name = "Heavy Box" }
        Dotted     = @{ TL = "."; TR = "."; BL = "."; BR = "."; HL = "·"; VL = ":"; ML = ":"; MR = ":"; Cross = "+"; TeeUp = "+"; TeeDown = "+"; TeeLeft = "+"; TeeRight = "+"; Name = "Dotted" }
        Borderless = @{ TL = " "; TR = " "; BL = " "; BR = " "; HL = " "; VL = " "; ML = " "; MR = " "; Cross = " "; TeeUp = " "; TeeDown = " "; TeeLeft = " "; TeeRight = " "; Name = "Borderless" }
        PowerShell = @{ TL = ">"; TR = "<"; BL = "<"; BR = ">"; HL = "~"; VL = "|"; ML = "|"; MR = "|"; Cross = "|"; TeeUp = "|"; TeeDown = "|"; TeeLeft = "|"; TeeRight = "|"; Name = "PowerShell Prompt" }
    }

    # ===========================================================================
    # 7. PROGRESS / SPINNERS
    # ===========================================================================
    Progress             = @{
        Default  = @{ FullChar = "█"; EmptyChar = "░"; ErrorChar = "▒"; Width = 40; ShowPercent = $true; ShowLabel = $true; ShowETA = $false }
        Compact  = @{ FullChar = "="; EmptyChar = "-"; ErrorChar = "X"; Width = 20; ShowPercent = $false; ShowLabel = $false; ShowETA = $false }
        BarOnly  = @{ FullChar = "■"; EmptyChar = "□"; ErrorChar = "!"; Width = 50; ShowPercent = $false; ShowLabel = $true; ShowETA = $true }
        Discrete = @{ FullChar = "●"; EmptyChar = "○"; ErrorChar = "⊗"; Width = 10; ShowPercent = $true; ShowLabel = $true; ShowETA = $false }
        Braille  = @{ Frames = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"); IntervalMs = 80 }
        Line     = @{ Frames = @("/", "-", "\\", "|"); IntervalMs = 120 }
        Dot      = @{ Frames = @(" . ", " ..", "...", ".. ", ".  "); IntervalMs = 150 }
        Blocks   = @{ Frames = @("▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"); IntervalMs = 60 }
    }

    # ===========================================================================
    # 8. STATUS BAR / MENU / TOOLTIP / HELP
    # ===========================================================================
    StatusBar            = @{
        Items = @(
            @{ Name = "Time"; Format = "HH:mm:ss"; Alignment = "Right" }
            @{ Name = "GitBranch"; Format = "{branch}"; Alignment = "Left"; Fallback = "(none)" }
            @{ Name = "ExecutionPolicy"; Format = "{policy}"; Alignment = "Left"; Default = "Unrestricted" }
            @{ Name = "RunspaceID"; Format = "RS:{id}"; Alignment = "Right"; Default = "Main" }
            @{ Name = "Memory"; Format = "{used}/{total}"; Alignment = "Right" }
            @{ Name = "Mode"; Alignment = "Left"; Default = "NORMAL" }
        )
        Separator = " │ "; ShowBackground = $true; BackgroundColor = "Base.Dark.Surface"
        MaxItems = 6; HideWhenNarrow = $true; MinWidthForFull = 80
    }
    Menu                 = @{
        IndentStep = 2; ShowShortcuts = $true; ShowIcons = $true
        HighlightSelected = "Bold"; SeparatorChar = "─"; SubmenuIndicator = "▶"
        BackIndicator = "◀"; CloseOnSelect = $true; BreadcrumbSep = " / "; MaxDepth = 4
    }
    Tooltip              = @{
        DelayMs = 500; FadeInMs = 100; MaxWidth = 60; BorderStyle = "Rounded"
        AutoPosition = $true; Shadow = $true; ShowHotkey = $true; RichText = $true
        FollowMouse = $false; OffsetX = 5; OffsetY = 1
    }
    Help                 = @{
        F1Key = $true; ContextSensitive = $true; DefaultPage = "welcome"
        Style = "fullscreen"; Colors = @{ Title = "Base.Cyan"; Section = "Base.Green"; Key = "Base.Yellow"; Description = "Base.White" }
        BreadcrumbSep = " > "; SearchHint = "Press / to search"
    }

    # ===========================================================================
    # 9. SCROLLBAR / MODAL / SOUND / RESIZE
    # ===========================================================================
    ScrollBar            = @{
        TrackChar = "░"; ThumbChar = "█"; Width = 1; HideWhenFull = $true
        Position = "right"; Style = "modern"; ArrowUp = "▲"; ArrowDown = "▼"
        ShowArrows = $false
    }
    Modal                = @{
        BackgroundOpacity = 0.8; CloseOnEsc = $true; CloseOnOutside = $false
        ShadowBlur = 0; BorderStyle = "Heavy"; Animate = $true
        AnimationType = "fade"; CenterVertically = $true; CenterHorizontally = $true
    }
    Sound                = @{
        Enabled = $false; Events = @{ Error = "beep"; Warning = "beep"; Success = "none"; Click = "none" }
        BeepDurationMs = 200; BeepFrequencyHz = 800
    }
    Resize               = @{
        Enabled = $true; MinWidth = 40; MinHeight = 10
        MaxWidth = 0; MaxHeight = 0; AutoFit = $true
        PreserveAspect = $false; NotifyEvent = $true
    }

    # ===========================================================================
    # 10. REDACTION / CAPABILITIES / DEFAULTS
    # ===========================================================================
    Redaction            = @{
        Enabled  = $true
        Patterns = @(
            @{ Regex = 'api[_-]?key\s*=\s*[\w]+'; Replace = 'api_key=***' }
            @{ Regex = 'token\s*=\s*[\w-]+'; Replace = 'token=***' }
            @{ Regex = 'password\s*=\s*\S+'; Replace = 'password=***' }
            @{ Regex = '[A-F0-9]{32,}'; Replace = '<HASH_REDACTED>' }
        )
        MaskChar = "*"
    }
    TerminalCapabilities = @{
        # Valores padrão das capacidades (serão sobrescritos pelas toggles do usuário)
        TrueColor       = $true
        Hyperlinks      = $true
        BracketedPaste  = $true
        MouseTracking   = $true
        AlternateScreen = $true
        FocusEvents     = $true
        KittyKeyboard   = $false
        SixelGraphics   = $false
        CSIuKeyboard    = $true
        Fallback256     = $true
        Fallback16      = $true
    }
    Defaults             = @{
        FrameStyle         = "Classic"
        AnimationEnabled   = $true
        ColorMode          = "TrueColor"      # mantido para compatibilidade, mas será derivado de TrueColor capability
        ShowHints          = $true
        CompactMode        = $false
        ThemePersistence   = $true
        MouseSupport       = $true
        SoundEnabled       = $false
        Locale             = "en-US"
        TimeFormat         = "HH:mm:ss"
        DateFormat         = "yyyy-MM-dd"
        NumericFormat      = "N0"
        MemoryFormat       = "Auto"
        DecimalSeparator   = "."
        ThousandsSeparator = ","
        ThemeProfile       = "PowerShell"
        SmallLogoVariant   = "Compact"
        StatusBarVisible   = $true
        AutoGitStatus      = $true
        OSC8Hyperlinks     = $true
        PromptIntegration  = $true
    }

    # ===========================================================================
    # 11. CYCLE LISTS (para opções com mais de dois estados)
    # ===========================================================================
    CycleLists           = @{
        I18N          = @('en-US', 'pt-BR')
        EngineMode    = @('EFFICIENCY', 'REDUNDANCY')
        ColorMode     = @('TrueColor', 'ANSI16')
        IconLevel     = @(0, 1, 2)
        FrameStyle    = @('Classic', 'Rounded', 'Minimal', 'ASCII', 'Block', 'Retro', 'Cyber', 'Heavy', 'Dotted', 'Borderless', 'PowerShell')
        ProgressStyle = @('Default', 'Compact', 'BarOnly', 'Discrete', 'Braille', 'Line', 'Dot', 'Blocks')
        ThemePersona  = @('Cyber', 'Corporate', 'Hacker', 'Minimal', 'Retro', 'HighVis', 'PowerShell')
        ThemeColor    = @(
            'Blue', 'Green', 'Cyan', 'Magenta', 'Yellow', 'Red', 'Black', 'White',
            'Gray', 'Purple', 'Orange', 'Teal', 'Pink', 'Brown', 'Lime', 'Indigo',
            'Navy', 'Violet', 'Gold', 'Silver', 'Bronze',
            'Amber', 'Dim', 'Coral', 'Salmon', 'Lavender', 'Mint'
        )
        RC_MT         = @(1, 2, 4, 8, 16, 32, 64, 128)
        RC_R          = @(0, 1, 3, 5, 10)
        RC_W          = @(0, 1, 5, 10, 30)
    }

    # ===========================================================================
    # 12. TOGGLE LISTS (opções binárias: ativo/inativo)
    # ===========================================================================
    ToggleLists          = @{
        # Flags do Robocopy (booleanas)
        RC_E                = $true
        RC_ZB               = $true
        RC_M                = $false
        RC_B                = $true
        RC_COPYALL          = $true
        RC_DCOPY_T          = $true
        RC_NP               = $false
        RC_FFT              = $false
        RC_XO               = $false
        RC_XN               = $false
        RC_XJ               = $true
        RC_L                = $false
        RC_V                = $false

        # Terminal Capabilities
        CAP_TRUECOLOR       = $true
        CAP_HYPERLINKS      = $true
        CAP_BRACKETEDPASTE  = $true
        CAP_MOUSETRACKING   = $true
        CAP_ALTERNATESCREEN = $true
        CAP_FOCUSEVENTS     = $true
        CAP_KITTYKEYBOARD   = $false
        CAP_SIXELGRAPHICS   = $false
        CAP_CSIUKEYBOARD    = $true
        CAP_FALLBACK256     = $true
        CAP_FALLBACK16      = $true
    }

    # ===========================================================================
    # 13. ICONS & SYMBOLS (Hierarquia: [0] Graphic, [1] Solid Unicode, [2] ASCII)
    # ===========================================================================
    Labels               = @{
        IconLevels = @('Graphic', 'Unicode', 'ASCII')
    }
    Icons                = @{
        # --- Status ---
        Success           = @("✅", "✔", "[OK]")
        Failure           = @("❌", "✖", "[ERR]")
        Warning           = @("⚠️", "⚠", "[!]")
        Info              = @("ℹ️", "ℹ", "[i]")
        Question          = @("❓", "⁇", "[?]")
        Checkmark         = @("✔️", "✓", "[V]")
        Crossmark         = @("❎", "✗", "[X]")
        Ellipsis          = @("…", "…", "...")
        Bullet            = @("•", "∙", "*")
        Separator         = @("─", "─", "-")

        # --- Colored status dots ---
        DotRed            = @("🔴", "●", "[!]")
        DotGreen          = @("🟢", "●", "[OK]")
        DotYellow         = @("🟡", "●", "[~]")
        DotBlue           = @("🔵", "●", "[i]")
        DotCyan           = @("🔷", "◆", "[*]")
        DotMagenta        = @("🟣", "●", "[★]")
        DotWhite          = @("⚪", "○", "[ ]")
        DotGray           = @("⚫", "●", "[•]")

        # --- Status badges ---
        BadgeNew          = @("🆕", "⊞", "[NEW]")
        BadgeUpdated      = @("🔄", "⟳", "[UPD]")
        BadgeHot          = @("🔥", "⚠", "[HOT]")
        BadgeCold         = @("❄️", "❄", "[CLD]")
        BadgeLock         = @("🔐", "☗", "[LCK]")
        BadgeUnlock       = @("🔓", "☖", "[OPN]")

        # ===========================================================================
        # NAVIGATION & DIRECTIONAL
        # ===========================================================================
        ArrowUp           = @("⬆️", "↑", "[^]")
        ArrowDown         = @("⬇️", "↓", "[v]")
        ArrowLeft         = @("⬅️", "←", "[<]")
        ArrowRight        = @("➡️", "→", "[>]")
        ArrowDoubleUp     = @("⬆⬆", "⇈", "[^^]")
        ArrowDoubleDown   = @("⬇⬇", "⇊", "[vv]")
        ArrowDoubleLeft   = @("⬅⬅", "⇇", "[<<]")
        ArrowDoubleRight  = @("➡➡", "⇉", "[>>]")

        CaretUp           = @("▲", "▲", "[^]")
        CaretDown         = @("▼", "▼", "[v]")
        CaretLeft         = @("◀", "◀", "[<]")
        CaretRight        = @("▶", "▶", "[>]")
        CaretSmallUp      = @("▴", "▵", "[^]")
        CaretSmallDown    = @("▾", "▿", "[v]")
        CaretSmallLeft    = @("◂", "◃", "[<]")
        CaretSmallRight   = @("▸", "▹", "[>]")

        Compass           = @("🧭", "▣", "[R]")
        CompassN          = @("🧭N", "◧", "[N]")
        CompassS          = @("🧭S", "◨", "[S]")
        CompassE          = @("🧭E", "◩", "[E]")
        CompassW          = @("🧭W", "◪", "[W]")

        Home              = @("🏠", "⌂", "[H]")
        End               = @("🏁", "⚑", "[E]")
        Jump              = @("⤴️", "↱", "[J]")
        Return            = @("↩️", "↵", "[RET]")

        # ===========================================================================
        # UI CONTROLS
        # ===========================================================================
        Menu              = @("☰", "≡", "[MENU]")
        Submenu           = @("▸", "▹", "[>]")
        Back              = @("◂", "◃", "[<]")
        Close             = @("✖️", "✕", "[X]")
        Minimize          = @("🗕", "—", "[_]")
        Maximize          = @("🗖", "□", "[#]")
        Normalize         = @("🗗", "▣", "[O]")
        Help              = @("❔", "⁇", "[?]")

        WindowTile        = @("🪟", "⊞", "[TILE]")
        WindowSplitH      = @("⇹", "⬌", "[SPLITH]")
        WindowSplitV      = @("⤢", "⇕", "[SPLITV]")
        WindowFull        = @("⛶", "⎔", "[FULL]")

        TabNew            = @("🗐", "⊞", "[+TAB]")
        TabClose          = @("🗙", "⊠", "[X]")
        TabNext           = @("➡️", "⇨", "[NEXT]")
        TabPrev           = @("⬅️", "⇦", "[PREV]")
        FocusIn           = @("🔍", "⊕", "[IN]")
        FocusOut          = @("🔎", "⊖", "[OUT]")

        # ===========================================================================
        # FORMS & INPUT
        # ===========================================================================
        CheckboxOn        = @("☑️", "☑", "[X]")
        CheckboxOff       = @("☐", "☐", "[ ]")
        CheckboxHalf      = @("☑", "◫", "[~]")

        RadioOn           = @("🔘", "◉", "(O)")
        RadioOff          = @("⚪", "○", "( )")

        SliderStart       = @("🔹", "⊢", "[o]")
        SliderMid         = @("─", "—", "[-]")
        SliderEnd         = @("🔸", "⊣", "[●]")
        SliderHandle      = @("🔶", "◈", "[H]")

        InputText         = @("📝", "▤", "[TXT]")
        InputNumber       = @("🔢", "#", "[NUM]")
        InputDate         = @("📅", "◪", "[DATE]")
        InputEmail        = @("📧", "✉", "[EMAIL]")
        InputPassword     = @("🔑", "⚷", "[PWD]")

        Dropdown          = @("🔽", "▿", "[▼]")
        Listbox           = @("📋", "▤", "[LIST]")
        Combobox          = @("🗂️", "⊟", "[COMBO]")

        # ===========================================================================
        # SYSTEM & HARDWARE
        # ===========================================================================
        Folder            = @("📁", "◫", "[DIR]")
        FolderOpen        = @("📂", "◪", "[OPN]")
        FolderSync        = @("📁🔄", "◫⟳", "[SYNCDIR]")

        File              = @("📄", "▤", "[FILE]")
        FileCode          = @("📜", "⌨", "[CODE]")
        FileConfig        = @("⚙️📄", "⚙", "[CFG]")
        FileLog           = @("📜", "≡", "[LOG]")
        FileTemp          = @("🗑️📄", "⌫", "[TMP]")
        FileArchive       = @("🗜️", "⊞", "[ZIP]")
        FileExec          = @("⚡", "↯", "[EXE]")

        Database          = @("🗄️", "☖", "[DB]")
        DatabaseSync      = @("🗄️🔄", "☖⟳", "[DBSYNC]")

        Network           = @("🌐", "⎈", "[NET]")
        NetworkWired      = @("🔌", "☍", "[ETH]")
        NetworkWireless   = @("📶", "⍋", "[WIFI]")
        NetworkCloud      = @("☁️", "☈", "[CLD]")
        NetworkLocal      = @("🏠", "⌂", "[LAN]")

        Disk              = @("💾", "▣", "[DISK]")
        DiskSSD           = @("⚡💾", "↯▣", "[SSD]")
        DiskHDD           = @("🌀", "⌾", "[HDD]")
        DiskUSB           = @("🔌", "☍", "[USB]")
        DiskNetwork       = @("🌐💾", "⎈▣", "[NAS]")

        Memory            = @("🧠", "☷", "[RAM]")
        Chip              = @("🔲", "▦", "[CHIP]")
        CPU               = @("⚙️", "⚙", "[CPU]")
        GPU               = @("🎮", "⊞", "[GPU]")

        Clock             = @("⏱️", "◴", "[TIME]")
        Calendar          = @("📅", "◪", "[DATE]")
        Timer             = @("⏲️", "◵", "[TMR]")
        Stopwatch         = @("⏱️", "◶", "[STOP]")

        Lock              = @("🔒", "☗", "[LCK]")
        Unlock            = @("🔓", "☖", "[OPN]")
        Key               = @("🔑", "⚷", "[KEY]")
        KeyPair           = @("🔐", "⚷⚷", "[PAIR]")
        Certificate       = @("📜🔐", "⣖", "[CERT]")

        User              = @("👤", "☻", "[USR]")
        Users             = @("👥", "☻☻", "[GRP]")
        Admin             = @("👑", "♔", "[ADM]")
        Guest             = @("🎭", "☺", "[GST]")
        Service           = @("⚙️👤", "⚙☻", "[SVC]")

        Settings          = @("⚙️", "⚙", "[SET]")
        Config            = @("🔧", "⤨", "[CFG]")
        Preferences       = @("🎛️", "⎚", "[PREF]")
        Tools             = @("🧰", "⚒", "[TLS]")
        Pickaxe           = @("⛏️", "⛏", "[PCK]")
        Shield            = @("🛡️", "⛨", "[SHD]")

        Search            = @("🔍", "⌕", "[FND]")
        Filter            = @("🔽", "◂", "[FLT]")
        SortAsc           = @("🔼", "▵", "[ASC]")
        SortDesc          = @("🔽", "▿", "[DESC]")
        GroupBy           = @("🗂️", "⊟", "[GRP]")

        Refresh           = @("🔄", "⟲", "[RFR]")
        Sync              = @("🔁", "⇌", "[SYNC]")
        Update            = @("⬆️", "⇡", "[UPD]")
        Upgrade           = @("🚀", "⇈", "[UPG]")

        Power             = @("⏻", "⌽", "[PWR]")
        BatteryFull       = @("🔋", "▮", "[FULL]")
        BatteryHalf       = @("🪫", "▯", "[HALF]")
        BatteryLow        = @("🪫⚠️", "▯⚠", "[LOW]")
        Charging          = @("🔌🔋", "⚡▮", "[CHG]")

        SignalFull        = @("📶📶📶📶", "⦀", "[MAX]")
        SignalHalf        = @("📶📶", "‖", "[MED]")
        SignalLow         = @("📶", "∣", "[LOW]")
        SignalNone        = @("📵", "⦰", "[NONE]")

        # ===========================================================================
        # ACTIONS & OPERATIONS
        # ===========================================================================
        Play              = @("▶️", "►", "[>]")
        Pause             = @("⏸️", "‖", "[||]")
        Stop              = @("⏹️", "■", "[STOP]")
        Record            = @("⏺️", "●", "[REC]")
        Eject             = @("⏏️", "⏏", "[EJT]")
        Next              = @("⏭️", "⏭", "[>>]")
        Prev              = @("⏮️", "⏮", "[<<]")
        Shuffle           = @("🔀", "⤮", "[SHF]")
        Repeat            = @("🔁", "⟳", "[RPT]")

        VolumeMax         = @("🔊", "◧", "[MAX]")
        VolumeMed         = @("🔉", "◨", "[MED]")
        VolumeMin         = @("🔈", "◩", "[MIN]")
        Mute              = @("🔇", "⦰", "[MUTE]")

        MicOn             = @("🎤", "⚑", "[MIC_ON]")
        MicOff            = @("🎤🚫", "⚑⦰", "[MIC_OFF]")

        CameraOn          = @("📷", "◘", "[CAM_ON]")
        CameraOff         = @("📷🚫", "◘⦰", "[CAM_OFF]")

        Print             = @("🖨️", "⎙", "[PRT]")
        Scan              = @("📠", "⎚", "[SCN]")
        Fax               = @("📠", "⎚", "[FAX]")

        MailSend          = @("📤", "⇡", "[SENT]")
        MailReceive       = @("📥", "⇣", "[INBOX]")
        MailDraft         = @("📝", "▤", "[DRAFT]")
        MailArchive       = @("🗄️📧", "☖✉", "[ARCH]")

        Chat              = @("💬", "▤", "[MSG]")
        Comment           = @("💭", "⌕", "[CMT]")
        Mention           = @("🔖", "@", "[@]")

        Share             = @("🔗", "☍", "[SHR]")
        Link              = @("🔗", "☍", "[LNK]")
        Unlink            = @("🔗✂️", "☍✄", "[UNLK]")

        Copy              = @("📋", "⎘", "[CPY]")
        Cut               = @("✂️", "✄", "[CUT]")
        Paste             = @("📌", "⌖", "[PST]")
        Clone             = @("👥📋", "☻⎘", "[CLN]")

        Save              = @("💾", "▣", "[SAV]")
        SaveAs            = @("💾✏️", "▣✎", "[SAVAS]")
        Load              = @("📂", "◪", "[LOAD]")
        Import            = @("📥", "⇊", "[IMP]")
        Export            = @("📤", "⇈", "[EXP]")

        New               = @("🆕", "⊞", "[NEW]")
        Open              = @("📂", "◪", "[OPEN]")
        Edit              = @("✏️", "✎", "[EDIT]")
        Delete            = @("🗑️", "⌫", "[DEL]")
        Trash             = @("🗑️", "⌫", "[TRSH]")
        Restore           = @("🔄🗑️", "⟲⌫", "[RST]")
        Undo              = @("↩️", "↶", "[UNDO]")
        Redo              = @("↪️", "↷", "[REDO]")

        Run               = @("🚀", "»", "[RUN]")
        Execute           = @("⚡", "↯", "[EXEC]")
        Build             = @("🔨", "⚒", "[BLD]")
        Deploy            = @("🚢", "⇈", "[DEP]")
        Test              = @("🧪", "⚗", "[TST]")
        Debug             = @("🐛", "⯐", "[DBG]")

        Upload            = @("⬆️📤", "⇡", "[UPL]")
        Download          = @("⬇️📥", "⇣", "[DWN]")

        Install           = @("💿", "⊞⇣", "[INS]")
        Installer         = @("📀", "⊞⇣", "[INS]")
        Uninstall         = @("💽", "⊠⇡", "[RMV]")
        Package           = @("📦", "⊞", "[PKG]")
        Module            = @("🧩", "⎈", "[MOD]")

        # ===========================================================================
        # VISUAL & DECORATIVE
        # ===========================================================================
        StarEmpty         = @("☆", "☆", "[ ]")
        StarHalf          = @("★", "⯨", "[*]")
        StarFull          = @("⭐", "★", "[★]")

        HeartEmpty        = @("♡", "♡", "[ ]")
        HeartFull         = @("❤️", "♥", "[♥]")

        Flag              = @("🚩", "⚑", "[FLG]")
        Bookmark          = @("🔖", "◫", "[BMK]")
        Tag               = @("🏷️", "⌂", "[TAG]")
        Label             = @("🏷️", "⌂", "[LBL]")

        Trophy            = @("🏆", "⛨", "[WIN]")
        Medal             = @("🎖️", "⚑", "[MED]")
        Crown             = @("👑", "♔", "[CRN]")

        Sparkle           = @("✨", "⁂", "[*]")
        Fire              = @("🔥", "⚠", "[FIRE]")
        Lightning         = @("⚡", "↯", "[LTN]")
        Snowflake         = @("❄️", "❄", "[SNOW]")
        Drop              = @("💧", "⌆", "[DROP]")
        Sun               = @("☀️", "☼", "[SUN]")
        Moon              = @("🌙", "☽", "[MON]")
        Cloud             = @("☁️", "☁", "[CLD]")
        Rainbow           = @("🌈", "◮", "[RBW]")
        Palette           = @("🎨", "☱", "[THM]")

        SepDot            = @("・", "·", "[.]")
        SepDash           = @("─", "─", "[-]")
        SepDouble         = @("═", "═", "[=]")
        SepWave           = @("〜", "≈", "[~]")
        SepArrow          = @("⟶", "→", "[->]")
        SepChevron        = @("»", "»", "[>]")

        BoxTL             = @("╭", "┌", "[TL]")
        BoxTR             = @("╮", "┐", "[TR]")
        BoxBL             = @("╰", "└", "[BL]")
        BoxBR             = @("╯", "┘", "[BR]")
        BoxH              = @("─", "─", "[H]")
        BoxV              = @("│", "│", "[V]")
        BoxCross          = @("┼", "┼", "[+]")

        # ===========================================================================
        # POWERSHELL NATIVE
        # ===========================================================================
        PSPrompt          = @("PS>", "PS>", "[PS]")
        PSFunction        = @("⚙️", "ƒ", "[FN]")
        PSFunctionPrivate = @("🔒⚙️", "☗ƒ", "[PRVF]")
        PSFunctionPublic  = @("🔓⚙️", "☖ƒ", "[PUBF]")

        PSVariable        = @("$", "$", "[VAR]")
        PSVariableConst   = @("🔒$", "☗$", "[CVAR]")
        PSVariableEnv     = @("🌍$", "⌾$", "[EVAR]")

        PSModule          = @("🧩", "⊞", "[MOD]")
        PSModuleCore      = @("💠", "◈", "[CORE]")
        PSModuleScript    = @("📜", "≡", "[SCR]")

        PSClass           = @("🏗️", "⌂", "[CLS]")
        PSEnum            = @("📋", "▤", "[ENUM]")

        PSRunspace        = @("🧵", "≎", "[RS]")
        PSJob             = @("📬", "✉", "[JOB]")
        PSJobRunning      = @("🟢📬", "▶✉", "[RUN]")
        PSJobStopped      = @("🔴📬", "■✉", "[STOP]")

        PSPipeline        = @("⚙️➡️⚙️", "|", "[PIPE]")
        PSOutput          = @("📤", "⇈", "[OUT]")
        PSInput           = @("📥", "⇊", "[IN]")

        PSProfile         = @("👤⚙️", "☻⚙", "[PROF]")
        PSHistory         = @("📜⏪", "↶", "[HIST]")
        PSAlias           = @("🏷️", "⌂", "[ALIAS]")

        PSDebug           = @("🐛", "⯐", "[DBG]")
        PSVerbose         = @("🗣️", "⚑", "[VB]")
        PSWarning         = @("⚠️", "⚠", "[WRN]")
        PSError           = @("❌", "✖", "[ERR]")

        PSGet             = @("📥", "⇊", "[GET]")
        PSSet             = @("📤", "⇈", "[SET]")
        PSNew             = @("🆕", "⊞", "[NEW]")
        PSRemove          = @("🗑️", "⌫", "[RM]")
        PSClear           = @("🧹", "⌧", "[CLR]")

        PSImport          = @("📦➡️", "⊞→", "[IMP]")
        PSExport          = @("➡️📦", "→⊞", "[EXP]")

        PSHelp            = @("❔", "⁇", "[?]")
        PSAbout           = @("ℹ️", "ℹ", "[i]")

        # ===========================================================================
        # MISC & FALLBACKS
        # ===========================================================================
        Unknown           = @("❓", "⁇", "[?]")
        Placeholder       = @("□", "□", "[ ]")
        Loading           = @("⏳", "⧖", "[...]")
        Processing        = @("⚙️", "⚙", "[PROC]")
        Waiting           = @("🕐", "◷", "[WAIT]")
        Idle              = @("😴", "⌾", "[IDLE]")
        Ready             = @("✅", "✔", "[READY]")

        # Emergency fallbacks
        FallbackIcon      = "•"
        FallbackText      = "[?]"
    }

    # ===========================================================================
    # 14. SEMANTIC MAPPING (Icon = Action)
    # ===========================================================================
    SemanticMap          = @{
        # ===========================================================================
        # NÚCLEO & TAREFAS PRINCIPAIS
        # ===========================================================================
        "SCAN"               = "Search"
        "PARSING"            = "Database"
        "ARCHAEOLOGY"        = "Pickaxe"
        "HARVESTER"          = "Package"
        "FORENSICS"          = "Shield"
        "SETTINGS"           = "Settings"
        "LOGISTICS"          = "Network"
        "LABORATORY"         = "Chip"
        "EXIT"               = "Power"
        "HOME"               = "Home"
        "DASHBOARD"          = "Menu"
        "OVERVIEW"           = "Info"
        "STATUS"             = "Info"
        "ABOUT"              = "Help"
        "HELP"               = "Help"
        "DOCS"               = "Help"
        "SUPPORT"            = "Chat"
        "FEEDBACK"           = "Comment"

        # ===========================================================================
        # NAVEGAÇÃO & CONTROLE DE FLUXO
        # ===========================================================================
        "RETURN"             = "Back"
        "CANCEL"             = "Close"
        "CLOSE"              = "Close"
        "AUTO"               = "Target"
        "UNMOUNT"            = "Eject"
        "DELETE"             = "Trash"
        "REMOVE"             = "Trash"
        "FOLDER"             = "Folder"
        "DIRECTORY"          = "Folder"
        "DIR"                = "Folder"
        "FILE"               = "File"
        "OPEN"               = "FolderOpen"
        "BROWSE"             = "Search"
        "NAVIGATE"           = "Compass"
        "UP"                 = "ArrowUp"
        "DOWN"               = "ArrowDown"
        "LEFT"               = "ArrowLeft"
        "RIGHT"              = "ArrowRight"
        "NEXT"               = "Next"
        "PREV"               = "Prev"
        "PREVIOUS"           = "Prev"
        "FIRST"              = "Home"
        "LAST"               = "End"
        "JUMP"               = "Jump"
        "GOTO"               = "Jump"

        # ===========================================================================
        # OPERAÇÕES DE ARQUIVO & SISTEMA
        # ===========================================================================
        "NEW"                = "New"
        "CREATE"             = "New"
        "SAVE"               = "Save"
        "SAVE_AS"            = "SaveAs"
        "LOAD"               = "Load"
        "IMPORT"             = "Import"
        "EXPORT"             = "Export"
        "COPY"               = "Copy"
        "CUT"                = "Cut"
        "PASTE"              = "Paste"
        "CLONE"              = "Clone"
        "DUPLICATE"          = "Clone"
        "RENAME"             = "Edit"
        "EDIT"               = "Edit"
        "MODIFY"             = "Edit"
        "UPDATE"             = "Update"
        "REFRESH"            = "Refresh"
        "RELOAD"             = "Refresh"
        "SYNC"               = "Sync"
        "SYNCHRONIZE"        = "Sync"
        "BACKUP"             = "DatabaseSync"
        "RESTORE"            = "Restore"      # Undelete
        "UNDELETE"           = "Restore"
        "UNTRASH"            = "Restore"
        "NORMALIZE"          = "Normalize"    # Normalize screen size
        "FORMAT"             = "Disk"
        "COMPRESS"           = "FileArchive"
        "DECOMPRESS"         = "FileArchive"
        "ARCHIVE"            = "FileArchive"
        "EXTRACT"            = "FileArchive"

        # ===========================================================================
        # OPERAÇÕES DE DISCO & STORAGE
        # ===========================================================================
        "DISKPART"           = "Disk"
        "CHKDSK"             = "Refresh"
        "WINFR"              = "Save"
        "FSUTIL"             = "Settings"
        "STORDIAG"           = "Bug"
        "VOLUME"             = "Disk"
        "PARTITION"          = "Disk"
        "MOUNT"              = "Disk"
        "DISMOUNT"           = "Eject"
        "DRIVE"              = "Disk"
        "STORAGE"            = "Disk"
        "SSD"                = "DiskSSD"
        "HDD"                = "DiskHDD"
        "USB"                = "DiskUSB"
        "NETWORK_DRIVE"      = "DiskNetwork"
        "NAS"                = "DiskNetwork"

        # ===========================================================================
        # REDE & CONECTIVIDADE
        # ===========================================================================
        "NET_MGR"            = "Network"
        "NETWORK"            = "Network"
        "INTERNET"           = "Network"
        "WIFI"               = "NetworkWireless"
        "ETHERNET"           = "NetworkWired"
        "CONNECT"            = "Link"
        "DISCONNECT"         = "Unlink"
        "PING"               = "Network"
        "TRACEROUTE"         = "Network"
        "DNS"                = "Network"
        "DHCP"               = "Network"
        "FIREWALL"           = "Shield"
        "PROXY"              = "Network"
        "VPN"                = "Lock"
        "SSH"                = "Terminal"
        "FTP"                = "Network"
        "HTTP"               = "Network"
        "API"                = "Network"
        "WEBHOOK"            = "Network"

        # ===========================================================================
        # BANCO DE DADOS & DADOS
        # ===========================================================================
        "DATABASE"           = "Database"
        "DB"                 = "Database"
        "SQL"                = "Database"
        "QUERY"              = "Search"
        "SELECT"             = "Search"
        "INSERT"             = "New"
        "UPDATE_DB"          = "Update"
        "DELETE_DB"          = "Trash"
        "SCHEMA"             = "Database"
        "TABLE"              = "Database"
        "INDEX"              = "Database"
        "MIGRATE"            = "Sync"
        "SEED"               = "Database"
        "ROLLBACK"           = "Undo"

        # ===========================================================================
        # POWERSHELL & SCRIPTING
        # ===========================================================================
        "ENGINE_MODE"        = "Terminal"
        "POWERSHELL"         = "PSPrompt"
        "PS"                 = "PSPrompt"
        "SCRIPT"             = "FileCode"
        "MODULE"             = "PSModule"
        "FUNCTION"           = "PSFunction"
        "CMDLET"             = "PSFunction"
        "VARIABLE"           = "PSVariable"
        "ALIAS"              = "PSAlias"
        "PROFILE"            = "PSProfile"
        "RUNSPACE"           = "PSRunspace"
        "JOB"                = "PSJob"
        "PIPELINE"           = "PSPipeline"
        "EXECUTE"            = "Run"
        "RUN"                = "Run"
        "INVOKE"             = "Run"
        "CALL"               = "Run"
        "TEST"               = "Test"
        "DEBUG"              = "Debug"
        "TRACE"              = "Debug"
        "VERBOSE"            = "PSVerbose"
        "WARNING"            = "PSWarning"
        "ERROR_PS"           = "PSError"

        # ===========================================================================
        # DESENVOLVIMENTO & DEVOPS
        # ===========================================================================
        "BUILD"              = "Build"
        "COMPILE"            = "Build"
        "DEPLOY"             = "Deploy"
        "PUBLISH"            = "Deploy"
        "RELEASE"            = "Deploy"
        "VERSION"            = "Tag"
        "TAG"                = "Tag"
        "BRANCH"             = "Network"
        "COMMIT"             = "Save"
        "PUSH"               = "Upload"
        "PULL"               = "Download"
        "MERGE"              = "Sync"
        "REBASE"             = "Sync"
        "DIFF"               = "Search"
        "LOG"                = "FileLog"
        "CHANGELOG"          = "FileLog"
        "ISSUE"              = "Bug"
        "BUG"                = "Bug"
        "FIX"                = "Checkmark"
        "FEATURE"            = "StarFull"
        "HOTFIX"             = "Fire"
        "PATCH"              = "FileCode"

        # ===========================================================================
        # SEGURANÇA & AUTENTICAÇÃO
        # ===========================================================================
        "AUTH"               = "Key"
        "AUTHENTICATE"       = "Key"
        "LOGIN"              = "User"
        "LOGOUT"             = "Power"
        "SIGN_IN"            = "User"
        "SIGN_OUT"           = "Power"
        "REGISTER"           = "New"
        "PASSWORD"           = "InputPassword"
        "TOKEN"              = "Key"
        "CERTIFICATE"        = "Certificate"
        "ENCRYPT"            = "Lock"
        "DECRYPT"            = "Unlock"
        "HASH"               = "Key"
        "SIGN"               = "Certificate"
        "VERIFY"             = "Checkmark"
        "AUDIT"              = "Shield"
        "PERMISSION"         = "Lock"
        "ROLE"               = "Admin"
        "ADMIN"              = "Admin"
        "GUEST"              = "Guest"

        # ===========================================================================
        # UI/UX & INTERFACE
        # ===========================================================================
        "THEME"              = "Palette"
        "LANGUAGE"           = "Chat"
        "LOCALE"             = "Chat"
        "TRANSLATE"          = "Chat"
        "LAYOUT"             = "WindowTile"
        "VIEW"               = "Search"
        "ZOOM_IN"            = "Zoom"
        "ZOOM_OUT"           = "Zoom"
        "FULLSCREEN"         = "WindowFull"
        "MINIMIZE"           = "Minimize"
        "MAXIMIZE"           = "Maximize"
        "TILE"               = "WindowTile"
        "SPLIT"              = "WindowSplitV"
        "TAB"                = "TabNew"
        "PANEL"              = "WindowTile"
        "SIDEBAR"            = "Menu"
        "TOOLBAR"            = "Tools"
        "STATUSBAR"          = "Info"
        "NOTIFICATION"       = "Info"
        "ALERT"              = "Warning"
        "TOOLTIP"            = "Help"
        "MODAL"              = "WindowFull"
        "DIALOG"             = "WindowFull"

        # ===========================================================================
        # AÇÕES DE EDIÇÃO & HISTÓRICO
        # ===========================================================================
        "UNDO"               = "Undo"
        "REDO"               = "Redo"
        "REVERT"             = "Undo"
        "RESET"              = "Refresh"
        "CLEAR"              = "PSClear"
        "ERASE"              = "Trash"
        "SELECT_ALL"         = "Checkmark"
        "DESELECT"           = "Crossmark"
        "FIND"               = "Search"
        "REPLACE"            = "Edit"
        "HIGHLIGHT"          = "StarFull"
        "BOOKMARK"           = "Bookmark"
        "FAVORITE"           = "HeartFull"
        "STAR"               = "StarFull"
        "PIN"                = "Bookmark"
        "UNPIN"              = "Bookmark"

        # ===========================================================================
        # MÍDIA & MULTIMÍDIA
        # ===========================================================================
        "PLAY"               = "Play"
        "PAUSE"              = "Pause"
        "STOP"               = "Stop"
        "RECORD"             = "Record"
        "EJECT_MEDIA"        = "Eject"
        "VOLUME_UP"          = "VolumeMax"
        "VOLUME_DOWN"        = "VolumeMin"
        "MUTE"               = "Mute"
        "MIC"                = "MicOn"
        "CAMERA"             = "CameraOn"
        "SCREENSHOT"         = "CameraOn"
        "CAPTURE"            = "CameraOn"
        "IMAGE"              = "File"
        "VIDEO"              = "File"
        "AUDIO"              = "File"
        "DOCUMENT"           = "File"
        "PDF"                = "FileCode"

        # ===========================================================================
        # FERRAMENTAS & UTILITÁRIOS ESPECÍFICOS
        # ===========================================================================
        "SYNC_START"         = "Play"
        "TAG_PREPARE"        = "Tag"
        "ROBO_CFG"           = "Edit"
        "DEFAULT_OUT"        = "Folder"
        "ROBOCOPY"           = "Copy"
        "DISK_MGR"           = "Disk"
        "REGISTRY"           = "Settings"
        "SERVICES"           = "Service"
        "PROCESSES"          = "CPU"
        "MEMORY_MGR"         = "Memory"
        "EVENT_LOG"          = "FileLog"
        "TASK_SCHEDULER"     = "Calendar"
        "POWER_SHELL"        = "Terminal"

        # ===========================================================================
        # ESTADOS & INDICADORES
        # ===========================================================================
        "READY"              = "Ready"
        "IDLE"               = "Idle"
        "BUSY"               = "Processing"
        "LOADING"            = "Loading"
        "WAITING"            = "Waiting"
        "SUCCESS"            = "Success"
        "OK"                 = "Success"
        "DONE"               = "Success"
        "COMPLETE"           = "Success"
        "FAILED"             = "Failure"
        "ERROR"              = "Failure"
        "WARNING_STATE"      = "Warning"
        "PENDING"            = "Waiting"
        "QUEUED"             = "Waiting"
        "RUNNING"            = "Play"
        "STOPPED"            = "Stop"
        "PAUSED_STATE"       = "Pause"
        "ENABLED"            = "CheckboxOn"
        "DISABLED"           = "CheckboxOff"
        "ACTIVE"             = "DotGreen"
        "INACTIVE"           = "DotGray"
        "ONLINE"             = "DotGreen"
        "OFFLINE"            = "DotRed"
        "AVAILABLE"          = "DotGreen"
        "UNAVAILABLE"        = "DotRed"

        # ===========================================================================
        # OPERAÇÕES EM LOTE & AUTOMAÇÃO
        # ===========================================================================
        "BATCH"              = "Package"
        "BULK"               = "Package"
        "MASS"               = "Package"
        "AUTOMATE"           = "Play"
        "SCHEDULE"           = "Calendar"
        "CRON"               = "Calendar"
        "TRIGGER"            = "Lightning"
        "WEBHOOK_TRIGGER"    = "Network"
        "EVENT"              = "Sparkle"
        "REACT"              = "Sparkle"
        "CHAIN"              = "Link"
        "WORKFLOW"           = "PSPipeline"
        "PIPELINE_OP"        = "PSPipeline"

        # ===========================================================================
        # UTILITÁRIOS GERAIS (Fallbacks inteligentes)
        # ===========================================================================
        "UNKNOWN"            = "Unknown"
        "DEFAULT"            = "Placeholder"
        "GENERIC"            = "Placeholder"
        "MISC"               = "Placeholder"
        "OTHER"              = "Placeholder"
        "MORE"               = "Ellipsis"
        "OPTIONS"            = "Menu"
        "ACTIONS"            = "Tools"
        "TOOLS"              = "Tools"
        "UTILS"              = "Tools"
        "ADVANCED"           = "Settings"
        "EXPERT"             = "Admin"
        "BASIC"              = "User"
        "SIMPLE"             = "Checkmark"
        "QUICK"              = "Lightning"
        "FAST"               = "Lightning"
        "SLOW"               = "Timer"
        "PRECISE"            = "Target"
        "APPROXIMATE"        = "Target"

        # ===========================================================================
        # DEPLOYER & FORGE SEMANTICS (O lugar correto para o mapeamento visual)
        # ===========================================================================
        "INIT_SYSTEM"        = "Lightning"
        "FORGE_ORCHESTRATOR" = "Tools"
        "BUILD_MONOLITH"     = "PSPipeline"
        "BUILD_EXE_PORTABLE" = "Package"
        "BUILD_EXE_SETUP"    = "Install"
        "BUILD_MSI"          = "Install"
    }
}
