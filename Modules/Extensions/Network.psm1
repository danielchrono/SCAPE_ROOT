<#
.SYNOPSIS
    Domain: Extensions | Module: Scape.Extensions.Network
    Architecture: SMB/CIFS Network Discovery and Mounting
#>

function Find-ScapeNetworkNode {
    [CmdletBinding()]
    [OutputType([string[]])]
    param([string]$SubnetRoot)

    if ([string]::IsNullOrWhiteSpace($SubnetRoot)) {
        $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
        if (-not $gw) { return @() }
        $SubnetRoot = $gw -replace '\.\d+$', ''
    }

    $port = Get-ScapeConstant -Path "network::PROTOCOLS::SMB_PORT" -Fallback 445
    $timeout = Get-ScapeConstant -Path "network::PROTOCOLS::TIMEOUT_MS" -Fallback 80

    $results = [System.Collections.Generic.List[string]]::new()
    $tasks = 1..254 | ForEach-Object {
        $ip = "$SubnetRoot.$_"
        Start-Job -ScriptBlock {
            param($tIP, $tPort, $tTime)
            $client = [System.Net.Sockets.TcpClient]::new()
            try { $client.ConnectAsync($tIP, $tPort).Wait($tTime); if ($client.Connected) { return $tIP } } catch {} finally { $client.Close() }
        } -ArgumentList $ip, $port, $timeout
    }

    $tasks | Wait-Job | Receive-Job | ForEach-Object { if ($_) { $results.Add($_) } }
    $tasks | Remove-Job -Force

    return $results.ToArray()
}

function Invoke-ScapeCredentialPopup {
    param([string]$Target)
    $tmpFile = Join-Path ([System.IO.Path]::GetTempPath()) "scape_cred_$([Guid]::NewGuid()).xml"
    $script = "Get-Credential -Message 'SCAPE: Authentication required for $Target' | Export-Clixml -Path '$tmpFile'"
    $proc = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-WindowStyle", "Hidden", "-Command", $script -Wait -PassThru
    if ($proc.ExitCode -eq 0 -and (Test-Path $tmpFile)) {
        $cred = Import-Clixml -Path $tmpFile
        Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
        return $cred
    }
    return $null
}

function New-ScapeNetworkMount {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$RemoteVault,
        [Parameter(Mandatory = $true)][string]$DriveLetter
    )

    $cred = Invoke-ScapeCredentialPopup -Target $RemoteVault
    if (-not $cred) { return $false }
    $user = $cred.UserName
    $pass = $cred.GetNetworkCredential().Password

    $netExe = Get-ScapeConstant -Path "system::TOOLS::NET_USE" -Fallback "net.exe"
    $proc = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo @{
                FileName = $netExe; Arguments = "use $DriveLetter $RemoteVault $pass /user:$user /persistent:yes"
                RedirectStandardOutput = $true; RedirectStandardError = $true; UseShellExecute = $false; CreateNoWindow = $true
            }))
    $proc.WaitForExit()

    if ($proc.ExitCode -eq 0) {
        Publish-ScapeEvent -Type "NET_SMB_LOCK" -Severity "LOG_INFO" -Payload @{ Target = $RemoteVault; Drive = $DriveLetter }
        return $true
    }
    return $false
}

function Remove-ScapeNetworkMount {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$DriveLetter)

    $netExe = Get-ScapeConstant -Path "system::TOOLS::NET_USE" -Fallback "net.exe"
    $proc = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo @{
                FileName = $netExe; Arguments = "use $DriveLetter /delete /yes"
                RedirectStandardOutput = $true; RedirectStandardError = $true; UseShellExecute = $false; CreateNoWindow = $true
            }))
    $proc.WaitForExit()

    if ($proc.ExitCode -eq 0) {
        Publish-ScapeEvent -Type "NET_SMB_UNMOUNT" -Severity "LOG_INFO" -Payload @{ Drive = $DriveLetter }
        return $true
    }
    return $false
}

function Clear-ScapeNetworkMounts {
    [CmdletBinding()]
    param()

    $netExe = Get-ScapeConstant -Path "system::TOOLS::NET_USE" -Fallback "net.exe"
    $proc = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo @{
                FileName = $netExe; Arguments = "use * /delete /yes"
                RedirectStandardOutput = $true; RedirectStandardError = $true; UseShellExecute = $false; CreateNoWindow = $true
            }))
    $proc.WaitForExit()
    Publish-ScapeEvent -Type "NET_SMB_UNMOUNT_ALL" -Severity "LOG_INFO" -Payload @{}
    return ($proc.ExitCode -eq 0)
}