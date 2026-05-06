@{
    Segment       = @{
        Name         = "infrastructure"
        Version      = "1.0.0"
        Description  = "Centralized configuration for Logger, Audit, and Compliance (system integrity & forensic ledger)"
        Dependencies = @("system")
        HashSHA256   = "PLACEHOLDER_INFRASTRUCTURE_HASH"
    }

    LogSeverity   = @{
        TRACE      = 0
        DEBUG      = 1
        INFO       = 2
        WARN       = 3
        ERROR      = 4
        FATAL      = 5
        COMPLIANCE = 5
    }

    EventCategory = @{
        SYS_CORE             = "SYS_CORE"
        SYSTEM_READY         = "SYSTEM_READY"
        SYSTEM_CRASH         = "SYSTEM_CRASH"
        MODULE_LOADED        = "MODULE_LOADED"
        LAYER_IGNITION       = "LAYER_IGNITION"
        ROUTER_STOP          = "ROUTER_STOP"
        ROUTER_NAVIGATE      = "ROUTER_NAVIGATE"
        UI_SELECTION         = "UI_SELECTION"
        UI_REDRAW_REQUEST    = "UI_REDRAW_REQUEST"
        MENU_OPEN            = "MENU_OPEN"
        LANG_SWITCH          = "LANG_SWITCH"
        ASSET_LOADED         = "ASSET_LOADED"
        LOG_ROTATED          = "LOG_ROTATED"
        AUDIT_EXPORT_SUCCESS = "AUDIT_EXPORT_SUCCESS"
        DEPLOYER_DONE        = "DEPLOYER_DONE"
        SCAPE_HANDOVER       = "SCAPE_HANDOVER"
        PROGRESS             = "PROGRESS"
        AUDIT_RECORD_ADDED   = "AUDIT_RECORD_ADDED"
        COMPLIANCE_MISMATCH  = "COMPLIANCE_MISMATCH"
        RUN_MARKER           = "RUN_MARKER"
    }

    UIAction      = @{
        UP        = "UP"
        DOWN      = "DOWN"
        BACK      = "BACK"
        SELECT    = "SELECT"
        NAVIGATE  = "NAVIGATE"
        TERMINATE = "TERMINATE"
        TRIGGER   = "TRIGGER"
        MUTATE    = "MUTATE"
    }

    MenuSpecial   = @{
        EXIT   = "EXIT"
        RETURN = "RETURN"
        CANCEL = "CANCEL"
    }

    # --- LOGGER: Configurações de Fluxo e Severidade ---
    Logger        = @{
        LOG_LEVELS          = @{ TRACE = 0; DEBUG = 1; INFO = 2; WARNING = 3; ERROR = 4; FATAL = 5; COMPLIANCE = 5 }
        DEFAULT_LEVEL_NAME  = "INFO"
        LOG_FILE_PATTERN    = "scape_{0:yyyyMMdd_HHmmss}.log"
        LOG_IMMEDIATE_FLUSH = $true
        LOG_EXCLUDE_TYPES   = @("TRACE", "METRIC_SAMPLE", "TELEMETRY_HEARTBEAT", "PROGRESS", "BUFFER_STATUS", "PIPELINE_TICK", "HEARTBEAT", "POLL_CYCLE")
        SHUTDOWN_EVENTS     = @("ROUTER_STOP", "SYSTEM_CRASH", "DEPLOYER_DONE")
        MAX_LOG_SIZE_MB     = 10
        TIMESTAMP_FORMAT    = "yyyy-MM-ddTHH:mm:ss.fffZ"
    }

    # --- AUDIT: Cadeia de Custódia e Ledger Forense ---
    Audit         = @{
        GENESIS_BLOCK           = "SCAPE_AUDIT_GENESIS_v1.0"
        HASH_ALGO               = "SHA256"
        LOG_DIR                 = "Logs"
        LOG_IMMEDIATE_FLUSH     = $true
        AUDIT_EVENT_TYPES       = @("*")
        DEFAULT_OPERATOR        = "SYS_CORE"
        TIME_FORMAT             = "yyyy-MM-ddTHH:mm:ss.fffZ"
        BACKPRESSURE_TIMEOUT_MS = 5000
        MAX_LOG_SIZE_MB         = 10
    }

    # --- COMPLIANCE: Integridade e Verificação de Segmentos (HASH UNIFICADO) ---
    Compliance    = @{
        MANIFEST_PATH          = "Data\Manifests\SegmentHashes.psd1"
        SEGMENT_VERIFY_ON_LOAD = $true
        CRITICAL_SEGMENTS      = @("core", "events", "infrastructure", "dir", "behavior", "ui", "theme")
        CACHE_VERIFICATION     = $true
        HASH_ALGO              = "SHA256"
    }
}
