<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Logger
    Architecture: Thread-safe EventBus subscriber for writing physical .log files.
#>

$Script:LogStream = $null
$Script:BackpressureLimit = $null

function Initialize-ScapeLogger {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $maxConcurrent = Get-ScapeConstant -Path "behavior::LIMITS::MAX_CONCURRENT_OPS" -Fallback 16
        $Script:BackpressureLimit = [System.Threading.SemaphoreSlim]::new($maxConcurrent, $maxConcurrent)

        $logDir = Join-Path -Path (Get-ScapeColdState)["ROOT"] -ChildPath (Get-ScapeConstant -Path "dir::PATHS::LOGS_FOLDER" -Fallback "Logs")
        if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

        $logFormat = Get-ScapeConstant -Path "dir::NAMING::LOG_FILE_PATTERN" -Fallback "scape_{0:yyyyMMdd_HHmmss}.log"
        $logFile = Join-Path -Path $logDir -ChildPath ($logFormat -f [DateTime]::Now)

        $Script:LogStream = [System.IO.StreamWriter]::new($logFile, $true, [System.Text.Encoding]::UTF8)
        $Script:LogStream.AutoFlush = (Get-ScapeConstant -Path "compliance::AUDIT::LOG_IMMUTABLE" -Fallback $true)

        if (Get-Command Register-ScapeEventListener -ErrorAction SilentlyContinue) {
            Register-ScapeEventListener -EventMatch "*" -Action {
                param($IncomingEvt)
                if ($IncomingEvt.Type -match "^(TRACE|METRIC_SAMPLE|TELEMETRY_HEARTBEAT)$") { return }
                Write-ScapeLogRecord -EventFrame $IncomingEvt
            }
        }
        return $true
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Logger_Init" }
        return $false
    }
}

function Write-ScapeLogRecord {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][PSCustomObject]$EventFrame)

    $timeout = Get-ScapeConstant -Path "behavior::LIMITS::AUDIT_TIMEOUT_MS" -Fallback 5000
    if (-not $Script:BackpressureLimit.Wait([int]$timeout)) {
        if ($EventFrame.Severity -notin @("LOG_ERR", "LOG_FATAL", "COMPLIANCE")) { return }
    }

    try {
        $timeFormat = Get-ScapeConstant -Path "compliance::AUDIT::TIMESTAMP_FORMAT" -Fallback "yyyy-MM-ddTHH:mm:ss.fffZ"
        $timestamp = [DateTime]::UtcNow.ToString($timeFormat)

        $payloadStr = if ($null -ne $EventFrame.Payload) {
            try { $EventFrame.Payload | ConvertTo-Json -Depth 3 -Compress } catch { "INVALID_PAYLOAD" }
        }
        else { "{}" }

        if ($null -ne $Script:LogStream -and $Script:LogStream.BaseStream.CanWrite) {
            $logLine = "[{0}] [{1}] {2} | {3}" -f $timestamp, $EventFrame.Severity, $EventFrame.Type, $payloadStr
            $Script:LogStream.WriteLine($logLine)
        }
    }
    catch {
        Write-Verbose "[LOGGER_FAULT] $($_.Exception.Message)" -ErrorAction SilentlyContinue
    }
    finally {
        $null = $Script:BackpressureLimit.Release()
    }
}

function Close-ScapeLogStream {
    [CmdletBinding()]
    param()
    try {
        if ($null -ne $Script:LogStream) {
            $Script:LogStream.Flush()
            $Script:LogStream.Close()
            $Script:LogStream.Dispose()
        }
    }
    catch {} finally {
        $Script:LogStream = $null
    }
}