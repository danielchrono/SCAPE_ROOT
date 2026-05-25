<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.PartitionTable
    Description: GPT and MBR partition table parsers.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>

$Script:C = $null

function Initialize-ScapePartitionTableParser {
    [CmdletBinding()]
    [OutputType([void])]
    param()

    $Script:C = @{
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "PARTITION_PARSER_READY"; Severity = "LOG_INFO" }
}

function Get-ScapeGPTMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    if (-not $Script:C) { Initialize-ScapePartitionTableParser }
    if ($Buffer.Length -lt 8) { return $null }
    $sig = [System.Text.Encoding]::ASCII::GetString($Buffer, $Offset, 8)
    if ($sig -ne $Script:C.FS.PARTITION.GPT_SIG) { return $null }

    $revision = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_REVISION_OFF)
    $headerSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_HEADERSIZE_OFF)
    $currentLBA = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_CURRENTLBA_OFF)
    $backupLBA = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_BACKUPLBA_OFF)
    $firstUsableLBA = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_FIRSTUSABLE_OFF)
    $lastUsableLBA = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_LASTUSABLE_OFF)
    $diskGUID = [System.BitConverter]::ToString($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_DISKGUID_OFF, 16) -replace '-', ''
    $partitionsStartLBA = [System.BitConverter]::ToUInt64($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_PARTSTART_OFF)
    $numPartitions = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_PARTCOUNT_OFF)
    $partitionEntrySize = [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.PARTITION.GPT_PARTENTRYSIZE_OFF)

    $partitions = @()
    $entryOff = $Offset + $partitionsStartLBA * $Script:C.FS.SECTOR_SIZE
    for ($i = 0; $i -lt [Math]::Min($numPartitions, 16); $i++) {
        if ($Buffer.Length -lt ($entryOff + $partitionEntrySize)) { break }
        $typeGUID = [System.BitConverter]::ToString($Buffer, $entryOff + $Script:C.FS.PARTITION.PART_TYPEGUID_OFF, 16) -replace '-', ''
        $partGUID = [System.BitConverter]::ToString($Buffer, $entryOff + $Script:C.FS.PARTITION.PART_PARTGUID_OFF, 16) -replace '-', ''
        $firstLBA = [System.BitConverter]::ToUInt64($Buffer, $entryOff + $Script:C.FS.PARTITION.PART_FIRSTLBA_OFF)
        $lastLBA = [System.BitConverter]::ToUInt64($Buffer, $entryOff + $Script:C.FS.PARTITION.PART_LASTLBA_OFF)
        $flags = [System.BitConverter]::ToUInt64($Buffer, $entryOff + $Script:C.FS.PARTITION.PART_FLAGS_OFF)
        $name = [System.Text.Encoding]::Unicode.GetString($Buffer, $entryOff + $Script:C.FS.PARTITION.PART_NAME_OFF, 72).TrimEnd([char]0)
        if ($firstLBA -eq 0) { break }
        $partitions += [PSCustomObject]@{
            Index = $i; TypeGUID = $typeGUID; PartitionGUID = $partGUID
            StartLBA = $firstLBA; EndLBA = $lastLBA; SizeBytes = ($lastLBA - $firstLBA + 1) * $Script:C.FS.SECTOR_SIZE
            Flags = $flags; Name = $name
        }
        $entryOff += $partitionEntrySize
    }

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "GPT"; Status = $Script:C.DB["STATUS_DISC"]
        FileName = "<GPT>"; RealSize = 0; IsDirectory = $false; IsDeleted = $false
        Revision = $revision; HeaderSize = $headerSize; DiskGUID = $diskGUID
        CurrentLBA = $currentLBA; BackupLBA = $backupLBA; FirstUsableLBA = $firstUsableLBA; LastUsableLBA = $lastUsableLBA
        Partitions = $partitions; ParsedAtOffset = $Offset
    }
}

function Get-ScapeMBRMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    if (-not $Script:C) { Initialize-ScapePartitionTableParser }
    if ($Buffer.Length -lt ($Offset + 512)) { return $null }
    $sig = [System.BitConverter]::ToUInt16($Buffer, $Offset + 510)
    if ($sig -ne $Script:C.FS.PARTITION.MBR_SIG) { return $null }

    $partitions = @()
    for ($i = 0; $i -lt 4; $i++) {
        $entryOff = $Offset + $Script:C.FS.PARTITION.MBR_PARTTABLE_OFF + ($i * 16)
        $status = $Buffer[$entryOff + $Script:C.FS.PARTITION.MBR_PART_STATUS_OFF]
        if ($status -eq 0) { continue }
        $type = $Buffer[$entryOff + $Script:C.FS.PARTITION.MBR_PART_TYPE_OFF]
        $startLBA = [System.BitConverter]::ToUInt32($Buffer, $entryOff + $Script:C.FS.PARTITION.MBR_PART_STARTLBA_OFF)
        $sectorCount = [System.BitConverter]::ToUInt32($Buffer, $entryOff + $Script:C.FS.PARTITION.MBR_PART_SECTORCOUNT_OFF)
        $partitions += [PSCustomObject]@{
            Index = $i; Status = $status; Type = $type; StartLBA = $startLBA; SectorCount = $sectorCount
            SizeBytes = $sectorCount * $Script:C.FS.SECTOR_SIZE
        }
    }

    $diskSig = if ($Buffer.Length -gt ($Offset + $Script:C.FS.PARTITION.MBR_DISKSIG_OFF + 3)) {
        [System.BitConverter]::ToUInt32($Buffer, $Offset + $Script:C.FS.PARTITION.MBR_DISKSIG_OFF)
    }
    else { 0 }

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "MBR"; Status = $Script:C.DB["STATUS_DISC"]
        FileName = "<MBR>"; RealSize = 0; IsDirectory = $false; IsDeleted = $false
        DiskSignature = $diskSig; Partitions = $partitions; ParsedAtOffset = $Offset
    }
}