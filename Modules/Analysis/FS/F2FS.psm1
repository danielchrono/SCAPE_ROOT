<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.F2FS
    Description: F2FS checkpoint, node/address/data segment parser.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapeF2FSParser {
    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "F2FS_PARSER_READY"
        Severity = "LOG_INFO"
    }
}

function Get-ScapeF2FSMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)][byte[]]$Buffer,
        [Parameter(Mandatory)][int]$Offset,
        [string]$VolumeSerial = ""
    )

    if (-not $Script:C) { Initialize-ScapeF2FSParser }

    $sbOff = 0x400
    if ($Buffer.Length -lt ($Offset + $sbOff + 0x200)) { return $null }
    $magic = [System.BitConverter]::ToUInt32($Buffer, $Offset + $sbOff)
    if ($magic -ne $Script:C.FS.F2FS.SB_SIG) { return $null }

    $blockSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $sbOff + $Script:C.FS.F2FS.SB_BLOCKSIZE_OFF)
    $totalSectors = [System.BitConverter]::ToUInt64($Buffer, $Offset + $sbOff + $Script:C.FS.F2FS.SB_TOTALSECTORS_OFF)
    $rootIno = [System.BitConverter]::ToUInt32($Buffer, $Offset + $sbOff + $Script:C.FS.F2FS.SB_ROOTINO_OFF)
    $segmentCount = [System.BitConverter]::ToUInt32($Buffer, $Offset + $sbOff + $Script:C.FS.F2FS.SB_SEGMENTCNT_OFF)

    $result = [PSCustomObject]@{
        VolumeSerial   = $VolumeSerial
        FSType         = "F2FS"
        Status         = $Script:C.DB["STATUS_DISC"]
        InodeNumber    = $rootIno
        FileName       = "<ROOT>"
        RealSize       = $totalSectors * $Script:C.FS.SECTOR_SIZE
        IsDirectory    = $true
        IsDeleted      = $false
        BlockSize      = $blockSize
        SegmentCount   = $segmentCount
        ParsedAtOffset = $Offset
        ParsedAtTime   = [DateTime]::UtcNow
    }

    Publish-ScapeEvent -Type "FS_RECORD_EXTRACTED" -Payload @{
        VolumeSerial = $VolumeSerial
        Record       = $result
        Category     = "FileSystem"
        FSType       = "F2FS"
        Timestamp    = [DateTime]::UtcNow
    }

    return $result
}
