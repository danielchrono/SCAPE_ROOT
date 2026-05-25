<#
.SYNOPSIS
    Domain: Extensions | Module: Scape.Extensions.CloudSync
    Architecture: Robocopy Cloud Engine integration and pre-flight space checks.
#>

function Invoke-ScapeRobocopy {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][hashtable]$Flags,
        [string]$LogFile = $null
    )

    if (-not (Get-Command "robocopy.exe" -ErrorAction SilentlyContinue)) {
        return @{ Success = $false; ExitCode = -1; Error = "ROBOCOPY_MISSING" }
    }

    $argsList = [System.Collections.Generic.List[string]]::new()
    $argsList.Add("`"$Source`""); $argsList.Add("`"$Destination`"")

    foreach ($key in $Flags.Keys) {
        $val = $Flags[$key]
        if ($val -is [bool] -and $val) {
            if ($key -eq "COPYALL") { $argsList.Add("/COPYALL") }
            elseif ($key -eq "DCOPY_T") { $argsList.Add("/DCOPY:T") }
            else { $argsList.Add("/$key") }
        }
        elseif ($val -is [int]) {
            $argsList.Add("/{$key}:$val")
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($LogFile)) { $argsList.Add("/LOG:`"$LogFile`"") }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = "robocopy.exe"
    $psi.Arguments = $argsList -join " "
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    $out = $proc.StandardOutput.ReadToEnd()
    $proc.WaitForExit()

    $limit = Get-ScapeConstant -Path "system::LIMITS::SUCCESS_EXIT_CODE_MAX" -Fallback 8
    $success = ($proc.ExitCode -lt $limit)

    return @{ Success = $success; ExitCode = $proc.ExitCode; Output = $out }
}

function Get-ScapeSyncSpaceRequirement {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$StagingPath,
        [long[]]$MarkedIDs = @(),
        [string]$DbPath = $null
    )

    $reqBytes = 0
    if (-not [string]::IsNullOrWhiteSpace($DbPath) -and $MarkedIDs.Count -gt 0) {
        try {
            $conn = [System.Data.SQLite.SQLiteConnection]::new("Data Source=$DbPath;Version=3;Read Only=True")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT SUM(LengthBytes) FROM FragmentMap WHERE ObjectID IN ($($MarkedIDs -join ','))"
            $r = $cmd.ExecuteScalar()
            if ($r -is [long] -or $r -is [int]) { $reqBytes = [long]$r }
            $conn.Close()
        }
        catch {}
    }

    $availGB = if (Test-Path $StagingPath) { (Get-PSDrive -Name ($StagingPath.Substring(0, 1))).Free / 1GB } else { 0 }
    $reqGB = [math]::Round($reqBytes / 1GB, 2)

    return @{
        RequiredGB   = $reqGB
        AvailableGB  = $availGB
        IsSufficient = ($availGB -ge $reqGB)
    }
}