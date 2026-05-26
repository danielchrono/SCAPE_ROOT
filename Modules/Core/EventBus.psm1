<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.EventBus
    Architecture: Thread-Safe, Lock-Free Asynchronous Event Bus.
#>

$Script:EventQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
$Script:EventSubscribers = [System.Collections.Generic.List[hashtable]]::new()

function Publish-ScapeEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Type,
        [Parameter(Mandatory = $true)][object]$Payload,
        [string]$Severity = "LOG_INFO"
    )

    $maxQueue = 10000
    if ($Script:EventQueue.Count -ge $maxQueue) {
        # Only drop TRACE/DEBUG/METRIC if explicitly set in config, otherwise queue them
        try {
            $cfg = Get-ScapeConstant -Path "infrastructure::Logger" -Fallback @{}
            $minLevelName = $cfg["DEFAULT_LEVEL_NAME"] -or "INFO"
            if ($null -eq $minLevelName) { $minLevelName = "INFO" }

            # Check for runtime override
            if ($env:SCAPE_LOG_LEVEL) { $minLevelName = $env:SCAPE_LOG_LEVEL }
            else {
                try {
                    $cs = Get-ScapeColdState
                    if ($cs -and $cs.ContainsKey('LOG_LEVEL_OVERRIDE')) { $minLevelName = $cs['LOG_LEVEL_OVERRIDE'] }
                }
                catch { }
            }

            # Only drop if below configured min level
            $severityMap = @{ TRACE = 0; DEBUG = 1; INFO = 2; WARN = 3; ERROR = 4; FATAL = 5 }
            $minValue = $severityMap[$minLevelName] -or 2
            $currValue = $severityMap[$Severity -replace '^LOG_', ''] -or 2

            if ($currValue -lt $minValue) { return }
        }
        catch { }
    }

    # IDENTIFICAÇÃO DE ORIGEM (CALLER ID REAL)
    $caller = "SYSTEM_CORE"
    $stack = Get-PSCallStack
    if ($null -ne $stack) {
        # Ignora a própria publicação e os blocos anônimos dos listeners para achar o dono da ação
        for ($i = 1; $i -lt $stack.Count; $i++) {
            $cmd = $stack[$i].Command
            if ($cmd -notmatch 'Publish-ScapeEvent|<ScriptBlock>') {
                $caller = $cmd
                break
            }
        }
    }

    $timeFormat = "yyyy-MM-ddTHH:mm:ss.fffZ"
    $EventFrame = [PSCustomObject]@{
        Timestamp = [datetime]::UtcNow.ToString($timeFormat)
        Type      = $Type
        Severity  = $Severity
        Payload   = $Payload
        Source    = $caller
    }

    $Script:EventQueue.Enqueue($EventFrame)
}

function Publish-ScapeError {
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

function Get-ScapeEventQueue { return ,$Script:EventQueue }

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
    catch { Write-Verbose "FAULT [$Context]: $($ErrorRecord.Exception.Message)" }
}

function Register-ScapeEventListener {
    [CmdletBinding()]
    param([string]$EventMatch, [scriptblock]$Action)
    $sub = @{ Match = $EventMatch; Action = $Action }
    $Script:EventSubscribers.Add($sub)
}

function Invoke-ScapeIdlePump {
    [CmdletBinding()]
    param()

    $eventFrame = $null
    while ($Script:EventQueue.TryDequeue([ref]$eventFrame)) {
        $subsCopy = [System.Collections.Generic.List[hashtable]]::new($Script:EventSubscribers)
        foreach ($sub in $subsCopy) {
            $isMatch = $false
            if ($sub.Match -eq '*') { $isMatch = $true }
            elseif ($sub.Match -like '*') {
                try { $isMatch = $eventFrame.Type -like $sub.Match } catch { $isMatch = $false }
            }
            else {
                try { $isMatch = $eventFrame.Type -match $sub.Match } catch { $isMatch = $false }
            }

            if ($isMatch) {
                try { & $sub.Action $eventFrame }
                catch {
                    if ($_.Exception.Message -eq "SCAPE_HANDOVER") { throw $_ }
                    Publish-ScapeEvent -Type "LISTENER_FAULT" -Severity "ERROR" -Payload @{
                        ListenerMatch = $sub.Match
                        EventType     = $eventFrame.Type
                        Error         = $_.Exception.Message
                    }
                }
            }
        }
    }
}

