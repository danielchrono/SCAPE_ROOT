<#
.SYNOPSIS
    Domain: Presentation\Dispatcher
    Module: Scape.Presentation.Dispatcher
    Architecture: Pure Event Handler Composition | Zero Rendering | SoC Compliant
#>
[CmdletBinding()] param()

function Test-ScapeUiEventCategory {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)]$IncomingEventData)
    process {
        $sev = Get-ScapeProperty -Object $IncomingEventData -PropertyName 'Severity' -Fallback 'INFO'
        $typ = Get-ScapeProperty -Object $IncomingEventData -PropertyName 'Type' -Fallback 'UNKNOWN'
        $pay = Get-ScapeProperty -Object $IncomingEventData -PropertyName 'Payload' -Fallback @{}

        $out = @{ Severity = $sev; Type = $typ; Payload = $pay; ShouldRender = $false; RenderTarget = $null; Priority = 3 }
        if ($sev -eq 'FATAL' -or $typ -eq 'SYSTEM_CRASH') { $out.ShouldRender = $true; $out.RenderTarget = 'ModalOverlay'; $out.Priority = 1 }
        elseif ($typ -eq 'PROGRESS') { $out.ShouldRender = $true; $out.RenderTarget = 'StatusBar'; $out.Priority = 2 }
        elseif ($typ -match 'HINT|WARN|DEBUG|ROUTER') { $out.ShouldRender = $true; $out.RenderTarget = 'TransientLog'; $out.Priority = 3 }
        return $out
    }
}

function Format-ScapeProgressBar {
    [CmdletBinding()]
    [OutputType([string])]
    param([hashtable]$Payload, [int]$BarWidth = 20)
    process {
        $stage = Get-ScapeProperty -Object $Payload -PropertyName 'Stage' -Fallback 'Processing'
        $cur = [double](Get-ScapeProperty -Object $Payload -PropertyName 'Current' -Fallback 0)
        $tot = [double](Get-ScapeProperty -Object $Payload -PropertyName 'Total' -Fallback 0)
        $pct = if ($tot -gt 0) { [Math]::Min(100, ($cur / $tot) * 100) } else { 0 }

        $bar = Get-ScapeConstant -Path "ui::Progress::Default" -Fallback @{}
        $fc = Get-ScapeProperty -Object $bar -PropertyName 'FullChar' -Fallback '█'
        $ec = Get-ScapeProperty -Object $bar -PropertyName 'EmptyChar' -Fallback '░'
        $show = Get-ScapeProperty -Object $bar -PropertyName 'ShowPercent' -Fallback $true

        $filled = [Math]::Floor(($pct / 100) * $BarWidth)
        $empty = [Math]::Max(0, $BarWidth - $filled)
        $pctTxt = if ($show) { " $([Math]::Round($pct))%" } else { '' }
        return "${stage} [$($fc * $filled)$($ec * $empty)]${pctTxt}"
    }
}

function Format-ScapeTransientMessage {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)]$IncomingEventData, [string]$Severity = 'INFO')
    process {
        $pay = Get-ScapeProperty -Object $IncomingEventData -PropertyName 'Payload' -Fallback @{}
        $typ = Get-ScapeProperty -Object $IncomingEventData -PropertyName 'Type' -Fallback 'UNKNOWN'
        $msg = Get-ScapeProperty -Object $pay -PropertyName 'Message' -Fallback ''
        if ([string]::IsNullOrWhiteSpace($msg)) {
            $k = Get-ScapeProperty -Object $pay -PropertyName 'Key' -Fallback ''
            if (-not [string]::IsNullOrWhiteSpace($k)) {
                $resolved = Get-ScapeLogMsg -Key $k
                if (-not [string]::IsNullOrWhiteSpace($resolved)) { $msg = $resolved } else { $msg = $k }
            }
        }
        if ([string]::IsNullOrWhiteSpace($msg)) { $msg = $typ }

        $iconKey = switch ($typ) {
            'ROUTER_FAULT' { 'Bug' }
            default {
                switch ($Severity) {
                    'ERROR' { 'Failure' }
                    'WARNING' { 'Warning' }
                    'DEBUG' { 'Bug' }
                    default { 'Info' }
                }
            }
        }
        $icon = Get-ScapeConstant -Path "icon::$iconKey" -Fallback '•'

        $flag = 'STATUS'
        if ($Severity -in @('ERROR', 'FATAL') -or $typ -match 'ERR|FATAL|FAULT') { $flag = 'FATAL' }
        elseif ($Severity -eq 'WARNING' -or $typ -match 'WARN') { $flag = 'WARN' }
        elseif ($Severity -in @('DEBUG', 'TRACE') -or $typ -match 'DEBUG|TRACE') { $flag = 'DEBUG' }
        elseif ($typ -match 'HINT|SYSTEM') { $flag = 'HINT' }
        return @{ Text = "${icon} ${msg}"; Flag = $flag }
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
            'ModalOverlay' { return @{ Type = 'Modal'; Severity = $cls.Severity; Message = Get-ScapeProperty -Object $cls.Payload -PropertyName 'Message' -Fallback 'System error'; Priority = 1 } }
            'StatusBar' { $txt = Format-ScapeProgressBar -Payload $cls.Payload; return @{ Type = 'StatusBar'; Text = $txt; Flag = 'HINT'; Priority = 2 } }
            'TransientLog' { $m = Format-ScapeTransientMessage -IncomingEventData $IncomingEventData -Severity $cls.Severity; return @{ Type = 'Transient'; Text = $m.Text; Flag = $m.Flag; Priority = 3 } }
            default { return @{ ShouldRender = $false } }
        }
    }
}