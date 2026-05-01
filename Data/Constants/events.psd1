@{
    # Logs e Níveis de Sistema (Internal Engine State)
    LogLevels = @{
        INFO    = "INFO"
        DEBUG   = "DEBUG"
        WARN    = "WARN"
        FATAL   = "FATAL"
        SYSTEM  = "SYSTEM"
        METRIC  = "METRIC"
        TRACE   = "TRACE"
    }

    # Códigos de Controle para o State Machine
    Engine = @{
        WATCHDOG        = "WATCHDOG"
        CARVER          = "CARVER"
        ARTIFACT        = "ARTIFACT"
        METADATA        = "METADATA"
        COMPLIANCE      = "COMPLIANCE"
        SESSION_ID      = "SessionId"
        STATE_RESTART   = "RESTART"
    }

    # Identificadores de Filesystem (Essenciais para o Analysis\FS)
    FileSystems = @{
        NTFS    = "NTFS"
        APFS    = "APFS"
        EXT4    = "EXT4"
        BTRFS   = "BTRFS"
        XFS     = "XFS"
        ZFS     = "ZFS"
        FAT32   = "FAT32"
        EXFAT   = "EXFAT"
        UDF     = "UDF"
        HFS     = "HFS"
        REFS    = "REFS"
    }

    # Hardware & Performance
    Hardware = @{
        RAM     = "RAM"
        HDD     = "HDD"
        SSD     = "SSD"
        NVME    = "NVME"
        USB     = "USB"
        CPU     = "CPU"
        OS      = "OS"
    }
}