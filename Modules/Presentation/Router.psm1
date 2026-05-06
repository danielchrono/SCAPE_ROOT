
<#
.SYNOPSIS
    Domain: Presentation\Router
    Module: Scape.Presentation.Router
    Architecture: State Machine Governor | Pure Event Publisher | Lazy-Ready | Zero Hardcode
#>
[CmdletBinding()] param()

function Get-ScapeMenuData {
    [CmdletBinding()]
    [OutputType([array])]
    param([Parameter(Mandatory = $true)][string]$MenuId)
    process {
        $data = Get-ScapeConstant -Path "navigation::$MenuId"
        if ($null -eq $data) { return $null }

        if ($data -is [hashtable] -and $data.ContainsKey('Items')) {
            return $data
        }

        if ($data -is [array]) {
            return @{ TitleKey = "MENU_$(($MenuId -replace 'Menu$', '').ToUpper())_TITLE"; Items = $data }
        }
        return $null
    }
}

function Invoke-ScapeRouterReducer {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([hashtable]$State, [string]$Intent)
    process {
        $opts = @()
        if ($null -ne $State.RawOptions) { $opts = @($State.RawOptions) }
        $max = $opts.Count

        $State.LastCursor = $State.Cursor
        $selAction = $null; $selId = $null; $selTarget = $null; $selPayload = $null; $selWake = $null

        switch ($Intent) {
            'UP' {
                if ($State.Cursor -gt 0) { $State.Cursor-- } else { $State.Cursor = [Math]::Max(0, $max - 1) }
                $State.NeedsCursorUpdate = $true
                return $State
            }
            'DOWN' {
                if ($max -gt 0 -and $State.Cursor -lt ($max - 1)) { $State.Cursor++ } else { $State.Cursor = 0 }
                $State.NeedsCursorUpdate = $true
                return $State
            }
            'BACK' {
                $selAction = 'BACK'
                $selId = 'CANCEL'
            }
            'SELECT' {
                if ($max -eq 0) { return $State }
                $sel = $opts[$State.Cursor]

                $selAction = if ($sel -is [hashtable]) { $sel['Action'] } else { $sel.Action }
                $selId = if ($sel -is [hashtable]) { $sel['Id'] } else { $sel.Id }
                $selTarget = if ($sel -is [hashtable]) { $sel['Target'] } else { $sel.Target }
                $selPayload = if ($sel -is [hashtable]) { $sel['Payload'] } else { $sel.Payload }
                $selWake = if ($sel -is [hashtable]) { $sel['Layer'] } else { $sel.Layer }
            }
            default { return $State }
        }

        if ($selId -eq 'EXIT' -or $selAction -eq 'TERMINATE') {
            $State.IsRunning = $false
            return $State
        }

        if ($selAction -or $selId) {
            $payload = @{
                MenuId = $State.CurrentMenu; SelectionId = $selId; Action = $selAction;
                Target = $selTarget; ActionPayload = $selPayload; Layer = $selWake
            }
            Publish-ScapeEvent -Type "UI_SELECTION" -Severity "INFO" -Payload $payload
        }

        if ($selAction -eq 'BACK' -or $selId -in @('RETURN', 'CANCEL')) {
            if ($State.RouteStack.Count -gt 1) {
                $State.RouteStack.RemoveAt($State.RouteStack.Count - 1)
                $State.CurrentMenu = $State.RouteStack[-1]
                $State.NeedsFullRedraw = $true
            }
            return $State
        }

        if ($selAction -eq 'NAVIGATE' -and $selTarget) {
            $State.RouteStack.Add($selTarget)
            $State.CurrentMenu = $selTarget
            $State.NeedsFullRedraw = $true
            Publish-ScapeEvent -Type "ROUTER_NAVIGATE" -Severity "INFO" -Payload @{ From = $State.RouteStack[-2]; To = $selTarget }
        }

        return $State
    }
}

function Start-ScapeRouter {
    param([string]$InitialMenu = 'MainMenu')
    process {
        Initialize-ScapeRenderer
        Initialize-ScapeStateObserver -AutoRegister | Out-Null

        $State = @{
            IsRunning         = $true
            CurrentMenu       = $InitialMenu
            RouteStack        = New-Object 'System.Collections.Generic.List[string]'
            Cursor            = 0
            NeedsFullRedraw   = $true
            NeedsCursorUpdate = $false
            RawOptions        = @()
            LastCursor        = -1
            TitleKey          = ""
        }
        $State.RouteStack.Add($InitialMenu)

        $viewportState = Initialize-ScapeViewportState

        # Limpa buffer antes de começar (segurança)
        if (Get-Command Clear-ScapeInputBuffer -ErrorAction SilentlyContinue) {
            Clear-ScapeInputBuffer
        }

        try {
            while ($State.IsRunning) {
                # --------------------------------------------------------------
                # DRENA FILA DE EVENTOS (obrigatório!)
                Invoke-ScapeIdlePump | Out-Null
                # --------------------------------------------------------------

                if (Test-ScapeViewportChanged -ViewportState $viewportState) {
                    $State.NeedsFullRedraw = $true
                }

                if ($State.NeedsFullRedraw -or $State.NeedsCursorUpdate) {
                    if ($State.NeedsFullRedraw -or -not $State.RawOptions) {
                        $menuData = Get-ScapeMenuData -MenuId $State.CurrentMenu
                        if ($null -eq $menuData -or $null -eq $menuData.Items) {
                            $fatalMsg = "ROUTER_FATAL: Menu starvation. '$($State.CurrentMenu)' not found."
                            Publish-ScapeEvent -Type "ROUTER_FATAL" -Severity "FATAL" -Payload $fatalMsg
                            throw $fatalMsg
                        }
                        $State.RawOptions = $menuData.Items
                        $State.TitleKey = $menuData.TitleKey
                        if ($State.NeedsFullRedraw) {
                            $State.Cursor = 0
                            $State.LastCursor = -1
                        }
                    }

                    $evtType = if ($State.NeedsFullRedraw) { 'FULL' } else { 'PARTIAL' }

                    # =================================================================
                    # CORREÇÃO: usa a função pública do StateObserver
                    if (Get-Command Request-ScapeRedraw -ErrorAction SilentlyContinue) {
                        Request-ScapeRedraw -MenuId $State.CurrentMenu -Type $evtType -RouterState $State -TitleKey $State.TitleKey
                    }
                    else {
                        Write-Host "[Router] ERRO: Request-ScapeRedraw não disponível" -ForegroundColor Red
                    }
                    # =================================================================

                    Invoke-ScapeIdlePump | Out-Null

                    $State.NeedsFullRedraw = $false
                    $State.NeedsCursorUpdate = $false
                }

                $intent = Get-ScapeInputIntent -CurrentMenuState $State
                if ($intent -ne 'IDLE') {
                    $State = Invoke-ScapeRouterReducer -State $State -Intent $intent
                }

                Start-Sleep -Milliseconds 15
            }
        }
        finally {
            Close-ScapeRenderer
            Publish-ScapeEvent -Type "ROUTER_STOP" -Severity "INFO" -Payload @{ Menu = $State.CurrentMenu }
        }
    }
}
