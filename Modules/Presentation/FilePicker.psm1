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
        $initMsg = Invoke-ScapeI18NFormat -Key "FILEPICKER_INIT"
        Publish-ScapeEvent -Type "NET_MAP_INIT" -Severity "INFO" -Payload @{ Message = $initMsg }

        $selectedPath = $null

        try {
            $shell = New-Object -ComObject Shell.Application
            $dialogTitle = Invoke-ScapeI18NFormat -Key "FILEPICKER_DIALOG"
            $folder = $shell.BrowseForFolder(0, $dialogTitle, 0x0240, 0)

            if ($null -ne $folder) {
                $selectedPath = $folder.Self.Path
            }
        }
        catch {
            $failMsg = Invoke-ScapeI18NFormat -Key "FILEPICKER_COM_FAIL"
            Publish-ScapeEvent -Type "UI_SELECT_DIR_ERROR" -Severity "WARN" -Payload @{ Message = $failMsg }

            [Console]::CursorVisible = $true
            [Console]::WriteLine("`n")
            
            $buf = ""
            while ($true) {
                if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }
                if ($Host.UI.RawUI.KeyAvailable) {
                    $k = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    if ($k.VirtualKeyCode -eq 13) { break }
                    if ($k.VirtualKeyCode -eq 8) { 
                        if ($buf.Length -gt 0) { 
                            $buf = $buf.Substring(0, $buf.Length - 1)
                            $x = [Console]::CursorLeft
                            $y = [Console]::CursorTop
                            if ($x -gt 0) { [Console]::SetCursorPosition($x - 1, $y); [Console]::Write(" "); [Console]::SetCursorPosition($x - 1, $y) }
                        } 
                    }
                    elseif ($k.Character -ne 0) { 
                        $buf += $k.Character
                        [Console]::Write($k.Character) 
                    }
                } else {
                    Start-Sleep -Milliseconds 15
                }
            }
            $selectedPath = $buf
            [Console]::CursorVisible = $false
        }

        if ([string]::IsNullOrWhiteSpace($selectedPath)) {
            $cancelMsg = Invoke-ScapeI18NFormat -Key "FILEPICKER_CANCEL"
            Publish-ScapeEvent -Type "NET_MAP_CANCELLED" -Severity "WARN" -Payload @{ Message = $cancelMsg }
            return
        }

        if (-not (Test-Path $selectedPath)) {
            try { New-Item -ItemType Directory -Path $selectedPath -Force | Out-Null }
            catch {
                $invalidMsg = (Invoke-ScapeI18NFormat -Key "FILEPICKER_INVALID") -f $selectedPath
                Publish-ScapeEvent -Type "ERR_PATH_INVALID" -Severity "ERROR" -Payload @{ Message = $invalidMsg }
                return
            }
        }

        if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) {
            Set-ScapeSettingMutation -Key 'OutPath' -Value $selectedPath | Out-Null

            Publish-ScapeEvent -Type "STATE_MUTATED" -Severity "INFO" -Payload @{
                MenuId      = "DestSelection"
                SelectionId = "FOLDER"
                Timestamp   = [DateTime]::Now
            }
            $lockedMsg = (Invoke-ScapeI18NFormat -Key "FILEPICKER_LOCKED") -f $selectedPath
            Publish-ScapeEvent -Type "RC_SPACE_CHECK" -Severity "SUCCESS" -Payload @{ Message = $lockedMsg }
        }
    }
}
Register-ScapeActionHandler -Target 'Scape.Presentation.FilePicker' -Handler {
    param($Task, $PayloadDef, $Target)
    if (Get-Command Invoke-ScapeDirectoryPicker -ErrorAction SilentlyContinue) { Invoke-ScapeDirectoryPicker -Payload $PayloadDef }
}