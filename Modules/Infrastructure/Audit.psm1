<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Audit
    Description: Ledger forense imutável. Compatível com PowerShell 5.1.
#>
[CmdletBinding()] param()

$Script:C = $null
$Script:Ledger = [System.Collections.Generic.List[PSCustomObject]]::new()
$Script:LastHash = $null
$Script:SequenceId = 0
$Script:LogStream = $null
$Script:BackpressureSemaphore = $null

function Initialize-ScapeAudit {
    [CmdletBinding(SupportsShouldProcess=$true)] [OutputType([bool])]
    param()

    if ($PSCmdlet.ShouldProcess("Audit Module", "Initialize Ledger")) {
        $Script:C = @{
            AUDIT  = Get-ScapeConstant -Path "compliance::AUDIT" -Fallback @{}
            LIMITS = Get-ScapeConstant -Path "behavior::LIMITS" -Fallback @{}
        }

        $genesis = "SCAPE_GENESIS_v1.0"
        if ($null -ne $Script:C.AUDIT["GENESIS_BLOCK"]) { $genesis = $Script:C.AUDIT["GENESIS_BLOCK"] }

        $hashAlgo = "SHA256"
        if ($null -ne $Script:C.AUDIT["HASH_ALGO"]) { $hashAlgo = $Script:C.AUDIT["HASH_ALGO"] }

        $Script:LastHash = _ComputeHash -RawData $genesis -Algo $hashAlgo

        $logDir = Join-Path -Path $BootRoot -ChildPath "Logs"
        if (-not (Test-Path -Path $logDir)) { $null = New-Item -ItemType Directory -Path $logDir -Force }

        $logFile = Join-Path -Path $logDir -ChildPath ("SCAPE_Audit_{0}.log" -f (Get-Date -Format "yyyyMMdd"))
        try {
            $Script:LogStream = [System.IO.StreamWriter]::new($logFile, $true, [System.Text.Encoding]::UTF8)
            $Script:LogStream.AutoFlush = ($Script:C.AUDIT["LOG_IMMEDIATE_FLUSH"] -eq $true)
        } catch {
            Write-Error "[AUDIT] Erro ao abrir log: $($_.Exception.Message)"
            return $false
        }

        $maxConcurrent = 16
        if ($null -ne $Script:C.LIMITS["MAX_CONCURRENT_OPS"]) { $maxConcurrent = $Script:C.LIMITS["MAX_CONCURRENT_OPS"] }
        $Script:BackpressureSemaphore = [System.Threading.SemaphoreSlim]::new($maxConcurrent, $maxConcurrent)

        if (Get-Command "Register-ScapeEventListener" -ErrorAction SilentlyContinue) {
            Register-ScapeEventListener -EventMatch "*" -Action {
                param($IncomingEvt)
                if ($IncomingEvt.Type -match "AUDIT|EVENT_BUS") { return }
                _ProcessAuditEvent -IncomingEvt $IncomingEvt
            }
        }
        return $true
    }
    return $false
}

function _ProcessAuditEvent {
    [CmdletBinding()] [OutputType([void])]
    param([PSCustomObject]$IncomingEvt)

    if (-not $Script:BackpressureSemaphore.Wait(0)) {
        if ($IncomingEvt.Severity -notin @("LOG_ERR", "LOG_FATAL", "COMPLIANCE")) { return }
        $timeout = 5000
        if ($null -ne $Script:C.LIMITS["AUDIT_TIMEOUT_MS"]) { $timeout = $Script:C.LIMITS["AUDIT_TIMEOUT_MS"] }
        if (-not $Script:BackpressureSemaphore.Wait([int]$timeout)) { return }
    }

    try {
        $auditTypes = @("*")
        if ($null -ne $Script:C.AUDIT["AUDIT_EVENT_TYPES"]) { $auditTypes = $Script:C.AUDIT["AUDIT_EVENT_TYPES"] }

        if ($auditTypes -notcontains "*" -and $auditTypes -notcontains $IncomingEvt.Type) { return }

        $record = New-ScapeAuditRecord -EventFrame $IncomingEvt
        if ($null -ne $record) {
            $Script:Ledger.Add($record)
            $logLine = _FormatLogLine -Record $record
            if ($null -ne $Script:LogStream) {
                $Script:LogStream.WriteLine($logLine)
            }
        }
    } catch {
        Write-Verbose "Audit write suppressed to avoid recursion: $($_.Exception.Message)" -ErrorAction SilentlyContinue
    } finally {
        $null = $Script:BackpressureSemaphore.Release()
    }
}

function New-ScapeAuditRecord {
    [CmdletBinding(SupportsShouldProcess=$true)] [OutputType([psobject])]
    param([PSCustomObject]$EventFrame)

    if ($PSCmdlet.ShouldProcess("Ledger", "Append Record")) {
        if ($null -eq $EventFrame) { return $null }

        $operator = "SYS_CORE"
        if ($null -ne $EventFrame.OperatorId) { $operator = $EventFrame.OperatorId }

        $timeFormat = "yyyy-MM-ddTHH:mm:ss.fffZ"
        if ($null -ne $Script:C.AUDIT["TIME_FORMAT"]) { $timeFormat = $Script:C.AUDIT["TIME_FORMAT"] }
        $timestamp = [DateTime]::UtcNow.ToString($timeFormat)

        $jsonPayload = ''
        if ($null -ne $EventFrame.Payload) {
            try { $jsonPayload = $EventFrame.Payload | ConvertTo-Json -Depth 10 -Compress -ErrorAction Stop }
            catch { $jsonPayload = '{"error":"serialization_failed"}' }
        }

        $algo = "SHA256"
        if ($null -ne $Script:C.AUDIT["HASH_ALGO"]) { $algo = $Script:C.AUDIT["HASH_ALGO"] }

        $chainInput = '' -f $Script:LastHash, $timestamp, $EventFrame.Type, $operator, $jsonPayload
        $currentHash = _ComputeHash -RawData $chainInput -Algo $algo

        $Script:SequenceId++
        $record = [PSCustomObject]@{
            SequenceId   = '' -f $Script:SequenceId
            Timestamp    = $timestamp
            EventType    = $EventFrame.Type
            Severity     = if ($null -ne $EventFrame.Severity) { $EventFrame.Severity } else { "LOG_INFO" }
            Operator     = $operator
            PreviousHash = $Script:LastHash
            Integrity    = '' -f $algo, $currentHash
            Details      = $jsonPayload
        }

        $Script:LastHash = $currentHash
        return $record
    }
    return $null
}

function _ComputeHash {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory=$true)][string]$RawData, [string]$Algo = "SHA256")
    try {
        $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($Algo)
        if ($null -eq $hasher) { $hasher = [System.Security.Cryptography.SHA256]::Create() }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($RawData)
        $hashBytes = $hasher.ComputeHash($bytes)
        $hasher.Dispose()
        return [System.BitConverter]::ToString($hashBytes) -replace '-'
    } catch {
        return $RawData.GetHashCode().ToString("X8")
    }
}

function _FormatLogLine {
    [CmdletBinding()] [OutputType([string])]
    param([PSCustomObject]$Record)
    return "[{0}] [{1}] {2} | {3} | {4} | {5}" -f $Record.Timestamp, $Record.Severity, $Record.SequenceId, $Record.EventType, $Record.Operator, $Record.Integrity
}