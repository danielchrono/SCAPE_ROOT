@{
    Segment = @{
        Name = "io"
        Version = "1.0.0"
        Description = "I/O engine tuning, buffer sizes, retry policies, and throughput constants"
        Dependencies = @("core", "behavior")
        HashSHA256 = "PLACEHOLDER_IO_HASH"
    }

    BUFFER = @{
        BATCH_SIZE       = 52428800    # 50 MB
        BUFFER_LARGE     = 52428800    # 50 MB
        CHUNK_READ       = 65536       # 64 KB
        BUFFER_CHUNK     = 65536       # 64 KB
        COPY_BUFFER      = 1048576     # 1 MB
        OVERLAP_BYTES    = 4096        # 4 KB overlap para continuidade no carving
        HASH_CHUNK       = 65536       # 64 KB chunks para computação de hash
    }

    FLOW = @{
        FLUSH_THRESHOLD  = 5000        # Registros por flush em disco
        MAX_RETRY        = 3
        RETRY_DELAY_MS   = 200
        TIMEOUT_SEC      = 30
        MAX_OPEN_FILES   = 100
        MAX_GAP_CLUSTERS = 32          # Máximo de gap contíguo tratado como fragmento único
    }

    METRICS = @{
        TOTAL_MFT_RECORDS = 500000     # Contagem esperada de MFT para pré-alocação
        SECTOR_SIZE       = 512        # Referência - também em FS
        ALIGNMENT_BYTES   = 4096       # Boundary de alinhamento de I/O
    }

    # =============================================================================
    # PERFORMANCE TUNING - Valores para ajuste fino de throughput
    # =============================================================================
    PERF = @{
        PARALLEL_READS      = 4
        WRITE_BUFFERED      = $false   # Unbuffered para aquisição forense
        PREAD_SUPPORTED     = $true    # Usar ReadFile com OVERLAPPED quando disponível
        ASYNC_IO_ENABLED    = $true
        IO_PRIORITY_DEFAULT = 3        # IO_PRIORITY_HIGH no Windows
    }
}