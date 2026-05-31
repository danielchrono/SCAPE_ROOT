<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.EventBus
    Architecture: Thread-Safe, Lock-Free Asynchronous Event Bus.
#>

$Script:EventQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
$Script:EventSubscribers = [System.Collections.Concurrent.ConcurrentQueue[hashtable]]::new()
$Script:PumpActive = 0 # 0 = false, 1 = true

function Publish-ScapeEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Type,
        [Parameter(Mandatory = $true)][object]$Payload,
        [string]$Severity = "LOG_INFO",
        [string]$Source = "SYSTEM_CORE"
    )

    $sysConfig = Get-ScapeConstant -Path "infrastructure::Logger" -Fallback @{}
    $maxQueue = if ($sysConfig["MAX_QUEUE"]) { $sysConfig["MAX_QUEUE"] } else { 10000 }
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
                catch { Write-Verbose "Suppressed error:                 catch { }"; }
            }

            # Only drop if below configured min level
            $severityMap = @{ TRACE = 0; DEBUG = 1; INFO = 2; WARN = 3; ERROR = 4; FATAL = 5 }
            $minValue = $severityMap[$minLevelName] -or 2
            $currValue = $severityMap[$Severity -replace '^LOG_', ''] -or 2

            if ($currValue -lt $minValue) { return }
        }
        catch { Write-Verbose "Suppressed error:         catch { }"; }
    }

    # IDENTIFICAÃ‡ÃƒO DE ORIGEM (CALLER ID REAL)
    $caller = if (-not [string]::IsNullOrWhiteSpace($Source)) { $Source } else { "SYSTEM_CORE" }

    $timeFormat = if ($sysConfig["TIME_FORMAT"]) { $sysConfig["TIME_FORMAT"] } else { "yyyy-MM-ddTHH:mm:ss.fffZ" }
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

function Get-ScapeEventQueue { return $Script:EventQueue }

function Publish-ScapeFault {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [System.Management.Automation.ErrorRecord]$ErrorRecord,
        [string]$Context = "Unknown",
        [string]$Severity = "LOG_WARN",
        [string]$Message = ""
    )
    try {
        if (Get-Command "Publish-ScapeEvent" -ErrorAction SilentlyContinue) {
            $payload = @{
                Context   = $Context
                Exception = $ErrorRecord.Exception.Message
                Line      = $ErrorRecord.InvocationInfo.ScriptLineNumber
                Command   = $ErrorRecord.InvocationInfo.MyCommand.Name
            }
            if (-not [string]::IsNullOrWhiteSpace($Message)) { $payload.Message = $Message }
            Publish-ScapeEvent -Type "SYSTEM_FAULT" -Severity $Severity -Payload $payload
        }
    }
    catch { Write-Verbose "FAULT [$Context]: $($ErrorRecord.Exception.Message)" }
}

function Register-ScapeEventListener {
    [CmdletBinding()]
    param([string]$EventMatch, [scriptblock]$Action)
    $sub = @{ Match = $EventMatch; Action = $Action }
    $Script:EventSubscribers.Enqueue($sub)
}

function Invoke-ScapeIdlePump {
    [CmdletBinding()]
    param()

    if ([System.Threading.Interlocked]::CompareExchange([ref]$Script:PumpActive, 1, 0) -ne 0) { return }

    try {
        $eventFrame = $null
        while ($Script:EventQueue.TryDequeue([ref]$eventFrame)) {
            $subsCopy = $Script:EventSubscribers.ToArray()
            foreach ($sub in $subsCopy) {
                $isMatch = $false
                $pattern = $sub.Match

                if ($pattern -eq '*') {
                    $isMatch = $true
                }
                elseif ($pattern -match '[\^\$\(\)\|\+]') {
                    # Contains regex metacharacters â€” use -match
                    try { $isMatch = $eventFrame.Type -match $pattern } catch { $isMatch = $false }
                }
                elseif ($pattern -match '[\*\?]') {
                    # Contains wildcard chars â€” use -like
                    try { $isMatch = $eventFrame.Type -like $pattern } catch { $isMatch = $false }
                }
                else {
                    # Exact string match
                    $isMatch = $eventFrame.Type -eq $pattern
                }

                if ($isMatch) {
                    try { & $sub.Action $eventFrame }
                    catch {
                        if ($_.Exception.Message -eq "SCAPE_HANDOVER") { throw $_ }
                        Write-Verbose "Listener fault [$($sub.Match)] on [$($eventFrame.Type)]: $($_.Exception.Message)"
                    }
                }
            }
        }
    }
    finally {
        [System.Threading.Interlocked]::Exchange([ref]$Script:PumpActive, 0) | Out-Null
    }
}
Export-ModuleMember -Function 'Publish-ScapeError',
'Receive-ScapeEvent',
'Publish-ScapeFault',
'Invoke-ScapeIdlePump',
'Register-ScapeEventListener',
'Get-ScapeEventQueue',
'Publish-ScapeEvent'
