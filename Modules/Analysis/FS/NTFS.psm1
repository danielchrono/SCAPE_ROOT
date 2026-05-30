<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.FS.NTFS
    Description: Deep NTFS MFT parser: attribute chains, DATA runs, hard links, EFS stubs.
    Architecture: FP Strict | Zero Hardcode | Constant-Driven | Event-Pipeline Ready
#>


            DB = Get-ScapeConstant -Path "network::DB" -Fallback @{}
        }
        Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
            Action   = "LogLine"
            Key      = "NTFS_PARSER_READY"
            Severity = "LOG_INFO"
        }
    }
}

function Get-ScapeNTFSAttributeList {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Record,
        [Parameter()][int]$BaseOffset = 0
    )
    process {
        

        $attrEnd = 0xFFFFFFFF
        if ((Get-ScapeConstant -Path "storage::FS").ContainsKey("NTFS_ATTR_END")) {
            $attrEnd = (Get-ScapeConstant -Path "storage::FS")["NTFS_ATTR_END"]
        }

        $attrOffOff = 20
        if ((Get-ScapeConstant -Path "storage::FS").ContainsKey("NTFS_MFT_ATTR_OFF")) {
            $attrOffOff = (Get-ScapeConstant -Path "storage::FS")["NTFS_MFT_ATTR_OFF"]
        }

        $attributes = New-Object System.Collections.Generic.List[PSCustomObject]
        if ($attrOffOff -lt 0 -or ($attrOffOff + 2) -gt $Record.Length) {
            return $attributes.ToArray()
        }

        $offset = [BitConverter]::ToUInt16($Record, $attrOffOff)
        while ($offset -lt ($Record.Length - 8)) {
            $type = [BitConverter]::ToUInt32($Record, $offset)
            if ($type -eq $attrEnd -or $type -eq 0) { break }

            $len = [BitConverter]::ToUInt32($Record, $offset + 4)
            if ($len -eq 0 -or ($offset + $len) -gt $Record.Length) { break }

            $nonRes = [BitConverter]::ToBoolean($Record, $offset + 8)

            $nameLen = 0
            $nameOff = 0
            if (-not $nonRes) {
                $nameLen = [int][BitConverter]::ToUInt16($Record, $offset + 9)
                $nameOff = [int][BitConverter]::ToUInt16($Record, $offset + 10)
            }

            $attr = [PSCustomObject]@{
                Type          = $type
                Length        = $len
                NonResident   = $nonRes
                NameLength    = $nameLen
                NameOffset    = $nameOff
                BaseOffset    = $BaseOffset
                Offset        = ($BaseOffset + $offset)
                NameStart     = ($offset + $nameOff)
                NameByteCount = ($nameLen * 2)
                NameEnd       = ($offset + $nameOff + ($nameLen * 2) - 1)
            }

            if ($attr.NameLength -gt 0 -and $attr.NameStart -ge 0 -and $attr.NameEnd -lt $Record.Length) {
                $nameBytes = $Record[$attr.NameStart..$attr.NameEnd]
                $attr | Add-Member -NotePropertyName "Name" -NotePropertyValue ([System.Text.Encoding]::Unicode.GetString($nameBytes))
            }

            $attributes.Add($attr)
            $offset += $len
        }

        return $attributes.ToArray()
    }
}

function Get-ScapeNTFSDataRun {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Record,
        [Parameter()][int]$BaseOffset = 0
    )
    process {
        

        $attrList = Get-ScapeNTFSAttributeList -Record $Record -BaseOffset $BaseOffset
        $targetType = 0x80
        if ((Get-ScapeConstant -Path "storage::FS").ContainsKey("NTFS_ATTR_DATA")) { $targetType = (Get-ScapeConstant -Path "storage::FS")["NTFS_ATTR_DATA"] }

        $dataAttr = $attrList | Where-Object { $_.Type -eq $targetType } | Select-Object -First 1
        if (-not $dataAttr -or $dataAttr.NonResident -eq $false) { return [System.Object[]]@() }

        $runOffPos = [int]$dataAttr.Offset + 0x20
        if ($runOffPos -lt 0 -or ($runOffPos + 2) -gt $Record.Length) { return [System.Object[]]@() }
        $runOff = [BitConverter]::ToUInt16($Record, $runOffPos)

        $runListStart = [int]$dataAttr.Offset + $runOff
        $idx = 0
        $curLCN = 0L
        $runs = New-Object System.Collections.Generic.List[PSCustomObject]

        while (($runListStart + $idx) -lt $Record.Length) {
            $headerPos = $runListStart + $idx
            if ($headerPos -ge $Record.Length) { break }
            $header = $Record[$headerPos]
            if ($header -eq 0) { break }

            $lcnLen = ($header -shr 4) -band 0x0F
            $offLen = $header -band 0x0F
            $idx++

            if (($runListStart + $idx + $lcnLen) -gt $Record.Length) { break }
            $lenBytes = 0L
            for ($j = 0; $j -lt $lcnLen; $j++) { $lenBytes += [long]$Record[$runListStart + $idx] -shl ($j * 8); $idx++ }

            if (($runListStart + $idx + $offLen) -gt $Record.Length) { break }
            $offBytes = 0L
            for ($j = 0; $j -lt $offLen; $j++) { $offBytes += [long]$Record[$runListStart + $idx] -shl ($j * 8); $idx++ }

            if ($offLen -gt 0 -and ($Record[$runListStart + $idx - 1] -band 0x80)) {
                $mask = -1L -shl ($offLen * 8)
                $offBytes = $offBytes -bor $mask
            }

            $curLCN += $offBytes
            $runs.Add([PSCustomObject]@{
                    LcnStart       = $curLCN
                    Length         = $lenBytes
                    Index          = $runs.Count
                    BaseOffset     = $BaseOffset
                    PhysicalOffset = $BaseOffset + ($curLCN * 512)
                })
        }
        return [System.Object[]]$runs.ToArray()
    }
}

function Resolve-ScapeNTFSHardLink {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)][long]$FRN,
        [Parameter(Mandatory = $true)][string]$VolumeSerial,
        [Parameter()][hashtable]$Cache = @{}
    )
    process {
        $cacheKey = "${VolumeSerial}_HL_${FRN}"
        if ($Cache.ContainsKey($cacheKey)) { return [System.Object[]]@($Cache[$cacheKey]) }

        if (Get-Command "Invoke-ScapeDBQuery" -ErrorAction SilentlyContinue) {
            $tbl = "ShadowMFT"
            if ((Get-ScapeConstant -Path "network::DB").ContainsKey("TABLE_MFT")) { $tbl = (Get-ScapeConstant -Path "network::DB")["TABLE_MFT"] }

            $query = "SELECT FileName, ParentFRN FROM {0} WHERE FRN = @frn AND VolumeSerial = @vs" -f $tbl
            $results = Invoke-ScapeDBQuery -Table $tbl -Query $query -Params @{ frn = $FRN; vs = $VolumeSerial }

            if ($results) {
                $links = $results | ForEach-Object { @{ FileName = $_.FileName; ParentFRN = $_.ParentFRN; FullPath = $null } }
                $Cache[$cacheKey] = $links
                return [System.Object[]]@($links)
            }
        }
        return [System.Object[]]@()
    }
}

function Unprotect-ScapeNTFSEFS {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$EncryptedData,
        [Parameter()][string]$KeyProvider = "WindowsDPAPI"
    )
    process {
        $dataSummary = "Size:{0}_Prov:{1}" -f $EncryptedData.Length, $KeyProvider

        Publish-ScapeEvent -Type "LOG_WARN" -Payload @{
            Action  = "LogLine"
            Key     = "EFS_DECRYPTION_STUB"
            Message = "EFS decryption is not supported in this kernel. Context: $dataSummary"
        }
        return @{ Success = $false; Reason = "EFS_STUB_NOT_IMPLEMENTED"; Data = $null }
    }
}

function Get-ScapeNTFSMeta {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Buffer,
        [Parameter(Mandatory = $true)][int]$Offset,
        [Parameter()][string]$VolumeSerial = ""
    )
    process {
        

        if (Get-Command "Set-ScapeFSMeta" -ErrorAction SilentlyContinue) {
            $base = Set-ScapeFSMeta -Buffer $Buffer -Offset $Offset -FSType "FS_NTFS" -VolumeSerial $VolumeSerial
            if ($null -ne $base) {
                $runs = Get-ScapeNTFSDataRun -Record $Buffer -BaseOffset $Offset
                $base | Add-Member -NotePropertyName "DataRuns" -NotePropertyValue $runs
                $base | Add-Member -NotePropertyName "AttributeList" -NotePropertyValue (
                    Get-ScapeNTFSAttributeList -Record $Buffer -BaseOffset $Offset
                )
                return $base
            }
        }

        return $null
    }
}