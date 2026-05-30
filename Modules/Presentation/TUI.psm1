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
    param([switch]$WithMargins)
    
    $maxW = Get-ScapeConstant -Path "ui::Config::MaxCanvasWidth" -Fallback 140
    $maxH = Get-ScapeConstant -Path "ui::Config::MaxCanvasHeight" -Fallback 40
    $layout = Get-ScapeConstant -Path "ui::Layout"
    
    $width = 120
    $height = 30
    
    try {
        $raw = Get-Host | Select-Object -ExpandProperty UI | Select-Object -ExpandProperty RawUI
        $width = $raw.WindowSize.Width
        $height = $raw.WindowSize.Height
    } catch {
        $width = [Console]::WindowWidth
        $height = [Console]::WindowHeight
    }
    
    if ($WithMargins) {
        $m = $layout.Margin * 2
        return @{
            Width  = [Math]::Max($layout.MinWidth, [Math]::Min($width - $m, $maxW))
            Height = [Math]::Max($layout.MinHeight, [Math]::Min($height - $layout.HeaderHeight, $maxH))
        }
    }
    
    return @{ Width = $width; Height = $height }
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

            if ($true) {
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
                Invoke-ScapeIdlePump | Out-Null
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
            if (Get-Command Add-ScapeDisplayListAt -ErrorAction SilentlyContinue) {
                Add-ScapeDisplayListAt -X $Left -Y ($Top + $i) -Text $blankLine
            } else {
                Set-ScapeCursorPosition -Left $Left -Top ($Top + $i)
                [Console]::Write($blankLine)
            }
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
        $blankLine = " " * $Width
        if (Get-Command Add-ScapeDisplayList -ErrorAction SilentlyContinue) {
            Add-ScapeDisplayListAt -X $Left -Y $Top -Text $blankLine
        } else {
            Set-ScapeCursorPosition -Left $Left -Top $Top
            [Console]::Write($blankLine)
        }
    }
}

Export-ModuleMember -Function Get-ScapeConsoleDimension, Set-ScapeCursorPosition, Set-ScapeCursorVisibility, Read-ScapeKeyPress, Clear-ScapeInputBuffer, Clear-ScapeRegion, Clear-ScapeLine
function Test-ScapeKeyAvailable { return [Console]::KeyAvailable }

function Read-ScapeRawKey { return [Console]::ReadKey($true) }
