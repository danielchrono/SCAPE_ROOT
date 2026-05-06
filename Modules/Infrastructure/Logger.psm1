<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Logger
    Description: Thread-safe operational logging with rotation, severity filtering, and zero hardcode.
    Subscribes to EventBus, respects backpressure, PowerShell 5.1 compatible.
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

    # Guard: evita re-inicialização
    if ($Script:Initialized) { return $true }

    # --- 1. CONFIGURAÇÃO DECLARATIVA (Fail-Fast se asset não existir) ---
    $loggerCfg = Get-ScapeConstant -Path "infrastructure::Logger"
    if ($null -eq $loggerCfg) {
        Write-Host "[LOGGER] Configuração não encontrada!" -ForegroundColor Red
        return $false
    }

    $Script:Config = @{
        Logger    = $loggerCfg
        LogLevels = Get-ScapeConstant -Path "infrastructure::LogSeverity" -Fallback @{}
        Limits    = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
        Dirs      = Get-ScapeConstant -Path "system::Workspace" -Fallback @{}
    }

    # --- 2. CONFIGURAÇÃO DE SEVERIDADE ---
    $severityMap = $Script:Config.Logger["LOG_LEVELS"]
    if ($null -eq $severityMap) {
        $severityMap = @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 }
    }

    $minLevelName = $Script:Config.Logger["DEFAULT_LEVEL_NAME"]
    if ($null -eq $minLevelName) { $minLevelName = "INFO" }

    $Script:MinSeverityValue = $severityMap[$minLevelName]
    if ($null -eq $Script:MinSeverityValue) { $Script:MinSeverityValue = 1 }

    try {
        # --- 3. INFRAESTRUTURA DE DIRETÓRIO ---
        $root = (Get-ScapeColdState)["ROOT"]
        if ([string]::IsNullOrWhiteSpace($root)) { return $false }

        $logFolder = $Script:Config.Dirs["LOGS"]
        if ($null -eq $logFolder) { $logFolder = "Logs" }

        $logDir = Join-Path $root $logFolder
        if (-not (Test-Path $logDir)) {
            $null = New-Item -ItemType Directory -Path $logDir -Force
        }

        # --- 4. SETUP DO STREAM ---
        $pattern = $Script:Config.Logger["LOG_FILE_PATTERN"]
        if ($null -eq $pattern) { $pattern = "scape_{0:yyyyMMdd_HHmmss}.log" }

        $Script:CurrentLogFile = Join-Path $logDir ($pattern -f [DateTime]::Now)
        $Script:LogStream = [System.IO.StreamWriter]::new($Script:CurrentLogFile, $true, [System.Text.Encoding]::UTF8)
        $Script:LogStream.AutoFlush = ($Script:Config.Logger["LOG_IMMEDIATE_FLUSH"] -eq $true)

        # Semaphore para Backpressure
        $maxOps = $Script:Config.Limits["MAX_CONCURRENT_OPS"]
        if ($null -eq $maxOps) { $maxOps = 16 }
        $Script:Semaphore = [System.Threading.SemaphoreSlim]::new($maxOps, $maxOps)

        # --- 5. ACTION BLOCK (ISOLADO) ---
        if (Get-Command "Register-ScapeEventListener" -ErrorAction SilentlyContinue) {

            $script:LogAction = {
                param($IncomingEvt)

                # Filtro de Exclusão
                $excludes = $Script:Config.Logger["LOG_EXCLUDE_TYPES"]
                if ($null -eq $excludes) {
                    $excludes = @("TRACE", "METRIC_SAMPLE", "TELEMETRY_HEARTBEAT")
                }

                $excludeRegex = "^($($excludes -join '|'))$"
                if ($IncomingEvt.Type -match $excludeRegex) { return }

                # Filtro de Severidade
                $evtSeverity = $IncomingEvt.Severity -replace '^LOG_', ''
                $evtValue = $severityMap[$evtSeverity]
                if ($null -eq $evtValue) { $evtValue = 1 }

                if ($evtValue -lt $Script:MinSeverityValue) { return }

                # Controle de Semaphore
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

            Register-ScapeEventListener -EventMatch "*" -Action $script:LogAction

            # Shutdown Events
            $stopEvents = $Script:Config.Logger["SHUTDOWN_EVENTS"]
            if ($null -eq $stopEvents) {
                $stopEvents = @("ROUTER_STOP", "SYSTEM_CRASH", "DEPLOYER_DONE")
            }

            $stopRegex = "($($stopEvents -join '|'))"
            Register-ScapeEventListener -EventMatch $stopRegex -Action { Close-ScapeLogStream }
        }

        # --- 6. SINALIZAÇÃO DE SUCESSO ---
        $maxSize = $Script:Config.Logger["MAX_LOG_SIZE_MB"]
        if ($null -eq $maxSize) { $maxSize = 10 }

        Publish-ScapeEvent -Type "LOGGER_INITIALIZED" -Severity "LOG_INFO" -Payload @{
            LogFile   = $Script:CurrentLogFile
            MinLevel  = $minLevelName
            MaxSizeMB = $maxSize
            Message   = Get-ScapeLogMsg -Key "CORE_ENGINE_START"
        }

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

# --- 1. ESCRITA DE REGISTROS (PIPELINE COMPACTO) ---
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
            try { $payloadStr = $EventFrame.Payload | ConvertTo-Json -Depth 3 -Compress -ErrorAction Stop }
            catch { $payloadStr = '{"Error":"JSON_SERIALIZE_FAILED"}' }
        }

        $logLine = "[{0}] [{1}] [{2}] [{3}] {4} | {5}" -f $timestamp, $enriched.Severity, $enriched.Layer, $enriched.Source, $enriched.Type, $payloadStr
        $Script:LogStream.WriteLine($logLine)
    }
    catch {
        Write-Verbose "Logger write failed: $($_.Exception.Message)"
    }
}

# --- 2. ENRIQUECIMENTO (FUNCIONAL STACK INSPECTION) ---
function _EnrichWithCallerInfo {
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param([PSCustomObject]$EventFrame)

    if ($EventFrame.Source -and $EventFrame.Layer) { return $EventFrame }

    $ignorePattern = 'Publish-ScapeEvent|Write-ScapeLogRecord|_EnrichWithCallerInfo|<ScriptBlock>'
    $callerFrame = Get-PSCallStack | Select-Object -Skip 1 |
    Where-Object { $_.Command -notmatch $ignorePattern } |
    Select-Object -First 1

    $caller = $callerFrame.Command
    if ($null -eq $caller) { $caller = "SYSTEM" }

    $layer = "CORE"
    $module = ""

    if ($modName = $callerFrame.ModuleName) {
        $parts = $modName -split '\.'
        $layerVal = $parts[1]
        if ($null -eq $layerVal) { $layerVal = "CORE" }
        $layer = $layerVal.ToUpper()
        $module = $parts[2]
        if ($null -eq $module) { $module = "" }
    }
    elseif ($caller -match '\.ps1$') {
        $layer = "BOOT"
        $caller = Split-Path $caller -Leaf
    }

    $source = if ($module) { "[$module] $caller" } else { $caller }

    $opId = $EventFrame.OperatorId
    if ($null -eq $opId) { $opId = "SYS_CORE" }

    return [PSCustomObject]@{
        Timestamp  = $EventFrame.Timestamp
        Type       = $EventFrame.Type
        Severity   = $EventFrame.Severity
        Payload    = $EventFrame.Payload
        Layer      = $layer
        Source     = $source -replace '\s+', ' '
        OperatorId = $opId
    }
}

# --- 3. ROTAÇÃO DE LOG (ESTRUTURA ATÔMICA) ---
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
    catch {
        # Falha na rotação não deve parar o sistema
    }
}

# --- 4. CLEANUP (RECURSIVE DISPOSAL) ---
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

# EngineEvent para garantir flush no exit
Register-EngineEvent -SourceIdentifier PowerShell.OnExit -Action { Close-ScapeLogStream } -SupportEvent
