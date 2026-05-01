<#
.SYNOPSIS
    Domain: Presentation\StateObserver
    Module: Scape.Presentation.StateObserver
    Architecture: Pure Event Listener | Zero Rendering | Zero Mutation | Observer Pattern
    Status: Standby Module (Ready for EventBus Hook)
#>
[CmdletBinding()] param()

function Initialize-ScapeStateObserver {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param(
        [Parameter()][string]$FilterPattern = '*',
        [Parameter()][switch]$AutoRegister
    )
    process {
        if ($PSCmdlet.ShouldProcess("State Observer", "Initialize with pattern $FilterPattern")) {
            $config = @{
                FilterPattern      = $FilterPattern
                IsActive           = $false
                RegisteredHandlers = @()
            }

            if ($AutoRegister -and (Get-Command Register-ScapeEventListener -ErrorAction SilentlyContinue)) {
                $handler = {
                    param($IncomingEventData)
                    if (Get-Command Convert-ScapeEventDataToRender -ErrorAction SilentlyContinue) {
                        $render = Convert-ScapeEventDataToRender -IncomingEventData $IncomingEventData
                        if ($render.ShouldRender) { return $render }
                    }
                    return $null
                }

                $registration = Register-ScapeEventListener -EventMatch $FilterPattern -Action $handler
                $config.IsActive = $true
                $config.RegisteredHandlers += $registration
            }
            return $config
        }
        return @{}
    }
}

function Convert-ScapeObservedEventData {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]$IncomingEventData,
        [Parameter()][string]$FilterPattern = '*'
    )
    process {
        if ($FilterPattern -ne '*' -and $IncomingEventData.Type -notlike $FilterPattern) {
            return @{ ShouldProcess = $false }
        }

        $renderConfig = if (Get-Command Convert-ScapeEventDataToRender -ErrorAction SilentlyContinue) {
            Convert-ScapeEventDataToRender -IncomingEventData $IncomingEventData
        }
        else {
            @{ ShouldRender = $false }
        }

        return @{
            ShouldProcess     = $true
            IncomingEventData = $IncomingEventData
            RenderConfig      = $renderConfig
            Priority          = Get-ScapeProperty -Object $renderConfig -PropertyName 'Priority' -Fallback 99
        }
    }
}

function Invoke-ScapeEventBatchProcessing {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)][array]$EventCollection,
        [Parameter()][string]$FilterPattern = '*',
        [Parameter()][int]$MaxPriority = 3
    )
    process {
        $results = New-Object System.Collections.Generic.List[hashtable]
        foreach ($evt in $EventCollection) {
            $processed = Convert-ScapeObservedEventData -IncomingEventData $evt -FilterPattern $FilterPattern
            if ($processed.ShouldProcess -and $processed.RenderConfig.ShouldRender) {
                if ($processed.Priority -le $MaxPriority) { $results.Add($processed.RenderConfig) }
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