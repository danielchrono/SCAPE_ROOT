<#
.SYNOPSIS
    Domain: Acquisition | Module: Scape.Acquisition.HighVolume
    Architecture: Native P/Invoke com suporte a Long Paths (\\?\) e Resiliência em Lote.
    Capacity: Otimizado para datasets de 20TB+
#>

$Script:BitwiseReady = $false

function Initialize-ScapeBitwise {
    if ($Script:BitwiseReady) { return }
    if (-not ("Scape.Core.Native.Win32Bitwise" -as [type])) {
        $csharpInterop = @"
using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace Scape.Core.Native {
    public static class Win32Bitwise {
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool SetFileAttributesW(string lpFileName, uint dwFileAttributes);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern uint GetFileAttributesW(string lpFileName);

        public const uint FILE_ATTRIBUTE_ARCHIVE = 0x20;
        public const uint INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF;
    }
}
"@
        Add-Type -TypeDefinition $csharpInterop -Language CSharp -ErrorAction Stop
    }
    $Script:BitwiseReady = $true
}

function Invoke-ScapeBulkBitwise {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Paths,
        [Parameter(Mandatory = $true)]
        [bool]$EnableArchiveBit
    )

    begin {
        Initialize-ScapeBitwise
        $report = @{ Success = 0; Failed = 0; Errors = @() }
    }

    process {
        foreach ($path in $Paths) {
            try {
                # Normalização para Long Paths (\\?\) para evitar erros de 260 caracteres
                $normalizedPath = if ($path.StartsWith("\\")) { $path } else { "\\?\$path" }

                $currentAttr = [Scape.Core.Native.Win32Bitwise]::GetFileAttributesW($normalizedPath)

                if ($currentAttr -eq [Scape.Core.Native.Win32Bitwise]::INVALID_FILE_ATTRIBUTES) {
                    throw "Atributos inválidos ou acesso negado."
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
                    throw "Falha ao gravar atributos via Kernel32."
                }
            }
            catch {
                $report.Failed++
                $report.Errors += @{ Path = $path; Message = $_.Exception.Message }

                if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                    Publish-ScapeEvent -Type "IO_BIT_ERROR" -Severity "LOG_ERROR" -Payload @{ Path = $path; Error = $_.Exception.Message }
                }
            }
        }
    }

    end {
        return $report
    }
}