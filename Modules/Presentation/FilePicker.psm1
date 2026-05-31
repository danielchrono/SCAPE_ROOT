<#
.SYNOPSIS
    Domain: Presentation | Module: Scape.Presentation.FilePicker
    Architecture: Hybrid COM/TUI Input Dialog
    Description: Uses Windows Shell COM object to prompt for folder selection
                 without locking the console message pump, with graceful TUI fallback.
#>
[CmdletBinding()] param()

function Invoke-ScapeDirectoryPicker {
    [CmdletBinding()]
    [OutputType([void])]
    param([hashtable]$Payload)
    process {
        [void]$Payload
        $initMsg = Invoke-ScapeI18NFormat -Key "FILEPICKER_INIT"
        Publish-ScapeEvent -Type "NET_MAP_INIT" -Severity "INFO" -Payload @{ Message = $initMsg }

        $dialogTitle = Invoke-ScapeI18NFormat -Key "FILEPICKER_DIALOG"

        # Create isolated STA Runspace for COM object
        $rs = [runspacefactory]::CreateRunspace()
        $rs.ApartmentState = "STA"
        $rs.ThreadOptions = "ReuseThread"
        $rs.Open()

        $ps = [powershell]::Create()
        $ps.Runspace = $rs
        $ps.AddScript({
                param($Title)
                $shell = New-Object -ComObject Shell.Application
                $folder = $shell.BrowseForFolder(0, $Title, 0x0240, 0)
                if ($null -ne $folder) { return $folder.Self.Path }
                return $null
            }).AddArgument($dialogTitle) | Out-Null

        # Register purely reactive callback
        Register-ObjectEvent -InputObject $ps -EventName InvocationStateChanged -Action {
            if ($sender.InvocationStateInfo.State -eq 'Completed') {
                $selectedPath = $sender.EndInvoke($sender.EndInvokeAsyncResult)[0]
                $sender.Dispose()
                $sender.Runspace.Close()
                $sender.Runspace.Dispose()

                if ([string]::IsNullOrWhiteSpace($selectedPath)) {
                    $cancelMsg = "Cancelado pelo usuario." # Fallback I18N
                    Publish-ScapeEvent -Type "NET_MAP_CANCELLED" -Severity "WARN" -Payload @{ Message = $cancelMsg }
                    return
                }

                # Dispatch intent to Model Layer instead of writing filesystem
                Publish-ScapeEvent -Type 'ACTION_CREATE_DIRECTORY' -Severity 'INFO' -Payload @{ Path = $selectedPath }
                Publish-ScapeEvent -Type 'INTENT_CHANGE_SETTING' -Key 'OutPath' -Value $selectedPath
                Publish-ScapeEvent -Type "STATE_MUTATED" -Severity "INFO" -Payload @{
                    MenuId      = "DestSelection"
                    SelectionId = "FOLDER"
                    Timestamp   = [DateTime]::Now
                }
            }
            elseif ($sender.InvocationStateInfo.State -eq 'Failed') {
                Publish-ScapeEvent -Type "UI_SELECT_DIR_ERROR" -Severity "FATAL" -Payload @{ Message = "COM_FAIL" }
                $sender.Dispose()
                $sender.Runspace.Close()
                $sender.Runspace.Dispose()
            }
        } | Out-Null

        $ps.BeginInvoke() | Out-Null
    }
}
Register-ScapeActionHandler -Target 'Scape.Presentation.FilePicker' -Handler {
    param($Task, $PayloadDef, $Target)
    [void]$Task
    [void]$Target
    if (Get-Command Invoke-ScapeDirectoryPicker -ErrorAction SilentlyContinue) { Invoke-ScapeDirectoryPicker -Payload $PayloadDef }
}