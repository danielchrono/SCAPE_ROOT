<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Signature
    Description: JIT Compiler and high-performance search index for carving signatures.
#>

$Script:SignatureIndex = $null
$Script:MaxHeaderLength = 0


function Find-ScapeSignatureAtOffset {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)] [byte[]]$SectorBuffer,
        [Parameter(Mandatory = $true)] [int]$Offset
    )

    if ($null -eq $Script:SignatureIndex) { throw "SIGNATURE_ENGINE_NOT_INITIALIZED" }
    if ($Offset -ge $SectorBuffer.Length) { return $null }

    $firstByte = $SectorBuffer[$Offset]

    if (-not $Script:SignatureIndex.ContainsKey($firstByte)) { return $null }

    $candidates = $Script:SignatureIndex[$firstByte]

    foreach ($sig in $candidates) {
        $hLen = $sig.HeaderBytes.Length
        if (($Offset + $sig.HeaderOffset + $hLen) -gt $SectorBuffer.Length) { continue }

        $isMatch = $true
        $targetStart = $Offset + $sig.HeaderOffset

        for ($i = 1; $i -lt $hLen; $i++) {
            if ($SectorBuffer[$targetStart + $i] -ne $sig.HeaderBytes[$i]) {
                $isMatch = $false
                break
            }
        }

        if (-not $isMatch) { continue }

        if ($null -ne $sig.ValidationBytes -and $sig.ValidationBytes.Length -gt 0) {
            $vLen = $sig.ValidationBytes.Length
            $vStart = $targetStart + $sig.ValidationOffset
            if (($vStart + $vLen) -gt $SectorBuffer.Length) { continue }

            for ($v = 0; $v -lt $vLen; $v++) {
                if ($SectorBuffer[$vStart + $v] -ne $sig.ValidationBytes[$v]) {
                    $isMatch = $false
                    break
                }
            }
        }

        if ($isMatch) { return $sig }
    }
    return $null
}

Export-ModuleMember -Function 'Find-ScapeSignatureAtOffset'
