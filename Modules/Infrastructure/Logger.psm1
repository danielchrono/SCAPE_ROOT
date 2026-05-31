<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Logger
    Description: Thread-safe operational logging with rotation, severity filtering, and zero hardcode.
    [PATCH] Fixed Resolve-ScapeCallerInfo to handle runspace failures, protected Register-EngineEvent
#>
[CmdletBinding()] param()

$Script:LogStream = $null
$Script:Semaphore = $null
$Script:CurrentLogFile = $null
$Script:Config = $null
$Script:RotationCounter = "0"
$Script:Initialized = $false

function Resolve-LogLevel {
    param([hashtable]$LoggerConfig)
    $minLevelName = $LoggerConfig["DEFAULT_LEVEL_NAME"]
    if ([string]::IsNullOrWhiteSpace($minLevelName)) { $minLevelName = "INFO" }

    try { $cs = Get-ScapeColdState } catch { $cs = $null }
    if ($cs -and $cs.ContainsKey('LOG_LEVEL_OVERRIDE')) { return $cs['LOG_LEVEL_OVERRIDE'] }
    if ($cs -and $cs.ContainsKey('DEV_MODE') -and $cs['DEV_MODE']) { return 'TRACE' }

    return $minLevelName
}

function Initialize-LogDirectory {
    param([hashtable]$LoggerConfig, [hashtable]$DirsConfig)
    [void]$LoggerConfig
    $logDir = $null
    try { $logDir = (Get-ScapeColdState)["WORKSPACE_LOGS"] } catch { Write-Verbose "Suppressed error:     try { `$logDir = (Get-ScapeColdState)[`"WORKSPACE_LOGS`"] } catch {}"; }

    if ([string]::IsNullOrWhiteSpace($logDir)) {
        $root = $null
        try { $root = (Get-ScapeColdState)["ROOT"] } catch { Write-Verbose "Suppressed error:         try { `$root = (Get-ScapeColdState)[`"ROOT`"] } catch {}"; }
        if ([string]::IsNullOrWhiteSpace($root)) { return $null }
        $logFolder = $DirsConfig["LOGS"]
        if ([string]::IsNullOrWhiteSpace($logFolder)) { $logFolder = "Logs" }
        $logDir = Join-Path $root $logFolder
    }

    if (-not (Test-Path -LiteralPath $logDir)) {
        $null = New-Item -ItemType Directory -Path $logDir -Force
    }
    return $logDir
}

function Initialize-ScapeLogger {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ($Script:Initialized) { return $true }

    $loggerCfg = Get-ScapeConstant -Path "infrastructure::Logger"
    if ($null -eq $loggerCfg) {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            $msg = if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "ROUTER_FATAL" -Args @("LOGGER_CONFIG_MISSING") } else { "LOGGER_CONFIG_MISSING" }
            Publish-ScapeEvent -Type "SYSTEM_FAULT" -Severity "LOG_WARN" -Payload @{ Context = "Logger_Config"; Message = $msg }
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

    $minLevelName = Resolve-LogLevel -LoggerConfig $Script:Config.Logger
    $Script:MinSeverityValue = $Script:SeverityMap[$minLevelName]
    if ($null -eq $Script:MinSeverityValue) { $Script:MinSeverityValue = 1 }

    try {
        $logDir = Initialize-LogDirectory -LoggerConfig $Script:Config.Logger -DirsConfig $Script:Config.Dirs
        if ($null -eq $logDir) { return $false }

        $pattern = $Script:Config.Logger["LOG_FILE_PATTERN"]
        if ([string]::IsNullOrWhiteSpace($pattern)) { $pattern = "scape_{0:yyyyMMdd_HHmmss}.log" }

        $Script:CurrentLogFile = Join-Path $logDir ($pattern -f [DateTime]::Now)
        $Script:LogStream = [System.IO.StreamWriter]::new($Script:CurrentLogFile, $true, [System.Text.Encoding]::UTF8)
        $Script:LogStream.AutoFlush = ($Script:Config.Logger["LOG_IMMEDIATE_FLUSH"] -eq $true)

        $maxOps = $Script:Config.Limits["MAX_CONCURRENT_OPS"]
        if ($null -eq $maxOps) { $maxOps = 16 }
        $Script:Semaphore = [System.Threading.SemaphoreSlim]::new($maxOps, $maxOps)

        if (Get-Command "Register-ScapeEventListener" -ErrorAction SilentlyContinue) {
            $loggerRef = [ref]$Script:LogStream
            $semRef = [ref]$Script:Semaphore
            $configRef = $Script:Config
            $sevMapRef = $Script:SeverityMap
            $minSevRef = [ref]$Script:MinSeverityValue
            $currentFileRef = [ref]$Script:CurrentLogFile
            $rotCountRef = [ref]$Script:RotationCounter

            $logAction = {
                param($IncomingEvt)
                try {
                    $stream = $loggerRef.Value
                    $sem = $semRef.Value
                    if ($null -eq $stream -or $null -eq $sem) { return }

                    $excludes = $configRef.Logger["LOG_EXCLUDE_TYPES"]
                    if ($null -eq $excludes) { $excludes = @("METRIC_SAMPLE", "TELEMETRY_HEARTBEAT") }

                    $excludeRegex = if ($excludes.Count -gt 0) { "^($($excludes -join '|'))$" } else { "^$" }
                    if ($IncomingEvt.Type -match $excludeRegex) { return }

                    $evtSeverity = $IncomingEvt.Severity -replace '^LOG_', ''
                    $evtValue = $sevMapRef[$evtSeverity]
                    if ($null -eq $evtValue) { $evtValue = 1 }
                    if ($evtValue -lt $minSevRef.Value) { return }

                    if (-not $sem.Wait(0)) {
                        if ($IncomingEvt.Severity -notin @("LOG_ERR", "LOG_FATAL", "COMPLIANCE")) { return }
                        $timeout = $configRef.Limits["CRITICAL_SECTION_TIMEOUT_MS"]
                        if ($null -eq $timeout) { $timeout = Get-ScapeConstant -Path "system::Limits::CRITICAL_SECTION_TIMEOUT_MS" -Fallback 5000 }
                        $deadline = [DateTime]::UtcNow.AddMilliseconds($timeout)
                        $timeToWait = [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds

                        $acquired = $false
                        while (-not $acquired -and $timeToWait -gt 0) {
                            $acquired = $sem.Wait(0)
                            if (-not $acquired) {
                                if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null } else { [System.Threading.Thread]::Sleep(10) }
                                $timeToWait = [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds
                            }
                        }
                        if (-not $acquired) { return }
                    }

                    try {
                        $maxSizeMB = $configRef.Logger["MAX_LOG_SIZE_MB"]
                        if ($null -eq $maxSizeMB) { $maxSizeMB = 10 }
                        $curFile = $currentFileRef.Value
                        if ($curFile -and $stream.BaseStream.CanWrite) {
                            $fi = [System.IO.FileInfo]::new($curFile)
                            if ($fi.Exists -and $fi.Length -gt ($maxSizeMB * 1MB)) {
                                $stream.Flush()
                                $stream.Dispose()
                                $base = [System.IO.Path]::ChangeExtension($curFile, $null)
                                $ext = [System.IO.Path]::GetExtension($curFile)
                                $rotCountRef.Value = [string]([int]$rotCountRef.Value + 1)
                                $archived = "{0}_{1}{2}" -f $base, $rotCountRef.Value, $ext
                                [System.IO.File]::Move($curFile, $archived)
                                $newStream = [System.IO.StreamWriter]::new($curFile, $true, [System.Text.Encoding]::UTF8)
                                $newStream.AutoFlush = ($configRef.Logger["LOG_IMMEDIATE_FLUSH"] -eq $true)
                                $loggerRef.Value = $newStream
                                $stream = $newStream
                            }
                        }

                        if ($stream.BaseStream.CanWrite) {
                            $timeFormat = $configRef.Logger["TIMESTAMP_FORMAT"]
                            if ($null -eq $timeFormat) { $timeFormat = "yyyy-MM-ddTHH:mm:ss.fffZ" }
                            $timestamp = [DateTime]::UtcNow.ToString($timeFormat)

                            $payloadStr = "{}"
                            if ($IncomingEvt.Payload) {
                                try { $payloadStr = $IncomingEvt.Payload | ConvertTo-Json -Depth 100 -Compress -WarningAction SilentlyContinue -ErrorAction Stop }
                                catch { $payloadStr = '{"Error":"JSON_SERIALIZE_FAILED"}' }
                            }

                            $source = if ($IncomingEvt.Source) { $IncomingEvt.Source } else { "SYSTEM" }
                            $logLine = "[{0}] [{1}] [{2}] {3} | {4}" -f $timestamp, $IncomingEvt.Severity, $source, $IncomingEvt.Type, $payloadStr
                            $stream.WriteLine($logLine)
                        }
                    }
                    finally {
                        $null = $sem.Release()
                    }
                }
                catch { Write-Verbose "Suppressed error:                 catch {}"; }
            }.GetNewClosure()

            Register-ScapeEventListener -EventMatch "*" -Action $logAction

            $stopEvents = $Script:Config.Logger["SHUTDOWN_EVENTS"]
            if ($null -eq $stopEvents) { $stopEvents = @("SYSTEM_CRASH", "DEPLOYER_DONE") }
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
            Message   = $(if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "CORE_ENGINE_START" -Args @() } else { "CORE_ENGINE_START" })
        }

        $Script:Initialized = $true
        return $true
    }
    catch {
        Publish-ScapeFault -ErrorRecord $_ -Context "Logger_Init" -Message $(
            if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "ROUTER_FATAL" -Args @($_.Exception.Message) } else { $_.Exception.Message }
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

        $enriched = Resolve-ScapeCallerInfo -EventFrame $EventFrame

        $payloadStr = "{}"
        if ($EventFrame.Payload) {
            try { $payloadStr = $EventFrame.Payload | ConvertTo-Json -Depth 100 -Compress -WarningAction SilentlyContinue -ErrorAction Stop }
            catch { $payloadStr = '{"Error":"JSON_SERIALIZE_FAILED"}' }
        }

        $logLine = "[{0}] [{1}] [{2}] {3} | {4}" -f $timestamp, $enriched.Severity, $enriched.Source, $enriched.Type, $payloadStr
        $Script:LogStream.WriteLine($logLine)
    }
    catch {
        Write-Verbose "Logger write failed: $($_.Exception.Message)"
    }
}

function Resolve-ScapeCallerInfo {
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param([PSCustomObject]$EventFrame)

    if ($EventFrame.Source -and $EventFrame.Layer) { return $EventFrame }

    $ignorePattern = 'Publish-ScapeEvent|Write-ScapeLogRecord|Resolve-ScapeCallerInfo|<ScriptBlock>'
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

function Invoke-ScapeLogRotation {
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
            Message = $(if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "LOG_ROTATED" -Args @($archived, $Script:CurrentLogFile, $Script:RotationCounter) } else { "LOG_ROTATED" })
        }
    }
    catch { Write-Verbose "Suppressed error:     catch { }"; }
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
catch { Write-Verbose "Suppressed error: catch { }"; }

Export-ModuleMember -Function 'Resolve-LogLevel',
'Initialize-LogDirectory',
'Initialize-ScapeLogger',
'Write-ScapeLogRecord',
'Resolve-ScapeCallerInfo',
'Invoke-ScapeLogRotation',
'Close-ScapeLogStream',
'Get-ScapeActiveLogFile'
