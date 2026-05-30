<#
.SYNOPSIS
    Domain: Foundation
    Module: Scape.Core.Security
    Description: Parameterized Privilege Escalator. Fetches API access flags and strings
                 exclusively via Data Contracts (Get-ScapeConstant).
#>

function Enable-ScapePrivilege {
    param([Parameter(Mandatory = $true)][string]$PrivilegeKey)

    $privilegeName = Get-ScapeConstant -Path "core::SECURITY::$PrivilegeKey"
    if (-not $privilegeName) {
        Publish-ScapeEvent -Type "SECURITY_FAULT" -Severity "LOG_ERR" -Payload "Undefined PrivilegeKey: $PrivilegeKey"
        return $false
    }

    $tokenAdj = Get-ScapeConstant -Path "core::SECURITY::TOKEN_ADJUST_PRIVILEGES" -Fallback 0x0020
    $tokenQry = Get-ScapeConstant -Path "core::SECURITY::TOKEN_QUERY" -Fallback 0x0008
    $access = $tokenAdj -bor $tokenQry

    $token = [IntPtr]::Zero
    $process = [Scape.Core.Native.Win32Security]::GetCurrentProcess()

    if (-not [Scape.Core.Native.Win32Security]::OpenProcessToken($process, $access, [ref]$token)) {
        return $false
    }

    $luid = New-Object Scape.Core.Native.Win32Security+LUID
    if (-not [Scape.Core.Native.Win32Security]::LookupPrivilegeValue($null, $privilegeName, [ref]$luid)) {
        return $false
    }

    $tp = New-Object Scape.Core.Native.Win32Security+TOKEN_PRIVILEGES
    $tp.PrivilegeCount = 1
    $tp.Luid = $luid
    $tp.Attributes = Get-ScapeConstant -Path "core::SECURITY::SE_PRIVILEGE_ENABLED" -Fallback 0x00000002

    $res = [Scape.Core.Native.Win32Security]::AdjustTokenPrivileges($token, $false, [ref]$tp, 0, [IntPtr]::Zero, [IntPtr]::Zero)

    if ($res) {
        Publish-ScapeEvent -Type "SECURITY_ELEVATED" -Severity "LOG_INFO" -Payload $privilegeName
    }
    else {
        Publish-ScapeEvent -Type "SECURITY_FAULT" -Severity "LOG_ERR" -Payload "AdjustTokenPrivileges failed for $privilegeName"
    }
    return $res
}