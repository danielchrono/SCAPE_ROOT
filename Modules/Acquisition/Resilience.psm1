<#.SYNOPSIS
    Domain: Acquisition
    Module: Scape.Acquisition.Resilience
    Description: Fault-tolerant invocation wrapper for raw disk I/O. Handles cyclic redundancy checks and bad blocks.
#>

$Script:C = $null

function Initialize-ScapeResilience {
    $Script:C = @{
        FLOW = Get-ScapeConstant -Path "storage::FLOW" -Fallback @{}
    }
}

function Invoke-ScapeResilientRead {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ReadOperation,

        [Parameter(Mandatory = $true)]
        [long]$TargetOffset
    )

    if (-not $Script:C) { Initialize-ScapeResilience }

    $maxRetries = [int]$Script:C.FLOW["MAX_RETRY"]
    $delayMs = [int]$Script:C.FLOW["RETRY_DELAY_MS"]
    $attempt = 0

    while ($attempt -lt $maxRetries) {
        try {
            # Executa a operação de I/O bloqueante (C# P/Invoke)
            $result = & $ReadOperation

            if ($result.Success) {
                return $result
            }
            else {
                throw "WIN32_READ_FAULT: $($result.ErrorCode)"
            }
        }
        catch {
            $attempt++
            $retryMsg = Get-ScapeLogMsg -Key "IO_RETRY_ATTEMPT" -MsgArgs @($attempt, $maxRetries, ($delayMs / 1000))
            Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Message = $retryMsg }

            if ($attempt -ge $maxRetries) {
                $badBlockMsg = Get-ScapeLogMsg -Key "IO_BIT_ERROR"
                Publish-ScapeEvent -Type "LOG_ERR" -Payload @{ Action = "LogLine"; Message = $badBlockMsg }
                return @{ Success = $false; BytesRead = 0; Error = $_.Exception.Message }
            }
            
            # Non-blocking delay
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            while ($sw.ElapsedMilliseconds -lt $delayMs) {
                if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
                    Invoke-ScapeIdlePump | Out-Null
                }
            }
            $sw.Stop()
        }
    }
}
Register-ScapeActionHandler -Target 'Scape.Acquisition.Resilience' -Handler {
    param($Task, $PayloadDef, $Target)
    $targetId = Resolve-ScapeActiveTarget
    if ([string]::IsNullOrWhiteSpace($targetId)) { throw "No Target Bound" }
}