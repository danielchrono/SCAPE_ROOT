<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Watchdog
    Architecture: Out-of-band execution integrity monitor (Runspace).
#>

$Script:ScapeHeartbeat = [DateTime]::UtcNow
$Script:WatchdogRunspace = $null
$Script:WatchdogPowerShell = $null

function Initialize-ScapeWatchdog {
    if ($null -ne $Script:WatchdogRunspace) { return }

    $Script:WatchdogRunspace = [runspacefactory]::CreateRunspace()
    $Script:WatchdogRunspace.ApartmentState = "STA"
    $Script:WatchdogRunspace.ThreadOptions = "ReuseThread"
    $Script:WatchdogRunspace.Open()

    $Script:WatchdogRunspace.SessionStateProxy.SetVariable("ScapeHeartbeat", $Script:ScapeHeartbeat)

    $eventQueue = if (Get-Command Get-ScapeEventQueue -ErrorAction SilentlyContinue) { Get-ScapeEventQueue } else { $null }
    $Script:WatchdogRunspace.SessionStateProxy.SetVariable("EventQueue", $eventQueue)

    $Script:WatchdogPowerShell = [powershell]::Create()
    $Script:WatchdogPowerShell.Runspace = $Script:WatchdogRunspace

    [void]$Script:WatchdogPowerShell.AddScript({
            while ($true) {
                Start-Sleep -Seconds 2
                $diff = ([DateTime]::UtcNow - $ScapeHeartbeat).TotalSeconds

                if ($diff -gt 15) {
                    $EventFrame = [PSCustomObject]@{
                        Timestamp = [datetime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                        Type      = "SYSTEM_CRASH"
                        Severity  = "LOG_FATAL"
                        Payload   = [PSCustomObject]@{ Context = "WATCHDOG"; Message = "SYSTEM DEADLOCK DETECTED. Core thread unresponsive for $diff seconds." }
                    }
                    if ($null -ne $EventQueue) { $EventQueue.Enqueue($EventFrame) }
                    break
                }
            }
        })

    [void]$Script:WatchdogPowerShell.BeginInvoke()

    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "WATCHDOG_ONLINE"; Severity = "LOG_INFO" }
    }
}

function Update-ScapeHeartbeat {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param()
    if ($PSCmdlet.ShouldProcess("Watchdog", "Heartbeat")) {
        $Script:ScapeHeartbeat = [DateTime]::UtcNow
        if ($null -ne $Script:WatchdogRunspace) {
            $Script:WatchdogRunspace.SessionStateProxy.SetVariable("ScapeHeartbeat", $Script:ScapeHeartbeat)
        }
    }
}