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
        Publish-ScapeEvent -Type "NET_MAP_INIT" -Severity "INFO" -Payload @{ Message = "Initializing secure directory selection sandbox..." }

        $selectedPath = $null

        try {
            $shell = New-Object -ComObject Shell.Application
            $folder = $shell.BrowseForFolder(0, "SCAPE STAGING: Select Destination Sandbox", 0x0240, 0)

            if ($null -ne $folder) {
                $selectedPath = $folder.Self.Path
            }
        }
        catch {
            Publish-ScapeEvent -Type "UI_SELECT_DIR_ERROR" -Severity "WARN" -Payload @{ Message = "COM Interface failed. Engaging CLI manual prompt." }

            [Console]::CursorVisible = $true
            [Console]::WriteLine("`n")
            $selectedPath = [Console]::ReadLine()
            [Console]::CursorVisible = $false
        }

        if ([string]::IsNullOrWhiteSpace($selectedPath)) {
            Publish-ScapeEvent -Type "NET_MAP_CANCELLED" -Severity "WARN" -Payload @{ Message = "Operation cancelled by operator." }
            return
        }

        if (-not (Test-Path $selectedPath)) {
            try { New-Item -ItemType Directory -Path $selectedPath -Force | Out-Null }
            catch {
                Publish-ScapeEvent -Type "ERR_PATH_INVALID" -Severity "ERROR" -Payload @{ Message = "Cannot create staging path: $selectedPath" }
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
            Publish-ScapeEvent -Type "RC_SPACE_CHECK" -Severity "SUCCESS" -Payload @{ Message = "Staging locked to: $selectedPath" }
        }
    }
}