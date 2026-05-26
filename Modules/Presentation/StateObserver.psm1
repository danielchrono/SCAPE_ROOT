<#
.SYNOPSIS
    Domain: Presentation\StateObserver
    Module: Scape.Presentation.StateObserver
    Architecture: SRP Event Handlers | Debounced Rendering
    [FIX] Corrigidos unapproved verbs (Handle -> Invoke).
    [FIX] Restaurada a legibilidade e verificações defensivas profundas.
#>
[CmdletBinding()] param()

$Script:LastStateHash = ""
$Script:ObserverInitialized = $false
$Script:RedrawDebounce = @{
    LastRequest   = [DateTime]::MinValue
    MinIntervalMs = 10
    IsRendering   = $false
    RequestQueue  = @()
}
$Script:RecentRedraws = [System.Collections.Concurrent.ConcurrentDictionary[string, DateTime]]::new()
$Script:TransientState = @{
    HoldUntil = [DateTime]::MinValue
}

# ==============================================================================
# ISOLATED EVENT HANDLERS (SRP & Approved Verbs)
# ==============================================================================

function Invoke-ScapeTreeUpdateEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -ne 'TREE_UPDATE') { return }

    $payload = $IncomingEventData.Payload
    $nodes = $payload['Nodes']
    $titleKey = $payload['TitleKey']

    $treeItems = @()
    foreach ($node in $nodes) {
        $path = $node['Path']
        $leafName = Split-Path $path -Leaf
        if ([string]::IsNullOrWhiteSpace($leafName)) { $leafName = $path }

        $treeItems += @{
            Text       = $leafName
            Depth      = ($path -split '[/\\]').Count - 1
            StatusFlag = if ($node['Status'] -eq 'Ready') { 'Success' } elseif ($node['Status'] -eq 'Error') { 'Failure' } else { 'Info' }
        }
    }

    $dims = Get-ScapeConsoleDimension -WithMargins
    $availableHeight = $dims.Height - 5
    $visibleCount = [Math]::Min($treeItems.Count, $availableHeight)

    $renderConfig = @{
        Type         = 'TreeView'
        ShouldRender = $true
        Config       = @{
            TitleKey      = $titleKey
            Items         = $treeItems
            CursorIndex   = 0
            ViewportStart = 0
            ViewportEnd   = $visibleCount
        }
    }

    $vmStateSnapshot = Get-ScapeColdState
    $frameStyle = if ($vmStateSnapshot -and $vmStateSnapshot.ContainsKey('FrameStyle')) { [string]$vmStateSnapshot['FrameStyle'] } else { $null }

    Write-ScapeTreeView -RenderConfig $renderConfig -FrameStyle $frameStyle
}

function Invoke-ScapeActionScreenEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -ne 'ACTION_SCREEN_UPDATE') { return }

    $payload = $IncomingEventData.Payload

    $renderConfig = @{
        Type         = 'ActionScreen'
        ShouldRender = $true
        Config       = @{
            TitleKey = $payload['TitleKey']
            Rows     = $payload['Rows']
        }
    }

    $vmStateSnapshot = Get-ScapeColdState
    $frameStyle = if ($vmStateSnapshot -and $vmStateSnapshot.ContainsKey('FrameStyle')) { [string]$vmStateSnapshot['FrameStyle'] } else { $null }

    if (Get-Command Write-ScapeActionScreen -ErrorAction SilentlyContinue) {
        Write-ScapeActionScreen -RenderConfig $renderConfig -FrameStyle $frameStyle
    }
}

function Invoke-ScapeRedrawRequestEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -ne 'UI_REDRAW_REQUEST' -or $null -eq $IncomingEventData.Payload) { return }

    $p = $IncomingEventData.Payload
    if ($null -eq $p) { return }

    # Extração defensiva do RouterState
    $routerState = if ($p -is [System.Collections.IDictionary]) { $p['State'] }
    elseif ($null -ne $p.PSObject -and $p.PSObject.Properties['State']) { $p.State }
    else { $null }

    if ($null -ne $routerState -and $null -eq $routerState.RawOptions) {
        $routerState.RawOptions = @()
    }

    $menuId = if ($p -is [System.Collections.IDictionary]) { $p['MenuId'] }
    elseif ($null -ne $p.PSObject -and $p.PSObject.Properties['MenuId']) { $p.MenuId }
    else { $null }

    if ([string]::IsNullOrWhiteSpace($menuId)) { return }

    $type = if ($p -is [System.Collections.IDictionary]) { $p['Type'] }
    elseif ($null -ne $p.PSObject -and $p.PSObject.Properties['Type']) { $p.Type }
    else { 'PARTIAL' }

    $titleKey = if ($p -is [System.Collections.IDictionary]) { $p['TitleKey'] }
    elseif ($null -ne $p.PSObject -and $p.PSObject.Properties['TitleKey']) { $p.TitleKey }
    else { $null }

    if ([string]::IsNullOrWhiteSpace($titleKey)) { return }

    $isFull = ($type -eq 'FULL')

    if ($null -eq $routerState) {
        $routerState = @{ Cursor = 0; LastCursor = -1; RawOptions = @() }
    }
    if ($null -eq $routerState.RawOptions) {
        $routerState.RawOptions = @()
    }

    $rawOpts = @($routerState.RawOptions)
    $cursorIdx = if ($null -ne $routerState.Cursor) { $routerState.Cursor } else { 0 }
    $lastIdx = if ($null -ne $routerState.LastCursor) { $routerState.LastCursor } else { -1 }

    # Lazy hydration delegated to Resolver listener (SRP)

    # Supressão de Duplicatas
    $dupKey = "${menuId}|${cursorIdx}|${lastIdx}|${rawOpts.Count}"
    $nowTs = [DateTime]::Now
    if ($Script:RecentRedraws.ContainsKey($dupKey)) {
        $prev = $Script:RecentRedraws[$dupKey]
        if (($nowTs - $prev).TotalMilliseconds -lt 250) { return }
    }
    $Script:RecentRedraws[$dupKey] = $nowTs

    $vmStateSnapshot = Get-ScapeColdState
    $hydratedOpts = Update-ScapeMenuViewModel -MenuId $menuId -RawOptions $rawOpts -StateSnapshot $vmStateSnapshot

    $frameStyle = if ($vmStateSnapshot -and $vmStateSnapshot.ContainsKey('FrameStyle')) { [string]$vmStateSnapshot['FrameStyle'] } else { $null }
    $iconLevel = if ($vmStateSnapshot -and $vmStateSnapshot.ContainsKey('IconLevel')) { [int]$vmStateSnapshot['IconLevel'] } else { 0 }

    Write-ScapeMenuBuffer -Options $hydratedOpts -CursorIndex $cursorIdx -LastCursorIndex $lastIdx -TitleKey $titleKey -FullRedraw $isFull -FrameStyle $frameStyle -IconLevel $iconLevel
}

function Invoke-ScapeTransientEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -match '^(UI_REDRAW_REQUEST|RENDER_OBSERVED|ROUTER_STOP|SYSTEM_CRASH|TREE_UPDATE|ACTION_SCREEN_UPDATE|LISTENER_FAULT|LOGGER_INITIALIZED|MODULE_LOADED|ASSET_READY|RESOLVER_REDRAW_SYNC|LAYER_IGNITION|CAPABILITY_FAULT|COMPLIANCE_REJECTION|LOG_ROTATED|LOGGER_HANDOVER_CHILD|LOGGER_HANDOVER_FALLBACK|LANG_SWITCH|LANG_FLUSHED|LANG_SWITCH_FAILED|MENU_LANGUAGE_SWITCH|PIPELINE_DROPPED|SYSTEM_READY|MODULE_WAKED)$') { return }

    $shouldFilter = $false
    try {
        $cfg = Get-ScapeConstant -Path "infrastructure::Logger" -Fallback @{}
        $minLevelName = $cfg["DEFAULT_LEVEL_NAME"] -or "INFO"

        if ($null -eq $minLevelName) { $minLevelName = "INFO" }

        if ($env:SCAPE_LOG_LEVEL) {
            $minLevelName = $env:SCAPE_LOG_LEVEL
        }
        else {
            try {
                $cs = Get-ScapeColdState
                if ($cs -and $cs.ContainsKey('LOG_LEVEL_OVERRIDE')) { $minLevelName = $cs['LOG_LEVEL_OVERRIDE'] }
            }
            catch { }
        }

        $severityMap = @{ TRACE = 0; DEBUG = 1; INFO = 2; WARN = 3; ERROR = 4; FATAL = 5; METRIC = -1 }
        $minValue = $severityMap[$minLevelName] -or 2
        $currValue = $severityMap[$IncomingEventData.Severity -replace '^LOG_', ''] -or 2

        $shouldFilter = ($IncomingEventData.Severity -eq 'METRIC') -or ($currValue -lt $minValue)
    }
    catch {
        $shouldFilter = $true
    }

    if ($shouldFilter) { return }

    $now = [DateTime]::Now
    $evtType = [string]$IncomingEventData.Type
    $isHelpLike = ($evtType -match '^(HINT|UI_HINT)$')
    $isActionLike = ($evtType -match '^(SYSTEM|SYSTEM_.*|INFO|WARN|ERROR|FATAL|ROUTER_FATAL|LAZY_WAKEUP|SYS_CORE|STATE_MUTATED|UI_SELECTION)$')

    if ($isHelpLike -and $now -lt $Script:TransientState.HoldUntil) { return }

    if (Get-Command Convert-ScapeObservedEventData -ErrorAction SilentlyContinue) {
        $processed = Convert-ScapeObservedEventData -IncomingEventData $IncomingEventData
        if ($processed.ShouldProcess -and $processed.RenderConfig.ShouldRender) {
            if ($isActionLike) {
                $holdMs = Get-ScapeConstant -Path "ui::Feedback::TransientActionHoldMs" -Fallback 1800
                $Script:TransientState.HoldUntil = $now.AddMilliseconds([int]$holdMs)
            }
            $processed.RenderConfig.HoldUntil = $Script:TransientState.HoldUntil
            Write-ScapeTransientView -RenderConfig $processed.RenderConfig
        }
    }
}

function Get-ScapePayloadField {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Payload,
        [Parameter(Mandatory = $true)][string]$Key,
        $Fallback = $null
    )

    if ($Payload -is [hashtable]) {
        if ($Payload.ContainsKey($Key)) { return $Payload[$Key] }
        return $Fallback
    }
    if ($null -ne $Payload.PSObject -and $Payload.PSObject.Properties[$Key]) {
        return $Payload.$Key
    }
    return $Fallback
}



function Invoke-ScapeSelectionEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -ne 'UI_SELECTION') { return }

    $p = $IncomingEventData.Payload
    if ($null -eq $p) { return }

    $action    = if ($p -is [hashtable]) { $p['Action'] }      elseif ($null -ne $p.PSObject) { $p.Action }      else { $null }
    $menuId    = if ($p -is [hashtable]) { $p['MenuId'] }      elseif ($null -ne $p.PSObject) { $p.MenuId }      else { $null }
    $selId     = if ($p -is [hashtable]) { $p['SelectionId'] } elseif ($null -ne $p.PSObject) { $p.SelectionId } else { $null }
    $cursorIdx = if ($p -is [hashtable]) { $p['Cursor'] }      elseif ($null -ne $p.PSObject) { $p.Cursor }      else { 0 }
    if ($null -eq $cursorIdx) { $cursorIdx = 0 }

    $menuOpts = Get-ScapeConstant -Path "navigation::$menuId"
    $routeDef = $null

    if ($menuOpts -and $menuOpts.Items) {
        $routeDef = $menuOpts.Items | Where-Object {
            $optId = if ($_ -is [hashtable]) { $_['Id'] } else { $_.Id }
            $optId -eq $selId
        } | Select-Object -First 1
    }

    if ($action -eq 'TRIGGER' -and $routeDef) {
        $payloadDef = if ($routeDef -is [hashtable]) { $routeDef['Payload'] } else { $routeDef.Payload }
        $target     = Get-ScapePayloadField -Payload $payloadDef -Key 'Target'
        $task       = Get-ScapePayloadField -Payload $payloadDef -Key 'Task'

        if (-not [string]::IsNullOrWhiteSpace($target)) {
            # MVVM/SRP: delegate to ActionManager — single dispatch path
            if (Get-Command Invoke-ScapeActionDispatcher -ErrorAction SilentlyContinue) {
                Invoke-ScapeActionDispatcher -Target $target -Task $task -PayloadDef $payloadDef -MenuId $menuId -Cursor ([int]$cursorIdx) | Out-Null
            }
        }
    }
    elseif ($action -eq 'MUTATE' -and $routeDef) {
        $payloadDef       = if ($routeDef -is [hashtable]) { $routeDef['Payload'] } else { $routeDef.Payload }
        $mutationDirection = if ($p -is [hashtable]) { $p['MutationDirection'] } elseif ($null -ne $p.PSObject) { $p.MutationDirection } else { $null }
        if ([string]::IsNullOrWhiteSpace($mutationDirection)) { $mutationDirection = 'NEXT' }

        if (Get-Command Invoke-ScapeStateMutation -ErrorAction SilentlyContinue) {
            $mutated = Invoke-ScapeStateMutation -MenuId $menuId -SelectionId $selId -Payload $payloadDef -Direction $mutationDirection

            if ($mutated) {
                Publish-ScapeEvent -Type "STATE_MUTATED" -Severity "INFO" -Payload @{
                    MenuId = $menuId; SelectionId = $selId; Timestamp = [DateTime]::Now
                }
            }
        }
    }
}

# ==============================================================================
# CORE OBSERVER EXPORTS
# ==============================================================================

function Request-ScapeRedraw {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $MenuId,
        [Parameter(Mandatory = $true)] [string] $Type,
        [Parameter(Mandatory = $true)] [hashtable] $RouterState,
        [Parameter(Mandatory = $true)] [string] $TitleKey
    )

    $now = [DateTime]::Now
    $elapsed = ($now - $Script:RedrawDebounce.LastRequest).TotalMilliseconds
    if ($elapsed -lt $Script:RedrawDebounce.MinIntervalMs) {
        $Script:RedrawDebounce.RequestQueue = @(@{ MenuId = $MenuId; Type = $Type; RouterState = $RouterState; TitleKey = $TitleKey })
        return
    }
    $Script:RedrawDebounce.LastRequest = $now

    if ($Script:RedrawDebounce.IsRendering) {
        $Script:RedrawDebounce.RequestQueue += @{ MenuId = $MenuId; Type = $Type; RouterState = $RouterState; TitleKey = $TitleKey }
        return
    }
    $Script:RedrawDebounce.IsRendering = $true

    try {
        $viewportStart = if ($RouterState.ContainsKey('ViewportStart')) { $RouterState['ViewportStart'] } else { 0 }
        $stateHash = "${MenuId}|${Type}|${RouterState.Cursor}|${RouterState.LastCursor}|${RouterState.RawOptions.Count}|${viewportStart}"

        $Script:LastStateHash = $stateHash

        Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{
            MenuId        = $MenuId
            Type          = $Type
            State         = $RouterState
            TitleKey      = $TitleKey
            ViewportStart = $viewportStart
        }
    }
    finally {
        $Script:RedrawDebounce.IsRendering = $false
        if ($Script:RedrawDebounce.RequestQueue.Count -gt 0) {
            $next = $Script:RedrawDebounce.RequestQueue[0]
            if ($Script:RedrawDebounce.RequestQueue.Count -gt 1) {
                $Script:RedrawDebounce.RequestQueue = @($Script:RedrawDebounce.RequestQueue[1..($Script:RedrawDebounce.RequestQueue.Count - 1)])
            }
            else {
                $Script:RedrawDebounce.RequestQueue = @()
            }
            Request-ScapeRedraw @next
        }
    }
}

function Initialize-ScapeStateObserver {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string] $FilterPattern = '*',
        [Parameter()] [switch] $AutoRegister
    )
    process {
        if ($Script:ObserverInitialized) { return @{} }

        if ($PSCmdlet.ShouldProcess("State Observer", "Initialize with pattern $FilterPattern")) {
            $config = @{
                FilterPattern      = $FilterPattern
                IsActive           = $false
                RegisteredHandlers = @()
                LastRendered       = @()
            }

            if ($AutoRegister -and (Get-Command Register-ScapeEventListener -ErrorAction SilentlyContinue)) {

                $reg1 = Register-ScapeEventListener -EventMatch "TREE_UPDATE" -Action { Invoke-ScapeTreeUpdateEvent -IncomingEventData $args[0] }
                $reg2 = Register-ScapeEventListener -EventMatch "UI_REDRAW_REQUEST" -Action { Invoke-ScapeRedrawRequestEvent -IncomingEventData $args[0] }
                $reg3 = Register-ScapeEventListener -EventMatch "^(PROGRESS|SYSTEM|SYSTEM_.*|SYS_CORE|LAZY_WAKEUP|HINT|UI_HINT|INFO|WARN|ERROR|FATAL|ROUTER_FATAL|STATE_MUTATED|UI_SELECTION)$" -Action { Invoke-ScapeTransientEvent -IncomingEventData $args[0] }
                $reg4 = Register-ScapeEventListener -EventMatch "UI_SELECTION" -Action { Invoke-ScapeSelectionEvent -IncomingEventData $args[0] }
                $reg5 = Register-ScapeEventListener -EventMatch "ACTION_SCREEN_UPDATE" -Action { Invoke-ScapeActionScreenEvent -IncomingEventData $args[0] }

                $config.IsActive = $true
                $Script:ObserverInitialized = $true
                $config.RegisteredHandlers += $reg1, $reg2, $reg3, $reg4, $reg5
            }
            return $config
        }
        return @{}
    }
}

function Convert-ScapeObservedEventData {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)]$IncomingEventData, [Parameter()][string]$FilterPattern = '*')
    process {
        $shouldProcess = $true
        if ($FilterPattern -ne '*' -and $IncomingEventData.Type -notlike $FilterPattern) { $shouldProcess = $false }

        $renderConfig = @{ ShouldRender = $false }
        if ($shouldProcess -and (Get-Command Convert-ScapeEventDataToRender -ErrorAction SilentlyContinue)) {
            $renderConfig = Convert-ScapeEventDataToRender -IncomingEventData $IncomingEventData
        }

        $priority = 99
        if ($renderConfig -is [hashtable] -and $renderConfig.ContainsKey('Priority')) { $priority = $renderConfig['Priority'] }

        return @{
            ShouldProcess     = $shouldProcess;
            IncomingEventData = $IncomingEventData;
            RenderConfig      = $renderConfig;
            Priority          = $priority
        }
    }
}

function Invoke-ScapeEventBatchProcessing {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param([Parameter(Mandatory = $true)][array]$EventCollection, [Parameter()][string]$FilterPattern = '*', [Parameter()][int]$MaxPriority = 3)
    process {
        $results = New-Object System.Collections.Generic.List[hashtable]
        foreach ($evt in $EventCollection) {
            $processed = Convert-ScapeObservedEventData -IncomingEventData $evt -FilterPattern $FilterPattern
            if ($processed.ShouldProcess -and $processed.RenderConfig.ShouldRender -and $processed.Priority -le $MaxPriority) {
                $results.Add($processed.RenderConfig)
            }
        }
        return [System.Object[]]($results.ToArray() | Sort-Object Priority)
    }
}

function Remove-ScapeStateObserver {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    param([Parameter(Mandatory = $true)][array]$RegisteredHandlers)
    process {
        if ($PSCmdlet.ShouldProcess("State Observer", "Remove $($RegisteredHandlers.Count) handlers")) {
            $cleanup = New-Object System.Collections.Generic.List[hashtable]
            foreach ($handler in $RegisteredHandlers) {
                if (Get-Command Unregister-ScapeEventListener -ErrorAction SilentlyContinue) {
                    $result = Unregister-ScapeEventListener -Handler $handler
                    $cleanup.Add($result)
                }
            }
            return [System.Object[]]$cleanup.ToArray()
        }
        return [System.Object[]]@()
    }
}