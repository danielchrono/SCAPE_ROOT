<#
.SYNOPSIS
    Domain: Presentation\Controller
    Module: Scape.Presentation.Controller
    Architecture: Functional Purity | Stateless | Immutable Hydration
#>
[CmdletBinding()] param()

$Script:VirtualInputQueue = New-Object 'System.Collections.Generic.Queue[string]'

function Get-ScapeInputIntent {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][hashtable]$CurrentMenuState)
    process {
        if ($Script:VirtualInputQueue.Count -gt 0) {
            $key = $Script:VirtualInputQueue.Dequeue()
            if ($key -in @('UP', 'DOWN', 'LEFT', 'RIGHT', 'SELECT', 'BACK', 'EXIT', 'IDLE')) {
                return $key
            }
        } else {
            $pollMs = Get-ScapeConstant -Path "ui::Input::PollMs" -Fallback 30
            $key = Read-ScapeKeyPress -TimeoutMilliseconds $pollMs
        }
        if ($null -eq $key) { return 'IDLE' }

        if (Get-Command Resolve-ScapeInputToAction -ErrorAction SilentlyContinue) {
            $action = Resolve-ScapeInputToAction -KeyInput $key
            if ($action -ne 'IDLE') { return $action }
        }

        $combos = Get-ScapeConstant -Path "ui::Input::PSCombos"
        if ($key -eq $combos.Accept -or $key -eq $combos.SecondaryAccept) { return 'SELECT' }
        if ($key -eq $combos.Cancel -or $key -eq $combos.SecondaryCancel) { return 'BACK' }
        if ($key -eq $combos.HistoryPrev -or $key -eq 'UpArrow') { return 'UP' }
        if ($key -eq $combos.HistoryNext -or $key -eq 'DownArrow') { return 'DOWN' }
        if ($key -eq 'LeftArrow') { return 'LEFT' }
        if ($key -eq 'RightArrow') { return 'RIGHT' }
        return 'IDLE'
    }
}


function Resolve-ScapeDynamicText {
    param($DynCfg, $StateSnapshot)

    if ($null -eq $DynCfg -or $DynCfg -isnot [hashtable]) { return $null }

    $dynType = $DynCfg['Type']
    $dynKey = $DynCfg['Key']

    if ($dynType -eq 'StateValue') {
        return Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
    }
    elseif ($dynType -eq 'ToggleState') {
        $val = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
        if ($val -is [string]) {
            if ($val -ieq 'TrueColor') { $val = $true }
            elseif ($val -ieq 'ANSI16') { $val = $false }
            elseif ($val -match '^(?i:true|yes|on|1)$') { $val = $true }
            elseif ($val -match '^(?i:false|no|off|0)$') { $val = $false }
        }
        return [bool]$val
    }
    elseif ($dynType -eq 'CycleState') {
        $cycle = Get-ScapeConstant -Path $DynCfg['List']
        if ($cycle -is [array]) {
            $curr = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
            if ($curr -is [bool]) {
                if ($cycle -contains 'TrueColor' -and $cycle -contains 'ANSI16') { $curr = if ($curr) { 'TrueColor' } else { 'ANSI16' } }
                elseif ($cycle -contains 'REDUNDANCY' -and $cycle -contains 'EFFICIENCY') { $curr = if ($curr) { 'REDUNDANCY' } else { 'EFFICIENCY' } }
                elseif ($cycle.Count -gt 1) { $curr = if ($curr) { $cycle[1] } else { $cycle[0] } }
            }
            elseif ([string]::IsNullOrWhiteSpace([string]$curr) -and $cycle.Count -gt 0) { $curr = $cycle[0] }
            return $curr
        }
    }
    elseif ($dynType -eq 'CycleLabel') {
        $labels = Get-ScapeConstant -Path $DynCfg['Labels']
        if ($labels -is [array]) {
            $curr = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
            $idx = if ($null -ne $curr -and $curr -is [int]) { [int]$curr } else { 0 }
            if ($idx -lt 0 -or $idx -ge $labels.Count) { $idx = 0 }
            return $labels[$idx]
        }
    }
    return $null
}

function Update-ScapeMenuViewModel {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $false)][array]$RawOptions,
        [Parameter()][hashtable]$StateSnapshot
    )
    process {
        if ($null -eq $RawOptions) { $RawOptions = @() }
        $st = if ($null -ne $StateSnapshot) { $StateSnapshot } else { Get-ScapeColdState }

        $hydratedOptions = foreach ($opt in $RawOptions) {
            $id = if ($opt -is [hashtable]) { $opt['Id'] } else { $opt.Id }
            $titleKey = if ($opt -is [hashtable]) { $opt['TitleKey'] } else { $opt.TitleKey }
            $type = if ($opt -is [hashtable]) { $opt['Type'] } else { $opt.Type }
            $dynCfg = if ($opt -is [hashtable]) { $opt['DynamicText'] } else { $opt.DynamicText }
            $fmtArgs = if ($opt -is [hashtable]) { $opt['FormatArgs'] } else { $opt.FormatArgs }

            $i18nNode = try { Get-ScapeI18NNode -Key $titleKey } catch { $null }
            $finalText = if ($i18nNode -and (-not [string]::IsNullOrWhiteSpace($i18nNode.Text))) { $i18nNode.Text } else { $titleKey }
            if ($null -ne $fmtArgs) {
                try { $finalText = $finalText -f $fmtArgs } catch {}
            }

            $iconLevel = if ($st -and $st.ContainsKey('IconLevel')) { [int]$st['IconLevel'] } else { 0 }

            $rawDyn = Resolve-ScapeDynamicText -DynCfg $dynCfg -StateSnapshot $st
            $formattedDynText = ""
            if ($null -ne $rawDyn) {
                if ($rawDyn -is [bool]) {
                    $isOn = [bool]$rawDyn
                    $iconPath = if ($isOn) { 'ui::Icons::CheckboxOn' } else { 'ui::Icons::CheckboxOff' }
                    $glyphSet = Get-ScapeConstant -Path $iconPath -Fallback @()
                    if ($glyphSet -is [array] -and $glyphSet.Count -gt 0) {
                        $idx = [Math]::Max(0, [Math]::Min([int]$iconLevel, $glyphSet.Count - 1))
                        $formattedDynText = " $($glyphSet[$idx])"
                    } else {
                        $formattedDynText = if ($isOn) { ' [X]' } else { ' [ ]' }
                    }
                } else {
                    if ($finalText -match '\{0\}') {
                        try { $finalText = $finalText -f $rawDyn } catch {}
                    }
                    $formattedDynText = " [$rawDyn]"
                }
            }

            $ansiStrip = "$([char]27)\[[0-9;]*[a-zA-Z]"
            $cleanStr = if ($finalText) { $finalText -replace $ansiStrip, '' } else { '' }
            $cleanDyn = if ($formattedDynText) { $formattedDynText -replace $ansiStrip, '' } else { '' }

            $visStrW = if (Get-Command Get-ScapeVisualWidth -ErrorAction SilentlyContinue) { try { Get-ScapeVisualWidth $cleanStr } catch { $cleanStr.Length } } else { $cleanStr.Length }
            $dynLen = if (Get-Command Get-ScapePlainTextLength -ErrorAction SilentlyContinue) { try { Get-ScapePlainTextLength -Text $formattedDynText } catch { $cleanDyn.Length } } else { $cleanDyn.Length }

            [PSCustomObject]@{
                Id          = $id
                TitleKey    = $titleKey
                Text        = $finalText
                Type        = $type
                Icon        = Get-ScapeResolvedIcon -RouteId $id -IconLevel $iconLevel
                DynamicText = $formattedDynText
                TextWidth   = $visStrW
                DynWidth    = $dynLen
                Hint        = if ($i18nNode) { $i18nNode.Hint } else { $null }
            }
        }
        return $hydratedOptions
    }
}

function Invoke-ScapeStateMutation {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$SelectionId,
        [Parameter()][hashtable]$Payload,
        [ValidateSet('NEXT', 'PREV')][string]$Direction = 'NEXT'
    )
    process {
        $st = Get-ScapeColdState
        $key = Get-ScapeProperty -Object $Payload -PropertyName 'Key'
        $op = Get-ScapeProperty -Object $Payload -PropertyName 'Value'

        if ([string]::IsNullOrWhiteSpace($key)) { return $false }

        if ($op -eq 'TOGGLE') {
            $curr = Get-ScapeProperty -Object $st -PropertyName $key
            $newValue = $null
            if ($key -eq 'ColorMode') {
                $currText = if ($null -eq $curr) { '' } else { [string]$curr }
                $newValue = if ($currText -ieq 'TrueColor') { 'ANSI16' } else { 'TrueColor' }
            }
            elseif ($curr -is [bool]) {
                $newValue = -not $curr
            }
            elseif ($curr -is [string]) {
                if ($curr -match '^(?i:true|yes|on|1)$') { $newValue = $false }
                elseif ($curr -match '^(?i:false|no|off|0)$') { $newValue = $true }
                else { $newValue = -not [bool]$curr }
            }
            else {
                $newValue = -not [bool]$curr
            }
            Set-ScapeSettingMutation -Key $key -Value $newValue | Out-Null
            return $true
        }
        elseif ($op -eq 'CYCLE') {
            $cyclePath = Get-ScapeProperty -Object $Payload -PropertyName 'List'
            if ([string]::IsNullOrWhiteSpace($cyclePath)) { $cyclePath = "ui::CycleLists::$key" }
            $cycle = Get-ScapeConstant -Path $cyclePath
            if ($cycle -is [array] -and $cycle.Count -gt 0) {
                $curr = Get-ScapeProperty -Object $st -PropertyName $key
                $idx = [array]::IndexOf($cycle, $curr)
                if ($idx -lt 0 -and $null -ne $curr) {
                    $currStr = [string]$curr
                    for ($i = 0; $i -lt $cycle.Count; $i++) {
                        if ([string]$cycle[$i] -eq $currStr) {
                            $idx = $i
                            break
                        }
                    }
                }
                if ($Direction -eq 'PREV') {
                    $new = if ($idx -gt 0) { $cycle[$idx - 1] } elseif ($idx -eq 0) { $cycle[$cycle.Count - 1] } else { $cycle[$cycle.Count - 1] }
                }
                else {
                    $new = if ($idx -ge 0 -and $idx -lt $cycle.Count - 1) { $cycle[$idx + 1] } else { $cycle[0] }
                }
                Set-ScapeSettingMutation -Key $key -Value $new | Out-Null
                return $true
            }
        }
        return $false
    }
}

function Get-ScapeHydratedOptions {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][array]$Options,
        [Parameter()][hashtable]$StateSnapshot,
        [string]$ThemeFlag = 'MENU'
    )
    process {
        if ($null -eq $Options) { return @() }
        $st = if ($null -ne $StateSnapshot) { $StateSnapshot } else { Get-ScapeColdState }

        $hydratedWithTheme = foreach ($opt in $Options) {
            $opt | Add-Member -MemberType NoteProperty -Name 'ThemeFlag' -Value $ThemeFlag -Force
            $opt | Add-Member -MemberType NoteProperty -Name 'IsHighlighted' -Value $false -Force
            $opt
        }
        return $hydratedWithTheme
    }
}

function Send-ScapeVirtualInput {
    [CmdletBinding()]
    [OutputType([void])]
    param([Parameter(Mandatory = $true)][string]$Key)
    process {
        $Script:VirtualInputQueue.Enqueue($Key)
    }
}

Export-ModuleMember -Function 'Get-ScapeInputIntent',
                              'Update-ScapeMenuViewModel',
                              'Invoke-ScapeStateMutation',
                              'Get-ScapeHydratedOptions',
                              'Send-ScapeVirtualInput'