<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Carving.Healer
    Description: Post-carving repair engine: fixes truncated headers, reconstructs footers, stitches fragments, validates integrity.
    Architecture: FP Strict | Zero Hardcode | Heuristic-Driven | Event-Pipeline Ready
#>

$Script:Stats = @{ Repaired = 0; Stitched = 0; Validated = 0; Failed = 0 }


function Repair-ScapeCarvedHeader {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Data,
        [Parameter(Mandatory = $true)][string]$SignatureId
    )

    $sig = (Get-ScapeConstant -Path "storage::SIGNATURES")[$SignatureId]
    if (-not $sig) { return @{ Success = $false; Reason = "SIGNATURE_NOT_FOUND" } }

    $expected = Convert-ScapeHexToByte -Hex $sig.Header
    if ($null -eq $expected -or $expected.Length -eq 0) {
        return @{ Success = $false; Reason = "INVALID_HEADER_DEF" }
    }

    $actualLen = [Math]::Min($Data.Length, $expected.Length)
    $matchCount = 0
    for ($i = 0; $i -lt $actualLen; $i++) {
        if ($Data[$i] -eq $expected[$i]) { $matchCount++ }
    }

    $confidence = $matchCount / $expected.Length

    if ($confidence -ge 0.8) {
        $repaired = $expected.Clone()
        if ($Data.Length -gt $expected.Length) {
            $tail = $Data[$expected.Length..($Data.Length - 1)]
            $repaired += $tail
        }
        $Script:Stats.Repaired++
        return @{ Success = $true; Data = $repaired; Confidence = $confidence; Reason = "HEADER_REPAIRED" }
    }

    return @{ Success = $false; Confidence = $confidence; Reason = "LOW_CONFIDENCE" }
}

function Repair-ScapeTruncatedFooter {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Data,
        [Parameter(Mandatory = $true)][string]$SignatureId,
        [Parameter()][long]$ExpectedSize = 0
    )

    $sig = (Get-ScapeConstant -Path "storage::SIGNATURES")[$SignatureId]
    if (-not $sig -or -not $sig.Footer) {
        return @{ Success = $false; Reason = "NO_FOOTER_DEF" }
    }

    $expectedFooter = Convert-ScapeHexToByte -Hex $sig.Footer
    if ($null -eq $expectedFooter) {
        return @{ Success = $false; Reason = "INVALID_FOOTER_DEF" }
    }

    # CorreÃ§Ã£o do PSScriptAnalyzer: UtilizaÃ§Ã£o inteligente do ExpectedSize
    if ($ExpectedSize -gt 0 -and $Data.Length -gt $ExpectedSize) {
        $Data = $Data[0..($ExpectedSize - 1)]
    }

    $searchWindow = [Math]::Min((Get-ScapeConstant -Path "system::ANALYSIS::BLOCK_SIZE"), $Data.Length)
    $startIdx = [Math]::Max(0, $Data.Length - $searchWindow)

    for ($i = $startIdx; $i -le ($Data.Length - $expectedFooter.Length); $i++) {
        $match = $true
        for ($j = 0; $j -lt $expectedFooter.Length; $j++) {
            if ($Data[$i + $j] -ne $expectedFooter[$j]) { $match = $false; break }
        }
        if ($match) {
            $repaired = $Data[0..($i + $expectedFooter.Length - 1)]
            $Script:Stats.Repaired++
            return @{ Success = $true; Data = $repaired; Reason = "FOUNDER_FOUND" }
        }
    }

    if ($sig.RequireExact -eq $false -and $sig.Category -in @("Image", "Document", "Archive")) {
        $repaired = $Data + $expectedFooter
        $Script:Stats.Repaired++
        return @{ Success = $true; Data = $repaired; Reason = "SYNTHETIC_FOOTER_APPENDED" }
    }

    return @{ Success = $false; Reason = "FOOTER_NOT_RECOVERABLE" }
}

function Repair-ScapeFragmentedRecord {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][array]$Fragments,
        [Parameter(Mandatory = $true)][string]$SignatureId,
        [Parameter()][int]$MaxGapBytes = 0
    )

    if ($Fragments.Count -lt 2) {
        return @{ Success = $false; Reason = "INSUFFICIENT_FRAGMENTS" }
    }

    $gapThreshold = if ($MaxGapBytes -gt 0) { $MaxGapBytes } else { $Script:C.ENGINE["MAX_ORPHAN_GAP_KB"] * (Get-ScapeConstant -Path "system::ANALYSIS::BYTE_THRESHOLD_1024") }
    $sig = (Get-ScapeConstant -Path "storage::SIGNATURES")[$SignatureId]

    $sorted = $Fragments | Sort-Object { $_.Offset }
    $stitched = [System.Collections.Generic.List[byte]]::new()
    $lastEnd = $null

    foreach ($frag in $sorted) {
        $data = if ($frag.RawRecord) { $frag.RawRecord } else { $frag.Data }
        if ($null -eq $data) { continue }

        if ($null -eq $lastEnd) {
            $stitched.AddRange($data)
            $lastEnd = $frag.Offset + $data.Length
        }
        else {
            $gap = $frag.Offset - $lastEnd
            if ($gap -ge 0 -and $gap -le $gapThreshold) {
                if ($gap -gt 0 -and $sig.Category -in @("Image", "Video")) {
                    $stitched.AddRange((New-Object byte[] $gap))
                }
                $stitched.AddRange($data)
                $lastEnd = $frag.Offset + $data.Length
                $Script:Stats.Stitched++
            }
            else {
                Publish-ScapeEvent -Type "LOG_WARN" -Payload @{ Action = "LogLine"; Key = "HEALER_GAP_TOO_LARGE"; Args = @($SignatureId, $gap, $gapThreshold) }
                break
            }
        }
    }

    if ($stitched.Count -eq 0) { return @{ Success = $false; Reason = "NO_DATA_STITCHED" } }

    return @{ Success = $true; Data = $stitched.ToArray(); FragmentCount = $sorted.Count; Reason = "FRAGMENTS_STITCHED" }
}

function Test-ScapeCarvedIntegrity {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][byte[]]$Data,
        [Parameter(Mandatory = $true)][string]$SignatureId,
        [Parameter()][switch]$StrictMode
    )

    $sig = (Get-ScapeConstant -Path "storage::SIGNATURES")[$SignatureId]
    if (-not $sig) { return @{ Valid = $false; Reason = "SIGNATURE_NOT_FOUND" } }

    if ($sig.Header) {
        $expected = Convert-ScapeHexToByte -Hex $sig.Header
        $actualLen = [Math]::Min($Data.Length, $expected.Length)
        for ($i = 0; $i -lt $actualLen; $i++) {
            if ($Data[$i] -ne $expected[$i]) {
                if ($StrictMode) { return @{ Valid = $false; Reason = "HEADER_MISMATCH" } }
            }
        }
    }

    if ($sig.RequireExact -and $sig.Footer) {
        $expectedFooter = Convert-ScapeHexToByte -Hex $sig.Footer
        $startIdx = [Math]::Max(0, $Data.Length - $expectedFooter.Length)
        $match = $true
        for ($i = 0; $i -lt $expectedFooter.Length; $i++) {
            if ($Data[$startIdx + $i] -ne $expectedFooter[$i]) { $match = $false; break }
        }
        if (-not $match) { return @{ Valid = $false; Reason = "FOOTER_MISSING_STRICT" } }
    }

    if ($Data.Length -gt $sig.MaxSize) { return @{ Valid = $false; Reason = "EXCEEDS_MAX_SIZE" } }

    switch ($sig.Category) {
        "Image" {
            if ($sig.Extension -eq ".jpg" -and $Data.Length -lt (Get-ScapeConstant -Path "system::ANALYSIS::BYTE_THRESHOLD_20")) { return @{ Valid = $false; Reason = "JPEG_TOO_SMALL" } }
        }
        "Archive" {
            if ($sig.Extension -in @(".zip", ".docx", ".xlsx")) {
                $eocdSig = Convert-ScapeHexToByte -Hex "504B0506"
                if ($Data.Length -ge 22) {
                    $found = $false
                    for ($i = 0; $i -le ($Data.Length - 4); $i++) {
                        if ($Data[$i..($i + 3)] -join '' -eq $eocdSig -join '') { $found = $true; break }
                    }
                    if (-not $found -and $StrictMode) { return @{ Valid = $false; Reason = "ZIP_EOCD_NOT_FOUND" } }
                }
            }
        }
    }

    $Script:Stats.Validated++
    return @{ Valid = $true; Reason = "INTEGRITY_OK" }
}

function Invoke-ScapeHealingPipeline {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][PSCustomObject]$Artifact,
        [Parameter()][switch]$EnableStitching,
        [Parameter()][switch]$StrictValidation
    )

    $sigId = $Artifact.SignatureID
    $data = $Artifact.RawRecord

    $headerResult = Repair-ScapeCarvedHeader -Data $data -SignatureId $sigId
    if ($headerResult.Success) { $data = $headerResult.Data }

    $footerResult = Repair-ScapeTruncatedFooter -Data $data -SignatureId $sigId
    if ($footerResult.Success) { $data = $footerResult.Data }

    if ($EnableStitching -and $Artifact.Fragments) {
        $stitchResult = Repair-ScapeFragmentedRecord -Fragments $Artifact.Fragments -SignatureId $sigId
        if ($stitchResult.Success) { $data = $stitchResult.Data }
    }

    $validation = Test-ScapeCarvedIntegrity -Data $data -SignatureId $sigId -StrictMode:$StrictValidation

    Publish-ScapeEvent -Type "HEALING_COMPLETE" -Payload @{
        OriginalOffset = $Artifact.Offset
        SignatureID    = $sigId
        OriginalSize   = $Artifact.RawRecord.Length
        HealedSize     = $data.Length
        Valid          = $validation.Valid
        Reason         = $validation.Reason
        Stats          = $Script:Stats.Clone()
    }

    return @{ Success = $validation.Valid; Data = $data; Stats = $Script:Stats.Clone(); Reason = $validation.Reason }
}

function Get-ScapeHealerStat {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    return $Script:Stats.Clone()
}

function Reset-ScapeHealerStat {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param()
    if ($PSCmdlet.ShouldProcess("HealerStats", "Reset Data")) {
        $Script:Stats = @{ Repaired = 0; Stitched = 0; Validated = 0; Failed = 0 }
    }
}
Export-ModuleMember -Function 'Invoke-ScapeHealingPipeline',
'Reset-ScapeHealerStat',
'Get-ScapeHealerStat'
