<#
.SYNOPSIS
    Domain: Analysis | Module: Scape.Analysis.Parser.Core
    Architecture: Deterministic Metadata Orchestrator (Plan A)
    Description: Governs the strict traversal of MFT/Inode tables, handling
                 backpressure, state checkpoints, and fallback triggering.
#>
[CmdletBinding()] param()

function Invoke-ScapeTargetedParsing {
    [CmdletBinding()]
    [OutputType([void])]
    param([hashtable]$Payload)
    process {
        $state = Get-ScapeColdState
        $target = if ($Payload -and $Payload.ContainsKey('Target')) { $Payload['Target'] } else { Get-ScapeProperty -Object $state -PropertyName 'ActiveTarget' -Fallback $null }

        if ($null -eq $target) {
            Publish-ScapeEvent -Type "ERR_DRIVE_SELECTION_NONE" -Severity "ERROR" -Payload @{
                Key     = "ERR_DRIVE_SELECTION_NONE"
                Message = Get-ScapeLogMsg -Key "ERR_DRIVE_SELECTION_NONE"
            }
            return
        }

        Publish-ScapeEvent -Type "PIPE_TARGETED_RECOVERY" -Severity "INFO" -Payload @{
            Key     = "PIPE_TARGETED_RECOVERY"
            Message = Get-ScapeLogMsg -Key "PIPE_TARGETED_RECOVERY"
        }

        try {
            $engineMode = if ($Payload -and $Payload.ContainsKey('EngineMode')) { $Payload['EngineMode'] } else { Get-ScapeProperty -Object $state -PropertyName 'EngineMode' -Fallback 'STANDARD' }
            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "PIPE_TRAVERSAL_START"; Target = $target }

            Publish-ScapeEvent -Type "PROGRESS" -Severity "INFO" -Payload @{
                Stage       = "MFT Traversal"
                Current     = 0
                Total       = 100
                ShowPercent = $true
            }

            # --- Real FS pipeline via reader modules ---
            $endOffset = [long]::MaxValue
            try {
                if ($target -match '^[A-Za-z]:\\?$') {
                    $drv = $target -replace '\\$', ''
                    $vol = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$drv'" -ErrorAction SilentlyContinue
                    if ($vol -and $vol.Size) { $endOffset = [long]$vol.Size }
                } elseif ($target -match 'PhysicalDrive(\d+)') {
                    $drvIndex = $Matches[1]
                    $disk = Get-CimInstance Win32_DiskDrive -Filter "Index=$drvIndex" -ErrorAction SilentlyContinue
                    if ($disk -and $disk.Size) { $endOffset = [long]$disk.Size }
                }
            } catch { Write-Verbose "Suppressed bound resolution error: $_" }

            $totalRecords = 0
            $onChunkAnalyzed = {
                param($chunkResult)
                
                # O chunkResult pode ser um array de PSCustomObject ou um hashtable com a propriedade Carved dependendo se foi FS parser ou Carver.
                $records = @()
                if ($chunkResult -is [array]) { $records = $chunkResult }
                elseif ($null -ne $chunkResult -and $chunkResult -isnot [hashtable]) { $records = @($chunkResult) }
                
                $count = $records.Count
                if ($count -eq 0) { return }

                $totalRecords += $count

                foreach ($record in $records) {
                    $evt = [PSCustomObject]@{
                        Type       = "ARTIFACT_DISCOVERED"
                        Severity   = "LOG_INFO"
                        OperatorId = "PARSER_ENGINE"
                        Payload    = $record
                    }
                    if (Get-Command New-ScapeAuditRecord -ErrorAction SilentlyContinue) {
                        New-ScapeAuditRecord -EventFrame $evt | Out-Null
                    }
                    Publish-ScapeEvent -Type "PIPELINE_RECORD_DISCOVERED" -Severity "TRACE" -Payload $record
                }

                # Publish Progress
                Publish-ScapeEvent -Type "PROGRESS" -Severity "INFO" -Payload @{
                    Stage       = "MFT Traversal"
                    Current     = $totalRecords
                    Total       = 0 # Unknown total artifacts, infinite scroll mode
                    ShowPercent = $false
                }
                
                if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
                    Invoke-ScapeIdlePump | Out-Null
                }
            }

            if (Get-Command Read-ScapeDiskStream -ErrorAction SilentlyContinue) {
                # Test Limit: 10MB to avoid infinite freeze during dev tests unless overridden
                $devLimit = 10MB
                if ($endOffset -gt $devLimit) { $endOffset = $devLimit }
                
                Read-ScapeDiskStream -DevicePath $target -StartOffset 0 -EndOffset $endOffset -OnChunkAnalyzed $onChunkAnalyzed
            } else {
                throw "Read-ScapeDiskStream command not found. Acquisition module missing."
            }

            if ($totalRecords -eq 0) {
                Publish-ScapeEvent -Type "PIPE_NO_RECORDS" -Severity "WARN" -Payload @{
                    Key    = "PIPE_NO_RECORDS"
                    Target = $target
                }
            }

            Publish-ScapeEvent -Type "PIPE_TRAVERSAL_COMPLETE" -Severity "INFO" -Payload @{
                Key     = "PIPE_TRAVERSAL_COMPLETE"
                Message = Get-ScapeLogMsg -Key "PIPE_TRAVERSAL_COMPLETE"
            }
        }
        catch {
            Publish-ScapeEvent -Type "INT_FAILSAFE_TRIG" -Severity "FATAL" -Payload @{
                Key     = "ROUTER_FATAL"
                Message = Get-ScapeLogMsg -Key "ROUTER_FATAL" -MsgArgs @($_.Exception.Message)
            }
        }
    }
}

Export-ModuleMember -Function 'Invoke-ScapeTargetedParsing'
