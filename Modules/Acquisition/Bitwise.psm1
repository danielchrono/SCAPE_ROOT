<#
.SYNOPSIS
    Domain: Acquisition | Module: Scape.Acquisition.Bitwise
    Architecture: Native P/Invoke com suporte a Long Paths (\\?\) e ResiliÃªncia em Lote.
    Capacity: Otimizado para datasets de 20TB+
    Delegates to: Scape.Core.Native.Win32Bitwise (Single Source of Truth)
#>

$Script:BitwiseReady = $false

function Initialize-ScapeBitwise {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    process {
        if ($Script:BitwiseReady) { return $true }

        # Garante que Interop esteja carregado
        if (-not ("Scape.Core.Native.Win32Bitwise" -as [type])) {
            if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) {
                $result = Initialize-ScapeInterop
                if (-not $result.Success) { return $false }
            }
            else {
                $err = if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "CORE_INTEROP_FAIL"  } else { "Core.Interop not available" }
                Publish-ScapeEvent -Type "BITWISE_INIT_FAIL" -Severity "FATAL" -Payload $err
                return $false
            }
        }

        $Script:BitwiseReady = $true
        return $true
    }
}

function Invoke-ScapeBulkBitwise {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string[]]$Paths,
        [Parameter(Mandatory = $true)][bool]$EnableArchiveBit
    )
    begin {
        Initialize-ScapeBitwise | Out-Null
        $report = @{ Success = 0; Failed = 0; Errors = @() }
    }
    process {
        foreach ($path in $Paths) {
            try {
                # NormalizaÃ§Ã£o para Long Paths (\\?\)
                $normalizedPath = if ($path.StartsWith("\\")) { $path } else { "\\?\$path" }

                $currentAttr = [Scape.Core.Native.Win32Bitwise]::GetFileAttributesW($normalizedPath)

                if ($currentAttr -eq [Scape.Core.Native.Win32Bitwise]::INVALID_FILE_ATTRIBUTES) {
                    throw (Get-ScapeLogMsg -Key "ERR_PERMISSION_DENIED")
                }

                $newAttr = if ($EnableArchiveBit) {
                    $currentAttr -bor [Scape.Core.Native.Win32Bitwise]::FILE_ATTRIBUTE_ARCHIVE
                }
                else {
                    $currentAttr -band (-bnot [Scape.Core.Native.Win32Bitwise]::FILE_ATTRIBUTE_ARCHIVE)
                }

                if ([Scape.Core.Native.Win32Bitwise]::SetFileAttributesW($normalizedPath, $newAttr)) {
                    $report.Success++
                }
                else {
                    throw (Get-ScapeLogMsg -Key "SETTINGS_IO_FAULT" -MsgArgs @($normalizedPath))
                }
            }
            catch {
                $report.Failed++
                $report.Errors += @{ Path = $path; Message = $_.Exception.Message }
                Publish-ScapeEvent -Type "IO_BIT_ERROR" -Severity "LOG_ERROR" -Payload @{ Path = $path; Error = $_.Exception.Message }
            }
        }
    }
    end {
        return $report
    }
}

Export-ModuleMember -Function 'Invoke-ScapeBulkBitwise'
