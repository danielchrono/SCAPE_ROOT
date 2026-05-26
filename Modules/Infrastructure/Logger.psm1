<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Logger
    Description: Thread-safe operational logging with rotation, severity filtering, and zero hardcode.
    [PATCH] Fixed _EnrichWithCallerInfo to handle runspace failures, protected Register-EngineEvent
#>
[CmdletBinding()] param()

$Script:LogStream = $null
$Script:Semaphore = $null
$Script:CurrentLogFile = $null
$Script:Config = $null
$Script:RotationCounter = "0"
$Script:Initialized = $false

function Initialize-ScapeLogger {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ($Script:Initialized) { return $true }

    $loggerCfg = Get-ScapeConstant -Path "infrastructure::Logger"
    if ($null -eq $loggerCfg) {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_FAULT" -Severity "LOG_WARN" -Payload @{
                Context = "Logger_Config"
                Message = Get-ScapeLogMsg -Key "ROUTER_FATAL" -MsgArgs @("LOGGER_CONFIG_MISSING")
            }
        }
        return $false
    }

    $Script:Config = @{
        Logger    = $loggerCfg
        LogLevels = Get-ScapeConstant -Path "infrastructure::LogSeverity" -Fallback @{}
        Limits    = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
        Dirs      = Get-ScapeConstant -Path "system::Workspace" -Fallback @{}
    }

    $Script:SeverityMap = $Script:Config.Logger["LOG_LEVELS"]
    if ($null -eq $Script:SeverityMap) {
        $Script:SeverityMap = @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 }
    }

    # Allow runtime override of minimum log level via env var or ColdState keys (no hardcode)
    $minLevelName = $Script:Config.Logger["DEFAULT_LEVEL_NAME"]
    if ($null -eq $minLevelName) { $minLevelName = "INFO" }

    $overrideLevel = $null
    if ($env:SCAPE_LOG_LEVEL) { $overrideLevel = $env:SCAPE_LOG_LEVEL }
    else {
        try { $cs = Get-ScapeColdState } catch { $cs = $null }
        if ($cs -and $cs.ContainsKey('LOG_LEVEL_OVERRIDE')) { $overrideLevel = $cs['LOG_LEVEL_OVERRIDE'] }
        elseif ($cs -and $cs.ContainsKey('DEV_MODE') -and $cs['DEV_MODE']) { $overrideLevel = 'TRACE' }
    }

    if ($overrideLevel -and -not [string]::IsNullOrWhiteSpace($overrideLevel)) { $minLevelName = $overrideLevel }

    $Script:MinSeverityValue = $Script:SeverityMap[$minLevelName]
    if ($null -eq $Script:MinSeverityValue) { $Script:MinSeverityValue = 1 }

    try {
        $logDir = (Get-ScapeColdState)["WORKSPACE_LOGS"]
        if ([string]::IsNullOrWhiteSpace($logDir)) {
            $root = (Get-ScapeColdState)["ROOT"]
            if ([string]::IsNullOrWhiteSpace($root)) { return $false }
            $logFolder = $Script:Config.Dirs["LOGS"]
            if ($null -eq $logFolder) { $logFolder = "Logs" }
            $logDir = Join-Path $root $logFolder
        }

        if (-not (Test-Path $logDir)) {
            $null = New-Item -ItemType Directory -Path $logDir -Force
        }

        $pattern = $Script:Config.Logger["LOG_FILE_PATTERN"]
        if ($null -eq $pattern) { $pattern = "scape_{0:yyyyMMdd_HHmmss}.log" }

        $requestedParentLog = $env:SCAPE_LOG_PARENT_FILE
        $requestedLogFile = if ($env:SCAPE_LOG_FILE_OVERRIDE) { $env:SCAPE_LOG_FILE_OVERRIDE } else { $requestedParentLog }
        $openFailedOnOverride = $false

        if (-not [string]::IsNullOrWhiteSpace($requestedLogFile)) {
            $overrideDir = Split-Path -Path $requestedLogFile -Parent
            if (-not [string]::IsNullOrWhiteSpace($overrideDir) -and -not (Test-Path -LiteralPath $overrideDir)) {
                $null = New-Item -ItemType Directory -Path $overrideDir -Force
            }
            try {
                $Script:CurrentLogFile = $requestedLogFile
                $Script:LogStream = [System.IO.StreamWriter]::new($Script:CurrentLogFile, $true, [System.Text.Encoding]::UTF8)
                $Script:LogStream.AutoFlush = ($Script:Config.Logger["LOG_IMMEDIATE_FLUSH"] -eq $true)
            }
            catch {
                $openFailedOnOverride = $true
                $Script:LogStream = $null
            }
        }

        if ($null -eq $Script:LogStream) {
            $suffix = if ($openFailedOnOverride) { "_child" } else { "" }
            $localPattern = if ($suffix) { "scape_{0:yyyyMMdd_HHmmss}${suffix}.log" } else { $pattern }
            $Script:CurrentLogFile = Join-Path $logDir ($localPattern -f [DateTime]::Now)
            $Script:LogStream = [System.IO.StreamWriter]::new($Script:CurrentLogFile, $true, [System.Text.Encoding]::UTF8)
            $Script:LogStream.AutoFlush = ($Script:Config.Logger["LOG_IMMEDIATE_FLUSH"] -eq $true)
        }

        $maxOps = $Script:Config.Limits["MAX_CONCURRENT_OPS"]
        if ($null -eq $maxOps) { $maxOps = 16 }
        $Script:Semaphore = [System.Threading.SemaphoreSlim]::new($maxOps, $maxOps)

        if (Get-Command "Register-ScapeEventListener" -ErrorAction SilentlyContinue) {
            $script:LogAction = {
                param($IncomingEvt)
                try {
                    $excludes = $Script:Config.Logger["LOG_EXCLUDE_TYPES"]
                    if ($null -eq $excludes) { $excludes = @("METRIC_SAMPLE", "TELEMETRY_HEARTBEAT") }

                    # Respect runtime min severity: if TRACE/DEBUG are allowed, don't exclude them by default
                    try {
                        if ($Script:MinSeverityValue -le $Script:SeverityMap['TRACE']) { $excludes = $excludes | Where-Object { $_ -ne 'TRACE' } }
                        if ($Script:MinSeverityValue -le $Script:SeverityMap['DEBUG']) { $excludes = $excludes | Where-Object { $_ -ne 'DEBUG' } }
                    } catch { }

                    $excludeRegex = if ($excludes.Count -gt 0) { "^($($excludes -join '|'))$" } else { "^$" }
                    if ($IncomingEvt.Type -match $excludeRegex) { return }

                    $evtSeverity = $IncomingEvt.Severity -replace '^LOG_', ''
                    $evtValue = $Script:SeverityMap[$evtSeverity]
                    if ($null -eq $evtValue) { $evtValue = 1 }
                    if ($evtValue -lt $Script:MinSeverityValue) { return }

                    if (-not $Script:Semaphore.Wait(0)) {
                        if ($IncomingEvt.Severity -notin @("LOG_ERR", "LOG_FATAL", "COMPLIANCE")) { return }
                        $timeout = $Script:Config.Limits["CRITICAL_SECTION_TIMEOUT_MS"]
                        if ($null -eq $timeout) { $timeout = 5000 }
                        if (-not $Script:Semaphore.Wait([int]$timeout)) { return }
                    }

                    try {
                        _RotateLogIfNeeded
                        Write-ScapeLogRecord -EventFrame $IncomingEvt
                    }
                    finally {
                        $null = $Script:Semaphore.Release()
                    }
                }
                catch {
                    Write-Verbose "Logger fault suppressed to prevent loop: $($_.Exception.Message)"
                }
            }

            Register-ScapeEventListener -EventMatch "*" -Action $script:LogAction

            $stopEvents = $Script:Config.Logger["SHUTDOWN_EVENTS"]
            if ($null -eq $stopEvents) { $stopEvents = @("ROUTER_STOP", "SYSTEM_CRASH", "DEPLOYER_DONE") }
            $stopEvents = @($stopEvents | Where-Object { $_ -ne "ROUTER_STOP" })
            if ($stopEvents.Count -gt 0) {
                $stopRegex = "($($stopEvents -join '|'))"
                Register-ScapeEventListener -EventMatch $stopRegex -Action { Close-ScapeLogStream }
            }
        }

        $maxSize = $Script:Config.Logger["MAX_LOG_SIZE_MB"]
        if ($null -eq $maxSize) { $maxSize = 10 }

        Publish-ScapeEvent -Type "LOGGER_INITIALIZED" -Severity "LOG_INFO" -Payload @{
            LogFile   = $Script:CurrentLogFile
            MinLevel  = $minLevelName
            MaxSizeMB = $maxSize
            Message   = Get-ScapeLogMsg -Key "CORE_ENGINE_START"
        }

        if (-not [string]::IsNullOrWhiteSpace($requestedParentLog)) {
            Publish-ScapeEvent -Type "LOGGER_HANDOVER_CHILD" -Severity "LOG_INFO" -Payload @{
                ParentLog = $requestedParentLog
                ChildLog  = $Script:CurrentLogFile
                Continuity = $true
            }
        }

        if ($openFailedOnOverride -and -not [string]::IsNullOrWhiteSpace($requestedLogFile)) {
            Publish-ScapeEvent -Type "LOGGER_HANDOVER_FALLBACK" -Severity "LOG_WARN" -Payload @{
                RequestedLog = $requestedLogFile
                FallbackLog  = $Script:CurrentLogFile
            }
        }

        $env:SCAPE_LOG_PARENT_FILE = $Script:CurrentLogFile
        $Script:Initialized = $true
        return $true
    }
    catch {
        Publish-ScapeFault -ErrorRecord $_ -Context "Logger_Init" -Message (
            Get-ScapeLogMsg -Key "ROUTER_FATAL" -MsgArgs @($_.Exception.Message)
        )
        return $false
    }
}

function Write-ScapeLogRecord {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][PSCustomObject]$EventFrame)

    if (-not $Script:LogStream) { return }
    if (-not $Script:LogStream.BaseStream.CanWrite) { return }

    try {
        $timeFormat = $Script:Config.Logger["TIMESTAMP_FORMAT"]
        if ($null -eq $timeFormat) { $timeFormat = "yyyy-MM-ddTHH:mm:ss.fffZ" }
        $timestamp = [DateTime]::UtcNow.ToString($timeFormat)

        $enriched = _EnrichWithCallerInfo -EventFrame $EventFrame

        $payloadStr = "{}"
        if ($EventFrame.Payload) {
            try { $payloadStr = $EventFrame.Payload | ConvertTo-Json -Depth 6 -Compress -ErrorAction Stop }
            catch { $payloadStr = '{"Error":"JSON_SERIALIZE_FAILED"}' }
        }

        $logLine = "[{0}] [{1}] [{2}] {3} | {4}" -f $timestamp, $enriched.Severity, $enriched.Source, $enriched.Type, $payloadStr
        $Script:LogStream.WriteLine($logLine)
    }
    catch {
        Write-Verbose "Logger write failed: $($_.Exception.Message)"
    }
}

function _EnrichWithCallerInfo {
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param([PSCustomObject]$EventFrame)

    if ($EventFrame.Source -and $EventFrame.Layer) { return $EventFrame }

    $ignorePattern = 'Publish-ScapeEvent|Write-ScapeLogRecord|_EnrichWithCallerInfo|<ScriptBlock>'
    $callerFrame = $null
    try {
        $callerFrame = Get-PSCallStack | Select-Object -Skip 1 |
        Where-Object { $_.Command -notmatch $ignorePattern } |
        Select-Object -First 1
    }
    catch {
        # Get-PSCallStack falhou (runspace isolado)
        $callerFrame = $null
    }

    $caller = if ($callerFrame -and $callerFrame.Command) { $callerFrame.Command } else { "SYSTEM" }
    $layer = "CORE"
    $module = ""

    if ($callerFrame -and $callerFrame.ModuleName) {
        $modName = $callerFrame.ModuleName
        $parts = $modName -split '\.'
        $layerVal = if ($parts.Count -gt 1) { $parts[1] } else { "CORE" }
        $layer = $layerVal.ToUpper()
        $module = if ($parts.Count -gt 2) { $parts[2] } else { "" }
    }
    elseif ($caller -match '\.ps1$') {
        $layer = "BOOT"
        $caller = Split-Path $caller -Leaf
    }

    $source = if ($module) { "[$module] $caller" } else { $caller }

    return [PSCustomObject]@{
        Timestamp  = $EventFrame.Timestamp
        Type       = $EventFrame.Type
        Severity   = $EventFrame.Severity
        Payload    = $EventFrame.Payload
        Layer      = $layer
        Source     = $source -replace '\s+', ' '
        OperatorId = if ($EventFrame.OperatorId) { $EventFrame.OperatorId } else { "SYS_CORE" }
    }
}

function _RotateLogIfNeeded {
    $maxSizeMB = $Script:Config.Logger["MAX_LOG_SIZE_MB"]
    if ($null -eq $maxSizeMB) { $maxSizeMB = 10 }

    if (-not $Script:LogStream -or -not $Script:CurrentLogFile) { return }

    $file = Get-Item -LiteralPath $Script:CurrentLogFile -ErrorAction SilentlyContinue
    if (-not $file -or $file.Length -le ($maxSizeMB * 1MB)) { return }

    try {
        $Script:LogStream.Flush()
        $Script:LogStream.Dispose()

        $base = [System.IO.Path]::ChangeExtension($Script:CurrentLogFile, $null)
        $ext = [System.IO.Path]::GetExtension($Script:CurrentLogFile)
        $archived = "{0}_{1}{2}" -f $base, (++$Script:RotationCounter), $ext

        Move-Item -LiteralPath $Script:CurrentLogFile -Destination $archived -Force

        $Script:LogStream = [System.IO.StreamWriter]::new($Script:CurrentLogFile, $true, [System.Text.Encoding]::UTF8)
        $Script:LogStream.AutoFlush = ($Script:Config.Logger["LOG_IMMEDIATE_FLUSH"] -eq $true)

        Publish-ScapeEvent -Type "LOG_ROTATED" -Severity "LOG_INFO" -Payload @{
            OldFile = $archived; NewFile = $Script:CurrentLogFile; Counter = $Script:RotationCounter
            Message = Get-ScapeLogMsg -Key "LOG_ROTATED" -MsgArgs @($archived, $Script:CurrentLogFile, $Script:RotationCounter)
        }
    }
    catch { }
}

function Close-ScapeLogStream {
    [CmdletBinding()]
    param()
    if ($Script:LogStream) {
        $Script:LogStream.Flush()
        $Script:LogStream.Dispose()
        $Script:LogStream = $null
    }
    if ($Script:Semaphore) {
        $Script:Semaphore.Dispose()
        $Script:Semaphore = $null
    }
}

function Get-ScapeActiveLogFile {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    return $Script:CurrentLogFile
}

# Engine event protegido
try {
    Register-EngineEvent -SourceIdentifier PowerShell.OnExit -Action { Close-ScapeLogStream } -SupportEvent -ErrorAction SilentlyContinue
}
catch { }
