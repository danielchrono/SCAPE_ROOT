<#.SYNOPSIS
    Domain: Acquisition
    Module: Scape.Acquisition.Selection
    Description: Discovers and maps physical drives and logical volumes using WMI/CIM.
#>

function Get-ScapePhysicalTarget {
    <#
    .DESCRIPTION
        Retorna todos os discos físicos atrelados ao host para varredura forense profunda.
    #>
    try {
        $drives = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction Stop
        $results = [System.Collections.Generic.List[PSCustomObject]]::new()

        foreach ($d in $drives) {
            $results.Add([PSCustomObject]@{
                    DeviceID     = $d.DeviceID      # Ex: \\.\PHYSICALDRIVE0
                    Model        = $d.Model
                    Size         = [long]$d.Size
                    Partitions   = $d.Partitions
                    SerialNumber = $d.SerialNumber
                    IsSystem     = ($d.Index -eq 0) # Heurística simples, aprimorar depois
                })
        }
        return $results
    }
    catch {
        $enumFailMsg = Get-ScapeLogMsg -Key "INVENTORY_WMI_FAIL"
        Publish-ScapeEvent -Type "LOG_ERR" -Payload @{ Action = "LogLine"; Message = $enumFailMsg }
        return $null
    }
}
Register-ScapeActionHandler -Target 'Scape.Acquisition.Selection' -Handler {
    param($Task, $PayloadDef, $Target)
    if (Get-Command Get-ScapePhysicalTarget -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "INVENTORY_PHYSICAL_DISKS"; Targets = @(Get-ScapePhysicalTarget) }
    } else { throw "Not Implemented" }
}

# --- INJECTED I18N KEYS ---
# INVENTORY_LOGICAL_VOLUMES
# VOLUME_ACCESS_DENIED
# VOLUME_NO_TARGETS
# VOLUME_SELECTION_INDEX
# VOLUME_SELECTION_PROMPT
# VOLUME_TYPE_APFS
# VOLUME_TYPE_BTRFS
# VOLUME_TYPE_EXFAT
# VOLUME_TYPE_EXT4
# VOLUME_TYPE_FAT32
# VOLUME_TYPE_NTFS
# VOLUME_TYPE_UNKNOWN
# VOLUME_TYPE_XFS
# VOLUME_TYPE_ZFS


# --- INJECTED I18N KEYS ---
# INVENTORY_LOGICAL_VOLUMES
# VOLUME_ACCESS_DENIED
# VOLUME_NO_TARGETS
# VOLUME_SELECTION_INDEX
# VOLUME_SELECTION_PROMPT
# VOLUME_TYPE_APFS
# VOLUME_TYPE_BTRFS
# VOLUME_TYPE_EXFAT
# VOLUME_TYPE_EXT4
# VOLUME_TYPE_FAT32
# VOLUME_TYPE_NTFS
# VOLUME_TYPE_UNKNOWN
# VOLUME_TYPE_XFS
# VOLUME_TYPE_ZFS
