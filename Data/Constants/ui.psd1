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
                        ClearFull = "$([char]27)[H$([char]27)[2J"; ClearToEOL = "$([char]27)[0K"; ClearToBOL = "$([char]27)[1K"
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

                # Separadores estruturais (longos) - ASCII fallbacks to avoid encoding issues
                SeparatorLong   = "-----------------------------------------------------------------"
                DoubleSepLong   = "================================================================="
                ThickSepLong    = "#################################################################"
                DottedSepLong   = "................................................................."
                DashedSepLong   = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
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
                Cyber      = @{ TL = "⟦"; TR = "⟧"; BL = "⟦"; BR = "⟧"; HL = "⎯"; VL = "⏐"; ML = "⊢"; MR = "⊣"; Cross = "⊞"; TeeUp = "⊥"; TeeDown = "⊤"; TeeLeft = "⊣"; TeeRight = "⊢"; Name = "Cyberpunk" }
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
                IconLevel          = 0
        }

        # ===========================================================================
        # 11. CYCLE LISTS (para opções com mais de dois estados)
        # ===========================================================================
        CycleLists           = @{
                I18N          = @('en-US', 'pt-BR')
                EngineMode    = @('EFFICIENCY', 'REDUNDANCY')
                ColorMode     = @('TrueColor', 'ANSI16')
                HydrationMode = @('graphic', 'unicode', 'ascii')
                IconLevel     = @(0, 1, 2)
                FrameStyle    = @('Classic', 'Rounded', 'Minimal', 'ASCII', 'Block', 'Retro', 'Cyber', 'Heavy', 'Dotted', 'Borderless', 'PowerShell')
                ProgressStyle = @('Default', 'Compact', 'BarOnly', 'Discrete', 'Braille', 'Line', 'Dot', 'Blocks')
                ThemePersona  = @('Cyber', 'Corporate', 'Hacker', 'Minimal', 'Retro', 'HighVis', 'PowerShell', 'RANDOM')
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
        Labels               = @{ IconLevels = @('Graphic', 'Unicode', 'ASCII') }

        Icons                = @{
                # --- Status & Alerts ---
                Success = @("✅", "✅︎", "[OK]"); Failure = @("❌", "✖", "[ERR]"); Warning = @("⚠️", "⚠", "[!]"); Info = @("ℹ️", "ℹ︎", "[i]")
                Question = @("❓", "⁇", "[?]"); Critical = @("💥", "☠︎︎", "[CRIT]"); Fatal = @("☢️", "☢︎", "[FATAL]"); Checkmark = @("✔️", "✔︎", "[V]")
                Crossmark = @("❎", "❎︎", "[X]"); Ellipsis = @("…", "…︎", "..."); Bullet = @("•", "∙", "*"); Separator = @("─", "─", "-")

                # --- Colored Status Dots ---
                DotRed = @("🔴", "●", "[!]"); DotGreen = @("🟢", "●", "[OK]"); DotYellow = @("🟡", "●", "[~]"); DotBlue = @("🔵", "●", "[i]")
                DotCyan = @("🔷", "◆", "[*]"); DotMagenta = @("🟣", "●", "[★]"); DotWhite = @("⚪", "○", "[ ]"); DotGray = @("⚫", "●", "[•]")
                DotOrange = @("🟠", "◆", "[O]"); DotHollow = @("⭕", "○", "( )")
                SquareRed = @("🟥", "■", "[X]"); SquareGreen = @("🟩", "■", "[OK]"); SquareYellow = @("🟨", "■", "[!]"); SquareBlue = @("🟦", "■", "[i]")

                # --- Status Badges & WIP ---
                BadgeNew = @("🆕", "🆕︎", "[NEW]"); BadgeUpdated = @("🔄", "🔄︎", "[UPD]"); BadgeHot = @("🔥", "🔥︎", "[HOT]"); BadgeCold = @("❄️", "❄", "[CLD]")
                BadgeLock = @("🔐", "🔐︎", "[LCK]"); BadgeUnlock = @("🔓", "🔓︎", "[OPN]"); BadgeBeta = @("🧪", "β", "[BETA]"); BadgeStable = @("⚓", "⎈", "[STABLE]")
                WIP = @("🚧", "⊘", "[WIP]")

                # --- THEMES & PERSONAS ---
                ThemeCyber = @("🪩", "◍", "[CYB]"); ThemeCorporate = @("🎩", "🎩︎", "[COR]"); ThemeHacker = @("🕶️", "🕶︎", "[HCK]"); ThemeMinimal = @("👕", "🖽", "[MIN]")
                ThemeRetro = @("🕹️", "⎚", "[RET]"); ThemeHighVis = @("⛑️", "⛑︎", "[HVS]"); ThemePowerShell = @("📸", "⌘", "[PS]"); ThemeDark = @("🌙", "⏾", "[DRK]")
                ThemeLight = @("☀️", "☀", "[LGT]"); Palette = @("🎨", "☱", "[THM]"); Persona = @("🪞", "🪞︎", "[PSN]"); Random = @("🎲", "⚄", "[RDM]"); ColorPicker = @("🖌️", "🖌︎", "[PCK]")
                ThemeMenu = @("🍭", "☱", "[THM]")

                # --- FORENSICS & DATA RECOVERY ---
                Corrupted = @("🚫", "⚠", "[COR]"); Overwritten = @("🔄", "🔄︎", "[OW]"); Unallocated = @("⬜", "◻", "[UNA]"); Allocated = @("⬛", "◼", "[ALC]")
                SlackSpace = @("🔲", "▤", "[SLK]"); Fragmented = @("⚙️", "⊘", "[FRG]"); Intact = @("💎", "◈", "[OK]"); Partial = @("🩹", "±", "[PRT]")
                Encrypted = @("🔐", "🔐︎", "[ENC]"); Decrypted = @("🔓", "🔓︎", "[DEC]"); Deleted = @("🗑️", "✖", "[DEL]"); Recovered = @("♻️", "♻︎", "[REC]")
                Unrecoverable = @("⚰️", "⊝", "[NREC]"); Tampered = @("⚠️", "⚠", "[TAMP]"); Orphaned = @("🪾", "⊘", "[ORF]")
                Carve = @("🧩", "✂", "[CRV]"); ImageDisk = @("💿", "💿︎", "[IMG]"); Verify = @("☑️", "✔", "[VRF]"); WriteBlock = @("🛑", "⊘", "[WB]")
                HashCalc = @("🔀", "#", "[HASH]"); Reconstruct = @("🧩", "✂", "[RCN]"); Wipe = @("🧹", "⌧", "[WIP]"); Scrub = @("🧽", "▒", "[SCR]")
                BytePatch = @("🩹", "±", "[PAT]"); BruteForce = @("🛠️", "⚒", "[BRF]"); XRayScan = @("🩻", "☠", "[XRY]"); FingerprintID = @("🆔", "⍝", "[FIN]")
                MFT = @("🗃️", "🗃︎", "[MFT]"); Inode = @("🔢", "🔢︎", "[INOD]"); BootSector = @("🦾", "⚙", "[BOOT]"); Superblock = @("🖲️", "🖲︎", "[SUP]")
                GPTHeader = @("📐", "📐︎", "[GPT]"); MBR = @("📟", "📟︎", "[MBR]"); FATTable = @("🗂️", "▦", "[FAT]"); Journal = @("📓", "📓︎", "[JRN]")
                BTree = @("🌲", "🌲︎", "[BTRE]"); Extent = @("⤢", "⤢", "[EXT]"); NestedArchive = @("🪆", "◫", "[NST]")
                HexView = @("🔢", "🔢︎", "[HEX]"); BinaryView = @("🖲️", "🖲︎", "[BIN]"); Entropy = @("☄️", "☄", "[ENT]"); Cluster = @("🪼", "❖", "[CLU]")
                Sector = @("🧫", "☉", "[SEC]"); Block = @("💢", "💢︎", "[BLK]")
                Color256 = @("🌈", "☱", "[256]"); Color16 = @("🎨", "🖽", "[16]")
                BadSector = @("❌", "✖", "[BAD]"); PendingSector = @("⚠️", "⚠", "[PEN]"); Reallocated = @("🔄", "🔄︎", "[REA]"); SSDWear = @("📉", "⊖", "[WRN]")
                SMARTWarn = @("🚨", "⊘", "[SMR]"); HeadCrash = @("☣️ ", "☣", "[HDC]")
                Evidence = @("💼", "💼︎", "[EVD]"); ChainOfCustody = @("⛓️", "⛓︎", "[COC]"); Sealed = @("🔏", "🔏︎", "[SEAL]"); IDCard = @("🪪", "🖹", "[ID]")

                # --- LAYOUTS & ADVANCED NAVIGATION ---
                ArrowUp = @("⬆️", "↑", "[^]"); ArrowDown = @("⬇️", "↓", "[v]"); ArrowLeft = @("⬅️", "←", "[<]"); ArrowRight = @("➡️", "→", "[>]")
                ArrowDoubleUp = @("⏫", "⇈", "[^^]"); ArrowDoubleDown = @("⏬", "⇊", "[vv]"); ArrowDoubleLeft = @("⬅️", "⇇", "[<<]"); ArrowDoubleRight = @("➡️", "⇉", "[>>]")
                ArrowSync = @("🔃", "🔃︎", "[<>]"); ArrowDiagonalUR = @("↗️", "↗︎", "[/^]"); ArrowDiagonalDR = @("↘️", "↘︎", "[\v]"); ArrowCurveRight = @("⤴️", "⤴︎", "[^>]")
                ArrowCurveLeft = @("⤵️", "⤵︎", "[<v]"); ArrowTarget = @("➜", "➜︎", "[->]"); ArrowRedirect = @("⤳", "⇝", "[>>]"); ArrowJump = @("⤴️", "↱", "[JMP]")
                CaretUp = @("▲", "▲︎", "[^]"); CaretDown = @("▼", "▼︎", "[v]"); CaretLeft = @("◀", "◀︎", "[<]"); CaretRight = @("▶", "▶︎", "[>]")
                CaretSmallUp = @("▴", "▵", "[^]"); CaretSmallDown = @("▾", "▿", "[v]"); CaretSmallLeft = @("◂", "◃", "[<]"); CaretSmallRight = @("▸", "▹", "[>]")
                Compass = @("🧭", "⌖", "[R]"); CompassN = @("🧭N", "◧", "[N]"); CompassS = @("🧭S", "◨", "[S]"); CompassE = @("🧭E", "◩", "[E]")
                CompassW = @("🧭W", "◪", "[W]"); Home = @("🏠", "🏠︎", "[H]"); End = @("🏁", "⚑", "[E]"); Jump = @("⤴️", "↱", "[J]")
                Return = @("↩️", "↵", "[RET]"); Breadcrumb = @("❯", "›", ">"); NextTab = @("⇥", "⇨", "[>>]"); PrevTab = @("⇤", "⇦", "[<<]")

                # --- UI CONTROLS, FORMS & BRACKETS ---
                Menu = @("☰", "≡", "[MENU]"); Submenu = @("▸", "▹", "[>]"); Back = @("◂", "◃", "[<]"); Close = @("✖️", "✖︎", "[X]")
                Minimize = @("◷", "—", "[_]"); Maximize = @("🗖", "□", "[#]"); Normalize = @("🗗", "▣", "[O]"); Help = @("❔", "⁇", "[?]")
                WindowTile = @("🪟", "⊞", "[TILE]"); WindowSplitH = @("⇹", "⇹", "[SPLITH]"); WindowSplitV = @("⤢", "⇕", "[SPLITV]"); WindowFull = @("⛶", "⎔", "[FULL]")
                TabNew = @("🗐", "+", "[+TAB]"); TabClose = @("🗙", "⊠", "[X]"); FocusIn = @("🔍", "⊕", "[IN]"); FocusOut = @("🔎", "⊖", "[OUT]")
                Chat = @("💬", "💬︎", "[MSG]"); Comment = @("💭", "💭︎", "[CMT]"); Mention = @("🔖", "@", "[@]")
                CheckboxOn = @("☑️", "☑︎", "[X]"); CheckboxOff = @("🔳", "◻", "[ ]"); CheckboxHalf = @("🟪", "⊟", "[-]");
                RadioOn = @("🔘", "◉", "(O)"); RadioOff = @("⚪", "○", "( )"); ToggleOn = @("🟢", "○", "[ON]"); ToggleOff = @("🔴", "○", "[OFF]")
                SliderStart = @("🔹", "⊢", "[o]"); SliderMid = @("─", "—", "[-]"); SliderEnd = @("🔸", "⊣", "[●]"); SliderHandle = @("🔶", "◈", "[H]")
                InputText = @("📝", "📝︎", "[TXT]"); InputNumber = @("🔢", "🔢︎", "[NUM]"); InputDate = @("📅", "◪", "[DATE]"); InputEmail = @("📧", "📧︎", "[EMAIL]")
                InputPassword = @("🔑", "⚷", "[PWD]"); Dropdown = @("▾", "▿", "[▼]"); Listbox = @("📋", "▤", "[LIST]"); Combobox = @("🗂️", "⊟", "[COMBO]")
                BracketAngle = @("⟨⟩", "⟨⟩︎", "<>"); BracketSquare = @("⟦⟧", "⟦⟧︎", "[]"); BracketCurly = @("⦃⦄", "⦃⦄︎", "{}"); BracketParen = @("⸨⸩", "⑉⑊", "()")

                # --- VEHICLES & TRANSPORT ---
                Rocket = @("🚀", "🚀︎", "[RCK]"); Helicopter = @("🚁", "⍙", "[HEL]"); Locomotive = @("🚂", "🛲", "[LOC]"); HighSpeedTrain = @("🚄", "🚄︎", "[HST]")
                BulletTrain = @("🚅", "🚅︎", "[BLT]"); Metro = @("🚇", "⊕", "[MET]"); Station = @("🚉", "◱", "[STA]"); Bus = @("🚌", "🚌︎", "[BUS]")
                BusStop = @("🚏", "⊡", "[BST]"); Ambulance = @("🚑", "🚑︎", "[AMB]"); FireEngine = @("🚒", "🚒︎", "[FIR]"); PoliceCar = @("🚓", "⛨", "[POL]")
                Taxi = @("🚕", "⛟", "[TAX]"); Automobile = @("🚗", "⛟", "[CAR]"); SUV = @("🚙", "⛟", "[SUV]"); DeliveryTruck = @("🚚", "⛟", "[TRK]")
                Tractor = @("🚜", "⛟", "[TRC]"); Ship = @("🚢", "⛴", "[SHP]"); Speedboat = @("🚤", "⛴", "[BOT]"); AirplaneDepart = @("🛫", "🛫︎", "[DEP]")
                AirplaneArrive = @("🛬", "🛬︎", "[ARR]"); Bicycle = @("🚲", "⋒", "[BKE]"); Scooter = @("🛵", "⋗", "[SCV]"); FlyingSaucer = @("🛸", "🛸", "[UFO]")
                Skateboard = @("🛹", "⋖", "[SKB]"); PickupTruck = @("🛻", "⛟", "[PCK]")

                # --- TRAFFIC, SIGNS & MAPS ---
                TrafficLightH = @("🚥", "≬", "[TLH]"); TrafficLightV = @("🚦", "⍙", "[TLV]"); NoSmoking = @("🚭", "⌀", "[NSM]"); NoLittering = @("🚯", "⌀", "[NLT]")
                PotableWater = @("🚰", "☵", "[WTR]"); NoPedestrians = @("🚷", "⌀", "[NPED]"); ChildrenCrossing = @("🚸", "⌅", "[KID]"); MensRoom = @("🚹", "♂", "[M]")
                WomensRoom = @("🚺", "♀", "[W]"); Restroom = @("🚻", "⚲", "[WC]"); BabySymbol = @("🚼", "⍙", "[BBY]"); PassportControl = @("🛂", "🛂︎", "[PAS]")
                Customs = @("🛃", "⊗", "[CST]"); BaggageClaim = @("🛄", "🛄︎", "[BAG]"); LeftLuggage = @("🛅", "🛅︎", "[LUG]"); ProhibitedSign = @("🛇", "⌀", "[PRO]")
                CircledInfo = @("🛈", "ⓘ", "[CINF]"); PlaceOfWorship = @("🛐", "♜", "[TEMP]"); StopSign = @("🛑", "⏹", "[STP]"); Wireless = @("🛜", "ᯤ", "[WIF]")
                Wheel = @("🛞", "◎", "[WHL]"); RingBuoy = @("🛟", "◎", "[BUOY]"); OilDrum = @("🛢️", "🛢︎", "[OIL]"); Motorway = @("🛣", "⚌", "[MWY]")
                RailwayTrack = @("🛤", "🛤︎", "[RWY]")

                # --- SYSTEM, HARDWARE & TOOLS ---
                Folder = @("📁", "📁︎", "[DIR]"); FolderOpen = @("📂", "◪", "[OPN]"); FolderSync = @("⊞", "∲", "[SYNCDIR]"); FolderSecure = @("☗", "⛨", "[SECDIR]")
                File = @("📄", "📄︎", "[FILE]"); FileCode = @("⌨️", "⌨︎", "[CODE]"); FileConfig = @("⚙️", "⚙︎", "[CFG]"); FileLog = @("📜", "⌹", "[LOG]")
                FileTemp = @("⌫", "⏱", "[TMP]"); FileArchive = @("🗜️", "🗜︎", "[ZIP]"); FileExec = @("⚡", "⚡︎", "[EXE]"); FileMedia = @("🎬", "🎬︎", "[MEDIA]")
                Database = @("🏛️", "🏛︎", "[DB]"); DatabaseSync = @("⟳", "⇌", "[DBSYNC]"); Server = @("🖥️", "🖥︎", "[SRV]"); ServerRack = @("🗄️", "🗄︎", "[RACK]")
                Network = @("🌐", "🖧", "[NET]"); NetworkWired = @("🔌", "🔌︎", "[ETH]"); NetworkWireless = @("📶", "📶︎", "[WIFI]"); NetworkCloud = @("☁️", "☁︎", "[CLD]")
                NetworkLocal = @("🏠", "🏠︎", "[LAN]"); Router = @("📡", "📡︎", "[RTR]")
                Disk = @("💾", "🖫", "[DISK]"); DiskSSD = @("⚡", "⚡︎", "[SSD]"); DiskHDD = @("💽", "💽︎", "[HDD]"); DiskUSB = @("🔌", "🔌︎", "[USB]")
                DiskNetwork = @("🔮", "⛃", "[NAS]")
                Memory = @("🧠", "☷", "[RAM]"); Chip = @("🔲", "▦", "[CHIP]"); CPU = @("⚙️", "⚙︎", "[CPU]"); GPU = @("🎮", "▤", "[GPU]")
                Power = @("⏻", "⌽", "[PWR]"); BatteryFull = @("🔋", "▮", "[FULL]"); BatteryHalf = @("🪫", "⌸", "[HALF]"); BatteryLow = @("🪫", "▯", "[LOW]")
                Charging = @("⚡", "⚡︎", "[CHG]")
                Lock = @("🔒", "🔒︎", "[LCK]"); Unlock = @("🔓", "🔓︎", "[OPN]"); Key = @("🔑", "🔑︎", "[KEY]"); KeyPair = @("🔐", "🔐︎", "[PAIR]")
                Certificate = @("📜🔐", "📜🔐︎", "[CERT]"); Shield = @("🛡️", "⛨", "[SHD]"); Bug = @("🪲", "🪲︎", "[BUG]")
                EyeOpen = @("👁️", "👁︎", "[SEE]"); EyeClosed = @("👁️‍🗨️", "⚇", "[BLIND]")
                User = @("👤", "☻", "[USR]"); Users = @("👥", "☻☻", "[GRP]"); Admin = @("👑", "♛", "[ADM]"); Guest = @("🎭", "☺", "[GST]")
                Service = @("⚙️", "⚙︎", "[SVC]")
                Terminal = @("💻", "♳", "[CLI]"); Container = @("📦", "⎈", "[DOCKER]"); API = @("🔌", "🔌︎", "[API]"); Webhook = @("🪝", "🪝︎", "[HOOK]")
                Robot = @("🤖", "⚙", "[BOT]")
                Clock = @("⏱️", "⏲", "[TIME]"); Calendar = @("📅", "◪", "[DATE]"); Timer = @("⏲️", "◵", "[TMR]"); Stopwatch = @("⏰", "⏲", "[STOP]")
                Hourglass = @("⏳", "⏳︎", "[WAIT]")
                Settings = @("⚙️", "⚙︎", "[SET]"); Config = @("🔧", "🔧︎", "[CFG]"); Preferences = @("🎛️", "⎚", "[PREF]")
                Target = @("🎯", "🎯︎", "[TGT]"); Search = @("🔍", "⌕", "[FND]"); Filter = @("🔽", "◂", "[FLT]"); SortAsc = @("🔼", "▵", "[ASC]")
                SortDesc = @("🔽", "▿", "[DESC]"); GroupBy = @("🗂️", "⊟", "[GRP]"); Refresh = @("🔄", "🔄︎", "[RFR]"); Sync = @("🔁", "⇌", "[SYNC]")
                Update = @("⬆️", "⇡", "[UPD]"); Upgrade = @("🚀", "⇈", "[UPG]")
                Play = @("▶️", "►", "[>]"); Pause = @("⏸️", "‖", "[||]"); Stop = @("⏹️", "■", "[STOP]"); Record = @("⏺️", "●", "[REC]")
                Eject = @("⏏️", "⏏︎", "[EJT]"); Next = @("⏭️", "⏭︎", "[>>]"); Prev = @("⏮️", "⏮︎", "[<<]"); Shuffle = @("🔀", "🔀︎", "[SHF]")
                Repeat = @("🔁", "🔁︎", "[RPT]"); VolumeMax = @("🔊", "🕪", "[MAX]"); VolumeMed = @("🔉", "🕩", "[MED]"); VolumeMin = @("🔈", "🕨", "[MIN]")
                VolumeMute = @("🔇", "🔇︎", "[MUTE]"); MicOn = @("🎤", "🎤︎", "[MIC_ON]"); MicOff = @("🎤🚫", "🎤︎🚫︎", "[MIC_OFF]"); CameraOn = @("📷", "◘", "[CAM_ON]")
                CameraOff = @("📷🚫", "📷🚫︎", "[CAM_OFF]")
                Print = @("🖨️", "⎙", "[PRT]"); Scan = @("📠", "⎚", "[SCN]"); Fax = @("📠", "⎚", "[FAX]")
                MailSend = @("📤", "ᯓ➤", "[SENT]"); MailReceive = @("📥", "📥︎", "[INBOX]"); MailDraft = @("📝", "📝︎", "[DRAFT]"); MailArchive = @("🗄️📧", "🗄📧︎", "[ARCH]")
                Share = @("🔗", "☍", "[SHR]"); Link = @("🔗", "☍", "[LNK]"); Unlink = @("✂️", "✂︎", "[UNLK]")
                Copy = @("📋", "⎘", "[CPY]"); Cut = @("✂️", "✂︎", "[CUT]"); Paste = @("📌", "🖈", "[PST]"); Clone = @("⊹", "⊹︎", "[CLN]")
                Save = @("💾", "🖫", "[SAV]"); SaveAs = @("💾✏️", "🖫✏︎", "[SAVAS]"); Trash = @("🗑️", "🗑", "[DEL]"); Delete = @("🗑️", "🗑︎", "[DEL]")
                Restore = @("🔄🗑️", "🔄︎🗑︎", "[RST]"); Undo = @("↩️", "↶", "[UNDO]"); Redo = @("↪️", "↷", "[REDO]"); New = @("🆕", "★", "[NEW]")
                Open = @("📂", "◪", "[OPEN]"); Edit = @("✍", "✍︎", "[EDIT]"); Load = @("📂", "◪", "[LOAD]"); Import = @("📥", "⇊", "[IMP]")
                Export = @("📤", "⇈", "[EXP]"); Upload = @("⤒", "⇡", "[UPL]"); Download = @("⤓", "⇣", "[DWN]"); Install = @("💿", "💿︎", "[INS]")
                Uninstall = @("💽", "💽︎⚡︎", "[RMV]"); Execute = @("⚡", "⚡︎", "[EXEC]"); Build = @("🛠️", "🛠︎", "[BLD]"); Deploy = @("🚀", "🚀︎", "[DEP]")
                Test = @("🧪", "⚗", "[TST]"); Write = @("✍", "✍︎", "[WRT]")
                Tools = @("🧰", "🧰︎", "[TLS]"); Wrench = @("🔧", "🔧︎", "[WRN]"); Hammer = @("🔨", "☭", "[HMR]"); Pickaxe = @("⛏️", "⛏︎", "[PCK]")
                Construction = @("🏗️", "🏗︎", "[BLD]"); Screwdriver = @("🪛", "🪛︎", "[SCW]"); Saw = @("🪚", "🪚︎", "[SAW]"); Axe = @("🪓", "🪓︎", "[AXE]")
                Bucket = @("🪣", "֎", "[BKT]"); Plunger = @("🪠", "⍙", "[PLG]"); Broom = @("🧹", "🧹︎", "[BRM]"); Sponge = @("🧽", "🧽︎", "[SPN]")
                Funnel = @("⏳", "⏳︎", "[FNL]")
                Fire = @("🔥", "🔥︎", "[FIRE]"); Lightning = @("⚡", "⚡︎", "[LTN]"); Sparkle = @("✨", "⁂", "[*]")

                # --- GIT & DEVOPS ICONS ---
                GitBranch = @("🌿", "⎇", "[BR]"); CodeCommit = @("📌", "🖈", "[COMMIT]"); GitPush = @("⬆️", "⇡", "[PUSH]"); GitPull = @("⬇️", "⇣", "[PULL]")
                GitMerge = @("🔀", "⇶", "[MERGE]")

                # --- CLOTHING & ACCESSORIES ---
                GraduationCap = @("🎓", "◬", "[GRAD]"); TopHat = @("🎩", "🎩︎", "[HAT]"); Backpack = @("🎒", "🎒︎", "[BAG]"); Dress = @("👗", "◌", "[DRS]")
                Bikini = @("👙", "◍", "[BIK]"); Purse = @("👛", "⊚", "[PRS]"); ManShoe = @("👞", "👞︎", "[SHO]"); RunningShoe = @("👟", "👟︎", "[RUN]")
                ClutchBag = @("👝", "⊡", "[CLU]"); Handbag = @("👜", "⊠", "[HAN]"); TShirt = @("👕", "◦", "[TSH]"); WomansSandal = @("👡", "⊓", "[SND]")
                Crown = @("👑", "👑︎", "[CRN]"); Lipstick = @("💄", "⌕", "[LIP]"); WomansClothes = @("👚", "◬", "[WCL]"); WomansBoot = @("👢", "⊟", "[WBT]")
                Ring = @("💍", "◉", "[RNG]"); Kimono = @("👘", "◈", "[KIM]"); GemStone = @("💎", "◈", "[GEM]"); Glasses = @("👓", "⌐", "[GLS]")
                Jeans = @("👖", "◭", "[JNS]"); Necktie = @("👔", "⌙", "[TIE]"); HighHeel = @("👠", "⊔", "[HEL]"); PrayerBeads = @("📿", "⊗", "[PRAY]")
                WomansHat = @("👒", "◊", "[WHAT]"); Sunglasses = @("🕶️", "🕶︎", "[SUN]"); ShoppingBags = @("🛍️", "⊟⊟", "[SHOP]"); BilledCap = @("🧢", "⊓", "[CAP]")
                SafetyVest = @("🦺", "⛨", "[SAFE]"); Scarf = @("🧣", "⌇", "[SCRF]"); Gloves = @("🧤", "🧤︎", "[GLV]"); Coat = @("🧥", "🧥︎", "[COAT]")
                Socks = @("🧦", "⌵", "[SCK]"); Sari = @("🥻", "◬", "[SARI]"); HikingBoot = @("🥾", "⊟", "[HIKE]"); LabCoat = @("🥼", "🥼︎", "[LAB]")
                FlatShoe = @("🥿", "🖦", "[FLAT]"); Goggles = @("🥽", "◔", "[GOG]"); MilitaryHelmet = @("🪖", "⛨", "[MIL]"); BalletShoes = @("🩰", "🖦", "[BALL]")
                ThongSandal = @("🩴", "⊣", "[THONG]"); Swimsuit = @("🩱", "⌆", "[SWIM]"); Briefs = @("🩲", "▯", "[BRF]"); Shorts = @("🩳", "▭", "[SHRT]")
                FoldingFan = @("🪭", "ᨐ", "[FAN]"); HairPick = @("🪮", "ᨐ", "[PICK]"); RescueHelmet = @("⛑️", "⛑︎", "[RSC]")

                # --- MUSIC & AUDIO ---
                Loudspeaker = @("📢", "⌲", "[SPK]"); Megaphone = @("📣", "⌻", "[MEGA]"); PostalHorn = @("📯", "⌺", "[HORN]"); MutedSpeaker = @("🔇", "🔇︎", "[MUTE]")
                SpeakerLow = @("🔈", "◬", "[SPK1]"); SpeakerMed = @("🔉", "◭", "[SPK2]"); SpeakerHigh = @("🔊", "◮", "[SPK3]"); Bell = @("🔔", "🔔︎", "[BELL]")
                BellSlash = @("🔕", "🔕︎", "[NOBEL]"); ControlKnobs = @("🎛️", "🎛︎", "[KNOB]"); StudioMic = @("🎙️", "🎙︎", "[STUM]"); Microphone = @("🎤", "🎤︎︎", "[MIC]")
                LevelSlider = @("🎚️", "🎚︎", "[SLDR]"); MusicalNotes = @("🎶", "♪♫", "[NOTES]"); MusicalScore = @("🎼", "🎼︎", "[SCORE]"); MusicalNote = @("🎵", "♪", "[NOTE]")
                Headphone = @("🎧", "☊", "[HP]"); Radio = @("📻", "⌻", "[RAD]"); Violin = @("🎻", "🎻︎", "[VLN]"); Trumpet = @("🎺", "🎺︎", "[TRU]")
                Saxophone = @("🎷", "⍛", "[SAX]"); Keyboard = @("🎹", "🎹︎", "[KEYB]"); Guitar = @("🎸", "🎸︎", "[GTR]"); Drum = @("🥁", "◉", "[DRUM]")
                Banjo = @("🪕", "🪕︎", "[BANJ]"); Accordion = @("🪗", "⌇⌇", "[ACC]"); LongDrum = @("🪘", "◉", "[LDRU]"); Flute = @("🪈", "⚱", "[FLT]")
                Maracas = @("🪇", "⊡", "[MARA]"); Harp = @("🪉", "🪉", "[HARP]")

                # --- OFFICE & STATIONERY ---
                TelephoneReceiver = @("📞", "🕽", "[PHONE]"); FaxMachine = @("📠", "⎚", "[FAX]"); MobilePhone = @("📱", "🖁", "[MOB]"); Pager = @("📟", "⌨", "[PGR]")
                MobileArrow = @("📲", "⇡", "[MOBA]"); Telephone = @("☎️", "🕿", "[TEL]"); Dvd = @("📀", "💿︎", "[DVD]"); OpticalDisk = @("💿", "💿︎", "[CD]")
                FloppyDisk = @("💾", "🖫", "[FLOP]"); ComputerDisk = @("💽", "💽︎", "[HD]"); Laptop = @("💻", "💻︎", "[LAP]"); ComputerMouse = @("🖱️", "🖰", "[MOUSE]")
                Trackball = @("🖲️", "◉", "[TRK]"); Desktop = @("🖥️", "🖳", "[PC]"); Printer = @("🖨️", "⎙", "[PRN]"); Battery = @("🔋", "▮", "[BAT]")
                Plug = @("🔌", "🔌︎", "[PLUG]"); Abacus = @("🧮", "🧮︎", "[ABAC]"); LowBattery = @("🪫", "▯", "[LBAT]"); KeyboardDev = @("⌨️", "⌨︎", "[KBD]")

                # --- MEDIA & ELECTRONICS ---
                MovieCamera = @("🎥", "◰", "[CAM]"); ClapperBoard = @("🎬", "🎬︎", "[ACT]"); Lantern = @("🏮", "◌", "[LAN]"); FilmFrames = @("🎞️", "🎞︎", "[FILM]")
                VideoCamera = @("📹", "◰", "[VID]"); CameraFlash = @("📸", "☎", "[CAMF]"); Camera = @("📷", "☎", "[CAM]"); LightBulb = @("💡", "◌", "[LAMP]")
                Television = @("📺", "📺︎", "[TV]"); Videocassette = @("📼", "◧", "[VHS]"); FilmProjector = @("📽️", "📽", "[PROJ]"); Candle = @("🕯️", "🕯", "[CNDL]")
                MagnifyRight = @("🔎", "⌕", "[MAG]"); MagnifyLeft = @("🔍", "🔍︎", "[MAG]"); Flashlight = @("🔦", "⌁", "[FLSH]"); DiyaLamp = @("🪔", "◌", "[DIY]")
                Label = @("🏷️", "🏷︎", "[LBL]"); BookmarkTabs = @("📑", "📑︎", "[BMT]"); Notebook = @("📓", "📓︎", "[NB]"); PageCurl = @("📃", "⌇", "[PC]")
                ClosedBook = @("📕", "📕︎", "[BOOK]"); Ledger = @("📒", "📒︎", "[LEDG]"); GreenBook = @("📗", "📗︎", "[GBK]"); NotebookDeco = @("📔", "📔︎", "[NBD]")
                OrangeBook = @("📙", "📙︎", "[OBK]"); OpenBook = @("📖", "◰", "[OPEN]"); BlueBook = @("📘", "📘︎", "[BBK]"); Scroll = @("📜", "⌇", "[SCRL]")
                Books = @("📚", "📚︎", "[LIBS]"); PageUp = @("📄", "📄︎", "[PAGE]"); Newspaper = @("📰", "📰︎", "[NEWS]"); RolledNewspaper = @("🗞️", "🗞︎", "[ROLL]")

                # --- MONEY & FINANCE ---
                MoneyWings = @("💸", "💸︎", "[MNY]"); PoundNote = @("💷", "£", "[GBP]"); ChartYen = @("💹", "¥", "[YEN]"); EuroNote = @("💶", "€", "[EUR]")
                DollarNote = @("💵", "$", "[USD]"); YenNote = @("💴", "¥", "[JPY]"); CreditCard = @("💳", "⌧", "[CC]"); MoneyBag = @("💰", "💰︎", "[BAG]")
                Receipt = @("🧾", "⌇", "[RCPT]"); Coin = @("🪙", "◉", "[COIN]"); Ticket = @("🎫", "🎫︎", "[TCK]")

                # --- MAIL & COMMUNICATION ---
                MailboxDown = @("📪", "◬", "[MBD]"); MailboxUp = @("📫", "◬", "[MBU]"); MailboxOpenUp = @("📬", "◬", "[MBOU]"); MailboxOpenDown = @("📭", "◬", "[MBOD]")
                Email = @("📧", "📧︎", "[EML]"); OutboxTray = @("📤", "⇡", "[OUT]"); InboxTray = @("📥", "⇣", "[IN]"); Package = @("📦", "📦︎", "[PKG]")
                IncomingEnvelope = @("📨", "📨︎", "[INEN]"); EnvelopeArrow = @("📩", "⇡", "[ENVA]"); Postbox = @("📮", "📮︎", "[POST]"); BallotBox = @("🗳️", "☑", "[VOTE]")
                Envelope = @("✉️", "✉︎", "[ENV]"); Memo = @("📝", "📝︎", "[MEMO]"); Crayon = @("🖍️", "🖍︎", "[CRY]"); FountainPen = @("🖋️", "🖋︎", "[PEN]")
                Paintbrush = @("🖌️", "🖌︎", "[BRUSH]"); Pen = @("🖊️", "🖊︎", "[PEN]"); BlackNib = @("✒️", "✒︎", "[NIB]"); Pencil = @("✏️", "✏︎", "[PEN]")
                ChartUp = @("📈", "📈︎", "[CHUP]"); Pushpin = @("📌", "🖈", "[PIN]"); BarChart = @("📊", "📊︎", "[BCH]"); RulerTriangle = @("📐", "📐︎", "[RUL]")
                Clipboard = @("📋", "📋︎", "[CLIP]"); ChartDown = @("📉", "🗠", "[CHDN]"); RulerStraight = @("📏", "─", "[RUL]"); FileFolder = @("📁", "📁︎", "[DIR]")
                RoundPushpin = @("📍", "𖤣", "[PIN]"); Briefcase = @("💼", "💼︎", "[CASE]"); TearCalendar = @("📆", "◪", "[TCAL]"); CardIndex = @("📇", "📇︎", "[CARD]")
                OpenFolder = @("📂", "◪", "[OPN]"); Paperclip = @("📎", "📎︎", "[CLIP]"); FileCabinet = @("🗄️", "🗄︎", "[CAB]"); CardBox = @("🗃️", "🗃︎", "[CBOX]")
                CardDividers = @("🗂️", "🗂︎", "[DIV]"); LinkedClips = @("🖇️", "🖇︎", "[LINK]"); SpiralCalendar = @("🗓️", "◪", "[SCAL]"); Wastebasket = @("🗑️", "🗑", "[TRASH]")
                SpiralNotepad = @("🗒️", "🗒︎", "[NOT]"); Scissors = @("✂️", "✂︎", "[SCIS]")

                # --- HOUSEHOLD & TOOLS ---
                LockedKey = @("🔐", "🔐︎", "[LCK]"); LockedPen = @("🔏", "🔏︎", "[LCKP]"); OldKey = @("🗝️", "🗝︎", "[OKEY]"); BowArrow = @("🏹", "🏹︎", "[BOW]")
                Bomb = @("💣", "◉", "[BMB]"); Clamp = @("🗜️", "🗜︎", "[CLMP]"); Dagger = @("🗡️", "🗡︎", "[DAG]"); NutBolt = @("🔩", "🔩︎", "[NUT]")
                HammerWrench = @("🛠️", "⚒", "[TOOL]"); Magnet = @("🧲", "∩", "[MAG]"); WhiteCane = @("🦯", "🦯︎", "[CANE]"); Toolbox = @("🧰", "⚒", "[TBX]")
                Hook = @("🪝", "ރ", "[HOOK]"); Ladder = @("🪜", "⌇", "[LAD]"); Boomerang = @("🪃", "🪃︎", "[BOOM]"); Shovel = @("🪏", "⌆", "[SHOV]")
                Gear = @("⚙️", "⚙︎", "[GEAR]"); Chains = @("⛓️", "⛓︎", "[CHN]"); CrossedSwords = @("⚔️", "⚔︎", "[XSW]"); BalanceScale = @("⚖️", "⚖︎", "[SCAL]")
                HammerPick = @("⚒️", "⚒︎", "[HMP]"); BrokenChain = @("⛓️‍💥", "⛓‍💥︎", "[BCH]"); Satellite = @("🛰️", "🛰", "[SAT]"); Telescope = @("🔭", "🔭︎", "[TEL]")
                Microscope = @("🔬", "◉", "[MIC]"); TestTube = @("🧪", "⚗", "[TUBE]"); PetriDish = @("🧫", "◌", "[PETR]"); Dna = @("🧬", "⚛︎", "[DNA]")
                Alembic = @("⚗️", "⚗︎", "[ALEM]"); Syringe = @("💉", "💉︎", "[SYR]"); Pill = @("💊", "◉", "[PILL]"); Stethoscope = @("🩺", "⌕", "[STET]")
                Bandage = @("🩹", "⌇", "[BND]"); BloodDrop = @("🩸", "◉", "[BLOOD]"); Crutch = @("🩼", "🩼︎", "[CRUT]"); XRay = @("🩻", "🩻︎", "[XRAY]")
                Microbe = @("🦠", "𖠌", "[MICR]"); Factory = @("🏭", "🏭︎", "[FAC]");

                # --- FURNITURE & APPLIANCES ---
                Bathtub = @("🛁", "⌇", "[BATH]"); Elevator = @("🛗", "◉", "[ELEV]"); CouchLamp = @("🛋️", "🛋︎", "[SOFA]"); ShoppingCart = @("🛒", "🛒︎", "[CART]")
                Shower = @("🚿", "⌇", "[SHWR]"); Bed = @("🛏️", "⌇", "[BED]"); Toilet = @("🚽", "◉", "[TOIL]"); Door = @("🚪", "🚪︎", "[DOOR]")
                LotionBottle = @("🧴", "◌", "[LOT]"); FireExtinguisher = @("🧯", "🧯︎", "[FIREX]"); SafetyPin = @("🧷", "🧷︎", "[PIN]"); Basket = @("🧺", "🧺︎", "[BASK]")
                Soap = @("🧼", "◌", "[SOAP]"); PaperRoll = @("🧻", "⌇", "[PAP]"); Toothbrush = @("🪥", "🪥︎", "[TOOTH]"); Mousetrap = @("🪤", "🪤︎", "[TRAP]")
                Window = @("🪟", "🪟︎", "[WIN]"); Mirror = @("🪞", "🪞︎", "[MIR]"); Chair = @("🪑", "🪑︎", "[CHAIR]"); Razor = @("🪒", "🪒︎", "[RAZ]")
                Bubbles = @("🫧", "◌", "[BUB]"); Moai = @("🗿", "🗿︎", "[MOAI]"); Cigarette = @("🚬", "⌇", "[CIG]"); NazarAmulet = @("🧿", "◉", "[NAZ]")
                Placard = @("🪧", "🪧︎", "[PLAC]"); Headstone = @("🪦", "🪦︎", "[TOMB]"); IDCardIcon = @("🪪", "🪪︎", "[ID]"); Hamsa = @("🪬", "⚜", "[HAM]")
                FuneralUrn = @("⚱️", "⚱", "[URN]"); Coffin = @("⚰️", "⚰︎", "[COFF]"); Monster = @("👾", "👾︎", "[MON]"); Alien = @("👽", "👽︎", "[ALN]")

                # --- VISUAL & DECORATIVE ---
                StarEmpty = @("☆", "☆︎", "[ ]"); StarHalf = @("⯨", "★︎", "[*]"); StarFull = @("⭐", "★", "[★]"); HeartEmpty = @("♡", "♡︎", "[ ]")
                HeartFull = @("❤️", "♥", "[♥]"); Bookmark = @("🔖", "🔖︎", "[BMK]"); Tag = @("🏷️", "🏷︎", "[TAG]"); Flag = @("🚩", "⚑", "[FLG]")
                Trophy = @("🏆", "⛨", "[WIN]"); Medal = @("🎖️", "🎖︎", "[MED]"); Snowflake = @("❄️", "❄︎", "[SNOW]"); Drop = @("💧", "💧︎", "[DROP]")
                Sun = @("☀️", "☀︎", "[SUN]"); Moon = @("🌙", "☽", "[MON]"); Cloud = @("☁️", "☁︎", "[CLD]"); Rainbow = @("🌈", "◮", "[RBW]")
                SepDot = @("・", "·", "[.]"); SepDash = @("─", "─︎", "[-]"); SepDouble = @("═", "═︎", "[=]"); SepWave = @("〜", "≈", "[~]")
                SepArrow = @("⟶", "→", "[->]"); SepChevron = @("»", "»︎", "[>]")
                BoxTL = @("╭", "┌", "+"); BoxTR = @("╮", "┐", "+"); BoxBL = @("╰", "└", "+"); BoxBR = @("╯", "┘", "+")
                BoxH = @("─", "─", "-"); BoxV = @("│", "│︎", "|"); BoxCross = @("┼", "┼︎", "[+]")

                # --- POWERSHELL NATIVE ---
                PSPrompt = @("〉", ">", "[PS]"); PSClass = @("🏗️", "🏗︎", "[CLS]"); PSFunction = @("⚙️", "ƒ", "[FN]"); PSFunctionPrivate = @("🔒⚙️", "🔒︎⚙︎", "[PRVF]")
                PSFunctionPublic = @("🔓⚙️", "🔓︎⚙︎", "[PUBF]"); PSVariable = @("$", "$︎", "[VAR]"); PSVariableConst = @("🔒$", "🔒︎$︎", "[CVAR]"); PSVariableEnv = @("🌍$", "⌾$", "[EVAR]")
                PSModule = @("🧩", "🧩︎", "[MOD]"); PSModuleCore = @("💠", "◈", "[CORE]"); PSModuleScript = @("📜", "≡", "[SCR]"); PSEnum = @("📋", "📋︎", "[ENUM]")
                PSRunspace = @("🧵", "🧵︎", "[RS]"); PSJob = @("📬", "📬︎", "[JOB]"); PSJobRunning = @("🟢📬", "📬︎✅︎", "[RUN]"); PSJobStopped = @("🔴📬", "📬︎❌︎", "[STOP]")
                PSPipeline = @("⎸", "⇶", "[PIPE]"); PSOutput = @("📤", "⇈", "[OUT]"); PSInput = @("📥", "⇊", "[IN]"); PSProfile = @("👤⚙️", "☻⚙", "[PROF]")
                PSHistory = @("⎌", "⇠", "[HIST]"); PSAlias = @("🏷️", "🏷︎", "[ALIAS]"); PSDebug = @("🐛", "🐛︎", "[DBG]"); PSVerbose = @("🗣️", "🗣", "[VB]")
                PSWarning = @("⚠️", "⚠︎", "[WRN]"); PSError = @("❌", "❌︎", "[ERR]"); PSGet = @("📥", "⇊", "[GET]"); PSSet = @("📤", "⇈", "[SET]")
                PSNew = @("🆕", "🆕︎", "[NEW]"); PSRemove = @("🗑️", "⌫", "[RM]"); PSClear = @("🧹", "⌧", "[CLR]"); PSImport = @("📦➡️", "📦︎➡︎", "[IMP]")
                PSExport = @("➡️📦", "➡📦︎", "[EXP]"); PSHelp = @("❔", "⁇", "[?]"); PSAbout = @("ℹ️", "ℹ︎", "[i]")

                # --- MISC & FALLBACKS ---
                Unknown = @("❓", "⁇", "[?]"); Placeholder = @("✌︎🕷︎", "□︎", "[ ]"); Loading = @("⏳", "⏳︎", "[...]"); Processing = @("⚙️", "⚙︎", "[PROC]")
                Waiting = @("🕐", "◷", "[WAIT]"); Idle = @("😴", "⌾", "[IDLE]"); Ready = @("✅", "✅︎", "[READY]"); Source = @("⛲", "⛲︎", "[SRC]")
                Spiral = @("🌀", "🌀︎", "[SPI]"); FallbackIcon = "•"; FallbackText = "[?]"
        }

        # ===========================================================================
        # 14. SEMANTIC MAPPING (Icon = Action)
        # ===========================================================================
        SemanticMap          = @{
                # NÚCLEO & TAREFAS PRINCIPAIS
                SCAN = "Search"; PARSING = "Target"; ARCHAEOLOGY = "Pickaxe"; HARVESTER = "Bucket"
                FORENSICS = "EyeOpen"; SETTINGS = "Wrench"; CAPABILITIES = "Monitor"; LOGISTICS = "DeliveryTruck"; LABORATORY = "TestTube"
                "EXIT" = "Power"; HOME = "Home"; DASHBOARD = "WindowTile"; OVERVIEW = "Info"
                STATUS = "Info"; ABOUT = "Help"; HELP = "Help"; DOCS = "FileCode"
                SUPPORT = "Critical"; FEEDBACK = "MailSend"
                BITWISE_TAGGING = "WIP"; TOPOLOGY_SCAN = "NetworkLocal"; TELEMETRY_SCAN = "ServerRack"
                TARGET_ARCHAEOLOGY = "Pickaxe"; BATCH_PROCESSING = "Robot"; FILE_LABORATORY = "TestTube"
                HYDRATION_MODE = "Palette"; CLOUD_SYNC = "NetworkCloud"
                NET_SCAN = "NetworkLocal"; NET_UNMOUNT_ALL = "Eject"

                # NAVEGAÇÃO & CONTROLE DE FLUXO
                "RETURN" = "Return"; CANCEL = "Close"; CLOSE = "Close"; AUTO = "Robot"
                UNMOUNT = "Eject"; DELETE = "Trash"; REMOVE = "Trash"; FOLDER = "Folder"
                DIRECTORY = "Folder"; DIR = "Folder"; FILE = "File"; OPEN = "FolderOpen"
                BROWSE = "Search"; NAVIGATE = "Compass"; UP = "ArrowUp"; DOWN = "ArrowDown"
                LEFT = "ArrowLeft"; RIGHT = "ArrowRight"; NEXT = "ArrowTarget"; PREV = "ArrowLeft"
                PREVIOUS = "ArrowLeft"; FIRST = "Home"; LAST = "End"; JUMP = "ArrowJump"
                GOTO = "ArrowRedirect"; NEXT_TAB = "NextTab"; PREV_TAB = "PrevTab"

                # OPERAÇÕES DE ARQUIVO & SISTEMA
                NEW = "BadgeNew"; CREATE = "BadgeNew"; SAVE = "Save"; SAVE_AS = "SaveAs"
                LOAD = "Load"; IMPORT = "Import"; EXPORT = "Export"; COPY = "Copy"
                CUT = "Cut"; PASTE = "Paste"; CLONE = "Clone"; DUPLICATE = "Clone"
                RENAME = "InputText"; EDIT = "Edit"; MODIFY = "Wrench"; UPDATE = "Update"
                REFRESH = "Refresh"; RELOAD = "Refresh"; SYNC = "Sync"; SYNCHRONIZE = "Sync"
                BACKUP = "DatabaseSync"; RESTORE = "Restore"; UNDELETE = "Recovered"; UNTRASH = "Recovered"
                NORMALIZE = "Normalize"; FORMAT = "Disk"; COMPRESS = "FileArchive"; DECOMPRESS = "FileArchive"
                ARCHIVE = "FileArchive"; EXTRACT = "Saw"

                # OPERAÇÕES DE DISCO, STORAGE & FORENSE
                DISKPART = "Disk"; CHKDSK = "Shield"; WINFR = "Carve"; FSUTIL = "Screwdriver"
                AUTOSPSY = "Toolbox"; VOLATILITY = "Toolbox"; FTKIMAGER = "Toolbox"; KAPE = "Toolbox"; TESTDISK = "Toolbox"; PHOTOREC = "Toolbox"; WIRESHARK = "Toolbox"; TCPDUMP = "Toolbox"; NMAP = "Toolbox"; SYSINTERNALS = "Toolbox"; REGCFG = "Toolbox"; MEMORYZE = "Toolbox"; REDLINE = "Toolbox"; PLASO = "Toolbox"; LOG2TIMELINE = "Toolbox"; XWAYS = "Toolbox"; SLEUTHKIT = "Toolbox";
                SFC = "Shield"; DISM = "Wrench"; EVENTVWR = "ListAlt"; FILEHASH = "FingerprintID"
                WINDIRSTAT = "PieChart"; PROCEXP = "ActivityPulse"; AUTORUNS = "Gear"; EVERYTHING = "Search"
                NATIVE = "Terminal"; THIRDPARTY = "Toolbox"
                STORDIAG = "Bug"; VOLUME = "Disk"; PARTITION = "WindowSplitV"; MOUNT = "Disk"
                DISMOUNT = "Eject"; DRIVE = "Disk"; STORAGE = "ServerRack"; SSD = "DiskSSD"
                HDD = "DiskHDD"; USB = "DiskUSB"; NETWORK_DRIVE = "DiskNetwork"; NAS = "DiskNetwork"
                IMAGE_DISK = "ImageDisk"; WRITE_BLOCK = "WriteBlock"; WIPE = "Broom"; SCRUB = "Sponge"
                CARVE = "Carve"; RECONSTRUCT = "Reconstruct"; BYTEPATCH = "BytePatch"; HASH_CALC = "HashCalc"
                BRUTE_FORCE = "Axe"; VERIFY_INTEGRITY = "Verify"; EXPORT_REPORT = "Export"; XRAY_SCAN = "XRay"
                FINGERPRINT = "FingerprintID"; DATA_DUMP = "Bucket"; DEEP_SCAN = "Search"; SURFACE_SCAN = "Search"
                UNBLOCK = "Plunger"; FINE_TUNE = "Screwdriver"; SLICE_FILE = "Saw"; FORCE_DELETE = "Axe"

                # ESTRUTURA DE DADOS & ARTEFATOS FORENSES
                CORRUPTED = "Corrupted"; OVERWRITTEN = "Overwritten"; UNALLOCATED = "Unallocated"; ALLOCATED = "Allocated"
                SLACK = "SlackSpace"; FRAGMENTED = "Fragmented"; INTACT = "Intact"; PARTIAL = "Partial"
                ENCRYPTED = "Encrypted"; DECRYPTED = "Decrypted"; DELETED = "Deleted"; RECOVERED = "Recovered"
                UNRECOVERABLE = "Unrecoverable"; TAMPERED = "Tampered"; ORPHANED = "Orphaned"; MFT = "MFT"
                INODE = "Inode"; BOOT_SECTOR = "BootSector"; SUPERBLOCK = "Superblock"; GPT_HEADER = "GPTHeader"
                MBR = "MBR"; FAT_TABLE = "FATTable"; JOURNAL = "Journal"; BTREE = "BTree"
                EXTENT = "Extent"; NESTED_ARCHIVE = "NestedArchive"; HEX_VIEW = "HexView"; BINARY_VIEW = "BinaryView"
                ENTROPY = "Entropy"; CLUSTER = "Cluster"; SECTOR = "Sector"; BAD_SECTOR = "BadSector"
                PENDING_SECTOR = "PendingSector"; REALLOCATED = "Reallocated"; SMART_WARN = "SMARTWarn"; HEAD_CRASH = "HeadCrash"
                EVIDENCE = "Evidence"; CHAIN_OF_CUSTODY = "ChainOfCustody"; SEALED = "Sealed"; ID_CARD = "IDCard"
                METADATA_EXIF = "IDCard"

                # REDE, CLOUD & CONECTIVIDADE
                NET_MGR = "Network"; NETWORK = "Network"; INTERNET = "Network"; WIFI = "NetworkWireless"
                ETHERNET = "NetworkWired"; CONNECT = "Link"; DISCONNECT = "Unlink"; PING = "ArrowSync"
                TRACEROUTE = "Compass"; DNS = "Network"; DHCP = "Router"; FIREWALL = "Shield"
                PROXY = "Network"; VPN = "Lock"; SSH = "Terminal"; FTP = "FolderSync"
                HTTP = "Network"; API = "API"; WEBHOOK = "Webhook"

                # BANCO DE DADOS & DADOS
                DATABASE = "Database"; DB = "Database"; SQL = "Database"; QUERY = "Search"
                SELECT = "Search"; INSERT = "ArrowDown"; UPDATE_DB = "Update"; DELETE_DB = "Trash"
                SCHEMA = "WindowTile"; TABLE = "Menu"; INDEX = "Listbox"; MIGRATE = "Deploy"
                SEED = "Database"; ROLLBACK = "Undo"

                # POWERSHELL, SCRIPTING & DEVOPS
                ENGINE_MODE = "Terminal"; POWERSHELL = "PSPrompt"; PS = "PSPrompt"; SCRIPT = "FileCode"
                MODULE = "PSModule"; FUNCTION = "PSFunction"; CMDLET = "PSFunction"; VARIABLE = "PSVariable"
                ALIAS = "PSAlias"; PROFILE = "PSProfile"; RUNSPACE = "PSRunspace"; JOB = "PSJob"
                PIPELINE = "PSPipeline"; EXECUTE = "FileExec"; RUN = "Play"; INVOKE = "Play"
                CALL = "Play"; TEST = "TestTube"; DEBUG = "PSDebug"; TRACE = "PSDebug"
                VERBOSE = "PSVerbose"; WARNING = "PSWarning"; ERROR_PS = "PSError"; "CLASS" = "PSClass"
                SCAFFOLD = "Construction"

                # DESENVOLVIMENTO & DEVOPS
                BUILD = "Hammer"; COMPILE = "Hammer"; DEPLOY = "Rocket"; PUBLISH = "Rocket"
                RELEASE = "BadgeStable"; VERSION = "Tag"; TAG = "Tag"; BRANCH = "GitBranch"
                COMMIT = "CodeCommit"; PUSH = "GitPush"; PULL = "GitPull"; MERGE = "GitMerge"
                REBASE = "Sync"; DIFF = "WindowSplitV"; LOG = "FileLog"; CHANGELOG = "FileLog"
                ISSUE = "Bug"; BUG = "Bug"; FIX = "Wrench"; FEATURE = "StarFull"
                HOTFIX = "Fire"; PATCH = "BytePatch"

                # SEGURANÇA, CYBER & AUTENTICAÇÃO
                AUTH = "Key"; AUTHENTICATE = "Key"; LOGIN = "BadgeUnlock"; LOGOUT = "BadgeLock"
                SIGN_IN = "BadgeUnlock"; SIGN_OUT = "BadgeLock"; REGISTER = "BadgeNew"; PASSWORD = "InputPassword"
                TOKEN = "Key"; CERTIFICATE = "Certificate"; ENCRYPT = "Lock"; DECRYPT = "Unlock"
                HASH = "Key"; SIGN = "Certificate"; VERIFY = "Shield"; AUDIT = "EyeOpen"
                PERMISSION = "Shield"; ROLE = "Admin"; ADMIN = "Crown"; GUEST = "Guest"
                PROHIBITED = "ProhibitedSign"; BANNED = "ProhibitedSign"

                # UI/UX & INTERFACE / VIEW LAYER & THEMES
                THEME = "ThemeMenu"; DARK_MODE = "ThemeDark"; LIGHT_MODE = "ThemeLight"; HIGH_CONTRAST = "ThemeHighVis"
                COLOR_PICKER = "ColorPicker"; CYBER = "ThemeCyber"; CORPORATE = "ThemeCorporate"; HACKER = "ThemeHacker"
                MINIMAL = "ThemeMinimal"; RETRO = "ThemeRetro"; RECOVERY = "ThemeHighVis"; LANGUAGE = "Chat"
                LOCALE = "Chat"; TRANSLATE = "Chat"; LAYOUT = "WindowTile"; VIEW = "EyeOpen"
                ZOOM_IN = "FocusIn"; ZOOM_OUT = "FocusOut"; FULLSCREEN = "WindowFull"; MINIMIZE = "Minimize"
                MAXIMIZE = "Maximize"; TILE = "WindowTile"; SPLIT = "WindowSplitV"; SPLIT_V = "WindowSplitV"
                SPLIT_H = "WindowSplitH"; TILE_GRID = "WindowTile"; CASCADE = "WindowTile"; TAB = "TabNew"
                PANEL = "WindowTile"; SIDEBAR = "Menu"; TOOLBAR = "Tools"; STATUSBAR = "Info"
                NOTIFICATION = "Info"; ALERT = "Warning"; TOOLTIP = "Help"; MODAL = "WindowFull"
                DIALOG = "WindowFull"; LAYOUT_HEX_TEXT = "HexView"; LAYOUT_TREE_HEX = "BTree"; LAYOUT_TIMELINE = "Calendar"
                THUMBNAIL = "FileMedia"; DETAILS = "Listbox"; COLUMNS = "WindowSplitV"; BRACKET_ANGLE = "BracketAngle"
                BRACKET_SQUARE = "BracketSquare"; BRACKET_CURLY = "BracketCurly"

                # AÇÕES DE EDIÇÃO & HISTÓRICO
                UNDO = "Undo"; REDO = "Redo"; REVERT = "Undo"; RESET = "Refresh"
                CLEAR = "PSClear"; ERASE = "Trash"; SELECT_ALL = "Checkmark"; DESELECT = "Crossmark"
                FIND = "Search"; REPLACE = "InputText"; HIGHLIGHT = "StarFull"; BOOKMARK = "Bookmark"
                FAVORITE = "HeartFull"; STAR = "StarFull"; PIN = "Bookmark"; UNPIN = "Crossmark"

                # MÍDIA & MULTIMÍDIA
                PLAY = "Play"; PAUSE = "Pause"; STOP = "Stop"; RECORD = "Record"
                EJECT_MEDIA = "Eject"; VOLUME_UP = "SpeakerHigh"; VOLUME_DOWN = "SpeakerLow"; MUTE = "MutedSpeaker"
                MIC = "Microphone"; CAMERA = "Camera"; SCREENSHOT = "CameraFlash"; CAPTURE = "Camera"
                IMAGE = "FileMedia"; VIDEO = "VideoCamera"; AUDIO = "MusicalNotes"; DOCUMENT = "File"
                PDF = "FileCode"

                # FERRAMENTAS & UTILITÁRIOS ESPECÍFICOS
                SYNC_START = "Play"; TAG_PREPARE = "Tag"; ROBO_CFG = "InputText"; DEFAULT_OUT = "Folder"
                ROBOCOPY = "Copy"; DISK_MGR = "Disk"; REGISTRY = "Settings"; SERVICES = "Service"
                PROCESSES = "CPU"; MEMORY_MGR = "Memory"; EVENT_LOG = "FileLog"; TASK_SCHEDULER = "Calendar"
                POWER_SHELL = "Terminal"

                # ESTADOS & INDICADORES
                READY = "Ready"; IDLE = "Idle"; BUSY = "Processing"; LOADING = "Loading"
                WAITING = "Waiting"; SUCCESS = "Success"; OK = "Success"; DONE = "Success"
                COMPLETE = "Success"; FAILED = "Failure"; ERROR = "Failure"; WARNING_STATE = "Warning"
                PENDING = "Waiting"; QUEUED = "Waiting"; RUNNING = "Play"; STOPPED = "Stop"
                PAUSED_STATE = "Pause"; ENABLED = "CheckboxOn"; DISABLED = "CheckboxOff"; ACTIVE = "DotGreen"
                INACTIVE = "DotGray"; ONLINE = "DotGreen"; OFFLINE = "DotRed"; AVAILABLE = "DotGreen"
                UNAVAILABLE = "DotRed"; WIP = "WIP"; DRAFT = "WIP"; UNDER_CONSTRUCTION = "WIP"
                UNSTABLE = "WIP"; IN_PROGRESS = "WIP"

                # OPERAÇÕES EM LOTE & AUTOMAÇÃO
                BATCH = "Package"; BULK = "Bucket"; MASS = "Bucket"; AUTOMATE = "Robot"
                SCHEDULE = "Calendar"; CRON = "Calendar"; TRIGGER = "Lightning"; WEBHOOK_TRIGGER = "Webhook"
                EVENT = "Sparkle"; REACT = "Sparkle"; CHAIN = "Link"; WORKFLOW = "PSPipeline"
                PIPELINE_OP = "PSPipeline"

                # UTILITÁRIOS GERAIS (Fallbacks inteligentes)
                UNKNOWN = "Unknown"; DEFAULT = "Placeholder"; GENERIC = "Placeholder"; MISC = "Placeholder"
                OTHER = "Placeholder"; MORE = "Ellipsis"; OPTIONS = "Menu"; ACTIONS = "Tools"
                TOOLS = "Tools"; UTILS = "Tools"; ADVANCED = "Wrench"; EXPERT = "Admin"
                BASIC = "User"; SIMPLE = "Checkmark"; QUICK = "Lightning"; FAST = "Lightning"
                SLOW = "Timer"; PRECISE = "FocusIn"; APPROXIMATE = "FocusOut"

                # VEHICLES, TRANSPORT & MAPS
                ROCKET = "Rocket"; HELICOPTER = "Helicopter"; TRAIN = "Locomotive"; BUS = "Bus"
                AMBULANCE = "Ambulance"; FIRE_ENGINE = "FireEngine"; POLICE = "PoliceCar"; TAXI = "Taxi"
                CAR = "Automobile"; TRUCK = "DeliveryTruck"; TRACTOR = "Tractor"; SHIP = "Ship"
                BOAT = "Speedboat"; DEPARTURE = "AirplaneDepart"; ARRIVAL = "AirplaneArrive"; BICYCLE = "Bicycle"
                SCOOTER = "Scooter"; FLYING_SAUCER = "FlyingSaucer"; SKATEBOARD = "Skateboard"; PICKUP = "PickupTruck"
                STATION = "Station"; TRAFFIC_LIGHT = "TrafficLightV"; NO_SMOKING = "NoSmoking"; WATER = "PotableWater"
                RESTROOM = "Restroom"; CUSTOMS = "Customs"; BAGGAGE = "BaggageClaim"; WORSHIP = "PlaceOfWorship"
                STOP_SIGN = "StopSign"; WIRELESS = "Wireless"; WHEEL = "Wheel"; OIL = "OilDrum"
                HIGHWAY = "Motorway"; RAILWAY = "RailwayTrack"

                # NOVOS CONCEITOS (Clothing, Music, Office, Household)
                GRADUATION = "GraduationCap"; HAT = "TopHat"; BACKPACK = "Backpack"; DRESS = "Dress"
                SHOE = "ManShoe"; RUNNING_SHOE = "RunningShoe"; HANDBAG = "Handbag"; TSHIRT = "TShirt"
                LIPSTICK = "Lipstick"; RING = "Ring"; GEM = "GemStone"; GLASSES = "Glasses"
                JEANS = "Jeans"; NECKTIE = "Necktie"; HIGH_HEEL = "HighHeel"; SUNGLASSES = "ThemeHacker"
                SHOPPING = "ShoppingBags"; SAFETY = "SafetyVest"; SCARF = "Scarf"; GLOVES = "Gloves"
                COAT = "Coat"; SOCKS = "Socks"; HIKING = "HikingBoot"; LAB_COAT = "LabCoat"
                GOGGLES = "Goggles"; HELMET = "MilitaryHelmet"; BALLET = "BalletShoes"; SWIMSUIT = "Swimsuit"
                SHORTS = "Shorts"; FAN = "FoldingFan"; MEGAPHONE = "Megaphone"; BELL = "Bell"
                MUSIC = "MusicalNotes"; HEADPHONES = "Headphone"; RADIO = "Radio"; VIOLIN = "Violin"
                TRUMPET = "Trumpet"; SAXOPHONE = "Saxophone"; GUITAR = "Guitar"; DRUM = "Drum"
                FLUTE = "Flute"; PHONE = "Telephone"; MOBILE = "MobilePhone"; LAPTOP = "Laptop"
                PRINTER = "Printer"; BATTERY = "Battery"; PLUG = "Plug"; MOVIE = "MovieCamera"
                CLAPPER = "ClapperBoard"; CAMERA_PHOTO = "Camera"; LIGHT = "LightBulb"; TV = "Television"
                FLASHLIGHT = "Flashlight"; BOOK = "ClosedBook"; NEWSPAPER = "Newspaper"; MONEY = "MoneyBag"
                CREDIT_CARD = "CreditCard"; COIN = "Coin"; EMAIL = "Email"; PACKAGE = "Package"
                ENVELOPE = "Envelope"; MEMO = "Memo"; PEN = "Pen"; PENCIL = "Pencil"
                CHART = "BarChart"; CLIPBOARD = "Clipboard"; CALENDAR = "Calendar"; PAPERCLIP = "Paperclip"
                SCISSORS = "Scissors"; KEY_TOOL = "OldKey"; HAMMER = "Hammer"; WRENCH = "Wrench"
                SCREWDRIVER = "Screwdriver"; SAW = "Saw"; AXE = "Axe"; BUCKET = "Bucket"
                BROOM = "Broom"; MAGNET = "Magnet"; GEAR = "Gear"; SCALE = "BalanceScale"
                TELESCOPE = "Telescope"; MICROSCOPE = "Microscope"; DNA = "Dna"; SYRINGE = "Syringe"
                PILL = "Pill"; STETHOSCOPE = "Stethoscope"; BANDAGE = "Bandage"; XRAY = "XRay"
                BATHTUB = "Bathtub"; ELEVATOR = "Elevator"; SHOWER = "Shower"; BED = "Bed"
                TOILET = "Toilet"; DOOR = "Door"; WINDOW = "Window"; CHAIR = "Chair"
                COFFIN = "Coffin"

                # DEPLOYER & FORGE SEMANTICS
                INIT_SYSTEM = "Lightning"; FORGE_ORCHESTRATOR = "Tools"; BUILD_MONOLITH = "PSPipeline"; BUILD_EXE_PORTABLE = "Package"
                BUILD_EXE_SETUP = "Install"; BUILD_MSI = "Install"; FRAME_STYLE = "WindowTile"; ICON_LEVEL = "LightBulb"
                PROGRESS_STYLE = "Processing"; THEME_COLOR = "Television"; THEME_PERSONA = "Persona"; RANDOM_THEME = "Random"
                TERMINAL_CAPABILITIES = "Monitor"; RC_BTN_SAVE = "Save"; RC_BTN_CANCEL = "Close"

                # Flags Booleanas (Checkboxes / Toggles)
                RC_FLAG_E = "Label"; RC_FLAG_M = "Label"; RC_FLAG_ZB = "Label"; RC_FLAG_FFT = "Label"
                RC_FLAG_XO = "Label"; RC_FLAG_XN = "Label"; RC_FLAG_XJ = "Label"; RC_FLAG_B = "Label"
                RC_FLAG_NP = "Label"; RC_FLAG_COPYALL = "Label"; RC_FLAG_DCOPY_T = "Label"; RC_FLAG_L = "Label"
                RC_FLAG_V = "Label"

                # Parâmetros Numéricos (Sliders / Inputs)
                RC_FLAG_MT = "CPU"; RC_RETRY_R = "Refresh"; RC_RETRY_W = "Timer"

                # Terminal Capabilities
                CAP_TRUECOLOR = "Television"; CAP_HYPERLINKS = "Link"; CAP_BRACKETEDPASTE = "Paste"; CAP_MOUSETRACKING = "Settings"
                CAP_ALTERNATESCREEN = "WindowFull"; CAP_FOCUSEVENTS = "FocusIn"; CAP_KITTYKEYBOARD = "KeyboardDev"; CAP_SIXELGRAPHICS = "FileMedia"
                CAP_CSIUKEYBOARD = "KeyboardDev"; CAP_FALLBACK256 = "Color256"; CAP_FALLBACK16 = "Color16"
        }
}