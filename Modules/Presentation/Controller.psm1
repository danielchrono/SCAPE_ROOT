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
            $idx = if ($null -ne $curr -and $curr -is [int]) { [int]$curr } else { 0 }
            if ($idx -lt 0 -or $idx -ge $labels.Count) { $idx = 0 }
            return " [$($labels[$idx])]"
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

function Format-ScapeGridLayout {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][array]$GridRows,
        [int]$Columns = 2,
        [int]$ColumnWidth = 30,
        [string]$FrameStyle = 'Classic',
        [switch]$WithBorder
    )
    process {
        if ($null -eq $GridRows -or $GridRows.Count -eq 0) { return "" }

        $ESC = [char]27
        $reset = "$ESC[0m"
        $sb = [System.Text.StringBuilder]::new()

        $frame = Get-ScapeConstant -Path "ui::Frames::$FrameStyle"
        if ($null -eq $frame) { $frame = Get-ScapeConstant -Path "ui::Frames::Classic" }

        if ($WithBorder) {
            $borderTop = $frame.TL + ($frame.HL * (($ColumnWidth * $Columns) + ($Columns - 1))) + $frame.TR
            [void]$sb.AppendLine((Format-ScapeANSIMessage -Text $borderTop -Flag 'MENU'))
        }

        $cellCount = 0
        $rowContent = ""

        foreach ($item in $GridRows) {
            $itemText = if ($item -is [string]) { $item } else { [string]$item }
            $padded = $itemText.PadRight($ColumnWidth).Substring(0, [Math]::Min($ColumnWidth, $itemText.Length + 5))

            $formatted = if ($item.PSObject.Properties['ThemeFlag']) {
                Format-ScapeANSIMessage -Text $padded -Flag $item.ThemeFlag
            } else {
                Format-ScapeANSIMessage -Text $padded -Flag 'MENU'
            }

            $rowContent += $formatted

            if ($WithBorder -and $cellCount -lt ($Columns - 1)) {
                $rowContent += (Format-ScapeANSIMessage -Text " | " -Flag 'HINT')
            }

            $cellCount++
            if ($cellCount -ge $Columns) {
                [void]$sb.AppendLine($rowContent)
                $rowContent = ""
                $cellCount = 0
            }
        }

        if ($rowContent.Length -gt 0) {
            [void]$sb.AppendLine($rowContent)
        }

        if ($WithBorder) {
            $borderBottom = $frame.BL + ($frame.HL * (($ColumnWidth * $Columns) + ($Columns - 1))) + $frame.BR
            [void]$sb.AppendLine((Format-ScapeANSIMessage -Text $borderBottom -Flag 'MENU'))
        }

        return $sb.ToString()
    }
}

function Format-ScapeThemifiedMenuBuffer {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $true)][array]$HydratedOptions,
        [int]$CursorIndex = 0,
        [string]$TitleKey,
        [string]$FrameStyle = 'Classic'
    )
    process {
        if ($null -eq $HydratedOptions -or $HydratedOptions.Count -eq 0) { return "" }

        $ESC = [char]27
        $reset = "$ESC[0m"
        $sb = [System.Text.StringBuilder]::new()

        $frame = Get-ScapeConstant -Path "ui::Frames::$FrameStyle"
        if ($null -eq $frame) { $frame = Get-ScapeConstant -Path "ui::Frames::Classic" }

        if ($null -ne $TitleKey) {
            $titleNode = Get-ScapeI18NNode -Key $TitleKey
            $title = $titleNode.Text -replace '^\[\s*|\s*\]$', ''
            $titleLine = $frame.TL + $title.PadRight(45, $frame.HL) + $frame.TR
            [void]$sb.AppendLine((Format-ScapeANSIMessage -Text $titleLine -Flag 'BANNER'))
        }

        for ($i = 0; $i -lt $HydratedOptions.Count; $i++) {
            $opt = $HydratedOptions[$i]
            $isSelected = ($i -eq $CursorIndex)

            $icon = if ($opt.PSObject.Properties['Icon']) { $opt.Icon } else { "" }
            $text = if ($opt.PSObject.Properties['Text']) { $opt.Text } else { $opt.TitleKey }
            $dynText = if ($opt.PSObject.Properties['DynamicText']) { $opt.DynamicText } else { "" }

            $selector = if ($isSelected) { "▶ " } else { "  " }
            $line = "$selector$icon $text"

            if ($dynText) { $line += " $dynText" }

            $flag = if ($opt.PSObject.Properties['ThemeFlag']) { $opt.ThemeFlag } else { 'MENU' }
            $formatted = Format-ScapeANSIMessage -Text $line -Flag $flag -Bold:$isSelected -IncludeBackground:$isSelected

            [void]$sb.AppendLine($formatted)
        }

        return $sb.ToString()
    }
}

Export-ModuleMember -Function 'Get-ScapeInputIntent',
                              'Update-ScapeMenuViewModel',
                              'Invoke-ScapeStateMutation',
                              'Get-ScapeHydratedOptions',
                              'Format-ScapeGridLayout',
                              'Format-ScapeThemifiedMenuBuffer'