<#
.SYNOPSIS
    Domain: Presentation\Dispatcher
    Module: Scape.Presentation.Dispatcher
    Architecture: Pure Event Handler Composition | Semantic Abstraction | Zero Console Touch
#>
[CmdletBinding()] param()

function Test-ScapeUiEventCategory {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)]$IncomingEventData)
    process {
        $sev = $IncomingEventData.Severity
        $typ = $IncomingEventData.Type
        $pay = $IncomingEventData.Payload

        $out = @{
            Severity     = $sev
            Type         = $typ
            Payload      = $pay
            ShouldRender = $false
            RenderTarget = $null
            Priority     = 3
        }

        if ($sev -eq 'FATAL' -or $typ -eq 'SYSTEM_CRASH') {
            $out.ShouldRender = $true
            $out.RenderTarget = 'ModalOverlay'
            $out.Priority = 1
        }
        elseif ($typ -eq 'PROGRESS') {
            $out.ShouldRender = $true
            $out.RenderTarget = 'StatusBar'
            $out.Priority = 2
        }
        elseif ($typ -eq 'UI' -and $pay['Action'] -eq 'REDRAW_REQUEST') {
            $out.ShouldRender = $true
            $out.RenderTarget = 'MasterRedraw'
            $out.Priority = 0
        }
        elseif ($typ -match 'HINT|WARN|DEBUG|ROUTER|SYSTEM|INFO|ERROR') {
            $out.ShouldRender = $true
            $out.RenderTarget = 'TransientLog'
            $out.Priority = 3
        }
        return $out
    }
}

function Format-ScapeProgressBar {
    [CmdletBinding()]
    [OutputType([string])]
    param([hashtable]$Payload, [int]$BarWidth = 0)
    process {
        if ($BarWidth -le 0) { $BarWidth = Get-ScapeConstant -Path "ui::Config::DefaultBarWidth" -Fallback 30 }
        $stage = $Payload['Stage']
        $cur = [double]($Payload['Current'] -replace ',', '.')
        $tot = [double]($Payload['Total'] -replace ',', '.')

        $pct = 0
        if ($tot -gt 0) { $pct = [Math]::Min(100, ($cur / $tot) * 100) }

        # MVVM estrito: ProgressStyle deve vir do ViewModel/Payload (read-only), não de ColdState
        $styleName = if ($Payload.ContainsKey('ProgressStyle') -and -not [string]::IsNullOrWhiteSpace($Payload['ProgressStyle'])) { [string]$Payload['ProgressStyle'] } else { 'Default' }
        $barConfig = Get-ScapeConstant -Path "ui::Progress::$styleName"

        if ($barConfig.Frames) {
            $frameIndex = [Math]::Floor(($cur / $tot) * $barConfig.Frames.Count) % $barConfig.Frames.Count
            $frame = $barConfig.Frames[$frameIndex]
            return "$stage $frame"
        }

        $fc = $barConfig['FullChar']
        $ec = $barConfig['EmptyChar']
        $show = $barConfig['ShowPercent']

        $filled = [Math]::Floor(($pct / 100) * $BarWidth)
        $empty = [Math]::Max(0, $BarWidth - $filled)

        $pctTxt = if ($show) { " $([Math]::Round($pct))%" } else { "" }

        return "${stage} [$($fc * $filled)$($ec * $empty)]${pctTxt}"
    }
}

function Format-ScapeTransientMessage {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)]$IncomingEventData, [string]$Severity)
    process {
        $pay = $IncomingEventData.Payload
        $typ = $IncomingEventData.Type

        $msg = $pay['Message']
        if ([string]::IsNullOrWhiteSpace($msg)) {
            $k = $pay['Key']
            if ($k) {
                $msgArgs = if ($pay['Tokens']) { $pay['Tokens'] } else { @() }
                if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) {
                    $msg = Invoke-ScapeI18NFormat -Key $k -Args $msgArgs
                }
                else {
                    $i18n = Get-ScapeConstant -Path "i18n::$k"
                    $msg = if ($i18n -and $i18n.T) { $i18n.T } else { $k }
                    if ($args.Count -gt 0) { try { $msg = $msg -f $args } catch { Write-Verbose "Suppressed error:                     if ($args.Count -gt 0) { try { $msg = $msg -f $args } catch {} }"; } }
                }
            }
            else {
                $tgt = $pay['Target']
                if ($tgt) {
                    if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) {
                        $msg = Invoke-ScapeI18NFormat -Key "DISPATCHER_TARGET_LABEL" -Args @($tgt)
                    }
                    else {
                        $msg = "Target: $tgt"
                    }
                }
                else {
                    $msg = $typ
                }
            }
        }

        $iconKey = 'Info'
        switch ($typ) {
            'ROUTER_FATAL' { $iconKey = 'Failure' }
            'SYSTEM' { $iconKey = 'Info' }
            'PROGRESS' { $iconKey = 'Processing' }
            default {
                switch ($Severity) {
                    'FATAL' { $iconKey = 'Failure' }
                    'ERROR' { $iconKey = 'Failure' }
                    'WARN' { $iconKey = 'Warning' }
                    'DEBUG' { $iconKey = 'Bug' }
                }
            }
        }

        $flag = 'STATUS'
        if ($Severity -in @('ERROR', 'FATAL') -or $typ -match 'ERR|FATAL|FAULT') { $flag = 'FATAL' }
        elseif ($Severity -eq 'WARN' -or $typ -match 'WARN') { $flag = 'WARN' }
        elseif ($Severity -in @('DEBUG', 'TRACE') -or $typ -match 'DEBUG|TRACE') { $flag = 'DEBUG' }
        elseif ($typ -match 'HINT|SYSTEM|INFO') { $flag = 'HINT' }

        return @{ Text = $msg; Flag = $flag; SemanticIcon = $iconKey }
    }
}

function Convert-ScapeEventDataToRender {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)]$IncomingEventData)
    process {
        $cls = Test-ScapeUiEventCategory -IncomingEventData $IncomingEventData
        if (-not $cls.ShouldRender) { return @{ ShouldRender = $false } }

        switch ($cls.RenderTarget) {
            'TreeViewPanel' {
                $treeCfg = Convert-ScapeTreeToRender -IncomingEventData $IncomingEventData
                return @{ Type = 'TreeView'; Config = $treeCfg; ShouldRender = $true; Priority = 2 }
            }
            'MasterRedraw' {
                return @{ Type = 'Redraw'; ShouldRender = $true; Priority = 0 }
            }
            'ModalOverlay' {
                $msg = $cls.Payload['Message']
                return @{ Type = 'Modal'; Severity = $cls.Severity; Message = $msg; Priority = 1; ShouldRender = $true }
            }
            'StatusBar' {
                $txt = Format-ScapeProgressBar -Payload $cls.Payload
                return @{ Type = 'StatusBar'; Text = $txt; Flag = 'HINT'; Priority = 2; ShouldRender = $true }
            }
            'TransientLog' {
                $m = Format-ScapeTransientMessage -IncomingEventData $IncomingEventData -Severity $cls.Severity
                return @{ Type = 'Transient'; Text = $m.Text; Flag = $m.Flag; SemanticIcon = $m.SemanticIcon; Priority = 3; ShouldRender = $true }
            }
            default { return @{ ShouldRender = $false } }
        }
    }
}

function Convert-ScapeTreeToRender {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$IncomingEventData)
    process {
        $pay = $IncomingEventData.Payload
        $nodes = $pay['Nodes']
        $treeId = $pay['TreeId']
        $titleKey = $pay['TitleKey']

        $flatRenderList = @()
        if ($nodes) {
            foreach ($node in $nodes) {
                $path = $node['Path']
                $depth = if ($path) { ($path -split '[/\\]').Count - 1 } else { 0 }
                $name = ($path -split '[/\\]')[-1]

                $iconKey = $node['Icon']
                $status = $node['Status']

                $statusFlag = switch ($status) {
                    'Ready' { 'Success' }
                    'Loading' { 'Loading' }
                    'Error' { 'Failure' }
                    'Vital' { 'Warning' }
                    default { 'Info' }
                }

                $flatRenderList += @{
                    Text         = $name
                    SemanticIcon = $iconKey
                    Depth        = $depth
                    Status       = $status
                    StatusFlag   = $statusFlag
                    RawPath      = $path
                }
            }
        }

        return @{
            Type         = 'TreeView'
            TreeId       = $treeId
            TitleKey     = $titleKey
            Items        = $flatRenderList
            ShouldRender = $true
            Priority     = 2
        }
    }
}

Export-ModuleMember -Function 'Test-ScapeUiEventCategory',
'Format-ScapeProgressBar',
'Format-ScapeTransientMessage',
'Convert-ScapeEventDataToRender',
'Convert-ScapeTreeToRender'
