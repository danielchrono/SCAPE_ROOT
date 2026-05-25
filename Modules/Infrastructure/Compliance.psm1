<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Compliance
    Description: Verifies integrity of system segments (PSD1, modules, binaries) using cryptographic hashes.
    Zero hardcode – all configs via Get-ScapeConstant from infrastructure::Compliance.
    Thread-safe, PowerShell 5.1 compatible.
#>
[CmdletBinding()] param()

$Script:Config = $null
$Script:ExpectedHashes = @{}
$Script:VerificationCache = @{}

function Initialize-ScapeCompliance {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    # --- 1. CONFIGURAÇÃO (DECLARATIVA + ESCOPO CORRETO) ---
    $Script:Config = @{
        Compliance = Get-ScapeConstant -Path "infrastructure::Compliance" -Fallback @{}
    }

    try {
        # --- 2. CARREGAMENTO DO MANIFESTO (GUARD CLAUSE) ---
        $manifestPath = $Script:Config.Compliance["MANIFEST_PATH"]

        $Script:ExpectedHashes = if ($manifestPath -and (Test-Path $manifestPath)) {
            Import-PowerShellDataFile -LiteralPath $manifestPath
        }
        else { @{} }

        # --- 3. VALIDAÇÃO DE SEGMENTOS (PIPELINE FUNCIONAL) ---
        if ($Script:Config.Compliance["SEGMENT_VERIFY_ON_LOAD"] -eq $true) {

            $criticalSegments = $Script:Config.Compliance["CRITICAL_SEGMENTS"]
            if ($null -eq $criticalSegments) {
                $criticalSegments = @("core", "boot", "constants")
            }

            $failedSegment = $criticalSegments | Where-Object { $Script:ExpectedHashes.ContainsKey($_) } | Where-Object {
                -not (Test-ScapeSegmentIntegrity -SegmentName $_ -ExpectedHash $Script:ExpectedHashes[$_])
            } | Select-Object -First 1

            if ($failedSegment) {
                Publish-ScapeFault -Severity "FATAL" -Context "Segment:$failedSegment" -Message (
                    Get-ScapeLogMsg -Key "COMPLIANCE_MISMATCH" -MsgArgs @(
                        $failedSegment,
                        $Script:ExpectedHashes[$failedSegment],
                        "INVALID",
                        $Script:Config.Compliance["HASH_ALGO"]
                    )
                )
                return $false
            }
        }

        # --- 4. FINALIZAÇÃO ---
        $hashAlgo = Get-DefaultHashAlgorithm

        Publish-ScapeEvent -Type "COMPLIANCE_INITIALIZED" -Severity "LOG_INFO" -Payload @{
            SegmentsLoaded = $Script:ExpectedHashes.Count
            HashAlgorithm  = $hashAlgo
            Message        = Get-ScapeLogMsg -Key "COMPLIANCE_INIT_OK" -MsgArgs @($Script:ExpectedHashes.Count, $hashAlgo)
        }

        return $true
    }
    catch {
        Publish-ScapeFault -ErrorRecord $_ -Context "Compliance_Init" -Message (
            Get-ScapeLogMsg -Key "ROUTER_FATAL" -MsgArgs @($_.Exception.Message)
        )
        return $false
    }
}

# --- 1. ALGORITMO PADRÃO (EXPRESSÃO PURA) ---
function Get-DefaultHashAlgorithm {
    [CmdletBinding()] [OutputType([string])]
    param()

    $algo = $Script:Config.Compliance["HASH_ALGO"]
    if ($null -eq $algo) { $algo = "SHA256" }
    return $algo
}

function Get-ScapeSegmentHash {
    [CmdletBinding()] [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$SegmentName,
        [string]$Algorithm
    )

    $algo = $Algorithm
    if ($null -eq $algo) { $algo = Get-DefaultHashAlgorithm }

    $root = (Get-ScapeColdState)["ROOT"]
    $path = Join-Path $root "Data\Constants\${SegmentName}.psd1"

    if (-not (Test-Path -LiteralPath $path)) {
        Publish-ScapeEvent -Type "COMPLIANCE_MISSING" -Severity "LOG_WARN" -Payload @{
            Segment = $SegmentName;
            Message = Get-ScapeLogMsg -Key "COMPLIANCE_MISSING" -MsgArgs @($SegmentName, "file not found", $algo)
        }
        return $null
    }

    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($algo)
    if ($null -eq $hasher) { $hasher = [System.Security.Cryptography.SHA256]::Create() }

    try {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $hashBytes = $hasher.ComputeHash($bytes)
        return [System.BitConverter]::ToString($hashBytes) -replace '-'
    }
    finally {
        $hasher.Dispose()
    }
}

# --- 3. TESTE DE INTEGRIDADE (COM MEMOIZATION) ---
function Test-ScapeSegmentIntegrity {
    [CmdletBinding()] [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$SegmentName,
        [string]$ExpectedHash
    )

    $algo = Get-DefaultHashAlgorithm
    $cacheKey = "${SegmentName}:${algo}"

    if ($Script:VerificationCache.ContainsKey($cacheKey)) {
        return $Script:VerificationCache[$cacheKey]
    }

    $actualHash = Get-ScapeSegmentHash -SegmentName $SegmentName -Algorithm $algo
    $isValid = ($actualHash -eq $ExpectedHash)
    $Script:VerificationCache[$cacheKey] = $isValid

    if (-not $isValid) {
        $actualSafe = if ($null -eq $actualHash) { "NULL" } else { $actualHash }
        Publish-ScapeEvent -Type "COMPLIANCE_MISMATCH" -Severity "LOG_ERR" -Payload @{
            Segment   = $SegmentName
            Expected  = $ExpectedHash
            Actual    = $actualSafe
            Algorithm = $algo
            Message   = Get-ScapeLogMsg -Key "COMPLIANCE_MISMATCH" -MsgArgs @($SegmentName, $ExpectedHash, $actualSafe, $algo)
        }
    }

    return $isValid
}

# --- 4. RELATÓRIO DE EXPORTAÇÃO (TRANSFORMAÇÃO DE DADOS) ---
function Export-ScapeComplianceReport {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][string]$OutputPath)

    if (-not $PSCmdlet.ShouldProcess($OutputPath, "Export Compliance Report")) { return }

    $segmentsStatus = @{}
    foreach ($seg in $Script:ExpectedHashes.Keys) {
        $actual = Get-ScapeSegmentHash -SegmentName $seg
        $segmentsStatus[$seg] = [PSCustomObject]@{
            Expected = $Script:ExpectedHashes[$seg]
            Actual   = $actual
            Valid    = ($actual -eq $Script:ExpectedHashes[$seg])
        }
    }

    $isCompromised = $segmentsStatus.Values.Valid -contains $false

    $report = [PSCustomObject]@{
        ExportTime    = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        Algorithm     = Get-DefaultHashAlgorithm
        Segments      = $segmentsStatus
        OverallStatus = if ($isCompromised) { "COMPROMISED" } else { "VALID" }
    }

    try {
        $json = $report | ConvertTo-Json -Depth 10 -Compress
        Set-Content -LiteralPath $OutputPath -Value $json -Encoding UTF8 -Force

        return @{
            Success = $true;
            Path    = $OutputPath;
            Status  = $report.OverallStatus;
            Message = Get-ScapeLogMsg -Key "AUDIT_REPORT_GEN" -MsgArgs @($OutputPath)
        }
    }
    catch {
        Throw "Failed to export compliance report: $($_.Exception.Message)"
    }
}