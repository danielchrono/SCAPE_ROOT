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
        [string]$StatusFlag = "INFO"
    )
    process {
        $targetDisp = if (-not [string]::IsNullOrWhiteSpace($Target)) { $Target } else { "System Task" }
        $taskDisp = if (-not [string]::IsNullOrWhiteSpace($Task)) { $Task } else { "Default" }

        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "ActionScreen"
            IsActive = $true
            TitleKey = "MENU_MAIN_TARGET"
            Rows = @(
                @{ LeftText = "Target Module"; RightText = $targetDisp; Flag = "HINT"; RightFlag = "Info" }
                @{ LeftText = "Active Task"; RightText = $taskDisp; Flag = "HINT"; RightFlag = "Info" }
                @{ LeftText = "Status"; RightText = $StatusText; Flag = "HINT"; RightFlag = $StatusFlag }
            )
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
        $silentTargets = @(
            'Scape.Presentation.Theme',
            'Scape.Core.Settings',
            'Scape.Presentation.FilePicker'
        )
        $isSilent = ($silentTargets -contains $Target)

        # Lifecycle Start
        if (-not $isSilent) {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "INITIALIZING..." -StatusFlag "WARN"
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

                if ($hasCustomRows) {
                    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                        Row = @{ LeftText = "Status"; RightText = "COMPLETED - PRESS ANY KEY"; Flag = "HINT"; RightFlag = "Success" }
                    }
                } else {
                    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "COMPLETED - PRESS ANY KEY" -StatusFlag "Success"
                }
            }
        }
        catch {
            if (-not $isSilent) {
                Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "FAILED: $($_.Exception.Message)" -StatusFlag "Failure"
            }
        }

        # Wait for user input to clear the screen
        if (-not $isSilent -and (Get-Command Clear-ScapeInputBuffer -ErrorAction SilentlyContinue)) {
            Clear-ScapeInputBuffer
            while ($true) {
                if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
                    Invoke-ScapeIdlePump | Out-Null
                }
                Start-Sleep -Milliseconds 15
                if ([Console]::KeyAvailable) {
                    $k = [Console]::ReadKey($true)
                    if ($k.Key -in @('Enter', 'Escape', 'Backspace', 'Spacebar')) { break }
                }
            }
            Clear-ScapeInputBuffer
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

function Start-ScapeRobocopyConfiguration {
    [CmdletBinding()]
    param([string]$Task, [string]$Target)

    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "PREPARING ROBOCOPY CONFIGURATION..." -StatusFlag "INFO"

    $rcOptionsData = Get-ScapeConstant -Path "ui::ToggleLists" -Fallback @{}
    $rcCycles = Get-ScapeConstant -Path "ui::CycleLists" -Fallback @{}

    $rcConfig = @{
        Flags = @{
            RC_E = $rcOptionsData.RC_E; RC_ZB = $rcOptionsData.RC_ZB; RC_M = $rcOptionsData.RC_M; RC_B = $rcOptionsData.RC_B
            RC_COPYALL = $rcOptionsData.RC_COPYALL; RC_DCOPY_T = $rcOptionsData.RC_DCOPY_T; RC_NP = $rcOptionsData.RC_NP
            RC_FFT = $rcOptionsData.RC_FFT; RC_XO = $rcOptionsData.RC_XO; RC_XN = $rcOptionsData.RC_XN
            RC_XJ = $rcOptionsData.RC_XJ; RC_L = $rcOptionsData.RC_L; RC_V = $rcOptionsData.RC_V
        }
        Parameters = @{
            RC_MT = if ($rcCycles.ContainsKey('RC_MT')) { $rcCycles['RC_MT'][0] } else { 1 }
            RC_R = if ($rcCycles.ContainsKey('RC_R')) { $rcCycles['RC_R'][0] } else { 0 }
            RC_W = if ($rcCycles.ContainsKey('RC_W')) { $rcCycles['RC_W'][0] } else { 0 }
        }
    }

    if (Get-Command Set-ScapeProperty -ErrorAction SilentlyContinue) {
        Set-ScapeProperty -Object (Get-ScapeColdState) -PropertyName "RobocopyConfig" -Value $rcConfig | Out-Null
    }

    $rcOptions = @(
        @{ Id = 'RC_E'; TitleKey = 'RC_FLAG_E'; Type = 'UI'; DynamicText = @{ Type = 'ToggleState'; Key = 'RC_E' } }
        @{ Id = 'RC_ZB'; TitleKey = 'RC_FLAG_ZB'; Type = 'UI'; DynamicText = @{ Type = 'ToggleState'; Key = 'RC_ZB' } }
        @{ Id = 'RC_M'; TitleKey = 'RC_FLAG_M'; Type = 'UI'; DynamicText = @{ Type = 'ToggleState'; Key = 'RC_M' } }
        @{ Id = 'RC_B'; TitleKey = 'RC_FLAG_B'; Type = 'UI'; DynamicText = @{ Type = 'ToggleState'; Key = 'RC_B' } }
        @{ Id = 'RC_COPYALL'; TitleKey = 'RC_FLAG_COPYALL'; Type = 'UI'; DynamicText = @{ Type = 'ToggleState'; Key = 'RC_COPYALL' } }
    )

    $hydratedOptions = Update-ScapeMenuViewModel -MenuId 'RobocopyConfig' -RawOptions $rcOptions -StateSnapshot (Get-ScapeColdState)

    if (Get-Command Get-ScapeHydratedOptions -ErrorAction SilentlyContinue) {
        $hydratedOptions = Get-ScapeHydratedOptions -Options $hydratedOptions -StateSnapshot (Get-ScapeColdState) -ThemeFlag 'UI'
    }

    if (Get-Command Format-ScapeThemifiedMenuBuffer -ErrorAction SilentlyContinue) {
        $rendered = Format-ScapeThemifiedMenuBuffer -MenuId 'RobocopyConfig' -HydratedOptions $hydratedOptions -CursorIndex 0 -TitleKey 'ROBOCOPY_CONFIG' -FrameStyle 'Classic'
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "RobocopyConfigScreen"
            Content = $rendered
            Rows = $hydratedOptions
        }
    }

    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "ROBOCOPY CONFIGURATION READY" -StatusFlag "Success"
}

function Invoke-ScapeKeyBindingAction {
    [CmdletBinding()]
    param([string]$Task, [hashtable]$PayloadDef, [string]$Target)

    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "INITIALIZING KEY BINDINGS MANAGER..." -StatusFlag "INFO"

    if (-not (Get-Command Initialize-ScapeKeyBindings -ErrorAction SilentlyContinue)) {
        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "KEY BINDINGS MODULE NOT LOADED" -StatusFlag "Failure"
        throw "KeyBindings module not available"
    }

    Initialize-ScapeKeyBindings | Out-Null

    if ($Task -eq 'REBIND_INTERACTIVE') {
        $actions = @('UP', 'DOWN', 'LEFT', 'RIGHT', 'SELECT', 'BACK')

        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "KeyBindingsScreen"
            TitleKey = "KEYBINDINGS_CONFIG"
            Rows = @(
                @{ LeftText = "Mode"; RightText = "INTERACTIVE REBINDING"; Flag = "Info"; RightFlag = "Info" }
                @{ LeftText = "Status"; RightText = "PRESS A KEY TO REBIND"; Flag = "Hint"; RightFlag = "Hint" }
            )
        }

        foreach ($action in $actions) {
            $currentBinding = Get-ScapeKeyBindings | Where-Object { $_.Action -eq $action } | Select-Object -First 1
            $currentSeq = if ($currentBinding) { $currentBinding.Sequence } else { "UNBOUND" }

            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                Row = @{ LeftText = "Action [$action]"; RightText = $currentSeq; Flag = "Hint"; RightFlag = "Info" }
            }
            Start-Sleep -Milliseconds 100
        }

        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "KEY BINDINGS READY" -StatusFlag "Success"

    } elseif ($Task -eq 'LOAD_PROFILE') {
        $TargetProfile = $PayloadDef['Profile']
        if ($null -ne $TargetProfile) {
            Set-ScapeKeyBindingProfile -ProfileName $TargetProfile | Out-Null
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "PROFILE [$TargetProfile] LOADED" -StatusFlag "Success"
        } else {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "NO PROFILE SPECIFIED" -StatusFlag "Failure"
        }
    } elseif ($Task -eq 'SAVE_BINDINGS') {
        $result = Save-ScapeKeyBindingsToFile
        if ($result) {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "KEY BINDINGS SAVED" -StatusFlag "Success"
        } else {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "FAILED TO SAVE KEY BINDINGS" -StatusFlag "Failure"
        }
    } else {
        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "KEY BINDINGS SYSTEM READY" -StatusFlag "Success"
    }
}

function Start-ScapeNetworkScan {
    [CmdletBinding()]
    param()
    
    $radarSweepMsg = Get-ScapeLogMsg -Key "NET_RADAR_SWEEP"
    Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $radarSweepMsg }

    $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
    if (-not $gw) {
        $gwErr = Get-ScapeLogMsg -Key "NET_RADAR_GATEWAY_ERR"
        Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = $gwErr }
        return $null
    }

    $subnet = $gw -replace '\.\d+$', ''
    $scanMsg = Get-ScapeLogMsg -Key "NET_RADAR_SCAN" -MsgArgs @($subnet)
    Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $scanMsg }

    $nodes = Find-ScapeNetworkNode -SubnetRoot $subnet
    return $nodes
}

function Invoke-ScapeNetworkRadarAction {
    [CmdletBinding()]
    param()
    
    $nodes = Start-ScapeNetworkScan
    if ($null -eq $nodes -or $nodes.Count -eq 0) {
        $noneMsg = Get-ScapeLogMsg -Key "NET_RADAR_NONE"
        Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $noneMsg }
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "NetworkRadar"
            TitleKey = "NET_MGR_TITLE"
            Rows = @( @{ LeftText = "Scan Result"; RightText = "NO SERVERS DETECTED"; Flag = "Failure"; RightFlag = "Failure" } )
        }
        return
    }

    $rows = @()
    foreach ($node in $nodes) {
        $foundMsg = Get-ScapeLogMsg -Key "NET_RADAR_FOUND" -MsgArgs @($node)
        Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $foundMsg }
        $rows += @{ LeftText = "Samba Server"; RightText = "\\$node"; Flag = "Success"; RightFlag = "Info" }
    }

    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
        ScreenId = "NetworkRadar"
        TitleKey = "NET_MGR_TITLE"
        Rows = $rows
    }

    $targetNode = $nodes[0]
    $usedLetters = (Get-Volume).DriveLetter
    $driveLetter = $null
    foreach ($l in ([char]'Z')..([char]'D')) {
        if ([char]$l -notin $usedLetters) {
            $driveLetter = "$([char]$l):"
            break
        }
    }

    if (-not $driveLetter) {
        Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = "No free drive letters available." }
        return
    }

    [Console]::WriteLine()
    [Console]::Write("Target Server: ")
    [Console]::ForegroundColor = [ConsoleColor]::Cyan
    [Console]::WriteLine("\\$targetNode")
    [Console]::ResetColor()
    [Console]::Write("Enter target Samba share name [Vault]: ")
    $share = [Console]::ReadLine()
    if ([string]::IsNullOrWhiteSpace($share)) { $share = "Vault" }

    $remotePath = "\\$targetNode\$share"
    $mapInitMsg = Get-ScapeLogMsg -Key "NET_MAP_INIT" -MsgArgs @($targetNode)
    Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $mapInitMsg }

    $mountOk = New-ScapeNetworkMount -RemoteVault $remotePath -DriveLetter $driveLetter
    if ($mountOk) {
        Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_SUCCESS" -MsgArgs @($driveLetter)) }
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "NetworkRadar"
            TitleKey = "NET_MGR_TITLE"
            Row = @{ LeftText = "Mapped Drive"; RightText = "$driveLetter -> $remotePath"; Flag = "Success"; RightFlag = "Success" }
        }
    } else {
        if (Get-Command Mount-ScapeNetworkShareWithCredential -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_SMB_AUTH_REQUIRED") }
            $mountOk = Mount-ScapeNetworkShareWithCredential -RemoteVault $remotePath -DriveLetter $driveLetter
            if ($mountOk) {
                Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_SUCCESS" -MsgArgs @($driveLetter)) }
                Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                    ScreenId = "NetworkRadar"
                    TitleKey = "NET_MGR_TITLE"
                    Row = @{ LeftText = "Mapped Drive"; RightText = "$driveLetter -> $remotePath"; Flag = "Success"; RightFlag = "Success" }
                }
            } else {
                Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_CANCELLED") }
                Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                    ScreenId = "NetworkRadar"
                    TitleKey = "NET_MGR_TITLE"
                    Row = @{ LeftText = "Status"; RightText = "AUTHENTICATION FAILED"; Flag = "Failure"; RightFlag = "Failure" }
                }
            }
        } else {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_CANCELLED") }
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                ScreenId = "NetworkRadar"
                TitleKey = "NET_MGR_TITLE"
                Row = @{ LeftText = "Status"; RightText = "MAPPING FAILED"; Flag = "Failure"; RightFlag = "Failure" }
            }
        }
    }
}

function Invoke-ScapeNetworkAction {
    [CmdletBinding()]
    param([string]$Task, [string]$Target)
    
    if (-not (Get-Command Find-ScapeNetworkNode -ErrorAction SilentlyContinue)) {
        throw "Not Implemented"
    }

    if ($Task -eq 'SCAN') {
        Invoke-ScapeNetworkRadarAction
    } elseif ($Task -eq 'UNMOUNT_ALL') {
        $unmountOk = Clear-ScapeNetworkMounts
        if ($unmountOk) {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MGR_ALL_REMOVED") }
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                ScreenId = "NetworkRadar"
                TitleKey = "NET_MGR_TITLE"
                Rows = @( @{ LeftText = "Status"; RightText = "ALL DRIVES UNMOUNTED"; Flag = "Warning"; RightFlag = "Warning" } )
            }
        } else {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = "Failed to clear network mounts." }
        }
    } else {
        Find-ScapeNetworkNode | Out-Null
    }
}


# ==============================================================================
# ACTION REGISTRY BINDINGS (Pure & Decoupled)
# ==============================================================================

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

Register-ScapeActionHandler -Target 'Scape.Presentation.FilePicker' -Handler {
    param($Task, $PayloadDef, $Target)
    if (Get-Command Invoke-ScapeDirectoryPicker -ErrorAction SilentlyContinue) { Invoke-ScapeDirectoryPicker -Payload $PayloadDef }
}

Register-ScapeActionHandler -Target 'Scape.Presentation.Theme' -Handler {
    param($Task, $PayloadDef, $Target)
    if ($Task -eq 'PROCEDURAL') {
        $rand = [Random]::new()
        Set-ScapeSettingMutation -Key "RandomBaseHue" -Value ($rand.NextDouble() * 360) | Out-Null
        Set-ScapeSettingMutation -Key "ThemePersona" -Value "RANDOM" | Out-Null
    }
}

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Audit' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "EXPORTING AUDIT LEDGER..." -StatusFlag "INFO"
    $root = (Get-ScapeColdState)["ROOT"]
    if ([string]::IsNullOrWhiteSpace($root)) { $root = (Get-Location).Path }
    $exportDir = Join-Path $root "Data\Exports"
    if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
    $exportPath = Join-Path $exportDir "AuditLedger_$(Get-Date -f 'yyyyMMdd_HHmmss').json"
    
    if (Get-Command Export-ScapeAuditLedger -ErrorAction SilentlyContinue) {
        $result = Export-ScapeAuditLedger -OutputPath $exportPath -Format "JSON"
        if ($result.Success) {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "AUDIT LEDGER EXPORTED SUCCESSFULLY" -StatusFlag "Success"
        } else {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "FAILED TO EXPORT AUDIT LEDGER" -StatusFlag "Failure"
            throw "Audit export failed"
        }
    } else {
        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "AUDIT MODULE NOT LOADED" -StatusFlag "Failure"
        throw "Audit module not available."
    }
}

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Compliance' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "GENERATING COMPLIANCE REPORT..." -StatusFlag "INFO"
    $root = (Get-ScapeColdState)["ROOT"]
    if ([string]::IsNullOrWhiteSpace($root)) { $root = (Get-Location).Path }
    $exportDir = Join-Path $root "Data\Exports"
    if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
    $exportPath = Join-Path $exportDir "ComplianceReport_$(Get-Date -f 'yyyyMMdd_HHmmss').json"
    
    if (Get-Command Export-ScapeComplianceReport -ErrorAction SilentlyContinue) {
        $result = Export-ScapeComplianceReport -OutputPath $exportPath
        if ($result.Success) {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "COMPLIANCE REPORT GENERATED: $($result.Status)" -StatusFlag "Success"
        } else {
            Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "FAILED TO GENERATE COMPLIANCE REPORT" -StatusFlag "Failure"
            throw "Compliance export failed"
        }
    } else {
        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "COMPLIANCE MODULE NOT LOADED" -StatusFlag "Failure"
        throw "Compliance module not available."
    }
}

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Pipeline' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "INITIALIZING MEMORY PIPELINE..." -StatusFlag "INFO"
    if (Get-Command Initialize-ScapePipeline -ErrorAction SilentlyContinue) {
        Initialize-ScapePipeline | Out-Null
        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "PIPELINE BUFFER ACTIVE" -StatusFlag "Success"
    } else {
        Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "PIPELINE MODULE NOT LOADED" -StatusFlag "Failure"
        throw "Pipeline module not available."
    }
}

Register-ScapeActionHandler -Target 'Scape.Acquisition.Selection' -Handler {
    param($Task, $PayloadDef, $Target)
    if (Get-Command Get-ScapePhysicalTarget -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "INVENTORY_PHYSICAL_DISKS"; Targets = @(Get-ScapePhysicalTarget) }
    } else { throw "Not Implemented" }
}

Register-ScapeActionHandler -Target 'Scape.Acquisition.Resilience' -Handler {
    param($Task, $PayloadDef, $Target)
    $targetId = Resolve-ScapeActiveTarget
    if ([string]::IsNullOrWhiteSpace($targetId)) { throw "No Target Bound" }
}

Register-ScapeActionHandler -Target 'Scape.Extensions.CloudSync' -Handler {
    param($Task, $PayloadDef, $Target)
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "RESOLVING CLOUD VAULT ENDPOINT..." -StatusFlag "WARN"
    Start-Sleep -Milliseconds 150
    if (Get-Command Invoke-ScapeCloudSyncPreparation -ErrorAction SilentlyContinue) { Invoke-ScapeCloudSyncPreparation | Out-Null } else { throw "Not Implemented" }
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "AUTHENTICATING SHA256 KEYS..." -StatusFlag "WARN"
    Start-Sleep -Milliseconds 200
    Write-ScapeActionProgress -Target $Target -Task $Task -StatusText "COMPRESSING COLD ARCHIVES..." -StatusFlag "WARN"
    Start-Sleep -Milliseconds 250
}

Export-ModuleMember -Function 'Register-ScapeActionHandler',
                              'Get-ScapeActionHandler',
                              'Invoke-ScapeActionDispatcher',
                              'Write-ScapeActionProgress',
                              'Resolve-ScapeActiveTarget',
                              'Start-ScapeRobocopyConfiguration',
                              'Invoke-ScapeKeyBindingAction',
                              'Start-ScapeNetworkScan',
                              'Invoke-ScapeNetworkRadarAction',
                              'Invoke-ScapeNetworkAction'