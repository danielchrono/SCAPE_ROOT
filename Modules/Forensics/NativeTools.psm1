<#
.SYNOPSIS
    Domain: Forensics | Module: Scape.Forensics.NativeTools
    Architecture: Specialized Native Forensics Handler
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.DiskPart' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("DISKPART")) -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "diskpart.exe" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "DiskpartScreen"
            TitleKey = "TOOL_DISKPART"
            Rows     = @(
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("Diskpart")); Flag = "Success"; RightFlag = "Success" }
                @{ LeftText = "ExitCode"; RightText = "$($proc.ExitCode)"; Flag = "Success"; RightFlag = "Info" }
            )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "DiskpartScreen"
            TitleKey = "TOOL_DISKPART"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("Diskpart")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("DISKPART")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Chkdsk' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("CHKDSK")) -StatusFlag "WARN"
    try {
        # Needs parameters normally, but we launch interactive cmd for now
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/k chkdsk.exe" -Wait -PassThru -ErrorAction Stop
        [void]$proc
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "ChkdskScreen"
            TitleKey = "TOOL_CHKDSK"
            Rows     = @(
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("Chkdsk")); Flag = "Success"; RightFlag = "Success" }
            )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "ChkdskScreen"
            TitleKey = "TOOL_CHKDSK"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("Chkdsk")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("CHKDSK")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.WinFR' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("WINFR")) -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "winfr.exe" -Wait -PassThru -ErrorAction Stop
        [void]$proc
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "WinFRScreen"
            TitleKey = "TOOL_WINFR"
            Rows     = @(
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("WinFR")); Flag = "Success"; RightFlag = "Success" }
            )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "WinFRScreen"
            TitleKey = "TOOL_WINFR"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("WinFR")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("WINFR")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Fsutil' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("FSUTIL")) -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/k fsutil.exe dirty query C:" -Wait -PassThru -ErrorAction Stop
        [void]$proc
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "FsutilScreen"
            TitleKey = "TOOL_FSUTIL"
            Rows     = @(
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("Fsutil")); Flag = "Success"; RightFlag = "Success" }
            )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "FsutilScreen"
            TitleKey = "TOOL_FSUTIL"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("Fsutil")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("FSUTIL")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Sfc' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("SFC")) -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -PassThru -ErrorAction Stop
        [void]$proc
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "SfcScreen"
            TitleKey = "TOOL_SFC"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("SFC")); Flag = "Success"; RightFlag = "Success" } )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "SfcScreen"
            TitleKey = "TOOL_SFC"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("SFC")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("SFC")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Dism' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("DISM")) -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -ErrorAction Stop
        [void]$proc
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "DismScreen"
            TitleKey = "TOOL_DISM"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("DISM")); Flag = "Success"; RightFlag = "Success" } )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "DismScreen"
            TitleKey = "TOOL_DISM"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("DISM")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("DISM")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.EventVwr' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("EVENT VIEWER")) -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "eventvwr.exe" -PassThru -ErrorAction Stop
        [void]$proc
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "EventVwrScreen"
            TitleKey = "TOOL_EVENTVWR"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @("Event Viewer")); Flag = "Success"; RightFlag = "Success" } )
        }
    }
    catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "EventVwrScreen"
            TitleKey = "TOOL_EVENTVWR"
            Rows     = @( @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @("Event Viewer")) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("EVENT VIEWER")) -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.FileHash' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$PayloadDef
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @("FILEHASH")) -StatusFlag "WARN"
    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
        ScreenId = "HashScreen"
        TitleKey = "TOOL_FILEHASH"
        Rows     = @( @{ LeftText = "Get-FileHash"; RightText = (Invoke-ScapeI18NFormat -Key "ACTION_FILEHASH_WARN"); Flag = "Warning"; RightFlag = "Warning" } )
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @("FILEHASH")) -StatusFlag "Success"
}

# Registration-only module: handlers are registered via Register-ScapeActionHandler at load time.
# No public functions to export directly.
Export-ModuleMember -Function @()
