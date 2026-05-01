@{
    Segment = @{
        Name        = "ui"
        Version     = "1.0.0"
        Description = "VT100/ANSI reference, layout constants, input protocols, frame presets, progress engines, window management & PowerShell TUI extensions"
        Dependencies = @("core", "theme")
        HashSHA256  = "PLACEHOLDER_UI_HASH"
    }

    # ===========================================================================
    # 1. ANSI / VT100 REFERENCE COMPLETO
    # ===========================================================================
    ANSI = @{
        SGR = @{
            Reset            = "`e[0m"; Bold             = "`e[1m"; Dim              = "`e[2m"
            Italic           = "`e[3m"; Underline        = "`e[4m"; SlowBlink        = "`e[5m"
            RapidBlink       = "`e[6m"; Invert           = "`e[7m"; Hidden           = "`e[8m"
            Strike           = "`e[9m"; DefaultFont      = "`e[10m"; Fraktur         = "`e[20m"
            DoublyUnderline  = "`e[21m"; NoBlink         = "`e[25m"; NoInvert        = "`e[27m"
            NoHidden         = "`e[28m"; NoStrike        = "`e[29m"; ForegroundReset = "`e[39m"
            BackgroundReset  = "`e[49m"
        }
        FG = @{
            Black      = "`e[30m"; Red     = "`e[31m"; Green   = "`e[32m"
            Yellow     = "`e[33m"; Blue    = "`e[34m"; Magenta = "`e[35m"
            Cyan       = "`e[36m"; White   = "`e[37m"; Default = "`e[39m"
            BrightBlack  = "`e[90m"; BrightRed    = "`e[91m"
            BrightGreen  = "`e[92m"; BrightYellow = "`e[93m"
            BrightBlue   = "`e[94m"; BrightMagenta= "`e[95m"
            BrightCyan   = "`e[96m"; BrightWhite  = "`e[97m"
        }
        BG = @{
            Black      = "`e[40m"; Red     = "`e[41m"; Green   = "`e[42m"
            Yellow     = "`e[43m"; Blue    = "`e[44m"; Magenta = "`e[45m"
            Cyan       = "`e[46m"; White   = "`e[47m"; Default = "`e[49m"
            BrightBlack  = "`e[100m"; BrightRed    = "`e[101m"
            BrightGreen  = "`e[102m"; BrightYellow = "`e[103m"
            BrightBlue   = "`e[104m"; BrightMagenta= "`e[105m"
            BrightCyan   = "`e[106m"; BrightWhite  = "`e[107m"
        }
        Color256FgPrefix   = "`e[38;5;"
        Color256BgPrefix   = "`e[48;5;"
        TrueColorFgPrefix  = "`e[38;2;"
        TrueColorBgPrefix  = "`e[48;2;"
        Cursor = @{
            Hide           = "`e[?25l"; Show           = "`e[?25h"; Save           = "`e[s"
            Restore        = "`e[u"; Up             = "`e[{0}A"; Down           = "`e[{0}B"
            Right          = "`e[{0}C"; Left           = "`e[{0}D"; NextLine       = "`e[{0}E"
            PrevLine       = "`e[{0}F"; Column         = "`e[{0}G"; Position       = "`e[{0};{1}H"
            Forward        = "`e[{0}C"; Backward       = "`e[{0}D"; LineStart      = "`e[G"
            LineEnd        = "`e[9999C"; ShapeBlock     = "`e[2 q"; ShapeLine      = "`e[6 q"
            ShapeUnderscore = "`e[4 q"; BlinkBlock     = "`e[1 q"; BlinkLine      = "`e[5 q"
            BlinkUnderscore = "`e[3 q"
        }
        Screen = @{
            ClearFull       = "`e[2J`e[H"; ClearToEOL      = "`e[0K"; ClearToBOL      = "`e[1K"
            ClearLineFull   = "`e[2K"; EraseScreen     = "`e[2J"; EraseSavedLines = "`e[3J"
            ScrollUp        = "`e[{0}S"; ScrollDown      = "`e[{0}T"; SetRegion       = "`e[{0};{1}r"
            SetColumns      = "`e[?3h`e[?3l"; SaveCursorState = "`e[s"; RestoreCursorState = "`e[u"
        }
        Mouse = @{
            EnableX10       = "`e[?9h"; DisableX10      = "`e[?9l"; EnableNormal    = "`e[?1000h"
            DisableNormal   = "`e[?1000l"; EnableButtonEvent = "`e[?1002h"; DisableButtonEvent = "`e[?1002l"
            EnableAnyEvent   = "`e[?1003h"; DisableAnyEvent  = "`e[?1003l"; EnableSGR        = "`e[?1006h"
            DisableSGR       = "`e[?1006l"; EnableUTF8Ext    = "`e[?1005h"; DisableUTF8Ext   = "`e[?1005l"
            ReportFormat     = "`e[<{0};{1};{2}{3}"
        }
        Keyboard = @{
            EnableCSIU     = "`e[>1u"; EnableKitty    = "`e[>u"
            LegacyMap      = @{
                Up         = "`e[A"; Down      = "`e[B"; Right     = "`e[C"; Left      = "`e[D"
                Home       = "`e[H"; End       = "`e[F"; PageUp    = "`e[5~"; PageDown  = "`e[6~"
                Insert     = "`e[2~"; Delete    = "`e[3~"; F1        = "`eOP"; F2        = "`eOQ"
                F3         = "`eOR"; F4        = "`eOS"; F5        = "`e[15~"; F6       = "`e[17~"
                F7         = "`e[18~"; F8       = "`e[19~"; F9        = "`e[20~"; F10      = "`e[21~"
                F11        = "`e[23~"; F12      = "`e[24~"
            }
        }
        OSC = @{
            SetTitle       = "`e]0;{0}`a"; SetIconTitle   = "`e]1;{0}`a"
            HyperlinkOpen  = "`e]8;;{0}`e\\"; HyperlinkClose = "`e]8;;`a`e\\"
            Notify         = "`e]9;{0};{1}`a"; QueryColors    = "`e]10;?`a`e]11;?`a`e]12;?`a"
            ClipboardRead  = "`e]52;{0};?`a"; ClipboardWrite = "`e]52;{0};{1}`a"
            ShellPrompt    = "`e]133;A`a"; ShellCommand   = "`e]133;B`a"; ShellExit      = "`e]133;C;{0}`a"
        }
        DEC = @{
            EnableAltBuffer   = "`e[?1049h"; DisableAltBuffer  = "`e[?1049l"
            EnableAutoWrap    = "`e[?7h"; DisableAutoWrap   = "`e[?7l"
            EnableCursorKeys  = "`e[?1h`e[?1l"; EnableFocusInOut  = "`e[?1004h"; DisableFocusInOut = "`e[?1004l"
            EnableBracketedPaste = "`e[?2004h"; DisableBracketedPaste = "`e[?2004l"
            EnableSixel       = "`e[?80h"; DisableSixel      = "`e[?80l"
        }
    }

    # ===========================================================================
    # 2. BRANDING & IDENTIDADE VISUAL
    # ===========================================================================
    Branding = @{
        Product   = "SCAPE"
        Tagline   = "Systematic Container & Asset Processing Engine"
        Author    = "Terminal Architect"
        Version   = "1.0.0"
        License   = "MIT"
        Repo      = "https://github.com/namespace/scape"
        Doc       = "https://scape.docs"
        Support   = "Discord: #scape-support | Email: support@scape.dev"
    }

    # ===========================================================================
    # 3. ASCII / ANSI ART
    # ===========================================================================
    Art = @{
        BannerLogo = @"
███████╗ ██████╗ █████╗ ██████╗ ███████╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝
███████╗██║     ███████║██████╔╝█████╗
╚════██║██║     ██╔══██║██╔═══╝ ██╔══╝
███████║╚██████╗██║  ██║██║     ███████╗
╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝
"@

        SmallLogo = @"
╔═╗╔═╗╔═╗╔═╗╔═╗
╚═╗║  ╠═╣╠═╝║═
╚═╝╚═╝╩ ╩╩  ╚═╝
"@

        SmallLogoMicro   = "◆ SCAPE v1.0 ◆"
        SmallLogoStatus  = "[ SCAPE TUI ]"
        SmallLogoIcon    = "◆"

        Variants = @{
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
    Layout = @{
        MinWidth        = 60; MaxWidth        = 140; MinHeight       = 15
        Margin          = 2;  Padding         = 1;   MaxLogLines     = 1000
        TitlePadding    = 2;  FooterHeight    = 3;   HeaderHeight    = 5
        StatusBarHeight = 1;  HelpBarHeight   = 2;   PanelGap        = 2
        ScrollBarWidth  = 1;  ResizeMargin    = 5;   AutoResize      = $true
        SaveWindowSize  = $true; SplitRatio    = @{ Left = 0.6; Right = 0.4 }
    }

    # ===========================================================================
    # 5. INPUT HANDLING (PS-aware + protocolos modernos)
    # ===========================================================================
    Input = @{
        PollMs            = 30; MenuWrap          = $true; DebounceMs         = 50
        HoldThresholdMs   = 500; RepeatDelayMs     = 200; RepeatRateMs        = 50
        AltKeyModifier    = $true; CtrlKeyModifier = $true; WinKeyModifier    = $false
        MouseSupport      = "auto"; PasteTimeoutMs = 2000; KeyEscapeTimeoutMs = 100
        Protocol          = "CSIu"  # "Legacy", "CSIu", "Kitty"

        KeyMap = @{
            Up       = "`e[A"; Down     = "`e[B"; Right    = "`e[C"; Left     = "`e[D"
            Home     = "`e[H"; End      = "`e[F"; PageUp   = "`e[5~"; PageDown = "`e[6~"
            Insert   = "`e[2~"; Delete  = "`e[3~"; F1       = "`eOP"; F2       = "`eOQ"
            F3       = "`eOR"; F4       = "`eOS"; F5       = "`e[15~"; F6      = "`e[17~"
            F7       = "`e[18~"; F8     = "`e[19~"; F9      = "`e[20~"; F10     = "`e[21~"
            F11      = "`e[23~"; F12    = "`e[24~"
        }
        PSCombos = @{
            Accept         = "Enter"; Cancel          = "Escape"
            AutoComplete   = "Ctrl+Space"; KillLine    = "Ctrl+K"
            Undo           = "Ctrl+Z"; HistoryPrev     = "Up"
            HistoryNext    = "Down"; SearchHistory     = "Ctrl+R"
            RunspaceSwitch = "Ctrl+Tab"; QuickExit     = "Alt+F4"
        }
    }

    # ===========================================================================
    # 6. FRAME PRESETS
    # ===========================================================================
    Frames = @{
        Classic    = @{ TL="╔"; TR="╗"; BL="╚"; BR="╝"; HL="═"; VL="║"; ML="╠"; MR="╣"; Cross="╬"; TeeUp="╩"; TeeDown="╦"; TeeLeft="╣"; TeeRight="╠"; Name="Classic Double-Line" }
        Rounded    = @{ TL="╭"; TR="╮"; BL="╰"; BR="╯"; HL="─"; VL="│"; ML="├"; MR="┤"; Cross="┼"; TeeUp="┴"; TeeDown="┬"; TeeLeft="┤"; TeeRight="├"; Name="Rounded Soft" }
        Minimal    = @{ TL="┌"; TR="┐"; BL="└"; BR="┘"; HL="─"; VL="│"; ML="├"; MR="┤"; Cross="┼"; TeeUp="┴"; TeeDown="┬"; TeeLeft="┤"; TeeRight="├"; Name="Minimal Single" }
        ASCII      = @{ TL="+"; TR="+"; BL="+"; BR="+"; HL="-"; VL="|"; ML="+"; MR="+"; Cross="+"; TeeUp="+"; TeeDown="+"; TeeLeft="+"; TeeRight="+"; Name="ASCII Fallback" }
        Block      = @{ TL="█"; TR="█"; BL="█"; BR="█"; HL="█"; VL="█"; ML="█"; MR="█"; Cross="█"; TeeUp="█"; TeeDown="█"; TeeLeft="█"; TeeRight="█"; Name="Block Heavy" }
        Retro      = @{ TL="┌"; TR="┐"; BL="└"; BR="┘"; HL="─"; VL="│"; ML="├"; MR="┤"; Cross="┼"; TeeUp="┴"; TeeDown="┬"; TeeLeft="┤"; TeeRight="├"; Name="Retro Terminal" }
        Cyber      = @{ TL="▛"; TR="▜"; BL="▙"; BR="▟"; HL="▄"; VL="▌"; ML="▐"; MR="▐"; Cross="▀"; TeeUp="▄"; TeeDown="▀"; TeeLeft="▐"; TeeRight="▌"; Name="Cyberpunk" }
        Heavy      = @{ TL="┏"; TR="┓"; BL="┗"; BR="┛"; HL="━"; VL="┃"; ML="┣"; MR="┫"; Cross="╋"; TeeUp="┻"; TeeDown="┳"; TeeLeft="┫"; TeeRight="┣"; Name="Heavy Box" }
        Dotted     = @{ TL="."; TR="."; BL="."; BR="."; HL="·"; VL=":"; ML=":"; MR=":"; Cross="+"; TeeUp="+"; TeeDown="+"; TeeLeft="+"; TeeRight="+"; Name="Dotted" }
        Borderless = @{ TL=" "; TR=" "; BL=" "; BR=" "; HL=" "; VL=" "; ML=" "; MR=" "; Cross=" "; TeeUp=" "; TeeDown=" "; TeeLeft=" "; TeeRight=" "; Name="Borderless" }
        PowerShell = @{ TL=">"; TR="<"; BL="<"; BR=">"; HL="~"; VL="|"; ML="|"; MR="|"; Cross="|"; TeeUp="|"; TeeDown="|"; TeeLeft="|"; TeeRight="|"; Name="PowerShell Prompt" }
    }

    # ===========================================================================
    # 7. PROGRESS / SPINNERS
    # ===========================================================================
    Progress = @{
        Default  = @{ FullChar="█"; EmptyChar="░"; ErrorChar="▒"; Width=40; ShowPercent=$true; ShowLabel=$true; ShowETA=$false }
        Compact  = @{ FullChar="="; EmptyChar="-"; ErrorChar="X"; Width=20; ShowPercent=$false; ShowLabel=$false; ShowETA=$false }
        BarOnly  = @{ FullChar="■"; EmptyChar="□"; ErrorChar="!"; Width=50; ShowPercent=$false; ShowLabel=$true; ShowETA=$true }
        Discrete = @{ FullChar="●"; EmptyChar="○"; ErrorChar="⊗"; Width=10; ShowPercent=$true; ShowLabel=$true; ShowETA=$false }
        Braille  = @{ Frames=@("⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"); IntervalMs=80 }
        Line     = @{ Frames=@("/","-","\\","|"); IntervalMs=120 }
        Dot      = @{ Frames=@(" . "," ..","...",".. ",".  "); IntervalMs=150 }
        Blocks   = @{ Frames=@("▁","▂","▃","▄","▅","▆","▇","█"); IntervalMs=60 }
    }

    # ===========================================================================
    # 8. STATUS BAR / MENU / TOOLTIP / HELP
    # ===========================================================================
    StatusBar = @{
        Items = @(
            @{ Name="Time"; Format="HH:mm:ss"; Alignment="Right" }
            @{ Name="GitBranch"; Format="{branch}"; Alignment="Left"; Fallback="(none)" }
            @{ Name="ExecutionPolicy"; Format="{policy}"; Alignment="Left"; Default="Unrestricted" }
            @{ Name="RunspaceID"; Format="RS:{id}"; Alignment="Right"; Default="Main" }
            @{ Name="Memory"; Format="{used}/{total}"; Alignment="Right" }
            @{ Name="Mode"; Alignment="Left"; Default="NORMAL" }
        )
        Separator      = " │ "; ShowBackground = $true; BackgroundColor = "Base.Dark.Surface"
        MaxItems       = 6; HideWhenNarrow   = $true; MinWidthForFull  = 80
    }
    Menu = @{
        IndentStep       = 2; ShowShortcuts    = $true; ShowIcons        = $true
        HighlightSelected = "Bold"; SeparatorChar    = "─"; SubmenuIndicator = "▶"
        BackIndicator    = "◀"; CloseOnSelect    = $true; BreadcrumbSep    = " / "; MaxDepth = 4
    }
    Tooltip = @{
        DelayMs     = 500; FadeInMs    = 100; MaxWidth    = 60; BorderStyle = "Rounded"
        AutoPosition = $true; Shadow      = $true; ShowHotkey  = $true; RichText    = $true
        FollowMouse = $false; OffsetX     = 5; OffsetY     = 1
    }
    Help = @{
        F1Key           = $true; ContextSensitive = $true; DefaultPage     = "welcome"
        Style           = "fullscreen"; Colors = @{ Title="Base.Cyan"; Section="Base.Green"; Key="Base.Yellow"; Description="Base.White" }
        BreadcrumbSep   = " > "; SearchHint      = "Press / to search"
    }

    # ===========================================================================
    # 9. SCROLLBAR / MODAL / SOUND / RESIZE
    # ===========================================================================
    ScrollBar = @{
        TrackChar    = "░"; ThumbChar    = "█"; Width        = 1; HideWhenFull = $true
        Position     = "right"; Style        = "modern"; ArrowUp      = "▲"; ArrowDown    = "▼"
        ShowArrows   = $false
    }
    Modal = @{
        BackgroundOpacity = 0.8; CloseOnEsc        = $true; CloseOnOutside    = $false
        ShadowBlur        = 0; BorderStyle       = "Heavy"; Animate           = $true
        AnimationType     = "fade"; CenterVertically  = $true; CenterHorizontally = $true
    }
    Sound = @{
        Enabled = $false; Events  = @{ Error="beep"; Warning="beep"; Success="none"; Click="none" }
        BeepDurationMs = 200; BeepFrequencyHz = 800
    }
    Resize = @{
        Enabled       = $true; MinWidth      = 40; MinHeight     = 10
        MaxWidth      = 0; MaxHeight     = 0; AutoFit       = $true
        PreserveAspect = $false; NotifyEvent   = $true
    }

    # ===========================================================================
    # 10. REDACTION / CAPABILITIES / DEFAULTS
    # ===========================================================================
    Redaction = @{
        Enabled = $true
        Patterns = @(
            @{ Regex='api[_-]?key\s*=\s*[\w]+'; Replace='api_key=***' }
            @{ Regex='token\s*=\s*[\w-]+'; Replace='token=***' }
            @{ Regex='password\s*=\s*\S+'; Replace='password=***' }
            @{ Regex='[A-F0-9]{32,}'; Replace='<HASH_REDACTED>' }
        )
        MaskChar = "*"
    }
    TerminalCapabilities = @{
        TrueColor       = $true; Hyperlinks      = $true; BracketedPaste  = $true
        MouseTracking   = $true; AlternateScreen = $true; FocusEvents     = $true
        KittyKeyboard   = $false; SixelGraphics   = $false; CSIuKeyboard    = $true
        Fallback256     = $true; Fallback16      = $true
    }
    Defaults = @{
        FrameStyle        = "Classic"; AnimationEnabled  = $true; ColorMode         = "TrueColor"
        ShowHints         = $true; CompactMode       = $false; ThemePersistence  = $true
        MouseSupport      = $true; SoundEnabled      = $false; Locale            = "en-US"
        TimeFormat        = "HH:mm:ss"; DateFormat     = "yyyy-MM-dd"; NumericFormat     = "N0"
        MemoryFormat      = "Auto"; DecimalSeparator  = "."; ThousandsSeparator= ","
        ThemeProfile      = "PowerShell"; SmallLogoVariant  = "Compact"; StatusBarVisible  = $true
        AutoGitStatus     = $true; OSC8Hyperlinks    = $true; PromptIntegration = $true
    }
    # ===========================================================================
    # 11. ICONS & SYMBOLS (VT100, Unicode, fallback text)
    # ===========================================================================
    Icons = @{
        Success      = @("✅", "√", "[OK]")
        Failure      = @("❌", "✗", "[ERR]")
        Warning      = @("⚠️", "⚠", "[!]")
        Info         = @("ℹ️", "i", "[i]")
        Question     = @("❓", "?", "[?]")
        Checkmark    = @("✔️", "✓", "[V]")
        Crossmark    = @("❎", "✗", "[X]")
        Ellipsis     = @("…", "...", "...")
        Bullet       = @("•", "•", "*")
        Separator    = @("─", "-", "-")

        # Colored status dots (user request: "bolinhas coloridas")
        DotRed       = @("🔴", "●", "[!]")
        DotGreen     = @("🟢", "●", "[OK]")
        DotYellow    = @("🟡", "●", "[~]")
        DotBlue      = @("🔵", "●", "[i]")
        DotCyan      = @("🔷", "◆", "[*]")
        DotMagenta   = @("🟣", "●", "[★]")
        DotWhite     = @("⚪", "○", "[ ]")
        DotGray      = @("⚫", "●", "[•]")

        # Status badges (text-only fallback for strict terminals)
        BadgeNew     = @("🆕", "NEW", "[NEW]")
        BadgeUpdated = @("🔄", "UPD", "[UPD]")
        BadgeHot     = @("🔥", "HOT", "[HOT]")
        BadgeCold    = @("❄️", "CLD", "[CLD]")
        BadgeLock    = @("🔐", "LCK", "[LCK]")
        BadgeUnlock  = @("🔓", "OPN", "[OPN]")

        # ===========================================================================
        # NAVIGATION & DIRECTIONAL (Setas, cursores, movimento)
        # ===========================================================================
        ArrowUp      = @("⬆️", "↑", "^")
        ArrowDown    = @("⬇️", "↓", "v")
        ArrowLeft    = @("⬅️", "←", "<")
        ArrowRight   = @("➡️", "→", ">")
        ArrowDoubleUp    = @("⬆⬆", "⇑", "^^")
        ArrowDoubleDown  = @("⬇⬇", "⇓", "vv")
        ArrowDoubleLeft  = @("⬅⬅", "⇐", "<<")
        ArrowDoubleRight = @("➡➡", "⇒", ">>")

        CaretUp      = @("▲", "▲", "^")
        CaretDown    = @("▼", "▼", "v")
        CaretLeft    = @("◀", "◀", "<")
        CaretRight   = @("▶", "▶", ">")
        CaretSmallUp    = @("▴", "^", "^")
        CaretSmallDown  = @("▾", "v", "v")
        CaretSmallLeft  = @("◂", "<", "<")
        CaretSmallRight = @("▸", ">", ">")

        CompassN     = @("🧭N", "N", "[N]")
        CompassS     = @("🧭S", "S", "[S]")
        CompassE     = @("🧭E", "E", "[E]")
        CompassW     = @("🧭W", "W", "[W]")

        Home         = @("🏠", "H", "[H]")
        End          = @("🏁", "E", "[E]")
        Jump         = @("⤴️", "J", "[J]")
        Return       = @("↩️", "↵", "[RET]")

        # ===========================================================================
        # UI CONTROLS (Botões, menus, ações de interface)
        # ===========================================================================
        Menu         = @("☰", "≡", "[M]")
        Submenu      = @("▸", "▶", ">")
        Back         = @("◂", "◀", "<")
        Close        = @("✖️", "✕", "[X]")
        Minimize     = @("🗕", "─", "_")
        Maximize     = @("🗖", "□", "[□]")
        Normalize    = @("🗗", "▢", "[▢]")
        Help         = @("❔", "?", "[?]")

        # Window management
        WindowTile   = @("🪟", "[]", "[TILE]")
        WindowSplitH = @("⇹", "|", "[SPLITH]")
        WindowSplitV = @("⤢", "-", "[SPLITV]")
        WindowFull   = @("⛶", "[ ]", "[FULL]")

        # Tab & focus
        TabNew       = @("🗐", "+", "[+TAB]")
        TabClose     = @("🗙", "x", "[X]")
        TabNext      = @("➡️", ">", "[NEXT]")
        TabPrev      = @("⬅️", "<", "[PREV]")
        FocusIn      = @("🔍", "⊕", "[IN]")
        FocusOut     = @("🔎", "⊖", "[OUT]")

        # ===========================================================================
        # FORMS & INPUT (Checkbox, radio, sliders, fields)
        # ===========================================================================
        CheckboxOn   = @("☑️", "[X]", "[X]")
        CheckboxOff  = @("☐", "[ ]", "[ ]")
        CheckboxHalf = @("☑", "[~]", "[~]")

        RadioOn      = @("🔘", "(●)", "(O)")
        RadioOff     = @("⚪", "( )", "( )")

        SliderStart  = @("🔹", "o", "[o]")
        SliderMid    = @("─", "-", "-")
        SliderEnd    = @("🔸", "●", "[●]")
        SliderHandle = @("🔶", "◆", "[H]")

        InputText    = @("📝", "[T]", "[TXT]")
        InputNumber  = @("🔢", "[#]", "[NUM]")
        InputDate    = @("📅", "[D]", "[DATE]")
        InputEmail   = @("📧", "[@]", "[EMAIL]")
        InputPassword= @("🔑", "[*]", "[PWD]")

        Dropdown     = @("🔽", "▼", "[▼]")
        Listbox      = @("📋", "[]", "[LIST]")
        Combobox     = @("🗂️", "[∨]", "[COMBO]")

        # ===========================================================================
        # SYSTEM & HARDWARE (Ricos, específicos, PowerShell-aware)
        # ===========================================================================
        Folder       = @("📁", "[DIR]", "[DIR]")
        FolderOpen   = @("📂", "[OPN]", "[OPN]")
        FolderSync   = @("📁🔄", "[SYNCDIR]", "[SYNCDIR]")

        File         = @("📄", "[FILE]", "[FILE]")
        FileCode     = @("📜", "[CODE]", "[CODE]")
        FileConfig   = @("⚙️📄", "[CFG]", "[CFG]")
        FileLog      = @("📜", "[LOG]", "[LOG]")
        FileTemp     = @("🗑️📄", "[TMP]", "[TMP]")
        FileArchive  = @("🗜️", "[ZIP]", "[ZIP]")
        FileExec     = @("⚡", "[EXE]", "[EXE]")

        Database     = @("🗄️", "[DB]", "[DB]")
        DatabaseSync = @("🗄️🔄", "[DBSYNC]", "[DBSYNC]")

        Network      = @("🌐", "[NET]", "[NET]")
        NetworkWired = @("🔌", "[ETH]", "[ETH]")
        NetworkWireless = @("📶", "[WIFI]", "[WIFI]")
        NetworkCloud = @("☁️", "[CLD]", "[CLD]")
        NetworkLocal = @("🏠", "[LAN]", "[LAN]")

        Disk         = @("💾", "[DISK]", "[DISK]")
        DiskSSD      = @("⚡💾", "[SSD]", "[SSD]")
        DiskHDD      = @("🌀", "[HDD]", "[HDD]")
        DiskUSB      = @("🔌", "[USB]", "[USB]")
        DiskNetwork  = @("🌐💾", "[NAS]", "[NAS]")

        Memory       = @("🧠", "[RAM]", "[RAM]")
        MemoryChip   = @("🔲", "[CHIP]", "[CHIP]")
        CPU          = @("⚙️", "[CPU]", "[CPU]")
        GPU          = @("🎮", "[GPU]", "[GPU]")

        Clock        = @("⏱️", "[TIME]", "[TIME]")
        Calendar     = @("📅", "[DATE]", "[DATE]")
        Timer        = @("⏲️", "[TMR]", "[TMR]")
        Stopwatch    = @("⏱️", "[STOP]", "[STOP]")

        Lock         = @("🔒", "[LCK]", "[LCK]")
        Unlock       = @("🔓", "[OPN]", "[OPN]")
        Key          = @("🔑", "[KEY]", "[KEY]")
        KeyPair      = @("🔐", "[PAIR]", "[PAIR]")
        Certificate  = @("📜🔐", "[CERT]", "[CERT]")

        User         = @("👤", "[USR]", "[USR]")
        Users        = @("👥", "[GRP]", "[GRP]")
        Admin        = @("👑", "[ADM]", "[ADM]")
        Guest        = @("🎭", "[GST]", "[GST]")
        Service      = @("⚙️👤", "[SVC]", "[SVC]")

        Settings     = @("⚙️", "[SET]", "[SET]")
        Config       = @("🔧", "[CFG]", "[CFG]")
        Preferences  = @("🎛️", "[PREF]", "[PREF]")
        Tools        = @("🧰", "[TLS]", "[TLS]")

        Search       = @("🔍", "[FND]", "[FND]")
        Filter       = @("🔽", "[FLT]", "[FLT]")
        SortAsc      = @("🔼", "[A→Z]", "[ASC]")
        SortDesc     = @("🔽", "[Z→A]", "[DESC]")
        GroupBy      = @("🗂️", "[GRP]", "[GRP]")

        Refresh      = @("🔄", "[RFR]", "[RFR]")
        Sync         = @("🔁", "[SYNC]", "[SYNC]")
        Update       = @("⬆️", "[UPD]", "[UPD]")
        Upgrade      = @("🚀", "[UPG]", "[UPG]")

        Power        = @("⏻", "[PWR]", "[PWR]")
        BatteryFull  = @("🔋", "[100%]", "[FULL]")
        BatteryHalf  = @("🪫", "[50%]", "[HALF]")
        BatteryLow   = @("🪫⚠️", "[LOW]", "[LOW]")
        Charging     = @("🔌🔋", "[CHG]", "[CHG]")

        SignalFull   = @("📶📶📶📶", "[SIG4]", "[MAX]")
        SignalHalf   = @("📶📶", "[SIG2]", "[MED]")
        SignalLow    = @("📶", "[SIG1]", "[LOW]")
        SignalNone   = @("📵", "[NO SIG]", "[NONE]")

        # ===========================================================================
        # ACTIONS & OPERATIONS (Verbos de ação)
        # ===========================================================================
        Play         = @("▶️", "▶", "[>]")
        Pause        = @("⏸️", "‖", "[‖]")
        Stop         = @("⏹️", "■", "[■]")
        Record       = @("⏺️", "●", "[●]")
        Eject        = @("⏏️", "⏏", "[EJT]")
        Next         = @("⏭️", "⏭", "[>>]")
        Prev         = @("⏮️", "⏮", "[<<]")
        Shuffle      = @("🔀", "🔀", "[SHF]")
        Repeat       = @("🔁", "🔁", "[RPT]")

        VolumeMax    = @("🔊", "[VOL+]", "[MAX]")
        VolumeMed    = @("🔉", "[VOL]", "[MED]")
        VolumeMin    = @("🔈", "[VOL-]", "[MIN]")
        Mute         = @("🔇", "[MUTE]", "[MUTE]")

        MicOn        = @("🎤", "[MIC]", "[ON]")
        MicOff       = @("🎤🚫", "[MUTED]", "[OFF]")

        CameraOn     = @("📷", "[CAM]", "[ON]")
        CameraOff    = @("📷🚫", "[CAM]", "[OFF]")

        Print        = @("🖨️", "[PRT]", "[PRT]")
        Scan         = @("📠", "[SCN]", "[SCN]")
        Fax          = @("📠", "[FAX]", "[FAX]")

        MailSend     = @("📤", "[SENT]", "[SENT]")
        MailReceive  = @("📥", "[INBOX]", "[INBOX]")
        MailDraft    = @("📝", "[DRAFT]", "[DRAFT]")
        MailArchive  = @("🗄️📧", "[ARCH]", "[ARCH]")

        Chat         = @("💬", "[MSG]", "[MSG]")
        Comment      = @("💭", "[CMT]", "[CMT]")
        Mention      = @("🔖", "[@]", "[@]")

        Share        = @("🔗", "[SHR]", "[SHR]")
        Link         = @("🔗", "[LNK]", "[LNK]")
        Unlink       = @("🔗✂️", "[UNLK]", "[UNLK]")

        Copy         = @("📋", "[CPY]", "[CPY]")
        Cut          = @("✂️", "[CUT]", "[CUT]")
        Paste        = @("📌", "[PST]", "[PST]")
        Clone        = @("👥📋", "[CLN]", "[CLN]")

        Save         = @("💾", "[SAV]", "[SAV]")
        SaveAs       = @("💾✏️", "[SAV AS]", "[SAVAS]")
        Load         = @("📂", "[LOAD]", "[LOAD]")
        Import       = @("📥", "[IMP]", "[IMP]")
        Export       = @("📤", "[EXP]", "[EXP]")

        New          = @("🆕", "[+]", "[NEW]")
        Open         = @("📂", "[O]", "[OPEN]")
        Edit         = @("✏️", "[E]", "[EDIT]")
        Delete       = @("🗑️", "[DEL]", "[DEL]")
        Trash        = @("🗑️", "[TRSH]", "[TRSH]")
        Restore      = @("🔄🗑️", "[RST]", "[RST]")
        Undo         = @("↩️", "[UNDO]", "[UNDO]")
        Redo         = @("↪️", "[REDO]", "[REDO]")

        Run          = @("🚀", "[RUN]", "[RUN]")
        Execute      = @("⚡", "[EXEC]", "[EXEC]")
        Build        = @("🔨", "[BLD]", "[BLD]")
        Deploy       = @("🚢", "[DEP]", "[DEP]")
        Test         = @("🧪", "[TST]", "[TST]")
        Debug        = @("🐛", "[DBG]", "[DBG]")

        Upload       = @("⬆️📤", "[UPL]", "[UPL]")
        Download     = @("⬇️📥", "[DWN]", "[DWN]")

        Install      = @("📦⬇️", "[INS]", "[INS]")
        Uninstall    = @("📦⬆️", "[RMV]", "[RMV]")
        Package      = @("📦", "[PKG]", "[PKG]")
        Module       = @("🧩", "[MOD]", "[MOD]")

        # ===========================================================================
        # VISUAL & DECORATIVE (Separadores, bordas, elementos estéticos)
        # ===========================================================================
        StarEmpty    = @("☆", "*", "[ ]")
        StarHalf     = @("★", "*", "[*]")
        StarFull     = @("⭐", "*", "[★]")

        HeartEmpty   = @("♡", "<3", "[ ]")
        HeartFull    = @("❤️", "<3", "[♥]")

        Flag         = @("🚩", "[FLG]", "[FLG]")
        Bookmark     = @("🔖", "[BMK]", "[BMK]")
        Tag          = @("🏷️", "[TAG]", "[TAG]")
        Label        = @("🏷️", "[LBL]", "[LBL]")

        Trophy       = @("🏆", "[WIN]", "[WIN]")
        Medal        = @("🎖️", "[MED]", "[MED]")
        Crown        = @("👑", "[CRN]", "[CRN]")

        Sparkle      = @("✨", "*", "[*]")
        Fire         = @("🔥", "[FIRE]", "[FIRE]")
        Lightning    = @("⚡", "[LTN]", "[LTN]")
        Snowflake    = @("❄️", "[SNOW]", "[SNOW]")
        Drop         = @("💧", "[DROP]", "[DROP]")
        Sun          = @("☀️", "[SUN]", "[SUN]")
        Moon         = @("🌙", "[MON]", "[MON]")
        Cloud        = @("☁️", "[CLD]", "[CLD]")
        Rainbow      = @("🌈", "[RBW]", "[RBW]")

        # Decorative separators (multiple styles)
        SepDot       = @("・", ".", "[.]")
        SepDash      = @("─", "-", "[-]")
        SepDouble    = @("═", "=", "[=]")
        SepWave      = @("〜", "~", "[~]")
        SepArrow     = @("⟶", "->", "[->]")
        SepChevron   = @("»", ">", "[>]")

        # Box drawing helpers (for dynamic frames)
        BoxTL        = @("╭", "+", "[TL]")
        BoxTR        = @("╮", "+", "[TR]")
        BoxBL        = @("╰", "+", "[BL]")
        BoxBR        = @("╯", "+", "[BR]")
        BoxH         = @("─", "-", "[H]")
        BoxV         = @("│", "|", "[V]")
        BoxCross     = @("┼", "+", "[+]")

        # ===========================================================================
        # POWERSHELL NATIVE (Ícones específicos do ecossistema PS)
        # ===========================================================================
        PSPrompt     = @("PS>", "PS>", "[PS]")
        PSFunction   = @("⚙️", "F", "[FN]")
        PSFunctionPrivate = @("🔒⚙️", "f", "[PRVF]")
        PSFunctionPublic  = @("🔓⚙️", "F", "[PUBF]")

        PSVariable   = @("$", "$", "[VAR]")
        PSVariableConst = @("🔒$", "$c", "[CVAR]")
        PSVariableEnv   = @("🌍$", "$e", "[EVAR]")

        PSModule     = @("🧩", "M", "[MOD]")
        PSModuleCore = @("💠", "MC", "[CORE]")
        PSModuleScript = @("📜", "MS", "[SCR]")

        PSClass      = @("🏗️", "C", "[CLS]")
        PSEnum       = @("📋", "E", "[ENUM]")

        PSRunspace   = @("🧵", "RS", "[RS]")
        PSJob        = @("📬", "J", "[JOB]")
        PSJobRunning = @("🟢📬", "JR", "[RUN]")
        PSJobStopped = @("🔴📬", "JS", "[STOP]")

        PSPipeline   = @("⚙️➡️⚙️", "|", "[PIPE]")
        PSOutput     = @("📤", "OUT", "[OUT]")
        PSInput      = @("📥", "IN", "[IN]")

        PSProfile    = @("👤⚙️", "PROF", "[PROF]")
        PSHistory    = @("📜⏪", "HIST", "[HIST]")
        PSAlias      = @("🏷️", "ALIAS", "[ALIAS]")

        PSDebug      = @("🐛", "DBG", "[DBG]")
        PSVerbose    = @("🗣️", "VB", "[VB]")
        PSWarning    = @("⚠️", "WRN", "[WRN]")
        PSError      = @("❌", "ERR", "[ERR]")

        PSGet        = @("📥", "GET", "[GET]")
        PSSet        = @("📤", "SET", "[SET]")
        PSNew        = @("🆕", "NEW", "[NEW]")
        PSRemove     = @("🗑️", "RM", "[RM]")
        PSClear      = @("🧹", "CLR", "[CLR]")

        PSImport     = @("📦➡️", "IMP", "[IMP]")
        PSExport     = @("➡️📦", "EXP", "[EXP]")

        PSHelp       = @("❔", "?", "[?]")
        PSAbout      = @("ℹ️", "i", "[i]")

        # ===========================================================================
        # MISC & FALLBACKS (Segurança para terminais limitados)
        # ===========================================================================
        Unknown      = @("❓", "?", "[?]")
        Placeholder  = @("□", "[ ]", "[ ]")
        Loading      = @("⏳", "...", "[...]")
        Processing   = @("⚙️", "[...]", "[PROC]")
        Waiting      = @("🕐", "[WAIT]", "[WAIT]")
        Idle         = @("😴", "[Zzz]", "[IDLE]")
        Ready        = @("✅", "[OK]", "[READY]")

        # Emergency fallbacks (never show ??)
        FallbackIcon = "•"
        FallbackText = "[?]"
    }

    # ===========================================================================
    # 12. SEMANTIC MAPPING (Icon = Action)
    # ===========================================================================
    SemanticMap = @{
        # ===========================================================================
        # NÚCLEO & TAREFAS PRINCIPAIS
        # ===========================================================================
        "SCAN"          = "Search"
        "PARSING"       = "Database"
        "ARCHAEOLOGY"   = "Pickaxe"
        "HARVESTER"     = "Package"
        "FORENSICS"     = "Shield"
        "SETTINGS"      = "Settings"
        "LOGISTICS"     = "Network"
        "LABORATORY"    = "Chip"
        "EXIT"          = "Power"
        "HOME"          = "Home"
        "DASHBOARD"     = "Menu"
        "OVERVIEW"      = "Info"
        "STATUS"        = "Info"
        "ABOUT"         = "Help"
        "HELP"          = "Help"
        "DOCS"          = "Help"
        "SUPPORT"       = "Chat"
        "FEEDBACK"      = "Comment"

        # ===========================================================================
        # NAVEGAÇÃO & CONTROLE DE FLUXO
        # ===========================================================================
        "RETURN"        = "Back"
        "CANCEL"        = "Close"
        "CLOSE"         = "Close"
        "AUTO"          = "Target"
        "UNMOUNT"       = "Eject"
        "DELETE"        = "Trash"
        "REMOVE"        = "Trash"
        "FOLDER"        = "Folder"
        "DIRECTORY"     = "Folder"
        "DIR"           = "Folder"
        "FILE"          = "File"
        "OPEN"          = "FolderOpen"
        "BROWSE"        = "Search"
        "NAVIGATE"      = "CompassN"
        "UP"            = "ArrowUp"
        "DOWN"          = "ArrowDown"
        "LEFT"          = "ArrowLeft"
        "RIGHT"         = "ArrowRight"
        "NEXT"          = "Next"
        "PREV"          = "Prev"
        "PREVIOUS"      = "Prev"
        "FIRST"         = "Home"
        "LAST"          = "End"
        "JUMP"          = "Jump"
        "GOTO"          = "Jump"

        # ===========================================================================
        # OPERAÇÕES DE ARQUIVO & SISTEMA
        # ===========================================================================
        "NEW"           = "New"
        "CREATE"        = "New"
        "SAVE"          = "Save"
        "SAVE_AS"       = "SaveAs"
        "LOAD"          = "Load"
        "IMPORT"        = "Import"
        "EXPORT"        = "Export"
        "COPY"          = "Copy"
        "CUT"           = "Cut"
        "PASTE"         = "Paste"
        "CLONE"         = "Clone"
        "DUPLICATE"     = "Clone"
        "RENAME"        = "Edit"
        "EDIT"          = "Edit"
        "MODIFY"        = "Edit"
        "UPDATE"        = "Update"
        "REFRESH"       = "Refresh"
        "RELOAD"        = "Refresh"
        "SYNC"          = "Sync"
        "SYNCHRONIZE"   = "Sync"
        "BACKUP"        = "DatabaseSync"
        "RESTORE"       = "Restore"      # Undelete
        "UNDELETE"      = "Restore"
        "UNTRASH"       = "Restore"
        "NORMALIZE"     = "Normalize"    # Normalize screen size
        "FORMAT"        = "Disk"
        "COMPRESS"      = "FileArchive"
        "DECOMPRESS"    = "FileArchive"
        "ARCHIVE"       = "FileArchive"
        "EXTRACT"       = "FileArchive"

        # ===========================================================================
        # OPERAÇÕES DE DISCO & STORAGE
        # ===========================================================================
        "DISKPART"      = "Disk"
        "CHKDSK"        = "Refresh"
        "WINFR"         = "Save"
        "FSUTIL"        = "Settings"
        "STORDIAG"      = "Bug"
        "VOLUME"        = "Disk"
        "PARTITION"     = "Disk"
        "MOUNT"         = "Disk"
        "DISMOUNT"      = "Eject"
        "DRIVE"         = "Disk"
        "STORAGE"       = "Disk"
        "SSD"           = "DiskSSD"
        "HDD"           = "DiskHDD"
        "USB"           = "DiskUSB"
        "NETWORK_DRIVE" = "DiskNetwork"
        "NAS"           = "DiskNetwork"

        # ===========================================================================
        # REDE & CONECTIVIDADE
        # ===========================================================================
        "NET_MGR"       = "Network"
        "NETWORK"       = "Network"
        "INTERNET"      = "Network"
        "WIFI"          = "NetworkWireless"
        "ETHERNET"      = "NetworkWired"
        "CONNECT"       = "Link"
        "DISCONNECT"    = "Unlink"
        "PING"          = "Network"
        "TRACEROUTE"    = "Network"
        "DNS"           = "Network"
        "DHCP"          = "Network"
        "FIREWALL"      = "Shield"
        "PROXY"         = "Network"
        "VPN"           = "Lock"
        "SSH"           = "Terminal"
        "FTP"           = "Network"
        "HTTP"          = "Network"
        "API"           = "Network"
        "WEBHOOK"       = "Network"

        # ===========================================================================
        # BANCO DE DADOS & DADOS
        # ===========================================================================
        "DATABASE"      = "Database"
        "DB"            = "Database"
        "SQL"           = "Database"
        "QUERY"         = "Search"
        "SELECT"        = "Search"
        "INSERT"        = "New"
        "UPDATE_DB"     = "Update"
        "DELETE_DB"     = "Trash"
        "SCHEMA"        = "Database"
        "TABLE"         = "Database"
        "INDEX"         = "Database"
        "MIGRATE"       = "Sync"
        "SEED"          = "Database"
        "ROLLBACK"      = "Undo"

        # ===========================================================================
        # POWERSHELL & SCRIPTING
        # ===========================================================================
        "ENGINE_MODE"   = "Terminal"
        "POWERSHELL"    = "PSPrompt"
        "PS"            = "PSPrompt"
        "SCRIPT"        = "FileCode"
        "MODULE"        = "PSModule"
        "FUNCTION"      = "PSFunction"
        "CMDLET"        = "PSFunction"
        "VARIABLE"      = "PSVariable"
        "ALIAS"         = "PSAlias"
        "PROFILE"       = "PSProfile"
        "RUNSPACE"      = "PSRunspace"
        "JOB"           = "PSJob"
        "PIPELINE"      = "PSPipeline"
        "EXECUTE"       = "Run"
        "RUN"           = "Run"
        "INVOKE"        = "Run"
        "CALL"          = "Run"
        "TEST"          = "Test"
        "DEBUG"         = "Debug"
        "TRACE"         = "Debug"
        "VERBOSE"       = "PSVerbose"
        "WARNING"       = "PSWarning"
        "ERROR_PS"      = "PSError"

        # ===========================================================================
        # DESENVOLVIMENTO & DEVOPS
        # ===========================================================================
        "BUILD"         = "Build"
        "COMPILE"       = "Build"
        "DEPLOY"        = "Deploy"
        "PUBLISH"       = "Deploy"
        "RELEASE"       = "Deploy"
        "VERSION"       = "Tag"
        "TAG"           = "Tag"
        "BRANCH"        = "Network"
        "COMMIT"        = "Save"
        "PUSH"          = "Upload"
        "PULL"          = "Download"
        "MERGE"         = "Sync"
        "REBASE"        = "Sync"
        "DIFF"          = "Search"
        "LOG"           = "FileLog"
        "CHANGELOG"     = "FileLog"
        "ISSUE"         = "Bug"
        "BUG"           = "Bug"
        "FIX"           = "Checkmark"
        "FEATURE"       = "StarFull"
        "HOTFIX"        = "Fire"
        "PATCH"         = "FileCode"

        # ===========================================================================
        # SEGURANÇA & AUTENTICAÇÃO
        # ===========================================================================
        "AUTH"          = "Key"
        "AUTHENTICATE"  = "Key"
        "LOGIN"         = "User"
        "LOGOUT"        = "Power"
        "SIGN_IN"       = "User"
        "SIGN_OUT"      = "Power"
        "REGISTER"      = "New"
        "PASSWORD"      = "InputPassword"
        "TOKEN"         = "Key"
        "CERTIFICATE"   = "Certificate"
        "ENCRYPT"       = "Lock"
        "DECRYPT"       = "Unlock"
        "HASH"          = "Key"
        "SIGN"          = "Certificate"
        "VERIFY"        = "Checkmark"
        "AUDIT"         = "Shield"
        "PERMISSION"    = "Lock"
        "ROLE"          = "Admin"
        "ADMIN"         = "Admin"
        "GUEST"         = "Guest"

        # ===========================================================================
        # UI/UX & INTERFACE
        # ===========================================================================
        "THEME"         = "Palette"
        "LANGUAGE"      = "Chat"
        "LOCALE"        = "Chat"
        "TRANSLATE"     = "Chat"
        "LAYOUT"        = "WindowTile"
        "VIEW"          = "Search"
        "ZOOM_IN"       = "Zoom"
        "ZOOM_OUT"      = "Zoom"
        "FULLSCREEN"    = "WindowFull"
        "MINIMIZE"      = "Minimize"
        "MAXIMIZE"      = "Maximize"
        "TILE"          = "WindowTile"
        "SPLIT"         = "WindowSplitV"
        "TAB"           = "TabNew"
        "PANEL"         = "WindowTile"
        "SIDEBAR"       = "Menu"
        "TOOLBAR"       = "Tools"
        "STATUSBAR"     = "Info"
        "NOTIFICATION"  = "Info"
        "ALERT"         = "Warning"
        "TOOLTIP"       = "Help"
        "MODAL"         = "WindowFull"
        "DIALOG"        = "WindowFull"

        # ===========================================================================
        # AÇÕES DE EDIÇÃO & HISTÓRICO
        # ===========================================================================
        "UNDO"          = "Undo"
        "REDO"          = "Redo"
        "REVERT"        = "Undo"
        "RESET"         = "Refresh"
        "CLEAR"         = "PSClear"
        "ERASE"         = "Trash"
        "SELECT_ALL"    = "Checkmark"
        "DESELECT"      = "Crossmark"
        "FIND"          = "Search"
        "REPLACE"       = "Edit"
        "HIGHLIGHT"     = "StarFull"
        "BOOKMARK"      = "Bookmark"
        "FAVORITE"      = "HeartFull"
        "STAR"          = "StarFull"
        "PIN"           = "Bookmark"
        "UNPIN"         = "Bookmark"

        # ===========================================================================
        # MÍDIA & MULTIMÍDIA
        # ===========================================================================
        "PLAY"          = "Play"
        "PAUSE"         = "Pause"
        "STOP"          = "Stop"
        "RECORD"        = "Record"
        "EJECT_MEDIA"   = "Eject"
        "VOLUME_UP"     = "VolumeMax"
        "VOLUME_DOWN"   = "VolumeMin"
        "MUTE"          = "Mute"
        "MIC"           = "MicOn"
        "CAMERA"        = "CameraOn"
        "SCREENSHOT"    = "CameraOn"
        "CAPTURE"       = "CameraOn"
        "IMAGE"         = "File"
        "VIDEO"         = "File"
        "AUDIO"         = "File"
        "DOCUMENT"      = "File"
        "PDF"           = "FileCode"

        # ===========================================================================
        # FERRAMENTAS & UTILITÁRIOS ESPECÍFICOS
        # ===========================================================================
        "SYNC_START"    = "Play"
        "TAG_PREPARE"   = "Tag"
        "ROBO_CFG"      = "Edit"
        "DEFAULT_OUT"   = "Folder"
        "ROBOCOPY"      = "Copy"
        "DISK_MGR"      = "Disk"
        "REGISTRY"      = "Settings"
        "SERVICES"      = "Service"
        "PROCESSES"     = "CPU"
        "MEMORY_MGR"    = "Memory"
        "EVENT_LOG"     = "FileLog"
        "TASK_SCHEDULER"= "Calendar"
        "POWER_SHELL"   = "Terminal"

        # ===========================================================================
        # ESTADOS & INDICADORES
        # ===========================================================================
        "READY"         = "Ready"
        "IDLE"          = "Idle"
        "BUSY"          = "Processing"
        "LOADING"       = "Loading"
        "WAITING"       = "Waiting"
        "SUCCESS"       = "Success"
        "OK"            = "Success"
        "DONE"          = "Success"
        "COMPLETE"      = "Success"
        "FAILED"        = "Failure"
        "ERROR"         = "Failure"
        "WARNING_STATE" = "Warning"
        "PENDING"       = "Waiting"
        "QUEUED"        = "Waiting"
        "RUNNING"       = "Play"
        "STOPPED"       = "Stop"
        "PAUSED_STATE"  = "Pause"
        "ENABLED"       = "CheckboxOn"
        "DISABLED"      = "CheckboxOff"
        "ACTIVE"        = "DotGreen"
        "INACTIVE"      = "DotGray"
        "ONLINE"        = "DotGreen"
        "OFFLINE"       = "DotRed"
        "AVAILABLE"     = "DotGreen"
        "UNAVAILABLE"   = "DotRed"

        # ===========================================================================
        # OPERAÇÕES EM LOTE & AUTOMAÇÃO
        # ===========================================================================
        "BATCH"         = "Package"
        "BULK"          = "Package"
        "MASS"          = "Package"
        "AUTOMATE"      = "Play"
        "SCHEDULE"      = "Calendar"
        "CRON"          = "Calendar"
        "TRIGGER"       = "Lightning"
        "WEBHOOK_TRIGGER"= "Network"
        "EVENT"         = "Sparkle"
        "REACT"         = "Sparkle"
        "CHAIN"         = "Link"
        "WORKFLOW"      = "PSPipeline"
        "PIPELINE_OP"   = "PSPipeline"

        # ===========================================================================
        # UTILITÁRIOS GERAIS (Fallbacks inteligentes)
        # ===========================================================================
        "UNKNOWN"       = "Unknown"
        "DEFAULT"       = "Placeholder"
        "GENERIC"       = "Placeholder"
        "MISC"          = "Placeholder"
        "OTHER"         = "Placeholder"
        "MORE"          = "Ellipsis"
        "OPTIONS"       = "Menu"
        "ACTIONS"       = "Tools"
        "TOOLS"         = "Tools"
        "UTILS"         = "Tools"
        "ADVANCED"      = "Settings"
        "EXPERT"        = "Admin"
        "BASIC"         = "User"
        "SIMPLE"        = "Checkmark"
        "QUICK"         = "Lightning"
        "FAST"          = "Lightning"
        "SLOW"          = "Timer"
        "PRECISE"       = "Target"
        "APPROXIMATE"   = "Target"
    }
}