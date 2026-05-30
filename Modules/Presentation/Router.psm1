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
        $ns = $State.Clone()
        $ns.RouteStack = [System.Collections.Generic.List[string]]::new([string[]]$State.RouteStack)
        $opts = $ns.RawOptions
        $max = $opts.Count
        $ns.LastCursor = $ns.Cursor
        $selAction = $null; $selId = $null; $selTarget = $null; $selPayload = $null; $selWake = $null
        $mutationDirection = $null

        $resolveSelection = {
            if ($max -eq 0) { return $null }
            $sel = $opts[$ns.Cursor]
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
                if ($ns.Cursor -gt 0) { $ns.Cursor-- } else { $ns.Cursor = [Math]::Max(0, $max - 1) }
                $ns.NeedsCursorUpdate = $true
                return $ns
            }
            'DOWN' {
                if ($max -gt 0 -and $ns.Cursor -lt ($max - 1)) { $ns.Cursor++ } else { $ns.Cursor = 0 }
                $ns.NeedsCursorUpdate = $true
                return $ns
            }
            'BACK' { $selAction = 'BACK'; $selId = 'CANCEL' }
            'SELECT' {
                $resolved = & $resolveSelection
                if ($null -eq $resolved) { return $ns }
                $selAction = $resolved.Action
                $selId = $resolved.Id
                $selTarget = $resolved.Target
                $selPayload = $resolved.Payload
                $selWake = $resolved.Layer
            }
            'LEFT' {
                $resolved = & $resolveSelection
                if ($null -eq $resolved -or $resolved.Action -ne 'MUTATE') { return $ns }
                $selAction = $resolved.Action
                $selId = $resolved.Id
                $selTarget = $resolved.Target
                $selPayload = $resolved.Payload
                $selWake = $resolved.Layer
                $mutationDirection = 'PREV'
                $ns.NeedsCursorUpdate = $true
            }
            'RIGHT' {
                $resolved = & $resolveSelection
                if ($null -eq $resolved -or $resolved.Action -ne 'MUTATE') { return $ns }
                $selAction = $resolved.Action
                $selId = $resolved.Id
                $selTarget = $resolved.Target
                $selPayload = $resolved.Payload
                $selWake = $resolved.Layer
                $mutationDirection = 'NEXT'
                $ns.NeedsCursorUpdate = $true
            }
            default { return $ns }
        }

        if ($selId -eq 'EXIT' -or $selAction -eq 'TERMINATE') { $ns.IsRunning = $false; return $ns }

        if ($selAction -or $selId) {
            $ns.EventToPublish = @{
                Type = "UI_SELECTION"
                Severity = "INFO"
                Payload = @{
                    MenuId = $ns.CurrentMenu; SelectionId = $selId; Action = $selAction
                    Target = $selTarget; Payload = $selPayload; ActionPayload = $selPayload; Layer = $selWake; MutationDirection = $mutationDirection
                    Cursor = $ns.Cursor
                }
            }
        }

        if ($selAction -eq 'BACK' -or $selId -in @('RETURN', 'CANCEL')) {
            if ($ns.RouteStack.Count -gt 1) {
                $ns.RouteStack.RemoveAt($ns.RouteStack.Count - 1)
                $ns.CurrentMenu = $ns.RouteStack[-1]
                $ns.NeedsFullRedraw = $true
            } else {
                $ns.IsRunning = $false
            }
            return $ns
        }
        if ($selAction -eq 'NAVIGATE' -and $selTarget) {
            $ns.RouteStack.Add($selTarget)
            $ns.CurrentMenu = $selTarget
            $ns.NeedsFullRedraw = $true
        }
        return $ns
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
                $resizeCheck = Test-ScapeViewportChanged -LastWidth $ViewportState.LastWidth -LastHeight $ViewportState.LastHeight
                if ($resizeCheck.HasResized) {
                    $ViewportState.LastWidth = $resizeCheck.NewWidth
                    $ViewportState.LastHeight = $resizeCheck.NewHeight
                    $ViewportState.HasResized = $true
                    if (Get-Command Set-ScapeViewportLocks -ErrorAction SilentlyContinue) { Set-ScapeViewportLocks | Out-Null }
                    $State.NeedsFullRedraw = $true
                    Clear-ScapeInputBuffer -ErrorAction SilentlyContinue # Limpa input fantasma gerado pelo redimensionamento no Windows
                } else {
                    $ViewportState.HasResized = $false
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
                    if ($State.EventToPublish) {
                        Publish-ScapeEvent -Type $State.EventToPublish.Type -Severity $State.EventToPublish.Severity -Payload $State.EventToPublish.Payload
                        $State.EventToPublish = $null
                    }
                    Clear-ScapeInputBuffer -ErrorAction SilentlyContinue
                }
                [System.Threading.Thread]::Sleep(15)
            }
        }
        finally {
            Close-ScapeRenderer
            Publish-ScapeEvent -Type "ROUTER_STOP" -Severity "INFO" -Payload @{ Menu = $State.CurrentMenu }
        }
    }
}