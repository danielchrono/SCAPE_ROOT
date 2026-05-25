@{
    Segment     = @{
        Name        = "system"
        Version     = "1.0.0"
        Description = "Core bootstrap and global constants for SCAPE Recovery System"
        Dependencies = @()
        HashSHA256   = "PLACEHOLDER_SYS_HASH"
    }
    Meta        = @{
        Name         = "SCAPE Recovery System"
        Version      = "1.0.0"
        MinPSVersion = "5.1"
        Architecture = @("x64", "ARM64")
    }
    Identifiers = @{
        SegmentPrefix = "SCAPE_"
        Separator     = "::"
        Wildcard      = "*"
    }
    Loader      = @{
        CacheEnabled    = $true
        CacheMaxItems   = 10
        CachePolicy     = "LRU"
        ValidateOnLoad  = $true
        AutoResolveDeps = $true
        LogLevel        = "WARNING"
    }
    Global      = @{
        NULL_BYTE     = 0x00
        TRUE_BYTE     = 0x01
        FALSE_BYTE    = 0x00
        MAX_PATH_WIN  = 260
        MAX_PATH_UNIX = 4096
        SECTOR_SIZE   = 512
        ALIGNMENT     = 4096
    }
    Tools       = @{
        DISKPART   = "diskpart.exe"
        CHKDSK     = "chkdsk.exe"
        WINFR      = "winfr.exe"
        FSUTIL     = "fsutil.exe"
        STORDIAG   = "stordiag.exe"
        ROBOCOPY   = "robocopy.exe"
        NET_USE    = "net.exe"
        CMD        = "cmd.exe"
        POWERSHELL = "powershell.exe"
        PWSH       = "pwsh.exe"
    }
    Platform    = @{
        WIN_DEV_PREFIX  = "\\.\"
        UNIX_DEV_PREFIX = "/dev/"
        WIN_PATH_SEP    = "\"
        UNIX_PATH_SEP   = "/"
        WIN_EOL         = "`r`n"
        UNIX_EOL        = "`n"
    }
    Regex       = @{
        BASE64      = '^[A-Za-z0-9+/]+=*$'
        HEX         = '^[0-9a-fA-F]+$'
        UUID        = '^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
        PATH_WIN    = '^[a-zA-Z]:\\'
        PATH_UNIX   = '^/'
        PATH_UNC    = '^\\\\[^\\]+\\[^\\]+'
        IPv4        = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        SHA256_HASH = '^[0-9a-fA-F]{64}$'
        URL_HTTP    = '^https?://[^\s/$.?#].[^\s]*$'
    }
    Limits      = @{
        RAM_CRITICAL_PCT            = 0.20
        THERMAL_WARNING             = 75
        THERMAL_CRITICAL            = 85
        QUEUE_WARNING               = 5
        QUEUE_CRITICAL              = 10
        MAX_DIR_DEPTH               = 20
        NET_SCAN_TIMEOUT_MS         = 80
        NET_SCAN_THREADS            = 256
        ROBOCOPY_RETRY_DEF          = 3
        ROBOCOPY_WAIT_DEF           = 10
        ROBOCOPY_THREAD_AUTO        = 128
        MAX_CONCURRENT_OPS          = 16
        CRITICAL_SECTION_TIMEOUT_MS = 5000
        ASYNC_OP_TIMEOUT_MS         = 30000
        FILE_LOCK_RETRY_ATTEMPTS    = 3
        FILE_LOCK_RETRY_DELAY_MS    = 100
    }
    Behavior    = @{
        RETRY_MAX_ATTEMPTS    = 5
        RETRY_BASE_DELAY_MS   = 100
        RETRY_BACKOFF_FACTOR  = 2.0
        RETRY_MAX_DELAY_MS    = 30000
        TIMER_DEFAULT_MS      = 5000
        WATCHDOG_INTERVAL_MS  = 2000
        WATCHDOG_ENABLED      = $true
        WATCHDOG_ACTION       = "RESTART"
        HEARTBEAT_ENABLED     = $true
        HEARTBEAT_INTERVAL_MS = 2000
        CPU_THROTTLE_PERCENT  = 30
        GRACEFUL_SHUTDOWN_MS  = 10000
    }
    Profiles    = @{
        MINIMUM     = @{ RAM_BUFFER_MB = 16; IO_CHUNK_KB = 64; MAX_PARALLEL_OPS = 1; THERMAL_THROTTLE_C = 70 }
        STANDARD    = @{ RAM_BUFFER_MB = 64; IO_CHUNK_KB = 256; MAX_PARALLEL_OPS = 4; THERMAL_THROTTLE_C = 80 }
        WORKSTATION = @{ RAM_BUFFER_MB = 256; IO_CHUNK_KB = 1024; MAX_PARALLEL_OPS = 8; THERMAL_THROTTLE_C = 85 }
        SERVER      = @{ RAM_BUFFER_MB = 512; IO_CHUNK_KB = 2048; MAX_PARALLEL_OPS = 16; THERMAL_THROTTLE_C = 90 }
    }
    Storage     = @{
        HDD  = @{ SEEK_PENALTY_MS = 10; OPTIMAL_CHUNK_KB = 64; MAX_PARALLEL_READS = 2 }
        SSD  = @{ SEEK_PENALTY_MS = 1; OPTIMAL_CHUNK_KB = 256; MAX_PARALLEL_READS = 8 }
        NVME = @{ SEEK_PENALTY_MS = 0; OPTIMAL_CHUNK_KB = 1024; MAX_PARALLEL_READS = 16 }
        USB  = @{ SEEK_PENALTY_MS = 20; OPTIMAL_CHUNK_KB = 32; MAX_PARALLEL_READS = 1; ENABLE_WRITE_CACHE = $false }
    }
    Safeguards  = @{
        RAM_CRITICAL_PCT = 0.15
        IO_QUEUE_MAX     = 1000
        BACKOFF_BASE_MS  = 100
        BACKOFF_MAX_MS   = 5000
    }
    Workspace   = @{
        ROOT      = "SCAPE_Storage"
        LOGS      = "Logs"
        TEMP      = "Temp"
        STAGING   = "Staging"
        REPORTS   = "Reports"
        DEPLOY    = "Build"
        RESOURCES = "Binaries"
        SETTINGS  = "Config"
    }
    Defaults    = @{
        MODE             = "EFFICIENCY"
        LANG             = "en-US"
        OUT_DIR          = "SCAPE_Storage\Staging"
        SETTINGS         = "user-settings.json"
        LOG_FILE_PATTERN = "scape_{0:yyyyMMdd_HHmmss}.log"
    }
}