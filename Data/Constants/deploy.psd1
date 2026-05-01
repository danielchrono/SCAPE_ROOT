@{
    Urls      = @{
        ps2exe   = "https://github.com/MScholtes/PS2EXE/archive/refs/heads/master.zip"
        wix      = "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip"
        sqlite   = "https://system.data.sqlite.org/downloads/1.0.118.0/sqlite-netFx46-binary-x64-2015-1.0.118.0.zip"
        sqlite86 = "https://system.data.sqlite.org/downloads/1.0.118.0/sqlite-netFx46-binary-Win32-2015-1.0.118.0.zip"
    }
    Paths     = @{
        OutputBase   = "SCAPE_RELEASE"
        ExpandedDir  = "SCAPE_EXPANDED"
        MonolithFile = "SCAPE_DEPLOY.ps1"
    }
    Installer = @{
        AppName    = "SCAPE Recovery Engine"
        AppVersion = "1.0.0"
        Publisher  = "Industrial Forensics"
    }
    Behavior  = @{
        LazyLoadingEnabled   = $true
        ModuleStackPolicy    = "UnloadOnReturn"
        MaxMemoryFootprintMB = 128
    }
}