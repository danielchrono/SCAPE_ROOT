<#
.SYNOPSIS
    Domain: Foundation
    Module: Scape.Core.Interop
    Architecture: Bare-metal P/Invoke signatures
#>

# O bloco abaixo deve começar exatamente na linha seguinte ao @", sem espaços.
$Script:InteropSignature = @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

namespace Scape.Core.Native
{
    public static class Win32DiskBridge
    {
        [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
        public static extern SafeFileHandle CreateFile(
            string lpFileName,
            uint dwDesiredAccess,
            uint dwShareMode,
            IntPtr lpSecurityAttributes,
            uint dwCreationDisposition,
            uint dwFlagsAndAttributes,
            IntPtr hTemplateFile
        );

        [DllImport("kernel32.dll", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool ReadFile(
            SafeFileHandle hFile,
            byte[] lpBuffer,
            uint nNumberOfBytesToRead,
            out uint lpNumberOfBytesRead,
            IntPtr lpOverlapped
        );

        [DllImport("kernel32.dll", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetFilePointerEx(
            SafeFileHandle hFile,
            long liDistanceToMove,
            out long lpNewFilePointer,
            uint dwMoveMethod
        );

        [DllImport("advapi32.dll", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool OpenProcessToken(
            IntPtr ProcessHandle,
            uint DesiredAccess,
            out IntPtr TokenHandle
        );

        [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool LookupPrivilegeValue(
            string lpSystemName,
            string lpName,
            out LUID lpLuid
        );

        [DllImport("advapi32.dll", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool AdjustTokenPrivileges(
            IntPtr TokenHandle,
            [MarshalAs(UnmanagedType.Bool)] bool DisableAllPrivileges,
            ref TOKEN_PRIVILEGES NewState,
            uint BufferLength,
            IntPtr PreviousState,
            IntPtr ReturnLength
        );

        [DllImport("kernel32.dll")]
        public static extern IntPtr GetCurrentProcess();

        [StructLayout(LayoutKind.Sequential)]
        public struct LUID { public uint LowPart; public int HighPart; }

        [StructLayout(LayoutKind.Sequential, Pack=1)]
        public struct TOKEN_PRIVILEGES
        {
            public uint PrivilegeCount;
            public LUID Luid;
            public uint Attributes;
        }
    }
}
"@

function Initialize-ScapeInterop {
    if (-not ("Scape.Core.Native.Win32DiskBridge" -as [type])) {
        try {
            Add-Type -TypeDefinition $Script:InteropSignature -Language CSharp -ErrorAction Stop
        } catch {
            Write-Error "Failed to load Win32 Interop: $_"
            return @{ Success = $false; Data = $null; Error = $_ }
        }
    }
    return @{ Success = $true; Data = "Interop.Ready"; Error = $null }
}