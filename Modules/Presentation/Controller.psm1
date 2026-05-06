<#
.SYNOPSIS
    Domain: Presentation\Controller
    Module: Scape.Presentation.Controller
    Architecture: Functional Purity | Stateless | Immutable Hydration | Event-Registered Mutations
#>
[CmdletBinding()] param()

function Get-ScapeInputIntent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$CurrentMenuState
    )
    process {
        $pollMs = Get-ScapeConstant -Path "ui::Input::PollMs" -Fallback 30
        $key = Read-ScapeKeyPress -TimeoutMilliseconds $pollMs
        if ($null -eq $key) { return 'IDLE' }
        $combos = Get-ScapeConstant -Path "ui::Input::PSCombos"
        if ($key -eq $combos.Accept -or $key -eq $combos.SecondaryAccept) { return 'SELECT' }
        if ($key -eq $combos.Cancel -or $key -eq $combos.SecondaryCancel) { return 'BACK' }
        if ($key -eq $combos.HistoryPrev) { return 'UP' }
        if ($key -eq $combos.HistoryNext) { return 'DOWN' }
        return 'IDLE'
    }
}

function Clear-ScapeInputBuffer {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    process { while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) } }
}

function Update-ScapeMenuViewModel {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][string]$MenuId,
        [Parameter(Mandatory = $true)][array]$RawOptions
    )
    process {
        $hydratedOptions = foreach ($opt in $RawOptions) {
            $id = if ($opt -is [hashtable]) { $opt['Id'] } else { $opt.Id }
            $titleKey = if ($opt -is [hashtable]) { $opt['TitleKey'] } else { $opt.TitleKey }
            $type = if ($opt -is [hashtable]) { $opt['Type'] } else { $opt.Type }
            $hint = (Get-ScapeI18NNode -Key $titleKey).Hint
            $icon = Get-ScapeResolvedIcon -RouteId $id # Centralizado

            # Resolução de texto dinâmico (inline para pureza)
            $dynText = $null
            $dynCfg = if ($opt -is [hashtable]) { $opt['DynamicText'] } else { $opt.DynamicText }
            if ($dynCfg -is [hashtable]) {
                $dynType = $dynCfg['Type']
                $dynKey = $dynCfg['Key']
                $st = Get-ScapeColdState
                switch ($dynType) {
                    'StateValue' { $dynText = Get-ScapeProperty -Object $st -PropertyName $dynKey }
                    'ToggleState' { $val = Get-ScapeProperty -Object $st -PropertyName $dynKey; $dynText = if ($val) { ' [X]' } else { ' [ ]' } }
                    'CycleState' { $listPath = $dynCfg['List']; $cycle = Get-ScapeConstant -Path $listPath; if ($cycle -is [array]) { $curr = Get-ScapeProperty -Object $st -PropertyName $dynKey; $dynText = " [$curr]" } }
                    'CycleLabel' { $labelsPath = $dynCfg['Labels']; $labels = Get-ScapeConstant -Path $labelsPath; if ($labels -is [array]) { $curr = Get-ScapeProperty -Object $st -PropertyName $dynKey; if ($curr -ge 0 -and $curr -lt $labels.Count) { $dynText = " [$($labels[$curr])]" } } }
                }
            }

            [PSCustomObject]@{
                Id          = $id
                TitleKey    = $titleKey
                Type        = $type
                Icon        = $icon
                DynamicText = $dynText
                Hint        = $hint
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
        [Parameter()][hashtable]$Payload
    )
    process {
        $st = Get-ScapeColdState
        $mutated = $false
        $key = Get-ScapeProperty -Object $Payload -PropertyName 'Key'
        $op = Get-ScapeProperty -Object $Payload -PropertyName 'Value'
        if ([string]::IsNullOrWhiteSpace($key)) { return $false }
        switch ($op) {
            'TOGGLE' {
                $curr = Get-ScapeProperty -Object $st -PropertyName $key
                $new = -not $curr
                Set-ScapeSettingMutation -Key $key -Value $new | Out-Null
                $mutated = $true
            }
            'CYCLE' {
                $cycle = Get-ScapeConstant -Path "ui::CycleLists::$key"
                if ($cycle -is [array] -and $cycle.Count -gt 0) {
                    $curr = Get-ScapeProperty -Object $st -PropertyName $key
                    $idx = [array]::IndexOf($cycle, $curr)
                    $new = if ($idx -ge 0 -and $idx -lt $cycle.Count - 1) { $cycle[$idx + 1] } else { $cycle[0] }
                    Set-ScapeSettingMutation -Key $key -Value $new | Out-Null
                    $mutated = $true
                }
            }
        }
        return $mutated
    }
}
