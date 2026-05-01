<#.SYNOPSIS
    Domain: Acquisition
    Module: Scape.Acquisition.Resilience
    Description: Fault-tolerant invocation wrapper for raw disk I/O. Handles cyclic redundancy checks and bad blocks.
#>

$Script:C = $null

function Initialize-ScapeResilience {
    $Script:C = @{
        FLOW = Get-ScapeConstant -Path "io::FLOW" -Fallback @{}
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
            Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Message = "I/O Error at offset $TargetOffset. Attempt $attempt/$maxRetries. Reason: $($_.Exception.Message)" }

            if ($attempt -ge $maxRetries) {
                # Limite atingido. Reporta falha crítica no bloco para o motor pular
                Publish-ScapeEvent -Type "LOG_ERR" -Payload @{ Action = "LogLine"; Message = "BAD_BLOCK_DETECTED at $TargetOffset. Max retries exhausted." }
                return @{ Success = $false; BytesRead = 0; Error = $_.Exception.Message }
            }
            Start-Sleep -Milliseconds $delayMs
        }
    }
}