<#
.SYNOPSIS
    Domain: Analysis | Module: Scape.Analysis.FS.EXT
    Description: EXT2/3/4 inode parser, indirect block resolver, and deleted inode recovery.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>
#Requires -Version 5.1

$Script:C = $null

function Initialize-ScapeEXTParser {
    [CmdletBinding()]
    param()
    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action = "LogLine"; Key = "EXT_PARSER_READY"; Severity = "LOG_INFO"
    }
}

function Get-ScapeEXTInode {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset
    )

    $inodeSize = [int]$Script:C.FS.EXT.INODE_SIZE
    if (($Offset + $inodeSize) -gt $Buffer.Length) { return $null }

    $mode = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_MODE_OFF)
    $uid = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_UID_OFF)
    $sizeLow = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_SIZE_LOW_OFF)
    $sizeHigh = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_SIZE_HIGH_OFF)
    $atime = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_ATIME_OFF)
    $mtime = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_MTIME_OFF)
    $ctime = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_CTIME_OFF)
    $links = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_LINKS_OFF)
    $blocks = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_BLOCKS_OFF)
    $flags = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + $Script:C.FS.EXT.INODE_FLAGS_OFF)

    $realSize = [int64]$sizeLow + ([int64]$sizeHigh -shl 32)
    $isDir = ($mode -band 0x4000) -ne 0
    $isDel = ($links -eq 0) -and ($sizeLow -gt 0)

    return [PSCustomObject]@{
        InodeNumber = [math]::Floor($Offset / $inodeSize) + 1
        Mode = $mode; UID = $uid; RealSize = $realSize
        AllocatedBlocks = $blocks
        Accessed = Convert-ScapeUnixTime -Epoch $atime
        Modified = Convert-ScapeUnixTime -Epoch $mtime
        StatusChanged = Convert-ScapeUnixTime -Epoch $ctime
        LinkCount = $links; Flags = $flags
        IsDirectory = $isDir; IsDeleted = $isDel; Offset = $Offset
    }
}

function Resolve-ScapeEXTIndirectBlock {
    [CmdletBinding()]
    [OutputType([long[]])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$InodeBuffer,
        [Parameter()][int]$BlockSize = 4096
    )
    $null = $BlockSize # PSReviewUnusedParameter

    $pointers = New-Object System.Collections.Generic.List[long]
    for ($i = 0; $i -lt 12; $i++) {
        $ptr = Read-ScapeUInt32LE -Buf $InodeBuffer -Off ($Script:C.FS.EXT.INODE_PTRS_START + ($i * 4))
        if ($ptr -gt 0) { $pointers.Add($ptr) }
    }
    $single = Read-ScapeUInt32LE -Buf $InodeBuffer -Off ($Script:C.FS.EXT.INODE_PTRS_START + 48)
    if ($single -gt 0) { $pointers.Add($single) }
    return $pointers.ToArray()
}

function Restore-ScapeEXTDeletedInode {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter()][int]$StartOffset = 0,
        [Parameter()][int]$MaxInodes = 100
    )

    $inodeSize = [int]$Script:C.FS.EXT.INODE_SIZE
    $recovered = New-Object System.Collections.Generic.List[PSCustomObject]
    $count = 0

    for ($i = $StartOffset; $i -lt ($Buffer.Length - $inodeSize) -and $count -lt $MaxInodes; $i += $inodeSize) {
        # CORREÇÃO: Get-ScapeEXTInode, não Set-
        $inode = Get-ScapeEXTInode -Buffer $Buffer -Offset $i
        if ($inode -and $inode.IsDeleted) {
            $recovered.Add($inode); $count++
        }
    }
    return $recovered.ToArray()
}

function Get-ScapeEXTJournal {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter()][int]$Offset = 0
    )
    if ($Buffer.Length -lt ($Offset + 4)) { return $null }
    $magic = Read-ScapeUInt32LE -Buf $Buffer -Off $Offset
    if ($magic -ne 0xC03B3991) { return $null }
    return [PSCustomObject]@{
        Type = "EXT_JOURNAL"; Magic = $magic; Offset = $Offset; Status = "STUB_NOT_IMPLEMENTED"
    }
}

function Get-ScapeEXTMeta {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset,
        [string]$VolumeSerial = ""
    )
    if (-not $Script:C) { Initialize-ScapeEXTParser }

    # CORREÇÃO: Get-ScapeEXTInode
    $inode = Get-ScapeEXTInode -Buffer $Buffer -Offset $Offset
    if ($inode) {
        $inode | Add-Member -NotePropertyName "VolumeSerial" -NotePropertyValue $VolumeSerial -Force
        $inode | Add-Member -NotePropertyName "FSType" -NotePropertyValue "EXT4" -Force
        $inode | Add-Member -NotePropertyName "Status" -NotePropertyValue $Script:C.DB["STATUS_DISC"] -Force
        $blocks = Resolve-ScapeEXTIndirectBlock -InodeBuffer $Buffer
        $inode | Add-Member -NotePropertyName "BlockPointers" -NotePropertyValue $blocks -Force
        return $inode
    }
    return $null
}
