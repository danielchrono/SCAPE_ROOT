@{
    Segment   = @{
        Name         = "forge"
        Version      = "1.0.0"
        Description  = "Constantes do Deployer, Compiler e Packager do Monolito SCAPE"
        Dependencies = @("core")
    }

    Urls      = @{
        ps2exe   = "https://github.com/MScholtes/PS2EXE/archive/refs/heads/master.zip"
        wix      = "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip"
        sqlite   = "https://system.data.sqlite.org/downloads/1.0.118.0/sqlite-netFx46-binary-x64-2015-1.0.118.0.zip"
        sqlite86 = "https://system.data.sqlite.org/downloads/1.0.118.0/sqlite-netFx46-binary-Win32-2015-1.0.118.0.zip"
        winfr    = "ms-windows-store://pdp/?ProductId=9N26S50LN705" # Link da store caso o Packager precise invocar
    }
    Paths     = @{
        OutputBase        = "SCAPE_RELEASE"
        ExpandedDir       = "SCAPE_EXPANDED"
        MonolithDir       = "Output"
        MonolithFile      = "SCAPE_DEPLOY.ps1"
        MainScriptFile    = "main.ps1"
        DeployWorkspaceDir = "Build"
        InnoSetupDirs     = @("%ProgramFiles(x86)%\Inno Setup 6", "%ProgramFiles%\Inno Setup 6")
    }
    Installer = @{
        AppName    = "SCAPE Recovery Engine"
        AppVersion = "1.0.0"
        Publisher  = "Industrial Forensics"
    }
}