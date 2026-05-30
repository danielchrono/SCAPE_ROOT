<#
.SYNOPSIS
    Domain: Core\ActionManager
    Module: Scape.Core.ActionManager
    Architecture: Registry-based Action Dispatcher | Functional Composition
    Description: Eliminates god-functions by mapping Target intents to pure handler functions.
                 Manages the lifecycle of an action execution visually, without scope leakage.
#>
[CmdletBinding()] param()

$Script:ActionRegistry = @{}

function Register-ScapeActionHandler {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][scriptblock]$Handler
    )
    process {
        $Script:ActionRegistry[$Target] = $Handler
    }
}

function Get-ScapeActionHandler {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Target)
    process {
        if ($Script:ActionRegistry.ContainsKey($Target)) { return $Script:ActionRegistry[$Target] }
        return $null
    }
}

function Write-ScapeActionProgress {
    [CmdletBinding()]
    param(
        [string]$Target,
        [string]$Task,
        [string]$StatusText,
        [string]$StatusFlag = "INFO",
        [int]$RunProgress = -1,
        [int]$StepProgress = -1
    )
    process {
        $targetFallback = Invoke-ScapeI18NFormat -Key "CORE_ACTION_SYSTEM_TASK"
        $targetDisp = if (-not [string]::IsNullOrWhiteSpace($Target)) { $Target } else { $targetFallback }
        $taskFallback = Invoke-ScapeI18NFormat -Key "CORE_ACTION_DEFAULT"
        $taskDisp = if (-not [string]::IsNullOrWhiteSpace($Task)) { $Task } else { $taskFallback }

        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "ActionScreen"
            IsActive = $true
            TitleKey = "MENU_MAIN_TARGET"
            Rows = @(
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_TARGET_MODULE"); RightText = $targetDisp; Flag = "HINT"; RightFlag = "Info" }
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_ACTIVE_TASK"); RightText = $taskDisp; Flag = "HINT"; RightFlag = "Info" }
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = $StatusText; Flag = "HINT"; RightFlag = $StatusFlag }
            )
            RunProgress = $RunProgress
            StepProgress = $StepProgress
        }

        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
            Invoke-ScapeIdlePump | Out-Null
        }
    }
}


function Invoke-ScapeActionDispatcher {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Task,
        [hashtable]$PayloadDef,
        [string]$MenuId,
        [int]$Cursor = 0
    )
    process {
        $handler = Get-ScapeActionHandler -Target $Target
        if ($null -eq $handler) {
            Publish-ScapeEvent -Type "SYSTEM_WARN" -Severity "WARN" -Payload @{
                Key    = "ORCH_MISSING_BINDING"
                Tokens = @($Target)
            }
            return $false
        }

        # Check if the target is instantaneous (silent execution without Action Screen)
        $silentTargets = Get-ScapeConstant -Path "system::ActionManager::SilentTargets" -Fallback @('Scape.Presentation.Theme','Scape.Core.Settings','Scape.Presentation.FilePicker')
        $isSilent = ($silentTargets -contains $Target)

        # Lifecycle Start
        if (-not $isSilent) {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "CORE_ACTION_INITIALIZING") -StatusFlag "WARN"
        }

        # Execution
        try {
            & $handler -Task $Task -PayloadDef $PayloadDef -Target $Target
            if (-not $isSilent) {
                $hasCustomRows = $false
                if (Get-Command Get-ScapeActionScreenState -ErrorAction SilentlyContinue) {
                    $screenState = Get-ScapeActionScreenState
                    if ($screenState -and $screenState.Rows -and $screenState.Rows.Count -gt 3) {
                        $hasCustomRows = $true
                    }
                }

                $completedText = Invoke-ScapeI18NFormat -Key "CORE_ACTION_COMPLETED"
                if ($hasCustomRows) {
                    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                        ScreenId = "ActionScreen"
                        Row = @{ LeftText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_STATUS"); RightText = $completedText; Flag = "HINT"; RightFlag = "Success" }
                    }
                } else {
                    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText $completedText -StatusFlag "Success"
                }
            }
        }
        catch {
            if (-not $isSilent) {
                $failedText = (Invoke-ScapeI18NFormat -Key "CORE_ACTION_FAILED") + ": $($_.Exception.Message)"
                Write-ScapeActionProgress -Target $Target -Task $Task -StatusText $failedText -StatusFlag "Failure"
            }
        }

        # Request UI layer to hold the screen and wait for user input
        if (-not $isSilent) {
            Publish-ScapeEvent -Type "ACTION_SCREEN_WAIT" -Severity "INFO" -Payload @{
                Target = $Target
                Task = $Task
            }
        }

        return $true
    }
}

# ==============================================================================
# TARGET RESOLUTION HELPER (shared by all handlers requiring active target)
# ==============================================================================

function Resolve-ScapeActiveTarget {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    process {
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
}

# ==============================================================================
# ACTION DELEGATES (Pure Domain Functions)
# ==============================================================================

Export-ModuleMember -Function 'Register-ScapeActionHandler', 'Get-ScapeActionHandler', 'Invoke-ScapeActionDispatcher', 'Write-ScapeActionProgress', 'Resolve-ScapeActiveTarget', 'Publish-ScapeTreeUpdate', 'Invoke-ScapeProgressWrapper'

function Publish-ScapeTreeUpdate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$TreeId,
        [Parameter(Mandatory = $true)][hashtable[]]$Nodes,
        [string]$TitleKey = 'TREE_DEFAULT_TITLE'
    )
    process {
        Publish-ScapeEvent -Type "TREE_UPDATE" -Severity "INFO" -Payload @{
            TreeId   = $TreeId
            Nodes    = $Nodes
            TitleKey = $TitleKey
        }
    }
}

function Invoke-ScapeProgressWrapper {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][array]$Items,
        [Parameter(Mandatory = $true)][string]$StageLabel,
        [Parameter(Mandatory = $true)][ScriptBlock]$ActionBlock
    )
    process {
        $total = $Items.Count
        if ($total -eq 0) { return @() }

        $results = New-Object System.Collections.Generic.List[object]
        for ($i = 0; $i -lt $total; $i++) {
            Publish-ScapeEvent -Type "PROGRESS" -Severity "LOG_INFO" -Payload @{
                Stage   = $StageLabel
                Current = $i
                Total   = $total
            }
            if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
                Invoke-ScapeIdlePump | Out-Null
            }
            $res = & $ActionBlock $Items[$i]
            if ($null -ne $res) { $results.Add($res) }
        }
        Publish-ScapeEvent -Type "PROGRESS" -Severity "LOG_INFO" -Payload @{
            Stage   = $StageLabel
            Current = $total
            Total   = $total
        }
        Invoke-ScapeIdlePump | Out-Null
        return $results.ToArray()
    }
}


Register-ScapeActionHandler -Target 'Scape.Forge.Deployer' -Handler {
    param($Task, $PayloadDef, $Target)
    if (Get-Command Invoke-ScapeDeployWorkflow -ErrorAction SilentlyContinue) { Invoke-ScapeDeployWorkflow -Task $Task } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Core.Settings' -Handler {
    param($Task, $PayloadDef, $Target)
    if ($Task -eq 'RESET' -and (Get-Command Reset-ScapeSettingToFactory -ErrorAction SilentlyContinue)) { Reset-ScapeSettingToFactory | Out-Null }
}

Register-ScapeActionHandler -Target 'Scape.Extensions.CloudSync.Robocopy' -Handler {
    param($Task, $PayloadDef, $Target)
    Start-ScapeRobocopyConfiguration -Task $Task -Target $Target
}

Register-ScapeActionHandler -Target 'Scape.Analysis.Parser.Core' -Handler {
    param($Task, $PayloadDef, $Target)
    Resolve-ScapeActiveTarget | Out-Null
    if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) { Invoke-ScapeTargetedParsing -Payload $PayloadDef } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Analysis.Carving.Carver' -Handler {
    param($Task, $PayloadDef, $Target)
    Resolve-ScapeActiveTarget | Out-Null
    if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) { Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "CARVING" } } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Analysis.FS.Abstraction' -Handler {
    param($Task, $PayloadDef, $Target)
    Resolve-ScapeActiveTarget | Out-Null
    if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) { Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "FS_ABSTRACTION" } } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Analysis.FS.NTFS' -Handler {
    param($Task, $PayloadDef, $Target)
    Resolve-ScapeActiveTarget | Out-Null
    if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) { Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "NTFS" } } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Analysis.FS.PartitionTable' -Handler {
    param($Task, $PayloadDef, $Target)
    Resolve-ScapeActiveTarget | Out-Null
    if (Get-Command Invoke-ScapeTargetedParsing -ErrorAction SilentlyContinue) { Invoke-ScapeTargetedParsing -Payload @{ Target = $Target; Task = "PARTITION_TABLE" } } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Telemetry' -Handler {
    param($Task, $PayloadDef, $Target)
    if (Get-Command Invoke-ScapeTelemetryWorkflow -ErrorAction SilentlyContinue) {
        $taskName = if ([string]::IsNullOrWhiteSpace($Task)) { 'TELEMETRY' } else { $Task }
        Invoke-ScapeTelemetryWorkflow -Task $taskName
    } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Presentation.KeyBindings' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ScapeKeyBindingAction -Task $Task -PayloadDef $PayloadDef -Target $Target
}

Register-ScapeActionHandler -Target 'Scape.Extensions.Network' -Handler {
    param($Task, $PayloadDef, $Target)
    Invoke-ScapeNetworkAction -Task $Task -Target $Target
}



