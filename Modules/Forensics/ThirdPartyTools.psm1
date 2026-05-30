<#
.SYNOPSIS
    Domain: Forensics | Module: Scape.Forensics.ThirdPartyTools
    Architecture: Specialized Third-Party Forensics Handler
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Invoke-ThirdPartyTool {
    param(
        [string]$ToolName,
        [string]$CommandName,
        [string]$TitleKey,
        [string]$ScreenId,
        [string]$Target,
        [string]$Task,
        [string]$Arguments = ""
    )
    $rows = @()
    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_LAUNCH" -Args @($ToolName)) -StatusFlag "WARN" -RunProgress 50 -StepProgress 50
        try {
            if ([string]::IsNullOrWhiteSpace($Arguments)) {
                $proc = Start-Process -FilePath $CommandName -Wait -PassThru -ErrorAction Stop
            }
            else {
                $proc = Start-Process -FilePath $CommandName -ArgumentList $Arguments -Wait -PassThru -ErrorAction Stop
            }
            $rows += @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_SUCCESS" -Args @($ToolName)); Flag = "Success"; RightFlag = "Success" }
            $rows += @{ LeftText = "ExitCode"; RightText = "$($proc.ExitCode)"; Flag = "Success"; RightFlag = "Info" }
        }
        catch {
            $rows += @{ LeftText = (Invoke-ScapeI18NFormat -Key "TOOL_ERROR_LBL"); RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_TOOL_FAIL" -Args @($ToolName)) + ": $($_.Exception.Message)"); Flag = "Failure"; RightFlag = "Failure" }
        }
    }
    else {
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_PACKAGER" -Args @($ToolName)) -StatusFlag "WARN"
        if (Get-Command "Install-ScapeForensicTool" -ErrorAction SilentlyContinue) {
            $installResult = Install-ScapeForensicTool -ToolName $ToolName
            if ($installResult.Success) {
                $rows += @{ LeftText = "Packager"; RightText = (Invoke-ScapeI18NFormat -Key "ACTION_PACKAGER_SUCCESS" -Args @($ToolName)); Flag = "Success"; RightFlag = "Success" }
            }
            else {
                $rows += @{ LeftText = "Packager"; RightText = ((Invoke-ScapeI18NFormat -Key "ACTION_PACKAGER_FAIL") + ": $($installResult.Message)"); Flag = "Warning"; RightFlag = "Failure" }
            }
        }
        else {
            $rows += @{ LeftText = "Missing"; RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_MISSING" -Args @($ToolName, $CommandName)); Flag = "Failure"; RightFlag = "Failure" }
            $rows += @{ LeftText = "Hint"; RightText = (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_MISSING_HINT"); Flag = "Info"; RightFlag = "Info" }
        }
    }
    
    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
        ScreenId = $ScreenId
        TitleKey = $TitleKey
        Rows     = $rows
    }
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "ACTION_TOOL_COMPLETE" -Args @($ToolName)) -StatusFlag "Success" -RunProgress 100 -StepProgress 100
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.AUTOSPSY' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'AUTOSPSY' -CommandName 'autopsy' -TitleKey 'TOOL_AUTOSPSY' -ScreenId 'AUTOSPSYScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.VOLATILITY' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'VOLATILITY' -CommandName 'volatility' -TitleKey 'TOOL_VOLATILITY' -ScreenId 'VOLATILITYScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.FTKIMAGER' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'FTKIMAGER' -CommandName 'ftkimager' -TitleKey 'TOOL_FTKIMAGER' -ScreenId 'FTKIMAGERScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.KAPE' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'KAPE' -CommandName 'kape' -TitleKey 'TOOL_KAPE' -ScreenId 'KAPEScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.TESTDISK' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'TESTDISK' -CommandName 'testdisk' -TitleKey 'TOOL_TESTDISK' -ScreenId 'TESTDISKScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.PHOTOREC' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'PHOTOREC' -CommandName 'photorec' -TitleKey 'TOOL_PHOTOREC' -ScreenId 'PHOTORECScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.MAGNET' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'MAGNET' -CommandName 'magnet' -TitleKey 'TOOL_MAGNET' -ScreenId 'MAGNETScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.WIRESHARK' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'WIRESHARK' -CommandName 'wireshark' -TitleKey 'TOOL_WIRESHARK' -ScreenId 'WIRESHARKScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.TCPDUMP' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'TCPDUMP' -CommandName 'tcpdump' -TitleKey 'TOOL_TCPDUMP' -ScreenId 'TCPDUMPScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.NMAP' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'NMAP' -CommandName 'nmap' -TitleKey 'TOOL_NMAP' -ScreenId 'NMAPScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.SYSINTERNALS' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'SYSINTERNALS' -CommandName 'sysinternals' -TitleKey 'TOOL_SYSINTERNALS' -ScreenId 'SYSINTERNALSScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.REGCFG' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'REGCFG' -CommandName 'regcfg' -TitleKey 'TOOL_REGCFG' -ScreenId 'REGCFGScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.MEMORYZE' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'MEMORYZE' -CommandName 'memoryze' -TitleKey 'TOOL_MEMORYZE' -ScreenId 'MEMORYZEScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.REDLINE' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'REDLINE' -CommandName 'redline' -TitleKey 'TOOL_REDLINE' -ScreenId 'REDLINEScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.PLASO' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'PLASO' -CommandName 'plaso' -TitleKey 'TOOL_PLASO' -ScreenId 'PLASOScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.LOG2TIMELINE' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'LOG2TIMELINE' -CommandName 'log2timeline' -TitleKey 'TOOL_LOG2TIMELINE' -ScreenId 'LOG2TIMELINEScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.XWAYS' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'XWAYS' -CommandName 'xways' -TitleKey 'TOOL_XWAYS' -ScreenId 'XWAYSScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.SLEUTHKIT' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'SLEUTHKIT' -CommandName 'sleuthkit' -TitleKey 'TOOL_SLEUTHKIT' -ScreenId 'SLEUTHKITScreen' -Target $Target -Task $Task
}

Register-ScapeActionHandler -Target 'Scape.Forensics.ThirdParty.DD' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ThirdPartyTool -ToolName 'DD' -CommandName 'dd' -TitleKey 'TOOL_DD' -ScreenId 'DDScreen' -Target $Target -Task $Task
}

Export-ModuleMember -Function 'Invoke-ThirdPartyTool'

