<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.Abstraction
    Description: Universal filesystem detection router. Identifies 15+ FS types and disk image containers, delegates to specialized parsers.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline | Lazy-Load Parsers
#>

$Script:LoadedParsers = @{}
$Script:DetectionCache = @{}


function Get-ScapeAbstractionConfig {
    $fs = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
    return @{
        FS      = $fs
        CARVING = Get-ScapeConstant -Path "storage::SIGNATURES" -Fallback @{}
        HW      = Get-ScapeConstant -Path "system::PROFILES" -Fallback @{}
        LIMITS  = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
        FS_SIGS = @{
            NTFS_MFT   = Convert-ScapeHexToByte -Hex ($fs["NTFS_MFT_SIG"].ToString("X8"))
            NTFS_BOOT  = Convert-ScapeHexToByte -Hex "4E54465320202020"
            FAT_BOOT   = [BitConverter]::GetBytes($fs["FAT_BOOT_SIG"])
            EXFAT_VBR  = Convert-ScapeHexToByte -Hex ($fs["EXFAT_VBR_SIG"].ToString("X16"))
            EXT_SB     = [BitConverter]::GetBytes($fs["EXT4_SB_SIG"])
            BTRFS_SB   = Convert-ScapeHexToByte -Hex ($fs["BTRFS_SB_SIG"].ToString("X16"))
            XFS_SB     = Convert-ScapeHexToByte -Hex ($fs["XFS_SB_SIG"].ToString("X8"))
            ZFS_UBER   = [BitConverter]::GetBytes($fs["ZFS_UBER_SIG"])
            ZFS_LABEL  = Convert-ScapeHexToByte -Hex ($fs["ZFS_LABEL_SIG"].ToString("X16"))
            APFS_SB    = Convert-ScapeHexToByte -Hex ($fs["APFS_SB_SIG"].ToString("X8"))
            REFS_SB    = Convert-ScapeHexToByte -Hex ($fs["REFS_SIG"].ToString("X8"))
            HFS_PLUS   = [BitConverter]::GetBytes($fs["HFS_PLUS_SIG"])
            HFSX       = [BitConverter]::GetBytes($fs["HFSX_SIG"])
            UDF_VRS    = Convert-ScapeHexToByte -Hex ($fs["UDF_SIG"].ToString("X8"))
            F2FS_SB    = [BitConverter]::GetBytes($fs["F2FS_SB_SIG"])
            JFS_SUPER  = Convert-ScapeHexToByte -Hex ($fs["JFS_SUPER_SIG"].ToString("X8"))
            VMDK       = Convert-ScapeHexToByte -Hex "4B444D56"
            VHD        = Convert-ScapeHexToByte -Hex "636F6E6563746978"
            VHDX       = Convert-ScapeHexToByte -Hex "7668647866696C65"
            QCOW2      = Convert-ScapeHexToByte -Hex "514649FB"
            DMG        = Convert-ScapeHexToByte -Hex "7801730D626260"
            ISO9660    = Convert-ScapeHexToByte -Hex "4344303031"
            GPT_HEADER = Convert-ScapeHexToByte -Hex "4546492050415254"
            MBR_SIG    = [BitConverter]::GetBytes([uint16]0xAA55)
        }
    }
}

# =============================================================================
# BYTE READING UTILS
# =============================================================================
function Read-ScapeRawBytes {
    param($Buf, $Off, $Len)
    if (($Off + $Len) -gt $Buf.Length) { return @() }
    return $Buf[$Off..($Off + $Len - 1)]
}

function Test-ScapeBytePatternMatch {
    param($Buf, $Off, $Pattern)
    $actual = Read-ScapeRawBytes -Buf $Buf -Off $Off -Len $Pattern.Length
    return ($actual -join ',') -eq ($Pattern -join ',')
}

function Read-ScapeUInt16LE { param($Buf, $Off) return [BitConverter]::ToUInt16($Buf, $Off) }
function Read-ScapeUInt32LE { param($Buf, $Off) return [BitConverter]::ToUInt32($Buf, $Off) }
function Read-ScapeUInt64LE { param($Buf, $Off) return [BitConverter]::ToUInt64($Buf, $Off) }
function Read-ScapeInt64LE { param($Buf, $Off) return [BitConverter]::ToInt64($Buf, $Off) }
function Read-ScapeUInt32BE {
    param($Buf, $Off)
    $b = $Buf[$Off..($Off + 3)]
    [Array]::Reverse($b)
    return [BitConverter]::ToUInt32($b, 0)
}
function Read-ScapeUInt64BE {
    param($Buf, $Off)
    $b = $Buf[$Off..($Off + 7)]
    [Array]::Reverse($b)
    return [BitConverter]::ToUInt64($b, 0)
}

# =============================================================================
# FS DETECTION ENGINE
# =============================================================================
function Resolve-ScapeFSType {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter()][long]$Offset = 0,
        [Parameter()][string]$VolumeSerial = "",
        [Parameter()][switch]$ForceRescan
    )


    if ($Buffer.Length -lt 512) { return "STATE_UNKNOWN" }

    $cacheKey = "${VolumeSerial}_${Offset}_${Buffer.Length}"
    if (-not $ForceRescan -and $Script:DetectionCache.ContainsKey($cacheKey)) {
        return $Script:DetectionCache[$cacheKey]
    }

    $result = "STATE_UNKNOWN"

    if (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.NTFS_MFT) { $result = "NTFS_MFT" }
    elseif ($Buffer.Length -ge ($Offset + 11) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off ($Offset + 3) -Pattern $c.FS_SIGS.NTFS_BOOT)) { $result = "NTFS_BOOT" }
    elseif ($Buffer.Length -ge ($Offset + 4) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.REFS_SB)) { $result = "FS_REFS" }
    elseif ($Buffer.Length -ge ($Offset + 512)) {
        $bootSig = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + 510)
        $fatBootSig = $c.FS["FAT_BOOT_SIG"]
        if ($fatBootSig -and $bootSig -eq $fatBootSig) {
            $oem = [System.Text.Encoding]::ASCII.GetString($Buffer, ($Offset + 3), 8).Trim()
            if ($oem -match 'FAT32|MSWIN|MSDOS') { $result = "FAT32" }
            elseif ($oem -match 'EXFAT|exFAT') { $result = "EXFAT" }
        }
    }
    elseif ($Buffer.Length -ge ($Offset + 8) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.EXFAT_VBR)) { $result = "EXFAT" }

    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 0x43A)) {
        $extMagic = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + 0x438)
        $extSig = $c.FS["EXT4_SB_SIG"]
        if ($extSig -and $extMagic -eq $extSig) { $result = "EXT4" }
    }
    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 4) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.XFS_SB)) { $result = "XFS" }
    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 72) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off ($Offset + 0x40) -Pattern $c.FS_SIGS.BTRFS_SB)) { $result = "FS_BTRFS" }
    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 0x404)) {
        $f2fsMagic = Read-ScapeUInt32LE -Buf $Buffer -Off ($Offset + 0x400)
        $f2fsSig = $c.FS["F2FS_SB_SIG"]
        if ($f2fsSig -and $f2fsMagic -eq $f2fsSig) { $result = "F2FS" }
    }
    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 4) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.JFS_SUPER)) { $result = "JFS" }

    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 36) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off ($Offset + 0x20) -Pattern $c.FS_SIGS.APFS_SB)) { $result = "FS_APFS" }
    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 1026)) {
        $hfsSig = Read-ScapeUInt16LE -Buf $Buffer -Off ($Offset + 1024)
        $hfsPlusSig = $c.FS["HFS_PLUS_SIG"]
        $hfsxSig = $c.FS["HFSX_SIG"]
        if ($hfsPlusSig -and $hfsSig -eq $hfsPlusSig) { $result = "HFS_PLUS" }
        elseif ($hfsxSig -and $hfsSig -eq $hfsxSig) { $result = "HFSX" }
    }

    if ($result -eq "STATE_UNKNOWN") {
        if ($Buffer.Length -ge ($Offset + 8) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.ZFS_LABEL)) { $result = "ZFS_LABEL" }
        elseif ($Buffer.Length -ge ($Offset + 4)) {
            $uberMagic = Read-ScapeUInt32LE -Buf $Buffer -Off $Offset
            $uberSig = $c.FS["ZFS_UBER_SIG"]
            if ($uberSig -and $uberMagic -eq $uberSig) { $result = "ZFS_UBER" }
        }
    }

    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 0x8005)) {
        if (Test-ScapeBytePatternMatch -Buf $Buffer -Off ($Offset + 0x8000) -Pattern $c.FS_SIGS.UDF_VRS) { $result = "UDF" }
    }
    if ($result -eq "STATE_UNKNOWN" -and $Buffer.Length -ge ($Offset + 0x8006)) {
        if (Test-ScapeBytePatternMatch -Buf $Buffer -Off ($Offset + 0x8001) -Pattern $c.FS_SIGS.ISO9660) { $result = "ISO9660" }
    }

    if ($result -eq "STATE_UNKNOWN") {
        if ($Buffer.Length -ge ($Offset + 4) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.VMDK)) { $result = "VMDK" }
        elseif ($Buffer.Length -ge ($Offset + 8) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.VHD)) { $result = "VHD" }
        elseif ($Buffer.Length -ge ($Offset + 8) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.VHDX)) { $result = "VHDX" }
        elseif ($Buffer.Length -ge ($Offset + 4) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.QCOW2)) { $result = "QCOW2" }
        elseif ($Buffer.Length -ge ($Offset + 7) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.DMG)) { $result = "DMG" }
        elseif ($Buffer.Length -ge ($Offset + 8) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off $Offset -Pattern $c.FS_SIGS.GPT_HEADER)) { $result = "GPT" }
        elseif ($Buffer.Length -ge ($Offset + 512) -and (Test-ScapeBytePatternMatch -Buf $Buffer -Off ($Offset + 510) -Pattern $c.FS_SIGS.MBR_SIG)) { $result = "MBR" }
    }

    $Script:DetectionCache[$cacheKey] = $result

    if ($result -ne "STATE_UNKNOWN") {
        Publish-ScapeEvent -Type "FS_DETECTED" -Payload @{
            VolumeSerial = $VolumeSerial
            Offset       = $Offset
            FSType       = $result
            BufferLen    = $Buffer.Length
            Timestamp    = [DateTime]::UtcNow
        }
    }

    return $result
}

# =============================================================================
# PARSER LOADING (Lazy, On-Demand)
# =============================================================================
function Invoke-ScapeParserModuleLoad {
    param([string]$FSType)

    if ($Script:LoadedParsers.ContainsKey($FSType)) { return $true }

    $parserMap = @{
        "NTFS_MFT"  = "Get-ScapeNTFSMeta"
        "NTFS_BOOT" = "Get-ScapeRawSector"
        "FAT32"     = "Get-ScapeFATMeta"
        "EXFAT"     = "Get-ScapeFATMeta"
        "EXT4"      = "Get-ScapeEXTMeta"
        "EXT3"      = "Get-ScapeEXTMeta"
        "EXT2"      = "Get-ScapeEXTMeta"
        "FS_BTRFS"  = "Get-ScapeBTRFSMeta"
        "XFS"       = "Get-ScapeXFSMeta"
        "ZFS_LABEL" = "Get-ScapeZFSMeta"
        "ZFS_UBER"  = "Get-ScapeZFSMeta"
        "FS_APFS"   = "Get-ScapeAPFSMeta"
        "FS_REFS"   = "Get-ScapeREFSMeta"
        "HFS_PLUS"  = "Get-ScapeHFSMeta"
        "HFSX"      = "Get-ScapeHFSMeta"
        "F2FS"      = "Get-ScapeF2FSMeta"
        "JFS"       = "Get-ScapeJFSMeta"
        "UDF"       = "Get-ScapeUDFMeta"
        "ISO9660"   = "Get-ScapeISO9660Meta"
        "VMDK"      = "Get-ScapeVMDKMeta"
        "VHD"       = "Get-ScapeVHDMeta"
        "VHDX"      = "Get-ScapeVHDXMeta"
        "QCOW2"     = "Get-ScapeQCOW2Meta"
        "DMG"       = "Get-ScapeDMGMeta"
        "GPT"       = "Get-ScapeGPTMeta"
        "MBR"       = "Get-ScapeMBRMeta"
    }

    $funcName = $parserMap[$FSType]
    if (-not $funcName) { return $false }

    if (Get-Command $funcName -ErrorAction SilentlyContinue) {
        $Script:LoadedParsers[$FSType] = $funcName
        return $true
    }

    $state = Get-ScapeColdState
    $assetKey = switch ($FSType) {
        { $_ -match "^NTFS" } { "FS_NTFS" }
        { $_ -match "^(FAT|EXFAT)" } { "fat" }
        { $_ -match "^EXT" } { "ext" }
        "FS_BTRFS" { "FS_BTRFS" }
        "XFS" { "xfs" }
        { $_ -match "^ZFS" } { "FS_ZFS" }
        "FS_APFS" { "FS_APFS" }
        "FS_REFS" { "FS_REFS" }
        { $_ -match "^HFS" } { "hfs" }
        "F2FS" { "f2fs" }
        "JFS" { "jfs" }
        "UDF" { "udf" }
        "ISO9660" { "iso9660" }
        { $_ -match "^(VMDK|VHD|VHDX|QCOW2|DMG)" } { "diskimage" }
        { $_ -match "^(GPT|MBR)" } { "partitiontable" }
        default { $null }
    }

    if ($assetKey -and $state["SYS_ASSETS_DIR"].ContainsKey($assetKey)) {
        if (Get-Command $funcName -ErrorAction SilentlyContinue) {
            $Script:LoadedParsers[$FSType] = $funcName
            Publish-ScapeEvent -Type "LOG_DEBUG" -Payload @{ Action = "LogLine"; Message = "Lazy-loaded parser: $FSType -> $funcName" }
            return $true
        }
    }

    if (Get-Command "Set-ScapeFSMeta" -ErrorAction SilentlyContinue) {
        $Script:LoadedParsers[$FSType] = "Set-ScapeFSMeta"
        return $true
    }

    return $false
}

# =============================================================================
# UNIFIED PARSER INTERFACE
# =============================================================================
function Invoke-ScapeFSParser {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)][string]$FSType,
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][long]$Offset,
        [Parameter()][string]$VolumeSerial = "",
        [Parameter()][hashtable]$Context = @{}
    )



    if (-not (Invoke-ScapeParserModuleLoad -FSType $FSType)) {
        Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Key = "PARSER_NOT_AVAILABLE"; Args = @($FSType); Severity = "WARN" }

        if (Get-Command "Set-ScapeFSMeta" -ErrorAction SilentlyContinue) {
            $result = Set-ScapeFSMeta -Buffer $Buffer -Offset $Offset -FSType $FSType -VolumeSerial $VolumeSerial
            if ($result) { return $result }
        }
        return $null
    }

    $funcName = $Script:LoadedParsers[$FSType]

    try {
        $result = & $funcName -Buffer $Buffer -Offset $Offset -VolumeSerial $VolumeSerial @Context

        if ($result) {
            $result | Add-Member -NotePropertyName "DetectedFSType" -NotePropertyValue $FSType -Force
            $result | Add-Member -NotePropertyName "ParsedAtOffset" -NotePropertyValue $Offset -Force
            $result | Add-Member -NotePropertyName "ParsedAtTimestamp" -NotePropertyValue ([DateTime]::UtcNow) -Force

            if (Get-Command "Test-ScapeMetadataIntegrity" -ErrorAction SilentlyContinue) {
                if (-not (Test-ScapeMetadataIntegrity $result)) {
                    Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Key = "METADATA_VALIDATION_FAILED"; Args = @($FSType, $Offset) }
                }
            }

            Publish-ScapeEvent -Type "FS_RECORD_EXTRACTED" -Payload @{
                VolumeSerial = $VolumeSerial
                Record       = $result
                Category     = "FileSystem"
                FSType       = $FSType
                Timestamp    = [DateTime]::UtcNow
            }

            return $result
        }
    }
    catch {
        Publish-ScapeEvent -Type "LOG_ERR" -Payload @{ Action = "LogLine"; Key = "PARSER_EXCEPTION"; Args = @($FSType, $_.Exception.Message); Severity = "LOG_ERR" }
    }

    return $null
}

# =============================================================================
# BATCH PROCESSING (Refactored ThreadJob variables for Scope Safety)
# =============================================================================
function Invoke-ScapeBatchFSAnalysis {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][byte[][]]$SectorBatch,
        [Parameter(Mandatory = $true)][long]$BaseOffset,
        [Parameter(Mandatory = $true)][string]$VolumeSerial,
        [Parameter()][int]$SectorSize = 512,
        [Parameter()][switch]$EnableParallelism
    )



    $maxParallel = 1
    if ($EnableParallelism) {
        $activeProfile = Get-ScapeActiveProfile
        if ($activeProfile -and $activeProfile.MAX_PARALLEL_OPS) {
            $maxParallel = [int]$activeProfile.MAX_PARALLEL_OPS
        }
        else {
            $maxParallel = 16
        }
    }

    $results = New-Object System.Collections.Concurrent.ConcurrentBag[PSCustomObject]

    if ($maxParallel -le 1) {
        for ($i = 0; $i -lt $SectorBatch.Count; $i++) {
            $offset = $BaseOffset + ($i * $SectorSize)
            $fsType = Resolve-ScapeFSType -Buffer $SectorBatch[$i] -Offset $offset -VolumeSerial $VolumeSerial
            if ($fsType -ne "STATE_UNKNOWN") {
                $record = Invoke-ScapeFSParser -FSType $fsType -Buffer $SectorBatch[$i] -Offset $offset -VolumeSerial $VolumeSerial
                if ($record) {
                    $results.Add([PSCustomObject]@{ Index = $i; Offset = $offset; FSType = $fsType; Record = $record })
                }
            }
        }
        return $results.ToArray()
    }

    $throttle = [System.Threading.SemaphoreSlim]::new($maxParallel)
    $tasks = New-Object System.Collections.Generic.List[System.Management.Automation.Job]

    for ($i = 0; $i -lt $SectorBatch.Count; $i++) {
        while (-not $throttle.Wait(0)) {
            if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
            else { [System.Threading.Thread]::Sleep(10) }
        }

        # Isolando escopo local para o Linter e para o ThreadJob injetar com `$using:`
        $localBuf = $SectorBatch[$i]
        $localOff = $BaseOffset + ($i * $SectorSize)
        $localVol = $VolumeSerial
        $localIdx = $i

        $task = Start-ThreadJob -ScriptBlock {
            try {
                $fsType = Resolve-ScapeFSType -Buffer $using:localBuf -Offset $using:localOff -VolumeSerial $using:localVol
                if ($fsType -ne "STATE_UNKNOWN") {
                    $record = Invoke-ScapeFSParser -FSType $fsType -Buffer $using:localBuf -Offset $using:localOff -VolumeSerial $using:localVol
                    if ($record) {
                        ($using:results).Add([PSCustomObject]@{ Index = $using:localIdx; Offset = $using:localOff; FSType = $fsType; Record = $record })
                    }
                }
            }
            finally {
                $null = ($using:throttle).Release()
            }
        }

        $tasks.Add($task)

        if ($i % 100 -eq 0) {
            Publish-ScapeEvent -Type "PROGRESS" -Payload @{ Action = "ProgressBar"; TaskID = 1; Current = $i; Total = $SectorBatch.Count; Label = "Analyzing structures..." }
            if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
        }
    }

    $deadline = [DateTime]::UtcNow.AddSeconds(300)
    while ( ($tasks | Where-Object { $_.State -eq 'Running' -or $_.State -eq 'NotStarted' }) -and [DateTime]::UtcNow -lt $deadline) {
        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
        [System.Threading.Thread]::Sleep(10)
    }
    $tasks | Remove-Job -Force
    $null = $throttle.Dispose()

    return $results.ToArray()
}

# =============================================================================
# CONTAINER HANDLING
# =============================================================================
function Invoke-ScapeContainerParser {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][string]$ContainerType,
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][long]$Offset,
        [Parameter()][string]$VolumeSerial = ""
    )

    $containerInfo = switch ($ContainerType) {
        "VMDK" { if (Get-Command "Set-ScapeVMDKHeader" -ErrorAction SilentlyContinue) { Set-ScapeVMDKHeader -Buffer $Buffer -Offset $Offset } }
        "VHD" { if (Get-Command "Set-ScapeVHDHeader" -ErrorAction SilentlyContinue) { Set-ScapeVHDHeader -Buffer $Buffer -Offset $Offset } }
        "VHDX" { if (Get-Command "Set-ScapeVHDXHeader" -ErrorAction SilentlyContinue) { Set-ScapeVHDXHeader -Buffer $Buffer -Offset $Offset } }
        "QCOW2" { if (Get-Command "Set-ScapeQCOW2Header" -ErrorAction SilentlyContinue) { Set-ScapeQCOW2Header -Buffer $Buffer -Offset $Offset } }
        "DMG" { if (Get-Command "Set-ScapeDMGHeader" -ErrorAction SilentlyContinue) { Set-ScapeDMGHeader -Buffer $Buffer -Offset $Offset } }
        "GPT" { if (Get-Command "Set-ScapeGPTHeader" -ErrorAction SilentlyContinue) { Set-ScapeGPTHeader -Buffer $Buffer -Offset $Offset } }
        "MBR" { if (Get-Command "Set-ScapeMBRHeader" -ErrorAction SilentlyContinue) { Set-ScapeMBRHeader -Buffer $Buffer -Offset $Offset } }
        default { $null }
    }

    if (-not $containerInfo -or -not $containerInfo.Partitions) { return $null }

    $innerResults = New-Object System.Collections.Generic.List[PSCustomObject]

    foreach ($part in $containerInfo.Partitions) {
        [byte[]]$partBuffer = if ($part.Size -le $Buffer.Length) {
            $Buffer[0..([Math]::Min($part.Size, $Buffer.Length) - 1)]
        }
        else {
            $Buffer
        }

        $innerFS = Resolve-ScapeFSType -Buffer $partBuffer -Offset 0 -VolumeSerial "${VolumeSerial}_PART$($part.Index)"
        if ($innerFS -ne "STATE_UNKNOWN") {
            $innerRecord = Invoke-ScapeFSParser -FSType $innerFS -Buffer $partBuffer -Offset 0 -VolumeSerial "${VolumeSerial}_PART$($part.Index)"
            if ($innerRecord) {
                $innerRecord | Add-Member -NotePropertyName "ContainerType" -NotePropertyValue $ContainerType
                $innerRecord | Add-Member -NotePropertyName "PartitionIndex" -NotePropertyValue $part.Index
                $innerResults.Add($innerRecord)
            }
        }
    }

    if ($innerResults.Count -gt 0) { return $innerResults.ToArray() } else { return $null }
}

Export-ModuleMember -Function 'Get-ScapeAbstractionConfig',
'Read-ScapeRawBytes',
'Test-ScapeBytePatternMatch',
'Read-ScapeUInt16LE',
'Read-ScapeUInt32LE',
'Read-ScapeUInt64LE',
'Read-ScapeInt64LE',
'Read-ScapeUInt32BE',
'Read-ScapeUInt64BE',
'Resolve-ScapeFSType',
'Invoke-ScapeParserModuleLoad',
'Invoke-ScapeFSParser',
'Invoke-ScapeBatchFSAnalysis',
'Invoke-ScapeContainerParser'
