<#
.SYNOPSIS
    Domain: Presentation\Router
    Module: Scape.Presentation.Router
    Architecture: State Machine | Viewport-Aware Event Loop
#>
[CmdletBinding()] param()

function Get-ScapeMenuData {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][string]$MenuId)
    process {
        $data = Get-ScapeConstant -Path "navigation::$MenuId" -Fallback $null
        if ($null -eq $data -or ($data -is [hashtable] -and $data.Count -eq 0)) {
            $navAsset = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
            if ($navAsset -and $navAsset.ContainsKey($MenuId)) { $data = $navAsset[$MenuId] }
        }
        if ($null -eq $data) { return $null }
        if ($data -is [hashtable] -and $data.ContainsKey('Items')) { return $data }
        if ($data -is [array]) { return @{ TitleKey = "MENU_$(($MenuId -replace 'Menu$', '').ToUpper())_TITLE"; Items = $data } }
        return $null
    }
}

function Invoke-ScapeRouterReducer {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([hashtable]$State, [string]$Intent)
    process {
        $opts = $State.RawOptions
        $max = $opts.Count
        $State.LastCursor = $State.Cursor
        $selAction = $null; $selId = $null; $selTarget = $null; $selPayload = $null; $selWake = $null
        $mutationDirection = $null

        $resolveSelection = {
            if ($max -eq 0) { return $null }
            $sel = $opts[$State.Cursor]
            return @{
                Action  = if ($sel -is [hashtable]) { $sel['Action'] } else { $sel.Action }
                Id      = if ($sel -is [hashtable]) { $sel['Id'] } else { $sel.Id }
                Target  = if ($sel -is [hashtable]) { $sel['Target'] } else { $sel.Target }
                Payload = if ($sel -is [hashtable]) { $sel['Payload'] } else { $sel.Payload }
                Layer   = if ($sel -is [hashtable]) { $sel['Layer'] } else { $sel.Layer }
            }
        }

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
            'BACK' { $selAction = 'BACK'; $selId = 'CANCEL' }
            'SELECT' {
                $resolved = & $resolveSelection
                if ($null -eq $resolved) { return $State }
                $selAction = $resolved.Action
                $selId = $resolved.Id
                $selTarget = $resolved.Target
                $selPayload = $resolved.Payload
                $selWake = $resolved.Layer
            }
            'LEFT' {
                $resolved = & $resolveSelection
                if ($null -eq $resolved -or $resolved.Action -ne 'MUTATE') { return $State }
                $selAction = $resolved.Action
                $selId = $resolved.Id
                $selTarget = $resolved.Target
                $selPayload = $resolved.Payload
                $selWake = $resolved.Layer
                $mutationDirection = 'PREV'
                $State.NeedsCursorUpdate = $true
            }
            'RIGHT' {
                $resolved = & $resolveSelection
                if ($null -eq $resolved -or $resolved.Action -ne 'MUTATE') { return $State }
                $selAction = $resolved.Action
                $selId = $resolved.Id
                $selTarget = $resolved.Target
                $selPayload = $resolved.Payload
                $selWake = $resolved.Layer
                $mutationDirection = 'NEXT'
                $State.NeedsCursorUpdate = $true
            }
            default { return $State }
        }

        if ($selId -eq 'EXIT' -or $selAction -eq 'TERMINATE') { $State.IsRunning = $false; return $State }

        if ($selAction -or $selId) {
            Publish-ScapeEvent -Type "UI_SELECTION" -Severity "INFO" -Payload @{
                MenuId = $State.CurrentMenu; SelectionId = $selId; Action = $selAction
                Target = $selTarget; Payload = $selPayload; ActionPayload = $selPayload; Layer = $selWake; MutationDirection = $mutationDirection
                Cursor = $State.Cursor
            }
        }

        if ($selAction -eq 'BACK' -or $selId -in @('RETURN', 'CANCEL')) {
            if ($State.RouteStack.Count -gt 1) {
                $State.RouteStack.RemoveAt($State.RouteStack.Count - 1)
                $State.CurrentMenu = $State.RouteStack[-1]
                $State.NeedsFullRedraw = $true
            } else {
                $State.IsRunning = $false
            }
            return $State
        }
        if ($selAction -eq 'NAVIGATE' -and $selTarget) {
            $State.RouteStack.Add($selTarget)
            $State.CurrentMenu = $selTarget
            $State.NeedsFullRedraw = $true
        }
        return $State
    }
}

function Start-ScapeRouter {
    param([string]$InitialMenu = 'MainMenu')
    process {
        # Rastreamento de Viewport (Responsividade)
        $ViewportState = @{}
        if (Get-Command Initialize-ScapeViewportState -ErrorAction SilentlyContinue) {
            $ViewportState = Initialize-ScapeViewportState
        }

        Initialize-ScapeRenderer
        if (Get-Command Set-ScapeViewportLocks -ErrorAction SilentlyContinue) { Set-ScapeViewportLocks | Out-Null }
        Initialize-ScapeStateObserver -AutoRegister | Out-Null

        $State = @{
            IsRunning = $true; CurrentMenu = $InitialMenu
            RouteStack = New-Object 'System.Collections.Generic.List[string]'
            Cursor = 0; NeedsFullRedraw = $true; NeedsCursorUpdate = $false
            RawOptions = @(); LastCursor = -1; TitleKey = ""
            LastLang = if (Get-Command Get-ScapeColdState -ErrorAction SilentlyContinue) { (Get-ScapeColdState)["CurrentLanguage"] } else { "" }
        }
        $State.RouteStack.Add($InitialMenu)

        Clear-ScapeInputBuffer -ErrorAction SilentlyContinue

        try {
            while ($State.IsRunning) {
                Invoke-ScapeIdlePump | Out-Null

                # PLUG DE RESPONSIVIDADE: Checa redimensionamento em tempo real
                if (Get-Command Test-ScapeViewportChanged -ErrorAction SilentlyContinue) {
                    if (Test-ScapeViewportChanged -ViewportState $ViewportState) {
                        if (Get-Command Set-ScapeViewportLocks -ErrorAction SilentlyContinue) { Set-ScapeViewportLocks | Out-Null }
                        $State.NeedsFullRedraw = $true
                        Clear-ScapeInputBuffer -ErrorAction SilentlyContinue # Limpa input fantasma gerado pelo redimensionamento no Windows
                    }
                }

                # PLUG DE I18N: Checa mudança de idioma
                if (Get-Command Get-ScapeColdState -ErrorAction SilentlyContinue) {
                    $currLang = (Get-ScapeColdState)["CurrentLanguage"]
                    if (-not [string]::IsNullOrWhiteSpace($currLang) -and $State.LastLang -ne $currLang) {
                        $State.NeedsFullRedraw = $true
                        $State.LastLang = $currLang
                    }
                }

                if ($State.NeedsFullRedraw -or $State.NeedsCursorUpdate) {
                    if ($State.NeedsFullRedraw -or -not $State.RawOptions) {
                        $menuData = Get-ScapeMenuData -MenuId $State.CurrentMenu
                        if ($null -eq $menuData -or $null -eq $menuData.Items) {
                            Publish-ScapeEvent -Type "ROUTER_FATAL" -Severity "FATAL" -Payload "Menu starvation: '$($State.CurrentMenu)'"
                            throw "ROUTER_FATAL: Menu '$($State.CurrentMenu)' not found."
                        }
                        $State.RawOptions = $menuData.Items
                        $State.TitleKey = $menuData.TitleKey
                        if ($State.NeedsFullRedraw) { $State.Cursor = 0; $State.LastCursor = -1 }
                    }

                    $__rrType = $(if ($State.NeedsFullRedraw) { 'FULL' } else { 'PARTIAL' })
                    Request-ScapeRedraw -MenuId $State.CurrentMenu -Type $__rrType -RouterState $State -TitleKey $State.TitleKey

                    $State.NeedsFullRedraw = $false
                    $State.NeedsCursorUpdate = $false
                }

                $intent = Get-ScapeInputIntent -CurrentMenuState $State
                if ($intent -ne 'IDLE') {
                    $State = Invoke-ScapeRouterReducer -State $State -Intent $intent
                    Clear-ScapeInputBuffer -ErrorAction SilentlyContinue
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