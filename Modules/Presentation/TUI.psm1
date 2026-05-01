<#
.SYNOPSIS
    Domain: Presentation\TUI
    Module: Scape.Presentation.TUI
    Architecture: Minimal Console I/O Primitives | Pure Functions | Data-Driven Bounds
#>
[CmdletBinding()] param()

function Get-ScapeConsoleDimension {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([switch]$WithMargins)
    process {
        try {
            $layout = Get-ScapeConstant -Path "ui::Layout" -Fallback @{ MinWidth = 60; MaxWidth = 140; MinHeight = 15 }
            $raw = $Host.UI.RawUI
            $m = if ($WithMargins) { $layout.Margin * 2 } else { 0 }

            return @{
                Width  = [Math]::Max($layout.MinWidth, [Math]::Min($raw.WindowSize.Width - $m, $layout.MaxWidth))
                Height = [Math]::Max($layout.MinHeight, $raw.WindowSize.Height - 5)
            }
        }
        catch {
            $null = $_ # Sacia o Linter (PSAvoidUsingEmptyCatchBlock)
            return @{ Width = 80; Height = 25 }
        }
    }
}

function Set-ScapeCursorPosition {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param([int]$Left = 0, [int]$Top = 0)
    process {
        if ($PSCmdlet.ShouldProcess("Console Cursor", "Set Position to X:$Left Y:$Top")) {
            try {
                $d = Get-ScapeConsoleDimension
                [Console]::SetCursorPosition([Math]::Max(0, [Math]::Min($Left, $d.Width - 1)), [Math]::Max(0, [Math]::Min($Top, $d.Height - 1)))
            }
            catch { $null = $_ }
        }
    }
}

function Set-ScapeCursorVisibility {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param([bool]$Visible)
    process {
        if ($PSCmdlet.ShouldProcess("Console Cursor", "Set Visibility to $Visible")) {
            try { [Console]::CursorVisible = $Visible } catch { $null = $_ }
        }
    }
}

function Read-ScapeKeyPress {
    [CmdletBinding()]
    [OutputType([string])]
    param([int]$TimeoutMilliseconds = 30)
    process {
        $start = [DateTime]::Now
        while (([DateTime]::Now - $start).TotalMilliseconds -lt $TimeoutMilliseconds) {
            if ([Console]::KeyAvailable) { return $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').Key.ToString() }
            Start-Sleep -Milliseconds 10
        }
        return $null
    }
}

function Clear-ScapeInputBuffer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        try { while ([Console]::KeyAvailable) { $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') } } catch { $null = $_ }
    }
}