<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Audit
    Description: Immutable forensic ledger for extracted artifacts chain-of-custody with hash chaining.
    Zero hardcode configs via infrastructure::Audit and system::LIMITS.
    Thread-safe with backpressure, PowerShell 5.1 compatible.
#>
[CmdletBinding()] param()

$Script:C = $null
$Script:Ledger = [System.Collections.Generic.List[PSCustomObject]]::new()
$Script:LastHash = $null
$Script:SequenceId = 0
$Script:LogStream = $null
$Script:Semaphore = $null
$Script:Initialized = $false

function Initialize-ScapeAudit {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([bool])]
    param()

    if ($Script:Initialized) { return $true }
    if (-not $PSCmdlet.ShouldProcess("Audit Module", "Initialize Forensic Ledger")) { return $false }

    try {
        # --- 2. CONFIGURAÃ‡ÃƒO DECLARATIVA ---
        $Script:C = @{
            Audit  = Get-ScapeConstant -Path "infrastructure::Audit" -Fallback @{}
            Limits = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
        }

        # --- 3. LÃ“GICA DE GÃŠNESIS ---
        $genesis = $Script:C.Audit["GENESIS_BLOCK"]
        if ($null -eq $genesis) { $genesis = "SCAPE_AUDIT_GENESIS_v1.0" }

        $hashAlgo = $Script:C.Audit["HASH_ALGO"]
        if ($null -eq $hashAlgo) { $hashAlgo = "SHA256" }

        $Script:LastHash = _ComputeHash -RawData $genesis -Algo $hashAlgo
        $Script:SequenceId = 0

        # --- 4. INFRAESTRUTURA DE LOGS ---
        $subDir = $Script:C.Audit["LOG_DIR"]
        if ($null -eq $subDir) { $subDir = "Logs" }

        $logDir = Join-Path ((Get-ScapeColdState)["ROOT"]) $subDir
        if (-not (Test-Path $logDir)) { $null = New-Item -ItemType Directory -Path $logDir -Force }

        $logFile = Join-Path $logDir ("SCAPE_Audit_{0}.log" -f (Get-Date -Format "yyyyMMdd"))

        $Script:LogStream = [System.IO.StreamWriter]::new($logFile, $true, [System.Text.Encoding]::UTF8)
        $Script:LogStream.AutoFlush = ($Script:C.Audit["LOG_IMMEDIATE_FLUSH"] -eq $true)

        # --- 5. CONTROLE DE CARGA (BACKPRESSURE PRESERVADO) ---
        $maxOps = $Script:C.Limits["MAX_CONCURRENT_OPS"]
        if ($null -eq $maxOps) { $maxOps = 16 }
        $Script:Semaphore = [System.Threading.SemaphoreSlim]::new($maxOps, $maxOps)

        # --- 6. EVENT LISTENER ---
        if (Get-Command "Register-ScapeEventListener" -ErrorAction SilentlyContinue) {
            $script:AuditAction = {
                param($IncomingEvt)

                if ($IncomingEvt.Type -match "^(AUDIT_|EVENT_BUS)") { return }

                $types = $Script:C.Audit["AUDIT_EVENT_TYPES"]
                if ($null -eq $types) { $types = @("*") }

                if ($types -notcontains "*" -and $types -notcontains $IncomingEvt.Type) { return }

                # Gerenciamento de Backpressure com TIMEOUT PRESERVADO
                if (-not $Script:Semaphore.Wait(0)) {
                    if ($IncomingEvt.Severity -notin @("LOG_ERR", "LOG_FATAL", "COMPLIANCE")) { return }

                    $timeout = $Script:C.Audit["BACKPRESSURE_TIMEOUT_MS"]
                    if ($null -eq $timeout) { $timeout = Get-ScapeConstant -Path "system::Limits::CRITICAL_SECTION_TIMEOUT_MS" -Fallback 5000 } # <<< PRESERVADO

                    $deadline = [DateTime]::UtcNow.AddMilliseconds($timeout)
                    $timeToWait = [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds
                    
                    $acquired = $false
                    while (-not $acquired -and $timeToWait -gt 0) {
                        $acquired = $Script:Semaphore.Wait(0)
                        if (-not $acquired) {
                            if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null } else { [System.Threading.Thread]::Sleep(10) }
                            $timeToWait = [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds
                        }
                    }
                    if (-not $acquired) { return }
                }
                try {
                    $record = New-ScapeAuditRecord -EventFrame $IncomingEvt
                    if ($record) {
                        $null = $Script:Ledger.Add($record)
                        $Script:LogStream?.WriteLine((_FormatLogLine -Record $record))
                    }
                }
                finally {
                    $null = $Script:Semaphore.Release()
                }
            }

            Register-ScapeEventListener -EventMatch "*" -Action $script:AuditAction
        }

        # --- 7. FINALIZAÃ‡ÃƒO ---
        $Script:Initialized = $true

        Publish-ScapeEvent -Type "AUDIT_INITIALIZED" -Severity "LOG_INFO" -Payload @{
            HashAlgorithm = $hashAlgo
            GenesisHash   = $Script:LastHash
            LedgerPath    = $logFile
            Message       = Get-ScapeLogMsg -Key "AUDIT_INIT_OK" -MsgArgs @($logFile)
        }

        return $true
    }
    catch {
        Publish-ScapeFault -ErrorRecord $_ -Context "Audit_Init" -Message (
            Get-ScapeLogMsg -Key "ROUTER_FATAL" -MsgArgs @($_.Exception.Message)
        )
        return $false
    }
}

function Register-ScapeExtraction {
    [CmdletBinding(SupportsShouldProcess = $true)] [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][string]$SourceIdentifier,
        [Parameter(Mandatory = $true)][string]$DestinationPath,
        [Parameter(Mandatory = $true)][string]$HashSHA256,
        [Parameter(Mandatory = $true)][long]$SizeBytes,
        [Parameter(Mandatory = $true)][string]$ToolName,
        [string]$OperatorId = "SYS_CORE",
        [string]$ChainOfCustodyNote
    )

    if ($PSCmdlet.ShouldProcess("Ledger", "Register Extraction")) {
        $payload = [PSCustomObject]@{
            Source      = $SourceIdentifier
            Destination = $DestinationPath
            HashSHA256  = $HashSHA256
            SizeBytes   = $SizeBytes
            Tool        = $ToolName
            CustodyNote = $ChainOfCustodyNote
        }

        $eventFrame = [PSCustomObject]@{
            Type       = "ARTIFACT_EXTRACTED"
            Severity   = "LOG_INFO"
            OperatorId = $OperatorId
            Payload    = $payload
            Timestamp  = [DateTime]::UtcNow
        }

        return New-ScapeAuditRecord -EventFrame $eventFrame
    }
}

function New-ScapeAuditRecord {
    [CmdletBinding(SupportsShouldProcess = $true)] [OutputType([psobject])]
    param([PSCustomObject]$EventFrame)

    if ($PSCmdlet.ShouldProcess("Ledger", "Append Record")) {
        if (-not $EventFrame) { return $null }

        $operator = $EventFrame.OperatorId
        if ($null -eq $operator) {
            $defaultOp = $Script:C.Audit["DEFAULT_OPERATOR"]
            if ($null -eq $defaultOp) { $defaultOp = "SYS_CORE" }
            $operator = $defaultOp
        }
        $timeFormat = $Script:C.Audit["TIME_FORMAT"]
        if ($null -eq $timeFormat) { $timeFormat = "yyyy-MM-ddTHH:mm:ss.fffZ" }
        $timestamp = [DateTime]::UtcNow.ToString($timeFormat)
        $hashAlgo = $Script:C.Audit["HASH_ALGO"]
        if ($null -eq $hashAlgo) { $hashAlgo = "SHA256" }

        $jsonPayload = if ($EventFrame.Payload) {
            try { $EventFrame.Payload | ConvertTo-Json -Depth 10 -Compress -ErrorAction Stop }
            catch { '{"Error":"JSON_SERIALIZE_FAILED"}' }
        }
        else { "{}" }

        $chainInput = "{0}|{1}|{2}|{3}|{4}" -f $Script:LastHash, $timestamp, $EventFrame.Type, $operator, $jsonPayload
        $currentHash = _ComputeHash -RawData $chainInput -Algo $hashAlgo

        $Script:SequenceId++
        $severity = $EventFrame.Severity
        if ($null -eq $severity) { $severity = "LOG_INFO" }
        $record = [PSCustomObject]@{
            SequenceId   = $Script:SequenceId.ToString("D10")
            Timestamp    = $timestamp
            EventType    = $EventFrame.Type
            Severity     = $severity
            Operator     = $operator
            PreviousHash = $Script:LastHash
            Integrity    = "{0}:{1}" -f $hashAlgo, $currentHash
            Details      = $jsonPayload
        }

        $Script:LastHash = $currentHash
        return $record
    }
    return $null
}

function Export-ScapeAuditLedger {
    [CmdletBinding(SupportsShouldProcess = $true)] [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$OutputPath,
        [ValidateSet("JSON", "CSV")][string]$Format = "JSON",
        [switch]$IncludeChainVerification
    )

    if ($PSCmdlet.ShouldProcess($OutputPath, "Export Audit Ledger")) {
        try {
            if ($Script:LogStream) { $Script:LogStream.Flush() }

            $state = Get-ScapeColdState
            $sessionId = $state["DATA_SESSION_ID"]
            if ($null -eq $sessionId) { $sessionId = [guid]::NewGuid().ToString() }
            $engineVersion = Get-ScapeConstant -Path "system::META::VERSION" 
            $report = [PSCustomObject]@{
                ExportTime    = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                SessionId     = $sessionId
                EngineVersion = $engineVersion
                TotalRecords  = $Script:Ledger.Count
                ClosingHash   = $Script:LastHash
                ChainVerified = $false
                Records       = $Script:Ledger.ToArray()
            }

            if ($IncludeChainVerification) {
                $report.ChainVerified = _VerifyLedgerChain
            }

            if ($Format -eq "CSV") {
                $mappedRecords = $report.Records | Select-Object `
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_ID'); E = { $_.SequenceId } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_NAME'); E = { $_.EventType } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_SIZE'); E = { if ($_.Details -match '"SizeBytes":(\d+)') { $matches[1] } else { 0 } } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_TYPE'); E = { $_.Operator } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_STATUS'); E = { $_.Severity } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_CATEGORY'); E = { "" } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_HASH'); E = { $_.PreviousHash } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_SCORE'); E = { $_.Integrity } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_OFFSET'); E = { "" } },
                @{N = (Invoke-ScapeI18NFormat -Key 'TABLE_HEADER_LENGTH'); E = { "" } }
                $csv = $mappedRecords | ConvertTo-Csv -NoTypeInformation
                [System.IO.File]::WriteAllLines($OutputPath, $csv)
            }
            else {
                $json = $report | ConvertTo-Json -Depth 10
                [System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
            }

            $msgExport = Get-ScapeLogMsg -Key "AUDIT_REPORT_GEN" -MsgArgs @($OutputPath)
            Publish-ScapeEvent -Type "AUDIT_EXPORT_SUCCESS" -Severity "LOG_INFO" -Payload @{
                Path     = $OutputPath
                Count    = $report.TotalRecords
                Verified = $report.ChainVerified
                Message  = $msgExport
            }
            return @{ Success = $true; Path = $OutputPath; Records = $report.TotalRecords }
        }
        catch {
            $errMsg = Get-ScapeLogMsg -Key "ROUTER_FATAL" -MsgArgs @($_.Exception.Message)
            Publish-ScapeFault -ErrorRecord $_ -Context "Audit_Export" -Message $errMsg
            return @{ Success = $false; Error = $_.Exception.Message }
        }
    }
}

function _VerifyLedgerChain {
    [CmdletBinding()] [OutputType([bool])]
    param()
    $hashAlgo = $Script:C.Audit["HASH_ALGO"]
    if ($null -eq $hashAlgo) { $hashAlgo = "SHA256" }
    $expectedNext = $Script:C.Audit["GENESIS_BLOCK"]
    if ($null -eq $expectedNext) { $expectedNext = "SCAPE_AUDIT_GENESIS_v1.0" }
    $expectedNext = _ComputeHash -RawData $expectedNext -Algo $hashAlgo

    foreach ($rec in $Script:Ledger) {
        if ($rec.PreviousHash -ne $expectedNext) { return $false }
        $chainInput = "{0}|{1}|{2}|{3}|{4}" -f $rec.PreviousHash, $rec.Timestamp, $rec.EventType, $rec.Operator, $rec.Details
        $expectedNext = _ComputeHash -RawData $chainInput -Algo $hashAlgo
        $storedHash = $rec.Integrity -replace "^${hashAlgo}:", ""
        if ($storedHash -ne $expectedNext) { return $false }
    }
    return $true
}

function _ComputeHash {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)][string]$RawData, [string]$Algo = "SHA256")
    try {
        $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($Algo)
        if (-not $hasher) { $hasher = [System.Security.Cryptography.SHA256]::Create() }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($RawData)
        $hashBytes = $hasher.ComputeHash($bytes)
        $hasher.Dispose()
        return [System.BitConverter]::ToString($hashBytes) -replace '-'
    }
    catch {
        return $RawData.GetHashCode().ToString("X8")
    }
}

function _FormatLogLine {
    [CmdletBinding()] [OutputType([string])]
    param([PSCustomObject]$Record)
    return "[{0}] [{1}] SEQ:{2} | {3} | {4} | {5}" -f `
        $Record.Timestamp, $Record.Severity, $Record.SequenceId, `
        $Record.EventType, $Record.Operator, $Record.Integrity
}

Register-EngineEvent -SourceIdentifier PowerShell.OnExit -Action {
    if ($Script:LogStream) {
        $Script:LogStream.Flush()
        $Script:LogStream.Close()
        $Script:LogStream.Dispose()
    }
    if ($Script:Semaphore) { $Script:Semaphore.Dispose() }
}
Register-ScapeActionHandler -Target 'Scape.Infrastructure.Audit' -Handler {
    param($Task, $PayloadDef, $Target)
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "AUDIT_EXPORTING" ) -StatusFlag "INFO" -RunProgress 10 -StepProgress 10
    
    
    $workspace = Get-ScapeConstant -Path "system::Workspace" -Fallback @{}
    $exportSubDir = if ($workspace.ContainsKey("Exports")) { $workspace["Exports"] } else { "Data\Exports" }
    
    $root = (Get-ScapeColdState)["ROOT"]
    if ([string]::IsNullOrWhiteSpace($root)) { $root = (Get-Location).Path }
    $exportDir = Join-Path $root $exportSubDir
    
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "AUDIT_EXPORTING" ) -StatusFlag "INFO" -RunProgress 30 -StepProgress 40
    

    if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
    $exportPath = Join-Path $exportDir "AuditLedger_$(Get-Date -f 'yyyyMMdd_HHmmss').json"
    
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "AUDIT_EXPORTING" ) -StatusFlag "INFO" -RunProgress 70 -StepProgress 80
    

    if (Get-Command Export-ScapeAuditLedger -ErrorAction SilentlyContinue) {
        $result = Export-ScapeAuditLedger -OutputPath $exportPath -Format "JSON"
        if ($result.Success) {
            Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "AUDIT_EXPORT_SUCCESS" ) -StatusFlag "Success" -RunProgress 100 -StepProgress 100
        }
        else {
            Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "AUDIT_EXPORT_FAILED" ) -StatusFlag "Failure" -RunProgress 100 -StepProgress 0
            throw "Audit export failed"
        }
    }
    else {
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "AUDIT_MODULE_NOT_LOADED" ) -StatusFlag "Failure" -RunProgress 100 -StepProgress 0
        throw "Audit module not available."
    }
}
