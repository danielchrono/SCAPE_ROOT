<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.DiskImage
    Description: Parsers for VMDK, VHD, VHDX, QCOW2, DMG disk image headers.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>


        DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
    }
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "DISKIMAGE_PARSER_READY"; Severity = "LOG_INFO" }
}

function Get-ScapeVMDKMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    
    if ($Buffer.Length -lt 4) { return $null }

    $sig = [System.Text.Encoding]::ASCII::GetString($Buffer, $Offset, 4)
    if ($sig -ne (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VMDK_SIG) { return $null }

    $version = [System.BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VMDK_VERSION_OFF)
    $flags = [System.BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VMDK_FLAGS_OFF)
    $capacity = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VMDK_CAPACITY_OFF)
    $grainSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VMDK_GRAINSIZE_OFF)

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "VMDK"; Status = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        FileName = "<VMDK>"; RealSize = $capacity; IsDirectory = $false; IsDeleted = $false
        Version = $version; Flags = $flags; GrainSize = $grainSize; ParsedAtOffset = $Offset
    }
}

function Get-ScapeVHDMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    
    if ($Buffer.Length -lt 8) { return $null }

    $sig = [System.Text.Encoding]::ASCII::GetString($Buffer, $Offset, 8)
    if ($sig -ne (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHD_SIG) { return $null }

    $fileSize = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHD_FILESIZE_OFF)
    $diskGeometry = [System.BitConverter]::ToUInt16($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHD_GEOMETRY_OFF)

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "VHD"; Status = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        FileName = "<VHD>"; RealSize = $fileSize; IsDirectory = $false; IsDeleted = $false
        DiskGeometry = $diskGeometry; ParsedAtOffset = $Offset
    }
}

function Get-ScapeVHDXMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    
    if ($Buffer.Length -lt 8) { return $null }

    $sig = [System.Text.Encoding]::ASCII::GetString($Buffer, $Offset, 8)
    if ($sig -ne (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHDX_SIG) { return $null }

    $fileSize = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHDX_FILESIZE_OFF)
    $logicalSectorSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHDX_LOGSECTOR_OFF)
    $physicalSectorSize = [System.BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.VHDX_PHYSECTOR_OFF)

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "VHDX"; Status = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        FileName = "<VHDX>"; RealSize = $fileSize; IsDirectory = $false; IsDeleted = $false
        LogicalSectorSize = $logicalSectorSize; PhysicalSectorSize = $physicalSectorSize; ParsedAtOffset = $Offset
    }
}

function Get-ScapeQCOW2Meta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    
    if ($Buffer.Length -lt 4) { return $null }

    $magic = [System.BitConverter]::ToUInt32($Buffer, $Offset)
    if ($magic -ne (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.QCOW2_MAGIC) { return $null }

    $version = [System.BitConverter]::ToUInt32($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.QCOW2_VERSION_OFF)
    $backingFileOffset = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.QCOW2_BACKING_OFF)
    $size = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.QCOW2_SIZE_OFF)
    $clusterBits = $Buffer[$Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.QCOW2_CLUSTERBITS_OFF]
    $clusterSize = 1 -shl $clusterBits

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "QCOW2"; Status = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        FileName = "<QCOW2>"; RealSize = $size; IsDirectory = $false; IsDeleted = $false
        Version = $version; ClusterSize = $clusterSize; BackingFileOffset = $backingFileOffset; ParsedAtOffset = $Offset
    }
}

function Get-ScapeDMGMeta {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([Parameter(Mandatory = $true)][byte[]]$Buffer, [Parameter(Mandatory = $true)][int]$Offset, [string]$VolumeSerial = "")

    
    if ($Buffer.Length -lt 0x10) { return $null }

    $sig = [System.Text.Encoding]::ASCII::GetString($Buffer, $Offset + 0x0C, 4)
    if ($sig -ne (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.DMG_SIG) { return $null }

    $size = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.DMG_SIZE_OFF)
    $dataForkOffset = [System.BitConverter]::ToUInt64($Buffer, $Offset + (Get-ScapeConstant -Path "storage::FS").DISKIMAGE.DMG_DATAFORK_OFF)

    return [PSCustomObject]@{
        VolumeSerial = $VolumeSerial; FSType = "DMG"; Status = (Get-ScapeConstant -Path "network::DB")["STATUS_DISC"]
        FileName = "<DMG>"; RealSize = $size; IsDirectory = $false; IsDeleted = $false
        DataForkOffset = $dataForkOffset; ParsedAtOffset = $Offset
    }
}