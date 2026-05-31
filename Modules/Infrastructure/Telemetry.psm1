<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Telemetry
    Description: Real-time hardware health monitoring and WMI polling.
#>

$Script:Metrics = @{
    RAM     = @{ Current = 0; Peak = 0; Warning = $false; Critical = $false }
    CPU     = @{ Current = 0; Peak = 0; Warning = $false; Critical = $false }
    Thermal = @{ Current = 0; Peak = 0; Warning = $false; Critical = $false }
    IO      = @{ QueueDepth = 0; Warning = $false; Critical = $false }
}
$Script:MonitorActive = $false

function Initialize-ScapeTelemetry {
    $Script:MonitorActive = $true
    $msgActivate = Get-ScapeLogMsg -Key "CORE_ENGINE_START" -MsgArgs @()
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "CORE_ENGINE_START"
        Args     = @()
        Severity = "LOG_INFO"
        Message  = $msgActivate
    }
    return $true
}

function Get-ScapeTelemetryCpu {
    try {
        if ($IsWindows -and $PSVersionTable.PSVersion.Major -ge 3) {
            $cpu = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
            return [Math]::Round($cpu, 1)
        }
    }
    catch { Publish-ScapeFault -ErrorRecord $_ -Context "Telemetry_CPU" -ErrorAction SilentlyContinue }
    return 0
}

function Get-ScapeTelemetryRam {
    try {
        if ($IsWindows) {
            $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
            $used = $os.TotalVisibleMemorySize - $os.FreeVisibleMemorySize
            return [Math]::Round(($used / $os.TotalVisibleMemorySize) * 100, 1)
        }
    }
    catch { Publish-ScapeFault -ErrorRecord $_ -Context "Telemetry_RAM" -ErrorAction SilentlyContinue }
    return 0
}

function Get-ScapeTelemetryThermal {
    try {
        if ($IsWindows) {
            $thermal = Get-CimInstance -Class MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ErrorAction Stop
            if ($thermal) {
                $kelvin = $thermal.CurrentTemperature / 10
                return [Math]::Round($kelvin - 273.15, 1)
            }
        }
    }
    catch { }
    return -1
}

function Get-ScapeTelemetryIo {
    try {
        if ($IsWindows) {
            $queue = (Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length' -ErrorAction Stop).CounterSamples.CookedValue
            return [Math]::Round($queue, 1)
        }
    }
    catch { Publish-ScapeFault -ErrorRecord $_ -Context "Telemetry_IO" -ErrorAction SilentlyContinue }
    return 0
}

function Get-ScapeTelemetrySnapshot {
    return [PSCustomObject]@{
        Timestamp = [DateTime]::UtcNow
        Metrics   = @{
            RAM     = $Script:Metrics.RAM.PSObject.Copy()
            CPU     = $Script:Metrics.CPU.PSObject.Copy()
            Thermal = $Script:Metrics.Thermal.PSObject.Copy()
            IO      = $Script:Metrics.IO.PSObject.Copy()
        }
    }
}

function Invoke-ScapeTelemetryWorkflow {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Task)

    switch ($Task) {
        'INVENTORY' {
            Publish-ScapeEvent -Type "INVENTORY_MANAGER" -Severity "INFO" -Payload (Get-ScapeI18NNode -Key "INVENTORY_PHYSICAL_DISKS").Hint
            try {
                $disks = Get-CimInstance Win32_DiskDrive -ErrorAction Stop
                $vols = Get-Volume | Where-Object DriveLetter -ErrorAction Stop
                Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Disks = $disks; Volumes = $vols }
            }
            catch {
                Publish-ScapeEvent -Type "INVENTORY_FATAL" -Severity "ERROR" -Payload (Get-ScapeI18NNode -Key "INVENTORY_WMI_FAIL").Hint
            }
        }
        'TOPOLOGY' {
            try {
                $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
                $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
                $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
                $isVm = ($cs.Model -match "Virtual|VMware|KVM" -or $cs.Manufacturer -match "VMware|Microsoft")
                $hyp = if ($isVm) { if ($cs.Model -match "VMware") { "VMware" } else { $cs.Model } } else { "BARE_METAL" }

                $topo = @{
                    CPU   = $cpu.Name.Trim()
                    RAM   = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
                    OS    = "$($os.Caption) ($($os.OSArchitecture))"
                    VM    = @{ IsVirtual = $isVm; Hypervisor = $hyp }
                    Host  = $env:COMPUTERNAME
                    User  = "$env:USERNAME@$env:USERDOMAIN"
                    Admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                }
                Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload $topo
            }
            catch {
                Publish-ScapeEvent -Type "INVENTORY_FATAL" -Severity "ERROR" -Payload (Get-ScapeI18NNode -Key "INVENTORY_WMI_FAIL").Hint
            }
        }
        'TELEMETRY' {
            $temp = Get-ScapeTelemetryThermal
            $queue = Get-ScapeTelemetryIo
            $ram = Get-ScapeTelemetryRam
            $cpu = Get-ScapeTelemetryCpu

            $critT = Get-ScapeConstant -Path "hardware::Metrics::ThermalCritical" -Fallback 85
            $warnT = Get-ScapeConstant -Path "hardware::Metrics::ThermalWarning" -Fallback 75
            $critQ = Get-ScapeConstant -Path "hardware::Limits::IoQueueCritical" -Fallback 10
            $warnQ = Get-ScapeConstant -Path "hardware::Limits::IoQueueWarning" -Fallback 5

            $actionNeeded = ($temp -ge $critT) -or ($queue -ge $critQ)

            $metrics = @{
                Thermal      = @{ Value = $temp; Critical = ($temp -ge $critT); Warning = ($temp -ge $warnT) }
                IO           = @{ Value = $queue; Critical = ($queue -ge $critQ); Warning = ($queue -ge $warnQ) }
                Ram          = @{ UsedPct = $ram }
                CPU          = @{ UsedPct = $cpu }
                ActionNeeded = $actionNeeded
            }
            
            # Atualiza o cache global (Correção do bug de zeros contínuos apontado pelo auditor)
            $Script:Metrics.Thermal.Current = $temp
            $Script:Metrics.Thermal.Warning = $metrics.Thermal.Warning
            $Script:Metrics.Thermal.Critical = $metrics.Thermal.Critical
            if ($temp -gt $Script:Metrics.Thermal.Peak) { $Script:Metrics.Thermal.Peak = $temp }

            $Script:Metrics.IO.QueueDepth = $queue
            $Script:Metrics.IO.Warning = $metrics.IO.Warning
            $Script:Metrics.IO.Critical = $metrics.IO.Critical

            $Script:Metrics.RAM.Current = $ram
            if ($ram -gt $Script:Metrics.RAM.Peak) { $Script:Metrics.RAM.Peak = $ram }

            $Script:Metrics.CPU.Current = $cpu
            if ($cpu -gt $Script:Metrics.CPU.Peak) { $Script:Metrics.CPU.Peak = $cpu }
            
            if ($actionNeeded) {
                Publish-ScapeEvent -Type "TELEMETRY_CRITICAL" -Severity "FATAL" -Payload $metrics
            }
            else {
                Publish-ScapeEvent -Type "TELEMETRY_UPDATE" -Severity "INFO" -Payload $metrics
            }
        }
    }
}
