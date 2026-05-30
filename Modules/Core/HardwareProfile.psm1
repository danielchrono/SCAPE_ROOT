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
    $scores = Get-ScapeConstant -Path "system::HardwareScoring" -Fallback @{}
    $rt3 = if ($scores.RAM_TIER3) { $scores.RAM_TIER3 } else { 64 }
    $rt2 = if ($scores.RAM_TIER2) { $scores.RAM_TIER2 } else { 32 }
    $rt1 = if ($scores.RAM_TIER1) { $scores.RAM_TIER1 } else { 16 }
    $ct3 = if ($scores.CPU_TIER3) { $scores.CPU_TIER3 } else { 16 }
    $ct2 = if ($scores.CPU_TIER2) { $scores.CPU_TIER2 } else { 8 }
    $ct1 = if ($scores.CPU_TIER1) { $scores.CPU_TIER1 } else { 4 }

    $score = 0
    $score += if ($Detected.RAM_GB -ge $rt3) { 3 } elseif ($Detected.RAM_GB -ge $rt2) { 2 } elseif ($Detected.RAM_GB -ge $rt1) { 1 } else { 0 }
    $score += if ($Detected.CPU_CORES -ge $ct3) { 3 } elseif ($Detected.CPU_CORES -ge $ct2) { 2 } elseif ($Detected.CPU_CORES -ge $ct1) { 1 } else { 0 }
    $score += switch ($Detected.STORAGE_TYPE) { "NVME" { 3 }; "SSD" { 2 }; "HDD" { 1 }; default { 0 } }

    # Seleção inicial por score
    $candidate = "MINIMUM"
    $ss = if ($scores.SCORE_SERVER) { $scores.SCORE_SERVER } else { 7 }
    $sw = if ($scores.SCORE_WORKSTATION) { $scores.SCORE_WORKSTATION } else { 5 }
    $st = if ($scores.SCORE_STANDARD) { $scores.SCORE_STANDARD } else { 3 }

    if ($score -ge $ss) { $candidate = "SERVER" }
    elseif ($score -ge $sw) { $candidate = "WORKSTATION" }
    elseif ($score -ge $st) { $candidate = "STANDARD" }

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
            Args = @($candidate)
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













# --- INJECTED I18N KEYS ---
# HW_BAD_SECTOR_DETECT
# HW_CACHE_FLUSH
# HW_CONTROLLER_RESET
# HW_CPU
# HW_GPU
# HW_HDD
# HW_IO_RECOVERY
# HW_IO_THRASHING
# HW_NVME
# HW_PRESSURE_RESUME
# HW_PRESSURE_SUSPEND
# HW_RAM
# HW_SMART_FAIL
# HW_SSD
# HW_STORAGE_HEALTH
# HW_TBW_CRITICAL
# HW_TBW_WARN
# HW_THERMAL_CRIT
# HW_THERMAL_NORMALIZED
# HW_USB
# SPEC_LABEL_CPU
# SPEC_LABEL_OS
# SPEC_LABEL_RAM
# SPEC_LABEL_VIRT


# --- INJECTED I18N KEYS ---
# HW_BAD_SECTOR_DETECT
# HW_CACHE_FLUSH
# HW_CONTROLLER_RESET
# HW_CPU
# HW_GPU
# HW_HDD
# HW_IO_RECOVERY
# HW_IO_THRASHING
# HW_NVME
# HW_PRESSURE_RESUME
# HW_PRESSURE_SUSPEND
# HW_RAM
# HW_SMART_FAIL
# HW_SSD
# HW_STORAGE_HEALTH
# HW_TBW_CRITICAL
# HW_TBW_WARN
# HW_THERMAL_CRIT
# HW_THERMAL_NORMALIZED
# HW_USB
# SPEC_LABEL_CPU
# SPEC_LABEL_OS
# SPEC_LABEL_RAM
# SPEC_LABEL_VIRT
