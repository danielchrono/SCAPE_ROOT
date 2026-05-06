<#
.SYNOPSIS
    Domain: Presentation\StateObserver
    Module: Scape.Presentation.StateObserver
    Architecture: Pure Event Listener | Coordinates Rendering | Exposes Request-ScapeRedraw
#>
[CmdletBinding()] param()

$Script:LastStateHash = ""

# =============================================================================
# FUNÇÃO PÚBLICA — chamada pelo Router
# =============================================================================
function Request-ScapeRedraw {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $MenuId,
        [Parameter(Mandatory = $true)] [string] $Type,
        [Parameter(Mandatory = $true)] [hashtable] $RouterState,
        [Parameter(Mandatory = $true)] [string] $TitleKey
    )
    $stateHash = "$MenuId|$Type|$($RouterState.Cursor)|$($RouterState.LastCursor)|$($RouterState.RawOptions.Count)"
    if ($stateHash -eq $Script:LastStateHash) { return }
    $Script:LastStateHash = $stateHash

    Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{
        MenuId   = $MenuId
        Type     = $Type
        State    = $RouterState
        TitleKey = $TitleKey
    }
}

# =============================================================================
# INICIALIZAÇÃO DO OBSERVER (com listener de redraw corrigido)
# =============================================================================
function Initialize-ScapeStateObserver {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string] $FilterPattern = '*',
        [Parameter()] [switch] $AutoRegister
    )
    process {
        if ($PSCmdlet.ShouldProcess("State Observer", "Initialize with pattern $FilterPattern")) {
            $config = @{
                FilterPattern      = $FilterPattern
                IsActive           = $false
                RegisteredHandlers = @()
                LastRendered       = @()
            }

            if ($AutoRegister -and (Get-Command Register-ScapeEventListener -ErrorAction SilentlyContinue)) {

                # HANDLER 1: REDRAW DE MENU (escuta UI_REDRAW_REQUEST)
                $redrawHandler = {
                    param($IncomingEventData)
                    if ($IncomingEventData.Type -ne 'UI_REDRAW_REQUEST' -or $null -eq $IncomingEventData.Payload) { return }

                    try {
                        $p = $IncomingEventData.Payload
                        $menuId = $p['MenuId']
                        if ([string]::IsNullOrWhiteSpace($menuId)) { return }

                        $type = $p['Type']
                        $isFull = ($type -eq 'FULL')

                        $routerState = $p['State']
                        $rawOpts = if ($null -ne $routerState.RawOptions) { @($routerState.RawOptions) } else { @() }
                        $cursorIdx = if ($null -ne $routerState.Cursor) { $routerState.Cursor } else { 0 }
                        $lastIdx = if ($null -ne $routerState.LastCursor) { $routerState.LastCursor } else { -1 }

                        $hydratedOpts = Update-ScapeMenuViewModel -MenuId $menuId -RawOptions $rawOpts
                        $titleKey = $p['TitleKey']
                        if ([string]::IsNullOrWhiteSpace($titleKey)) {
                            throw "UI_REDRAW_REQUEST missing TitleKey for menu $menuId"
                        }

                        if ($isFull -or $hydratedOpts.Count -gt 0) {
                            Write-ScapeMenuBuffer -Options $hydratedOpts -CursorIndex $cursorIdx -LastCursorIndex $lastIdx -TitleKey $titleKey -FullRedraw $isFull
                        }

                        Publish-ScapeEvent -Type "RENDER_OBSERVED" -Severity "TRACE" -Payload @{
                            Timestamp    = [DateTime]::Now
                            MenuId       = $menuId
                            OptionsCount = $hydratedOpts.Count
                        }
                    }
                    catch {
                        Publish-ScapeEvent -Type "REDRAW_FAULT" -Severity "ERROR" -Payload @{
                            MenuId = $menuId
                            Error  = $_.Exception.Message
                            Stack  = $_.ScriptStackTrace
                        }
                    }
                }

                # HANDLER 2: STATUS / TRANSIENTES
                $transientHandler = {
                    param($evt)
                    if ($evt.Type -match '^(UI_REDRAW_REQUEST|RENDER_OBSERVED|ROUTER_STOP|SYSTEM_CRASH)$') { return }
                    if ($evt.Severity -match '^(DEBUG|TRACE|METRIC)$') { return }

                    if (Get-Command Convert-ScapeObservedEventData -ErrorAction SilentlyContinue) {
                        $processed = Convert-ScapeObservedEventData -IncomingEventData $evt
                        if ($processed.ShouldProcess -and $processed.RenderConfig.ShouldRender) {
                            Write-ScapeTransientView -RenderConfig $processed.RenderConfig
                        }
                    }
                }

                # HANDLER 3: AÇÕES (TRIGGER / MUTATE)
                $selectionHandler = {
                    param($IncomingEventData)
                    if ($IncomingEventData.Type -eq 'UI_SELECTION') {
                        $p = $IncomingEventData.Payload
                        if ($null -eq $p) { return }

                        $action = $p['Action']
                        $menuId = $p['MenuId']
                        $selId = $p['SelectionId']

                        $routeMap = Get-ScapeConstant -Path "navigation::Navigation"
                        $menuOpts = $routeMap[$menuId]
                        $routeDef = $null
                        if ($menuOpts) {
                            $routeDef = $menuOpts | Where-Object {
                                $optId = if ($_ -is [hashtable]) { $_['Id'] } else { $_.Id }
                                $optId -eq $selId
                            } | Select-Object -First 1
                        }

                        if ($action -eq 'TRIGGER' -and $routeDef) {
                            $payloadDef = if ($routeDef -is [hashtable]) { $routeDef['Payload'] } else { $routeDef.Payload }
                            $target = if ($payloadDef -is [hashtable]) { $payloadDef['Target'] } else { $payloadDef.Target }
                            $task = if ($payloadDef -is [hashtable]) { $payloadDef['Task'] } else { $payloadDef.Task }

                            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "DEBUG" -Payload "Trigger acionado: $target"

                            if ($target -eq 'Scape.Forge.Deployer' -and (Get-Command Invoke-ScapeDeployWorkflow -ErrorAction SilentlyContinue)) {
                                Invoke-ScapeDeployWorkflow -Task $task
                            }
                            elseif ($target -eq 'Scape.Analysis.Parser.Core' -and (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue)) {
                                Invoke-ScapeTargetedParsing -Payload $payloadDef
                            }
                            elseif ($target -eq 'Scape.Presentation.FilePicker' -and (Get-Command Invoke-ScapeDirectoryPicker -ErrorAction SilentlyContinue)) {
                                Invoke-ScapeDirectoryPicker -Payload $payloadDef
                            }
                        }
                        elseif ($action -eq 'MUTATE' -and $routeDef) {
                            $payloadDef = if ($routeDef -is [hashtable]) { $routeDef['Payload'] } else { $routeDef.Payload }
                            if (Get-Command Invoke-ScapeStateMutation -ErrorAction SilentlyContinue) {
                                $mutated = Invoke-ScapeStateMutation -MenuId $menuId -SelectionId $selId -Payload $payloadDef
                                if ($mutated) {
                                    Publish-ScapeEvent -Type "STATE_MUTATED" -Severity "INFO" -Payload @{
                                        MenuId      = $menuId
                                        SelectionId = $selId
                                        Timestamp   = [DateTime]::Now
                                    }
                                    if ($menuId -eq 'SettingsMenu' -or $menuId -eq 'ThemeMenu') {
                                        Request-ScapeRedraw -MenuId $menuId -Type 'FULL' -RouterState @{ Cursor = 0; LastCursor = -1; RawOptions = @() } -TitleKey $menuId
                                    }
                                }
                            }
                        }
                    }
                }

                # REGISTRO
                $reg1 = Register-ScapeEventListener -EventMatch "UI_REDRAW_REQUEST" -Action $redrawHandler
                $reg2 = Register-ScapeEventListener -EventMatch ".*"                 -Action $transientHandler
                $reg3 = Register-ScapeEventListener -EventMatch "UI_SELECTION"        -Action $selectionHandler

                $config.IsActive = $true
                $config.RegisteredHandlers += $reg1, $reg2, $reg3
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
            ShouldProcess     = $shouldProcess
            IncomingEventData = $IncomingEventData
            RenderConfig      = $renderConfig
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
