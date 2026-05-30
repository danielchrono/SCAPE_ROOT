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
                $ns.RouteStack = @($ns.RouteStack[0..($ns.RouteStack.Count - 2)])
                $ns.CurrentMenu = $ns.RouteStack[-1]
                $ns.NeedsFullRedraw = $true
            } else {
                $ns.IsRunning = $false
            }
            return $ns
        }
        if ($selAction -eq 'NAVIGATE' -and $selTarget) {
            $ns.RouteStack = @($ns.RouteStack) + $selTarget
            $ns.CurrentMenu = $selTarget
            $ns.NeedsFullRedraw = $true
        }
        return $ns
    }
}

function Start-ScapeRouter {
    param([string]$InitialMenu = 'MainMenu')
    process {
        $ViewportState = @{}
        if (Get-Command Initialize-ScapeViewportState -ErrorAction SilentlyContinue) {
            $ViewportState = Initialize-ScapeViewportState
        }

        Initialize-ScapeRenderer
        Initialize-ScapeStateObserver -AutoRegister | Out-Null

        $State = @{
            IsRunning = $true; CurrentMenu = $InitialMenu
            RouteStack = @($InitialMenu)
            Cursor = 0; NeedsFullRedraw = $true; NeedsCursorUpdate = $false
            RawOptions = @(); LastCursor = -1; TitleKey = ""
        }

        Clear-ScapeInputBuffer -ErrorAction SilentlyContinue

        try {
            # Start Async Input Listener
            $inputRs = [runspacefactory]::CreateRunspace()
            $inputRs.Open()
            $inputPs = [powershell]::Create()
            $inputPs.Runspace = $inputRs
            $inputPs.AddScript({
                while($true) {
                    if (Test-ScapeKeyAvailable) {
                        $key = Read-ScapeRawKey
                        New-Event -SourceIdentifier "KEY_PRESSED" -MessageData $key | Out-Null
                    }
                    [System.Threading.Thread]::Sleep(20)
                }
            }) | Out-Null
            $inputAsync = $inputPs.BeginInvoke()

            while ($State.IsRunning) {
                Invoke-ScapeIdlePump | Out-Null
                $evt = Wait-Event -Timeout 0.05
                if ($evt) {
                    Remove-Event -SourceIdentifier $evt.SourceIdentifier
                }

                $resizeCheck = Test-ScapeViewportChanged -LastWidth $ViewportState.LastWidth -LastHeight $ViewportState.LastHeight
                if ($resizeCheck.HasResized) {
                    $ViewportState.LastWidth = $resizeCheck.NewWidth
                    $ViewportState.LastHeight = $resizeCheck.NewHeight
                    $ViewportState.HasResized = $true
                    $ns = $State.Clone()
                    $ns.NeedsFullRedraw = $true
                    $State = $ns
                    Clear-ScapeInputBuffer -ErrorAction SilentlyContinue
                } else {
                    $ViewportState.HasResized = $false
                }

                    }

                    $__rrType = $(if ($State.NeedsFullRedraw) { 'FULL' } else { 'PARTIAL' })
                    Request-ScapeRedraw -MenuId $State.CurrentMenu -Type $__rrType -RouterState $ns -TitleKey $ns.TitleKey

                    $ns.NeedsFullRedraw = $false
                    $ns.NeedsCursorUpdate = $false
                    $State = $ns
                }

                $intent = Get-ScapeInputIntent -CurrentMenuState $State
                if ($intent -ne 'IDLE') {
                    $State = Invoke-ScapeRouterReducer -State $State -Intent $intent
                    if ($State.EventToPublish) {
                        Publish-ScapeEvent -Type $State.EventToPublish.Type -Severity $State.EventToPublish.Severity -Payload $State.EventToPublish.Payload
                        $ns2 = $State.Clone()
                        $ns2.EventToPublish = $null
                        $State = $ns2
                    }
                    Clear-ScapeInputBuffer -ErrorAction SilentlyContinue
                }
            }
        }
        finally {
            Close-ScapeRenderer
            Publish-ScapeEvent -Type "ROUTER_STOP" -Severity "INFO" -Payload @{ Menu = $State.CurrentMenu }
        }
    }
}

$Script:LocalI18N = @(
    "MENU_CHOICE_INVALID",
    "MENU_DEPLOY_TITLE",
    "MENU_DRIVE_OPT_ARCHAEOLOGY",
    "MENU_DRIVE_OPT_HYBRID",
    "MENU_DRIVE_OPT_ISOLATE",
    "MENU_DRIVE_OPT_JOURNAL",
    "MENU_DRIVE_OPT_RETURN",
    "MENU_DRIVE_OPT_TARGETED",
    "MENU_INPUT_PROMPT",
    "MENU_MAESTRO_PROMPT",
    "MENU_MAIN_ARCHAEOLOGY",
    "MENU_MAIN_EXIT",
    "MENU_MAIN_FORENSICS",
    "MENU_MAIN_HARVESTER",
    "MENU_MAIN_LAB",
    "MENU_MAIN_LOGISTICS",
    "MENU_MAIN_PARSING",
    "MENU_MAIN_RECOVERY",
    "MENU_MAIN_SCAN",
    "MENU_MAIN_SETTINGS",
    "MENU_MAIN_TITLE",
    "MENU_OPTION_AUTODETECT",
    "MENU_OPTION_COLOR_MODE",
    "MENU_OPTION_DEFAULT_OUT",
    "MENU_OPTION_ENGINE_MODE",
    "MENU_OPTION_FRAME_STYLE",
    "MENU_OPTION_ICON_LEVEL",
    "MENU_OPTION_LANGUAGE",
    "MENU_OPTION_NETWORK_MGR",
    "MENU_OPTION_PROGRESS_STYLE",
    "MENU_OPTION_RETURN",
    "MENU_OPTION_ROBOCOPY",
    "MENU_OPTION_THEME_PERSONA",
    "MENU_RANDOM_THEME",
    "MENU_RECOVERY_TITLE",
    "MENU_SETTINGS_THEME",
    "MENU_VALUE_DISABLED",
    "MENU_VALUE_ENABLED",
    "MENU_VALUE_NOT_SET",
) | ForEach-Object { Get-ScapeI18NNode -Key $_ }



$Script:LocalI18N += @(
    "ROUTE_EXEC_FAIL",
) | ForEach-Object { Get-ScapeI18NNode -Key $_ }

