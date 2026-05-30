<#
.SYNOPSIS
    Domain: Analysis | Module: Scape.Analysis.FS.Metadata
    Description: High-performance filesystem metadata parser, timestamp normalizer, and forensic record mapper.
#>
#Requires -Version 5.1

$Script:FSConstants = $null
$Script:DBConstants = $null
$Script:Limits = $null


# Helper functions com parâmetros tipados para evitar PSReviewUnusedParameter
function Read-ScapeUInt16LE {
    [CmdletBinding()][OutputType([uint16])]
    param([Parameter(Mandatory=$true)][byte[]]$Buf, [Parameter(Mandatory=$true)][int]$Off)
    return [BitConverter]::ToUInt16($Buf, $Off)
}
function Read-ScapeUInt32LE {
    [CmdletBinding()][OutputType([uint32])]
    param([Parameter(Mandatory=$true)][byte[]]$Buf, [Parameter(Mandatory=$true)][int]$Off)
    return [BitConverter]::ToUInt32($Buf, $Off)
}
function Read-ScapeUInt64LE {
    [CmdletBinding()][OutputType([uint64])]
    param([Parameter(Mandatory=$true)][byte[]]$Buf, [Parameter(Mandatory=$true)][int]$Off)
    return [BitConverter]::ToUInt64($Buf, $Off)
}
function Read-ScapeInt64LE {
    [CmdletBinding()][OutputType([int64])]
    param([Parameter(Mandatory=$true)][byte[]]$Buf, [Parameter(Mandatory=$true)][int]$Off)
    return [BitConverter]::ToInt64($Buf, $Off)
}

function Read-ScapeAsciiString {
    [CmdletBinding()][OutputType([string])]
    param(
        [Parameter(Mandatory=$true)][byte[]]$Buf,
        [Parameter(Mandatory=$true)][int]$Off,
        [Parameter(Mandatory=$true)][int]$Len
    )
    if ($Len -le 0 -or ($Off + $Len) -gt $Buf.Length) { return "" }
    $bytes = $Buf[$Off..($Off + $Len - 1)]
    $text = [System.Text.Encoding]::ASCII.GetString($bytes).Trim()
    return $text -replace '[^\x20-\x7E]', ''
}

function Read-ScapeUTF16LEString {
    [CmdletBinding()][OutputType([string])]
    param(
        [Parameter(Mandatory=$true)][byte[]]$Buf,
        [Parameter(Mandatory=$true)][int]$Off,
        [Parameter(Mandatory=$true)][int]$Len
    )
    if ($Len -le 0 -or ($Off + $Len) -gt $Buf.Length) { return "" }
    $text = [System.Text.Encoding]::Unicode.GetString($Buf, $Off, $Len).Trim()
    return $text -replace '[^\x20-\x{FFFF}]', ''
}

function Convert-ScapeNTFSTime {
    [CmdletBinding()][OutputType([DateTime])]
    param([Parameter(Mandatory=$true)][long]$Raw100ns)
    if ($Raw100ns -le 0) { return $null }
    try {
        $base = [DateTime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        return $base.AddTicks($Raw100ns)
    }
    catch { return $null }
}

function Convert-ScapeFATTime {
    [CmdletBinding()][OutputType([DateTime])]
    param([Parameter(Mandatory=$true)][uint16]$Time, [Parameter(Mandatory=$true)][uint16]$Date)
    if ($Date -eq 0 -or $Time -eq 0) { return $null }
    $year = (($Date -shr 9) -band 0x7F) + 1980
    $month = ($Date -shr 5) -band 0x0F; $day = $Date -band 0x1F
    $hour = ($Time -shr 11) -band 0x1F; $min = ($Time -shr 5) -band 0x3F; $sec = ($Time -band 0x1F) * 2
    try { return [DateTime]::new($year, $month, $day, $hour, $min, $sec, [System.DateTimeKind]::Utc) }
    catch { return $null }
}

function Convert-ScapeUnixTime {
    [CmdletBinding()][OutputType([DateTime])]
    param([Parameter(Mandatory=$true)][uint32]$Epoch)
    if ($Epoch -eq 0) { return $null }
    try { return [DateTimeOffset]::FromUnixTimeSeconds($Epoch).UtcDateTime }
    catch { return $null }
}

function Get-ScapeNTFSMFT {
    [CmdletBinding()][OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory=$true)][byte[]]$Buffer,
        [Parameter(Mandatory=$true)][int]$Offset
    )
    if (-not $Script:FSConstants) { Initialize-ScapeFSMetadataEngine }

    $recSize = [int]($Script:FSConstants.NTFS.MFT_REC_SIZE)
    if (($Offset + $recSize) -gt $Buffer.Length) { return $null }

    $sig = Read-ScapeUInt32LE -Buf $Buffer -Off $Offset
    if ($sig -ne $Script:FSConstants.NTFS.MFT_SIG) { return $null }

    $seqNum = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.NTFS.MFT_SEQ_OFF)
    $frn = Read-ScapeUInt64LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.NTFS.MFT_FRN_OFF)
    $attrOff = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.NTFS.MFT_ATTR_OFF_OFF)

    $curr = $Offset + $attrOff
    $name = $null; $created = $null; $modified = $null; $accessed = $null; $mftChanged = $null
    $sizeOnDisk = 0; $realSize = 0

    while ($true) {
        if ($curr -ge ($Offset + $recSize - 4)) { break } # Previne buffer overrun
        $type = Read-ScapeUInt32LE -Buf $Buffer -Off $curr
        if ($type -eq 0xFFFFFFFF -or $type -eq 0) { break }

        $len = Read-ScapeUInt32LE -Buf $Buffer -Off ($curr + $Script:FSConstants.NTFS.ATTR_LEN_OFF)
        if ($len -le 0) { break } # Previne loop infinito

        $res = [System.BitConverter]::ToBoolean($Buffer, $curr + $Script:FSConstants.NTFS.ATTR_NONRES_OFF)
        $nameLen = if ($res) { 0 } else { [int](Read-ScapeUInt16LE -Buf $Buffer -Off ($curr + $Script:FSConstants.NTFS.ATTR_NAMELEN_OFF)) }
        $nameOff = if ($res) { 0 } else { [int](Read-ScapeUInt16LE -Buf $Buffer -Off ($curr + $Script:FSConstants.NTFS.ATTR_NAMEOFF_OFF)) }

        if ($type -eq $Script:FSConstants.NTFS.ATTR_NAME -and $nameLen -gt 0 -and -not $name) {
            $name = Read-ScapeUTF16LEString -Buf $Buffer -Off ($curr + $nameOff) -Len ($nameLen * 2)
        }
        elseif ($type -eq $Script:FSConstants.NTFS.ATTR_DATA -and $res -eq $false) {
            $realSize = [int64](Read-ScapeInt64LE -Buf $Buffer -Off ($curr + $Script:FSConstants.NTFS.ATTR_DATA_SIZE_OFF))
            $sizeOnDisk = [int64](Read-ScapeInt64LE -Buf $Buffer -Off ($curr + $Script:FSConstants.NTFS.ATTR_DATA_SIZE_OFF + 8))
        }
        elseif ($type -eq 0x10) {
            $created = Convert-ScapeNTFSTime -Raw100ns (Read-ScapeInt64LE -Buf $Buffer -Off ($curr + 16))
            $modified = Convert-ScapeNTFSTime -Raw100ns (Read-ScapeInt64LE -Buf $Buffer -Off ($curr + 24))
            $mftChanged = Convert-ScapeNTFSTime -Raw100ns (Read-ScapeInt64LE -Buf $Buffer -Off ($curr + 32))
            $accessed = Convert-ScapeNTFSTime -Raw100ns (Read-ScapeInt64LE -Buf $Buffer -Off ($curr + 40))
        }
        $curr += $len
    }
    $flags = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.NTFS.MFT_FLAGS_OFF)
    $fallbackUnknown = Get-ScapeConstant -Path "ui::STATUS_UNKNOWN" -Fallback "STATUS_UNKNOWN"

    return [PSCustomObject]@{
        FRN = $frn -band $Script:FSConstants.NTFS.FRN_MASK; SeqNumber = $seqNum
        FileName = if ($name) { $name } else { $fallbackUnknown }
        RealSize = $realSize; AllocatedSize = $sizeOnDisk
        Created = $created; Modified = $modified; Accessed = $accessed; MFTChanged = $mftChanged
        IsDirectory = ([System.IO.FileAttributes]::Directory -band $flags) -ne 0
        IsDeleted = ($seqNum -band 0x8000) -ne 0
    }
}

function Get-ScapeFATEntry {
    [CmdletBinding()][OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory=$true)][byte[]]$Buffer,
        [Parameter(Mandatory=$true)][int]$Offset
    )
    if (-not $Script:FSConstants) { Initialize-ScapeFSMetadataEngine }

    $dirSize = [int]($Script:FSConstants.FAT.DIR_SIZE)
    if (($Offset + $dirSize) -gt $Buffer.Length) { return $null }

    $delSig = $Buffer[$Offset]
    if ($delSig -eq 0x00 -or $delSig -eq $Script:FSConstants.FAT.DEL_SIG) { return $null }

    $nameRaw = Read-ScapeAsciiString -Buf $Buffer -Off ($Offset + $Script:FSConstants.FAT.DIR_NAME_OFF) -Len 8
    $extRaw = Read-ScapeAsciiString -Buf $Buffer -Off ($Offset + $Script:FSConstants.FAT.DIR_NAME_OFF + 8) -Len 3
    $fileName = if ($extRaw) { "$nameRaw.$extRaw" } else { $nameRaw }

    $attr = $Buffer[$Offset + $Script:FSConstants.FAT.DIR_ATTR_OFF]
    $timeRaw = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.FAT.DIR_TIME_OFF)
    $dateRaw = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.FAT.DIR_DATE_OFF)
    $startClus = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.FAT.DIR_STARTCLU_OFF)
    $size = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.FAT.DIR_SIZE_OFF)

    return [PSCustomObject]@{
        FileName = $fileName.Trim(); Attributes = $attr
        Modified = Convert-ScapeFATTime -Time $timeRaw -Date $dateRaw
        StartCluster = $startClus; Size = $size
        IsDeleted = ($delSig -eq $Script:FSConstants.FAT.DEL_SIG)
        IsDirectory = ($attr -band 0x10) -ne 0
    }
}

function Get-ScapeEXTInode {
    [CmdletBinding()][OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory=$true)][byte[]]$Buffer,
        [Parameter(Mandatory=$true)][int]$Offset
    )
    if (-not $Script:FSConstants) { Initialize-ScapeFSMetadataEngine }

    $inodeSize = [int]($Script:FSConstants.EXT.INODE_SIZE)
    if (($Offset + $inodeSize) -gt $Buffer.Length) { return $null }

    $mode = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_MODE_OFF)
    $uid = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_UID_OFF)
    $sizeLow = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_SIZE_LOW_OFF)
    $sizeHigh = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_SIZE_HIGH_OFF)
    $atime = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_ATIME_OFF)
    $mtime = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_MTIME_OFF)
    $ctime = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_CTIME_OFF)
    $links = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_LINKS_OFF)
    $blocks = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_BLOCKS_OFF)
    $flags = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:FSConstants.EXT.INODE_FLAGS_OFF)

    $realSize = [int64]$sizeLow + ([int64]$sizeHigh -shl 32)
    $isDir = ($mode -band 0x4000) -ne 0; $isDel = ($links -eq 0) -and ($sizeLow -gt 0)

    return [PSCustomObject]@{
        InodeNumber = [math]::Floor($Offset / $inodeSize) + 1; Mode = $mode; UID = $uid
        RealSize = $realSize; AllocatedBlocks = $blocks
        Accessed = Convert-ScapeUnixTime -Epoch $atime; Modified = Convert-ScapeUnixTime -Epoch $mtime
        StatusChanged = Convert-ScapeUnixTime -Epoch $ctime; LinkCount = $links; Flags = $flags
        IsDirectory = $isDir; IsDeleted = $isDel
    }
}

function Get-ScapeFSMeta {
    [CmdletBinding()][OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory=$true)][byte[]]$Buffer,
        [Parameter(Mandatory=$true)][int]$Offset,
        [Parameter(Mandatory=$true)][ValidateSet("NTFS", "FAT32", "EXT4", "RAW")][string]$FSType,
        [string]$VolumeSerial = ""
    )
    if (-not $Script:FSConstants) { Initialize-ScapeFSMetadataEngine }

    $result = switch ($FSType) {
        "NTFS" { Get-ScapeNTFSMFT -Buffer $Buffer -Offset $Offset }
        "FAT32" { Get-ScapeFATEntry -Buffer $Buffer -Offset $Offset }
        "EXT4" { Get-ScapeEXTInode -Buffer $Buffer -Offset $Offset }
        default { $null }
    }

    if ($null -eq $result) {
        Publish-ScapeEvent -Type "LOG_WARN" -Payload @{
            Action = "LogLine"
            Key = "ERR_CORRUPTED_RECORD"
            Offset = $Offset
            FSType = $FSType
        }
        return $null
    }

    $status = if ($Script:DBConstants.ContainsKey("STATUS_DISC")) { $Script:DBConstants["STATUS_DISC"] } else { "DISCOVERED" }

    $result | Add-Member -NotePropertyName "VolumeSerial" -NotePropertyValue $VolumeSerial -Force
    $result | Add-Member -NotePropertyName "ParsedAtOffset" -NotePropertyValue $Offset -Force
    $result | Add-Member -NotePropertyName "FSType" -NotePropertyValue $FSType -Force
    $result | Add-Member -NotePropertyName "Status" -NotePropertyValue $status -Force
    return $result
}

function Convert-ScapeMetadataToDBRecord {
    [CmdletBinding()][OutputType([PSCustomObject])]
    param([Parameter(Mandatory=$true)][PSCustomObject]$Meta)

    if ($null -eq $Meta) { return $null }
    if (-not $Script:DBConstants) { Initialize-ScapeFSMetadataEngine }

    $table = $Script:DBConstants["TABLE_UNIV"]
    if ($Meta.FSType -eq "NTFS") { $table = $Script:DBConstants["TABLE_MFT"] }

    $parent = 0
    if ($Meta.FRN) { $parent = $Meta.FRN } elseif ($Meta.InodeNumber) { $parent = $Meta.InodeNumber }

    $jsonRaw = try { $Meta | ConvertTo-Json -Compress -Depth 1 -WarningAction SilentlyContinue } catch { "{}" }

    return [PSCustomObject]@{
        TableName = $table; ParentID = $parent
        ObjectID = [Guid]::NewGuid().ToString(); FileName = $Meta.FileName; RealSize = $Meta.RealSize
        Status = $Meta.Status; VolumeSerial = $Meta.VolumeSerial
        Created = $Meta.Created; Modified = $Meta.Modified; Accessed = $Meta.Accessed; MFTChanged = $Meta.MFTChanged
        MetadataRaw = $jsonRaw; ExtractionDate = [DateTime]::UtcNow
    }
}

function Test-ScapeMetadataIntegrity {
    [CmdletBinding()][OutputType([bool])]
    param([Parameter(Mandatory=$true)][PSCustomObject]$Record)

    if ($null -eq $Record) { return $false }
    if (-not $Script:Limits) { Initialize-ScapeFSMetadataEngine }

    $maxDepth = 256
    if ($Script:Limits.ContainsKey('MAX_DIR_DEPTH')) { $maxDepth = [int]$Script:Limits['MAX_DIR_DEPTH'] }

    $currentDepth = ($Record.FileName.ToCharArray() | Where-Object { $_ -eq '\' -or $_ -eq '/' }).Count
    if ($currentDepth -gt $maxDepth) { return $false }
    if ($Record.FileName -match '[\\/]{2,}' -or $Record.FileName.Length -gt 255) { return $false }
    if ($null -ne $Record.RealSize -and $Record.RealSize -lt 0) { return $false }

    $validYear = $true
    foreach ($prop in @('Created', 'Modified', 'Accessed', 'MFTChanged', 'StatusChanged')) {
        $val = $Record.$prop
        if ($val -is [DateTime] -and ($val.Year -lt 1980 -or $val.Year -gt 2050)) { $validYear = $false; break }
    }
    return $validYear
}

$Script:LocalI18N = @(
    "META_ACCESSED",
    "META_CREATED",
    "META_FILENAME",
    "META_MFT_CHANGED",
    "META_MODIFIED",
    "META_OFFSET",
    "META_PID",
) | ForEach-Object { Get-ScapeI18NNode -Key $_ }

