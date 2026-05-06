@{
    Segment    = @{
        Name         = "storage"
        Version      = "1.0.0"
        Description  = "I/O buffer sizes and flow control, FS Parsing and Carving signatures"
        Dependencies = @("system")
        HashSHA256   = "PLACEHOLDER_STORAGE_HASH"
    }
    Buffer     = @{
        BATCH_SIZE  = 52428800   # 50 MB
        CHUNK_READ  = 65536      # 64 KB
        COPY_BUFFER = 1048576    # 1 MB
        HASH_CHUNK  = 65536
    }
    Flow       = @{
        FLUSH_THRESHOLD = 5000
        MAX_RETRY       = 3
        RETRY_DELAY_MS  = 200
        TIMEOUT_SEC     = 30
        MAX_OPEN_FILES  = 100
    }
    Perf       = @{
        PARALLEL_READS      = 4
        WRITE_BUFFERED      = $false
        ASYNC_IO_ENABLED    = $true
        IO_PRIORITY_DEFAULT = 3
    }

    # =====================================================================
    # Filesystem signatures, offsets, structural constants, and field definitions for forensic parsing
    # =====================================================================
    FS         = @{
        # GLOBAL / COMMON
        SECTOR_SIZE          = 512
        BLOCK_SIZE           = 4096
        CLUSTER_SIZES        = @(512, 1024, 2048, 4096, 8192, 16384, 32768, 65536)
        ROOT_DIR_ID          = 5
        CLUSTER_DEFAULT      = 4096
        UNKNOWN_FS_SIG_LEN   = 8
        UNKNOWN_FS_PROBE_LEN = 16384

        # =====================================================================
        # NTFS
        # =====================================================================
        NTFS                 = @{
            # Signatures & Sizes
            MFT_SIG              = 0x454C4946          # "FILE"
            MFT_SIZE             = 1024
            MFT_REC_SIZE         = 1024
            FILE_REC_SIZE        = 1024
            ALIGN                = 512

            # Boot Sector Offsets
            BOOT_MFT_OFF         = 0x30
            BOOT_CLS_OFF         = 0x0B
            BOOT_SPC_OFF         = 0x0D
            BOOT_OEM_OFF         = 0x03
            BOOT_OEM_LEN         = 8

            # MFT Record Field Offsets (from record start)
            MFT_USA_OFF_OFF      = 4                   # Offset to Update Sequence Array offset
            MFT_USA_CNT_OFF      = 6                   # Update Sequence Array count
            MFT_LSN_OFF          = 8                   # Log File Sequence Number
            MFT_SEQ_OFF          = 16                  # Sequence number
            MFT_FRN_OFF          = 44                  # File Reference Number (low 48 bits)
            MFT_ATTR_OFF_OFF     = 20                  # Offset to first attribute
            MFT_FLAGS_OFF        = 22                  # Flags (incl. deleted flag)

            # Attribute Types
            ATTR_NAME            = 0x30                # $FILE_NAME
            ATTR_DATA            = 0x80                # $DATA
            ATTR_SECURITY        = 0x50                # $SECURITY_DESCRIPTOR
            ATTR_END             = 0xFFFFFFFF

            # Attribute Field Offsets (relative to attribute header)
            ATTR_TYPE_OFF        = 0
            ATTR_LEN_OFF         = 4
            ATTR_NONRES_OFF      = 8
            ATTR_NAMELEN_OFF     = 16
            ATTR_NAMEOFF_OFF     = 18
            ATTR_FLAGS_OFF       = 24
            ATTR_DATA_SIZE_OFF   = 24                # For resident: size; non-resident: VCN
            ATTR_DATA_RUNOFF_OFF = 32              # Runlist offset for non-resident

            # Masks & Constants
            FRN_MASK             = 0x0000FFFFFFFFFFFF  # Mask to extract FRN from file reference
        }

        # =====================================================================
        # FAT / exFAT
        # =====================================================================
        FAT                  = @{
            DIR_SIZE           = 32
            DEL_SIG            = 0xE5
            BOOT_SIG           = 0xAA55

            # FAT32 Boot Sector Offsets
            FAT32_FAT_OFFSET   = 0x24                # Offset to FAT size field
            FAT32_ROOT_CLS_OFF = 0x2C              # Root directory start cluster
            FAT32_FSINFO_OFF   = 0x1E4               # FSINFO sector offset

            # Directory Entry Field Offsets (32-byte entry)
            DIR_NAME_OFF       = 0                   # 8.3 name (8+3 bytes)
            DIR_ATTR_OFF       = 0xB                 # Attributes byte
            DIR_TIME_OFF       = 0x16                # Last write time (DOS packed)
            DIR_DATE_OFF       = 0x18                # Last write date (DOS packed)
            DIR_STARTCLU_OFF   = 0x1A                # Start cluster (low word)
            DIR_SIZE_OFF       = 0x1C                # File size (32-bit)

            # exFAT
            EXFAT_FILE_SIG     = 0x85                # File directory entry type
            EXFAT_STRM_SIG     = 0xC0                # Stream extension entry type
            EXFAT_VBR_SIG      = 0x4558464154202020  # "EXFAT   "
            EXFAT_CLUST_SIZE   = 0x4000
            EXFAT_DIR_SIZE     = 32

            # exFAT Stream Extension Field Offsets (relative to entry start)
            EXFAT_FLAGS_OFF    = 1
            EXFAT_NAMELEN_OFF  = 2
            EXFAT_NAMEHASH_OFF = 4
            EXFAT_VALIDLEN_OFF = 8
            EXFAT_ALLOCLEN_OFF = 12
            EXFAT_FIRSTCLU_OFF = 16
        }

        # =====================================================================
        # EXT Family (EXT2/3/4)
        # =====================================================================
        EXT                  = @{
            # Signatures
            SIG                 = 0xEF53              # Common to EXT2/3/4
            EXT2_SIG            = 0xEF53
            EXT3_SIG            = 0xEF53
            EXT4_SIG            = 0xF30A              # EXT4-specific feature flag

            # Superblock Offsets (from start of superblock at 0x438)
            SB_OFFSET           = 0x38                # Offset to superblock within block group
            SB_OFFSET_HEX       = 0x438               # Absolute offset in sector 1
            MAGIC_OFF           = 0x438               # Magic number offset (16-bit)
            INODE_SIZE          = 256
            BLOCK_GROUP_DESC    = 0x20                # Size of group descriptor

            # Superblock Field Offsets (relative to superblock start)
            SB_INODES_OFF       = 0x00                # Total inodes (32-bit)
            SB_BLOCKS_OFF       = 0x04                # Total blocks (32-bit)
            SB_INODE_SIZE_OFF   = 0x58               # Inode size (16-bit)
            SB_FEATURES_OFF     = 0x60                # Feature flags (32-bit)

            # Inode Field Offsets (relative to inode start)
            INODE_MODE_OFF      = 0                   # File mode (16-bit)
            INODE_UID_OFF       = 4                   # Owner UID (32-bit)
            INODE_SIZE_LOW_OFF  = 8                 # File size low (32-bit)
            INODE_SIZE_HIGH_OFF = 12               # File size high (32-bit, EXT4)
            INODE_ATIME_OFF     = 16                  # Last access time (32-bit epoch)
            INODE_MTIME_OFF     = 20                  # Last modification time
            INODE_CTIME_OFF     = 24                  # Last status change time
            INODE_LINKS_OFF     = 28                  # Hard link count (16-bit)
            INODE_BLOCKS_OFF    = 32                  # Blocks allocated (32-bit)
            INODE_FLAGS_OFF     = 48                  # Flags (32-bit)
            INODE_PTRS_START    = 40                  # Block pointers start (12 direct + indirect)
        }

        # =====================================================================
        # BTRFS
        # =====================================================================
        BTRFS                = @{
            SB_SIG            = 0x5F42485266535F4D  # "_BHRfS_M"
            SB_OFFSET         = 0x40                # Superblock offset within device
            SB_OFF_HEX        = 0x10040             # Absolute offset for detection
            NODE_SIZE         = 16384
            CHUNK_TYPE        = 0x3C
            MIRROR_TYPE       = 0x3D

            # Superblock Field Offsets (relative to superblock start)
            SB_UUID_OFF       = 0x20                # Filesystem UUID (16 bytes)
            SB_FSID_OFF       = 0x18                # Filesystem FSID (16 bytes)
            SB_CSUMTYPE_OFF   = 0x68                # Checksum type (1 byte)
            SB_NODESIZE_OFF   = 0x2C                # Node size (32-bit)
            SB_SECTORSIZE_OFF = 0x30                # Sector size (32-bit)
            SB_TOTALBYTES_OFF = 0x38                # Total filesystem size (64-bit)
            SB_ROOTDIR_OFF    = 0x48                # Root directory object ID (64-bit)
            SB_GENERATION_OFF = 0x50                # Transaction generation (64-bit)
            SB_CHUNKROOT_OFF  = 0x58                # Chunk tree root generation (64-bit)
            SB_ROOTLEVEL_OFF  = 0x60                # Root tree level (1 byte)
        }

        # =====================================================================
        # XFS
        # =====================================================================
        XFS                  = @{
            SB_SIG           = 0x58465342          # "XFSB"
            SB_SIZE          = 512
            AGF_SIG          = 0x58414746          # "XAGF"
            AGI_SIG          = 0x58414749          # "XAGI"

            # Superblock Field Offsets (big-endian fields)
            SB_BLOCKSIZE_OFF = 0x18                # Block size (32-bit BE)
            SB_DBLOCKS_OFF   = 0x20                # Data blocks count (64-bit BE)
            SB_RBLOCKS_OFF   = 0x28                # Real blocks count (64-bit BE)
            SB_AGCOUNT_OFF   = 0x30                # Allocation group count (32-bit BE)
            SB_AGBLOCKS_OFF  = 0x34                # Blocks per AG (32-bit BE)
            SB_ROOTINO_OFF   = 0x60                # Root inode number (64-bit BE)
            SB_UUID_OFF      = 0x28                # Filesystem UUID (16 bytes)
        }

        # =====================================================================
        # ZFS
        # =====================================================================
        ZFS                  = @{
            LABEL_SIG          = 0x2F5A42534F4C5953  # "/ZBSOLYS"
            UBER_SIG           = 0x00BAB10C
            UBER_SIZE          = 512
            MIN_TXG_OFF        = 0x08                # Transaction group offset in uberblock
            VDEV_OFFSET        = 0x1000              # Typical vdev label offset
            GUID_OFF_HEX       = 0x40                # GUID offset in label

            # Uberblock Field Offsets (relative to uberblock start)
            UBER_TXG_OFF       = 0x08                # Transaction group (64-bit LE)
            UBER_TIMESTAMP_OFF = 0x10                # Timestamp (64-bit LE)
            UBER_ROOTBP_OFF    = 0x20                # Root block pointer (64-bit LE)
        }

        # =====================================================================
        # APFS
        # =====================================================================
        APFS                 = @{
            SB_SIG                 = 0x4E585342          # "NXSB"
            BLOCK_SIZE             = 4096
            MAGIC_OFF              = 0x20                # Alias for compatibility
            MAGIC_OFFSET           = 0x20                # Magic number offset in container header
            VOL_SIG                = 0x41504653          # "APFS"
            CHECKPOINT_OFF         = 0x1000
            SERIAL_OFF             = 0x48

            # Container Superblock Field Offsets (relative to magic offset)
            SB_BLOCKSIZE_OFF       = 0x04                # Block size (32-bit LE)
            SB_CONTAINERSIZE_OFF   = 0x08              # Container size (64-bit LE)
            SB_VERSION_OFF         = 0x10                # NX version (32-bit LE)
            SB_CHECKPOINT_DESC_OFF = 0x58            # Checkpoint descriptor address (64-bit LE)
        }

        # =====================================================================
        # ReFS
        # =====================================================================
        REFS                 = @{
            SIG                  = 0x53664552          # "fReS" (little-endian)
            VBR_OEM_ID           = "ReFS   "
            CLUSTER_SIZE         = 65536
            METADATA_SIZE        = 4096
            SUPERBLOCK_OFF       = 0
            CHECKPOINT_OFF       = 0x2000
            CONTAINER_ID_OFF     = 0x28
            BLOCK_SIZE           = 4096

            # Superblock Field Offsets (relative to superblock start)
            SB_VERSION_MAJOR_OFF = 0x08            # Major version (32-bit LE)
            SB_VERSION_MINOR_OFF = 0x0C            # Minor version (32-bit LE)
            SB_CLUSTERSIZE_OFF   = 0x14              # Cluster size (32-bit LE)
            SB_VOLUMESIZE_OFF    = 0x18               # Volume size in clusters (64-bit LE)
            SB_METADATASIZE_OFF  = 0x28             # Metadata size (64-bit LE)
            SB_ROOTFILEREFF_OFF  = 0x60             # Root file reference (64-bit LE)
        }

        # =====================================================================
        # HFS / HFS+ / HFSX
        # =====================================================================
        HFS                  = @{
            SIG                = 0x4244              # "BD" (HFS)
            PLUS_SIG           = 0x484B              # "H+" (HFS+)
            HFSX_SIG           = 0x482B              # "H+" (HFSX)
            VOLUME_HEADER_OFF  = 1024                # Volume header offset in bytes
            ALLOC_FILE         = 0x00000003
            EXTENTS_FILE       = 0x00000004
            CATALOG_FILE       = 0x00000005
            ATTRIBUTES_FILE    = 0x00000006
            STARTUP_FILE       = 0x00000007
            BLOCK_SIZE         = 4096
            NODE_SIZE          = 8192
            LEAF_NODE_RECORD   = 0x00
            INDEX_NODE_RECORD  = 0x01
            HEADER_UNIQUENESS  = 0x3A2C4D1E

            # Volume Header Field Offsets (relative to volume header start)
            VH_SIGNATURE_OFF   = 0x00                # Signature (16-bit)
            VH_BLOCKSIZE_OFF   = 0x0C                # Block size (16-bit HFS, 32-bit HFS+)
            VH_TOTALBLOCKS_OFF = 0x10                # Total blocks (32-bit)
            VH_ROOTDIR_OFF     = 0x14                # Root directory CNID (32-bit)
            VH_VOLNAME_OFF     = 0x2C                # Volume name (32 bytes ASCII)
        }

        # =====================================================================
        # F2FS
        # =====================================================================
        F2FS                 = @{
            SB_SIG              = 0xF2F52010
            BLOCK_SIZE          = 4096
            CP_OFF              = 0x2000              # Checkpoint offset

            # Superblock Field Offsets (at offset 0x400 within device)
            SB_BLOCKSIZE_OFF    = 0x0C                # Block size (32-bit LE)
            SB_TOTALSECTORS_OFF = 0x18               # Total sectors (64-bit LE)
            SB_ROOTINO_OFF      = 0x48                # Root inode number (32-bit LE)
            SB_SEGMENTCNT_OFF   = 0x58                # Segment count (32-bit LE)
        }

        # =====================================================================
        # JFS
        # =====================================================================
        JFS                  = @{
            SUPER_SIG          = 0x315F4A46          # "JFS1" (ASCII)
            BLOCK_SIZE         = 4096

            # Superblock Field Offsets (relative to superblock start)
            SB_BLOCKSIZE_OFF   = 0x08                # Block size (32-bit LE)
            SB_TOTALBLOCKS_OFF = 0x0C                # Total blocks (64-bit LE)
            SB_ROOTINODE_OFF   = 0x20                # Root inode number (32-bit LE)
        }

        # =====================================================================
        # UDF
        # =====================================================================
        UDF                  = @{
            SIG               = 0x42454130          # "BEA0" (VRS signature prefix)
            VRS_OFF           = 0x8000              # Volume Recognition Sequence offset
            ANCHOR_OFF        = 0x10000             # Anchor Volume Descriptor offset
            LV_INFO_OFF       = 0x20000             # Logical Volume Info offset

            # Primary Volume Descriptor Field Offsets (relative to PVD start)
            PVD_VOLNAME_OFF   = 0x28                # Volume identifier (32 bytes)
            PVD_BLOCKSIZE_OFF = 0x10                # Logical block size (32-bit LE)
            PVD_VOLSPACE_OFF  = 0x50                # Volume space size (32-bit LE)
        }

        # =====================================================================
        # ISO9660
        # =====================================================================
        ISO9660              = @{
            SIG                    = "CD001"             # Primary Volume Descriptor signature (ASCII)
            PVD_OFFSET             = 0x8000              # Primary Volume Descriptor sector offset
            PVD_BYTE_OFFSET        = 0x8001              # Byte offset within sector for signature

            # Primary Volume Descriptor Field Offsets (relative to PVD start)
            PVD_VOLNAME_OFF        = 0x28                # Volume identifier (32 bytes)
            PVD_BLOCKSIZE_OFF      = 0x80                # Logical block size (16-bit LE)
            PVD_VOLSPACE_OFF       = 0x50                # Volume space size (32-bit LE)
            PVD_ROOTDIR_OFF        = 0x9E                # Root directory record offset
            PVD_ROOTDIR_LEN_OFF    = 0xAA               # Root directory length (1 byte)
            PVD_ROOTDIR_EXTENT_OFF = 0xA2            # Root directory extent location (32-bit LE)
        }

        # =====================================================================
        # DISK IMAGE CONTAINERS
        # =====================================================================
        DISKIMAGE            = @{
            # VMDK
            VMDK_SIG              = "KDMV"              # Little-endian "VMDK"
            VMDK_VERSION_OFF      = 0x04                # Format version (32-bit LE)
            VMDK_FLAGS_OFF        = 0x08                # Flags (32-bit LE)
            VMDK_CAPACITY_OFF     = 0x30                # Capacity in sectors (64-bit LE)
            VMDK_GRAINSIZE_OFF    = 0x28                # Grain size in sectors (32-bit LE)

            # VHD (Legacy)
            VHD_SIG               = "conectix"          # ASCII signature at offset 0
            VHD_FILESIZE_OFF      = 0x28                # File size in bytes (64-bit BE)
            VHD_GEOMETRY_OFF      = 0x40                # Disk geometry (16-bit BE)

            # VHDX
            VHDX_SIG              = "vhdxfile"          # ASCII signature at offset 0
            VHDX_FILESIZE_OFF     = 0x20                # File size in bytes (64-bit LE)
            VHDX_LOGSECTOR_OFF    = 0x30                # Logical sector size (32-bit LE)
            VHDX_PHYSECTOR_OFF    = 0x34                # Physical sector size (32-bit LE)

            # QCOW2
            QCOW2_MAGIC           = 0x514649FB          # "QFI" + 0xFB
            QCOW2_VERSION_OFF     = 0x04                # Format version (32-bit BE)
            QCOW2_BACKING_OFF     = 0x08                # Backing file offset (64-bit BE)
            QCOW2_SIZE_OFF        = 0x18                # Virtual size in bytes (64-bit BE)
            QCOW2_CLUSTERBITS_OFF = 0x20             # Cluster size as power of 2 (8-bit)

            # DMG (Apple)
            DMG_SIG               = "koly"              # ASCII signature at offset 0x0C
            DMG_SIZE_OFF          = 0x04                # Size field (64-bit BE)
            DMG_DATAFORK_OFF      = 0x2C                # Data fork offset (64-bit BE)
        }

        # =====================================================================
        # PARTITION TABLES
        # =====================================================================
        PARTITION            = @{
            # GPT
            GPT_SIG                  = "EFI PART"          # ASCII signature at offset 0
            GPT_REVISION_OFF         = 0x08                # Revision (32-bit LE)
            GPT_HEADERSIZE_OFF       = 0x0C                # Header size (32-bit LE)
            GPT_CURRENTLBA_OFF       = 0x18                # Current LBA (64-bit LE)
            GPT_BACKUPLBA_OFF        = 0x20                 # Backup LBA (64-bit LE)
            GPT_FIRSTUSABLE_OFF      = 0x28               # First usable LBA (64-bit LE)
            GPT_LASTUSABLE_OFF       = 0x30                # Last usable LBA (64-bit LE)
            GPT_DISKGUID_OFF         = 0x38                # Disk GUID (16 bytes)
            GPT_PARTSTART_OFF        = 0x48                 # Partition array start LBA (64-bit LE)
            GPT_PARTCOUNT_OFF        = 0x50                 # Number of partitions (32-bit LE)
            GPT_PARTENTRYSIZE_OFF    = 0x54             # Partition entry size (32-bit LE)

            # Partition Entry Field Offsets (relative to entry start)
            PART_TYPEGUID_OFF        = 0x00                # Partition type GUID (16 bytes)
            PART_PARTGUID_OFF        = 0x10                # Unique partition GUID (16 bytes)
            PART_FIRSTLBA_OFF        = 0x20                # First LBA (64-bit LE)
            PART_LASTLBA_OFF         = 0x28                # Last LBA (64-bit LE)
            PART_FLAGS_OFF           = 0x30                # Attributes flags (64-bit LE)
            PART_NAME_OFF            = 0x38                # Partition name (72 bytes UTF-16LE)

            # MBR
            MBR_SIG                  = 0xAA55              # Boot signature at offset 510
            MBR_DISKSIG_OFF          = 0x1B8               # Disk signature (32-bit LE, optional)
            MBR_PARTTABLE_OFF        = 0x1BE               # Partition table start offset

            # MBR Partition Entry Field Offsets (16 bytes each, 4 entries)
            MBR_PART_STATUS_OFF      = 0x00               # Boot indicator (1 byte)
            MBR_PART_STARTCHS_OFF    = 0x01             # Start CHS (3 bytes)
            MBR_PART_TYPE_OFF        = 0x04                # Partition type (1 byte)
            MBR_PART_ENDCHS_OFF      = 0x05               # End CHS (3 bytes)
            MBR_PART_STARTLBA_OFF    = 0x08             # Start LBA (32-bit LE)
            MBR_PART_SECTORCOUNT_OFF = 0x0C          # Sector count (32-bit LE)
        }

        # =====================================================================
        # MAGIC OFFSET LIBRARY (Generic FS detection)
        # =====================================================================
        FS_MAGIC_OFFSET_LIB  = @(
            @{Magic = 0x0B5B1A2F; Name = "cramfs"; Offset = 0x0 }
            @{Magic = 0x73717368; Name = "squashfs"; Offset = 0x0 }
            @{Magic = 0x68737173; Name = "squashfs (alt)"; Offset = 0x0 }
            @{Magic = 0x2F5B2F5B; Name = "romfs"; Offset = 0x0 }
            @{Magic = 0x72617930; Name = "cramfs-alt"; Offset = 0x0 }
            @{Magic = 0x68737173; Name = "squashfs-be"; Offset = 0x0 }
        )
    }


    # =============================================================================
    # CARVING ENGINE
    # Raw disk carving signatures, magic bytes, and boundary definitions for forensic recovery
    # =============================================================================
    ENGINE     = @{
        # LIMITS & TUNING
        DEFAULT_MAX_SIZE_BYTES = 536870912   # 500 MB (failsafe se footer não for achado)
        SECTOR_ALIGNMENT       = 512         # Assinaturas geralmente começam no limite do setor
        MAX_ORPHAN_GAP_KB      = 128         # Tolerância para pular clusters danificados
        FOOTER_SCAN_CHUNK_SIZE = 1048576     # 1 MB chunk reading scan para achar footer
        SCAN_PARALLELISM       = 4           # Threads simultâneos para busca de headers
        HASH_ON_EXTRACT        = $true       # Calcular SHA256 durante extração (custo: +15% CPU)
        VALIDATE_FOOTER_STRICT = $false      # Se $true, rejeita arquivos sem footer exato
        MIN_CONFIDENCE_SCORE   = 0.6         # Threshold para aceitar carving ambíguo
    }

    # =============================================================================
    # SIGNATURE DEFINITIONS
    # Formato: Header/Footer em hex string contínua (case-insensitive)
    # RequireExact: $true = exige footer exato; $false = aceita truncamento inteligente
    # =============================================================================
    SIGNATURES = @{

        # ─────────────────────────────────────────────────────────────────
        # IMAGENS & GRÁFICOS
        # ─────────────────────────────────────────────────────────────────
        "JPEG"            = @{
            Category     = "Image"
            Extension    = ".jpg"
            Header       = "FFD8FF"          # Ignora último byte (E0/E1) para pegar variantes EXIF/JFIF
            Footer       = "FFD9"            # End Of Image (EOI)
            HeaderOffset = 0
            MaxSize      = 52428800          # 50 MB
            RequireExact = $true
            Description  = "Joint Photographic Experts Group"
        }
        "PNG"             = @{
            Category     = "Image"
            Extension    = ".png"
            Header       = "89504E470D0A1A0A"
            Footer       = "49454E44AE426082"  # IEND chunk
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $true
            Description  = "Portable Network Graphics"
        }
        "GIF"             = @{
            Category     = "Image"
            Extension    = ".gif"
            Header       = "47494638"         # GIF8 (pega GIF87a e GIF89a)
            Footer       = "003B"             # Trailer
            HeaderOffset = 0
            MaxSize      = 20971520           # 20 MB
            RequireExact = $true
            Description  = "Graphics Interchange Format"
        }
        "BMP"             = @{
            Category     = "Image"
            Extension    = ".bmp"
            Header       = "424D"             # "BM"
            Footer       = $null              # Sem footer padrão; usa tamanho do header
            HeaderOffset = 0
            MaxSize      = 104857600          # 100 MB
            RequireExact = $false
            Description  = "Bitmap Image File"
        }
        "TIFF_LE"         = @{
            Category     = "Image"
            Extension    = ".tiff"
            Header       = "49492A00"         # Little-endian
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Tagged Image File Format (LE)"
        }
        "TIFF_BE"         = @{
            Category     = "Image"
            Extension    = ".tiff"
            Header       = "4D4D002A"         # Big-endian
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Tagged Image File Format (BE)"
        }
        "WEBP"            = @{
            Category         = "Image"
            Extension        = ".webp"
            Header           = "52494646"         # "RIFF"
            Footer           = $null              # Estrutura RIFF; footer não confiável
            HeaderOffset     = 0
            ValidationBytes  = "57454250"      # "WEBP" após 8 bytes
            ValidationOffset = 8
            MaxSize          = 52428800
            RequireExact     = $false
            Description      = "WebP Image Format"
        }
        "ICO"             = @{
            Category     = "Image"
            Extension    = ".ico"
            Header       = "00000100"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760           # 10 MB
            RequireExact = $false
            Description  = "Windows Icon"
        }
        "CUR"             = @{
            Category     = "Image"
            Extension    = ".cur"
            Header       = "00000200"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Windows Cursor"
        }
        "PSD"             = @{
            Category     = "Image"
            Extension    = ".psd"
            Header       = "38425053"         # "8BPS"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200          # 200 MB
            RequireExact = $false
            Description  = "Adobe Photoshop Document"
        }
        "TGA"             = @{
            Category     = "Image"
            Extension    = ".tga"
            Header       = "00000200"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Truevision TGA"
        }
        "DDS"             = @{
            Category     = "Image"
            Extension    = ".dds"
            Header       = "44445320"         # "DDS "
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "DirectDraw Surface"
        }
        "CR2"             = @{
            Category     = "Image"
            Extension    = ".cr2"
            Header       = "49492A00100000004352"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Canon RAW 2"
        }
        "NEF"             = @{
            Category     = "Image"
            Extension    = ".nef"
            Header       = "4D4D002A00000008"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Nikon Electronic Format"
        }
        "ARW"             = @{
            Category     = "Image"
            Extension    = ".arw"
            Header       = "49492A0008000000"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Sony Alpha RAW"
        }
        "DNG"             = @{
            Category     = "Image"
            Extension    = ".dng"
            Header       = "49492A0010000000444E47"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Digital Negative (Adobe RAW)"
        }
        "HEIC"            = @{
            Category     = "Image"
            Extension    = ".heic"
            Header       = "6674797068656963"  # "ftypheic"
            Footer       = $null
            HeaderOffset = 4
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "High Efficiency Image Container"
        }
        "HEIF"            = @{
            Category     = "Image"
            Extension    = ".heif"
            Header       = "667479706D696631"  # "ftypmif1"
            Footer       = $null
            HeaderOffset = 4
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "High Efficiency Image Format"
        }
        "JP2"             = @{
            Category     = "Image"
            Extension    = ".jp2"
            Header       = "0000000C6A5020200D0A870A"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "JPEG 2000"
        }
        "SVG"             = @{
            Category     = "Image"
            Extension    = ".svg"
            Header       = "3C3F786D6C"        # "<?xml" em hex
            Footer       = "3C2F7376673E"       # "</svg>" em hex (opcional)
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Scalable Vector Graphics (XML)"
        }

        # ─────────────────────────────────────────────────────────────────
        # DOCUMENTOS & TEXTOS
        # ─────────────────────────────────────────────────────────────────
        "PDF"             = @{
            Category     = "Document"
            Extension    = ".pdf"
            Header       = "255044462D"        # "%PDF-"
            Footer       = "2525454F46"         # "%%EOF"
            HeaderOffset = 0
            MaxSize      = 209715200           # 200 MB
            RequireExact = $false              # PDFs truncados ainda são úteis
            Description  = "Portable Document Format"
        }
        "OLE2"            = @{
            Category     = "Document"
            Extension    = ".doc"              # Cobre .doc, .xls, .ppt legados
            Header       = "D0CF11E0A1B11AE1"
            Footer       = $null               # Sem footer; requer parsing FAT interno
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "OLE2 Compound Document (Legacy Office)"
        }
        "DOCX"            = @{
            Category         = "Document"
            Extension        = ".docx"
            Header           = "504B0304"          # ZIP local header
            Footer           = "504B0506"          # ZIP End of Central Directory
            HeaderOffset     = 0
            ValidationBytes  = "5B436F6E74656E745F54797065735D"  # "[Content_Types]"
            ValidationOffset = 30
            MaxSize          = 104857600
            RequireExact     = $false
            Description      = "Office Open XML Document"
        }
        "XLSX"            = @{
            Category         = "Document"
            Extension        = ".xlsx"
            Header           = "504B0304"
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "786C2F"         # "xl/"
            ValidationOffset = 30
            MaxSize          = 104857600
            RequireExact     = $false
            Description      = "Office Open XML Spreadsheet"
        }
        "PPTX"            = @{
            Category         = "Document"
            Extension        = ".pptx"
            Header           = "504B0304"
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "7070742F"       # "ppt/"
            ValidationOffset = 30
            MaxSize          = 104857600
            RequireExact     = $false
            Description      = "Office Open XML Presentation"
        }
        "RTF"             = @{
            Category     = "Document"
            Extension    = ".rtf"
            Header       = "7B5C727466"        # "{\rtf"
            Footer       = "7D"                 # "}"
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Rich Text Format"
        }
        "ODT"             = @{
            Category         = "Document"
            Extension        = ".odt"
            Header           = "504B0304"
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "6D696D65747970656170706C69636174696F6E2F766E642E6F617369732E6F70656E646F63756D656E742E74657874"
            ValidationOffset = 30
            MaxSize          = 104857600
            RequireExact     = $false
            Description      = "OpenDocument Text"
        }
        "EPUB"            = @{
            Category         = "Document"
            Extension        = ".epub"
            Header           = "504B0304"
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "6D696D65747970656170706C69636174696F6E2F657075622B7A6970"
            ValidationOffset = 30
            MaxSize          = 104857600
            RequireExact     = $false
            Description      = "Electronic Publication"
        }
        "MOBI"            = @{
            Category     = "Document"
            Extension    = ".mobi"
            Header       = "424F4F4B4D4F4249"  # "BOOKMOBI"
            Footer       = $null
            HeaderOffset = 60                   # 0x3C
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Mobipocket eBook"
        }
        "AZW"             = @{
            Category         = "Document"
            Extension        = ".azw"
            Header           = "504B0304"
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "6D696D65747970656170706C69636174696F6E2F766E642E616D617A6F6E2E6D6F6269"
            ValidationOffset = 30
            MaxSize          = 52428800
            RequireExact     = $false
            Description      = "Amazon Kindle Format"
        }

        # ─────────────────────────────────────────────────────────────────
        # ARQUIVOS COMPACTADOS & CONTAINERS
        # ─────────────────────────────────────────────────────────────────
        "ZIP"             = @{
            Category     = "Archive"
            Extension    = ".zip"              # Cobre DOCX, XLSX, PPTX, APK, JAR
            Header       = "504B0304"          # Local file header signature
            Footer       = "504B0506"          # End of central directory (EoCD)
            HeaderOffset = 0
            MaxSize      = 2147483648          # 2 GB
            RequireExact = $true
            Description  = "ZIP Archive"
        }
        "RAR"             = @{
            Category     = "Archive"
            Extension    = ".rar"
            Header       = "526172211A0700"
            Footer       = "C43D7B00400700"    # RAR v4 EOF (v5 requer parsing de bloco final)
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "RAR Archive (v4)"
        }
        "RAR5"            = @{
            Category     = "Archive"
            Extension    = ".rar"
            Header       = "526172211A070100"
            Footer       = $null               # RAR5: footer não confiável
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "RAR Archive (v5)"
        }
        "GZIP"            = @{
            Category     = "Archive"
            Extension    = ".gz"
            Header       = "1F8B"
            Footer       = $null               # Footer é CRC32+size; parsing necessário
            HeaderOffset = 0
            MaxSize      = 536870912           # 500 MB
            RequireExact = $false
            Description  = "GNU Zip Compressed"
        }
        "BZIP2"           = @{
            Category     = "Archive"
            Extension    = ".bz2"
            Header       = "425A68"            # "BZh"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Bzip2 Compressed"
        }
        "XZ"              = @{
            Category     = "Archive"
            Extension    = ".xz"
            Header       = "FD377A585A00"
            Footer       = "0000000000"        # 5 bytes zero + CRC32
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "XZ Compressed"
        }
        "7ZIP"            = @{
            Category     = "Archive"
            Extension    = ".7z"
            Header       = "377ABCAF271C"
            Footer       = $null               # Estrutura baseada em headers encadeados
            HeaderOffset = 0
            MaxSize      = 5368709120          # 5 GB
            RequireExact = $false
            Description  = "7-Zip Archive"
        }
        "ARJ"             = @{
            Category     = "Archive"
            Extension    = ".arj"
            Header       = "60EA"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "ARJ Archive"
        }
        "LHA"             = @{
            Category     = "Archive"
            Extension    = ".lha"
            Header       = "2D6C68352D"        # "-lh5-"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "LHA Archive"
        }
        "ZOO"             = @{
            Category     = "Archive"
            Extension    = ".zoo"
            Header       = "5A4F4F20"          # "ZOO "
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "ZOO Archive"
        }
        "ACE"             = @{
            Category     = "Archive"
            Extension    = ".ace"
            Header       = "2A2A4143452A2A"    # "**ACE**"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "ACE Archive"
        }
        "CAB"             = @{
            Category     = "Archive"
            Extension    = ".cab"
            Header       = "4D534346"          # "MSCF"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Microsoft Cabinet"
        }
        "UHA"             = @{
            Category     = "Archive"
            Extension    = ".uha"
            Header       = "554841524301"      # "UHARC" + version
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "UHARC Archive"
        }
        "SIT"             = @{
            Category     = "Archive"
            Extension    = ".sit"
            Header       = "53495421"          # "SIT!"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "StuffIt Archive"
        }
        "SITX"            = @{
            Category     = "Archive"
            Extension    = ".sitx"
            Header       = "53495458436F6D70"  # "SITXComp"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "StuffIt X Archive"
        }
        "ARC"             = @{
            Category     = "Archive"
            Extension    = ".arc"
            Header       = "1A070000"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "ARC Archive"
        }
        "TAR"             = @{
            Category     = "Archive"
            Extension    = ".tar"
            Header       = "7573746172"        # "ustar"
            Footer       = $null
            HeaderOffset = 257                  # 0x101
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Tape Archive"
        }

        # ─────────────────────────────────────────────────────────────────
        # ÁUDIO & VÍDEO
        # ─────────────────────────────────────────────────────────────────
        "MP3_ID3v2"       = @{
            Category     = "Audio"
            Extension    = ".mp3"
            Header       = "494433"             # "ID3"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "MP3 with ID3v2 Tag"
        }
        "MP3_FRAME"       = @{
            Category     = "Audio"
            Extension    = ".mp3"
            Header       = "FFF2"               # MPEG-1 Layer 3, 44.1kHz, stereo (comum)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "MP3 Raw Frame Sync"
            Notes        = "Heurística: múltiplos frames válidos consecutivos"
        }
        "MP4"             = @{
            Category     = "Video"
            Extension    = ".mp4"
            Header       = "66747970"           # "ftyp"
            Footer       = $null
            HeaderOffset = 4
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "MPEG-4 Part 14"
        }
        "M4A"             = @{
            Category     = "Audio"
            Extension    = ".m4a"
            Header       = "667479704D3441"    # "ftypM4A"
            Footer       = $null
            HeaderOffset = 4
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "MPEG-4 Audio"
        }
        "M4V"             = @{
            Category     = "Video"
            Extension    = ".m4v"
            Header       = "667479704D3456"    # "ftypM4V"
            Footer       = $null
            HeaderOffset = 4
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "MPEG-4 Video (Apple)"
        }
        "AVI"             = @{
            Category         = "Video"
            Extension        = ".avi"
            Header           = "52494646"           # "RIFF"
            Footer           = $null
            HeaderOffset     = 0
            ValidationBytes  = "41564920"        # "AVI "
            ValidationOffset = 8
            MaxSize          = 2147483648
            RequireExact     = $false
            Description      = "Audio Video Interleave"
        }
        "WAV"             = @{
            Category         = "Audio"
            Extension        = ".wav"
            Header           = "52494646"           # "RIFF"
            Footer           = $null
            HeaderOffset     = 0
            ValidationBytes  = "57415645"        # "WAVE"
            ValidationOffset = 8
            MaxSize          = 536870912
            RequireExact     = $false
            Description      = "Waveform Audio File"
        }
        "FLAC"            = @{
            Category     = "Audio"
            Extension    = ".flac"
            Header       = "664C6143"           # "fLaC"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Free Lossless Audio Codec"
        }
        "OGG"             = @{
            Category     = "Audio"
            Extension    = ".ogg"
            Header       = "4F676753"           # "OggS"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Ogg Vorbis Container"
        }
        "OPUS"            = @{
            Category     = "Audio"
            Extension    = ".opus"
            Header       = "4F70757348656164"  # "OpusHead"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Opus Audio Codec"
        }
        "FLV"             = @{
            Category     = "Video"
            Extension    = ".flv"
            Header       = "464C5601"           # "FLV" + version
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "Flash Video"
        }
        "MKV"             = @{
            Category     = "Video"
            Extension    = ".mkv"
            Header       = "1A45DFA3"           # EBML header
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Matroska Video Container"
        }
        "WEBM"            = @{
            Category     = "Video"
            Extension    = ".webm"
            Header       = "1A45DFA3"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "WebM Video Container"
        }
        "ASF"             = @{
            Category     = "Video"
            Extension    = ".asf"
            Header       = "3026B2758E66CF11A6D900AA0062CE6C"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "Advanced Systems Format (Windows Media)"
        }
        "RMVB"            = @{
            Category     = "Video"
            Extension    = ".rmvb"
            Header       = "2E726D66"           # ".rmf"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "RealMedia Variable Bitrate"
        }
        "MOV"             = @{
            Category     = "Video"
            Extension    = ".mov"
            Header       = "6674797071742020"  # "ftypqt  "
            Footer       = $null
            HeaderOffset = 4
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "QuickTime Movie"
        }
        "MXF"             = @{
            Category     = "Video"
            Extension    = ".mxf"
            Header       = "060E2B34020501010D0102010102"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Material Exchange Format"
        }

        # ─────────────────────────────────────────────────────────────────
        # EXECUTÁVEIS & SISTEMA
        # ─────────────────────────────────────────────────────────────────
        "PE_WIN"          = @{
            Category     = "Executable"
            Extension    = ".exe"              # Cobre .dll, .sys, .efi
            Header       = "4D5A"               # "MZ"
            Footer       = $null               # Motor lê SizeOfImage no OptionalHeader
            HeaderOffset = 0
            MaxSize      = 209715200           # 200 MB
            RequireExact = $false
            Description  = "Portable Executable (Windows)"
        }
        "COM"             = @{
            Category     = "Executable"
            Extension    = ".com"
            Header       = "E90000"            # JMP near (comum em COM)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760            # 10 MB
            RequireExact = $false
            Description  = "DOS COM Executable"
        }
        "DLL"             = @{
            Category     = "Executable"
            Extension    = ".dll"
            Header       = "4D5A"               # "MZ"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Dynamic Link Library (PE)"
        }
        "SYS"             = @{
            Category     = "Executable"
            Extension    = ".sys"
            Header       = "4D5A"               # "MZ"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Windows Driver (PE)"
        }
        "ELF"             = @{
            Category     = "Executable"
            Extension    = ".elf"
            Header       = "7F454C46"           # ".ELF"
            Footer       = $null               # Requer parsing de Section Headers
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Executable and Linkable Format (Linux/Unix)"
        }
        "MACHO"           = @{
            Category     = "Executable"
            Extension    = ".macho"
            Header       = "FEEDFACE"           # 32-bit
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Mach-O (macOS) 32-bit"
        }
        "MACHO_64"        = @{
            Category     = "Executable"
            Extension    = ".macho"
            Header       = "FEEDFACF"           # 64-bit
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Mach-O (macOS) 64-bit"
        }
        "MACHO_FAT"       = @{
            Category     = "Executable"
            Extension    = ".macho"
            Header       = "CAFEBABE"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Mach-O Fat Binary (multi-arch)"
        }
        "DEB"             = @{
            Category     = "Executable"
            Extension    = ".deb"
            Header       = "213C617263683E0A64656269616E"  # "!<arch>\ndebian"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Debian Package"
        }
        "RPM"             = @{
            Category     = "Executable"
            Extension    = ".rpm"
            Header       = "EDABEEDB"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Red Hat Package Manager"
        }
        "MSI"             = @{
            Category     = "Executable"
            Extension    = ".msi"
            Header       = "D0CF11E0"           # OLE2
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Windows Installer Package"
        }
        "AXF"             = @{
            Category     = "Executable"
            Extension    = ".axf"
            Header       = "415846"             # "AXF"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "ARM Executable Format"
        }

        # ─────────────────────────────────────────────────────────────────
        # BANCOS DE DADOS & ESTRUTURAS
        # ─────────────────────────────────────────────────────────────────
        "SQLITE"          = @{
            Category     = "Database"
            Extension    = ".sqlite"
            Header       = "53514C69746520666F726D6174203300"  # "SQLite format 3\0"
            Footer       = $null               # Carving calcula via PageSize * PageCount
            HeaderOffset = 0
            MaxSize      = 10737418240         # 10 GB
            RequireExact = $false
            Description  = "SQLite Database"
        }
        "ACCESS_2000"     = @{
            Category     = "Database"
            Extension    = ".mdb"
            Header       = "000100005374616E64617264204A6574204442"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "Microsoft Access 2000 (Jet DB)"
        }
        "ACCESS_2007"     = @{
            Category         = "Database"
            Extension        = ".accdb"
            Header           = "504B0304"
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "63757272656E742E"  # "current."
            ValidationOffset = 30
            MaxSize          = 2147483648
            RequireExact     = $false
            Description      = "Microsoft Access 2007+ (ACE)"
        }
        "FIREBIRD"        = @{
            Category     = "Database"
            Extension    = ".fdb"
            Header       = "254649524542495244"  # "%FIREBIRD"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Firebird Database"
        }
        "PARADOX"         = @{
            Category     = "Database"
            Extension    = ".db"
            Header       = "600F0100"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Paradox Database"
        }
        "DBF"             = @{
            Category     = "Database"
            Extension    = ".dbf"
            Header       = "03000000"           # dBASE III
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "dBASE/FoxPro Table"
        }
        "MYSQL_FRM"       = @{
            Category     = "Database"
            Extension    = ".frm"
            Header       = "FB617365"           # "ase"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "MySQL Table Definition"
        }
        "REDIS_RDB"       = @{
            Category     = "Database"
            Extension    = ".rdb"
            Header       = "5245444953"         # "REDIS"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Redis Database Dump"
        }
        "MDF"             = @{
            Category     = "Database"
            Extension    = ".mdf"
            Header       = "4D4943524F534F46542053514C20534552564552"  # "MICROSOFT SQL SERVER"
            Footer       = $null
            HeaderOffset = 28                   # 0x1C
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "SQL Server Primary Data File"
        }

        # ─────────────────────────────────────────────────────────────────
        # IMAGENS DE DISCO & VMS
        # ─────────────────────────────────────────────────────────────────
        "VMDK"            = @{
            Category     = "DiskImage"
            Extension    = ".vmdk"
            Header       = "4B444D56"           # "KDMV" (little-endian "VMDK")
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240          # 10 GB
            RequireExact = $false
            Description  = "VMware Virtual Disk"
        }
        "VHD"             = @{
            Category     = "DiskImage"
            Extension    = ".vhd"
            Header       = "636F6E6563746978"  # "conectix"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "Virtual Hard Disk (Legacy)"
        }
        "VHDX"            = @{
            Category     = "DiskImage"
            Extension    = ".vhdx"
            Header       = "7668647866696C65"  # "vhdxfile"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 68719476736         # 64 GB
            RequireExact = $false
            Description  = "Virtual Hard Disk v2"
        }
        "QCOW2"           = @{
            Category     = "DiskImage"
            Extension    = ".qcow2"
            Header       = "514649FB"           # "QFI"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "QEMU Copy-On-Write v2"
        }
        "OVF"             = @{
            Category     = "DiskImage"
            Extension    = ".ovf"
            Header       = "3C3F786D6C"         # "<?xml"
            Footer       = "3C2F456E76656C6F70653E"  # "</Envelope>"
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Open Virtualization Format"
        }
        "ISO9660"         = @{
            Category     = "DiskImage"
            Extension    = ".iso"
            Header       = "4344303031"         # "CD001"
            Footer       = $null
            HeaderOffset = 32769                 # 0x8001
            MaxSize      = 4294967296           # 4 GB (ISO9660 limit)
            RequireExact = $false
            Description  = "ISO 9660 CD/DVD Image"
        }
        "UDF"             = @{
            Category     = "DiskImage"
            Extension    = ".iso"
            Header       = "4245413031"         # "BEA01"
            Footer       = $null
            HeaderOffset = 32768                 # 0x8000
            MaxSize      = 17179869184          # 16 GB
            RequireExact = $false
            Description  = "Universal Disk Format"
        }
        "DMG"             = @{
            Category     = "DiskImage"
            Extension    = ".dmg"
            Header       = "7801730D626260"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "Apple Disk Image"
        }
        "MBR"             = @{
            Category     = "DiskImage"
            Extension    = ".bin"
            Header       = "55AA"
            Footer       = $null
            HeaderOffset = 510                   # 0x1FE
            MaxSize      = 512                   # Setor de boot apenas
            RequireExact = $true
            Description  = "Master Boot Record Signature"
        }
        "GPT_HEADER"      = @{
            Category     = "DiskImage"
            Extension    = ".bin"
            Header       = "4546492050415254"  # "EFI PART"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 512                   # Header GPT é 1 setor
            RequireExact = $true
            Description  = "GUID Partition Table Header"
        }
        "NTFS_BOOT"       = @{
            Category     = "DiskImage"
            Extension    = ".bin"
            Header       = "4E54465320202020"  # "NTFS    "
            Footer       = $null
            HeaderOffset = 3
            MaxSize      = 512
            RequireExact = $true
            Description  = "NTFS Boot Sector"
        }
        "FAT32_BOOT"      = @{
            Category     = "DiskImage"
            Extension    = ".bin"
            Header       = "4641543332202020"  # "FAT32   "
            Footer       = $null
            HeaderOffset = 82                    # 0x52
            MaxSize      = 512
            RequireExact = $true
            Description  = "FAT32 Boot Sector"
        }
        "EXT4_SUPER"      = @{
            Category     = "DiskImage"
            Extension    = ".bin"
            Header       = "53EF"
            Footer       = $null
            HeaderOffset = 1080                  # 0x438
            MaxSize      = 1024                  # Superblock EXT4
            RequireExact = $true
            Description  = "EXT4 Superblock Magic"
        }
        "APFS_CONT"       = @{
            Category     = "DiskImage"
            Extension    = ".bin"
            Header       = "4E585342"           # "NXSB"
            Footer       = $null
            HeaderOffset = 32                    # 0x20
            MaxSize      = 4096                  # Container header APFS
            RequireExact = $true
            Description  = "APFS Container Signature"
        }

        # ─────────────────────────────────────────────────────────────────
        # LOGS, EMAILS & DADOS FORENSES
        # ─────────────────────────────────────────────────────────────────
        "PST"             = @{
            Category     = "Forensic"
            Extension    = ".pst"
            Header       = "2142444E"            # "!BDN"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Outlook Personal Storage Table"
        }
        "OST"             = @{
            Category     = "Forensic"
            Extension    = ".ost"
            Header       = "2142444E"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Outlook Offline Storage Table"
        }
        "MSG"             = @{
            Category     = "Forensic"
            Extension    = ".msg"
            Header       = "D0CF11E0"            # OLE2
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Outlook Message File"
        }
        "EML"             = @{
            Category     = "Forensic"
            Extension    = ".eml"
            Header       = "52656365697665643A2066726F6D"  # "Received: from"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Email Message (RFC822)"
        }
        "MBOX"            = @{
            Category     = "Forensic"
            Extension    = ".mbox"
            Header       = "46726F6D20"          # "From "
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Unix Mailbox Format"
        }
        "EVENTLOG"        = @{
            Category     = "Forensic"
            Extension    = ".evt"
            Header       = "456C6646696C65"     # "ElFFile"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Windows Event Log (Legacy)"
        }
        "REGISTRY"        = @{
            Category     = "Forensic"
            Extension    = ".reg"
            Header       = "72656766"            # "regf"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Windows Registry Hive"
        }
        "PREFETCH"        = @{
            Category     = "Forensic"
            Extension    = ".pf"
            Header       = "53434341"            # "SCCA"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Windows Prefetch File"
        }
        "IIS_LOG"         = @{
            Category     = "Forensic"
            Extension    = ".log"
            Header       = "23536F6674776172653A204D6963726F736F667420496E7465726E657420496E666F726D6174696F6E205365727669636573"  # "#Software: Microsoft Internet Information Services"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "IIS Log File"
        }
        "DMP"             = @{
            Category     = "Forensic"
            Extension    = ".dmp"
            Header       = "5041474544554D50"  # "PAGEDUMP"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 17179869184          # 16 GB
            RequireExact = $false
            Description  = "Windows Memory Dump"
        }
        "CORE_DUMP"       = @{
            Category     = "Forensic"
            Extension    = ".core"
            Header       = "7F454C46020101000000000000000000"  # ELF 64-bit
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 17179869184
            RequireExact = $false
            Description  = "Linux Core Dump"
        }
        "RAW_MEM"         = @{
            Category     = "Forensic"
            Extension    = ".raw"
            Header       = "4C696E7578"         # "Linux"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 68719476736          # 64 GB
            RequireExact = $false
            Description  = "Raw Memory Capture"
        }

        # ─────────────────────────────────────────────────────────────────
        # FONTES
        # ─────────────────────────────────────────────────────────────────
        "TTF"             = @{
            Category     = "Font"
            Extension    = ".ttf"
            Header       = "0001000000"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "TrueType Font"
        }
        "OTF"             = @{
            Category     = "Font"
            Extension    = ".otf"
            Header       = "4F54544F"           # "OTTO"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "OpenType Font"
        }
        "WOFF"            = @{
            Category     = "Font"
            Extension    = ".woff"
            Header       = "774F4646"           # "wOFF"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 20971520
            RequireExact = $false
            Description  = "Web Open Font Format"
        }
        "WOFF2"           = @{
            Category     = "Font"
            Extension    = ".woff2"
            Header       = "774F4632"           # "wOF2"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 20971520
            RequireExact = $false
            Description  = "Web Open Font Format 2"
        }
        "PFB"             = @{
            Category     = "Font"
            Extension    = ".pfb"
            Header       = "8001"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 20971520
            RequireExact = $false
            Description  = "PostScript Font Binary"
        }

        # ─────────────────────────────────────────────────────────────────
        # GEORREFERÊNCIA & CAD
        # ─────────────────────────────────────────────────────────────────
        "SHP"             = @{
            Category     = "Geo"
            Extension    = ".shp"
            Header       = "0000270A"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "ESRI Shapefile"
        }
        "DWG"             = @{
            Category     = "CAD"
            Extension    = ".dwg"
            Header       = "41433130"           # "AC10"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "AutoCAD Drawing"
        }
        "DXF"             = @{
            Category     = "CAD"
            Extension    = ".dxf"
            Header       = "484541444552"       # "HEADER"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Drawing Exchange Format"
        }
        "GPX"             = @{
            Category     = "Geo"
            Extension    = ".gpx"
            Header       = "3C3F786D6C"         # "<?xml"
            Footer       = "3C2F6770783E"        # "</gpx>"
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "GPS Exchange Format"
        }
        "KML"             = @{
            Category     = "Geo"
            Extension    = ".kml"
            Header       = "6B6D6C"              # "kml"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "Keyhole Markup Language"
        }

        # ─────────────────────────────────────────────────────────────────
        # CERTIFICADOS & CHAVES
        # ─────────────────────────────────────────────────────────────────
        "PEM"             = @{
            Category     = "Crypto"
            Extension    = ".pem"
            Header       = "2D2D2D2D2D424547494E"  # "-----BEGIN"
            Footer       = "2D2D2D2D2D454E44"      # "-----END"
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Privacy-Enhanced Mail (Base64)"
        }
        "DER"             = @{
            Category     = "Crypto"
            Extension    = ".der"
            Header       = "3082"                 # ASN.1 SEQUENCE
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Distinguished Encoding Rules (Binary)"
        }
        "PKCS7"           = @{
            Category     = "Crypto"
            Extension    = ".p7b"
            Header       = "30823082"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "PKCS#7 Signed Data"
        }
        "PKCS12"          = @{
            Category     = "Crypto"
            Extension    = ".p12"
            Header       = "3084"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "PKCS#12 Personal Information Exchange"
        }
        "JKS"             = @{
            Category     = "Crypto"
            Extension    = ".jks"
            Header       = "FEEDFEED"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Java KeyStore"
        }
        "BKS"             = @{
            Category     = "Crypto"
            Extension    = ".bks"
            Header       = "424B5300"            # "BKS" + null
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "Bouncy Castle KeyStore"
        }
        "GPG"             = @{
            Category     = "Crypto"
            Extension    = ".gpg"
            Header       = "9901000D04"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "GnuPG Encrypted/ Signed"
        }
        "OPENSSH_PRIV"    = @{
            Category     = "Crypto"
            Extension    = ".key"
            Header       = "6F70656E7373682D6B6579"  # "openssh-key"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "OpenSSH Private Key"
        }

        # ─────────────────────────────────────────────────────────────────
        # CONTÊINERS CRIPTOGRÁFICOS
        # ─────────────────────────────────────────────────────────────────
        "VERA_CRYPT"      = @{
            Category     = "Crypto"
            Extension    = ".vc"
            Header       = "56455241"            # "VERA"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "VeraCrypt Volume Header"
        }
        "TRUE_CRYPT"      = @{
            Category     = "Crypto"
            Extension    = ".tc"
            Header       = "54525545"            # "TRUE"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "TrueCrypt Volume Header"
        }
        "LUKS_HEADER"     = @{
            Category     = "Crypto"
            Extension    = ".luks"
            Header       = "4C554B53BABE"       # "LUKS\xba\xbe" (Magic LUKS1)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "Linux Unified Key Setup"
        }

        # ─────────────────────────────────────────────────────────────────
        # BINÁRIOS GENÉRICOS & FIRMWARE
        # ─────────────────────────────────────────────────────────────────
        "UEFI_APP"        = @{
            Category     = "Firmware"
            Extension    = ".efi"
            Header       = "4D5A9000"            # MZ + stub
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Description  = "UEFI Application"
        }
        "EFI_IMG"         = @{
            Category     = "Firmware"
            Extension    = ".img"
            Header       = "4546492050415254"  # "EFI PART"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "EFI System Partition Image"
        }
        "RAW_BIN"         = @{
            Category     = "Firmware"
            Extension    = ".bin"
            Header       = "0000000000000000"  # 8 bytes zero (heurística)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Heuristic    = "low_entropy"
            Description  = "Raw Binary (Heuristic Detection)"
        }
        "BOOT_SECTOR"     = @{
            Category     = "Firmware"
            Extension    = ".bin"
            Header       = "55AA"
            Footer       = $null
            HeaderOffset = 510
            MaxSize      = 512
            RequireExact = $true
            Description  = "Generic Boot Sector Signature"
        }
        "INTEL_HEX"       = @{
            Category     = "Firmware"
            Extension    = ".hex"
            Header       = "3A3130"              # ":10"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Intel HEX Format"
        }
        "MOTOROLA_SREC"   = @{
            Category     = "Firmware"
            Extension    = ".s19"
            Header       = "5330"                # "S0"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Motorola S-Record"
        }
        "FIRMWARE_TRX"    = @{
            Category     = "Firmware"
            Extension    = ".trx"
            Header       = "48445230"            # "HDR0"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 67108864              # 64 MB
            RequireExact = $false
            Description  = "Broadcom TRX Firmware"
        }
        "FIRMWARE_BIN"    = @{
            Category     = "Firmware"
            Extension    = ".bin"
            Header       = "42494E465752"       # "BINFWR"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 67108864
            RequireExact = $false
            Description  = "Generic Firmware Blob"
        }

        # ─────────────────────────────────────────────────────────────────
        # SCRIPTS INTERPRETADOS
        # ─────────────────────────────────────────────────────────────────
        "BASH_SCRIPT"     = @{
            Category     = "Script"
            Extension    = ".sh"
            Header       = "23212F62696E2F62617368"  # "#!/bin/bash"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Bash Shell Script"
        }
        "SH_SCRIPT"       = @{
            Category     = "Script"
            Extension    = ".sh"
            Header       = "23212F62696E2F7368"  # "#!/bin/sh"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "POSIX Shell Script"
        }
        "PYTHON_SCRIPT"   = @{
            Category     = "Script"
            Extension    = ".py"
            Header       = "23212F7573722F62696E2F656E7620707974686F6E"  # "#!/usr/bin/env python"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Python Script"
        }
        "PERL_SCRIPT"     = @{
            Category     = "Script"
            Extension    = ".pl"
            Header       = "23212F7573722F62696E2F7065726C"  # "#!/usr/bin/perl"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Perl Script"
        }
        "RUBY_SCRIPT"     = @{
            Category     = "Script"
            Extension    = ".rb"
            Header       = "23212F7573722F62696E2F72756279"  # "#!/usr/bin/ruby"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Ruby Script"
        }
        "PS1_SCRIPT"      = @{
            Category     = "Script"
            Extension    = ".ps1"
            Header       = "3C235053536372697074496E666F"  # "<#PSScriptInfo"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "PowerShell Script"
        }
        "VBS_SCRIPT"      = @{
            Category     = "Script"
            Extension    = ".vbs"
            Header       = "5642536372697074"    # "VBScript"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "VBScript File"
        }
        "JS_SCRIPT"       = @{
            Category     = "Script"
            Extension    = ".js"
            Header       = "23212F7573722F62696E2F6E6F6465"  # "#!/usr/bin/node"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "Node.js Script"
        }
        "PHP_SCRIPT"      = @{
            Category     = "Script"
            Extension    = ".php"
            Header       = "3C3F706870"          # "<?php"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "PHP Script"
        }

        # ─────────────────────────────────────────────────────────────────
        # BINÁRIOS COMPILADOS/INTERMEDIÁRIOS
        # ─────────────────────────────────────────────────────────────────
        "JAR_MAGIC"       = @{
            Category         = "Compiled"
            Extension        = ".jar"
            Header           = "504B0304"            # ZIP
            Footer           = "504B0506"
            HeaderOffset     = 0
            ValidationBytes  = "4D4554412D494E46"  # "META-INF"
            ValidationOffset = 30
            MaxSize          = 536870912
            RequireExact     = $false
            Description      = "Java Archive"
        }
        "WASM"            = @{
            Category     = "Compiled"
            Extension    = ".wasm"
            Header       = "0061736D"            # "\0asm"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "WebAssembly Binary/Module"
        }
        "LLVM_BITCODE"    = @{
            Category     = "Compiled"
            Extension    = ".bc"
            Header       = "4243C0DE"            # "BC"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "LLVM Bitcode"
        }
        "GO_OBJ"          = @{
            Category     = "Compiled"
            Extension    = ".o"
            Header       = "474F20312E3136"     # "GO 1.16"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Go Object File"
        }
        "RUST_LIB"        = @{
            Category     = "Compiled"
            Extension    = ".rlib"
            Header       = "727573742F"          # "rust/"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Rust Library"
        }
        # ─────────────────────────────────────────────────────────────────
        # ARTEFATOS WINDOWS & METADADOS
        # ─────────────────────────────────────────────────────────────────
        "LNK_FILE"        = @{
            Category     = "Forensic"
            Extension    = ".lnk"
            Header       = "4C00000001140200"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 4096
            RequireExact = $false
            Description  = "Windows Shell Link (Shortcut)"
        }
        "JUMPLIST"        = @{
            Category     = "Forensic"
            Extension    = ".automaticDestinations-ms"
            Header       = "FF09000000000000"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1048576
            RequireExact = $false
            Description  = "Windows 7+ JumpList (Compound Doc)"
        }
        "EVTX_LOG"        = @{
            Category     = "Forensic"
            Extension    = ".evtx"
            Header       = "456C6646696C6500"  # "ElFFile\0"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Windows Event Log (XML/Chunked)"
        }
        "REG_HIVE"        = @{
            Category     = "Forensic"
            Extension    = ".dat"
            Header       = "72656766"            # "regf"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Windows Registry Hive"
        }
        "THUMBCACHE"      = @{
            Category     = "Forensic"
            Extension    = ".db"
            Header       = "4344303030303031"  # "CD000001"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Windows Thumbnail Cache (DB)"
        }
        "USN_JOURNAL"     = @{
            Category     = "Forensic"
            Extension    = ".bin"
            Header       = "55534E"             # "USN"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "NTFS Update Sequence Number Journal"
        }
        "NTFS_LOGFILE"    = @{
            Category     = "Forensic"
            Extension    = ".bin"
            Header       = "52535452"           # "RSTR"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "NTFS Transaction Log"
        }

        # ─────────────────────────────────────────────────────────────────
        # ARTEFATOS MACOS & APPLE
        # ─────────────────────────────────────────────────────────────────
        "PLIST_BINARY"    = @{
            Category     = "Forensic"
            Extension    = ".plist"
            Header       = "62706C6973743030"  # "bplist00"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "macOS Binary Property List"
        }
        "DS_STORE"        = @{
            Category     = "Forensic"
            Extension    = ".DS_Store"
            Header       = "0000000100001000"  # Bud1 header
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "macOS Folder Metadata"
        }
        "FSEVENTS"        = @{
            Category     = "Forensic"
            Extension    = ".fseventsd"
            Header       = "46534576"           # "FSEv"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "macOS File System Events Log"
        }
        "KEYCHAIN_DB"     = @{
            Category     = "Forensic"
            Extension    = ".keychain-db"
            Header       = "6B6579636861"      # "keycha"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "macOS Keychain 2.0 Database"
        }
        "SPOTLIGHT_STORE" = @{
            Category     = "Forensic"
            Extension    = ".store"
            Header       = "53706F74"           # "Spot"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "macOS Spotlight Metadata Store"
        }
        "TIME_MACHINE"    = @{
            Category     = "Forensic"
            Extension    = ".sparsebundle"
            Header       = "7801730D626260"    # SparseImage header
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "macOS Time Machine Backup Bundle"
        }

        # ─────────────────────────────────────────────────────────────────
        # ARTEFATOS LINUX & UNIX
        # ─────────────────────────────────────────────────────────────────
        "JOURNALD"        = @{
            Category     = "Forensic"
            Extension    = ".journal"
            Header       = "4C50"               # "LP" (Little Endian)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "systemd Journal (mmap binary)"
        }
        "APT_ARCHIVE"     = @{
            Category     = "Forensic"
            Extension    = ".deb"
            Header       = "213C617263683E0A"  # "!<arch>\n"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Debian Package (ar archive)"
        }
        "BASH_HISTORY"    = @{
            Category     = "Forensic"
            Extension    = ".bash_history"
            Header       = "23212F62696E2F62617368"  # "#!/bin/bash" (optional)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Heuristic    = "text_lines"
            Description  = "Bash Command History (Text)"
        }
        "ZSH_HISTORY"     = @{
            Category     = "Forensic"
            Extension    = ".zsh_history"
            Header       = "3A20"               # ": " (zsh format prefix)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Heuristic    = "text_lines"
            Description  = "Zsh Command History"
        }
        "CRONTAB"         = @{
            Category     = "Forensic"
            Extension    = ".crontab"
            Header       = "2320"               # "# "
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1048576
            RequireExact = $false
            Heuristic    = "text_lines"
            Description  = "Cron Job Definition"
        }

        # ─────────────────────────────────────────────────────────────────
        # IMAGENS FORENSES & BACKUP MODERNO
        # ─────────────────────────────────────────────────────────────────
        "E01_ENCASE"      = @{
            Category     = "ForensicImage"
            Extension    = ".E01"
            Header       = "45564632"           # "EVF2"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "EnCase Forensic Image v2"
        }
        "AFF4_CONTAINER"  = @{
            Category     = "ForensicImage"
            Extension    = ".aff4"
            Header       = "414634"             # "AF4"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10737418240
            RequireExact = $false
            Description  = "Advanced Forensics Format v4"
        }
        "ZSTD_COMPRESS"   = @{
            Category     = "Archive"
            Extension    = ".zst"
            Header       = "28B52FFD"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Zstandard Compressed"
        }
        "LZ4_COMPRESS"    = @{
            Category     = "Archive"
            Extension    = ".lz4"
            Header       = "04224D18"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "LZ4 Compressed"
        }
        "NRG_IMAGE"       = @{
            Category     = "DiskImage"
            Extension    = ".nrg"
            Header       = "4E45524F"           # "NERO"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 4294967296
            RequireExact = $false
            Description  = "Nero Burning ROM Image"
        }
        "CCD_IMAGE"       = @{
            Category     = "DiskImage"
            Extension    = ".ccd"
            Header       = "5B434C4F4E45444953435D"  # "[CloneDisc]"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Description  = "CloneCD Control File"
        }

        # ─────────────────────────────────────────────────────────────────
        # MOBILE, DEV & MODERN COMPILADOS
        # ─────────────────────────────────────────────────────────────────
        "JAVA_CLASS"      = @{
            Category     = "Compiled"
            Extension    = ".class"
            Header       = "CAFEBABE"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Java Virtual Machine Bytecode"
        }
        "DEX_ANDROID"     = @{
            Category     = "Compiled"
            Extension    = ".dex"
            Header       = "6465780A30333500"  # "dex\n035\0"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Dalvik Executable (Android)"
        }
        "ODEX_ANDROID"    = @{
            Category     = "Compiled"
            Extension    = ".odex"
            Header       = "646579"             # "dey"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Optimized Dalvik Executable"
        }
        "ART_ANDROID"     = @{
            Category     = "Compiled"
            Extension    = ".art"
            Header       = "61727400"           # "art\0"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 209715200
            RequireExact = $false
            Description  = "Android Runtime Compiled"
        }
        "PYC_BYTECODE"    = @{
            Category     = "Compiled"
            Extension    = ".pyc"
            Header       = "03F30D0A"           # Python 3.7+ magic (varia por versão)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Heuristic    = "pyc_version"
            Description  = "Python Compiled Bytecode"
        }
        "PROTOBUF_RAW"    = @{
            Category     = "Compiled"
            Extension    = ".pb"
            Header       = "080112"             # Common proto start (varia)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Heuristic    = "varint_scan"
            Description  = "Protocol Buffers (Heuristic)"
        }

        # ─────────────────────────────────────────────────────────────────
        # DADOS ESTRUTURADOS & WEB
        # ─────────────────────────────────────────────────────────────────
        "JSON_DATA"       = @{
            Category     = "Data"
            Extension    = ".json"
            Header       = "7B"                 # "{"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Heuristic    = "json_parse"
            Description  = "JavaScript Object Notation"
        }
        "XML_DATA"        = @{
            Category     = "Data"
            Extension    = ".xml"
            Header       = "3C3F786D6C"         # "<?xml"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Description  = "Extensible Markup Language"
        }
        "YAML_DATA"       = @{
            Category     = "Data"
            Extension    = ".yaml"
            Header       = "2D2D2D"             # "---"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 104857600
            RequireExact = $false
            Heuristic    = "yaml_indent"
            Description  = "YAML Ain't Markup Language"
        }
        "CSV_DATA"        = @{
            Category     = "Data"
            Extension    = ".csv"
            Header       = "22"                 # """ (optional quote)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 536870912
            RequireExact = $false
            Heuristic    = "comma_tab_lines"
            Description  = "Comma-Separated Values"
        }
        "MARKDOWN"        = @{
            Category     = "Data"
            Extension    = ".md"
            Header       = "2320"               # "# "
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 52428800
            RequireExact = $false
            Heuristic    = "md_syntax"
            Description  = "Markdown Document"
        }
        "GIT_PACK"        = @{
            Category     = "Data"
            Extension    = ".pack"
            Header       = "5041434B"           # "PACK"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 2147483648
            RequireExact = $false
            Description  = "Git Object Pack"
        }
        "DOCKER_LAYER"    = @{
            Category     = "Data"
            Extension    = ".layer"
            Header       = "1F8B"               # GZIP (Docker layers)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 5368709120
            RequireExact = $false
            Description  = "Docker/Container Layer Tarball"
        }

        # ─────────────────────────────────────────────────────────────────
        # METADATA & ESTRUTURAS DE FS CARVABLES
        # ─────────────────────────────────────────────────────────────────
        "FAT_FSINFO"      = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "52526141"           # "RRaA"
            Footer       = $null
            HeaderOffset = 484                   # 0x1E4
            MaxSize      = 512
            RequireExact = $true
            Description  = "FAT32 FSINFO Sector"
        }
        "EXT_JOURNAL"     = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "C03B3991"           # JBD Magic
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1073741824
            RequireExact = $false
            Description  = "EXT2/3/4 Filesystem Journal"
        }
        "BTRFS_CSUM"      = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "42545266535F4D"     # "BTRfS_M" (partial)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1073741824
            RequireExact = $false
            Description  = "BTRFS Checksum Tree Node"
        }
        "ZFS_UBERBLOCK"   = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "00BAB10C"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1048576
            RequireExact = $false
            Description  = "ZFS Uberblock (Transaction Point)"
        }
        "XFS_INODE"       = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "494E"               # "IN" (partial inode magic)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "XFS Inode Block"
        }
        "HFS_CATALOG"     = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "42756431"           # "Bud1"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1073741824
            RequireExact = $false
            Description  = "HFS+ Catalog File"
        }
        "APFS_OBJECT_MAP" = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "4E585342"           # "NXSB" (reused for container map)
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 10485760
            RequireExact = $false
            Description  = "APFS Object Map / Checkpoint"
        }
        "REFS_INTEGRITY"  = @{
            Category     = "FSMetadata"
            Extension    = ".bin"
            Header       = "53664552"           # "fReS"
            Footer       = $null
            HeaderOffset = 0
            MaxSize      = 1073741824
            RequireExact = $false
            Description  = "ReFS Integrity Stream Header"
        }
    }
}
