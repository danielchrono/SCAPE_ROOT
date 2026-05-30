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
    IsRendering = $false
    RequestQueue = @()
    LastRouterState = $null
    LastTitleKey = $null
    LastViewportStart = -1
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
        $routerState = @{ Cursor = $null; LastCursor = -1; RawOptions = @() }
    }
    if ($null -eq $routerState.RawOptions) {
        $routerState.RawOptions = @()
    }

    $rawOpts = @($routerState.RawOptions)
    $cursorIdx = $routerState.Cursor
    $lastIdx = if ($null -ne $routerState.LastCursor) { $routerState.LastCursor } else { -1 }

    $vmStateSnapshot = Get-ScapeColdState
    $hydratedOpts = Update-ScapeMenuViewModel -MenuId $menuId -RawOptions $rawOpts -StateSnapshot $vmStateSnapshot

    $frameStyle = if ($vmStateSnapshot -and $vmStateSnapshot.ContainsKey('FrameStyle')) { [string]$vmStateSnapshot['FrameStyle'] } else { $null }
    $iconLevel = if ($vmStateSnapshot -and $vmStateSnapshot.ContainsKey('IconLevel')) { [int]$vmStateSnapshot['IconLevel'] } else { 0 }

    # Viewport Calculation (Moved from Renderer for Pure View)
    $dims = Get-ScapeConsoleDimension -WithMargins
    $layout = Get-ScapeConstant -Path "ui::Layout"
    $safeDimsHeight = [Math]::Max(10, $dims.Height - 1)
    $itemCount = $hydratedOpts.Count
    $bannerVariant = if (Get-Command Get-ScapeBannerVariant -ErrorAction SilentlyContinue) {
        Get-ScapeBannerVariant -ConsoleHeight $safeDimsHeight -ItemCount $itemCount -HeaderHeight $layout.HeaderHeight
    } else {
        if (($itemCount + $layout.HeaderHeight) -gt $safeDimsHeight) { 'Compact' } else { 'Standard' }
    }
    $artMap = Get-ScapeConstant -Path "ui::Art::Variants"
    $artKey = 'SmallLogo'
    if ($artMap -and $artMap.ContainsKey($bannerVariant)) { $artKey = $artMap[$bannerVariant] }
    $rawArt = Get-ScapeConstant -Path "ui::Art::$artKey"
    $bannerLineCount = if ([string]::IsNullOrWhiteSpace($rawArt)) { 0 } else { ($rawArt -split '\r?\n' | Where-Object { $_.Trim() }).Count }
    $availableHeight = [Math]::Max(1, $safeDimsHeight - $bannerLineCount - $layout.Padding - 5)

    $viewportRange = $null
    if (Get-Command Get-ScapeViewportRange -ErrorAction SilentlyContinue) {
        $viewportRange = Get-ScapeViewportRange -TotalItems $itemCount -CursorIndex $cursorIdx -AvailableHeight $availableHeight
    }
    if ($null -eq $viewportRange) {
        $viewportRange = @{ Start = 0; End = [Math]::Min($itemCount, $availableHeight) }
    }
    
    $viewportStart = $viewportRange.Start
    $viewportEnd = $viewportRange.End
    
    if ($Script:RedrawDebounce.LastViewportStart -ne $viewportStart) {
        $isFull = $true
    }
    $Script:RedrawDebounce.LastViewportStart = $viewportStart
    
    $isDataMutated = ($type -eq 'DATA')
    $forceRowRedraw = ($isFull -or $isDataMutated)

    $lastIdx = if ($null -ne $Script:RedrawDebounce.LastCursorIndex) { $Script:RedrawDebounce.LastCursorIndex } else { -1 }

    Publish-ScapeEvent -Type "VIEW_MODEL_READY" -Severity "TRACE" -Payload @{
        Options = $hydratedOpts
        CursorIndex = $cursorIdx
        LastCursorIndex = $lastIdx
        ViewportStart = $viewportStart
        ViewportEnd = $viewportEnd
        TitleKey = $titleKey
        FullRedraw = $isFull
        ForceRowRedraw = $forceRowRedraw
        FrameStyle = $frameStyle
        IconLevel = $iconLevel
    }
    $Script:RedrawDebounce.LastCursorIndex = $cursorIdx
}

function Invoke-ScapeTransientEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -match '^(LAZY_WAKEUP|UI_REDRAW_REQUEST|RENDER_OBSERVED|ROUTER_STOP|SYSTEM_CRASH|TREE_UPDATE|ACTION_SCREEN_UPDATE|LISTENER_FAULT|LOGGER_INITIALIZED|MODULE_LOADED|ASSET_READY|RESOLVER_REDRAW_SYNC|LAYER_IGNITION|CAPABILITY_FAULT|COMPLIANCE_REJECTION|LOG_ROTATED|LOGGER_HANDOVER_CHILD|LOGGER_HANDOVER_FALLBACK|LANG_SWITCH|LANG_FLUSHED|LANG_SWITCH_FAILED|MENU_LANGUAGE_SWITCH|PIPELINE_DROPPED|SYSTEM_READY|MODULE_WAKED)$') { return }

    $now = [DateTime]::Now
    $evtType = [string]$IncomingEventData.Type
    $isHelpLike = ($evtType -match '^(HINT|UI_HINT)$')
    $isActionLike = ($evtType -match '^(SYSTEM|SYSTEM_.*|INFO|WARN|ERROR|FATAL|ROUTER_FATAL|SYS_CORE|STATE_MUTATED|UI_SELECTION)$')

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
    process {
        if ($null -ne $RouterState) {
            $Script:RedrawDebounce.LastRouterState = $RouterState
        }
        if ($null -ne $TitleKey) {
            $Script:RedrawDebounce.LastTitleKey = $TitleKey
        }

        $isFull = ($Type -eq 'FULL')
    foreach ($q in $Script:RedrawDebounce.RequestQueue) {
        if ($q.Type -eq 'FULL') { $isFull = $true; break }
    }
    $finalType = if ($isFull) { 'FULL' } else { 'PARTIAL' }

    $Script:RedrawDebounce.RequestQueue = @(@{ MenuId = $MenuId; Type = $finalType; RouterState = $RouterState; TitleKey = $TitleKey })

    if ($Script:RedrawDebounce.IsRendering) { return }
    $Script:RedrawDebounce.IsRendering = $true

    try {
        while ($Script:RedrawDebounce.RequestQueue.Count -gt 0) {
            $next = $Script:RedrawDebounce.RequestQueue[0]
            $Script:RedrawDebounce.RequestQueue = @() # Clear queue before dispatch

            $viewportStart = if ($next.RouterState.ContainsKey('ViewportStart')) { $next.RouterState['ViewportStart'] } else { 0 }
            
            Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{
                MenuId        = $next.MenuId
                Type          = $next.Type
                State         = $next.RouterState
                TitleKey      = $next.TitleKey
                ViewportStart = $viewportStart
            }
        }
    }
    finally {
        $Script:RedrawDebounce.IsRendering = $false
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
                $reg3 = Register-ScapeEventListener -EventMatch "^(PROGRESS|SYSTEM|SYSTEM_.*|SYS_CORE|HINT|UI_HINT|INFO|WARN|ERROR|FATAL|ROUTER_FATAL|STATE_MUTATED|UI_SELECTION)$" -Action { Invoke-ScapeTransientEvent -IncomingEventData $args[0] }
                $reg4 = Register-ScapeEventListener -EventMatch "UI_SELECTION" -Action { Invoke-ScapeSelectionEvent -IncomingEventData $args[0] }
                $reg5 = Register-ScapeEventListener -EventMatch "ACTION_SCREEN_UPDATE" -Action { Invoke-ScapeActionScreenEvent -IncomingEventData $args[0] }
                
                $reg6 = Register-ScapeEventListener -EventMatch "^(SETTING_MUTATED)$" -Action {
                    param($EventFrame)
                    $p = $EventFrame.Payload
                    $redrawType = 'PARTIAL'
                    if (Get-Command Test-ScapeRedrawScope -ErrorAction SilentlyContinue) {
                        $redrawType = Test-ScapeRedrawScope -MutationKey $p.Key
                    } else {
                        $fullKeys = Get-ScapeConstant -Path "ui::Redraw::DestructiveKeys" -Fallback @('ThemePersona', 'ColorMode', 'Capability_TrueColor', 'IconLevel', 'FrameStyle', 'ProgressStyle', 'CurrentLanguage')
                        if ($p.Key -in $fullKeys) { $redrawType = 'FULL' }
                    }
                    
                    $lastState = $Script:RedrawDebounce.LastRouterState
                    $lastTitle = $Script:RedrawDebounce.LastTitleKey
                    $st = Get-ScapeColdState
                    $menuId = if ($lastState) { $lastState.CurrentMenu } elseif ($st) { $st.CurrentMenu } else { $null }
                    
                    if ($menuId) {
                        $actualType = if ($redrawType -eq 'PARTIAL') { 'DATA' } else { $redrawType }
                        Request-ScapeRedraw -MenuId $menuId -Type $actualType -RouterState $lastState -TitleKey $lastTitle
                    }
                }

                $config.IsActive = $true
                $Script:ObserverInitialized = $true
                $config.RegisteredHandlers += $reg1, $reg2, $reg3, $reg4, $reg5, $reg6
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