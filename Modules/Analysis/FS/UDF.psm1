<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.UDF
    Description: UDF Volume Descriptor Sequence, File Entry, Directory Record.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapeUDFParser {
    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "UDF_PARSER_READY"
        Severity = "LOG_INFO"
    }
}

function Get-ScapeUDFMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)][byte[]]$Buffer,
        [Parameter(Mandatory)][int]$Offset,
        [string]$VolumeSerial = ""
    )

    if (-not $Script:C) { Initialize-ScapeUDFParser }

    $anchorOff = $Script:C.FS.UDF.ANCHOR_OFF
    if ($Buffer.Length -lt ($Offset + $anchorOff + 0x200)) { return $null }

    $vrsSig = [System.Text.Encoding]::ASCII.GetString($Buffer, $Offset + $anchorOff, 5)
    if ($vrsSig -ne "BEA01") { return $null }

    $pvdOff = $anchorOff + 0x200
    $volId = [System.Text.Encoding]::ASCII.GetString($Buffer, $Offset + $pvdOff + $Script:C.FS.UDF.PVD_VOLNAME_OFF, 32).Trim()
    $blockSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $pvdOff + $Script:C.FS.UDF.PVD_BLOCKSIZE_OFF)
    $volSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $pvdOff + $Script:C.FS.UDF.PVD_VOLSPACE_OFF)

    $result = [PSCustomObject]@{
        VolumeSerial   = $VolumeSerial
        FSType         = "UDF"
        Status         = $Script:C.DB["STATUS_DISC"]
        InodeNumber    = 0
        FileName       = $volId
        RealSize       = $volSize * $blockSize
        IsDirectory    = $true
        IsDeleted      = $false
        BlockSize      = $blockSize
        VolumeID       = $volId
        ParsedAtOffset = $Offset
        ParsedAtTime   = [DateTime]::UtcNow
    }

    Publish-ScapeEvent -Type "FS_RECORD_EXTRACTED" -Payload @{
        VolumeSerial = $VolumeSerial
        Record       = $result
        Category     = "FileSystem"
        FSType       = "UDF"
        Timestamp    = [DateTime]::UtcNow
    }

    return $result
}
