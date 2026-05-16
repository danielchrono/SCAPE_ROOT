<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Watchdog
    Description: Out-of-band execution integrity monitor (Runspace).
#>

$Script:ScapeHeartbeat = [DateTime]::UtcNow
$Script:WatchdogRunspace = $null
$Script:WatchdogPowerShell = $null

function Initialize-ScapeWatchdog {
    [CmdletBinding()]
    param()

    # --- 1. CLÁUSULA DE GUARDA (SINGLETON) ---
    if ($Script:WatchdogRunspace) { return $true }

    try {
        # --- 2. CONFIGURAÇÃO E PARÂMETROS (SAFE 5.1) ---

        # Fallback para Intervalo
        $intervalMs = Get-ScapeConstant -Path "system::system::WATCHDOG_INTERVAL_MS"
        if ($null -eq $intervalMs) {
            $intervalMs = 2000
        }

        $timeoutSec = 15 # Timeout fixo de segurança (Hard Deadline)

        # Fallback para EventQueue (Tratamento explícito)
        $eventQueue = $null
        if (Get-Command Get-ScapeEventQueue -ErrorAction SilentlyContinue) {
            $eventQueue = Get-ScapeEventQueue
        }

        # --- 3. INFRAESTRUTURA DE RUNSPACE (ISOLAMENTO) ---
        $Script:WatchdogRunspace = [RunspaceFactory]::CreateRunspace()
        $Script:WatchdogRunspace.ApartmentState = "STA"
        $Script:WatchdogRunspace.ThreadOptions = "ReuseThread"
        $Script:WatchdogRunspace.Open()

        # Injeção de dependências no estado do Runspace
        $proxy = $Script:WatchdogRunspace.SessionStateProxy
        $proxy.SetVariable("ScapeHeartbeat", $Script:ScapeHeartbeat)
        $proxy.SetVariable("EventQueue", $eventQueue)

        # --- 4. SCRIPTBLOCK DO SENTINELA (LÓGICA AUTÔNOMA) ---
        $sentinelBlock = {
            param($interval, $timeout, $queue)

            # Proxy interno para i18n
            $getMsgCmd = Get-Command Get-ScapeLogMsg -ErrorAction SilentlyContinue

            while ($true) {
                Start-Sleep -Milliseconds $interval

                $idleTime = ([DateTime]::UtcNow - $ScapeHeartbeat).TotalSeconds

                if ($idleTime -gt $timeout) {
                    $errorMsg = if ($getMsgCmd) {
                        & $getMsgCmd -Key "ROUTER_FATAL" -MsgArgs @("SYSTEM DEADLOCK: Core unresponsive for $idleTime seconds.")
                    }
                    else {
                        "SYSTEM DEADLOCK: Core unresponsive for $idleTime seconds."
                    }

                    $crashFrame = [PSCustomObject]@{
                        Timestamp = [datetime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                        Type      = "SYSTEM_CRASH"
                        Severity  = "LOG_FATAL"
                        Payload   = @{ Context = "WATCHDOG"; Message = $errorMsg }
                    }

                    # Disparo de emergência
                    if ($queue) { $queue.Enqueue($crashFrame) }
                    break # Watchdog morre com o sistema
                }
            }
        }

        # --- 5. INVOCAÇÃO ASSÍNCRONA ---
        $Script:WatchdogPowerShell = [powershell]::Create()
        $Script:WatchdogPowerShell.Runspace = $Script:WatchdogRunspace

        $null = $Script:WatchdogPowerShell.AddScript($sentinelBlock).AddArgument($intervalMs).AddArgument($timeoutSec).AddArgument($eventQueue)
        $null = $Script:WatchdogPowerShell.BeginInvoke()

        # --- 6. NOTIFICAÇÃO DE ATIVAÇÃO ---
        Publish-ScapeEvent -Type "SYS_CORE" -Severity "LOG_INFO" -Payload @{
            Action  = "LogLine"
            Key     = "CORE_KERNEL_SHIELD_ACTIVE"
            Message = Get-ScapeLogMsg -Key "CORE_KERNEL_SHIELD_ACTIVE"
        }

        return $true
    }
    catch {
        # Em caso de falha crítica no Watchdog, o sistema não deve subir sem proteção
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) {
            Publish-ScapeFault -ErrorRecord $_ -Context "Watchdog_Init"
        }
        return $false
    }
}

function Update-ScapeHeartbeat {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()
    if ($PSCmdlet.ShouldProcess("Watchdog", "Heartbeat")) {
        $Script:ScapeHeartbeat = [DateTime]::UtcNow
        if ($Script:WatchdogRunspace) {
            $Script:WatchdogRunspace.SessionStateProxy.SetVariable("ScapeHeartbeat", $Script:ScapeHeartbeat)
        }
    }
}