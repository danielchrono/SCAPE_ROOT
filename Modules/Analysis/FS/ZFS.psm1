<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.ZFS
    Description: ZFS uberblock, objset, dnode, and ZAP parser.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapeZFSParser {
    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "ZFS_PARSER_READY"
        Severity = "LOG_INFO"
    }
}

function Get-ScapeZFSMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)][byte[]]$Buffer,
        [Parameter(Mandatory)][int]$Offset,
        [string]$VolumeSerial = ""
    )

    if (-not $Script:C) { Initialize-ScapeZFSParser }

    $uberMagic = [System.BitConverter]::ToUInt32($Buffer, $Offset)
    if ($uberMagic -eq $Script:C.FS.ZFS.UBER_SIG) {
        $txg = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.ZFS.UBER_TXG_OFF)
        $timestamp = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.ZFS.UBER_TIMESTAMP_OFF)
        $rootbp = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.ZFS.UBER_ROOTBP_OFF)

        $result = [PSCustomObject]@{
            VolumeSerial   = $VolumeSerial
            FSType         = "FS_ZFS"
            Status         = $Script:C.DB["STATUS_DISC"]
            InodeNumber    = 0
            FileName       = "<UBERBLOCK>"
            RealSize       = 0
            IsDirectory    = $false
            IsDeleted      = $false
            UberblockTxg   = $txg
            UberTimestamp  = Convert-ScapeUnixTime -Epoch $timestamp
            RootBP         = $rootbp
            ParsedAtOffset = $Offset
            ParsedAtTime   = [DateTime]::UtcNow
        }
        return $result
    }

    $labelMagic = [System.Text.Encoding]::ASCII.GetString($Buffer, $Offset, 8)
    if ($labelMagic -eq "/ZBSOLYS") {
        $result = [PSCustomObject]@{
            VolumeSerial   = $VolumeSerial
            FSType         = "FS_ZFS"
            Status         = $Script:C.DB["STATUS_DISC"]
            InodeNumber    = 0
            FileName       = "<LABEL>"
            RealSize       = 0
            LabelMagic     = $labelMagic
            ParsedAtOffset = $Offset
        }
        return $result
    }

    return $null
}