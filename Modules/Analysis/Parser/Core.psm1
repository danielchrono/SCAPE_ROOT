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
        $state  = Get-ScapeColdState
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
            $records = @()
            if (Get-Command Get-ScapeFSMeta -ErrorAction SilentlyContinue) {
                $records = @(Get-ScapeFSMeta -Target $target -Mode $engineMode)
            }
            elseif (Get-Command Get-ScapeMFTRecords -ErrorAction SilentlyContinue) {
                $records = @(Get-ScapeMFTRecords -Target $target)
            }

            $total = $records.Count
            if ($total -eq 0) {
                Publish-ScapeEvent -Type "PIPE_NO_RECORDS" -Severity "WARN" -Payload @{
                    Key    = "PIPE_NO_RECORDS"
                    Target = $target
                }
            }
            else {
                $notifyInterval = [Math]::Max(1, [Math]::Floor($total / 20))
                for ($i = 0; $i -lt $total; $i++) {
                    $record = $records[$i]
                    if ($record) {
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
                    if (($i % $notifyInterval) -eq 0 -or $i -eq ($total - 1)) {
                        Publish-ScapeEvent -Type "PROGRESS" -Severity "INFO" -Payload @{
                            Stage       = "MFT Traversal"
                            Current     = $i + 1
                            Total       = $total
                            ShowPercent = $true
                        }
                        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
                            Invoke-ScapeIdlePump | Out-Null
                        }
                    }
                }
                Publish-ScapeEvent -Type "PROGRESS" -Severity "INFO" -Payload @{
                    Stage   = "MFT Traversal"
                    Current = $total
                    Total   = $total
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