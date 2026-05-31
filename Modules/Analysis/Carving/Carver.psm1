<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Carving.Carver
    Description: Deep binary carving loop with adaptive backpressure and hardware-aware tuning.
    Architecture: FP Strict | Zero Hardcode | Event-Pipeline | Backpressure-Aware
#>

$Script:Stats = @{ Processed = 0; Carved = 0; Errors = 0 } # Deprecated in favor of FP


function Invoke-ScapeRawCarving {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [byte[]]$Buffer,
        [Parameter(Mandatory = $true)] [long]$PhysicalOffset,
        [Parameter(Mandatory = $true)] [string]$VolumeSerial,
        [switch]$EnableBackpressure
    )



    $hwProfile = $Script:C.ACTIVE
    $sectorSize = [int]$Script:C.ENGINE["SECTOR_ALIGNMENT"]
    $bufferLen = $Buffer.Length
    $batchSize = [int]$hwProfile.CARVING_BATCH_SIZE

    $i = 0
    $carvedBatch = [System.Collections.Generic.List[PSCustomObject]]::new()
    $localStats = @{ Processed = 0; Carved = 0; Errors = 0 }

    while ($i -lt ($bufferLen - $sectorSize)) {
        if ($EnableBackpressure) {
            $pressure = Test-ScapeResourcePressure -Resource "RAM"
            if ($pressure.Critical) {
                Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Key = "CARVING_BACKPRESSURE_CRITICAL"; Severity = "WARN" }
                $deadline = [DateTime]::UtcNow.AddMilliseconds((Get-ScapeConstant -Path "system::PROFILES").SAFEGUARDS.BACKOFF_MAX_MS)
                while ([DateTime]::UtcNow -lt $deadline) {
                    if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
                }
                continue
            }
            elseif ($pressure.Warning) {
                $deadline = [DateTime]::UtcNow.AddMilliseconds((Get-ScapeConstant -Path "system::PROFILES").SAFEGUARDS.BACKOFF_BASE_MS)
                while ([DateTime]::UtcNow -lt $deadline) {
                    if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
                }
            }
        }

        $match = Find-ScapeSignatureAtOffset -SectorBuffer $Buffer -Offset $i

        if ($null -ne $match) {
            $carveSize = [Math]::Min([long]$match.MaxSize, ($bufferLen - $i))
            $carvedData = [byte[]]::new($carveSize)
            [System.Array]::Copy($Buffer, $i, $carvedData, 0, $carveSize)

            $artifact = [PSCustomObject]@{
                VolumeSerial = $VolumeSerial
                SignatureID  = $match.Id
                Category     = $match.Category
                Extension    = $match.Extension
                RawRecord    = $carvedData
                Offset       = ($PhysicalOffset + $i)
                Size         = $carveSize
                Confidence   = if ($match.RequireExact) { 1.0 } else { 0.8 }
                Timestamp    = [DateTime]::UtcNow
            }

            $carvedBatch.Add($artifact)
            $localStats.Carved++

            if ($carvedBatch.Count -ge $batchSize) {
                _FlushCarvedBatch -Batch $carvedBatch
                $carvedBatch.Clear()
            }
            $i += $carveSize
        }
        else {
            $i += $sectorSize
        }
        $localStats.Processed++
    }

    if ($carvedBatch.Count -gt 0) {
        _FlushCarvedBatch -Batch $carvedBatch
    }

    Publish-ScapeEvent -Type "METRIC" -Payload @{ Action = "LogLine"; Key = "CARVING_STATS"; Args = @("Processed: $($localStats.Processed)", "Carved: $($localStats.Carved)", "Errors: $($localStats.Errors)"); Severity = "LOG_DEBUG" }

    return @{ Processed = $localStats.Processed; Carved = $localStats.Carved }
}

function _FlushCarvedBatch {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[PSCustomObject]]$Batch)

    if ($Batch.Count -eq 0) { return }

    Publish-ScapeEvent -Type "CARVED_ARTIFACT_BATCH" -Payload @{ VolumeSerial = $Batch[0].VolumeSerial; Count = $Batch.Count; Artifacts = $Batch; Timestamp = [DateTime]::UtcNow }
}

function Get-ScapeCarverStat {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    return $Script:Stats.Clone()
}

function Reset-ScapeCarverStat {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param()
    if ($PSCmdlet.ShouldProcess("CarverStats", "Reset Data")) {
        $Script:Stats = @{ Processed = 0; Carved = 0; Errors = 0 }
    }
}
