@{
    Segment = @{
        Name = "db"
        Version = "1.0.0"
        Description = "Database schema, queries, connection tuning, and forensic persistence constants"
        Dependencies = @("core", "fs")
        HashSHA256 = "PLACEHOLDER_DB_HASH"
    }

    # =============================================================================
    # CORE DB CONFIG
    # =============================================================================
    DB = @{
        PAGE_SIZE      = 4096
        BUSY_TIMEOUT   = 5000
        CONN_STR_FMT   = "Data Source={0};Version=3;Journal Mode=WAL;BusyTimeout={1};Pooling=True;FailIfMissing=False;"
        PRAGMA_INIT    = "PRAGMA synchronous = OFF; PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;"
        PRAGMA_MAINT   = "PRAGMA wal_checkpoint(TRUNCATE); PRAGMA optimize; VACUUM;"

        # Table Names
        TABLE_SESSION  = "ScapeSession"
        TABLE_MFT      = "ShadowMFT"
        TABLE_UNIV     = "UniversalMetadata"
        TABLE_FRAG     = "FragmentMap"

        # Status Enums
        STATUS_DISC    = "DISCOVERED"
        STATUS_DISC_R  = "DISCOVERED_RAW"
        STATUS_EXTRACT = "EXTRACTED"
        STATUS_FAILED  = "FAILED"

        # Query Templates ({0}=TableName)
        QUERY_PATH_MFT = "SELECT ParentFRN as PID, FileName FROM {0} WHERE FRN = @id AND VolumeSerial = @vs"
        QUERY_PATH_UNI = "SELECT ParentID as PID, FileName FROM {0} WHERE ObjectID = @id AND VolumeSerial = @vs"
        QUERY_MFT_SEL  = "SELECT ID, PID, FileName, RawRecord FROM {0} WHERE Status='{1}' AND VolumeSerial=@VS"
        QUERY_MFT_UPD  = "UPDATE {0} SET Status=@2, FileHash=@H, IntegrityScore=@I, ExtractionDate=CURRENT_TIMESTAMP WHERE ID=@ID"
        QUERY_INS_FRAG = "INSERT OR IGNORE INTO {0} (VolumeSerial, ObjectID, FragmentIndex, PhysicalOffset, LengthBytes, IsCorrupt) VALUES (@VS, @OID, @IDX, @PO, @LEN, 0)"
        QUERY_INS_MFT  = "INSERT OR IGNORE INTO {0} (VolumeSerial, FRN, BaseFRN, SequenceNumber, Status, IsBaseRecord, ParentFRN, FileName, Category, RawRecord) VALUES (@VS, @F, @B, @S, @ST, @I, @P, @FN, @Cat, @R)"
        QUERY_INS_UNIV = "INSERT OR IGNORE INTO {0} (VolumeSerial, ObjectID, ParentID, SequenceNumber, Status, FileName, Category, RawRecord) VALUES (@VS, @OID, 0, 1, @ST, @FN, @Cat, @R)"

        # Index Names
        IDX_MFT_VOL_FRN = "idx_shdw_vol_frn"
        IDX_MFT_PAR     = "idx_shdw_par"
        IDX_UNIV_VOL_OBJ= "idx_univ_vol_obj"
        IDX_UNIV_PAR    = "idx_univ_par"
        IDX_FRAG_LOOKUP = "idx_frag_lookup"

        # NTFS MFT Field Offsets (Bytes from MFT record start)
        NTFS_MFT_FRN_OFF   = 44
        NTFS_MFT_BASE_OFF  = 32
        NTFS_MFT_SEQ_OFF   = 16
        NTFS_MFT_PARENT_OFF= 32 # Reuses BaseFRN for parent extraction when IsBase=0
    }

    # =============================================================================
    # FILEMAP & FRAGMENT CONSTANTS
    # =============================================================================
    FILEMAP = @{
        MAX_EXTENTS_PER_FILE   = 1024
        EXTENT_LIST_DEFAULT    = "sequential"
        FRAGMENT_MAP_TYPES     = @("bitmap", "extent", "runlist", "bplustree", "fat", "mft", "catalog")
        BITMAP_ENTRY_SIZE      = 1
        EXTENT_ENTRY_SIZE      = 12
        RUNLIST_ENTRY_SIZE     = 8
        FRAGMAP_CACHE_SIZE     = 10000
        CARVING_FRAGMENT_OVERLAP = 512
        UNIVERSAL_MAP_SIGNATURE = 0x554E4956
        FRAGMAP_BATCH_SIZE     = 500
    }

    # =============================================================================
    # SCHEMA & MIGRATION
    # =============================================================================
    SCHEMA = @{
        VERSION_CURRENT = 3
        MIGRATION_TABLE = "_SchemaVersions"
        AUTO_MIGRATE    = $true
        BACKUP_ON_MIGRATE = $true
    }

    # =============================================================================
    # SCHEMA DDL (Parameterized via constants at runtime)
    # =============================================================================
    DDL = @{
        SESSION = @"
CREATE TABLE IF NOT EXISTS {0} (
    SessionID INTEGER PRIMARY KEY AUTOINCREMENT,
    TargetDrive TEXT, VolumeSerial TEXT, VolumeType TEXT,
    StartTime DATETIME DEFAULT CURRENT_TIMESTAMP
);
"@
        MFT = @"
CREATE TABLE IF NOT EXISTS {0} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    VolumeSerial TEXT, FRN BIGINT, BaseFRN BIGINT,
    SequenceNumber INTEGER, Status TEXT, IsBaseRecord INTEGER,
    ParentFRN BIGINT, FileName TEXT, Category TEXT,
    FileHash TEXT, ExtractionDate DATETIME, IntegrityScore INTEGER,
    RawRecord BLOB, Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS {IDX_VOL_FRN} ON {0}(VolumeSerial, FRN);
CREATE INDEX IF NOT EXISTS {IDX_PAR} ON {0}(ParentFRN);
"@
        UNIV = @"
CREATE TABLE IF NOT EXISTS {0} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    VolumeSerial TEXT, ObjectID BIGINT, ParentID BIGINT,
    SequenceNumber INTEGER, Status TEXT, FileName TEXT,
    Category TEXT, FileHash TEXT, ExtractionDate DATETIME,
    IntegrityScore INTEGER, RawRecord BLOB, Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS {IDX_VOL_OBJ} ON {0}(VolumeSerial, ObjectID);
CREATE INDEX IF NOT EXISTS {IDX_PAR} ON {0}(ParentID);
"@
        FRAG = @"
CREATE TABLE IF NOT EXISTS {0} (
    VolumeSerial TEXT, ObjectID BIGINT, FragmentIndex INTEGER,
    PhysicalOffset BIGINT, LengthBytes BIGINT, IsCorrupt INTEGER DEFAULT 0
);
CREATE INDEX IF NOT EXISTS {IDX_LOOKUP} ON {0}(VolumeSerial, ObjectID);
"@
    }
}