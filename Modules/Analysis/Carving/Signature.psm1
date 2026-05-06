<#
.SYNOPSIS
    Domain: Analysis
    Module: Scape.Analysis.Signature
    Description: JIT Compiler and high-performance search index for carving signatures.
#>

$Script:SignatureIndex = $null
$Script:MaxHeaderLength = 0

function Initialize-ScapeSignatureEngine {
    [CmdletBinding()]
    [OutputType([void])]
    param()

    Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "CARVING_ENGINE_INIT" }

    $state = Get-ScapeColdState
    if (-not $state["SYS_ASSETS_DIR"].ContainsKey("carving")) {
        throw "CARVING_ASSETS_NOT_LOADED"
    }

    $rawDefs = $state["SYS_ASSETS_DIR"]["carving"]["SIGNATURES"]
    $index = [System.Collections.Generic.Dictionary[byte, System.Collections.Generic.List[PSCustomObject]]]::new()
    $localMax = 0

    foreach ($key in $rawDefs.Keys) {
        $def = $rawDefs[$key]

        $headerBytes = Convert-ScapeHexToByte -Hex $def.Header

        if ($null -eq $headerBytes -or $headerBytes.Length -eq 0) { continue }

        $firstByte = $headerBytes[0]
        if (-not $index.ContainsKey($firstByte)) {
            $index[$firstByte] = [System.Collections.Generic.List[PSCustomObject]]::new()
        }

        if ($headerBytes.Length -gt $localMax) { $localMax = $headerBytes.Length }

        $compiledSig = [PSCustomObject]@{
            Id               = $key
            Category         = $def.Category
            Extension        = $def.Extension
            HeaderBytes      = $headerBytes
            HeaderOffset     = [int]$def.HeaderOffset
            FooterBytes      = Convert-ScapeHexToByte -Hex $def.Footer
            ValidationBytes  = Convert-ScapeHexToByte -Hex $def.ValidationBytes
            ValidationOffset = if ($null -ne $def.ValidationOffset) { [int]$def.ValidationOffset } else { 0 }
            MaxSize          = [long]$def.MaxSize
            RequireExact     = [bool]$def.RequireExact
        }

        $index[$firstByte].Add($compiledSig)
    }

    $Script:SignatureIndex = $index
    $Script:MaxHeaderLength = $localMax

    Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Message = "Carving Engine: Compiled $($rawDefs.Count) signatures. Max depth: $localMax bytes." }
}

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