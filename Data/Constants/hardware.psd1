@{
    Segment = @{
        Name = "hardware"
        Version = "1.0.0"
        Description = "Hardware-aware tuning profiles for adaptive performance and resource safety"
        Dependencies = @("core", "behavior")
        HashSHA256 = "PLACEHOLDER_HARDWARE_HASH"
    }

    # =============================================================================
    # DETECTION HINTS (Runtime: preencher via HardwareProfile.psm1)
    # =============================================================================
    DETECTED = @{
        RAM_GB              = 0      # Runtime: [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        CPU_CORES           = 0      # Runtime: $env:NUMBER_OF_PROCESSORS
        STORAGE_TYPE        = "UNKNOWN"  # Runtime: "SSD", "HDD", "NVMe", "USB"
        IS_ADMIN            = $false # Runtime: ([Security.Principal.WindowsPrincipal]...).IsInRole(...)
        PS_EDITION          = "Desktop"  # Runtime: $PSVersionTable.PSEdition
        MAX_CONCURRENCY     = 1      # Runtime: calculado baseado em RAM + CPU + Storage
    }

    # =============================================================================
    # PROFILES: Pre-configurações por cenário de hardware
    # =============================================================================
    PROFILES = @{
        # Mínimo viável: 4GB RAM, HDD, dual-core
        MINIMUM = @{
            RAM_BUFFER_MB       = 16
            IO_CHUNK_KB         = 64
            MAX_PARALLEL_OPS    = 1
            CARVING_BATCH_SIZE  = 10
            DB_FLUSH_EVERY      = 100
            ENABLE_PREFETCH     = $false
            THERMAL_THROTTLE_C  = 70
        }

        # Padrão: 8-16GB RAM, SSD, quad-core
        STANDARD = @{
            RAM_BUFFER_MB       = 64
            IO_CHUNK_KB         = 256
            MAX_PARALLEL_OPS    = 4
            CARVING_BATCH_SIZE  = 50
            DB_FLUSH_EVERY      = 500
            ENABLE_PREFETCH     = $true
            THERMAL_THROTTLE_C  = 80
        }

        # Workstation: 32GB+ RAM, NVMe, 8+ cores
        WORKSTATION = @{
            RAM_BUFFER_MB       = 256
            IO_CHUNK_KB         = 1024
            MAX_PARALLEL_OPS    = 8
            CARVING_BATCH_SIZE  = 200
            DB_FLUSH_EVERY      = 2000
            ENABLE_PREFETCH     = $true
            THERMAL_THROTTLE_C  = 85
        }

        # Server: 64GB+ RAM, RAID/NVMe, 16+ cores
        SERVER = @{
            RAM_BUFFER_MB       = 512
            IO_CHUNK_KB         = 2048
            MAX_PARALLEL_OPS    = 16
            CARVING_BATCH_SIZE  = 500
            DB_FLUSH_EVERY      = 5000
            ENABLE_PREFETCH     = $true
            THERMAL_THROTTLE_C  = 90
        }
    }

    # =============================================================================
    # THROTTLING & SAFEGUARDS (Global, aplicável a todos os profiles)
    # =============================================================================
    SAFEGUARDS = @{
        RAM_CRITICAL_PCT      = 0.15      # Abortar se uso > 85%
        RAM_WARNING_PCT       = 0.25      # Reduzir paralelismo se uso > 75%
        IO_QUEUE_MAX          = 1000      # Limite de operações pendentes
        CARVING_MAX_GAP_KB    = 128       # Máximo gap tolerado entre fragments
        DB_TRANSACTION_MAX_MS = 30000     # Timeout para commit em lote
        BACKOFF_BASE_MS       = 100       # Base para retry exponencial
        BACKOFF_MAX_MS        = 5000      # Teto para backoff
        HEARTBEAT_INTERVAL_MS = 2000      # Health check do pipeline
    }

    # =============================================================================
    # STORAGE-SPECIFIC TUNING
    # =============================================================================
    STORAGE = @{
        HDD = @{
            SEEK_PENALTY_MS   = 10
            OPTIMAL_CHUNK_KB  = 64
            PREFETCH_BLOCKS   = 4
            MAX_PARALLEL_READS = 2
        }
        SSD = @{
            SEEK_PENALTY_MS   = 1
            OPTIMAL_CHUNK_KB  = 256
            PREFETCH_BLOCKS   = 16
            MAX_PARALLEL_READS = 8
        }
        NVME = @{
            SEEK_PENALTY_MS   = 0
            OPTIMAL_CHUNK_KB  = 1024
            PREFETCH_BLOCKS   = 32
            MAX_PARALLEL_READS = 16
        }
        USB = @{
            SEEK_PENALTY_MS   = 20
            OPTIMAL_CHUNK_KB  = 32
            PREFETCH_BLOCKS   = 2
            MAX_PARALLEL_READS = 1
            ENABLE_WRITE_CACHE = $false
        }
    }

    # =============================================================================
    # MEMORY MANAGEMENT
    # =============================================================================
    MEMORY = @{
        BUFFER_ALIGNMENT      = 4096          # Alinhamento para alocação eficiente
        GC_THRESHOLD_MB       = 100           # Forçar GC se heap > X MB
        LARGE_OBJECT_THRESHOLD = 85000        # Objetos >85KB vão para LOH (.NET)
        POOL_RECYCLE_COUNT    = 100           # Reutilizar buffers após N usos
    }
}