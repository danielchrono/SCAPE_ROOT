<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.EventBus
    Description: Thread-Safe, Lock-Free Asynchronous Event Bus. Implements dynamic
                 Backpressure dropping and standardized Exception unrolling.
#>

# Encapsulamento em escopo de Script em vez de Global
$Script:EventQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()

function Publish-ScapeEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Type,
        [Parameter(Mandatory = $true)][object]$Payload,
        [string]$Severity = "LOG_INFO"
    )

    # Lógica de Backpressure (Volume original preservado)
    $maxQueue = 10000
    if ($Script:EventQueue.Count -ge $maxQueue) {
        if ($Severity -match "^(TRACE|DEBUG|METRIC)$") { return }
    }

    $timeFormat = "yyyy-MM-ddTHH:mm:ss.fffZ"
    $EventFrame = [PSCustomObject]@{
        Timestamp = [datetime]::UtcNow.ToString($timeFormat)
        Type      = $Type
        Severity  = $Severity
        Payload   = $Payload
    }

    $Script:EventQueue.Enqueue($EventFrame)
}

function Publish-ScapeError {
    <#
    .SYNOPSIS
        Desempacota ErrorRecords nativos do PowerShell e System.Exceptions para
        captura detalhada de bugs, impedindo a perda do StackTrace.
    #>
    param(
        [Parameter(Mandatory = $true)]$ErrorRecord,
        [string]$Context = "UNHANDLED_EXCEPTION",
        [string]$Severity = "LOG_FATAL"
    )

    $msg = $ErrorRecord.ToString()
    $stack = "NO_STACK_TRACE"

    if ($ErrorRecord -is [System.Management.Automation.ErrorRecord]) {
        $msg = $ErrorRecord.Exception.Message
        $stack = if ($ErrorRecord.ScriptStackTrace) { $ErrorRecord.ScriptStackTrace } else { $ErrorRecord.Exception.StackTrace }
    }
    elseif ($ErrorRecord -is [System.Exception]) {
        $msg = $ErrorRecord.Message
        $stack = $ErrorRecord.StackTrace
        if ($ErrorRecord.InnerException) {
            $msg += " [Inner: $($ErrorRecord.InnerException.Message)]"
        }
    }

    $payload = [PSCustomObject]@{
        Context    = $Context
        Message    = $msg
        StackTrace = $stack
        Engine     = "SCAPE_CORE"
    }

    Publish-ScapeEvent -Type "SYSTEM_CRASH" -Severity $Severity -Payload $payload
}

function Receive-ScapeEvent {
    [CmdletBinding()]
    param([int]$MaxBatchSize = 100)

    $batch = [System.Collections.Generic.List[object]]::new()
    $eventFrame = $null

    while ($batch.Count -lt $MaxBatchSize -and $Script:EventQueue.TryDequeue([ref]$eventFrame)) {
        $batch.Add($eventFrame)
    }

    return $batch.ToArray()
}

function Get-ScapeEventQueue { return $Script:EventQueue }

function Publish-ScapeFault {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [System.Management.Automation.ErrorRecord]$ErrorRecord,
        [string]$Context = "Unknown",
        [string]$Severity = "LOG_WARN"
    )
    try {
        if (Get-Command "Publish-ScapeEvent" -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_FAULT" -Severity $Severity -Payload @{
                Context   = $Context
                Exception = $ErrorRecord.Exception.Message
                Line      = $ErrorRecord.InvocationInfo.ScriptLineNumber
                Command   = $ErrorRecord.InvocationInfo.MyCommand.Name
            }
        }
    }
    catch {
        # Fallback silencioso: se o EventBus falhar, não entra em loop infinito
        Write-Verbose "FAULT [$Context]: $($ErrorRecord.Exception.Message)"
    }
}