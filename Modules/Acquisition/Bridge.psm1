<#.SYNOPSIS
    Domain: Acquisition
    Module: Scape.Acquisition.Bridge
    Description: P/Invoke wrapper for kernel32.dll. Obtains raw handles for DASD (Direct Access Storage Device).
#>

$Script:C = $null
$Script:BridgeReady = $false

function Initialize-ScapeBridge {
    if ($Script:BridgeReady) { return }

    $Script:C = @{
        CORE = Get-ScapeConstant -Path "core::Global" -Fallback @{}
    }

    $csharpInterop = @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public static class ScapeWin32 {
    public const uint GENERIC_READ = 0x80000000;
    public const uint FILE_SHARE_READ = 0x00000001;
    public const uint FILE_SHARE_WRITE = 0x00000002;
    public const uint OPEN_EXISTING = 3;
    public const uint FILE_ATTRIBUTE_NORMAL = 0x80;
    public const uint FILE_FLAG_BACKUP_SEMANTICS = 0x02000000;

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern SafeFileHandle CreateFile(
        string lpFileName,
        uint dwDesiredAccess,
        uint dwShareMode,
        IntPtr lpSecurityAttributes,
        uint dwCreationDisposition,
        uint dwFlagsAndAttributes,
        IntPtr hTemplateFile);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool ReadFile(
        SafeFileHandle hFile,
        byte[] lpBuffer,
        uint nNumberOfBytesToRead,
        out uint lpNumberOfBytesRead,
        IntPtr lpOverlapped);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetFilePointerEx(
        SafeFileHandle hFile,
        long liDistanceToMove,
        out long lpNewFilePointer,
        uint dwMoveMethod);
}
"@
    # Compila a classe estática no AppDomain do PowerShell
    if (-not ([System.Management.Automation.PSTypeName]"ScapeWin32").Type) {
        Add-Type -TypeDefinition $csharpInterop
    }

    $Script:BridgeReady = $true
    Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "BRIDGE_INIT_OK"; Severity = "LOG_INFO" }
}

function Open-ScapeRawHandle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DevicePath  # Ex: "\\.\PhysicalDrive0" ou "\\.\C:"
    )

    if (-not $Script:BridgeReady) { Initialize-ScapeBridge }

    $handle = [ScapeWin32]::CreateFile(
        $DevicePath,
        [ScapeWin32]::GENERIC_READ,
        ([ScapeWin32]::FILE_SHARE_READ -bor [ScapeWin32]::FILE_SHARE_WRITE),
        [IntPtr]::Zero,
        [ScapeWin32]::OPEN_EXISTING,
        ([ScapeWin32]::FILE_ATTRIBUTE_NORMAL -bor [ScapeWin32]::FILE_FLAG_BACKUP_SEMANTICS),
        [IntPtr]::Zero
    )

    if ($handle.IsInvalid) {
        $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "RAW_HANDLE_DENIED: Error Code $err for $DevicePath. Are you running as Admin?"
    }

    return $handle
}

function Close-ScapeRawHandle {
    param([Microsoft.Win32.SafeHandles.SafeFileHandle]$Handle)
    if ($null -ne $Handle -and -not $Handle.IsInvalid -and -not $Handle.IsClosed) {
        $Handle.Close()
        $Handle.Dispose()
    }
}