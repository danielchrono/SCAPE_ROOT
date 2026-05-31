<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.HFS
    Description: HFS/HFS+/HFSX catalog B-tree, extents, attributes.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapeHFSParser {
    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "HFS_PARSER_READY"
        Severity = "LOG_INFO"
    }
}

function Get-ScapeHFSMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)][byte[]]$Buffer,
        [Parameter(Mandatory)][int]$Offset,
        [string]$VolumeSerial = ""
    )



    $vhOff = (Get-ScapeConstant -Path "storage::FS").HFS.VOLUME_HEADER_OFF
    if ($Buffer.Length -lt ($Offset + $vhOff + 0x200)) { return $null }

    $sig = [System.BitConverter]::ToUInt16($Buffer, $Offset + $vhOff)
    $isHFSPlus = ($sig -eq (Get-ScapeConstant -Path "storage::FS").HFS.PLUS_SIG -or $sig -eq (Get-ScapeConstant -Path "storage::FS").HFS.HFSX_SIG)
    if (-not $isHFSPlus -and $sig -ne (Get-ScapeConstant -Path "storage::FS").HFS.SIG) { return $null }

    if ($sig -eq (Get-ScapeConstant -Path "storage::FS").HFS.SIG) {
        $blockSize = [System.BitConverter]::ToUInt16($Buffer, $Offset + $vhOff + (Get-ScapeConstant -Path "storage::FS").HFS.VH_BLOCKSIZE_OFF)
    }
    else {
        $blockSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $vhOff + (Get-ScapeConstant -Path "storage::FS").HFS.VH_BLOCKSIZE_OFF)
    }
    $totalBlocks = [System.BitConverter]::ToUInt32($Buffer, $Offset + $vhOff + (Get-ScapeConstant -Path "storage::FS").HFS.VH_TOTALBLOCKS_OFF)
    $rootDirCNID = [System.BitConverter]::ToUInt32($Buffer, $Offset + $vhOff + (Get-ScapeConstant -Path "storage::FS").HFS.VH_ROOTDIR_OFF)
    $volumeName = [System.Text.Encoding]::ASCII.GetString($Buffer, $Offset + $vhOff + (Get-ScapeConstant -Path "storage::FS").HFS.VH_VOLNAME_OFF, 32).Trim()

    $result = [PSCustomObject]@{
        VolumeSerial   = $VolumeSerial
        FSType         = if ($sig -eq (Get-ScapeConstant -Path "storage::FS").HFS.PLUS_SIG) { "HFS_PLUS" } elseif ($sig -eq (Get-ScapeConstant -Path "storage::FS").HFS.HFSX_SIG) { "HFSX" } else { "HFS" }
        Status         = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        InodeNumber    = $rootDirCNID
        FileName       = $volumeName
        RealSize       = $totalBlocks * $blockSize
        IsDirectory    = $true
        IsDeleted      = $false
        BlockSize      = $blockSize
        TotalBlocks    = $totalBlocks
        VolumeName     = $volumeName
        ParsedAtOffset = $Offset
        ParsedAtTime   = [DateTime]::UtcNow
    }

    Publish-ScapeEvent -Type "FS_RECORD_EXTRACTED" -Payload @{
        VolumeSerial = $VolumeSerial
        Record       = $result
        Category     = "FileSystem"
        FSType       = $result.FSType
        Timestamp    = [DateTime]::UtcNow
    }

    return $result
}
Export-ModuleMember -Function 'Initialize-ScapeHFSParser'
