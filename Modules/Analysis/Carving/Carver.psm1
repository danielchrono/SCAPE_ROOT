<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Carving.Carver
    Description: Deep binary carving loop with adaptive backpressure and hardware-aware tuning.
    Architecture: FP Strict | Zero Hardcode | Event-Pipeline | Backpressure-Aware
#>

$Script:C = $null
$Script:Stats = @{ Processed = 0; Carved = 0; Errors = 0 }

function Initialize-ScapeCarver {
    [CmdletBinding()]
    [OutputType([void])]
    param()

    $Script:C = @{
        ENGINE = Get-ScapeConstant -Path "storage::ENGINE" -Fallback @{}
        HW     = Get-ScapeConstant -Path "hardware" -Fallback @{}
        LIMITS = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
    }

    $hwProfile = Get-ScapeActiveProfile
    $Script:C.ACTIVE = $hwProfile

    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "CARVER_INITIALIZED"; Args = @("Profile: $($Script:C.ACTIVE)", "Batch: $($hwProfile.CARVING_BATCH_SIZE)"); Severity = "LOG_INFO" }
}

function Invoke-ScapeRawCarving {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [byte[]]$Buffer,
        [Parameter(Mandatory = $true)] [long]$PhysicalOffset,
        [Parameter(Mandatory = $true)] [string]$VolumeSerial,
        [switch]$EnableBackpressure
    )

    if (-not $Script:C) { Initialize-ScapeCarver }

    $hwProfile = $Script:C.ACTIVE
    $sectorSize = [int]$Script:C.ENGINE["SECTOR_ALIGNMENT"]
    $bufferLen = $Buffer.Length
    $batchSize = [int]$hwProfile.CARVING_BATCH_SIZE

    $i = 0
    $carvedBatch = [System.Collections.Generic.List[PSCustomObject]]::new()

    while ($i -lt ($bufferLen - $sectorSize)) {
        if ($EnableBackpressure) {
            $pressure = Test-ScapeResourcePressure -Resource "RAM"
            if ($pressure.Critical) {
                Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Key = "CARVING_BACKPRESSURE_CRITICAL"; Severity = "WARN" }
                Start-Sleep -Milliseconds $Script:C.HW.SAFEGUARDS.BACKOFF_MAX_MS
                continue
            }
            elseif ($pressure.Warning) {
                Start-Sleep -Milliseconds $Script:C.HW.SAFEGUARDS.BACKOFF_BASE_MS
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
            $Script:Stats.Carved++

            if ($carvedBatch.Count -ge $batchSize) {
                _FlushCarvedBatch -Batch $carvedBatch
                $carvedBatch.Clear()
            }
            $i += $carveSize
        }
        else {
            $i += $sectorSize
        }
        $Script:Stats.Processed++
    }

    if ($carvedBatch.Count -gt 0) {
        _FlushCarvedBatch -Batch $carvedBatch
    }

    Publish-ScapeEvent -Type "METRIC" -Payload @{ Action = "LogLine"; Key = "CARVING_STATS"; Args = @("Processed: $($Script:Stats.Processed)", "Carved: $($Script:Stats.Carved)", "Errors: $($Script:Stats.Errors)"); Severity = "LOG_DEBUG" }

    return @{ Processed = $Script:Stats.Processed; Carved = $Script:Stats.Carved }
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