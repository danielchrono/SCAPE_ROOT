<#
.SYNOPSIS
    Domain: Core
    Module: Scape.Core.HardwareProfile
    Description: Runtime hardware detection and adaptive profile selection.
    Architecture: FP Strict | Zero Side-Effects | Constant-Driven
#>

$Script:C = $null
$Script:ActiveProfile = $null
function Initialize-ScapeHardwareProfile {
    $Script:C = @{
        HW       = Get-ScapeConstant -Path "hardware" -Fallback @{}
        BEHAVIOR = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
    }

    # Detect hardware at runtime (safe fallbacks)
    $detected = @{
        RAM_GB       = 8
        CPU_CORES    = 4
        STORAGE_TYPE = "STATE_UNKNOWN"
        IS_ADMIN     = $false
        PS_EDITION   = $PSVersionTable.PSEdition
    }

    try {
        # RAM
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $ram = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
            $detected.RAM_GB = [math]::Round($ram.TotalPhysicalMemory / 1GB)
        }

        # CPU
        $detected.CPU_CORES = [int]$env:NUMBER_OF_PROCESSORS

        # Storage type
        try {
            $disk = Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq 0 }
            if ($disk.BusType -eq 'NVMe') { $detected.STORAGE_TYPE = "NVME" }
            elseif ($disk.MediaType -eq 'SSD') { $detected.STORAGE_TYPE = "SSD" }
            elseif ($disk.MediaType -eq 'HDD') { $detected.STORAGE_TYPE = "HDD" }
            else { $detected.STORAGE_TYPE = "USB" }
        }
        catch { $detected.STORAGE_TYPE = "STATE_UNKNOWN" }

        # Admin check
        try {
            $principal = [Security.Principal.WindowsPrincipal]::new(
                [Security.Principal.WindowsIdentity]::GetCurrent()
            )
            $detected.IS_ADMIN = $principal.IsInRole(
                [Security.Principal.WindowsBuiltInRole]::Administrator
            )
        }
        catch { $detected.IS_ADMIN = $false }
    }
    catch {
        Publish-ScapeEvent -Type "LOG_WARN" -Payload @{
            Action = "LogLine"; Key = "HW_DETECT_FALLBACK"; Args = @($_.Exception.Message)
        }
    }

    # Merge detected values into constants
    $Script:C.HW.DETECTED = $detected

    # Select profile (agora usando os safeguards e profiles)
    $Script:ActiveProfile = Select-ScapeHardwareProfile -Detected $detected

    # Publish for other modules
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "HW_PROFILE_SELECTED"
        Args     = @($Script:ActiveProfile)
        Severity = "LOG_INFO"
    }

    return $Script:ActiveProfile
}

function Select-ScapeHardwareProfile {
    param([hashtable]$Detected)

    # Pega os perfis e salvaguardas DEFINIDOS (agora USADOS)
    $profiles = $Script:C.HW.PROFILES
    $safeguards = $Script:C.HW.SAFEGUARDS

    # Se não existir estrutura válida, usa fallback duro
    if (-not $profiles -or $profiles.Count -eq 0) {
        $profiles = @{
            SERVER      = $true
            WORKSTATION = $true
            STANDARD    = $true
            MINIMUM     = $true
        }
    }
    if (-not $safeguards) { $safeguards = @{} }

    # --- 1. Score baseado em hardware bruto (original) ---
    $score = 0
    $score += if ($Detected.RAM_GB -ge 64) { 3 } elseif ($Detected.RAM_GB -ge 32) { 2 } elseif ($Detected.RAM_GB -ge 16) { 1 } else { 0 }
    $score += if ($Detected.CPU_CORES -ge 16) { 3 } elseif ($Detected.CPU_CORES -ge 8) { 2 } elseif ($Detected.CPU_CORES -ge 4) { 1 } else { 0 }
    $score += switch ($Detected.STORAGE_TYPE) { "NVME" { 3 }; "SSD" { 2 }; "HDD" { 1 }; default { 0 } }

    # Seleção inicial por score
    $candidate = "MINIMUM"
    if ($score -ge 7) { $candidate = "SERVER" }
    elseif ($score -ge 5) { $candidate = "WORKSTATION" }
    elseif ($score -ge 3) { $candidate = "STANDARD" }

    # --- 2. Aplicar safeguards (a porra que faltava) ---
    # Se o safeguard exigir RAM mínima para um perfil e o hardware não atingir, REBAIXA
    $ramMinServer = $safeguards["RAM_SERVER_MIN"] -as [int]
    if ($candidate -eq "SERVER" -and $ramMinServer -and $Detected.RAM_GB -lt $ramMinServer) {
        $candidate = "WORKSTATION"
        Publish-ScapeEvent -Type "LOG_INFO" -Payload @{
            Action = "LogLine"; Key = "HW_PROFILE_DOWNGRADED"
            Args = @("SERVER->WORKSTATION", "RAM $($Detected.RAM_GB)GB < $ramMinServer GB")
        }
    }

    $ramMinWorkstation = $safeguards["RAM_WORKSTATION_MIN"] -as [int]
    if ($candidate -eq "WORKSTATION" -and $ramMinWorkstation -and $Detected.RAM_GB -lt $ramMinWorkstation) {
        $candidate = "STANDARD"
        Publish-ScapeEvent -Type "LOG_INFO" -Payload @{
            Action = "LogLine"; Key = "HW_PROFILE_DOWNGRADED"
            Args = @("WORKSTATION->STANDARD", "RAM $($Detected.RAM_GB)GB < $ramMinWorkstation GB")
        }
    }

    $cpuMinServer = $safeguards["CPU_SERVER_MIN"] -as [int]
    if ($candidate -eq "SERVER" -and $cpuMinServer -and $Detected.CPU_CORES -lt $cpuMinServer) {
        $candidate = "WORKSTATION"
        Publish-ScapeEvent -Type "LOG_INFO" -Payload @{
            Action = "LogLine"; Key = "HW_PROFILE_DOWNGRADED"
            Args = @("SERVER->WORKSTATION", "CPU cores $($Detected.CPU_CORES) < $cpuMinServer")
        }
    }

    # --- 3. Garantir que o profile candidato existe no hash de profiles ---
    if (-not $profiles.ContainsKey($candidate)) {
        $candidate = "MINIMUM"
        Publish-ScapeEvent -Type "LOG_WARN" -Payload @{
            Action = "LogLine"; Key = "HW_PROFILE_MISSING"
            Args = @("$candidate não encontrado, usando MINIMUM")
        }
    }

    return $candidate
}

function Get-ScapeActiveProfile {
    if ($null -eq $Script:ActiveProfile) { Initialize-ScapeHardwareProfile | Out-Null }
    # Aqui sim usa o perfil (já usava, mas mantenho)
    return $Script:C.HW.PROFILES[$Script:ActiveProfile]
}

function Get-ScapeStorageTuning {
    param([string]$StorageType)
    if (-not $StorageType) { $StorageType = $Script:C.HW.DETECTED.STORAGE_TYPE }
    if ($null -ne $Script:C.HW.STORAGE[$StorageType]) {
        return $Script:C.HW.STORAGE[$StorageType]
    }
    else {
        return $Script:C.HW.STORAGE["HDD"]
    }
}

function Test-ScapeResourcePressure {
    param([string]$Resource = "RAM")
    try {
        switch ($Resource) {
            "RAM" {
                $mem = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
                $usedPct = ($mem.TotalVisibleMemorySize - $mem.FreeVisibleMemorySize) / $mem.TotalVisibleMemorySize
                # Safeguards sendo USADOS corretamente (já estavam)
                $warningPct = 1 - $Script:C.HW.SAFEGUARDS.RAM_WARNING_PCT
                $criticalPct = 1 - $Script:C.HW.SAFEGUARDS.RAM_CRITICAL_PCT
                return @{
                    Pressure = $usedPct
                    Warning  = $usedPct -gt $warningPct
                    Critical = $usedPct -gt $criticalPct
                }
            }
            default { return @{ Pressure = 0; Warning = $false; Critical = $false } }
        }
    }
    catch {
        return @{ Pressure = 0; Warning = $false; Critical = $false }
    }
}
