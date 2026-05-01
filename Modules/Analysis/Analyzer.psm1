<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Analyzer
    Description: Root orchestrator for Layer 2. Routes raw buffers to FS Abstraction or Raw Carver based on detection.
    Architecture: FP Strict | Zero Hardcode | Event-Pipeline | Hardware-Aware
#>

$Script:C = $null
$Script:Initialized = $false

function Initialize-ScapeAnalyzer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        if ($Script:Initialized) { return }

        $Script:C = @{
            LIMITS = Get-ScapeConstant -Path "behavior::LIMITS" -Fallback @{}
            HW     = Get-ScapeConstant -Path "hardware" -Fallback @{}
        }

        if (Get-Command "Initialize-ScapeAbstraction" -ErrorAction SilentlyContinue) {
            Initialize-ScapeAbstraction | Out-Null
        }
        if (Get-Command "Initialize-ScapeCarver" -ErrorAction SilentlyContinue) {
            Initialize-ScapeCarver | Out-Null
        }

        $Script:Initialized = $true

        Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "ANALYZER_INITIALIZED"; Severity = "LOG_INFO" }
    }
}

function Start-ScapeAnalysisStream {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [byte[]]$SectorBuffer,
        [Parameter(Mandatory = $true)] [long]$PhysicalOffset,
        [Parameter(Mandatory = $true)] [string]$VolumeSerial,
        [switch]$ForceCarving
    )
    process {
        if (-not $PSCmdlet.ShouldProcess("Sector at Offset $PhysicalOffset", "Analyze Stream")) {
            return @{ Success = $false; Reason = 'ShouldProcessDenied'; Data = $null }
        }

        if (-not $Script:Initialized) { Initialize-ScapeAnalyzer }

        if (-not $ForceCarving) {
            $fsType = Resolve-ScapeFSType -Buffer $SectorBuffer

            if ($fsType -ne "STATE_UNKNOWN") {
                $result = Invoke-ScapeFSParser -FSType $fsType -Buffer $SectorBuffer -Offset $PhysicalOffset -VolumeSerial $VolumeSerial

                if ($null -ne $result) {
                    Publish-ScapeEvent -Type "LOG_DEBUG" -Payload @{ Action = "LogLine"; Message = "FS parsed: $fsType at offset $PhysicalOffset" }
                    return $result
                }
            }
        }

        $activeProfile = Get-ScapeActiveProfile
        $ramLimit = if ($activeProfile -and $activeProfile.ContainsKey('RAM_BUFFER_MB')) { [int]$activeProfile['RAM_BUFFER_MB'] } else { 0 }
        $enableBP = $ramLimit -lt 128

        $result = Invoke-ScapeRawCarving -Buffer $SectorBuffer -PhysicalOffset $PhysicalOffset -VolumeSerial $VolumeSerial -EnableBackpressure:$enableBP

        Publish-ScapeEvent -Type "LOG_DEBUG" -Payload @{ Action = "LogLine"; Message = "Carving completed: $($result.Carved) artifacts at offset $PhysicalOffset" }

        return $result
    }
    end {
        if (-not $PSBoundParameters.ContainsKey('SectorBuffer')) {
            return @{ Success = $false; Reason = 'MissingParameters'; Data = $null }
        }
    }
}

function Invoke-ScapeBatchAnalysis {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)] [byte[][]]$SectorBatch,
        [Parameter(Mandatory = $true)] [long]$BaseOffset,
        [Parameter(Mandatory = $true)] [string]$VolumeSerial,
        [Parameter()][int]$SectorSize = 512
    )
    process {
        if (-not $PSCmdlet.ShouldProcess("Batch of $($SectorBatch.Count) sectors", "Batch Analysis")) { return @() }
        if (-not $Script:Initialized) { Initialize-ScapeAnalyzer }

        $results = New-Object System.Collections.Generic.List[hashtable]
        $progressInterval = [Math]::Max(100, [Math]::Floor($SectorBatch.Count / 10))

        for ($i = 0; $i -lt $SectorBatch.Count; $i++) {
            $offset = $BaseOffset + ($i * $SectorSize)
            $result = Start-ScapeAnalysisStream -SectorBuffer $SectorBatch[$i] -PhysicalOffset $offset -VolumeSerial $VolumeSerial
            $results.Add(@{ Index = $i; Offset = $offset; Result = $result })

            if ($i % $progressInterval -eq 0) {
                Publish-ScapeEvent -Type "PROGRESS" -Payload @{ Action = "ProgressBar"; TaskID = 1; Current = $i; Total = $SectorBatch.Count; Label = "Analyzing sectors..." }
            }
        }
        return [System.Object[]]$results.ToArray()
    }
}