@{
    __Meta__      = @{
        Name    = "Navigation"
        Version = "1.0"
        Author  = "Scape.Core"
        Purpose = "Navigation & Routing Manifest. Mechanical flow, zero inference."
    }

    MainMenu      = @{
        TitleKey = "MENU_MAIN_TITLE"
        Items    = @(
            @{ Id = "SCAN"; TitleKey = "MENU_MAIN_SCAN"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Telemetry"; Task = "INVENTORY" }; Layer = "Infrastructure" }
            @{ Id = "PARSING"; TitleKey = "MENU_MAIN_PARSING"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.Parser.Core" }; Layer = "Analysis" }
            @{ Id = "ARCHAEOLOGY"; TitleKey = "MENU_MAIN_ARCHAEOLOGY"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.Carving.Carver" }; Layer = "Analysis" }
            @{ Id = "HARVESTER"; TitleKey = "MENU_MAIN_HARVESTER"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Acquisition"; Target = "Scape.Acquisition.Selection" }; Layer = "Acquisition" }
            @{ Id = "FORENSICS"; TitleKey = "MENU_MAIN_FORENSICS"; Type = "Special"; Action = "NAVIGATE"; Target = "ForensicsMenu"; Layer = "Infrastructure" }
            @{ Id = "SETTINGS"; TitleKey = "MENU_MAIN_SETTINGS"; Type = "Warning"; Action = "NAVIGATE"; Target = "SettingsMenu"; Layer = "Core" }
            @{ Id = "LOGISTICS"; TitleKey = "MENU_MAIN_LOGISTICS"; Type = "Special"; Action = "NAVIGATE"; Target = "LogisticsMenu"; Layer = "Extensions" }
            @{ Id = "LABORATORY"; TitleKey = "MENU_MAIN_LAB"; Type = "Warning"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.Abstraction" }; Layer = "Analysis" }
            @{ Id = "EXIT"; TitleKey = "MENU_MAIN_EXIT"; Type = "Destructive"; Action = "TERMINATE" }
        )
    }

    ForensicsMenu = @{
        TitleKey = "MENU_MAIN_FORENSICS"
        Items    = @(
            @{ Id = "DISKPART"; TitleKey = "TOOL_DISKPART"; Type = "Warning"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Audit" }; Layer = "Infrastructure" }
            @{ Id = "CHKDSK"; TitleKey = "TOOL_CHKDSK"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Compliance" }; Layer = "Infrastructure" }
            @{ Id = "WINFR"; TitleKey = "TOOL_WINFR"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.NTFS" }; Layer = "Analysis" }
            @{ Id = "FSUTIL"; TitleKey = "TOOL_FSUTIL"; Type = "Special"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.PartitionTable" }; Layer = "Analysis" }
            @{ Id = "STORDIAG"; TitleKey = "TOOL_STORDIAG"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Telemetry"; Task = "TOPOLOGY" }; Layer = "Infrastructure" }
            @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
        )
    }

    SettingsMenu  = @{
        TitleKey = "MENU_MAIN_SETTINGS"
        Items    = @(
            @{ Id = "ENGINE_MODE"; TitleKey = "MENU_OPTION_ENGINE_MODE"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "EngineMode"; Value = "CYCLE"; List = "ui::CycleLists::EngineMode" }; DynamicText = @{ Type = "CycleState"; Key = "EngineMode"; List = "ui::CycleLists::EngineMode" } }
            @{ Id = "DEFAULT_OUT"; TitleKey = "MENU_OPTION_DEFAULT_OUT"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Presentation"; Target = "Scape.Presentation.FilePicker" }; Layer = "Presentation" }
            @{ Id = "NET_MGR"; TitleKey = "MENU_OPTION_NETWORK_MGR"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Extensions"; Target = "Scape.Extensions.Network" }; Layer = "Extensions" }
            @{ Id = "ROBOCOPY"; TitleKey = "MENU_OPTION_ROBOCOPY"; Type = "Special"; Action = "NAVIGATE"; Target = "RobocopyMenu"; Layer = "Extensions" }
            @{ Id = "LANGUAGE"; TitleKey = "MENU_OPTION_LANGUAGE"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "CurrentLanguage"; Value = "CYCLE"; List = "ui::CycleLists::I18N" }; DynamicText = @{ Type = "CycleState"; Key = "CurrentLanguage"; List = "ui::CycleLists::I18N" } }
            @{ Id = "THEME"; TitleKey = "MENU_SETTINGS_THEME"; Type = "Highlight"; Action = "NAVIGATE"; Target = "ThemeMenu"; Layer = "Presentation" }
            @{ Id = "RESET"; TitleKey = "SETTINGS_RESET_DEFAULTS"; Type = "Warning"; Action = "TRIGGER"; Payload = @{ Domain = "Core"; Target = "Scape.Core.Settings"; Task = "RESET" } }
            @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
        )
    }

    CapMenu       = @{
        TitleKey = "CAP_MENU_TITLE"
        Items    = @(
            @{ Id = "CAP_TRUECOLOR"; TitleKey = "CAP_TRUECOLOR"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_TrueColor"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_TrueColor" } }
            @{ Id = "CAP_HYPERLINKS"; TitleKey = "CAP_HYPERLINKS"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_Hyperlinks"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_Hyperlinks" } }
            @{ Id = "CAP_BRACKETEDPASTE"; TitleKey = "CAP_BRACKETEDPASTE"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_BracketedPaste"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_BracketedPaste" } }
            @{ Id = "CAP_MOUSETRACKING"; TitleKey = "CAP_MOUSETRACKING"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_MouseTracking"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_MouseTracking" } }
            @{ Id = "CAP_ALTERNATESCREEN"; TitleKey = "CAP_ALTERNATESCREEN"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_AlternateScreen"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_AlternateScreen" } }
            @{ Id = "CAP_FOCUSEVENTS"; TitleKey = "CAP_FOCUSEVENTS"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_FocusEvents"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_FocusEvents" } }
            @{ Id = "CAP_KITTYKEYBOARD"; TitleKey = "CAP_KITTYKEYBOARD"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_KittyKeyboard"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_KittyKeyboard" } }
            @{ Id = "CAP_SIXELGRAPHICS"; TitleKey = "CAP_SIXELGRAPHICS"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_SixelGraphics"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_SixelGraphics" } }
            @{ Id = "CAP_CSIUKEYBOARD"; TitleKey = "CAP_CSIUKEYBOARD"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_CSIuKeyboard"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_CSIuKeyboard" } }
            @{ Id = "CAP_FALLBACK256"; TitleKey = "CAP_FALLBACK256"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_Fallback256"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_Fallback256" } }
            @{ Id = "CAP_FALLBACK16"; TitleKey = "CAP_FALLBACK16"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Capability_Fallback16"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "Capability_Fallback16" } }
            @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
        )
    }

    ThemeMenu     = @{
        TitleKey = "MENU_SETTINGS_THEME"
        Items    = @(
            @{ Id = "ICON_LEVEL"; TitleKey = "MENU_OPTION_ICON_LEVEL"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "IconLevel"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleLabel"; Key = "IconLevel"; Labels = "ui::Labels::IconLevels" } }
            @{ Id = "FRAME_STYLE"; TitleKey = "MENU_OPTION_FRAME_STYLE"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "FrameStyle"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleState"; Key = "FrameStyle"; List = "ui::CycleLists::FrameStyle" } }
            @{ Id = "PROGRESS_STYLE"; TitleKey = "MENU_OPTION_PROGRESS_STYLE"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "ProgressStyle"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleState"; Key = "ProgressStyle"; List = "ui::CycleLists::ProgressStyle" } }
            @{ Id = "THEME_PERSONA"; TitleKey = "MENU_OPTION_THEME_PERSONA"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "ThemePersona"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleState"; Key = "ThemePersona"; List = "ui::CycleLists::ThemePersona" } }
            @{ Id = "THEME_COLOR"; TitleKey = "MENU_OPTION_COLOR_MODE"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "ColorMode"; Value = "CYCLE"; List = "ui::CycleLists::ColorMode" }; DynamicText = @{ Type = "CycleState"; Key = "ColorMode"; List = "ui::CycleLists::ColorMode" } }
            @{ Id = "RANDOM_THEME"; TitleKey = "MENU_RANDOM_THEME"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Presentation"; Target = "Scape.Presentation.Theme"; Task = "PROCEDURAL" } }
            @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
        )
    }

    LogisticsMenu = @{
        TitleKey = "RC_TITLE"
        Items    = @(
            @{ Id = "SYNC_START"; TitleKey = "RC_BTN_START"; Type = "Success"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Pipeline" }; Layer = "Infrastructure" }
            @{ Id = "TAG_PREPARE"; TitleKey = "RC_BTN_PREPARE_FLAGS"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Extensions"; Target = "Scape.Extensions.CloudSync" }; Layer = "Extensions" }
            @{ Id = "ROBO_CFG"; TitleKey = "RC_BTN_EDIT_DESC"; Type = "Warning"; Action = "NAVIGATE"; Target = "RobocopyMenu" }
            @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
        )
    }

    RobocopyMenu  = @{
        TitleKey = "RC_DEFAULTS_TITLE"
        Items    = @(
            @{ Id = "RC_FLAG_E"; TitleKey = "RC_FLAG_E"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_E"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_E" } }
            @{ Id = "RC_FLAG_M"; TitleKey = "RC_FLAG_M"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_M"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_M" } }
            @{ Id = "RC_FLAG_ZB"; TitleKey = "RC_FLAG_ZB"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_ZB"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_ZB" } }
            @{ Id = "RC_FLAG_FFT"; TitleKey = "RC_FLAG_FFT"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_FFT"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_FFT" } }
            @{ Id = "RC_FLAG_XO"; TitleKey = "RC_FLAG_XO"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_XO"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_XO" } }
            @{ Id = "RC_FLAG_XN"; TitleKey = "RC_FLAG_XN"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_XN"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_XN" } }
            @{ Id = "RC_FLAG_XJ"; TitleKey = "RC_FLAG_XJ"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_XJ"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_XJ" } }
            @{ Id = "RC_FLAG_B"; TitleKey = "RC_FLAG_B"; Type = "Warning"; Action = "MUTATE"; Payload = @{ Key = "RC_B"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_B" } }
            @{ Id = "RC_FLAG_NP"; TitleKey = "RC_FLAG_NP"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_NP"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_NP" } }
            @{ Id = "RC_FLAG_COPYALL"; TitleKey = "RC_FLAG_COPYALL"; Type = "Warning"; Action = "MUTATE"; Payload = @{ Key = "RC_COPYALL"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_COPYALL" } }
            @{ Id = "RC_FLAG_DCOPY_T"; TitleKey = "RC_FLAG_DCOPY_T"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_DCOPY_T"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_DCOPY_T" } }
            @{ Id = "RC_FLAG_L"; TitleKey = "RC_FLAG_L"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_L"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_L" } }
            @{ Id = "RC_FLAG_V"; TitleKey = "RC_FLAG_V"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_V"; Value = "TOGGLE" }; DynamicText = @{ Type = "ToggleState"; Key = "RC_V" } }
            @{ Id = "RC_FLAG_MT"; TitleKey = "RC_FLAG_MT"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "RC_MT"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleState"; Key = "RC_MT"; List = "ui::CycleLists::RC_MT" } }
            @{ Id = "RC_RETRY_R"; TitleKey = "RC_RETRY_R"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "RC_R"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleState"; Key = "RC_R"; List = "ui::CycleLists::RC_R" } }
            @{ Id = "RC_RETRY_W"; TitleKey = "RC_RETRY_W"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "RC_W"; Value = "CYCLE" }; DynamicText = @{ Type = "CycleState"; Key = "RC_W"; List = "ui::CycleLists::RC_W" } }
            @{ Id = "RC_BTN_SAVE"; TitleKey = "RC_SAVE_RETURN"; Type = "Success"; Action = "BACK" }
            @{ Id = "RC_BTN_CANCEL"; TitleKey = "RC_DEL_RTN"; Type = "Destructive"; Action = "BACK" }
        )
    }

    DestSelection = @{
        TitleKey = "UI_SelectFolder"
        Items    = @(
            @{ Id = "FOLDER"; TitleKey = "UI_SelectFolder"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Presentation"; Target = "Scape.Presentation.FilePicker" }; Layer = "Presentation" }
            @{ Id = "AUTO"; TitleKey = "MENU_OPTION_AUTODETECT"; Type = "Special"; Action = "TRIGGER"; Payload = @{ Domain = "Acquisition"; Target = "Scape.Acquisition.Resilience" }; Layer = "Acquisition" }
            @{ Id = "CANCEL"; TitleKey = "RC_CANCEL"; Type = "Destructive"; Action = "BACK" }
        )
    }

    DeployMenu    = @{
        TitleKey = "MENU_DEPLOY_TITLE"
        Items    = @(
            @{ Id = "INIT_SYSTEM"; TitleKey = "DEPLOYER_GENERATE"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Forge"; Target = "Scape.Forge.Deployer"; Task = "INIT_AND_EXIT" } }
            @{ Id = "BUILD_MONOLITH"; TitleKey = "DEPLOYER_OPT_DEV"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Forge"; Target = "Scape.Forge.Deployer"; Task = "BUILD_AND_LAUNCH_MONOLITH" } }
            @{ Id = "EXIT"; TitleKey = "MENU_MAIN_EXIT"; Type = "Destructive"; Action = "TERMINATE" }
        )
    }

    ForgeMenu     = @{
        TitleKey = "DEPLOYER_MATRIX_HEADER"
        Items    = @(
            @{ Id = "INIT_SYSTEM"; TitleKey = "DEPLOYER_GENERATE"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Forge"; Target = "Scape.Forge.Deployer"; Task = "INIT_AND_EXIT" } }
            @{ Id = "BUILD_EXE_PORTABLE"; TitleKey = "DEPLOYER_OPT_EXE"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Forge"; Target = "Scape.Forge.Deployer"; Task = "EXE_PORTABLE" } }
            @{ Id = "BUILD_EXE_SETUP"; TitleKey = "DEPLOYER_OPT_SETUP"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Forge"; Target = "Scape.Forge.Deployer"; Task = "EXE_SETUP" } }
            @{ Id = "BUILD_MSI"; TitleKey = "DEPLOYER_OPT_MSI"; Type = "Warning"; Action = "TRIGGER"; Payload = @{ Domain = "Forge"; Target = "Scape.Forge.Deployer"; Task = "MSI" } }
            @{ Id = "EXIT"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
        )
    }
}