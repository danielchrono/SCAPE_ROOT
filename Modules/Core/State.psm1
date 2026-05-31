<#
.SYNOPSIS
    Domain: Foundation | Module: Scape.Core.State
    Description: Thread-safe Hybrid State Manager.
#>

$Script:HotStateCSharp = @"
using System.Threading;
namespace Scape.Core.Memory
{
    public sealed class HotTelemetry
    {
        private long _bytesRead;
        private long _badSectors;
        public long BytesRead => Interlocked.Read(ref _bytesRead);
        public long BadSectors => Interlocked.Read(ref _badSectors);
        public void AddBytes(long count) { Interlocked.Add(ref _bytesRead, count); }
        public void IncrementBadSector() { Interlocked.Increment(ref _badSectors); }
        public void Reset()
        {
            Interlocked.Exchange(ref _bytesRead, 0);
            Interlocked.Exchange(ref _badSectors, 0);
        }
    }
}
"@

$Script:ColdState = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
$Script:HotState = $null

function Initialize-ScapeState {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    process {
        try {
            if (-not ("Scape.Core.Memory.HotTelemetry" -as [type])) {
                Add-Type -TypeDefinition $Script:HotStateCSharp -Language CSharp -ErrorAction Stop
            }

            if ($null -eq $Script:HotState) {
                $Script:HotState = [Scape.Core.Memory.HotTelemetry]::new()
            }

            $null = $Script:ColdState.TryAdd("DATA_SESSION_ID", [guid]::NewGuid().ToString())
            $null = $Script:ColdState.TryAdd("IsAdmin", $false)
            $null = $Script:ColdState.TryAdd("LoadedLayers", [System.Collections.Concurrent.ConcurrentBag[string]]::new())
            $null = $Script:ColdState.TryAdd("Assets", [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new())
            $null = $Script:ColdState.TryAdd("Config", @{})

            return @{ Success = $true; Data = $Script:ColdState["DATA_SESSION_ID"]; Error = $null }
        }
        catch {
            return @{ Success = $false; Data = $null; Error = $_.Exception.Message }
        }
    }
}

function Update-ScapeColdState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$NewProperties
    )
    process {
        if ($PSCmdlet.ShouldProcess("StateEngine", "Update ColdState keys")) {
            foreach ($key in $NewProperties.Keys) {
                $null = $Script:ColdState.AddOrUpdate($key, $NewProperties[$key], {
                        param($k, $v)
                        $null = $v
                        return $NewProperties[$k]
                    }.GetNewClosure())
            }
            return @{ Success = $true; Data = $Script:ColdState; Error = $null }
        }
        return @{ Success = $false; Data = $null; Error = "SKIPPED_BY_SHOULDPROCESS" }
    }
}

function Get-ScapeColdState {
    [CmdletBinding()]
    [OutputType([System.Collections.Concurrent.ConcurrentDictionary[string, object]])]
    param()
    process {
        return $Script:ColdState
    }
}

function Get-ScapeHotState {
    [CmdletBinding()]
    [OutputType([object])]
    param()
    process {
        return $Script:HotState
    }
}

function Get-ScapeRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    process {
        $root = $Script:ColdState["ROOT"]
        if ($null -ne $root) {
            return [string]$root
        }
        else {
            return [string]::Empty
        }
    }
}

function Test-ScapeDevMode {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    process {
        $devMode = $Script:ColdState["DEV_MODE"]
        # Retorna o valor direto: se for null/false, retorna $false
        return [bool]$devMode
    }
}

function Get-ScapeManifest {
    [CmdletBinding()]
    [OutputType([object])]
    param()
    process {
        return $Script:ColdState["MANIFEST"]
    }
}

Export-ModuleMember -Function 'Initialize-ScapeState',
'Update-ScapeColdState',
'Get-ScapeColdState',
'Get-ScapeHotState',
'Get-ScapeRoot',
'Test-ScapeDevMode',
'Get-ScapeManifest'
