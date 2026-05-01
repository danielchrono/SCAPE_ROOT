@{
    Segment = @{
        Name = "dir"
        Version = "1.0.0"
        Description = "Directory paths, default locations, and file naming constants"
        Dependencies = @("core")
        HashSHA256 = "PLACEHOLDER_DIR_HASH"
    }

    PATHS = @{
        DB_NAME          = "SCAPE_Index.db"
        STAGING_ROOT     = "Desktop\SCAPE_Recovery"  # Runtime: Join-Path $env:USERPROFILE (Win) ou $env:HOME (Unix)
        TEMP_PREFIX      = "SCAPE_"
        LOGS_FOLDER      = "Logs"
        REPORTS_FOLDER   = "Reports"
        ARTIFACTS_FOLDER = "Artifacts"
        # Runtime: DEV_PREFIX = "\\.\" (Windows) ou "/dev/" (Unix)
    }

    DEFAULTS = @{
        MODE    = "EFFICIENCY"
        LANG    = "en-US"
        OUT_DIR = "Desktop\SCAPE_Recovery"
    }

    NAMING = @{
        TEMP_FILE_PATTERN = "{0}{1:D6}.tmp"   # PREFIX + sequence numérica
        LOG_FILE_PATTERN  = "scape_{0:yyyyMMdd_HHmmss}.log"
        REPORT_EXT        = ".json"
        DB_EXT            = ".db"
        HASH_EXT          = ".sha256"
        EVIDENCE_EXT      = ".evidence"
    }

    FILTERS = @{
        EXCLUDE_EXTENSIONS = @(".tmp", ".log", ".lock", ".db-shm", ".db-wal")
        EXCLUDE_FOLDERS    = @("System Volume Information", "`$RECYCLE.BIN", "Config.Msi")
        INCLUDE_EXTENSIONS = @("*")  # Wildcard padrão
    }
}