<#
.SYNOPSIS
    Domain: Forensics | Module: Scape.Forensics.NativeTools
    Architecture: Specialized Native Forensics Handler
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.DiskPart' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING DISKPART SANDBOX..." -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "diskpart.exe" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "DiskpartScreen"
            TitleKey = "TOOL_DISKPART"
            Rows = @(
                @{ LeftText = "Status"; RightText = "Diskpart executed successfully."; Flag = "Success"; RightFlag = "Success" }
                @{ LeftText = "ExitCode"; RightText = "$($proc.ExitCode)"; Flag = "Success"; RightFlag = "Info" }
            )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "DiskpartScreen"
            TitleKey = "TOOL_DISKPART"
            Rows = @( @{ LeftText = "Error"; RightText = "Failed to launch Diskpart: $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "DISKPART AUDIT COMPLETE" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Chkdsk' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING CHKDSK SANDBOX..." -StatusFlag "WARN"
    try {
        # Needs parameters normally, but we launch interactive cmd for now
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/k chkdsk.exe" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "ChkdskScreen"
            TitleKey = "TOOL_CHKDSK"
            Rows = @(
                @{ LeftText = "Status"; RightText = "Chkdsk executed successfully."; Flag = "Success"; RightFlag = "Success" }
            )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "ChkdskScreen"
            TitleKey = "TOOL_CHKDSK"
            Rows = @( @{ LeftText = "Error"; RightText = "Failed to launch Chkdsk: $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "CHKDSK AUDIT COMPLETE" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.WinFR' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING WINDOWS FILE RECOVERY..." -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "winfr.exe" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "WinFRScreen"
            TitleKey = "TOOL_WINFR"
            Rows = @(
                @{ LeftText = "Status"; RightText = "WinFR executed successfully."; Flag = "Success"; RightFlag = "Success" }
            )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "WinFRScreen"
            TitleKey = "TOOL_WINFR"
            Rows = @( @{ LeftText = "Error"; RightText = "Failed to launch WinFR (is it installed?): $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "WINFR AUDIT COMPLETE" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Fsutil' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING FSUTIL..." -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/k fsutil.exe dirty query C:" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "FsutilScreen"
            TitleKey = "TOOL_FSUTIL"
            Rows = @(
                @{ LeftText = "Status"; RightText = "Fsutil executed successfully."; Flag = "Success"; RightFlag = "Success" }
            )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "FsutilScreen"
            TitleKey = "TOOL_FSUTIL"
            Rows = @( @{ LeftText = "Error"; RightText = "Failed to launch Fsutil: $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "FSUTIL AUDIT COMPLETE" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Sfc' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING SFC..." -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "SfcScreen"
            TitleKey = "TOOL_SFC"
            Rows = @( @{ LeftText = "Status"; RightText = "SFC executed successfully."; Flag = "Success"; RightFlag = "Success" } )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "SfcScreen"
            TitleKey = "TOOL_SFC"
            Rows = @( @{ LeftText = "Error"; RightText = "SFC Error: $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "SFC COMPLETE" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.Dism' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING DISM..." -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "DismScreen"
            TitleKey = "TOOL_DISM"
            Rows = @( @{ LeftText = "Status"; RightText = "DISM executed successfully."; Flag = "Success"; RightFlag = "Success" } )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "DismScreen"
            TitleKey = "TOOL_DISM"
            Rows = @( @{ LeftText = "Error"; RightText = "DISM Error: $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "DISM COMPLETE" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.EventVwr' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "LAUNCHING EVENT VIEWER..." -StatusFlag "WARN"
    try {
        $proc = Start-Process -FilePath "eventvwr.exe" -PassThru -ErrorAction Stop
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "EventVwrScreen"
            TitleKey = "TOOL_EVENTVWR"
            Rows = @( @{ LeftText = "Status"; RightText = "Event Viewer window launched."; Flag = "Success"; RightFlag = "Success" } )
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
            ScreenId = "EventVwrScreen"
            TitleKey = "TOOL_EVENTVWR"
            Rows = @( @{ LeftText = "Error"; RightText = "Event Viewer failed: $($_.Exception.Message)"; Flag = "Failure"; RightFlag = "Failure" } )
        }
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "EVENT VIEWER LAUNCHED" -StatusFlag "Success"
}

Register-ScapeActionHandler -Target 'Scape.Forensics.Native.FileHash' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "CALCULATING FILE HASHES..." -StatusFlag "WARN"
    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
        ScreenId = "HashScreen"
        TitleKey = "TOOL_FILEHASH"
        Rows = @( @{ LeftText = "Get-FileHash"; RightText = "Please specify a specific file path to hash. This module requires CLI arguments or a FilePicker integration."; Flag = "Warning"; RightFlag = "Warning" } )
    }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "FILEHASH AUDIT PENDING" -StatusFlag "Success"
}
