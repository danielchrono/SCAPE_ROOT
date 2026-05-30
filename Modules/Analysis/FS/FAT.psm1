<#
.SYNOPSIS
    Domain: Analysis | Module: Scape.Analysis.FS.FAT
    Description: FAT32/exFAT directory parser, cluster chain walker, and deleted entry recovery.
#>
#Requires -Version 5.1


        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action = "LogLine"; Key = "FAT_PARSER_READY"; Severity = "LOG_INFO"
    }
}

function Get-ScapeFATDirectoryEntry {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset
    )
    $dirSize = [int](Get-ScapeConstant -Path "storage::FS").FAT.DIR_SIZE
    if (($Offset + $dirSize) -gt $Buffer.Length) { return $null }

    $delSig = $Buffer[$Offset]
    if ($delSig -eq 0x00) { return $null }
    $isDeleted = ($delSig -eq (Get-ScapeConstant -Path "storage::FS").FAT.DEL_SIG)

    $nameRaw = Read-ScapeAsciiString -Buf $Buffer -Off ($Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_NAME_OFF) -Len 8
    $extRaw = Read-ScapeAsciiString -Buf $Buffer -Off ($Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_NAME_OFF + 8) -Len 3
    $fileName = if ($extRaw) { "$nameRaw.$extRaw" } else { $nameRaw }

    $attr = $Buffer[$Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_ATTR_OFF]
    $timeRaw = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_TIME_OFF)
    $dateRaw = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_DATE_OFF)
    $startClus = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_STARTCLU_OFF)
    $size = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + (Get-ScapeConstant -Path "storage::FS").FAT.DIR_SIZE_OFF)

    return [PSCustomObject]@{
        FileName = $fileName.Trim(); Attributes = $attr
        Modified = Convert-ScapeFATTime -Time $timeRaw -Date $dateRaw
        StartCluster = $startClus; Size = $size
        IsDeleted = $isDeleted; IsDirectory = ($attr -band 0x10) -ne 0; Offset = $Offset
    }
}

function Trace-ScapeFATChain {
    [CmdletBinding()]
    [OutputType([int[]])]
    param(
        [Parameter(Mandatory = $true)][int]$StartCluster,
        [Parameter(Mandatory = $true)][byte[]]$FATTable,
        [Parameter()][int]$FatType = 32
    )
    $clusters = New-Object System.Collections.Generic.List[int]
    $current = $StartCluster; $maxIter = 100000

    for ($i = 0; $i -lt $maxIter; $i++) {
        if ($current -lt 2) { break }
        $clusters.Add($current)
        $fatOffset = switch ($FatType) {
            32 { $current * 4 }; 16 { $current * 2 }; 12 { [Math]::Floor($current * 1.5) }
        }
        if ($fatOffset + 4 -gt $FATTable.Length) { break }
        $next = switch ($FatType) {
            32 { [BitConverter]::ToUInt32($FATTable, $fatOffset) -band 0x0FFFFFFF }
            16 { [BitConverter]::ToUInt16($FATTable, $fatOffset) }
            12 {
                $val = [BitConverter]::ToUInt16($FATTable, $fatOffset)
                if ($current -band 1) { ($val -shr 4) -band 0x0FFF } else { $val -band 0x0FFF }
            }
        }
        if ($next -ge 0x0FFFFFF8) { break }
        $current = $next
    }
    return $clusters.ToArray()
}

function Restore-ScapeDeletedFATEntry {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter()][int]$StartOffset = 0,
        [Parameter()][int]$MaxEntries = 100
    )
    $dirSize = [int](Get-ScapeConstant -Path "storage::FS").FAT.DIR_SIZE
    $recovered = New-Object System.Collections.Generic.List[PSCustomObject]
    $count = 0

    for ($i = $StartOffset; $i -lt ($Buffer.Length - $dirSize) -and $count -lt $MaxEntries; $i += $dirSize) {
        if ($Buffer[$i] -eq (Get-ScapeConstant -Path "storage::FS").FAT.DEL_SIG) {
            # CORREÇÃO: Get-ScapeFATDirectoryEntry
            $entry = Get-ScapeFATDirectoryEntry -Buffer $Buffer -Offset $i
            if ($entry -and -not [string]::IsNullOrWhiteSpace($entry.FileName)) {
                $recovered.Add($entry); $count++
            }
        }
    }
    return $recovered.ToArray()
}

function Get-ScapeExFATStreamExtension {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset
    )
    $type = $Buffer[$Offset]
    if ($type -ne (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_STRM_SIG) { return $null }

    $flags = $Buffer[$Offset + (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_FLAGS_OFF]
    $nameLen = $Buffer[$Offset + (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_NAMELEN_OFF]
    $nameHash = [BitConverter]::ToUInt16($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_NAMEHASH_OFF)
    $validLen = [BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_VALIDLEN_OFF)
    $allocLen = [BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_ALLOCLEN_OFF)
    $firstClus = [BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").FAT.EXFAT_FIRSTCLU_OFF)

    return [PSCustomObject]@{
        Type = "EXFAT_STREAM"; Flags = $flags; NameLength = $nameLen; NameHash = $nameHash
        ValidDataLen = $validLen; AllocatedLen = $allocLen; FirstCluster = $firstClus; Offset = $Offset
    }
}

function Get-ScapeFATMeta {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset,
        [string]$VolumeSerial = ""
    )
    

    # CORREÇÃO: Get-ScapeFATDirectoryEntry
    $entry = Get-ScapeFATDirectoryEntry -Buffer $Buffer -Offset $Offset
    if ($entry) {
        $entry | Add-Member -NotePropertyName "VolumeSerial" -NotePropertyValue $VolumeSerial -Force
        $entry | Add-Member -NotePropertyName "FSType" -NotePropertyValue "FAT32" -Force
        $entry | Add-Member -NotePropertyName "Status" -NotePropertyValue (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"] -Force
        return $entry
    }

    # CORREÇÃO: Get-ScapeExFATStreamExtension
    $exfat = Get-ScapeExFATStreamExtension -Buffer $Buffer -Offset $Offset
    if ($exfat) {
        $exfat | Add-Member -NotePropertyName "VolumeSerial" -NotePropertyValue $VolumeSerial -Force
        $exfat | Add-Member -NotePropertyName "FSType" -NotePropertyValue "exFAT" -Force
        $exfat | Add-Member -NotePropertyName "Status" -NotePropertyValue (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"] -Force
        return $exfat
    }
    return $null
}