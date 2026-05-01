<#
.SYNOPSIS
    Domain: Presentation\Router
    Module: Scape.Presentation.Router
    Architecture: State Machine Governor | Single Path Routing | Non-Blocking Main Loop
#>
[CmdletBinding()] param()

$Script:RouteStack = [System.Collections.Generic.List[string]]::new()
$Script:CursorMemory = @{}

function Add-ScapeRouteToStack {
    [CmdletBinding(SupportsShouldProcess = $true)] [OutputType([array])]
    param([Parameter(Mandatory = $true)][array]$Stack, [Parameter(Mandatory = $true)][string]$Route)
    process {
        if ($PSCmdlet.ShouldProcess("RouteStack", "Add $Route")) { return $Stack + @($Route) }
        return $Stack
    }
}

function Remove-ScapeRouteFromStack {
    [CmdletBinding(SupportsShouldProcess = $true)] [OutputType([array])]
    param([Parameter(Mandatory = $true)][array]$Stack)
    process {
        if ($PSCmdlet.ShouldProcess("RouteStack", "Remove Last")) {
            if ($Stack.Count -le 1) { return $Stack }
            return $Stack[0..($Stack.Count - 2)]
        }
        return $Stack
    }
}

function Get-ScapeMenuData {
    [CmdletBinding()] [OutputType([array])]
    param([Parameter(Mandatory = $true)][string]$MenuId, [Parameter(Mandatory = $false)]$Fallback = @())
    process {
        $data = Get-ScapeConstant -Path "menu::$MenuId" -Fallback $null
        if ($null -eq $data) { $data = Get-ScapeConstant -Path "ui::$MenuId" -Fallback $null }
        if ($null -eq $data) { $data = Get-ScapeConstant -Path "ui::Menus::$MenuId" -Fallback $null }

        if ($data -is [array]) { return $data }

        [Console]::Clear()
        Write-Output "`n [ROUTER FATAL ERROR] Inanição de Dados no Menu: $MenuId" -ForegroundColor Red -BackgroundColor Black
        Write-Output " O Router tentou renderizar a tela, mas o Get-ScapeConstant retornou vazio." -ForegroundColor Yellow
        Read-Host "`n Pressione ENTER para forçar o encerramento..."
        return $Fallback
    }
}

function Resolve-ScapeMenuTitleKey {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)][string]$MenuId)
    process {
        $cleanId = ($MenuId -replace 'Menu$', '').ToUpper()
        $candidate = "MENU_$($cleanId)_TITLE"
        if (Get-Command Get-ScapeI18NNode -ErrorAction SilentlyContinue) {
            $resolved = Get-ScapeI18NNode -Key $candidate
            if ($resolved.Text -ne $candidate) { return $candidate }
        }
        return $MenuId
    }
}

function Invoke-ScapeMenuStateTransition {
    [CmdletBinding()] [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$CurrentState,
        [Parameter(Mandatory = $true)][string]$UserInput,
        [Parameter(Mandatory = $true)][int]$CursorIndex,
        [Parameter(Mandatory = $true)][int]$OptionCount,
        [Parameter(Mandatory = $false)][bool]$WrapNavigation = $true
    )
    process {
        $combos = Get-ScapeConstant -Path "ui::Input::PSCombos" -Fallback @{ Accept = 'Enter'; Cancel = 'Escape'; HistoryPrev = 'UpArrow'; HistoryNext = 'DownArrow' }
        $normKey = $UserInput -replace 'Arrow', ''

        $newCursor = $CursorIndex
        $shouldRender = $false
        $action = $null

        $acceptKey = Get-ScapeProperty -Object $combos -PropertyName 'Accept' -Fallback 'Enter'
        $cancelKey = Get-ScapeProperty -Object $combos -PropertyName 'Cancel' -Fallback 'Escape'
        $prevKey = Get-ScapeProperty -Object $combos -PropertyName 'HistoryPrev' -Fallback 'Up'
        $nextKey = Get-ScapeProperty -Object $combos -PropertyName 'HistoryNext' -Fallback 'Down'

        if ($normKey -eq $acceptKey -or $normKey -eq 'Enter') { $action = 'Select' }
        elseif ($normKey -eq $cancelKey -or $normKey -eq 'Escape' -or $normKey -eq 'Backspace') { $action = 'Back' }
        elseif ($normKey -eq $prevKey -or $normKey -eq 'Up') {
            $newCursor = if ($CursorIndex -gt 0) { $CursorIndex - 1 } elseif ($WrapNavigation) { $OptionCount - 1 } else { $CursorIndex }
            $shouldRender = $true
        }
        elseif ($normKey -eq $nextKey -or $normKey -eq 'Down') {
            $newCursor = if ($CursorIndex -lt ($OptionCount - 1)) { $CursorIndex + 1 } elseif ($WrapNavigation) { 0 } else { $CursorIndex }
            $shouldRender = $true
        }

        return @{ State = $CurrentState; Cursor = $newCursor; ShouldRender = $shouldRender; Action = $action }
    }
}

function Start-ScapeRouter {
    [CmdletBinding(SupportsShouldProcess = $true)] [OutputType([void])]
    param([Parameter(Mandatory = $false)][string]$InitialMenu = 'MainMenu')
    process {
        if ($PSCmdlet.ShouldProcess("Presentation Layer", "Start View Router")) {
            if (Get-Command Initialize-ScapeRenderer -ErrorAction SilentlyContinue) { Initialize-ScapeRenderer }
            if (Get-Command Initialize-ScapeTheme -ErrorAction SilentlyContinue) { Initialize-ScapeTheme }

            $menu = $InitialMenu
            $stack = @($InitialMenu)
            [Console]::CursorVisible = $false

            try {
                while ($true) {
                    $rawOpts = Get-ScapeMenuData -MenuId $menu
                    if ($null -eq $rawOpts -or $rawOpts.Count -eq 0) { break }

                    $titleKey = Resolve-ScapeMenuTitleKey -MenuId $menu
                    $initCursor = if ($Script:CursorMemory.Contains($menu)) { $Script:CursorMemory[$menu] } else { 0 }

                    $hydratedOpts = Update-ScapeMenuViewModel -MenuId $menu -RawOptions $rawOpts

                    $engineResult = Invoke-ScapeMenuEngine -MenuId $menu -RawOptions $hydratedOpts -TitleKey $titleKey -InitialCursor $initCursor

                    if ($null -eq $engineResult -or $null -eq $engineResult.Selection) {
                        if (Get-Command Receive-ScapeEvent -ErrorAction SilentlyContinue) {
                            $null = Receive-ScapeEvent -MaxBatchSize 20
                        }
                        continue
                    }

                    $Script:CursorMemory[$menu] = $engineResult.Cursor
                    $selection = $engineResult.Selection
                    $selAction = Get-ScapeProperty -Object $selection -PropertyName 'Action' -Fallback ''
                    $selId = Get-ScapeProperty -Object $selection -PropertyName 'Id' -Fallback ''

                    if ($selAction -eq 'ESC' -or $selId -in @('RETURN', 'CANCEL')) {
                        if ($stack.Count -gt 1) {
                            $stack = Remove-ScapeRouteFromStack -Stack $stack
                            $menu = $stack[-1]
                            [Console]::Clear()
                            continue
                        }
                        else { break }
                    }

                    if ($selId -eq 'EXIT') { break }

                    $eff = Resolve-ScapeSelectionEffect -SelectedOption $selection -CurrentMenu $menu -RouteStack $stack

                    $effAction = Get-ScapeProperty -Object $eff -PropertyName 'Action' -Fallback ''
                    if ($effAction -eq 'TERMINATE') { break }
                    if ($effAction -eq 'MUTATE') { [Console]::Clear(); continue }

                    $menu = Get-ScapeProperty -Object $eff -PropertyName 'NextMenu' -Fallback $menu
                    $stack = Get-ScapeProperty -Object $eff -PropertyName 'RouteStack' -Fallback $stack

                    [Console]::Clear()
                }
            }
            finally {
                [Console]::CursorVisible = $true
                [Console]::Clear()
                Write-Output "SCAPE RECOVERY ENGINE SHUTDOWN." -ForegroundColor DarkGray
            }
        }
    }
}