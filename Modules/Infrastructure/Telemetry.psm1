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
