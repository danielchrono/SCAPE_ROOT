<#
.SYNOPSIS
    Domain: Diagnostics | Module: Scape.Diagnostics.UXSimulator
    Description: Injects virtual user inputs (arrow keys, select) into the orchestration layer
                 to validate UI state transitions and view renderer robustness.
#>

function Start-ScapeUXSimulation {
    [CmdletBinding()]
    param([int]$Steps = 50, [int]$DelayMs = 250)

    Publish-ScapeEvent -Type "SIMULATION_START" -Severity "WARN" -Payload @{ Message = "Commencing automated UX sequence ($Steps steps)." }

    $testSequence = @(
        'DOWN', 'DOWN', 'UP', 'SELECT', 'DOWN', 'LEFT', 'RIGHT', 'BACK'
    )

    $global:UXSimState = @{
        Idx   = 0
        Steps = $Steps
        Seq   = $testSequence
    }

    $timer = New-Object System.Timers.Timer
    $timer.Interval = $DelayMs
    $timer.AutoReset = $true

    $action = {
        if ($global:UXSimState.Idx -ge $global:UXSimState.Steps) {
            $EventSubscriber.SourceObject.Stop()
            $EventSubscriber.SourceObject.Dispose()
            Unregister-Event -SourceIdentifier $EventSubscriber.SourceIdentifier
            return
        }

        $key = $global:UXSimState.Seq[$global:UXSimState.Idx % $global:UXSimState.Seq.Count]
        if (Get-Command Send-ScapeVirtualInput -ErrorAction SilentlyContinue) {
            Send-ScapeVirtualInput -Key $key
        }
        $global:UXSimState.Idx++
    }

    Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $action -SourceIdentifier "UXSimulatorPump" | Out-Null
    $timer.Start()
}

Export-ModuleMember -Function 'Start-ScapeUXSimulation'
