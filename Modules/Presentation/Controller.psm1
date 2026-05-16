<#
.SYNOPSIS
    Domain: Presentation\Controller
    Module: Scape.Presentation.Controller
    Architecture: Functional Purity | Stateless | Immutable Hydration
#>
[CmdletBinding()] param()

function Get-ScapeInputIntent {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][hashtable]$CurrentMenuState)
    process {
        $pollMs = Get-ScapeConstant -Path "ui::Input::PollMs" -Fallback 30
        $key = Read-ScapeKeyPress -TimeoutMilliseconds $pollMs
        if ($null -eq $key) { return 'IDLE' }
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

function Clear-ScapeInputBuffer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process { while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) } }
}

# EXTRAÍDO PARA SRP
function Resolve-ScapeDynamicText {
    param($DynCfg, $StateSnapshot)

    if ($null -eq $DynCfg -or $DynCfg -isnot [hashtable]) { return $null }

    $dynType = $DynCfg['Type']
    $dynKey = $DynCfg['Key']

    $formatStateValue = {
        param($Value)
        if ($Value -is [bool]) {
            $key = if ($Value) { 'MENU_VALUE_ENABLED' } else { 'MENU_VALUE_DISABLED' }
            return (Get-ScapeLogMsg -Key $key)
        }
        return [string]$Value
    }

    $resolveToggleGlyph = {
        param([bool]$IsOn)
        $iconLevel = Get-ScapeProperty -Object $StateSnapshot -PropertyName 'IconLevel' -Fallback 2
        $iconPath = if ($IsOn) { 'ui::Icons::CheckboxOn' } else { 'ui::Icons::CheckboxOff' }
        $glyphSet = Get-ScapeConstant -Path $iconPath -Fallback @()
        if ($glyphSet -is [array] -and $glyphSet.Count -gt 0) {
            $idx = [Math]::Max(0, [Math]::Min([int]$iconLevel, $glyphSet.Count - 1))
            return " $($glyphSet[$idx])"
        }
        return if ($IsOn) { ' [X]' } else { ' [ ]' }
    }

    if ($dynType -eq 'StateValue') {
        $stateValue = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
        return & $formatStateValue $stateValue
    }
    elseif ($dynType -eq 'ToggleState') {
        $val = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
        if ($val -is [string]) {
            if ($val -ieq 'TrueColor') { $val = $true }
            elseif ($val -ieq 'ANSI16') { $val = $false }
            elseif ($val -match '^(?i:true|yes|on|1)$') { $val = $true }
            elseif ($val -match '^(?i:false|no|off|0)$') { $val = $false }
        }
        return & $resolveToggleGlyph ([bool]$val)
    }
    elseif ($dynType -eq 'CycleState') {
        $cycle = Get-ScapeConstant -Path $DynCfg['List']
        if ($cycle -is [array]) {
            $curr = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
            if ($curr -is [bool]) {
                if ($cycle -contains 'TrueColor' -and $cycle -contains 'ANSI16') {
                    $curr = if ($curr) { 'TrueColor' } else { 'ANSI16' }
                }
                elseif ($cycle -contains 'REDUNDANCY' -and $cycle -contains 'EFFICIENCY') {
                    $curr = if ($curr) { 'REDUNDANCY' } else { 'EFFICIENCY' }
                }
                elseif ($cycle.Count -gt 1) {
                    $curr = if ($curr) { $cycle[1] } else { $cycle[0] }
                }
            }
            elseif ([string]::IsNullOrWhiteSpace([string]$curr) -and $cycle.Count -gt 0) {
                $curr = $cycle[0]
            }
            return " [$( & $formatStateValue $curr )]"
        }
    }
    elseif ($dynType -eq 'CycleLabel') {
        $labels = Get-ScapeConstant -Path $DynCfg['Labels']
        if ($labels -is [array]) {
            $curr = Get-ScapeProperty -Object $StateSnapshot -PropertyName $dynKey
            if ($curr -ge 0 -and $curr -lt $labels.Count) { return " [$($labels[$curr])]" }
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

            $i18nNode = Get-ScapeI18NNode -Key $titleKey
            $iconLevel = if ($st -and $st.ContainsKey('IconLevel')) { [int]$st['IconLevel'] } else { 0 }

            [PSCustomObject]@{
                Id          = $id
                TitleKey    = $titleKey
                Text        = $i18nNode.Text
                Type        = $type
                Icon        = Get-ScapeResolvedIcon -RouteId $id -IconLevel $iconLevel
                DynamicText = Resolve-ScapeDynamicText -DynCfg $dynCfg -StateSnapshot $st
                Hint        = $i18nNode.Hint
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

Export-ModuleMember -Function 'Get-ScapeInputIntent',
                              'Clear-ScapeInputBuffer',
                              'Update-ScapeMenuViewModel',
                              'Invoke-ScapeStateMutation'