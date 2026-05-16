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
            return @{
                Width  = [Math]::Max($layout.MinWidth, [Math]::Min($Script:ConsoleCache.Width - $m, $layout.MaxWidth))
                Height = [Math]::Max($layout.MinHeight, $Script:ConsoleCache.Height - $layout.HeaderHeight)
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

        return @{
            Width  = [Math]::Max($layout.MinWidth, [Math]::Min($Script:ConsoleCache.Width - $m, $layout.MaxWidth))
            Height = [Math]::Max($layout.MinHeight, $Script:ConsoleCache.Height - $layout.HeaderHeight)
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
                $d = Get-ScapeConsoleDimension
                [Console]::SetCursorPosition(
                    [Math]::Max(0, [Math]::Min($Left, $d.Width - 1)),
                    [Math]::Max(0, [Math]::Min($Top, $d.Height - 1))
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
        $vKeyMap = Get-ScapeConstant -Path "ui::Input::VirtualKeyMap" -Fallback @{}

        # Unifica input via [Console] apenas (evita conflito Host.UI.RawUI)
        $start = [DateTime]::Now
        $timeout = [TimeSpan]::FromMilliseconds($TimeoutMilliseconds)

        while (([DateTime]::Now - $start) -lt $timeout) {
            if ([Console]::KeyAvailable) {
                try {
                    $keyInfo = [Console]::ReadKey($true)
                    $keyCode = $keyInfo.Key

                    # Tenta match por nome (string) primeiro, depois por valor (int)
                    $mapped = $vKeyMap[$keyCode.ToString()]
                    if ($null -eq $mapped) {
                        $mapped = $vKeyMap[[int]$keyCode]
                    }
                    if ($null -ne $mapped) { return [string]$mapped }

                    # Fallback: retorna caractere ou nome da tecla
                    if ($keyInfo.KeyChar -ne 0) { return $keyInfo.KeyChar.ToString() }
                    return $keyCode.ToString()
                }
                catch { return $null }
            }
            Start-Sleep -Milliseconds 10  # Polling curto para responsividade
        }
        return $null
    }
}

function Clear-ScapeInputBuffer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        try {
            while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) }
        }
        catch { $null = $_ }
    }
}