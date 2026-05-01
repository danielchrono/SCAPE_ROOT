<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Compliance
    Architecture: Cryptographic Chain of Custody (Ledger) manager.
#>

$Script:LastHash = $null
$Script:AuditLedger = [System.Collections.Generic.List[object]]::new()

function Initialize-ScapeCompliance {
    [CmdletBinding()]
    param()

    Get-ScapeGenesisHash | Out-Null

    if (Get-Command "Register-ScapeEventListener" -ErrorAction SilentlyContinue) {
        Register-ScapeEventListener -EventMatch "*" -Action {
            param([object]$EventFrame)
            if ($EventFrame.Type -notin @("TRACE", "LOG_DEBUG", "METRIC_SAMPLE", "TELEMETRY_HEARTBEAT")) {
                Add-ScapeComplianceRecord -EventFrame $EventFrame | Out-Null
            }
        }
    }
    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "COMPLIANCE_SHIELD_ACTIVE"; Severity = "LOG_INFO" }
    }
}

function Get-ScapeGenesisHash {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($null -eq $Script:LastHash) {
        $Script:LastHash = Get-ScapeConstant -Path "compliance::AUDIT::GENESIS_BLOCK" -Fallback "SCAPE_GENESIS_BLOCK_v1.0"
    }
    return $Script:LastHash
}

function Add-ScapeComplianceRecord {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][object]$EventFrame,
        [string]$OperatorId = ""
    )

    $OperatorId = if ([string]::IsNullOrWhiteSpace($OperatorId)) { Get-ScapeConstant -Path "compliance::AUDIT::DEFAULT_OPERATOR" -Fallback "SYS_CORE" } else { $OperatorId }
    $timeFormat = Get-ScapeConstant -Path "core::COMPLIANCE::TIME_FORMAT" -Fallback "yyyy-MM-ddTHH:mm:ss.fffZ"
    $timestamp = [datetime]::UtcNow.ToString($timeFormat)

    $jsonPayload = if ($null -ne $EventFrame.Payload) {
        try { $EventFrame.Payload | ConvertTo-Json -Depth 5 -Compress -ErrorAction Stop } catch { "{}" }
    }
    else { "{}" }

    $lastHash = Get-ScapeGenesisHash
    $signatureStr = "{0}|{1}|{2}|{3}|{4}" -f $lastHash, $timestamp, $EventFrame.Type, $OperatorId, $jsonPayload
    $algoName = Get-ScapeConstant -Path "compliance::AUDIT::HASH_ALGO" -Fallback "SHA256"

    $hasher = $null
    try {
        $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($algoName)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($signatureStr)
        $currHash = ([System.BitConverter]::ToString($hasher.ComputeHash($bytes)) -replace '-')

        $record = [PSCustomObject]@{
            SequenceId   = [guid]::NewGuid().ToString()
            Timestamp    = $timestamp
            Action       = $EventFrame.Type
            Operator     = $OperatorId
            PreviousHash = $lastHash
            Integrity    = "{0}:{1}" -f $algoName, $currHash
            Details      = $jsonPayload
        }

        $Script:LastHash = $currHash
        $Script:AuditLedger.Add($record)
        return $record
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Compliance_Hash" }
        return $null
    }
    finally {
        if ($null -ne $hasher) { $hasher.Dispose() }
    }
}

function Export-ScapeComplianceLedger {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][string]$OutputPath)

    if ($PSCmdlet.ShouldProcess($OutputPath, "Export Compliance Ledger")) {
        try {
            $engineVersion = Get-ScapeConstant -Path "core::META::ENGINE_VERSION" -Fallback "SCAPE_v1.0.0"
            $closingTs = [datetime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

            $report = [PSCustomObject]@{
                SessionId       = (Get-ScapeColdState)["DATA_SESSION_ID"]
                EngineVersion   = $engineVersion
                ExportTimestamp = $closingTs
                TotalRecords    = $Script:AuditLedger.Count
                ClosingHash     = $Script:LastHash
                Ledger          = $Script:AuditLedger.ToArray()
            }

            $jsonReport = $report | ConvertTo-Json -Depth 10
            Set-Content -LiteralPath $OutputPath -Value $jsonReport -Encoding UTF8 -Force

            if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                Publish-ScapeEvent -Type "AUDIT_EXPORT_SUCCESS" -Severity "LOG_INFO" -Payload @{ File = $OutputPath; Records = $Script:AuditLedger.Count }
            }
            return @{ Success = $true; Error = $null }
        }
        catch {
            if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Compliance_Export" }
            return @{ Success = $false; Error = $_.Exception.Message }
        }
    }
}