@{
    __Meta__      = @{
        Version = "1.0"
        Author  = "Scape.Core"
        Purpose = "Navigation & Routing Manifest. Mechanical flow, zero inference."
    }

    MainMenu      = @(
        @{ Id = "SCAN"; TitleKey = "MENU_MAIN_SCAN"; Type = "Highlight"; Action = "NAVIGATE"; Target = "ScanMenu"; WakeDomain = "Acquisition" }
        @{ Id = "PARSING"; TitleKey = "MENU_MAIN_PARSING"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.Parser.Core" }; WakeDomain = "Analysis" }
        @{ Id = "ARCHAEOLOGY"; TitleKey = "MENU_MAIN_ARCHAEOLOGY"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.Carving.Carver" }; WakeDomain = "Analysis" }
        @{ Id = "HARVESTER"; TitleKey = "MENU_MAIN_HARVESTER"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Acquisition"; Target = "Scape.Acquisition.Selection" }; WakeDomain = "Acquisition" }
        @{ Id = "FORENSICS"; TitleKey = "MENU_MAIN_FORENSICS"; Type = "Special"; Action = "NAVIGATE"; Target = "ForensicsMenu"; WakeDomain = "Infrastructure" }
        @{ Id = "SETTINGS"; TitleKey = "MENU_MAIN_SETTINGS"; Type = "Warning"; Action = "NAVIGATE"; Target = "SettingsMenu"; WakeDomain = "Core" }
        @{ Id = "LOGISTICS"; TitleKey = "MENU_MAIN_LOGISTICS"; Type = "Special"; Action = "NAVIGATE"; Target = "LogisticsMenu"; WakeDomain = "Extensions" }
        @{ Id = "LABORATORY"; TitleKey = "MENU_MAIN_LAB"; Type = "Warning"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.Abstraction" }; WakeDomain = "Analysis" }
        @{ Id = "EXIT"; TitleKey = "MENU_MAIN_EXIT"; Type = "Destructive"; Action = "TERMINATE" }
    )

    ForensicsMenu = @(
        @{ Id = "DISKPART"; TitleKey = "TOOL_DISKPART"; Type = "Warning"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Audit" }; WakeDomain = "Infrastructure" }
        @{ Id = "CHKDSK"; TitleKey = "TOOL_CHKDSK"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Compliance" }; WakeDomain = "Infrastructure" }
        @{ Id = "WINFR"; TitleKey = "TOOL_WINFR"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.NTFS" }; WakeDomain = "Analysis" }
        @{ Id = "FSUTIL"; TitleKey = "TOOL_FSUTIL"; Type = "Special"; Action = "TRIGGER"; Payload = @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.PartitionTable" }; WakeDomain = "Analysis" }
        @{ Id = "STORDIAG"; TitleKey = "TOOL_STORDIAG"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Telemetry" }; WakeDomain = "Infrastructure" }
        @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
    )

    SettingsMenu  = @(
        @{ Id = "ENGINE_MODE"; TitleKey = "MENU_OPTION_ENGINE_MODE"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "EngineMode"; Value = "PERFORMANCE" } }
        @{ Id = "DEFAULT_OUT"; TitleKey = "MENU_OPTION_DEFAULT_OUT"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "OutPath"; Value = "C:\Scape\Export" } }
        @{ Id = "NET_MGR"; TitleKey = "MENU_OPTION_NETWORK_MGR"; Type = "Normal"; Action = "TRIGGER"; Payload = @{ Domain = "Extensions"; Target = "Scape.Extensions.Network" }; WakeDomain = "Extensions" }
        @{ Id = "ROBOCOPY"; TitleKey = "MENU_OPTION_ROBOCOPY"; Type = "Special"; Action = "NAVIGATE"; Target = "LogisticsMenu"; WakeDomain = "Extensions" }
        @{ Id = "LANGUAGE"; TitleKey = "MENU_OPTION_LANGUAGE"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "CurrentLanguage"; Value = "pt-BR" } }
        @{ Id = "THEME"; TitleKey = "MENU_SETTINGS_THEME"; Type = "Highlight"; Action = "NAVIGATE"; Target = "ThemeMenu"; WakeDomain = "Presentation" }
        @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
    )

    ThemeMenu     = @(
        @{ Id = "THEME_CYBER"; TitleKey = "THEME_CYBER"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "CYBER" } }
        @{ Id = "THEME_CORP"; TitleKey = "THEME_CORP"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "CORP" } }
        @{ Id = "THEME_HACKER"; TitleKey = "THEME_HACKER"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "HACKER" } }
        @{ Id = "THEME_MINIMAL"; TitleKey = "THEME_MINIMAL"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "MINIMAL" } }
        @{ Id = "THEME_RETRO"; TitleKey = "THEME_RETRO"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "RETRO" } }
        @{ Id = "THEME_HIGHVIS"; TitleKey = "THEME_HIGHVIS"; Type = "Warning"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "HIGHVIS" } }
        @{ Id = "THEME_POWERSHELL"; TitleKey = "THEME_POWERSHELL"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "POWERSHELL" } }
        @{ Id = "THEME_RANDOM"; TitleKey = "THEME_RANDOM"; Type = "Special"; Action = "MUTATE"; Payload = @{ Key = "Theme"; Value = "RANDOM" } }
        @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
    )

    LogisticsMenu = @(
        @{ Id = "SYNC_START"; TitleKey = "RC_BTN_START"; Type = "Success"; Action = "TRIGGER"; Payload = @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Pipeline" }; WakeDomain = "Infrastructure" }
        @{ Id = "TAG_PREPARE"; TitleKey = "RC_BTN_PREPARE_FLAGS"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Extensions"; Target = "Scape.Extensions.CloudSync" }; WakeDomain = "Extensions" }
        @{ Id = "ROBO_CFG"; TitleKey = "RC_BTN_EDIT_DESC"; Type = "Warning"; Action = "MUTATE"; Payload = @{ Key = "RoboFlags"; Value = "/MIR /Z" } }
        @{ Id = "RETURN"; TitleKey = "MENU_OPTION_RETURN"; Type = "Destructive"; Action = "BACK" }
    )

    RobocopyMenu  = @(
        @{ Id = "RC_FLAG_E"; TitleKey = "RC_FLAG_E"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_E"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_M"; TitleKey = "RC_FLAG_M"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_M"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_ZB"; TitleKey = "RC_FLAG_ZB"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_ZB"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_FFT"; TitleKey = "RC_FLAG_FFT"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_FFT"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_XO"; TitleKey = "RC_FLAG_XO"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_XO"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_XN"; TitleKey = "RC_FLAG_XN"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_XN"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_XJ"; TitleKey = "RC_FLAG_XJ"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_XJ"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_B"; TitleKey = "RC_FLAG_B"; Type = "Warning"; Action = "MUTATE"; Payload = @{ Key = "RC_B"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_NP"; TitleKey = "RC_FLAG_NP"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_NP"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_COPYALL"; TitleKey = "RC_FLAG_COPYALL"; Type = "Warning"; Action = "MUTATE"; Payload = @{ Key = "RC_COPYALL"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_DCOPY_T"; TitleKey = "RC_FLAG_DCOPY_T"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_DCOPY_T"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_L"; TitleKey = "RC_FLAG_L"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_L"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_V"; TitleKey = "RC_FLAG_V"; Type = "Normal"; Action = "MUTATE"; Payload = @{ Key = "RC_V"; Value = "TOGGLE" } }
        @{ Id = "RC_FLAG_MT"; TitleKey = "RC_FLAG_MT"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "RC_MT"; Value = "CYCLE" } }
        @{ Id = "RC_RETRY_R"; TitleKey = "RC_RETRY_R"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "RC_R"; Value = "CYCLE" } }
        @{ Id = "RC_RETRY_W"; TitleKey = "RC_RETRY_W"; Type = "Highlight"; Action = "MUTATE"; Payload = @{ Key = "RC_W"; Value = "CYCLE" } }
        @{ Id = "RC_BTN_SAVE"; TitleKey = "RC_BTN_SAVE"; Type = "Success"; Action = "BACK" }
        @{ Id = "RC_BTN_CANCEL"; TitleKey = "RC_BTN_CANCEL"; Type = "Destructive"; Action = "BACK" }
    )

    DestSelection = @(
        @{ Id = "FOLDER"; TitleKey = "UI_SelectFolder"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{ Domain = "Presentation"; Target = "Scape.Presentation.FilePicker" }; WakeDomain = "Presentation" }
        @{ Id = "AUTO"; TitleKey = "MENU_OPTION_AUTODETECT"; Type = "Special"; Action = "TRIGGER"; Payload = @{ Domain = "Acquisition"; Target = "Scape.Acquisition.Resilience" }; WakeDomain = "Acquisition" }
        @{ Id = "CANCEL"; TitleKey = "RC_CANCEL"; Type = "Destructive"; Action = "BACK" }
    )
}