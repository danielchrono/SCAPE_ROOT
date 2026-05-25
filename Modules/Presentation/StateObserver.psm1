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

    # LAZY HYDRATION
    try {
        $navData = Get-ScapeConstant -Path "navigation::$menuId" -Fallback @{}
        $navItems = if ($navData -is [hashtable] -and $navData.ContainsKey('Items')) { @($navData['Items']) }
        elseif ($null -ne $navData.PSObject -and $navData.PSObject.Properties['Items']) { @($navData.Items) }
        else { @() }

        $layers = @($navItems | ForEach-Object {
                if ($_ -is [hashtable]) { $_['Layer'] }
                elseif ($null -ne $_.PSObject) { $_.Layer }
                else { $null }
            } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

        foreach ($domain in $layers) {
            if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) {
                Invoke-ScapeWakeAssets -Domain $domain | Out-Null
            }
        }
    }
    catch { }

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

    if ($IncomingEventData.Type -match '^(UI_REDRAW_REQUEST|RENDER_OBSERVED|ROUTER_STOP|SYSTEM_CRASH|TREE_UPDATE)$') { return }

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

function Invoke-ScapeCloudSyncPreparation {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $state = Get-ScapeColdState
    if ($null -eq $state) { return $false }

    $flagKeys = @($state.Keys | Where-Object { $_ -match '^RC_' } | Sort-Object)
    $flags = @{}
    foreach ($flagKey in $flagKeys) {
        $flags[$flagKey] = $state[$flagKey]
    }

    Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{
        Key   = "RC_DEFAULTS_TITLE"
        Flags = $flags
        Count = $flags.Count
    }
    return $true
}

function Resolve-ScapeActiveTarget {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $state = Get-ScapeColdState
    if ($state -and $state.ContainsKey('ActiveTarget') -and -not [string]::IsNullOrWhiteSpace([string]$state['ActiveTarget'])) {
        return [string]$state['ActiveTarget']
    }

    $resolvedTarget = $null

    if (Get-Command Get-ScapePhysicalTarget -ErrorAction SilentlyContinue) {
        $physicalTargets = @(Get-ScapePhysicalTarget)
        if ($physicalTargets.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$physicalTargets[0].DeviceID)) {
            $resolvedTarget = [string]$physicalTargets[0].DeviceID
        }
    }

    if ([string]::IsNullOrWhiteSpace($resolvedTarget)) {
        try {
            $volume = Get-Volume | Where-Object DriveLetter | Select-Object -First 1
            if ($volume -and $volume.DriveLetter) {
                $resolvedTarget = ('{0}:\' -f $volume.DriveLetter)
            }
        }
        catch { }
    }

    if ([string]::IsNullOrWhiteSpace($resolvedTarget) -and $state -and $state.ContainsKey('ROOT')) {
        $resolvedTarget = [string]$state['ROOT']
    }

    if (-not [string]::IsNullOrWhiteSpace($resolvedTarget)) {
        Update-ScapeColdState -NewProperties @{ ActiveTarget = $resolvedTarget } | Out-Null
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{
            Key    = "MENU_DRIVE_TARGET_LABEL"
            Tokens = @($resolvedTarget)
        }
    }

    return $resolvedTarget
}

function Invoke-ScapeSelectionTriggerAction {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Task,
        [hashtable]$PayloadDef,
        [string]$MenuId
    )

    switch ($Target) {
        'Scape.Forge.Deployer' {
            if (Get-Command Invoke-ScapeDeployWorkflow -ErrorAction SilentlyContinue) {
                Invoke-ScapeDeployWorkflow -Task $Task
                return $true
            }
            break
        }
        'Scape.Core.Settings' {
            if ($Task -eq 'RESET' -and (Get-Command Reset-ScapeSettingToFactory -ErrorAction SilentlyContinue)) {
                Reset-ScapeSettingToFactory | Out-Null
                return $true
            }
            break
        }
        'Scape.Analysis.Parser.Core' {
            Resolve-ScapeActiveTarget | Out-Null
            if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) {
                Invoke-ScapeTargetedParsing -Payload $PayloadDef
                return $true
            }
            break
        }
        'Scape.Analysis.Carving.Carver' {
            Resolve-ScapeActiveTarget | Out-Null
            if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) {
                Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "CARVING" }
                return $true
            }
            break
        }
        'Scape.Analysis.FS.Abstraction' {
            Resolve-ScapeActiveTarget | Out-Null
            if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) {
                Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "FS_ABSTRACTION" }
                return $true
            }
            break
        }
        'Scape.Analysis.FS.NTFS' {
            Resolve-ScapeActiveTarget | Out-Null
            if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) {
                Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "NTFS" }
                return $true
            }
            break
        }
        'Scape.Analysis.FS.PartitionTable' {
            Resolve-ScapeActiveTarget | Out-Null
            if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) {
                Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "PARTITION_TABLE" }
                return $true
            }
            break
        }
        'Scape.Infrastructure.Telemetry' {
            if (Get-Command Invoke-ScapeTelemetryWorkflow -ErrorAction SilentlyContinue) {
                $taskName = if ([string]::IsNullOrWhiteSpace($Task)) { 'TELEMETRY' } else { $Task }
                Invoke-ScapeTelemetryWorkflow -Task $taskName
                return $true
            }
            break
        }
        'Scape.Extensions.Network' {
            if (Get-Command Find-ScapeNetworkNode -ErrorAction SilentlyContinue) {
                Find-ScapeNetworkNode | Out-Null
                return $true
            }
            break
        }
        'Scape.Presentation.FilePicker' {
            if (Get-Command Invoke-ScapeDirectoryPicker -ErrorAction SilentlyContinue) {
                Invoke-ScapeDirectoryPicker -Payload $PayloadDef
                return $true
            }
            break
        }
        'Scape.Presentation.Theme' {
            if ($Task -eq 'PROCEDURAL' -and (Get-Command Invoke-ScapeProceduralTheme -ErrorAction SilentlyContinue)) {
                Invoke-ScapeProceduralTheme
                # Preserve current cursor position instead of resetting to 0
                $cursorIdx = if ($p -is [hashtable]) { $p['Cursor'] } elseif ($null -ne $p.PSObject) { $p.Cursor } else { 0 }
                if ($null -eq $cursorIdx) { $cursorIdx = 0 }
                $menuOpts = Get-ScapeConstant -Path "navigation::$MenuId"
                $menuTitle = if ($menuOpts -and $menuOpts.Items) { $menuOpts.TitleKey } else { $MenuId }
                $menuItems = if ($menuOpts -and $menuOpts.Items) { @($menuOpts.Items) } else { @() }
                Request-ScapeRedraw -MenuId $MenuId -Type 'FULL' -RouterState @{ Cursor = [int]$cursorIdx; LastCursor = -1; RawOptions = $menuItems } -TitleKey $menuTitle
                return $true
            }
            break
        }
        'Scape.Infrastructure.Audit' {
            if (Get-Command Initialize-ScapeAudit -ErrorAction SilentlyContinue) {
                Initialize-ScapeAudit | Out-Null
                return $true
            }
            break
        }
        'Scape.Infrastructure.Compliance' {
            if (Get-Command Initialize-ScapeCompliance -ErrorAction SilentlyContinue) {
                Initialize-ScapeCompliance | Out-Null
                return $true
            }
            break
        }
        'Scape.Infrastructure.Pipeline' {
            if (Get-Command Initialize-ScapePipeline -ErrorAction SilentlyContinue) {
                Initialize-ScapePipeline | Out-Null
                return $true
            }
            break
        }
        'Scape.Acquisition.Selection' {
            if (Get-Command Get-ScapePhysicalTarget -ErrorAction SilentlyContinue) {
                $targets = @(Get-ScapePhysicalTarget)
                Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{
                    Key     = "INVENTORY_PHYSICAL_DISKS"
                    Targets = $targets
                }
                return $true
            }
            break
        }
        'Scape.Acquisition.Resilience' {
            $targetId = Resolve-ScapeActiveTarget
            if (-not [string]::IsNullOrWhiteSpace($targetId)) {
                return $true
            }
            break
        }
        'Scape.Extensions.CloudSync' {
            if (Get-Command Invoke-ScapeCloudSyncPreparation -ErrorAction SilentlyContinue) {
                return (Invoke-ScapeCloudSyncPreparation)
            }
            break
        }
    }

    Publish-ScapeEvent -Type "SYSTEM_WARN" -Severity "WARN" -Payload @{
        Key    = "ORCH_MISSING_BINDING"
        Tokens = @($Target)
    }
    return $false
}

function Invoke-ScapeSelectionEvent {
    [CmdletBinding()]
    param($IncomingEventData)

    if ($IncomingEventData.Type -ne 'UI_SELECTION') { return }

    $p = $IncomingEventData.Payload
    if ($null -eq $p) { return }

    $action = if ($p -is [hashtable]) { $p['Action'] } elseif ($null -ne $p.PSObject) { $p.Action } else { $null }
    $menuId = if ($p -is [hashtable]) { $p['MenuId'] } elseif ($null -ne $p.PSObject) { $p.MenuId } else { $null }
    $selId = if ($p -is [hashtable]) { $p['SelectionId'] } elseif ($null -ne $p.PSObject) { $p.SelectionId } else { $null }

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
        $target = Get-ScapePayloadField -Payload $payloadDef -Key 'Target'
        $task = Get-ScapePayloadField -Payload $payloadDef -Key 'Task'
        if (-not [string]::IsNullOrWhiteSpace($target)) {
            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{
                TriggerTarget = $target
                TriggerTask   = $task
                SelectionId   = $selId
            }
            Invoke-ScapeSelectionTriggerAction -Target $target -Task $task -PayloadDef $payloadDef -MenuId $menuId | Out-Null
        }
    }
    elseif ($action -eq 'MUTATE' -and $routeDef) {
        $payloadDef = if ($routeDef -is [hashtable]) { $routeDef['Payload'] } else { $routeDef.Payload }
        $mutationDirection = if ($p -is [hashtable]) { $p['MutationDirection'] } elseif ($null -ne $p.PSObject) { $p.MutationDirection } else { $null }
        $cursorIdx = if ($p -is [hashtable]) { $p['Cursor'] } elseif ($null -ne $p.PSObject) { $p.Cursor } else { 0 }
        if ([string]::IsNullOrWhiteSpace($mutationDirection)) { $mutationDirection = 'NEXT' }
        if ($null -eq $cursorIdx) { $cursorIdx = 0 }

        if (Get-Command Invoke-ScapeStateMutation -ErrorAction SilentlyContinue) {
            $mutated = Invoke-ScapeStateMutation -MenuId $menuId -SelectionId $selId -Payload $payloadDef -Direction $mutationDirection

            if ($mutated) {
                Publish-ScapeEvent -Type "STATE_MUTATED" -Severity "INFO" -Payload @{
                    MenuId = $menuId; SelectionId = $selId; Timestamp = [DateTime]::Now
                }

                $menuTitle = if ($menuOpts -and $menuOpts.Items) { $menuOpts.TitleKey } else { $menuId }
                $menuItems = if ($menuOpts -and $menuOpts.Items) { @($menuOpts.Items) } else { @() }
                Request-ScapeRedraw -MenuId $menuId -Type 'FULL' -RouterState @{ Cursor = [int]$cursorIdx; LastCursor = -1; RawOptions = $menuItems } -TitleKey $menuTitle
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

                $config.IsActive = $true
                $Script:ObserverInitialized = $true
                $config.RegisteredHandlers += $reg1, $reg2, $reg3, $reg4
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