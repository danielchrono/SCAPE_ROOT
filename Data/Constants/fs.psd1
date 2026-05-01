@{
    Segment = @{
        Name = "fs"
        Version = "1.0.0"
        Description = "Filesystem signatures, offsets, structural constants, and field definitions for forensic parsing"
        Dependencies = @("core")
        HashSHA256 = "PLACEHOLDER_FS_HASH"
    }

    FS = @{
        # =====================================================================
        # GLOBAL / COMMON
        # =====================================================================
        SECTOR_SIZE         = 512
        BLOCK_SIZE          = 4096
        CLUSTER_SIZES       = @(512, 1024, 2048, 4096, 8192, 16384, 32768, 65536)
        ROOT_DIR_ID         = 5
        CLUSTER_DEFAULT     = 4096
        UNKNOWN_FS_SIG_LEN  = 8
        UNKNOWN_FS_PROBE_LEN = 16384

        # =====================================================================
        # NTFS
        # =====================================================================
        NTFS = @{
            # Signatures & Sizes
            MFT_SIG          = 0x454C4946          # "FILE"
            MFT_SIZE         = 1024
            MFT_REC_SIZE     = 1024
            FILE_REC_SIZE    = 1024
            ALIGN            = 512

            # Boot Sector Offsets
            BOOT_MFT_OFF     = 0x30
            BOOT_CLS_OFF     = 0x0B
            BOOT_SPC_OFF     = 0x0D
            BOOT_OEM_OFF     = 0x03
            BOOT_OEM_LEN     = 8

            # MFT Record Field Offsets (from record start)
            MFT_USA_OFF_OFF  = 4                   # Offset to Update Sequence Array offset
            MFT_USA_CNT_OFF  = 6                   # Update Sequence Array count
            MFT_LSN_OFF      = 8                   # Log File Sequence Number
            MFT_SEQ_OFF      = 16                  # Sequence number
            MFT_FRN_OFF      = 44                  # File Reference Number (low 48 bits)
            MFT_ATTR_OFF_OFF = 20                  # Offset to first attribute
            MFT_FLAGS_OFF    = 22                  # Flags (incl. deleted flag)

            # Attribute Types
            ATTR_NAME        = 0x30                # $FILE_NAME
            ATTR_DATA        = 0x80                # $DATA
            ATTR_SECURITY    = 0x50                # $SECURITY_DESCRIPTOR
            ATTR_END         = 0xFFFFFFFF

            # Attribute Field Offsets (relative to attribute header)
            ATTR_TYPE_OFF    = 0
            ATTR_LEN_OFF     = 4
            ATTR_NONRES_OFF  = 8
            ATTR_NAMELEN_OFF = 16
            ATTR_NAMEOFF_OFF = 18
            ATTR_FLAGS_OFF   = 24
            ATTR_DATA_SIZE_OFF = 24                # For resident: size; non-resident: VCN
            ATTR_DATA_RUNOFF_OFF = 32              # Runlist offset for non-resident

            # Masks & Constants
            FRN_MASK         = 0x0000FFFFFFFFFFFF  # Mask to extract FRN from file reference
        }

        # =====================================================================
        # FAT / exFAT
        # =====================================================================
        FAT = @{
            DIR_SIZE         = 32
            DEL_SIG          = 0xE5
            BOOT_SIG         = 0xAA55

            # FAT32 Boot Sector Offsets
            FAT32_FAT_OFFSET = 0x24                # Offset to FAT size field
            FAT32_ROOT_CLS_OFF = 0x2C              # Root directory start cluster
            FAT32_FSINFO_OFF = 0x1E4               # FSINFO sector offset

            # Directory Entry Field Offsets (32-byte entry)
            DIR_NAME_OFF     = 0                   # 8.3 name (8+3 bytes)
            DIR_ATTR_OFF     = 0xB                 # Attributes byte
            DIR_TIME_OFF     = 0x16                # Last write time (DOS packed)
            DIR_DATE_OFF     = 0x18                # Last write date (DOS packed)
            DIR_STARTCLU_OFF = 0x1A                # Start cluster (low word)
            DIR_SIZE_OFF     = 0x1C                # File size (32-bit)

            # exFAT
            EXFAT_FILE_SIG   = 0x85                # File directory entry type
            EXFAT_STRM_SIG   = 0xC0                # Stream extension entry type
            EXFAT_VBR_SIG    = 0x4558464154202020  # "EXFAT   "
            EXFAT_CLUST_SIZE = 0x4000
            EXFAT_DIR_SIZE   = 32

            # exFAT Stream Extension Field Offsets (relative to entry start)
            EXFAT_FLAGS_OFF  = 1
            EXFAT_NAMELEN_OFF= 2
            EXFAT_NAMEHASH_OFF=4
            EXFAT_VALIDLEN_OFF=8
            EXFAT_ALLOCLEN_OFF=12
            EXFAT_FIRSTCLU_OFF=16
        }

        # =====================================================================
        # EXT Family (EXT2/3/4)
        # =====================================================================
        EXT = @{
            # Signatures
            SIG              = 0xEF53              # Common to EXT2/3/4
            EXT2_SIG         = 0xEF53
            EXT3_SIG         = 0xEF53
            EXT4_SIG         = 0xF30A              # EXT4-specific feature flag

            # Superblock Offsets (from start of superblock at 0x438)
            SB_OFFSET        = 0x38                # Offset to superblock within block group
            SB_OFFSET_HEX    = 0x438               # Absolute offset in sector 1
            MAGIC_OFF        = 0x438               # Magic number offset (16-bit)
            INODE_SIZE       = 256
            BLOCK_GROUP_DESC = 0x20                # Size of group descriptor

            # Superblock Field Offsets (relative to superblock start)
            SB_INODES_OFF    = 0x00                # Total inodes (32-bit)
            SB_BLOCKS_OFF    = 0x04                # Total blocks (32-bit)
            SB_INODE_SIZE_OFF = 0x58               # Inode size (16-bit)
            SB_FEATURES_OFF  = 0x60                # Feature flags (32-bit)

            # Inode Field Offsets (relative to inode start)
            INODE_MODE_OFF   = 0                   # File mode (16-bit)
            INODE_UID_OFF    = 4                   # Owner UID (32-bit)
            INODE_SIZE_LOW_OFF = 8                 # File size low (32-bit)
            INODE_SIZE_HIGH_OFF = 12               # File size high (32-bit, EXT4)
            INODE_ATIME_OFF  = 16                  # Last access time (32-bit epoch)
            INODE_MTIME_OFF  = 20                  # Last modification time
            INODE_CTIME_OFF  = 24                  # Last status change time
            INODE_LINKS_OFF  = 28                  # Hard link count (16-bit)
            INODE_BLOCKS_OFF = 32                  # Blocks allocated (32-bit)
            INODE_FLAGS_OFF  = 48                  # Flags (32-bit)
            INODE_PTRS_START = 40                  # Block pointers start (12 direct + indirect)
        }

        # =====================================================================
        # BTRFS
        # =====================================================================
        BTRFS = @{
            SB_SIG           = 0x5F42485266535F4D  # "_BHRfS_M"
            SB_OFFSET        = 0x40                # Superblock offset within device
            SB_OFF_HEX       = 0x10040             # Absolute offset for detection
            NODE_SIZE        = 16384
            CHUNK_TYPE       = 0x3C
            MIRROR_TYPE      = 0x3D

            # Superblock Field Offsets (relative to superblock start)
            SB_UUID_OFF      = 0x20                # Filesystem UUID (16 bytes)
            SB_FSID_OFF      = 0x18                # Filesystem FSID (16 bytes)
            SB_CSUMTYPE_OFF  = 0x68                # Checksum type (1 byte)
            SB_NODESIZE_OFF  = 0x2C                # Node size (32-bit)
            SB_SECTORSIZE_OFF= 0x30                # Sector size (32-bit)
            SB_TOTALBYTES_OFF= 0x38                # Total filesystem size (64-bit)
            SB_ROOTDIR_OFF   = 0x48                # Root directory object ID (64-bit)
            SB_GENERATION_OFF= 0x50                # Transaction generation (64-bit)
            SB_CHUNKROOT_OFF = 0x58                # Chunk tree root generation (64-bit)
            SB_ROOTLEVEL_OFF = 0x60                # Root tree level (1 byte)
        }

        # =====================================================================
        # XFS
        # =====================================================================
        XFS = @{
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
        ZFS = @{
            LABEL_SIG        = 0x2F5A42534F4C5953  # "/ZBSOLYS"
            UBER_SIG         = 0x00BAB10C
            UBER_SIZE        = 512
            MIN_TXG_OFF      = 0x08                # Transaction group offset in uberblock
            VDEV_OFFSET      = 0x1000              # Typical vdev label offset
            GUID_OFF_HEX     = 0x40                # GUID offset in label

            # Uberblock Field Offsets (relative to uberblock start)
            UBER_TXG_OFF     = 0x08                # Transaction group (64-bit LE)
            UBER_TIMESTAMP_OFF=0x10                # Timestamp (64-bit LE)
            UBER_ROOTBP_OFF  = 0x20                # Root block pointer (64-bit LE)
        }

        # =====================================================================
        # APFS
        # =====================================================================
        APFS = @{
            SB_SIG           = 0x4E585342          # "NXSB"
            BLOCK_SIZE       = 4096
            MAGIC_OFF        = 0x20                # Alias for compatibility
            MAGIC_OFFSET     = 0x20                # Magic number offset in container header
            VOL_SIG          = 0x41504653          # "APFS"
            CHECKPOINT_OFF   = 0x1000
            SERIAL_OFF       = 0x48

            # Container Superblock Field Offsets (relative to magic offset)
            SB_BLOCKSIZE_OFF = 0x04                # Block size (32-bit LE)
            SB_CONTAINERSIZE_OFF=0x08              # Container size (64-bit LE)
            SB_VERSION_OFF   = 0x10                # NX version (32-bit LE)
            SB_CHECKPOINT_DESC_OFF=0x58            # Checkpoint descriptor address (64-bit LE)
        }

        # =====================================================================
        # ReFS
        # =====================================================================
        REFS = @{
            SIG              = 0x53664552          # "fReS" (little-endian)
            VBR_OEM_ID       = "ReFS   "
            CLUSTER_SIZE     = 65536
            METADATA_SIZE    = 4096
            SUPERBLOCK_OFF   = 0
            CHECKPOINT_OFF   = 0x2000
            CONTAINER_ID_OFF = 0x28
            BLOCK_SIZE       = 4096

            # Superblock Field Offsets (relative to superblock start)
            SB_VERSION_MAJOR_OFF = 0x08            # Major version (32-bit LE)
            SB_VERSION_MINOR_OFF = 0x0C            # Minor version (32-bit LE)
            SB_CLUSTERSIZE_OFF = 0x14              # Cluster size (32-bit LE)
            SB_VOLUMESIZE_OFF = 0x18               # Volume size in clusters (64-bit LE)
            SB_METADATASIZE_OFF = 0x28             # Metadata size (64-bit LE)
            SB_ROOTFILEREFF_OFF = 0x60             # Root file reference (64-bit LE)
        }

        # =====================================================================
        # HFS / HFS+ / HFSX
        # =====================================================================
        HFS = @{
            SIG              = 0x4244              # "BD" (HFS)
            PLUS_SIG         = 0x484B              # "H+" (HFS+)
            HFSX_SIG         = 0x482B              # "H+" (HFSX)
            VOLUME_HEADER_OFF= 1024                # Volume header offset in bytes
            ALLOC_FILE       = 0x00000003
            EXTENTS_FILE     = 0x00000004
            CATALOG_FILE     = 0x00000005
            ATTRIBUTES_FILE  = 0x00000006
            STARTUP_FILE     = 0x00000007
            BLOCK_SIZE       = 4096
            NODE_SIZE        = 8192
            LEAF_NODE_RECORD = 0x00
            INDEX_NODE_RECORD= 0x01
            HEADER_UNIQUENESS= 0x3A2C4D1E

            # Volume Header Field Offsets (relative to volume header start)
            VH_SIGNATURE_OFF = 0x00                # Signature (16-bit)
            VH_BLOCKSIZE_OFF = 0x0C                # Block size (16-bit HFS, 32-bit HFS+)
            VH_TOTALBLOCKS_OFF=0x10                # Total blocks (32-bit)
            VH_ROOTDIR_OFF   = 0x14                # Root directory CNID (32-bit)
            VH_VOLNAME_OFF   = 0x2C                # Volume name (32 bytes ASCII)
        }

        # =====================================================================
        # F2FS
        # =====================================================================
        F2FS = @{
            SB_SIG           = 0xF2F52010
            BLOCK_SIZE       = 4096
            CP_OFF           = 0x2000              # Checkpoint offset

            # Superblock Field Offsets (at offset 0x400 within device)
            SB_BLOCKSIZE_OFF = 0x0C                # Block size (32-bit LE)
            SB_TOTALSECTORS_OFF=0x18               # Total sectors (64-bit LE)
            SB_ROOTINO_OFF   = 0x48                # Root inode number (32-bit LE)
            SB_SEGMENTCNT_OFF= 0x58                # Segment count (32-bit LE)
        }

        # =====================================================================
        # JFS
        # =====================================================================
        JFS = @{
            SUPER_SIG        = 0x315F4A46          # "JFS1" (ASCII)
            BLOCK_SIZE       = 4096

            # Superblock Field Offsets (relative to superblock start)
            SB_BLOCKSIZE_OFF = 0x08                # Block size (32-bit LE)
            SB_TOTALBLOCKS_OFF=0x0C                # Total blocks (64-bit LE)
            SB_ROOTINODE_OFF = 0x20                # Root inode number (32-bit LE)
        }

        # =====================================================================
        # UDF
        # =====================================================================
        UDF = @{
            SIG              = 0x42454130          # "BEA0" (VRS signature prefix)
            VRS_OFF          = 0x8000              # Volume Recognition Sequence offset
            ANCHOR_OFF       = 0x10000             # Anchor Volume Descriptor offset
            LV_INFO_OFF      = 0x20000             # Logical Volume Info offset

            # Primary Volume Descriptor Field Offsets (relative to PVD start)
            PVD_VOLNAME_OFF  = 0x28                # Volume identifier (32 bytes)
            PVD_BLOCKSIZE_OFF= 0x10                # Logical block size (32-bit LE)
            PVD_VOLSPACE_OFF = 0x50                # Volume space size (32-bit LE)
        }

        # =====================================================================
        # ISO9660
        # =====================================================================
        ISO9660 = @{
            SIG              = "CD001"             # Primary Volume Descriptor signature (ASCII)
            PVD_OFFSET       = 0x8000              # Primary Volume Descriptor sector offset
            PVD_BYTE_OFFSET  = 0x8001              # Byte offset within sector for signature

            # Primary Volume Descriptor Field Offsets (relative to PVD start)
            PVD_VOLNAME_OFF  = 0x28                # Volume identifier (32 bytes)
            PVD_BLOCKSIZE_OFF= 0x80                # Logical block size (16-bit LE)
            PVD_VOLSPACE_OFF = 0x50                # Volume space size (32-bit LE)
            PVD_ROOTDIR_OFF  = 0x9E                # Root directory record offset
            PVD_ROOTDIR_LEN_OFF=0xAA               # Root directory length (1 byte)
            PVD_ROOTDIR_EXTENT_OFF=0xA2            # Root directory extent location (32-bit LE)
        }

        # =====================================================================
        # DISK IMAGE CONTAINERS
        # =====================================================================
        DISKIMAGE = @{
            # VMDK
            VMDK_SIG         = "KDMV"              # Little-endian "VMDK"
            VMDK_VERSION_OFF = 0x04                # Format version (32-bit LE)
            VMDK_FLAGS_OFF   = 0x08                # Flags (32-bit LE)
            VMDK_CAPACITY_OFF= 0x30                # Capacity in sectors (64-bit LE)
            VMDK_GRAINSIZE_OFF=0x28                # Grain size in sectors (32-bit LE)

            # VHD (Legacy)
            VHD_SIG          = "conectix"          # ASCII signature at offset 0
            VHD_FILESIZE_OFF = 0x28                # File size in bytes (64-bit BE)
            VHD_GEOMETRY_OFF = 0x40                # Disk geometry (16-bit BE)

            # VHDX
            VHDX_SIG         = "vhdxfile"          # ASCII signature at offset 0
            VHDX_FILESIZE_OFF= 0x20                # File size in bytes (64-bit LE)
            VHDX_LOGSECTOR_OFF=0x30                # Logical sector size (32-bit LE)
            VHDX_PHYSECTOR_OFF=0x34                # Physical sector size (32-bit LE)

            # QCOW2
            QCOW2_MAGIC      = 0x514649FB          # "QFI" + 0xFB
            QCOW2_VERSION_OFF= 0x04                # Format version (32-bit BE)
            QCOW2_BACKING_OFF= 0x08                # Backing file offset (64-bit BE)
            QCOW2_SIZE_OFF   = 0x18                # Virtual size in bytes (64-bit BE)
            QCOW2_CLUSTERBITS_OFF=0x20             # Cluster size as power of 2 (8-bit)

            # DMG (Apple)
            DMG_SIG          = "koly"              # ASCII signature at offset 0x0C
            DMG_SIZE_OFF     = 0x04                # Size field (64-bit BE)
            DMG_DATAFORK_OFF = 0x2C                # Data fork offset (64-bit BE)
        }

        # =====================================================================
        # PARTITION TABLES
        # =====================================================================
        PARTITION = @{
            # GPT
            GPT_SIG          = "EFI PART"          # ASCII signature at offset 0
            GPT_REVISION_OFF = 0x08                # Revision (32-bit LE)
            GPT_HEADERSIZE_OFF=0x0C                # Header size (32-bit LE)
            GPT_CURRENTLBA_OFF=0x18                # Current LBA (64-bit LE)
            GPT_BACKUPLBA_OFF=0x20                 # Backup LBA (64-bit LE)
            GPT_FIRSTUSABLE_OFF=0x28               # First usable LBA (64-bit LE)
            GPT_LASTUSABLE_OFF=0x30                # Last usable LBA (64-bit LE)
            GPT_DISKGUID_OFF = 0x38                # Disk GUID (16 bytes)
            GPT_PARTSTART_OFF=0x48                 # Partition array start LBA (64-bit LE)
            GPT_PARTCOUNT_OFF=0x50                 # Number of partitions (32-bit LE)
            GPT_PARTENTRYSIZE_OFF=0x54             # Partition entry size (32-bit LE)

            # Partition Entry Field Offsets (relative to entry start)
            PART_TYPEGUID_OFF= 0x00                # Partition type GUID (16 bytes)
            PART_PARTGUID_OFF= 0x10                # Unique partition GUID (16 bytes)
            PART_FIRSTLBA_OFF= 0x20                # First LBA (64-bit LE)
            PART_LASTLBA_OFF = 0x28                # Last LBA (64-bit LE)
            PART_FLAGS_OFF   = 0x30                # Attributes flags (64-bit LE)
            PART_NAME_OFF    = 0x38                # Partition name (72 bytes UTF-16LE)

            # MBR
            MBR_SIG          = 0xAA55              # Boot signature at offset 510
            MBR_DISKSIG_OFF  = 0x1B8               # Disk signature (32-bit LE, optional)
            MBR_PARTTABLE_OFF= 0x1BE               # Partition table start offset

            # MBR Partition Entry Field Offsets (16 bytes each, 4 entries)
            MBR_PART_STATUS_OFF=0x00               # Boot indicator (1 byte)
            MBR_PART_STARTCHS_OFF=0x01             # Start CHS (3 bytes)
            MBR_PART_TYPE_OFF= 0x04                # Partition type (1 byte)
            MBR_PART_ENDCHS_OFF=0x05               # End CHS (3 bytes)
            MBR_PART_STARTLBA_OFF=0x08             # Start LBA (32-bit LE)
            MBR_PART_SECTORCOUNT_OFF=0x0C          # Sector count (32-bit LE)
        }

        # =====================================================================
        # MAGIC OFFSET LIBRARY (Generic FS detection)
        # =====================================================================
        FS_MAGIC_OFFSET_LIB = @(
            @{Magic = 0x0B5B1A2F; Name = "cramfs"; Offset = 0x0}
            @{Magic = 0x73717368; Name = "squashfs"; Offset = 0x0}
            @{Magic = 0x68737173; Name = "squashfs (alt)"; Offset = 0x0}
            @{Magic = 0x2F5B2F5B; Name = "romfs"; Offset = 0x0}
            @{Magic = 0x72617930; Name = "cramfs-alt"; Offset = 0x0}
            @{Magic = 0x68737173; Name = "squashfs-be"; Offset = 0x0}
        )
    }
}