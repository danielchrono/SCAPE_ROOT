<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.ISO9660
    Description: ISO9660 Primary Volume Descriptor, Directory Record, Path Table.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapeISO9660Parser {
    [CmdletBinding()]
    [OutputType([void])]
    param()

    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "ISO9660_PARSER_READY"; Severity = "LOG_INFO" }
}

function Get-ScapeISO9660Meta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset,
        [string]$VolumeSerial = ""
    )



    $pvdOff = (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_OFFSET
    if ($Buffer.Length -lt ($Offset + $pvdOff + 0x800)) { return $null }

    $cdSig = [System.Text.Encoding]::ASCII.GetString($Buffer, $Offset + $pvdOff + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_BYTE_OFFSET, 5)
    if ($cdSig -ne (Get-ScapeConstant -Path "storage::FS").ISO9660.SIG) { return $null }

    $volId = [System.Text.Encoding]::ASCII.GetString($Buffer, $Offset + $pvdOff + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_VOLNAME_OFF, 32).Trim()
    $blockSize = [System.BitConverter]::ToUInt16($Buffer, $Offset + $pvdOff + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_BLOCKSIZE_OFF)
    $volSpace = [System.BitConverter]::ToUInt32($Buffer, $Offset + $pvdOff + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_VOLSPACE_OFF)
    $rootDirRecOffset = $pvdOff + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_ROOTDIR_OFF
    $rootDirLen = $Buffer[$Offset + $rootDirRecOffset + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_ROOTDIR_LEN_OFF]
    $rootExtent = [System.BitConverter]::ToUInt32($Buffer, $Offset + $rootDirRecOffset + (Get-ScapeConstant -Path "storage::FS").ISO9660.PVD_ROOTDIR_EXTENT_OFF)

    $result = [PSCustomObject]@{
        VolumeSerial   = $VolumeSerial
        FSType         = "ISO9660"
        Status         = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        InodeNumber    = $rootExtent
        FileName       = $volId
        RealSize       = $volSpace * $blockSize
        IsDirectory    = $true
        IsDeleted      = $false
        BlockSize      = $blockSize
        VolumeID       = $volId
        RootExtent     = $rootExtent
        RootDirLength  = $rootDirLen
        ParsedAtOffset = $Offset
        ParsedAtTime   = [DateTime]::UtcNow
    }

    Publish-ScapeEvent -Type "FS_RECORD_EXTRACTED" -Payload @{ VolumeSerial = $VolumeSerial; Record = $result; Category = "FileSystem"; FSType = "ISO9660"; Timestamp = [DateTime]::UtcNow }

    return $result
}
Export-ModuleMember -Function 'Initialize-ScapeISO9660Parser'
