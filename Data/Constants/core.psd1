@{
    Segment = @{
        Name = "core"
        Version = "1.0.0"
        Description = "Core bootstrap constants for SCAPE Recovery System"
        Dependencies = @()
        HashSHA256 = "PLACEHOLDER_CORE_HASH"
    }

    Meta = @{
        Name          = "SCAPE Recovery System"
        Version       = "1.0.0"
        MinPSVersion  = "5.1"
        Architecture  = @("x64", "ARM64")
        SegmentSchema = "1.0"
    }

    Identifiers = @{
        SegmentPrefix = "SCAPE_"
        Separator     = "::"
        Wildcard      = "*"
    }

    Loader = @{
        CacheEnabled      = $true
        CacheMaxItems     = 10
        CachePolicy       = "LRU"
        ValidateOnLoad    = $true
        AutoResolveDeps   = $true
        LogLevel          = "WARNING"
    }

    Global = @{
        NULL_BYTE     = 0x00
        TRUE_BYTE     = 0x01
        FALSE_BYTE    = 0x00
        MAX_PATH_WIN  = 260
        MAX_PATH_UNIX = 4096
        SECTOR_SIZE   = 512
        ALIGNMENT     = 4096
    }

    Extensibility = @{
        AllowCustomSegments = $true
        CustomSegmentPath   = "Segments/Custom"
        OnSegmentLoad       = "Test-SegmentSignature"
        OnSegmentUnload     = "Cleanup-SegmentResources"
    }

    # =============================================================================
    # REGEX PATTERNS - Validação e Parsing
    # =============================================================================
    REGEX = @{
        BASE64       = '^[A-Za-z0-9+/]+=*$'
        HEX          = '^[0-9a-fA-F]+$'
        NUMERIC      = '^\d+$'
        ALPHABETIC   = '^[a-zA-Z]+$'
        ALPHANUMERIC = '^[a-zA-Z0-9]+$'
        FILE_NAME_SAFE = '^[^<>:"/\\|?*]+$'
        UUID           = '^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
        PATH_WIN       = '^[a-zA-Z]:\\'
        PATH_UNIX      = '^/'
        PATH_UNC       = '^\\\\[^\\]+\\[^\\]+'
        IPv4           = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        IPv6           = '^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'
        EMAIL          = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        MD5_HASH       = '^[0-9a-fA-F]{32}$'
        SHA1_HASH      = '^[0-9a-fA-F]{40}$'
        SHA256_HASH    = '^[0-9a-fA-F]{64}$'
        DOMAIN         = '^(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
        URL_HTTP       = '^https?://[^\s/$.?#].[^\s]*$'
    }

    # =============================================================================
    # TOOLS - Caminhos de utilitários do sistema
    # =============================================================================
    TOOLS = @{
        DISKPART  = "diskpart.exe"
        CHKDSK    = "chkdsk.exe"
        WINFR     = "winfr.exe"
        FSUTIL    = "fsutil.exe"
        STORDIAG  = "stordiag.exe"
        ROBOCOPY  = "robocopy.exe"
        NET_USE   = "net.exe"
        CMD       = "cmd.exe"
        POWERSHELL = "powershell.exe"
        PWSH      = "pwsh.exe"
    }

    # =============================================================================
    # PLATFORM - Hints estáticos (detecção real é feita em runtime pelo código)
    # =============================================================================
    PLATFORM = @{
        WIN_DEV_PREFIX   = "\\.\"
        UNIX_DEV_PREFIX  = "/dev/"
        WIN_PATH_SEP     = "\"
        UNIX_PATH_SEP    = "/"
        WIN_EOL          = "`r`n"
        UNIX_EOL         = "`n"
        # Runtime: IS_WINDOWS, IS_LINUX, IS_MACOS, IS_64BIT, IS_ARM devem ser
        # detectados via [Runtime.InteropServices.RuntimeInformation]
    }
}