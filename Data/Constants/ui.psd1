@{
        Segment              = @{
                Name         = "ui"
                Version      = "1.0.0"
                Description  = "VT100/ANSI reference, layout constants, input protocols, frame presets, progress engines, window management & PowerShell TUI extensions"
                Dependencies = @("system", "theme")
                HashSHA256   = "PLACEHOLDER_UI_HASH"
        }

        # ===========================================================================
        # 1. ANSI / VT100 REFERENCE COMPLETO (COMPATÃVEL COM PS 5.1)
        # ===========================================================================
        ANSI                 = @{
                AnsiStripRegex    = "(?:\x1B)\[[0-9;]*[a-zA-Z]"
                ESC               = "$([char]27)"
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
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
  â–ˆâ–ˆâ•”â•â•â•â•â•â–ˆâ–ˆâ•”â•â•â•â•â•â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•â•â•â•â•
â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
â•šâ•â•â•â•â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â•â• â–ˆâ–ˆâ•”â•â•â•
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
  â•šâ•â•â•â•â•â•â• â•šâ•â•â•â•â•â•â•šâ•â•  â•šâ•â•â•šâ•â•     â•šâ•â•â•â•â•â•â•
"@

                SmallLogo       = @"
 â•”â•â•—â•”â•â•—â•”â•â•—â•”â•â•—â•”â•â•—
â•šâ•â•—â•‘  â• â•â•£â• â•â•â•‘â•
 â•šâ•â•â•šâ•â•â•© â•©â•©  â•šâ•â•
"@

                SmallLogoMicro  = "â—† SCAPE v1.0 â—†"
                SmallLogoStatus = "[ SCAPE TUI ]"
                SmallLogoIcon   = "â—†"

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
        # 4. CONFIG & LAYOUT
        # ===========================================================================
        Config               = @{
                MaxCanvasWidth  = 140
                MaxCanvasHeight = 40
                DefaultWidth    = 120
                DefaultHeight   = 30
                DefaultEventPriority = 99
                DefaultBarWidth = 30
                DefaultColumnWidth = 30
        }
        Layout               = @{
                MinWidth     = 70       # Aumentei um pouco para dar respiro aos submenus
                MaxWidth     = 0        # 0 = DinÃ¢mico (Expande atÃ© o fim da tela 4k/8k)
                MinHeight    = 20
                MaxHeight    = 0       # 0 = DinÃ¢mico
                Margin       = 2
                Padding      = 1
                TitlePadding = 2
                HeaderHeight = 5    # Altura do banner (importante bater com o tamanho da logo)
                FooterHeight = 3
                SafeZoneWidth = 10
                IconColumnWidth = 5
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
                Classic    = @{ TL = "â•”"; TR = "â•—"; BL = "â•š"; BR = "â•"; HL = "â•"; VL = "â•‘"; ML = "â• "; MR = "â•£"; Cross = "â•¬"; TeeUp = "â•©"; TeeDown = "â•¦"; TeeLeft = "â•£"; TeeRight = "â• "; Name = "Classic Double-Line" }
                Rounded    = @{ TL = "â•­"; TR = "â•®"; BL = "â•°"; BR = "â•¯"; HL = "â”€"; VL = "â”‚"; ML = "â”œ"; MR = "â”¤"; Cross = "â”¼"; TeeUp = "â”´"; TeeDown = "â”¬"; TeeLeft = "â”¤"; TeeRight = "â”œ"; Name = "Rounded Soft" }
                Minimal    = @{ TL = "â”Œ"; TR = "â”"; BL = "â””"; BR = "â”˜"; HL = "â”€"; VL = "â”‚"; ML = "â”œ"; MR = "â”¤"; Cross = "â”¼"; TeeUp = "â”´"; TeeDown = "â”¬"; TeeLeft = "â”¤"; TeeRight = "â”œ"; Name = "Minimal Single" }
                ASCII      = @{ TL = "+"; TR = "+"; BL = "+"; BR = "+"; HL = "-"; VL = "|"; ML = "+"; MR = "+"; Cross = "+"; TeeUp = "+"; TeeDown = "+"; TeeLeft = "+"; TeeRight = "+"; Name = "ASCII Fallback" }
                Block      = @{ TL = "â–ˆ"; TR = "â–ˆ"; BL = "â–ˆ"; BR = "â–ˆ"; HL = "â–ˆ"; VL = "â–ˆ"; ML = "â–ˆ"; MR = "â–ˆ"; Cross = "â–ˆ"; TeeUp = "â–ˆ"; TeeDown = "â–ˆ"; TeeLeft = "â–ˆ"; TeeRight = "â–ˆ"; Name = "Block Heavy" }
                Retro      = @{ TL = "â”Œ"; TR = "â”"; BL = "â””"; BR = "â”˜"; HL = "â”€"; VL = "â”‚"; ML = "â”œ"; MR = "â”¤"; Cross = "â”¼"; TeeUp = "â”´"; TeeDown = "â”¬"; TeeLeft = "â”¤"; TeeRight = "â”œ"; Name = "Retro Terminal" }
                Cyber      = @{ TL = "âŸ¦"; TR = "âŸ§"; BL = "âŸ¦"; BR = "âŸ§"; HL = "âŽ¯"; VL = "â"; ML = "âŠ¢"; MR = "âŠ£"; Cross = "âŠž"; TeeUp = "âŠ¥"; TeeDown = "âŠ¤"; TeeLeft = "âŠ£"; TeeRight = "âŠ¢"; Name = "Cyberpunk" }
                Heavy      = @{ TL = "â”"; TR = "â”“"; BL = "â”—"; BR = "â”›"; HL = "â”"; VL = "â”ƒ"; ML = "â”£"; MR = "â”«"; Cross = "â•‹"; TeeUp = "â”»"; TeeDown = "â”³"; TeeLeft = "â”«"; TeeRight = "â”£"; Name = "Heavy Box" }
                Dotted     = @{ TL = "."; TR = "."; BL = "."; BR = "."; HL = "Â·"; VL = ":"; ML = ":"; MR = ":"; Cross = "+"; TeeUp = "+"; TeeDown = "+"; TeeLeft = "+"; TeeRight = "+"; Name = "Dotted" }
                Borderless = @{ TL = " "; TR = " "; BL = " "; BR = " "; HL = " "; VL = " "; ML = " "; MR = " "; Cross = " "; TeeUp = " "; TeeDown = " "; TeeLeft = " "; TeeRight = " "; Name = "Borderless" }
                PowerShell = @{ TL = ">"; TR = "<"; BL = "<"; BR = ">"; HL = "~"; VL = "|"; ML = "|"; MR = "|"; Cross = "|"; TeeUp = "|"; TeeDown = "|"; TeeLeft = "|"; TeeRight = "|"; Name = "PowerShell Prompt" }
        }

        # ===========================================================================
        # 7. PROGRESS / SPINNERS
        # ===========================================================================
        Progress             = @{
                Default  = @{ FullChar = "â–ˆ"; EmptyChar = "â–‘"; ErrorChar = "â–’"; Width = 40; ShowPercent = $true; ShowLabel = $true; ShowETA = $false }
                Compact  = @{ FullChar = "="; EmptyChar = "-"; ErrorChar = "X"; Width = 20; ShowPercent = $false; ShowLabel = $false; ShowETA = $false }
                BarOnly  = @{ FullChar = "â– "; EmptyChar = "â–¡"; ErrorChar = "!"; Width = 50; ShowPercent = $false; ShowLabel = $true; ShowETA = $true }
                Discrete = @{ FullChar = "â—"; EmptyChar = "â—‹"; ErrorChar = "âŠ—"; Width = 10; ShowPercent = $true; ShowLabel = $true; ShowETA = $false }
                Braille  = @{ Frames = @("â ‹", "â ™", "â ¹", "â ¸", "â ¼", "â ´", "â ¦", "â §", "â ‡", "â "); IntervalMs = 80 }
                Line     = @{ Frames = @("/", "-", "\\", "|"); IntervalMs = 120 }
                Dot      = @{ Frames = @(" . ", " ..", "...", ".. ", ".  "); IntervalMs = 150 }
                Blocks   = @{ Frames = @("â–", "â–‚", "â–ƒ", "â–„", "â–…", "â–†", "â–‡", "â–ˆ"); IntervalMs = 60 }
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
                Separator = " â”‚ "; ShowBackground = $true; BackgroundColor = "Base.Dark.Surface"
                MaxItems = 6; HideWhenNarrow = $true; MinWidthForFull = 80
        }
        Menu                 = @{
                IndentStep = 2; ShowShortcuts = $true; ShowIcons = $true
                HighlightSelected = "Bold"; SeparatorChar = "â”€"; SubmenuIndicator = "â–¶"
                BackIndicator = "â—€"; CloseOnSelect = $true; BreadcrumbSep = " / "; MaxDepth = 4
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
        # 9. SCROLLBAR / MODAL / SOUND / RESIZE / FEEDBACK / COLORS
        # ===========================================================================
        ColorConfig          = @{
                DefaultRGB = @(120, 120, 120)
                BgRGB      = @(20, 20, 20)
        }
        Feedback             = @{
                TransientActionHoldMs = 1800
                RouterSleepMs         = 20
        }
        ScrollBar            = @{
                TrackChar = "â–‘"; ThumbChar = "â–ˆ"; Width = 1; HideWhenFull = $true
                Position = "right"; Style = "modern"; ArrowUp = "â–²"; ArrowDown = "â–¼"
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
                # Valores padrÃ£o das capacidades (serÃ£o sobrescritos pelas toggles do usuÃ¡rio)
                TrueColor       = @{ Value = $true; I18NKey = "CAP_TRUECOLOR" }
                Hyperlinks      = @{ Value = $true; I18NKey = "CAP_HYPERLINKS" }
                BracketedPaste  = @{ Value = $true; I18NKey = "CAP_BRACKETEDPASTE" }
                MouseTracking   = @{ Value = $true; I18NKey = "CAP_MOUSETRACKING" }
                AlternateScreen = @{ Value = $true; I18NKey = "CAP_ALTERNATESCREEN" }
                FocusEvents     = @{ Value = $true; I18NKey = "CAP_FOCUSEVENTS" }
                KittyKeyboard   = @{ Value = $false; I18NKey = "CAP_KITTYKEYBOARD" }
                SixelGraphics   = @{ Value = $false; I18NKey = "CAP_SIXELGRAPHICS" }
                CSIuKeyboard    = @{ Value = $true; I18NKey = "CAP_CSIUKEYBOARD" }
                Fallback256     = @{ Value = $true; I18NKey = "CAP_FALLBACK256" }
                Fallback16      = @{ Value = $true; I18NKey = "CAP_FALLBACK16" }
        }
        Defaults             = @{
                FrameStyle         = "Classic"
                AnimationEnabled   = $true
                ColorMode          = "TrueColor"      # mantido para compatibilidade, mas serÃ¡ derivado de TrueColor capability
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
        # 11. CYCLE LISTS (para opÃ§Ãµes com mais de dois estados)
        # ===========================================================================
        CycleLists           = @{
                I18N          = @{ Options = @('en-US', 'pt-BR'); I18NKey = "CYCLE_I18N" }
                EngineMode    = @{ Options = @('EFFICIENCY', 'REDUNDANCY'); I18NKey = "CYCLE_ENGINEMODE" }
                ColorMode     = @{ Options = @('TrueColor', 'ANSI16'); I18NKey = "CYCLE_COLORMODE" }
                HydrationMode = @{ Options = @('graphic', 'unicode', 'ascii'); I18NKey = "CYCLE_HYDRATION" }
                IconLevel     = @{ Options = @(0, 1, 2); I18NKey = "CYCLE_ICONLEVEL" }
                FrameStyle    = @{ Options = @('Classic', 'Rounded', 'Minimal', 'ASCII', 'Block', 'Retro', 'Cyber', 'Heavy', 'Dotted', 'Borderless', 'PowerShell'); I18NKey = "CYCLE_FRAMESTYLE" }
                ProgressStyle = @{ Options = @('Default', 'Compact', 'BarOnly', 'Discrete', 'Braille', 'Line', 'Dot', 'Blocks'); I18NKey = "CYCLE_PROGSTYLE" }
                ThemePersona  = @{ Options = @('Cyber', 'Corporate', 'Hacker', 'Minimal', 'Retro', 'HighVis', 'PowerShell', 'RANDOM'); I18NKey = "CYCLE_PERSONA" }
                ThemeColor    = @{
                        Options = @(
                                'Blue', 'Green', 'Cyan', 'Magenta', 'Yellow', 'Red', 'Black', 'White',
                                'Gray', 'Purple', 'Orange', 'Teal', 'Pink', 'Brown', 'Lime', 'Indigo',
                                'Navy', 'Violet', 'Gold', 'Silver', 'Bronze',
                                'Amber', 'Dim', 'Coral', 'Salmon', 'Lavender', 'Mint'
                        )
                        I18NKey = "CYCLE_THEMECOLOR"
                }
                RC_MT         = @{ Options = @(1, 2, 4, 8, 16, 32, 64, 128); I18NKey = "RC_FLAG_MT" }
                RC_R          = @{ Options = @(0, 1, 3, 5, 10); I18NKey = "RC_RETRY_R" }
                RC_W          = @{ Options = @(0, 1, 5, 10, 30); I18NKey = "RC_RETRY_W" }
        }

        # ===========================================================================
        # 12. TOGGLE LISTS (opÃ§Ãµes binÃ¡rias: ativo/inativo)
        # ===========================================================================
        ToggleLists          = @{
                # Flags do Robocopy (booleanas)
                RC_E                = @{ Value = $true; I18NKey = "RC_FLAG_E" }
                RC_ZB               = @{ Value = $true; I18NKey = "RC_FLAG_ZB" }
                RC_M                = @{ Value = $false; I18NKey = "RC_FLAG_M" }
                RC_B                = @{ Value = $true; I18NKey = "RC_FLAG_B" }
                RC_COPYALL          = @{ Value = $true; I18NKey = "RC_FLAG_COPYALL" }
                RC_DCOPY_T          = @{ Value = $true; I18NKey = "RC_FLAG_DCOPY_T" }
                RC_NP               = @{ Value = $false; I18NKey = "RC_FLAG_NP" }
                RC_FFT              = @{ Value = $false; I18NKey = "RC_FLAG_FFT" }
                RC_XO               = @{ Value = $false; I18NKey = "RC_FLAG_XO" }
                RC_XN               = @{ Value = $false; I18NKey = "RC_FLAG_XN" }
                RC_XJ               = @{ Value = $true; I18NKey = "RC_FLAG_XJ" }
                RC_L                = @{ Value = $false; I18NKey = "RC_FLAG_L" }
                RC_V                = @{ Value = $false; I18NKey = "RC_FLAG_V" }

                # Terminal Capabilities
                CAP_TRUECOLOR       = @{ Value = $true; I18NKey = "CAP_TRUECOLOR" }
                CAP_HYPERLINKS      = @{ Value = $true; I18NKey = "CAP_HYPERLINKS" }
                CAP_BRACKETEDPASTE  = @{ Value = $true; I18NKey = "CAP_BRACKETEDPASTE" }
                CAP_MOUSETRACKING   = @{ Value = $true; I18NKey = "CAP_MOUSETRACKING" }
                CAP_ALTERNATESCREEN = @{ Value = $true; I18NKey = "CAP_ALTERNATESCREEN" }
                CAP_FOCUSEVENTS     = @{ Value = $true; I18NKey = "CAP_FOCUSEVENTS" }
                CAP_KITTYKEYBOARD   = @{ Value = $false; I18NKey = "CAP_KITTYKEYBOARD" }
                CAP_SIXELGRAPHICS   = @{ Value = $false; I18NKey = "CAP_SIXELGRAPHICS" }
                CAP_CSIUKEYBOARD    = @{ Value = $true; I18NKey = "CAP_CSIUKEYBOARD" }
                CAP_FALLBACK256     = @{ Value = $true; I18NKey = "CAP_FALLBACK256" }
                CAP_FALLBACK16      = @{ Value = $true; I18NKey = "CAP_FALLBACK16" }
        }

        # ===========================================================================
        # 13. ICONS & SYMBOLS (Hierarquia: [0] Graphic, [1] Solid Unicode, [2] ASCII)
        # ===========================================================================
        Labels               = @{ IconLevels = @('Graphic', 'Unicode', 'ASCII') }

        Icons                = @{
                # --- Status & Alerts ---
                Success = @("âœ…", "âœ…ï¸Ž", "[OK]"); Failure = @("âŒ", "âœ–", "[ERR]"); Warning = @("âš ï¸", "âš ", "[!]"); Info = @("â„¹ï¸", "â„¹ï¸Ž", "[i]")
                Question = @("â“", "â‡", "[?]"); Critical = @("ðŸ’¥", "â˜ ï¸Žï¸Ž", "[CRIT]"); Fatal = @("â˜¢ï¸", "â˜¢ï¸Ž", "[FATAL]"); Checkmark = @("âœ”ï¸", "âœ”ï¸Ž", "[V]")
                Crossmark = @("âŽ", "âŽï¸Ž", "[X]"); Ellipsis = @("â€¦", "â€¦ï¸Ž", "..."); Bullet = @("â€¢", "âˆ™", "*"); Separator = @("â”€", "â”€", "-")

                # --- Colored Status Dots ---
                DotRed = @("ðŸ”´", "â—", "[!]"); DotGreen = @("ðŸŸ¢", "â—", "[OK]"); DotYellow = @("ðŸŸ¡", "â—", "[~]"); DotBlue = @("ðŸ”µ", "â—", "[i]")
                DotCyan = @("ðŸ”·", "â—†", "[*]"); DotMagenta = @("ðŸŸ£", "â—", "[â˜…]"); DotWhite = @("âšª", "â—‹", "[ ]"); DotGray = @("âš«", "â—", "[â€¢]")
                DotOrange = @("ðŸŸ ", "â—†", "[O]"); DotHollow = @("â­•", "â—‹", "( )")
                SquareRed = @("ðŸŸ¥", "â– ", "[X]"); SquareGreen = @("ðŸŸ©", "â– ", "[OK]"); SquareYellow = @("ðŸŸ¨", "â– ", "[!]"); SquareBlue = @("ðŸŸ¦", "â– ", "[i]")

                # --- Status Badges & WIP ---
                BadgeNew = @("ðŸ†•", "ðŸ†•ï¸Ž", "[NEW]"); BadgeUpdated = @("ðŸ”„", "ðŸ”„ï¸Ž", "[UPD]"); BadgeHot = @("ðŸ”¥", "ðŸ”¥ï¸Ž", "[HOT]"); BadgeCold = @("â„ï¸", "â„", "[CLD]")
                BadgeLock = @("ðŸ”", "ðŸ”ï¸Ž", "[LCK]"); BadgeUnlock = @("ðŸ”“", "ðŸ”“ï¸Ž", "[OPN]"); BadgeBeta = @("ðŸ§ª", "Î²", "[BETA]"); BadgeStable = @("âš“", "âŽˆ", "[STABLE]")
                WIP = @("ðŸš§", "âŠ˜", "[WIP]")

                # --- THEMES & PERSONAS ---
                ThemeCyber = @("ðŸª©", "â—", "[CYB]"); ThemeCorporate = @("ðŸŽ©", "ðŸŽ©ï¸Ž", "[COR]"); ThemeHacker = @("ðŸ•¶ï¸", "ðŸ•¶ï¸Ž", "[HCK]"); ThemeMinimal = @("ðŸ‘•", "ðŸ–½", "[MIN]")
                ThemeRetro = @("ðŸ•¹ï¸", "âŽš", "[RET]"); ThemeHighVis = @("â›‘ï¸", "â›‘ï¸Ž", "[HVS]"); ThemePowerShell = @("ðŸ“¸", "âŒ˜", "[PS]"); ThemeDark = @("ðŸŒ™", "â¾", "[DRK]")
                ThemeLight = @("â˜€ï¸", "â˜€", "[LGT]"); Palette = @("ðŸŽ¨", "â˜±", "[THM]"); Persona = @("ðŸªž", "ðŸªžï¸Ž", "[PSN]"); Random = @("ðŸŽ²", "âš„", "[RDM]"); ColorPicker = @("ðŸ–Œï¸", "ðŸ–Œï¸Ž", "[PCK]")
                ThemeMenu = @("ðŸ­", "â˜±", "[THM]")

                # --- FORENSICS & DATA RECOVERY ---
                Corrupted = @("ðŸš«", "âš ", "[COR]"); Overwritten = @("ðŸ”„", "ðŸ”„ï¸Ž", "[OW]"); Unallocated = @("â¬œ", "â—»", "[UNA]"); Allocated = @("â¬›", "â—¼", "[ALC]")
                SlackSpace = @("ðŸ”²", "â–¤", "[SLK]"); Fragmented = @("âš™ï¸", "âŠ˜", "[FRG]"); Intact = @("ðŸ’Ž", "â—ˆ", "[OK]"); Partial = @("ðŸ©¹", "Â±", "[PRT]")
                Encrypted = @("ðŸ”", "ðŸ”ï¸Ž", "[ENC]"); Decrypted = @("ðŸ”“", "ðŸ”“ï¸Ž", "[DEC]"); Deleted = @("ðŸ—‘ï¸", "âœ–", "[DEL]"); Recovered = @("â™»ï¸", "â™»ï¸Ž", "[REC]")
                Unrecoverable = @("âš°ï¸", "âŠ", "[NREC]"); Tampered = @("âš ï¸", "âš ", "[TAMP]"); Orphaned = @("ðŸª¾", "âŠ˜", "[ORF]")
                Carve = @("ðŸ§©", "âœ‚", "[CRV]"); ImageDisk = @("ðŸ’¿", "ðŸ’¿ï¸Ž", "[IMG]"); Verify = @("â˜‘ï¸", "âœ”", "[VRF]"); WriteBlock = @("ðŸ›‘", "âŠ˜", "[WB]")
                HashCalc = @("ðŸ”€", "#", "[HASH]"); Reconstruct = @("ðŸ§©", "âœ‚", "[RCN]"); Wipe = @("ðŸ§¹", "âŒ§", "[WIP]"); Scrub = @("ðŸ§½", "â–’", "[SCR]")
                BytePatch = @("ðŸ©¹", "Â±", "[PAT]"); BruteForce = @("ðŸ› ï¸", "âš’", "[BRF]"); XRayScan = @("ðŸ©»", "â˜ ", "[XRY]"); FingerprintID = @("ðŸ†”", "â", "[FIN]")
                MFT = @("ðŸ—ƒï¸", "ðŸ—ƒï¸Ž", "[MFT]"); Inode = @("ðŸ”¢", "ðŸ”¢ï¸Ž", "[INOD]"); BootSector = @("ðŸ¦¾", "âš™", "[BOOT]"); Superblock = @("ðŸ–²ï¸", "ðŸ–²ï¸Ž", "[SUP]")
                GPTHeader = @("ðŸ“", "ðŸ“ï¸Ž", "[GPT]"); MBR = @("ðŸ“Ÿ", "ðŸ“Ÿï¸Ž", "[MBR]"); FATTable = @("ðŸ—‚ï¸", "â–¦", "[FAT]"); Journal = @("ðŸ““", "ðŸ““ï¸Ž", "[JRN]")
                BTree = @("ðŸŒ²", "ðŸŒ²ï¸Ž", "[BTRE]"); Extent = @("â¤¢", "â¤¢", "[EXT]"); NestedArchive = @("ðŸª†", "â—«", "[NST]")
                HexView = @("ðŸ”¢", "ðŸ”¢ï¸Ž", "[HEX]"); BinaryView = @("ðŸ–²ï¸", "ðŸ–²ï¸Ž", "[BIN]"); Entropy = @("â˜„ï¸", "â˜„", "[ENT]"); Cluster = @("ðŸª¼", "â–", "[CLU]")
                Sector = @("ðŸ§«", "â˜‰", "[SEC]"); Block = @("ðŸ’¢", "ðŸ’¢ï¸Ž", "[BLK]")
                Color256 = @("ðŸŒˆ", "â˜±", "[256]"); Color16 = @("ðŸŽ¨", "ðŸ–½", "[16]")
                BadSector = @("âŒ", "âœ–", "[BAD]"); PendingSector = @("âš ï¸", "âš ", "[PEN]"); Reallocated = @("ðŸ”„", "ðŸ”„ï¸Ž", "[REA]"); SSDWear = @("ðŸ“‰", "âŠ–", "[WRN]")
                SMARTWarn = @("ðŸš¨", "âŠ˜", "[SMR]"); HeadCrash = @("â˜£ï¸ ", "â˜£", "[HDC]")
                Evidence = @("ðŸ’¼", "ðŸ’¼ï¸Ž", "[EVD]"); ChainOfCustody = @("â›“ï¸", "â›“ï¸Ž", "[COC]"); Sealed = @("ðŸ”", "ðŸ”ï¸Ž", "[SEAL]"); IDCard = @("ðŸªª", "ðŸ–¹", "[ID]")

                # --- LAYOUTS & ADVANCED NAVIGATION ---
                ArrowUp = @("â¬†ï¸", "â†‘", "[^]"); ArrowDown = @("â¬‡ï¸", "â†“", "[v]"); ArrowLeft = @("â¬…ï¸", "â†", "[<]"); ArrowRight = @("âž¡ï¸", "â†’", "[>]")
                ArrowDoubleUp = @("â«", "â‡ˆ", "[^^]"); ArrowDoubleDown = @("â¬", "â‡Š", "[vv]"); ArrowDoubleLeft = @("â¬…ï¸", "â‡‡", "[<<]"); ArrowDoubleRight = @("âž¡ï¸", "â‡‰", "[>>]")
                ArrowSync = @("ðŸ”ƒ", "ðŸ”ƒï¸Ž", "[<>]"); ArrowDiagonalUR = @("â†—ï¸", "â†—ï¸Ž", "[/^]"); ArrowDiagonalDR = @("â†˜ï¸", "â†˜ï¸Ž", "[\v]"); ArrowCurveRight = @("â¤´ï¸", "â¤´ï¸Ž", "[^>]")
                ArrowCurveLeft = @("â¤µï¸", "â¤µï¸Ž", "[<v]"); ArrowTarget = @("âžœ", "âžœï¸Ž", "[->]"); ArrowRedirect = @("â¤³", "â‡", "[>>]"); ArrowJump = @("â¤´ï¸", "â†±", "[JMP]")
                CaretUp = @("â–²", "â–²ï¸Ž", "[^]"); CaretDown = @("â–¼", "â–¼ï¸Ž", "[v]"); CaretLeft = @("â—€", "â—€ï¸Ž", "[<]"); CaretRight = @("â–¶", "â–¶ï¸Ž", "[>]")
                CaretSmallUp = @("â–´", "â–µ", "[^]"); CaretSmallDown = @("â–¾", "â–¿", "[v]"); CaretSmallLeft = @("â—‚", "â—ƒ", "[<]"); CaretSmallRight = @("â–¸", "â–¹", "[>]")
                Compass = @("ðŸ§­", "âŒ–", "[R]"); CompassN = @("ðŸ§­N", "â—§", "[N]"); CompassS = @("ðŸ§­S", "â—¨", "[S]"); CompassE = @("ðŸ§­E", "â—©", "[E]")
                CompassW = @("ðŸ§­W", "â—ª", "[W]"); Home = @("ðŸ ", "ðŸ ï¸Ž", "[H]"); End = @("ðŸ", "âš‘", "[E]"); Jump = @("â¤´ï¸", "â†±", "[J]")
                Return = @("â†©ï¸", "â†µ", "[RET]"); Breadcrumb = @("â¯", "â€º", ">"); NextTab = @("â‡¥", "â‡¨", "[>>]"); PrevTab = @("â‡¤", "â‡¦", "[<<]")

                # --- UI CONTROLS, FORMS & BRACKETS ---
                Menu = @("â˜°", "â‰¡", "[MENU]"); Submenu = @("â–¸", "â–¹", "[>]"); Back = @("â—‚", "â—ƒ", "[<]"); Close = @("âœ–ï¸", "âœ–ï¸Ž", "[X]")
                Minimize = @("â—·", "â€”", "[_]"); Maximize = @("ðŸ—–", "â–¡", "[#]"); Normalize = @("ðŸ——", "â–£", "[O]"); Help = @("â”", "â‡", "[?]")
                WindowTile = @("ðŸªŸ", "âŠž", "[TILE]"); WindowSplitH = @("â‡¹", "â‡¹", "[SPLITH]"); WindowSplitV = @("â¤¢", "â‡•", "[SPLITV]"); WindowFull = @("â›¶", "âŽ”", "[FULL]")
                TabNew = @("ðŸ—", "+", "[+TAB]"); TabClose = @("ðŸ—™", "âŠ ", "[X]"); FocusIn = @("ðŸ”", "âŠ•", "[IN]"); FocusOut = @("ðŸ”Ž", "âŠ–", "[OUT]")
                Chat = @("ðŸ’¬", "ðŸ’¬ï¸Ž", "[MSG]"); Comment = @("ðŸ’­", "ðŸ’­ï¸Ž", "[CMT]"); Mention = @("ðŸ”–", "@", "[@]")
                CheckboxOn = @("â˜‘ï¸", "â˜‘ï¸Ž", "[X]"); CheckboxOff = @("ðŸ”³", "â—»", "[ ]"); CheckboxHalf = @("ðŸŸª", "âŠŸ", "[-]");
                RadioOn = @("ðŸ”˜", "â—‰", "(O)"); RadioOff = @("âšª", "â—‹", "( )"); ToggleOn = @("ðŸŸ¢", "â—‹", "[ON]"); ToggleOff = @("ðŸ”´", "â—‹", "[OFF]")
                SliderStart = @("ðŸ”¹", "âŠ¢", "[o]"); SliderMid = @("â”€", "â€”", "[-]"); SliderEnd = @("ðŸ”¸", "âŠ£", "[â—]"); SliderHandle = @("ðŸ”¶", "â—ˆ", "[H]")
                InputText = @("ðŸ“", "ðŸ“ï¸Ž", "[TXT]"); InputNumber = @("ðŸ”¢", "ðŸ”¢ï¸Ž", "[NUM]"); InputDate = @("ðŸ“…", "â—ª", "[DATE]"); InputEmail = @("ðŸ“§", "ðŸ“§ï¸Ž", "[EMAIL]")
                InputPassword = @("ðŸ”‘", "âš·", "[PWD]"); Dropdown = @("â–¾", "â–¿", "[â–¼]"); Listbox = @("ðŸ“‹", "â–¤", "[LIST]"); Combobox = @("ðŸ—‚ï¸", "âŠŸ", "[COMBO]")
                BracketAngle = @("âŸ¨âŸ©", "âŸ¨âŸ©ï¸Ž", "<>"); BracketSquare = @("âŸ¦âŸ§", "âŸ¦âŸ§ï¸Ž", "[]"); BracketCurly = @("â¦ƒâ¦„", "â¦ƒâ¦„ï¸Ž", "{}"); BracketParen = @("â¸¨â¸©", "â‘‰â‘Š", "()")

                # --- VEHICLES & TRANSPORT ---
                Rocket = @("ðŸš€", "ðŸš€ï¸Ž", "[RCK]"); Helicopter = @("ðŸš", "â™", "[HEL]"); Locomotive = @("ðŸš‚", "ðŸ›²", "[LOC]"); HighSpeedTrain = @("ðŸš„", "ðŸš„ï¸Ž", "[HST]")
                BulletTrain = @("ðŸš…", "ðŸš…ï¸Ž", "[BLT]"); Metro = @("ðŸš‡", "âŠ•", "[MET]"); Station = @("ðŸš‰", "â—±", "[STA]"); Bus = @("ðŸšŒ", "ðŸšŒï¸Ž", "[BUS]")
                BusStop = @("ðŸš", "âŠ¡", "[BST]"); Ambulance = @("ðŸš‘", "ðŸš‘ï¸Ž", "[AMB]"); FireEngine = @("ðŸš’", "ðŸš’ï¸Ž", "[FIR]"); PoliceCar = @("ðŸš“", "â›¨", "[POL]")
                Taxi = @("ðŸš•", "â›Ÿ", "[TAX]"); Automobile = @("ðŸš—", "â›Ÿ", "[CAR]"); SUV = @("ðŸš™", "â›Ÿ", "[SUV]"); DeliveryTruck = @("ðŸšš", "â›Ÿ", "[TRK]")
                Tractor = @("ðŸšœ", "â›Ÿ", "[TRC]"); Ship = @("ðŸš¢", "â›´", "[SHP]"); Speedboat = @("ðŸš¤", "â›´", "[BOT]"); AirplaneDepart = @("ðŸ›«", "ðŸ›«ï¸Ž", "[DEP]")
                AirplaneArrive = @("ðŸ›¬", "ðŸ›¬ï¸Ž", "[ARR]"); Bicycle = @("ðŸš²", "â‹’", "[BKE]"); Scooter = @("ðŸ›µ", "â‹—", "[SCV]"); FlyingSaucer = @("ðŸ›¸", "ðŸ›¸", "[UFO]")
                Skateboard = @("ðŸ›¹", "â‹–", "[SKB]"); PickupTruck = @("ðŸ›»", "â›Ÿ", "[PCK]")

                # --- TRAFFIC, SIGNS & MAPS ---
                TrafficLightH = @("ðŸš¥", "â‰¬", "[TLH]"); TrafficLightV = @("ðŸš¦", "â™", "[TLV]"); NoSmoking = @("ðŸš­", "âŒ€", "[NSM]"); NoLittering = @("ðŸš¯", "âŒ€", "[NLT]")
                PotableWater = @("ðŸš°", "â˜µ", "[WTR]"); NoPedestrians = @("ðŸš·", "âŒ€", "[NPED]"); ChildrenCrossing = @("ðŸš¸", "âŒ…", "[KID]"); MensRoom = @("ðŸš¹", "â™‚", "[M]")
                WomensRoom = @("ðŸšº", "â™€", "[W]"); Restroom = @("ðŸš»", "âš²", "[WC]"); BabySymbol = @("ðŸš¼", "â™", "[BBY]"); PassportControl = @("ðŸ›‚", "ðŸ›‚ï¸Ž", "[PAS]")
                Customs = @("ðŸ›ƒ", "âŠ—", "[CST]"); BaggageClaim = @("ðŸ›„", "ðŸ›„ï¸Ž", "[BAG]"); LeftLuggage = @("ðŸ›…", "ðŸ›…ï¸Ž", "[LUG]"); ProhibitedSign = @("ðŸ›‡", "âŒ€", "[PRO]")
                CircledInfo = @("ðŸ›ˆ", "â“˜", "[CINF]"); PlaceOfWorship = @("ðŸ›", "â™œ", "[TEMP]"); StopSign = @("ðŸ›‘", "â¹", "[STP]"); Wireless = @("ðŸ›œ", "á¯¤", "[WIF]")
                Wheel = @("ðŸ›ž", "â—Ž", "[WHL]"); RingBuoy = @("ðŸ›Ÿ", "â—Ž", "[BUOY]"); OilDrum = @("ðŸ›¢ï¸", "ðŸ›¢ï¸Ž", "[OIL]"); Motorway = @("ðŸ›£", "âšŒ", "[MWY]")
                RailwayTrack = @("ðŸ›¤", "ðŸ›¤ï¸Ž", "[RWY]")

                # --- SYSTEM, HARDWARE & TOOLS ---
                Folder = @("ðŸ“", "ðŸ“ï¸Ž", "[DIR]"); FolderOpen = @("ðŸ“‚", "â—ª", "[OPN]"); FolderSync = @("âŠž", "âˆ²", "[SYNCDIR]"); FolderSecure = @("â˜—", "â›¨", "[SECDIR]")
                File = @("ðŸ“„", "ðŸ“„ï¸Ž", "[FILE]"); FileCode = @("âŒ¨ï¸", "âŒ¨ï¸Ž", "[CODE]"); FileConfig = @("âš™ï¸", "âš™ï¸Ž", "[CFG]"); FileLog = @("ðŸ“œ", "âŒ¹", "[LOG]")
                FileTemp = @("âŒ«", "â±", "[TMP]"); FileArchive = @("ðŸ—œï¸", "ðŸ—œï¸Ž", "[ZIP]"); FileExec = @("âš¡", "âš¡ï¸Ž", "[EXE]"); FileMedia = @("ðŸŽ¬", "ðŸŽ¬ï¸Ž", "[MEDIA]")
                Database = @("ðŸ›ï¸", "ðŸ›ï¸Ž", "[DB]"); DatabaseSync = @("âŸ³", "â‡Œ", "[DBSYNC]"); Server = @("ðŸ–¥ï¸", "ðŸ–¥ï¸Ž", "[SRV]"); ServerRack = @("ðŸ—„ï¸", "ðŸ—„ï¸Ž", "[RACK]")
                Network = @("ðŸŒ", "ðŸ–§", "[NET]"); NetworkWired = @("ðŸ”Œ", "ðŸ”Œï¸Ž", "[ETH]"); NetworkWireless = @("ðŸ“¶", "ðŸ“¶ï¸Ž", "[WIFI]"); NetworkCloud = @("â˜ï¸", "â˜ï¸Ž", "[CLD]")
                NetworkLocal = @("ðŸ ", "ðŸ ï¸Ž", "[LAN]"); Router = @("ðŸ“¡", "ðŸ“¡ï¸Ž", "[RTR]")
                Disk = @("ðŸ’¾", "ðŸ–«", "[DISK]"); DiskSSD = @("âš¡", "âš¡ï¸Ž", "[SSD]"); DiskHDD = @("ðŸ’½", "ðŸ’½ï¸Ž", "[HDD]"); DiskUSB = @("ðŸ”Œ", "ðŸ”Œï¸Ž", "[USB]")
                DiskNetwork = @("ðŸ”®", "â›ƒ", "[NAS]")
                Memory = @("ðŸ§ ", "â˜·", "[RAM]"); Chip = @("ðŸ”²", "â–¦", "[CHIP]"); CPU = @("âš™ï¸", "âš™ï¸Ž", "[CPU]"); GPU = @("ðŸŽ®", "â–¤", "[GPU]")
                Power = @("â»", "âŒ½", "[PWR]"); BatteryFull = @("ðŸ”‹", "â–®", "[FULL]"); BatteryHalf = @("ðŸª«", "âŒ¸", "[HALF]"); BatteryLow = @("ðŸª«", "â–¯", "[LOW]")
                Charging = @("âš¡", "âš¡ï¸Ž", "[CHG]")
                Lock = @("ðŸ”’", "ðŸ”’ï¸Ž", "[LCK]"); Unlock = @("ðŸ”“", "ðŸ”“ï¸Ž", "[OPN]"); Key = @("ðŸ”‘", "ðŸ”‘ï¸Ž", "[KEY]"); KeyPair = @("ðŸ”", "ðŸ”ï¸Ž", "[PAIR]")
                Certificate = @("ðŸ“œðŸ”", "ðŸ“œðŸ”ï¸Ž", "[CERT]"); Shield = @("ðŸ›¡ï¸", "â›¨", "[SHD]"); Bug = @("ðŸª²", "ðŸª²ï¸Ž", "[BUG]")
                EyeOpen = @("ðŸ‘ï¸", "ðŸ‘ï¸Ž", "[SEE]"); EyeClosed = @("ðŸ‘ï¸â€ðŸ—¨ï¸", "âš‡", "[BLIND]")
                User = @("ðŸ‘¤", "â˜»", "[USR]"); Users = @("ðŸ‘¥", "â˜»â˜»", "[GRP]"); Admin = @("ðŸ‘‘", "â™›", "[ADM]"); Guest = @("ðŸŽ­", "â˜º", "[GST]")
                Service = @("âš™ï¸", "âš™ï¸Ž", "[SVC]")
                Terminal = @("ðŸ’»", "â™³", "[CLI]"); Container = @("ðŸ“¦", "âŽˆ", "[DOCKER]"); API = @("ðŸ”Œ", "ðŸ”Œï¸Ž", "[API]"); Webhook = @("ðŸª", "ðŸªï¸Ž", "[HOOK]")
                Robot = @("ðŸ¤–", "âš™", "[BOT]")
                Clock = @("â±ï¸", "â²", "[TIME]"); Calendar = @("ðŸ“…", "â—ª", "[DATE]"); Timer = @("â²ï¸", "â—µ", "[TMR]"); Stopwatch = @("â°", "â²", "[STOP]")
                Hourglass = @("â³", "â³ï¸Ž", "[WAIT]")
                Settings = @("âš™ï¸", "âš™ï¸Ž", "[SET]"); Config = @("ðŸ”§", "ðŸ”§ï¸Ž", "[CFG]"); Preferences = @("ðŸŽ›ï¸", "âŽš", "[PREF]")
                Target = @("ðŸŽ¯", "ðŸŽ¯ï¸Ž", "[TGT]"); Search = @("ðŸ”", "âŒ•", "[FND]"); Filter = @("ðŸ”½", "â—‚", "[FLT]"); SortAsc = @("ðŸ”¼", "â–µ", "[ASC]")
                SortDesc = @("ðŸ”½", "â–¿", "[DESC]"); GroupBy = @("ðŸ—‚ï¸", "âŠŸ", "[GRP]"); Refresh = @("ðŸ”„", "ðŸ”„ï¸Ž", "[RFR]"); Sync = @("ðŸ”", "â‡Œ", "[SYNC]")
                Update = @("â¬†ï¸", "â‡¡", "[UPD]"); Upgrade = @("ðŸš€", "â‡ˆ", "[UPG]")
                Play = @("â–¶ï¸", "â–º", "[>]"); Pause = @("â¸ï¸", "â€–", "[||]"); Stop = @("â¹ï¸", "â– ", "[STOP]"); Record = @("âºï¸", "â—", "[REC]")
                Eject = @("âï¸", "âï¸Ž", "[EJT]"); Next = @("â­ï¸", "â­ï¸Ž", "[>>]"); Prev = @("â®ï¸", "â®ï¸Ž", "[<<]"); Shuffle = @("ðŸ”€", "ðŸ”€ï¸Ž", "[SHF]")
                Repeat = @("ðŸ”", "ðŸ”ï¸Ž", "[RPT]"); VolumeMax = @("ðŸ”Š", "ðŸ•ª", "[MAX]"); VolumeMed = @("ðŸ”‰", "ðŸ•©", "[MED]"); VolumeMin = @("ðŸ”ˆ", "ðŸ•¨", "[MIN]")
                VolumeMute = @("ðŸ”‡", "ðŸ”‡ï¸Ž", "[MUTE]"); MicOn = @("ðŸŽ¤", "ðŸŽ¤ï¸Ž", "[MIC_ON]"); MicOff = @("ðŸŽ¤ðŸš«", "ðŸŽ¤ï¸ŽðŸš«ï¸Ž", "[MIC_OFF]"); CameraOn = @("ðŸ“·", "â—˜", "[CAM_ON]")
                CameraOff = @("ðŸ“·ðŸš«", "ðŸ“·ðŸš«ï¸Ž", "[CAM_OFF]")
                Print = @("ðŸ–¨ï¸", "âŽ™", "[PRT]"); Scan = @("ðŸ“ ", "âŽš", "[SCN]"); Fax = @("ðŸ“ ", "âŽš", "[FAX]")
                MailSend = @("ðŸ“¤", "á¯“âž¤", "[SENT]"); MailReceive = @("ðŸ“¥", "ðŸ“¥ï¸Ž", "[INBOX]"); MailDraft = @("ðŸ“", "ðŸ“ï¸Ž", "[DRAFT]"); MailArchive = @("ðŸ—„ï¸ðŸ“§", "ðŸ—„ðŸ“§ï¸Ž", "[ARCH]")
                Share = @("ðŸ”—", "â˜", "[SHR]"); Link = @("ðŸ”—", "â˜", "[LNK]"); Unlink = @("âœ‚ï¸", "âœ‚ï¸Ž", "[UNLK]")
                Copy = @("ðŸ“‹", "âŽ˜", "[CPY]"); Cut = @("âœ‚ï¸", "âœ‚ï¸Ž", "[CUT]"); Paste = @("ðŸ“Œ", "ðŸ–ˆ", "[PST]"); Clone = @("âŠ¹", "âŠ¹ï¸Ž", "[CLN]")
                Save = @("ðŸ’¾", "ðŸ–«", "[SAV]"); SaveAs = @("ðŸ’¾âœï¸", "ðŸ–«âœï¸Ž", "[SAVAS]"); Trash = @("ðŸ—‘ï¸", "ðŸ—‘", "[DEL]"); Delete = @("ðŸ—‘ï¸", "ðŸ—‘ï¸Ž", "[DEL]")
                Restore = @("ðŸ”„ðŸ—‘ï¸", "ðŸ”„ï¸ŽðŸ—‘ï¸Ž", "[RST]"); Undo = @("â†©ï¸", "â†¶", "[UNDO]"); Redo = @("â†ªï¸", "â†·", "[REDO]"); New = @("ðŸ†•", "â˜…", "[NEW]")
                Open = @("ðŸ“‚", "â—ª", "[OPEN]"); Edit = @("âœ", "âœï¸Ž", "[EDIT]"); Load = @("ðŸ“‚", "â—ª", "[LOAD]"); Import = @("ðŸ“¥", "â‡Š", "[IMP]")
                Export = @("ðŸ“¤", "â‡ˆ", "[EXP]"); Upload = @("â¤’", "â‡¡", "[UPL]"); Download = @("â¤“", "â‡£", "[DWN]"); Install = @("ðŸ’¿", "ðŸ’¿ï¸Ž", "[INS]")
                Uninstall = @("ðŸ’½", "ðŸ’½ï¸Žâš¡ï¸Ž", "[RMV]"); Execute = @("âš¡", "âš¡ï¸Ž", "[EXEC]"); Build = @("ðŸ› ï¸", "ðŸ› ï¸Ž", "[BLD]"); Deploy = @("ðŸš€", "ðŸš€ï¸Ž", "[DEP]")
                Test = @("ðŸ§ª", "âš—", "[TST]"); Write = @("âœ", "âœï¸Ž", "[WRT]")
                Tools = @("ðŸ§°", "ðŸ§°ï¸Ž", "[TLS]"); Wrench = @("ðŸ”§", "ðŸ”§ï¸Ž", "[WRN]"); Hammer = @("ðŸ”¨", "â˜­", "[HMR]"); Pickaxe = @("â›ï¸", "â›ï¸Ž", "[PCK]")
                Construction = @("ðŸ—ï¸", "ðŸ—ï¸Ž", "[BLD]"); Screwdriver = @("ðŸª›", "ðŸª›ï¸Ž", "[SCW]"); Saw = @("ðŸªš", "ðŸªšï¸Ž", "[SAW]"); Axe = @("ðŸª“", "ðŸª“ï¸Ž", "[AXE]")
                Bucket = @("ðŸª£", "ÖŽ", "[BKT]"); Plunger = @("ðŸª ", "â™", "[PLG]"); Broom = @("ðŸ§¹", "ðŸ§¹ï¸Ž", "[BRM]"); Sponge = @("ðŸ§½", "ðŸ§½ï¸Ž", "[SPN]")
                Funnel = @("â³", "â³ï¸Ž", "[FNL]")
                Fire = @("ðŸ”¥", "ðŸ”¥ï¸Ž", "[FIRE]"); Lightning = @("âš¡", "âš¡ï¸Ž", "[LTN]"); Sparkle = @("âœ¨", "â‚", "[*]")

                # --- GIT & DEVOPS ICONS ---
                GitBranch = @("ðŸŒ¿", "âŽ‡", "[BR]"); CodeCommit = @("ðŸ“Œ", "ðŸ–ˆ", "[COMMIT]"); GitPush = @("â¬†ï¸", "â‡¡", "[PUSH]"); GitPull = @("â¬‡ï¸", "â‡£", "[PULL]")
                GitMerge = @("ðŸ”€", "â‡¶", "[MERGE]")

                # --- CLOTHING & ACCESSORIES ---
                GraduationCap = @("ðŸŽ“", "â—¬", "[GRAD]"); TopHat = @("ðŸŽ©", "ðŸŽ©ï¸Ž", "[HAT]"); Backpack = @("ðŸŽ’", "ðŸŽ’ï¸Ž", "[BAG]"); Dress = @("ðŸ‘—", "â—Œ", "[DRS]")
                Bikini = @("ðŸ‘™", "â—", "[BIK]"); Purse = @("ðŸ‘›", "âŠš", "[PRS]"); ManShoe = @("ðŸ‘ž", "ðŸ‘žï¸Ž", "[SHO]"); RunningShoe = @("ðŸ‘Ÿ", "ðŸ‘Ÿï¸Ž", "[RUN]")
                ClutchBag = @("ðŸ‘", "âŠ¡", "[CLU]"); Handbag = @("ðŸ‘œ", "âŠ ", "[HAN]"); TShirt = @("ðŸ‘•", "â—¦", "[TSH]"); WomansSandal = @("ðŸ‘¡", "âŠ“", "[SND]")
                Crown = @("ðŸ‘‘", "ðŸ‘‘ï¸Ž", "[CRN]"); Lipstick = @("ðŸ’„", "âŒ•", "[LIP]"); WomansClothes = @("ðŸ‘š", "â—¬", "[WCL]"); WomansBoot = @("ðŸ‘¢", "âŠŸ", "[WBT]")
                Ring = @("ðŸ’", "â—‰", "[RNG]"); Kimono = @("ðŸ‘˜", "â—ˆ", "[KIM]"); GemStone = @("ðŸ’Ž", "â—ˆ", "[GEM]"); Glasses = @("ðŸ‘“", "âŒ", "[GLS]")
                Jeans = @("ðŸ‘–", "â—­", "[JNS]"); Necktie = @("ðŸ‘”", "âŒ™", "[TIE]"); HighHeel = @("ðŸ‘ ", "âŠ”", "[HEL]"); PrayerBeads = @("ðŸ“¿", "âŠ—", "[PRAY]")
                WomansHat = @("ðŸ‘’", "â—Š", "[WHAT]"); Sunglasses = @("ðŸ•¶ï¸", "ðŸ•¶ï¸Ž", "[SUN]"); ShoppingBags = @("ðŸ›ï¸", "âŠŸâŠŸ", "[SHOP]"); BilledCap = @("ðŸ§¢", "âŠ“", "[CAP]")
                SafetyVest = @("ðŸ¦º", "â›¨", "[SAFE]"); Scarf = @("ðŸ§£", "âŒ‡", "[SCRF]"); Gloves = @("ðŸ§¤", "ðŸ§¤ï¸Ž", "[GLV]"); Coat = @("ðŸ§¥", "ðŸ§¥ï¸Ž", "[COAT]")
                Socks = @("ðŸ§¦", "âŒµ", "[SCK]"); Sari = @("ðŸ¥»", "â—¬", "[SARI]"); HikingBoot = @("ðŸ¥¾", "âŠŸ", "[HIKE]"); LabCoat = @("ðŸ¥¼", "ðŸ¥¼ï¸Ž", "[LAB]")
                FlatShoe = @("ðŸ¥¿", "ðŸ–¦", "[FLAT]"); Goggles = @("ðŸ¥½", "â—”", "[GOG]"); MilitaryHelmet = @("ðŸª–", "â›¨", "[MIL]"); BalletShoes = @("ðŸ©°", "ðŸ–¦", "[BALL]")
                ThongSandal = @("ðŸ©´", "âŠ£", "[THONG]"); Swimsuit = @("ðŸ©±", "âŒ†", "[SWIM]"); Briefs = @("ðŸ©²", "â–¯", "[BRF]"); Shorts = @("ðŸ©³", "â–­", "[SHRT]")
                FoldingFan = @("ðŸª­", "á¨", "[FAN]"); HairPick = @("ðŸª®", "á¨", "[PICK]"); RescueHelmet = @("â›‘ï¸", "â›‘ï¸Ž", "[RSC]")

                # --- MUSIC & AUDIO ---
                Loudspeaker = @("ðŸ“¢", "âŒ²", "[SPK]"); Megaphone = @("ðŸ“£", "âŒ»", "[MEGA]"); PostalHorn = @("ðŸ“¯", "âŒº", "[HORN]"); MutedSpeaker = @("ðŸ”‡", "ðŸ”‡ï¸Ž", "[MUTE]")
                SpeakerLow = @("ðŸ”ˆ", "â—¬", "[SPK1]"); SpeakerMed = @("ðŸ”‰", "â—­", "[SPK2]"); SpeakerHigh = @("ðŸ”Š", "â—®", "[SPK3]"); Bell = @("ðŸ””", "ðŸ””ï¸Ž", "[BELL]")
                BellSlash = @("ðŸ”•", "ðŸ”•ï¸Ž", "[NOBEL]"); ControlKnobs = @("ðŸŽ›ï¸", "ðŸŽ›ï¸Ž", "[KNOB]"); StudioMic = @("ðŸŽ™ï¸", "ðŸŽ™ï¸Ž", "[STUM]"); Microphone = @("ðŸŽ¤", "ðŸŽ¤ï¸Žï¸Ž", "[MIC]")
                LevelSlider = @("ðŸŽšï¸", "ðŸŽšï¸Ž", "[SLDR]"); MusicalNotes = @("ðŸŽ¶", "â™ªâ™«", "[NOTES]"); MusicalScore = @("ðŸŽ¼", "ðŸŽ¼ï¸Ž", "[SCORE]"); MusicalNote = @("ðŸŽµ", "â™ª", "[NOTE]")
                Headphone = @("ðŸŽ§", "â˜Š", "[HP]"); Radio = @("ðŸ“»", "âŒ»", "[RAD]"); Violin = @("ðŸŽ»", "ðŸŽ»ï¸Ž", "[VLN]"); Trumpet = @("ðŸŽº", "ðŸŽºï¸Ž", "[TRU]")
                Saxophone = @("ðŸŽ·", "â›", "[SAX]"); Keyboard = @("ðŸŽ¹", "ðŸŽ¹ï¸Ž", "[KEYB]"); Guitar = @("ðŸŽ¸", "ðŸŽ¸ï¸Ž", "[GTR]"); Drum = @("ðŸ¥", "â—‰", "[DRUM]")
                Banjo = @("ðŸª•", "ðŸª•ï¸Ž", "[BANJ]"); Accordion = @("ðŸª—", "âŒ‡âŒ‡", "[ACC]"); LongDrum = @("ðŸª˜", "â—‰", "[LDRU]"); Flute = @("ðŸªˆ", "âš±", "[FLT]")
                Maracas = @("ðŸª‡", "âŠ¡", "[MARA]"); Harp = @("ðŸª‰", "ðŸª‰", "[HARP]")

                # --- OFFICE & STATIONERY ---
                TelephoneReceiver = @("ðŸ“ž", "ðŸ•½", "[PHONE]"); FaxMachine = @("ðŸ“ ", "âŽš", "[FAX]"); MobilePhone = @("ðŸ“±", "ðŸ–", "[MOB]"); Pager = @("ðŸ“Ÿ", "âŒ¨", "[PGR]")
                MobileArrow = @("ðŸ“²", "â‡¡", "[MOBA]"); Telephone = @("â˜Žï¸", "ðŸ•¿", "[TEL]"); Dvd = @("ðŸ“€", "ðŸ’¿ï¸Ž", "[DVD]"); OpticalDisk = @("ðŸ’¿", "ðŸ’¿ï¸Ž", "[CD]")
                FloppyDisk = @("ðŸ’¾", "ðŸ–«", "[FLOP]"); ComputerDisk = @("ðŸ’½", "ðŸ’½ï¸Ž", "[HD]"); Laptop = @("ðŸ’»", "ðŸ’»ï¸Ž", "[LAP]"); ComputerMouse = @("ðŸ–±ï¸", "ðŸ–°", "[MOUSE]")
                Trackball = @("ðŸ–²ï¸", "â—‰", "[TRK]"); Desktop = @("ðŸ–¥ï¸", "ðŸ–³", "[PC]"); Printer = @("ðŸ–¨ï¸", "âŽ™", "[PRN]"); Battery = @("ðŸ”‹", "â–®", "[BAT]")
                Plug = @("ðŸ”Œ", "ðŸ”Œï¸Ž", "[PLUG]"); Abacus = @("ðŸ§®", "ðŸ§®ï¸Ž", "[ABAC]"); LowBattery = @("ðŸª«", "â–¯", "[LBAT]"); KeyboardDev = @("âŒ¨ï¸", "âŒ¨ï¸Ž", "[KBD]")

                # --- MEDIA & ELECTRONICS ---
                MovieCamera = @("ðŸŽ¥", "â—°", "[CAM]"); ClapperBoard = @("ðŸŽ¬", "ðŸŽ¬ï¸Ž", "[ACT]"); Lantern = @("ðŸ®", "â—Œ", "[LAN]"); FilmFrames = @("ðŸŽžï¸", "ðŸŽžï¸Ž", "[FILM]")
                VideoCamera = @("ðŸ“¹", "â—°", "[VID]"); CameraFlash = @("ðŸ“¸", "â˜Ž", "[CAMF]"); Camera = @("ðŸ“·", "â˜Ž", "[CAM]"); LightBulb = @("ðŸ’¡", "â—Œ", "[LAMP]")
                Television = @("ðŸ“º", "ðŸ“ºï¸Ž", "[TV]"); Videocassette = @("ðŸ“¼", "â—§", "[VHS]"); FilmProjector = @("ðŸ“½ï¸", "ðŸ“½", "[PROJ]"); Candle = @("ðŸ•¯ï¸", "ðŸ•¯", "[CNDL]")
                MagnifyRight = @("ðŸ”Ž", "âŒ•", "[MAG]"); MagnifyLeft = @("ðŸ”", "ðŸ”ï¸Ž", "[MAG]"); Flashlight = @("ðŸ”¦", "âŒ", "[FLSH]"); DiyaLamp = @("ðŸª”", "â—Œ", "[DIY]")
                Label = @("ðŸ·ï¸", "ðŸ·ï¸Ž", "[LBL]"); BookmarkTabs = @("ðŸ“‘", "ðŸ“‘ï¸Ž", "[BMT]"); Notebook = @("ðŸ““", "ðŸ““ï¸Ž", "[NB]"); PageCurl = @("ðŸ“ƒ", "âŒ‡", "[PC]")
                ClosedBook = @("ðŸ“•", "ðŸ“•ï¸Ž", "[BOOK]"); Ledger = @("ðŸ“’", "ðŸ“’ï¸Ž", "[LEDG]"); GreenBook = @("ðŸ“—", "ðŸ“—ï¸Ž", "[GBK]"); NotebookDeco = @("ðŸ“”", "ðŸ“”ï¸Ž", "[NBD]")
                OrangeBook = @("ðŸ“™", "ðŸ“™ï¸Ž", "[OBK]"); OpenBook = @("ðŸ“–", "â—°", "[OPEN]"); BlueBook = @("ðŸ“˜", "ðŸ“˜ï¸Ž", "[BBK]"); Scroll = @("ðŸ“œ", "âŒ‡", "[SCRL]")
                Books = @("ðŸ“š", "ðŸ“šï¸Ž", "[LIBS]"); PageUp = @("ðŸ“„", "ðŸ“„ï¸Ž", "[PAGE]"); Newspaper = @("ðŸ“°", "ðŸ“°ï¸Ž", "[NEWS]"); RolledNewspaper = @("ðŸ—žï¸", "ðŸ—žï¸Ž", "[ROLL]")

                # --- MONEY & FINANCE ---
                MoneyWings = @("ðŸ’¸", "ðŸ’¸ï¸Ž", "[MNY]"); PoundNote = @("ðŸ’·", "Â£", "[GBP]"); ChartYen = @("ðŸ’¹", "Â¥", "[YEN]"); EuroNote = @("ðŸ’¶", "â‚¬", "[EUR]")
                DollarNote = @("ðŸ’µ", "$", "[USD]"); YenNote = @("ðŸ’´", "Â¥", "[JPY]"); CreditCard = @("ðŸ’³", "âŒ§", "[CC]"); MoneyBag = @("ðŸ’°", "ðŸ’°ï¸Ž", "[BAG]")
                Receipt = @("ðŸ§¾", "âŒ‡", "[RCPT]"); Coin = @("ðŸª™", "â—‰", "[COIN]"); Ticket = @("ðŸŽ«", "ðŸŽ«ï¸Ž", "[TCK]")

                # --- MAIL & COMMUNICATION ---
                MailboxDown = @("ðŸ“ª", "â—¬", "[MBD]"); MailboxUp = @("ðŸ“«", "â—¬", "[MBU]"); MailboxOpenUp = @("ðŸ“¬", "â—¬", "[MBOU]"); MailboxOpenDown = @("ðŸ“­", "â—¬", "[MBOD]")
                Email = @("ðŸ“§", "ðŸ“§ï¸Ž", "[EML]"); OutboxTray = @("ðŸ“¤", "â‡¡", "[OUT]"); InboxTray = @("ðŸ“¥", "â‡£", "[IN]"); Package = @("ðŸ“¦", "ðŸ“¦ï¸Ž", "[PKG]")
                IncomingEnvelope = @("ðŸ“¨", "ðŸ“¨ï¸Ž", "[INEN]"); EnvelopeArrow = @("ðŸ“©", "â‡¡", "[ENVA]"); Postbox = @("ðŸ“®", "ðŸ“®ï¸Ž", "[POST]"); BallotBox = @("ðŸ—³ï¸", "â˜‘", "[VOTE]")
                Envelope = @("âœ‰ï¸", "âœ‰ï¸Ž", "[ENV]"); Memo = @("ðŸ“", "ðŸ“ï¸Ž", "[MEMO]"); Crayon = @("ðŸ–ï¸", "ðŸ–ï¸Ž", "[CRY]"); FountainPen = @("ðŸ–‹ï¸", "ðŸ–‹ï¸Ž", "[PEN]")
                Paintbrush = @("ðŸ–Œï¸", "ðŸ–Œï¸Ž", "[BRUSH]"); Pen = @("ðŸ–Šï¸", "ðŸ–Šï¸Ž", "[PEN]"); BlackNib = @("âœ’ï¸", "âœ’ï¸Ž", "[NIB]"); Pencil = @("âœï¸", "âœï¸Ž", "[PEN]")
                ChartUp = @("ðŸ“ˆ", "ðŸ“ˆï¸Ž", "[CHUP]"); Pushpin = @("ðŸ“Œ", "ðŸ–ˆ", "[PIN]"); BarChart = @("ðŸ“Š", "ðŸ“Šï¸Ž", "[BCH]"); RulerTriangle = @("ðŸ“", "ðŸ“ï¸Ž", "[RUL]")
                Clipboard = @("ðŸ“‹", "ðŸ“‹ï¸Ž", "[CLIP]"); ChartDown = @("ðŸ“‰", "ðŸ— ", "[CHDN]"); RulerStraight = @("ðŸ“", "â”€", "[RUL]"); FileFolder = @("ðŸ“", "ðŸ“ï¸Ž", "[DIR]")
                RoundPushpin = @("ðŸ“", "ð–¤£", "[PIN]"); Briefcase = @("ðŸ’¼", "ðŸ’¼ï¸Ž", "[CASE]"); TearCalendar = @("ðŸ“†", "â—ª", "[TCAL]"); CardIndex = @("ðŸ“‡", "ðŸ“‡ï¸Ž", "[CARD]")
                OpenFolder = @("ðŸ“‚", "â—ª", "[OPN]"); Paperclip = @("ðŸ“Ž", "ðŸ“Žï¸Ž", "[CLIP]"); FileCabinet = @("ðŸ—„ï¸", "ðŸ—„ï¸Ž", "[CAB]"); CardBox = @("ðŸ—ƒï¸", "ðŸ—ƒï¸Ž", "[CBOX]")
                CardDividers = @("ðŸ—‚ï¸", "ðŸ—‚ï¸Ž", "[DIV]"); LinkedClips = @("ðŸ–‡ï¸", "ðŸ–‡ï¸Ž", "[LINK]"); SpiralCalendar = @("ðŸ—“ï¸", "â—ª", "[SCAL]"); Wastebasket = @("ðŸ—‘ï¸", "ðŸ—‘", "[TRASH]")
                SpiralNotepad = @("ðŸ—’ï¸", "ðŸ—’ï¸Ž", "[NOT]"); Scissors = @("âœ‚ï¸", "âœ‚ï¸Ž", "[SCIS]")

                # --- HOUSEHOLD & TOOLS ---
                LockedKey = @("ðŸ”", "ðŸ”ï¸Ž", "[LCK]"); LockedPen = @("ðŸ”", "ðŸ”ï¸Ž", "[LCKP]"); OldKey = @("ðŸ—ï¸", "ðŸ—ï¸Ž", "[OKEY]"); BowArrow = @("ðŸ¹", "ðŸ¹ï¸Ž", "[BOW]")
                Bomb = @("ðŸ’£", "â—‰", "[BMB]"); Clamp = @("ðŸ—œï¸", "ðŸ—œï¸Ž", "[CLMP]"); Dagger = @("ðŸ—¡ï¸", "ðŸ—¡ï¸Ž", "[DAG]"); NutBolt = @("ðŸ”©", "ðŸ”©ï¸Ž", "[NUT]")
                HammerWrench = @("ðŸ› ï¸", "âš’", "[TOOL]"); Magnet = @("ðŸ§²", "âˆ©", "[MAG]"); WhiteCane = @("ðŸ¦¯", "ðŸ¦¯ï¸Ž", "[CANE]"); Toolbox = @("ðŸ§°", "âš’", "[TBX]")
                Hook = @("ðŸª", "Þƒ", "[HOOK]"); Ladder = @("ðŸªœ", "âŒ‡", "[LAD]"); Boomerang = @("ðŸªƒ", "ðŸªƒï¸Ž", "[BOOM]"); Shovel = @("ðŸª", "âŒ†", "[SHOV]")
                Gear = @("âš™ï¸", "âš™ï¸Ž", "[GEAR]"); Chains = @("â›“ï¸", "â›“ï¸Ž", "[CHN]"); CrossedSwords = @("âš”ï¸", "âš”ï¸Ž", "[XSW]"); BalanceScale = @("âš–ï¸", "âš–ï¸Ž", "[SCAL]")
                HammerPick = @("âš’ï¸", "âš’ï¸Ž", "[HMP]"); BrokenChain = @("â›“ï¸â€ðŸ’¥", "â›“â€ðŸ’¥ï¸Ž", "[BCH]"); Satellite = @("ðŸ›°ï¸", "ðŸ›°", "[SAT]"); Telescope = @("ðŸ”­", "ðŸ”­ï¸Ž", "[TEL]")
                Microscope = @("ðŸ”¬", "â—‰", "[MIC]"); TestTube = @("ðŸ§ª", "âš—", "[TUBE]"); PetriDish = @("ðŸ§«", "â—Œ", "[PETR]"); Dna = @("ðŸ§¬", "âš›ï¸Ž", "[DNA]")
                Alembic = @("âš—ï¸", "âš—ï¸Ž", "[ALEM]"); Syringe = @("ðŸ’‰", "ðŸ’‰ï¸Ž", "[SYR]"); Pill = @("ðŸ’Š", "â—‰", "[PILL]"); Stethoscope = @("ðŸ©º", "âŒ•", "[STET]")
                Bandage = @("ðŸ©¹", "âŒ‡", "[BND]"); BloodDrop = @("ðŸ©¸", "â—‰", "[BLOOD]"); Crutch = @("ðŸ©¼", "ðŸ©¼ï¸Ž", "[CRUT]"); XRay = @("ðŸ©»", "ðŸ©»ï¸Ž", "[XRAY]")
                Microbe = @("ðŸ¦ ", "ð– Œ", "[MICR]"); Factory = @("ðŸ­", "ðŸ­ï¸Ž", "[FAC]");

                # --- FURNITURE & APPLIANCES ---
                Bathtub = @("ðŸ›", "âŒ‡", "[BATH]"); Elevator = @("ðŸ›—", "â—‰", "[ELEV]"); CouchLamp = @("ðŸ›‹ï¸", "ðŸ›‹ï¸Ž", "[SOFA]"); ShoppingCart = @("ðŸ›’", "ðŸ›’ï¸Ž", "[CART]")
                Shower = @("ðŸš¿", "âŒ‡", "[SHWR]"); Bed = @("ðŸ›ï¸", "âŒ‡", "[BED]"); Toilet = @("ðŸš½", "â—‰", "[TOIL]"); Door = @("ðŸšª", "ðŸšªï¸Ž", "[DOOR]")
                LotionBottle = @("ðŸ§´", "â—Œ", "[LOT]"); FireExtinguisher = @("ðŸ§¯", "ðŸ§¯ï¸Ž", "[FIREX]"); SafetyPin = @("ðŸ§·", "ðŸ§·ï¸Ž", "[PIN]"); Basket = @("ðŸ§º", "ðŸ§ºï¸Ž", "[BASK]")
                Soap = @("ðŸ§¼", "â—Œ", "[SOAP]"); PaperRoll = @("ðŸ§»", "âŒ‡", "[PAP]"); Toothbrush = @("ðŸª¥", "ðŸª¥ï¸Ž", "[TOOTH]"); Mousetrap = @("ðŸª¤", "ðŸª¤ï¸Ž", "[TRAP]")
                Window = @("ðŸªŸ", "ðŸªŸï¸Ž", "[WIN]"); Mirror = @("ðŸªž", "ðŸªžï¸Ž", "[MIR]"); Chair = @("ðŸª‘", "ðŸª‘ï¸Ž", "[CHAIR]"); Razor = @("ðŸª’", "ðŸª’ï¸Ž", "[RAZ]")
                Bubbles = @("ðŸ«§", "â—Œ", "[BUB]"); Moai = @("ðŸ—¿", "ðŸ—¿ï¸Ž", "[MOAI]"); Cigarette = @("ðŸš¬", "âŒ‡", "[CIG]"); NazarAmulet = @("ðŸ§¿", "â—‰", "[NAZ]")
                Placard = @("ðŸª§", "ðŸª§ï¸Ž", "[PLAC]"); Headstone = @("ðŸª¦", "ðŸª¦ï¸Ž", "[TOMB]"); IDCardIcon = @("ðŸªª", "ðŸªªï¸Ž", "[ID]"); Hamsa = @("ðŸª¬", "âšœ", "[HAM]")
                FuneralUrn = @("âš±ï¸", "âš±", "[URN]"); Coffin = @("âš°ï¸", "âš°ï¸Ž", "[COFF]"); Monster = @("ðŸ‘¾", "ðŸ‘¾ï¸Ž", "[MON]"); Alien = @("ðŸ‘½", "ðŸ‘½ï¸Ž", "[ALN]")

                # --- VISUAL & DECORATIVE ---
                StarEmpty = @("â˜†", "â˜†ï¸Ž", "[ ]"); StarHalf = @("â¯¨", "â˜…ï¸Ž", "[*]"); StarFull = @("â­", "â˜…", "[â˜…]"); HeartEmpty = @("â™¡", "â™¡ï¸Ž", "[ ]")
                HeartFull = @("â¤ï¸", "â™¥", "[â™¥]"); Bookmark = @("ðŸ”–", "ðŸ”–ï¸Ž", "[BMK]"); Tag = @("ðŸ·ï¸", "ðŸ·ï¸Ž", "[TAG]"); Flag = @("ðŸš©", "âš‘", "[FLG]")
                Trophy = @("ðŸ†", "â›¨", "[WIN]"); Medal = @("ðŸŽ–ï¸", "ðŸŽ–ï¸Ž", "[MED]"); Snowflake = @("â„ï¸", "â„ï¸Ž", "[SNOW]"); Drop = @("ðŸ’§", "ðŸ’§ï¸Ž", "[DROP]")
                Sun = @("â˜€ï¸", "â˜€ï¸Ž", "[SUN]"); Moon = @("ðŸŒ™", "â˜½", "[MON]"); Cloud = @("â˜ï¸", "â˜ï¸Ž", "[CLD]"); Rainbow = @("ðŸŒˆ", "â—®", "[RBW]")
                SepDot = @("ãƒ»", "Â·", "[.]"); SepDash = @("â”€", "â”€ï¸Ž", "[-]"); SepDouble = @("â•", "â•ï¸Ž", "[=]"); SepWave = @("ã€œ", "â‰ˆ", "[~]")
                SepArrow = @("âŸ¶", "â†’", "[->]"); SepChevron = @("Â»", "Â»ï¸Ž", "[>]")
                BoxTL = @("â•­", "â”Œ", "+"); BoxTR = @("â•®", "â”", "+"); BoxBL = @("â•°", "â””", "+"); BoxBR = @("â•¯", "â”˜", "+")
                BoxH = @("â”€", "â”€", "-"); BoxV = @("â”‚", "â”‚ï¸Ž", "|"); BoxCross = @("â”¼", "â”¼ï¸Ž", "[+]")

                # --- POWERSHELL NATIVE ---
                PSPrompt = @("âŒª", ">", "[PS]"); PSClass = @("ðŸ—ï¸", "ðŸ—ï¸Ž", "[CLS]"); PSFunction = @("âš™ï¸", "Æ’", "[FN]"); PSFunctionPrivate = @("ðŸ”’âš™ï¸", "ðŸ”’ï¸Žâš™ï¸Ž", "[PRVF]")
                PSFunctionPublic = @("ðŸ”“âš™ï¸", "ðŸ”“ï¸Žâš™ï¸Ž", "[PUBF]"); PSVariable = @("$", "$ï¸Ž", "[VAR]"); PSVariableConst = @("ðŸ”’$", "ðŸ”’ï¸Ž$ï¸Ž", "[CVAR]"); PSVariableEnv = @("ðŸŒ$", "âŒ¾$", "[EVAR]")
                PSModule = @("ðŸ§©", "ðŸ§©ï¸Ž", "[MOD]"); PSModuleCore = @("ðŸ’ ", "â—ˆ", "[CORE]"); PSModuleScript = @("ðŸ“œ", "â‰¡", "[SCR]"); PSEnum = @("ðŸ“‹", "ðŸ“‹ï¸Ž", "[ENUM]")
                PSRunspace = @("ðŸ§µ", "ðŸ§µï¸Ž", "[RS]"); PSJob = @("ðŸ“¬", "ðŸ“¬ï¸Ž", "[JOB]"); PSJobRunning = @("ðŸŸ¢ðŸ“¬", "ðŸ“¬ï¸Žâœ…ï¸Ž", "[RUN]"); PSJobStopped = @("ðŸ”´ðŸ“¬", "ðŸ“¬ï¸ŽâŒï¸Ž", "[STOP]")
                PSPipeline = @("âŽ¸", "â‡¶", "[PIPE]"); PSOutput = @("ðŸ“¤", "â‡ˆ", "[OUT]"); PSInput = @("ðŸ“¥", "â‡Š", "[IN]"); PSProfile = @("ðŸ‘¤âš™ï¸", "â˜»âš™", "[PROF]")
                PSHistory = @("âŽŒ", "â‡ ", "[HIST]"); PSAlias = @("ðŸ·ï¸", "ðŸ·ï¸Ž", "[ALIAS]"); PSDebug = @("ðŸ›", "ðŸ›ï¸Ž", "[DBG]"); PSVerbose = @("ðŸ—£ï¸", "ðŸ—£", "[VB]")
                PSWarning = @("âš ï¸", "âš ï¸Ž", "[WRN]"); PSError = @("âŒ", "âŒï¸Ž", "[ERR]"); PSGet = @("ðŸ“¥", "â‡Š", "[GET]"); PSSet = @("ðŸ“¤", "â‡ˆ", "[SET]")
                PSNew = @("ðŸ†•", "ðŸ†•ï¸Ž", "[NEW]"); PSRemove = @("ðŸ—‘ï¸", "âŒ«", "[RM]"); PSClear = @("ðŸ§¹", "âŒ§", "[CLR]"); PSImport = @("ðŸ“¦âž¡ï¸", "ðŸ“¦ï¸Žâž¡ï¸Ž", "[IMP]")
                PSExport = @("âž¡ï¸ðŸ“¦", "âž¡ðŸ“¦ï¸Ž", "[EXP]"); PSHelp = @("â”", "â‡", "[?]"); PSAbout = @("â„¹ï¸", "â„¹ï¸Ž", "[i]")

                # --- MISC & FALLBACKS ---
                Unknown = @("â“", "â‡", "[?]"); Placeholder = @("âœŒï¸ŽðŸ•·ï¸Ž", "â–¡ï¸Ž", "[ ]"); Loading = @("â³", "â³ï¸Ž", "[...]"); Processing = @("âš™ï¸", "âš™ï¸Ž", "[PROC]")
                Waiting = @("ðŸ•", "â—·", "[WAIT]"); Idle = @("ðŸ˜´", "âŒ¾", "[IDLE]"); Ready = @("âœ…", "âœ…ï¸Ž", "[READY]"); Source = @("â›²", "â›²ï¸Ž", "[SRC]")
                Spiral = @("ðŸŒ€", "ðŸŒ€ï¸Ž", "[SPI]"); FallbackIcon = "â€¢"; FallbackText = "[?]"
        }

        # ===========================================================================
        # 14. SEMANTIC MAPPING (Icon = Action)
        # ===========================================================================
        SemanticMap          = @{
                AUTORUNS = "Execute"
                AUTOSPSY = "TestTube"
                BUILD_EXE_PORTABLE = "Install"
                BUILD_EXE_SETUP = "Install"
                BUILD_MONOLITH = "Build"
                BUILD_MSI = "Install"
                CANCEL = "Close"
                CAP_ALTERNATESCREEN = "WindowFull"
                CAP_BRACKETEDPASTE = "Paste"
                CAP_CSIUKEYBOARD = "Keyboard"
                CAP_FALLBACK16 = "Color16"
                CAP_FALLBACK256 = "Color256"
                CAP_FOCUSEVENTS = "EyeOpen"
                CAP_HYPERLINKS = "Link"
                CAP_KITTYKEYBOARD = "Keyboard"
                CAP_MOUSETRACKING = "Mouse"
                CAP_SIXELGRAPHICS = "ImageDisk"
                CAP_TRUECOLOR = "Palette"
                CAPABILITIES = "Monitor"
                CHKDSK = "Disk"
                DD = "Disk"
                DEFAULT_OUT = "Folder"
                DISKPART = "DiskHDD"
                DISM = "Shield"
                ENGINE_MODE = "Config"
                EVENTVWR = "FileLog"
                EVERYTHING = "Search"
                EXIT = "Power"
                FILEHASH = "HashCalc"
                FOLDER = "Folder"
                FORENSICS = "EyeOpen"
                FRAME_STYLE = "WindowTile"
                FSUTIL = "FileConfig"
                FTKIMAGER = "ImageDisk"
                HARVESTER = "Bucket"
                ICON_LEVEL = "EyeOpen"
                INIT_SYSTEM = "Rocket"
                KAPE = "Shield"
                LABORATORY = "TestTube"
                LANGUAGE = "Chat"
                LOG2TIMELINE = "Clock"
                LOGISTICS = "DeliveryTruck"
                MAGNET = "Search"
                MEMORYZE = "Memory"
                NET_MGR = "Network"
                NET_SCAN = "NetworkLocal"
                NET_UNMOUNT_ALL = "Eject"
                NMAP = "Network"
                PARSING = "Target"
                PHOTOREC = "Recovered"
                PLASO = "Clock"
                PROCEXP = "CPU"
                PROGRESS_STYLE = "Hourglass"
                RANDOM_THEME = "Random"
                RC_BTN_CANCEL = "Close"
                RC_BTN_SAVE = "Save"
                RC_FLAG_B = "Settings"
                RC_FLAG_COPYALL = "Copy"
                RC_FLAG_DCOPY_T = "Copy"
                RC_FLAG_E = "Settings"
                RC_FLAG_FFT = "Clock"
                RC_FLAG_L = "FileLog"
                RC_FLAG_M = "Settings"
                RC_FLAG_MT = "CPU"
                RC_FLAG_NP = "Settings"
                RC_FLAG_V = "FileLog"
                RC_FLAG_XJ = "Settings"
                RC_FLAG_XN = "Settings"
                RC_FLAG_XO = "Settings"
                RC_FLAG_ZB = "Settings"
                RC_RETRY_R = "Repeat"
                RC_RETRY_W = "Timer"
                REDLINE = "Bug"
                REGCFG = "FileConfig"
                RESET = "Refresh"
                RETURN = "Return"
                ROBO_CFG = "Config"
                ROBOCOPY = "Sync"
                SCAN = "Search"
                SETTINGS = "Settings"
                SFC = "Shield"
                SLEUTHKIT = "Search"
                STORDIAG = "Disk"
                SYNC_START = "Play"
                SYSINTERNALS = "Terminal"
                TAG_PREPARE = "Edit"
                TCPDUMP = "NetworkWired"
                TESTDISK = "Recovered"
                THEME = "Palette"
                THEME_COLOR = "Palette"
                THEME_PERSONA = "Persona"
                VOLATILITY = "Memory"
                WINDIRSTAT = "PieChart"
                WINFR = "Recovered"
                WIRESHARK = "Network"
                XWAYS = "Search"
                # NÃšCLEO & TAREFAS PRINCIPAIS
# NÃšCLEO & TAREFAS PRINCIPAIS
                SCAN = "Search"; PARSING = "Target"; ARCHAEOLOGY = "Pickaxe"; HARVESTER = "Bucket"
                FORENSICS = "EyeOpen"; SETTINGS = "Wrench"; CAPABILITIES = "Monitor"; LOGISTICS = "DeliveryTruck"; LABORATORY = "TestTube"
                "EXIT" = "Power"; HOME = "Home"; DASHBOARD = "WindowTile"; OVERVIEW = "Info"
                STATUS = "Info"; ABOUT = "Help"; HELP = "Help"; DOCS = "FileCode"
                SUPPORT = "Critical"; FEEDBACK = "MailSend"
                BITWISE_TAGGING = "WIP"; TOPOLOGY_SCAN = "NetworkLocal"; TELEMETRY_SCAN = "ServerRack"
                TARGET_ARCHAEOLOGY = "Pickaxe"; BATCH_PROCESSING = "Robot"; FILE_LABORATORY = "TestTube"
                HYDRATION_MODE = "Palette"; CLOUD_SYNC = "NetworkCloud"
                NET_SCAN = "NetworkLocal"; NET_UNMOUNT_ALL = "Eject"

                # NAVEGAÃ‡ÃƒO & CONTROLE DE FLUXO
                "RETURN" = "Return"; CANCEL = "Close"; CLOSE = "Close"; AUTO = "Robot"
                UNMOUNT = "Eject"; DELETE = "Trash"; REMOVE = "Trash"; FOLDER = "Folder"
                DIRECTORY = "Folder"; DIR = "Folder"; FILE = "File"; OPEN = "FolderOpen"
                BROWSE = "Search"; NAVIGATE = "Compass"; UP = "ArrowUp"; DOWN = "ArrowDown"
                LEFT = "ArrowLeft"; RIGHT = "ArrowRight"; NEXT = "ArrowTarget"; PREV = "ArrowLeft"
                PREVIOUS = "ArrowLeft"; FIRST = "Home"; LAST = "End"; JUMP = "ArrowJump"
                GOTO = "ArrowRedirect"; NEXT_TAB = "NextTab"; PREV_TAB = "PrevTab"

                # OPERAÃ‡Ã•ES DE ARQUIVO & SISTEMA
                NEW = "BadgeNew"; CREATE = "BadgeNew"; SAVE = "Save"; SAVE_AS = "SaveAs"
                LOAD = "Load"; IMPORT = "Import"; EXPORT = "Export"; COPY = "Copy"
                CUT = "Cut"; PASTE = "Paste"; CLONE = "Clone"; DUPLICATE = "Clone"
                RENAME = "InputText"; EDIT = "Edit"; MODIFY = "Wrench"; UPDATE = "Update"
                REFRESH = "Refresh"; RELOAD = "Refresh"; SYNC = "Sync"; SYNCHRONIZE = "Sync"
                BACKUP = "DatabaseSync"; RESTORE = "Restore"; UNDELETE = "Recovered"; UNTRASH = "Recovered"
                NORMALIZE = "Normalize"; FORMAT = "Disk"; COMPRESS = "FileArchive"; DECOMPRESS = "FileArchive"
                ARCHIVE = "FileArchive"; EXTRACT = "Saw"

                # OPERAÃ‡Ã•ES DE DISCO, STORAGE & FORENSE
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

                # SEGURANÃ‡A, CYBER & AUTENTICAÃ‡ÃƒO
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

                # AÃ‡Ã•ES DE EDIÃ‡ÃƒO & HISTÃ“RICO
                UNDO = "Undo"; REDO = "Redo"; REVERT = "Undo"; RESET = "Refresh"
                CLEAR = "PSClear"; ERASE = "Trash"; SELECT_ALL = "Checkmark"; DESELECT = "Crossmark"
                FIND = "Search"; REPLACE = "InputText"; HIGHLIGHT = "StarFull"; BOOKMARK = "Bookmark"
                FAVORITE = "HeartFull"; STAR = "StarFull"; PIN = "Bookmark"; UNPIN = "Crossmark"

                # MÃDIA & MULTIMÃDIA
                PLAY = "Play"; PAUSE = "Pause"; STOP = "Stop"; RECORD = "Record"
                EJECT_MEDIA = "Eject"; VOLUME_UP = "SpeakerHigh"; VOLUME_DOWN = "SpeakerLow"; MUTE = "MutedSpeaker"
                MIC = "Microphone"; CAMERA = "Camera"; SCREENSHOT = "CameraFlash"; CAPTURE = "Camera"
                IMAGE = "FileMedia"; VIDEO = "VideoCamera"; AUDIO = "MusicalNotes"; DOCUMENT = "File"
                PDF = "FileCode"

                # FERRAMENTAS & UTILITÃRIOS ESPECÃFICOS
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

                # OPERAÃ‡Ã•ES EM LOTE & AUTOMAÃ‡ÃƒO
                BATCH = "Package"; BULK = "Bucket"; MASS = "Bucket"; AUTOMATE = "Robot"
                SCHEDULE = "Calendar"; CRON = "Calendar"; TRIGGER = "Lightning"; WEBHOOK_TRIGGER = "Webhook"
                EVENT = "Sparkle"; REACT = "Sparkle"; CHAIN = "Link"; WORKFLOW = "PSPipeline"
                PIPELINE_OP = "PSPipeline"

                # UTILITÃRIOS GERAIS (Fallbacks inteligentes)
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

                # ParÃ¢metros NumÃ©ricos (Sliders / Inputs)
                RC_FLAG_MT = "CPU"; RC_RETRY_R = "Refresh"; RC_RETRY_W = "Timer"

                # Terminal Capabilities
                CAP_TRUECOLOR = "Television"; CAP_HYPERLINKS = "Link"; CAP_BRACKETEDPASTE = "Paste"; CAP_MOUSETRACKING = "Settings"
                CAP_ALTERNATESCREEN = "WindowFull"; CAP_FOCUSEVENTS = "FocusIn"; CAP_KITTYKEYBOARD = "KeyboardDev"; CAP_SIXELGRAPHICS = "FileMedia"
                CAP_CSIUKEYBOARD = "KeyboardDev"; CAP_FALLBACK256 = "Color256"; CAP_FALLBACK16 = "Color16"
        }
}

# --- INJECTED I18N KEYS ---
# BANNER_TITLE
# CAP_MENU_TITLE
# CONFIG_VAL_EFFICIENCY
# CONFIG_VAL_REDUNDANCY
# CONFIRM_REGEX
# CORE_ADMIN_REQUIRED
# CORE_BACKUP_PRIV_GRANTED
# CORE_BACKUP_PRIV_MISSING
# CORE_ENGINE_STOP
# CORE_KERNEL_SHIELD_FAIL
# CORE_PRESERVATION_ACTIVE
# CORE_VALEDICTORY_CLEANUP
# CORE_VALEDICTORY_DONE
# CORE_VALEDICTORY_ERROR
# DOMAIN_ANALYSIS
# DOMAIN_ARCHAEOLOGY
# DOMAIN_HARVESTER
# DOMAIN_INFRA
# DOMAIN_PARSING
# PROMPT_EXE_NAME
# SYS_ACCESS_DENIED_DRIVE
# SYS_ASSET_WARN
# SYS_BARE_METAL
# SYS_BOOT_OK
# SYS_HOST_DETECTED
# SYS_MEM_CRITICAL
# SYS_NA
# SYS_VM_DETECTED
# TOPOLOGY_TITLE


# --- INJECTED I18N KEYS ---
# BANNER_TITLE
# CAP_MENU_TITLE
# CONFIG_VAL_EFFICIENCY
# CONFIG_VAL_REDUNDANCY
# CONFIRM_REGEX
# CORE_ADMIN_REQUIRED
# CORE_BACKUP_PRIV_GRANTED
# CORE_BACKUP_PRIV_MISSING
# CORE_ENGINE_STOP
# CORE_KERNEL_SHIELD_FAIL
# CORE_PRESERVATION_ACTIVE
# CORE_VALEDICTORY_CLEANUP
# CORE_VALEDICTORY_DONE
# CORE_VALEDICTORY_ERROR
# DOMAIN_ANALYSIS
# DOMAIN_ARCHAEOLOGY
# DOMAIN_HARVESTER
# DOMAIN_INFRA
# DOMAIN_PARSING
# PROMPT_EXE_NAME
# SYS_ACCESS_DENIED_DRIVE
# SYS_ASSET_WARN
# SYS_BARE_METAL
# SYS_BOOT_OK
# SYS_HOST_DETECTED
# SYS_MEM_CRITICAL
# SYS_NA
# SYS_VM_DETECTED
# TOPOLOGY_TITLE
