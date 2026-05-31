<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Analyzer
    Description: Root orchestrator for Layer 2. Routes raw buffers to FS Abstraction or Raw Carver based on detection.
    Architecture: FP Strict | Zero Hardcode | Event-Pipeline | Hardware-Aware | TreeView-Ready
#>

$Script:Initialized = $false


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

        # â”€â”€ TreeView Hook: Notifica inÃ­cio do parsing por setor â”€â”€
        if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
            Publish-ScapeTreeUpdate -TreeId 'Analysis_Stream' -TitleKey 'ANALYSIS_FS_PARSED' -Nodes @(
                @{ Path = "$VolumeSerial/Stream/Offset_$PhysicalOffset"; Icon = "Processing"; Status = 'Loading' }
            )
        }

        if (-not $ForceCarving) {
            $fsType = Resolve-ScapeFSType -Buffer $SectorBuffer

            if ($fsType -ne "STATE_UNKNOWN") {
                $result = Invoke-ScapeFSParser -FSType $fsType -Buffer $SectorBuffer -Offset $PhysicalOffset -VolumeSerial $VolumeSerial

                if ($null -ne $result) {
                    # â”€â”€ TreeView Hook: Atualiza status para Ready quando FS Ã© parseado â”€â”€
                    if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
                        Publish-ScapeTreeUpdate -TreeId 'Analysis_Stream' -TitleKey 'ANALYSIS_FS_PARSED' -Nodes @(
                            @{ Path = "$VolumeSerial/FS/$fsType/Offset_$PhysicalOffset"; Icon = "Database"; Status = 'Ready' }
                        )
                    }
                    Publish-ScapeEvent -Type "LOG_DEBUG" -Payload @{ Action = "LogLine"; Message = "FS parsed: $fsType at offset $PhysicalOffset" }
                    return $result
                }
            }
        }

        # Fallback para Carving
        $activeProfile = Get-ScapeActiveProfile
        $ramLimit = if ($activeProfile -and $activeProfile.ContainsKey('RAM_BUFFER_MB')) { [int]$activeProfile['RAM_BUFFER_MB'] } else { 0 }
        $enableBP = $ramLimit -lt (Get-ScapeConstant -Path "system::ANALYSIS::RAM_LIMIT")

        $result = Invoke-ScapeRawCarving -Buffer $SectorBuffer -PhysicalOffset $PhysicalOffset -VolumeSerial $VolumeSerial -EnableBackpressure:$enableBP

        # â”€â”€ TreeView Hook: Notifica artefatos recuperados via carving â”€â”€
        if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue -and $result.Carved -gt 0) {
            Publish-ScapeTreeUpdate -TreeId 'Analysis_Carving' -TitleKey 'CARVE_RECORD_ADDED' -Nodes @(
                @{ Path = "$VolumeSerial/Carved/Artifacts_$($result.Carved)"; Icon = "FileArchive"; Status = 'Ready' }
            )
        }

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
        [Parameter()][int]$SectorSize = (Get-ScapeConstant -Path "system::ANALYSIS::SECTOR_SIZE")
    )
    process {
        if (-not $PSCmdlet.ShouldProcess("Batch of $($SectorBatch.Count) sectors", "Batch Analysis")) { return @() }
        if (-not $Script:Initialized) { Initialize-ScapeAnalyzer }

        $results = New-Object System.Collections.Generic.List[hashtable]
        $progressInterval = [Math]::Max((Get-ScapeConstant -Path "system::ANALYSIS::DEFAULT_INTERVAL"), [Math]::Floor($SectorBatch.Count / 10))

        for ($i = 0; $i -lt $SectorBatch.Count; $i++) {
            $offset = $BaseOffset + ($i * $SectorSize)
            $result = Start-ScapeAnalysisStream -SectorBuffer $SectorBatch[$i] -PhysicalOffset $offset -VolumeSerial $VolumeSerial
            $results.Add(@{ Index = $i; Offset = $offset; Result = $result })

            if ($i % $progressInterval -eq 0) {
                # MVVM estrito: Presentation nÃ£o deve buscar ProgressStyle em ColdState/estado global.
                # Aqui derivamos ProgressStyle como read-only e injetamos no Payload.
                $progressStyle = $null
                try { $progressStyle = (Get-ScapeColdState)['ProgressStyle'] } catch { Write-Verbose "Suppressed error:                 try { $progressStyle = (Get-ScapeColdState)['ProgressStyle'] } catch {}";}
                Publish-ScapeEvent -Type "PROGRESS" -Payload @{
                    Action        = "ProgressBar"
                    TaskID        = 1
                    Current       = $i
                    Total         = $SectorBatch.Count
                    Label         = "Analyzing sectors..."
                    ProgressStyle = $(if ($null -ne $progressStyle -and -not [string]::IsNullOrWhiteSpace($progressStyle)) { [string]$progressStyle } else { 'Default' })
                }
                if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
                # â”€â”€ TreeView Hook: Atualiza progresso em lote â”€â”€
                if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
                    Publish-ScapeTreeUpdate -TreeId 'Analysis_Batch' -TitleKey 'PIPE_BATCH_START' -Nodes @(
                        @{ Path = "$VolumeSerial/Batch/Progress_$i/$($SectorBatch.Count)"; Icon = "Processing"; Status = 'Loading' }
                    )
                }
            }
        }

        # â”€â”€ TreeView Hook: Finaliza batch â”€â”€
        if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
            Publish-ScapeTreeUpdate -TreeId 'Analysis_Batch' -TitleKey 'PIPE_BATCH_COMPLETE' -Nodes @(
                @{ Path = "$VolumeSerial/Batch/Complete"; Icon = "Success"; Status = 'Ready' }
            )
        }

        return [System.Object[]]$results.ToArray()
    }
}

Export-ModuleMember -Function 'Invoke-ScapeBatchAnalysis'
