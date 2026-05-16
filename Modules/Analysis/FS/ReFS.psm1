<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.ReFS
    Description: ReFS superblock, metadata streams, B+tree parser.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapeREFSParser {
    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "REFS_PARSER_READY"
        Severity = "LOG_INFO"
    }
}

function Get-ScapeREFSMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)][byte[]]$Buffer,
        [Parameter(Mandatory)][int]$Offset,
        [string]$VolumeSerial = ""
    )

    if (-not $Script:C) { Initialize-ScapeREFSParser }

    if ($Buffer.Length -lt ($Offset + 4)) { return $null }
    $magic = [System.BitConverter]::ToUInt32($Buffer, $Offset)
    if ($magic -ne $Script:C.FS.REFS.SIG) { return $null }

    $versionMajor = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.REFS.SB_VERSION_MAJOR_OFF)
    $versionMinor = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.REFS.SB_VERSION_MINOR_OFF)
    $clusterSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.REFS.SB_CLUSTERSIZE_OFF)
    $volumeSize = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.REFS.SB_VOLUMESIZE_OFF)
    $metadataSize = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.REFS.SB_METADATASIZE_OFF)
    $rootFileRef = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.REFS.SB_ROOTFILEREFF_OFF)

    $result = [PSCustomObject]@{
        VolumeSerial   = $VolumeSerial
        FSType         = "FS_REFS"
        Status         = $Script:C.DB["STATUS_DISC"]
        InodeNumber    = $rootFileRef
        FileName       = "<ROOT>"
        RealSize       = $volumeSize
        IsDirectory    = $true
        IsDeleted      = $false
        VersionMajor   = $versionMajor
        VersionMinor   = $versionMinor
        ClusterSize    = $clusterSize
        MetadataSize   = $metadataSize
        ParsedAtOffset = $Offset
        ParsedAtTime   = [DateTime]::UtcNow
    }

    Publish-ScapeEvent -Type "FS_RECORD_EXTRACTED" -Payload @{
        VolumeSerial = $VolumeSerial
        Record       = $result
        Category     = "FileSystem"
        FSType       = "FS_REFS"
        Timestamp    = [DateTime]::UtcNow
    }

    return $result
}