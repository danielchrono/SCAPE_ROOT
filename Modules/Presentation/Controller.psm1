<#
.SYNOPSIS
    Domain: Presentation\Controller
    Module: Scape.Presentation.Controller
    Architecture: Controller | ViewModel Hydration | Input Engine
#>
[CmdletBinding()] param()

function ConvertTo-ScapeMenuViewModel {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $true)][array]$RawOptions,
        [Parameter()][hashtable]$DynamicData = @{}
    )
    process {
        $viewModels = New-Object System.Collections.Generic.List[PSCustomObject]
        foreach ($opt in $RawOptions) {
            $id = Get-ScapeProperty -Object $opt -PropertyName 'Id' -Fallback ''
            $dynText = if (-not [string]::IsNullOrWhiteSpace($id)) { Get-ScapeProperty -Object $DynamicData -PropertyName $id -Fallback '' } else { '' }

            $viewModels.Add([PSCustomObject]@{
                    Id          = $id
                    TitleKey    = Get-ScapeProperty -Object $opt -PropertyName 'TitleKey' -Fallback ''
                    Type        = Get-ScapeProperty -Object $opt -PropertyName 'Type' -Fallback 'Normal'
                    DynamicText = $dynText
                })
        }
        return $viewModels.ToArray()
    }
}

function Update-ScapeMenuViewModel {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $true)][array]$RawOptions
    )
    process {
        if ($PSCmdlet.ShouldProcess("Menu $MenuId", "Update ViewModel")) {
            $dynamicData = @{}
            $state = Get-ScapeColdState

            if ($MenuId -eq 'SettingsMenu') {
                $dynamicData['ENGINE_MODE'] = Get-ScapeProperty -Object $state -PropertyName 'EngineMode' -Fallback 'STANDARD'
                $dynamicData['LANGUAGE'] = Get-ScapeProperty -Object $state -PropertyName 'CurrentLanguage' -Fallback 'en-US'
                $dynamicData['THEME'] = Get-ScapeProperty -Object $state -PropertyName 'Theme' -Fallback 'CYBER'
                $dynamicData['DEFAULT_OUT'] = Get-ScapeProperty -Object $state -PropertyName 'OutPath' -Fallback 'C:\Export'
            }

            if ($MenuId -eq 'RobocopyMenu') {
                $rcKeys = @("RC_E", "RC_M", "RC_ZB", "RC_FFT", "RC_XO", "RC_XN", "RC_XJ", "RC_B", "RC_NP", "RC_COPYALL", "RC_DCOPY_T", "RC_L", "RC_V")
                foreach ($k in $rcKeys) {
                    $flagId = $k -replace "RC_", "RC_FLAG_"
                    $dynamicData[$flagId] = if (Get-ScapeProperty -Object $state -PropertyName $k -Fallback $false) { " [X]" } else { " [ ]" }
                }
                $dynamicData['RC_FLAG_MT'] = " [" + (Get-ScapeProperty -Object $state -PropertyName "RC_MT" -Fallback 128) + "]"
                $dynamicData['RC_RETRY_R'] = " [" + (Get-ScapeProperty -Object $state -PropertyName "RC_R" -Fallback 3) + "]"
                $dynamicData['RC_RETRY_W'] = " [" + (Get-ScapeProperty -Object $state -PropertyName "RC_W" -Fallback 10) + "]"
            }

            if ($MenuId -eq 'ThemeMenu') {
                $activeTheme = Get-ScapeProperty -Object $state -PropertyName 'Theme' -Fallback 'CYBER'
                foreach ($opt in $RawOptions) {
                    $id = Get-ScapeProperty -Object $opt -PropertyName 'Id' -Fallback ''
                    if (-not [string]::IsNullOrWhiteSpace($id) -and ($id -replace "THEME_", "") -eq $activeTheme) {
                        $dynamicData[$id] = " [ACTIVE]"
                    }
                }
            }
            return [System.Object[]](ConvertTo-ScapeMenuViewModel -RawOptions $RawOptions -DynamicData $dynamicData)
        }
        return [System.Object[]]@()
    }
}

function Read-ScapeKeyPress {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter()][int]$TimeoutMilliseconds = 30)
    process {
        $start = [DateTime]::Now
        while (([DateTime]::Now - $start).TotalMilliseconds -lt $TimeoutMilliseconds) {
            if ([Console]::KeyAvailable) {
                $ki = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                return $ki.Key.ToString()
            }
            Start-Sleep -Milliseconds 10
        }
        return [string]::Empty
    }
}

function Clear-ScapeInputBuffer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process {
        try {
            while ([Console]::KeyAvailable) {
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            }
        }
        catch {
            if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) {
                Publish-ScapeFault -ErrorRecord $_ -Context "Controller"
            }
        }
    }
}

function Invoke-ScapeMenuEngine {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $true)][array]$RawOptions,
        [Parameter(Mandatory = $true)][string]$TitleKey,
        [Parameter(Mandatory = $true)][int]$InitialCursor
    )
    process {
        $vp = if (Get-Command Initialize-ScapeViewportState -ErrorAction SilentlyContinue) { Initialize-ScapeViewportState } else { $null }
        $cursor = $InitialCursor
        $forceRedraw = $true

        while ($true) {
            if ($null -ne $vp -and (Get-Command Test-ScapeViewportChanged -ErrorAction SilentlyContinue)) {
                if (Test-ScapeViewportChanged -ViewportState $vp) { $forceRedraw = $true }
            }

            if (Get-Command Invoke-ScapeMasterRedraw -ErrorAction SilentlyContinue) {
                Invoke-ScapeMasterRedraw -MenuId $MenuId -Options $RawOptions -CursorIndex $cursor -TitleKey $TitleKey -ForceFullRedraw:$forceRedraw
            }
            $forceRedraw = $false

            while (-not [Console]::KeyAvailable) {
                Start-Sleep -Milliseconds 50
                if ($null -ne $vp -and (Get-Command Test-ScapeViewportChanged -ErrorAction SilentlyContinue)) {
                    if (Test-ScapeViewportChanged -ViewportState $vp) { $forceRedraw = $true; break }
                }
            }

            if ($forceRedraw) { continue }

            $rawKey = Read-ScapeKeyPress
            if ([string]::IsNullOrEmpty($rawKey)) { continue }

            Clear-ScapeInputBuffer

            $trans = Invoke-ScapeMenuStateTransition -CurrentState $MenuId -UserInput $rawKey -CursorIndex $cursor -OptionCount $RawOptions.Count

            $cursor = $trans.Cursor
            $forceRedraw = $trans.ShouldRender

            if ($null -ne $trans.Action) {
                if ($trans.Action -eq 'Back') {
                    return [PSCustomObject]@{ Selection = @{ Action = 'ESC'; Id = 'CANCEL' }; Cursor = $cursor }
                }
                return [PSCustomObject]@{ Selection = $RawOptions[$cursor]; Cursor = $cursor }
            }
        }
    }
    end {
        return [PSCustomObject]@{ Selection = @{ Action = 'TIMEOUT'; Id = 'CANCEL' }; Cursor = $InitialCursor }
    }
}

function Resolve-ScapeSelectionEffect {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][psobject]$SelectedOption,
        [Parameter(Mandatory = $true)][string]$CurrentMenu,
        [Parameter(Mandatory = $true)][array]$RouteStack
    )
    process {
        $selId = Get-ScapeProperty -Object $SelectedOption -PropertyName 'Id' -Fallback ''
        $routeMap = Get-ScapeConstant -Path "routes::Navigation" -Fallback @{}

        $menuMap = Get-ScapeProperty -Object $routeMap -PropertyName $CurrentMenu -Fallback @{}

        $route = @{}
        if ($menuMap -is [hashtable] -and $menuMap.ContainsKey($selId)) {
            $route = $menuMap[$selId]
        }
        else {
            $globalMap = Get-ScapeProperty -Object $routeMap -PropertyName "Global" -Fallback @{}
            if ($globalMap -is [hashtable] -and $globalMap.ContainsKey($selId)) {
                $route = $globalMap[$selId]
            }
            else {
                $route = @{ Next = $CurrentMenu; Action = 'FAULT_UNHANDLED' }
            }
        }

        $next = Get-ScapeProperty -Object $route -PropertyName 'Next' -Fallback $CurrentMenu
        $action = Get-ScapeProperty -Object $route -PropertyName 'Action' -Fallback 'FAULT_UNHANDLED'

        if ($action -eq 'TERMINATE') { return @{ NextMenu = $null; RouteStack = $RouteStack; Action = 'TERMINATE' } }
        if ($action -eq 'BACK') {
            $next = if ($RouteStack.Count -gt 1) { $RouteStack[-2] } else { $CurrentMenu }
            $newStack = Remove-ScapeRouteFromStack -Stack $RouteStack
            return @{ NextMenu = $next; RouteStack = $newStack; Action = 'BACK' }
        }
        if ($action -eq 'FAULT_UNHANDLED') {
            if (Get-Command Dispatch-ScapeRouteFault -ErrorAction SilentlyContinue) { Dispatch-ScapeRouteFault -RouteId $selId }
            return @{ NextMenu = $CurrentMenu; RouteStack = $RouteStack; Action = 'FAULT_UNHANDLED' }
        }

        if ($CurrentMenu -in @("SettingsMenu", "ThemeMenu")) {
            $st = Get-ScapeColdState
            if ($selId -eq "ENGINE_MODE") {
                $new = if ((Get-ScapeProperty -Object $st -PropertyName 'EngineMode' -Fallback 'STANDARD') -eq "STANDARD") { "FORENSIC_DEEP" } else { "STANDARD" }
                if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) { Set-ScapeSettingMutation -Key "EngineMode" -Value $new | Out-Null }
            }
            if ($selId -eq "CFG_LANG") {
                $new = if ((Get-ScapeProperty -Object $st -PropertyName 'CurrentLanguage' -Fallback 'en-US') -eq "en-US") { "pt-BR" } else { "en-US" }
                if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) { Set-ScapeSettingMutation -Key "CurrentLanguage" -Value $new | Out-Null }
            }
            if ($selId -match "^THEME_") {
                $new = ($selId -replace "THEME_", "")
                if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) { Set-ScapeSettingMutation -Key "Theme" -Value $new | Out-Null }
            }
            return @{ NextMenu = $CurrentMenu; RouteStack = $RouteStack; Action = 'MUTATE' }
        }

        if ($CurrentMenu -eq "MainMenu" -and $selId -eq "PARSING") {
            if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                Publish-ScapeEvent -Type "LAZY_WAKEUP" -Severity "SYS_CORE" -Payload @{ Domain = "Analysis"; Target = "Scape.Analysis.FS.NTFS" }
            }
        }
        if ($CurrentMenu -eq "MainMenu" -and $selId -eq "ARCHAEOLOGY") {
            if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                Publish-ScapeEvent -Type "LAZY_WAKEUP" -Severity "SYS_CORE" -Payload @{ Domain = "Analysis"; Target = "Scape.Analysis.Carving.Carver" }
            }
        }
        if ($CurrentMenu -eq "MainMenu" -and $selId -eq "HARVESTER") {
            if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                Publish-ScapeEvent -Type "LAZY_WAKEUP" -Severity "SYS_CORE" -Payload @{ Domain = "Infrastructure"; Target = "Scape.Infrastructure.Pipeline" }
            }
        }

        if ($CurrentMenu -eq "RobocopyMenu" -and $action -eq "MUTATE") {
            $payload = Get-ScapeProperty -Object $route -PropertyName 'Payload' -Fallback @{}
            $key = Get-ScapeProperty -Object $payload -PropertyName 'Key' -Fallback ''
            $op = Get-ScapeProperty -Object $payload -PropertyName 'Value' -Fallback ''

            $st = Get-ScapeColdState
            $currVal = Get-ScapeProperty -Object $st -PropertyName $key

            if ($op -eq "TOGGLE") {
                $newVal = if ($null -ne $currVal) { -not $currVal } else { $true }
                if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) { Set-ScapeSettingMutation -Key $key -Value $newVal | Out-Null }
            }
            elseif ($op -eq "CYCLE") {
                $arr = switch ($key) {
                    "RC_MT" { @(1, 2, 4, 8, 16, 32, 64, 128) }
                    "RC_R" { @(0, 1, 3, 5, 10) }
                    "RC_W" { @(0, 1, 5, 10, 30) }
                }
                $idx = [array]::IndexOf($arr, $currVal)
                $newVal = if ($idx -lt ($arr.Count - 1)) { $arr[$idx + 1] } else { $arr[0] }
                if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) { Set-ScapeSettingMutation -Key $key -Value $newVal | Out-Null }
            }
            return @{ NextMenu = $CurrentMenu; RouteStack = $RouteStack; Action = 'MUTATE' }
        }

        if ([string]::IsNullOrWhiteSpace($next)) { $next = $CurrentMenu }
        $newStack = if ($next -ne $CurrentMenu) { Add-ScapeRouteToStack -Stack $RouteStack -Route $next } else { $RouteStack }

        return @{ NextMenu = $next; RouteStack = $newStack; Action = 'NAVIGATE' }
    }
}