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
    } catch {
        Publish-ScapeEvent -Type "LOG_ERR" -Payload @{ Action="LogLine"; Message="Failed to enumerate physical targets: $($_.Exception.Message)" }
        return $null
    }
}

