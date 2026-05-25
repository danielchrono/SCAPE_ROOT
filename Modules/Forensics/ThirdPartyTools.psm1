<#
.SYNOPSIS
    Domain: Forensics | Module: Scape.Forensics.ThirdPartyTools
    Architecture: Specialized Third-Party Forensics Handler
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.WinDirStat' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "CHECKING WINDIRSTAT..." -StatusFlag "WARN"
    try {
        if (Get-Command "windirstat" -ErrorAction SilentlyContinue) {
            Start-Process -FilePath "windirstat" -PassThru
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{ ScreenId = "WinDirStatScreen"; TitleKey = "TOOL_WINDIRSTAT"; Rows = @( @{ LeftText = "Status"; RightText = "Launched"; Flag = "Success"; RightFlag = "Success" } ) }
        } else {
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "WARN" -Payload @{ ScreenId = "WinDirStatScreen"; TitleKey = "TOOL_WINDIRSTAT"; Rows = @( @{ LeftText = "Status"; RightText = "Not Found. Consider using Packager to install via winget (Qiplex.WinDirStat)."; Flag = "Warning"; RightFlag = "Warning" } ) }
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{ ScreenId = "WinDirStatScreen"; TitleKey = "TOOL_WINDIRSTAT"; Rows = @( @{ LeftText = "Error"; RightText = "Execution failed"; Flag = "Failure"; RightFlag = "Failure" } ) }
    }
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.ProcessExplorer' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "CHECKING PROCESS EXPLORER..." -StatusFlag "WARN"
    try {
        if (Get-Command "procexp" -ErrorAction SilentlyContinue) {
            Start-Process -FilePath "procexp" -PassThru
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{ ScreenId = "ProcExpScreen"; TitleKey = "TOOL_PROCEXP"; Rows = @( @{ LeftText = "Status"; RightText = "Launched"; Flag = "Success"; RightFlag = "Success" } ) }
        } else {
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "WARN" -Payload @{ ScreenId = "ProcExpScreen"; TitleKey = "TOOL_PROCEXP"; Rows = @( @{ LeftText = "Status"; RightText = "Not Found. Consider using Packager to install via winget (Microsoft.Sysinternals)."; Flag = "Warning"; RightFlag = "Warning" } ) }
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{ ScreenId = "ProcExpScreen"; TitleKey = "TOOL_PROCEXP"; Rows = @( @{ LeftText = "Error"; RightText = "Execution failed"; Flag = "Failure"; RightFlag = "Failure" } ) }
    }
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.Autoruns' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "CHECKING AUTORUNS..." -StatusFlag "WARN"
    try {
        if (Get-Command "autoruns" -ErrorAction SilentlyContinue) {
            Start-Process -FilePath "autoruns" -PassThru
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{ ScreenId = "AutorunsScreen"; TitleKey = "TOOL_AUTORUNS"; Rows = @( @{ LeftText = "Status"; RightText = "Launched"; Flag = "Success"; RightFlag = "Success" } ) }
        } else {
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "WARN" -Payload @{ ScreenId = "AutorunsScreen"; TitleKey = "TOOL_AUTORUNS"; Rows = @( @{ LeftText = "Status"; RightText = "Not Found. Consider using Packager to install via winget (Microsoft.Sysinternals)."; Flag = "Warning"; RightFlag = "Warning" } ) }
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{ ScreenId = "AutorunsScreen"; TitleKey = "TOOL_AUTORUNS"; Rows = @( @{ LeftText = "Error"; RightText = "Execution failed"; Flag = "Failure"; RightFlag = "Failure" } ) }
    }
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.Everything' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "CHECKING EVERYTHING..." -StatusFlag "WARN"
    try {
        if (Get-Command "Everything" -ErrorAction SilentlyContinue) {
            Start-Process -FilePath "Everything" -PassThru
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{ ScreenId = "EverythingScreen"; TitleKey = "TOOL_EVERYTHING"; Rows = @( @{ LeftText = "Status"; RightText = "Launched"; Flag = "Success"; RightFlag = "Success" } ) }
        } else {
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "WARN" -Payload @{ ScreenId = "EverythingScreen"; TitleKey = "TOOL_EVERYTHING"; Rows = @( @{ LeftText = "Status"; RightText = "Not Found. Consider using Packager to install via winget (voidtools.Everything)."; Flag = "Warning"; RightFlag = "Warning" } ) }
        }
    } catch {
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{ ScreenId = "EverythingScreen"; TitleKey = "TOOL_EVERYTHING"; Rows = @( @{ LeftText = "Error"; RightText = "Execution failed"; Flag = "Failure"; RightFlag = "Failure" } ) }
    }
}
