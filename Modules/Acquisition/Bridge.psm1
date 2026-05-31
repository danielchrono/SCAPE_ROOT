<#
.SYNOPSIS
    Domain: Acquisition
    Module: Scape.Acquisition.Bridge
    Description: P/Invoke wrapper for kernel32.dll. Obtains raw handles for DASD (Direct Access Storage Device).
    Architecture: Delegates to Scape.Core.Native.Win32DiskBridge (Single Source of Truth)
#>

$Script:C = $null
$Script:BridgeReady = $false

function Initialize-ScapeBridge {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    process {
        if ($Script:BridgeReady) { return $true }

        # Garante que Interop esteja carregado (fail-fast se nÃ£o)
        if (-not ("Scape.Core.Native.Win32DiskBridge" -as [type])) {
            if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) {
                $result = Initialize-ScapeInterop
                if (-not $result.Success) { return $false }
            }
            else {
                $err = if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "CORE_INTEROP_FAIL"  } else { "Core.Interop not available" }
                Publish-ScapeEvent -Type "BRIDGE_INIT_FAIL" -Severity "FATAL" -Payload $err
                return $false
            }
        }

        $Script:C = @{
            CORE = Get-ScapeConstant -Path "core::Global" -Fallback @{}
        }

        $Script:BridgeReady = $true
        Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "BRIDGE_INIT_OK"; Severity = "LOG_INFO" }
        return $true
    }
}

function Open-ScapeRawHandle {
    [CmdletBinding()]
    [OutputType([Microsoft.Win32.SafeHandles.SafeFileHandle])]
    param(
        [Parameter(Mandatory = $true)][string]$DevicePath
    )
    process {
        if (-not $Script:BridgeReady) { Initialize-ScapeBridge | Out-Null }

        $handle = [Scape.Core.Native.Win32DiskBridge]::CreateFile(
            $DevicePath,
            [Scape.Core.Native.Win32DiskBridge]::GENERIC_READ,
            ([Scape.Core.Native.Win32DiskBridge]::FILE_SHARE_READ -bor [Scape.Core.Native.Win32DiskBridge]::FILE_SHARE_WRITE),
            [IntPtr]::Zero,
            [Scape.Core.Native.Win32DiskBridge]::OPEN_EXISTING,
            ([Scape.Core.Native.Win32DiskBridge]::FILE_ATTRIBUTE_NORMAL -bor [Scape.Core.Native.Win32DiskBridge]::FILE_FLAG_BACKUP_SEMANTICS),
            [IntPtr]::Zero
        )

        if ($handle.IsInvalid) {
            $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            $errMsg = Get-ScapeLogMsg -Key "IO_CREATEFILE_FAIL" -MsgArgs @($err)
            Publish-ScapeEvent -Type "RAW_HANDLE_DENIED" -Severity "ERROR" -Payload @{
                DevicePath = $DevicePath
                Win32Error = $err
                Message    = $errMsg
            }
            throw $errMsg
        }

        return $handle
    }
}

function Close-ScapeRawHandle {
    [CmdletBinding()]
    [OutputType([void])]
    param([Microsoft.Win32.SafeHandles.SafeFileHandle]$Handle)
    process {
        if ($null -ne $Handle -and -not $Handle.IsInvalid -and -not $Handle.IsClosed) {
            $Handle.Close()
            $Handle.Dispose()
        }
    }
}
