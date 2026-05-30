<#
.SYNOPSIS
    Domain: Presentation\TUI
    Module: Scape.Presentation.TUI
    Architecture: Minimal Console I/O Primitives | Pure Functions | Data-Driven Bounds
#>
[CmdletBinding()] param()

# Cache de dimensões para evitar chamadas repetidas ao Host
$Script:ConsoleCache = @{
    Width     = 0
    Height    = 0
    LastCheck = [DateTime]::MinValue
    TTL_MS    = 100  # Cache válido por 100ms
}

function Get-ScapeConsoleDimension {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([switch]$WithMargins)
    process {
        # Memoization: reusa cache se válido
        $now = [DateTime]::Now
        $elapsed = ($now - $Script:ConsoleCache.LastCheck).TotalMilliseconds

        if ($elapsed -lt $Script:ConsoleCache.TTL_MS -and $Script:ConsoleCache.Width -gt 0) {
            $layout = Get-ScapeConstant -Path "ui::Layout"
            $m = if ($WithMargins) { $layout.Margin * 2 } else { 0 }
            $maxW = if ($layout.MaxWidth -gt 0) { $layout.MaxWidth } else { 9999 }
            $maxH = if ($layout.MaxHeight -gt 0) { $layout.MaxHeight } else { 9999 }
            return @{
                Width  = [Math]::Max($layout.MinWidth, [Math]::Min($Script:ConsoleCache.Width - $m, $maxW))
                Height = [Math]::Max($layout.MinHeight, [Math]::Min($Script:ConsoleCache.Height - $layout.HeaderHeight, $maxH))
            }
        }

        # Atualiza cache
        try {
            $raw = $Host.UI.RawUI
            $Script:ConsoleCache.Width = $raw.WindowSize.Width
            $Script:ConsoleCache.Height = $raw.WindowSize.Height
            $Script:ConsoleCache.LastCheck = $now
        }
        catch {
            # Fallback seguro
            $Script:ConsoleCache.Width = [Console]::WindowWidth
            $Script:ConsoleCache.Height = [Console]::WindowHeight
            $Script:ConsoleCache.LastCheck = $now
        }

        $layout = Get-ScapeConstant -Path "ui::Layout"
        $m = if ($WithMargins) { $layout.Margin * 2 } else { 0 }
        $maxW = if ($layout.MaxWidth -gt 0) { $layout.MaxWidth } else { 9999 }
        $maxH = if ($layout.MaxHeight -gt 0) { $layout.MaxHeight } else { 9999 }

        return @{
            Width  = [Math]::Max($layout.MinWidth, [Math]::Min($Script:ConsoleCache.Width - $m, $maxW))
            Height = [Math]::Max($layout.MinHeight, [Math]::Min($Script:ConsoleCache.Height - $layout.HeaderHeight, $maxH))
        }
    }
}

function Set-ScapeCursorPosition {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param([int]$Left, [int]$Top)
    process {
        if ($PSCmdlet.ShouldProcess("Console Cursor", "Set Position to X:$Left Y:$Top")) {
            try {
                # Clamp against REAL console window size, not derived layout dimensions.
                # Get-ScapeConsoleDimension subtracts HeaderHeight, which misaligns cursor placement.
                $realW = [Console]::WindowWidth
                $realH = [Console]::WindowHeight
                [Console]::SetCursorPosition(
                    [Math]::Max(0, [Math]::Min($Left, $realW - 1)),
                    [Math]::Max(0, [Math]::Min($Top, $realH - 1))
                )
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
    param([int]$TimeoutMilliseconds)
    process {
        $oldEap = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        try {
            $vKeyMap = Get-ScapeConstant -Path "ui::Input::VirtualKeyMap" -Fallback @{}

            $start = [DateTime]::Now
            $timeout = [TimeSpan]::FromMilliseconds($TimeoutMilliseconds)

            while (([DateTime]::Now - $start) -lt $timeout) {
                try {
                    if ($Host.UI.RawUI.KeyAvailable) {
                        $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                        $keyCode = $keyInfo.VirtualKeyCode

                        $mapped = $vKeyMap[$keyCode.ToString()]
                        if ($null -eq $mapped) {
                            $mapped = $vKeyMap[[int]$keyCode]
                        }
                        if ($null -ne $mapped) { return [string]$mapped }

                        if ($keyInfo.Character -ne 0) { return $keyInfo.Character.ToString() }
                        return $keyCode.ToString()
                    }
                } catch { return $null }
                Start-Sleep -Milliseconds 10
            }
            return $null
        } finally {
            $ErrorActionPreference = $oldEap
        }
    }
}

function Clear-ScapeInputBuffer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        $oldEap = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        try {
            if ($Host.UI.RawUI.KeyAvailable) {
                $Host.UI.RawUI.FlushInputBuffer()
            }
        }
        catch { }
        finally {
            $ErrorActionPreference = $oldEap
        }
    }
}

function Clear-ScapeRegion {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][int]$Left,
        [Parameter(Mandatory = $true)][int]$Top,
        [Parameter(Mandatory = $true)][int]$Width,
        [Parameter(Mandatory = $true)][int]$Height
    )
    process {
        if ($Width -le 0 -or $Height -le 0) { return }
        $blankLine = " " * $Width
        for ($i = 0; $i -lt $Height; $i++) {
            Set-ScapeCursorPosition -Left $Left -Top ($Top + $i)
            [Console]::Write($blankLine)
        }
    }
}

function Clear-ScapeLine {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][int]$Left,
        [Parameter(Mandatory = $true)][int]$Top,
        [Parameter(Mandatory = $true)][int]$Width
    )
    process {
        if ($Width -le 0) { return }
        Set-ScapeCursorPosition -Left $Left -Top $Top
        [Console]::Write(" " * $Width)
    }
}

Export-ModuleMember -Function Get-ScapeConsoleDimension, Set-ScapeCursorPosition, Set-ScapeCursorVisibility, Read-ScapeKeyPress, Clear-ScapeInputBuffer, Clear-ScapeRegion, Clear-ScapeLine