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
    $ipRange = Get-ScapeConstant -Path "network::PROTOCOLS::SUBNET_RANGE" -Fallback (1..254)

    $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, [Environment]::ProcessorCount, $iss, $null)
    $pool.Open()
    $tasks = [System.Collections.ArrayList]::new()
    $results = @()

    foreach ($i in $ipRange) {
        $ip = "$SubnetRoot.$i"
        $ps = [powershell]::Create($iss).AddScript({
                param($tIP, $tPort, $tTime)
                $client = [System.Net.Sockets.TcpClient]::new()
                try {
                    $asyncTask = $client.ConnectAsync($tIP, $tPort)
                    $deadline = [DateTime]::UtcNow.AddMilliseconds($tTime)
                    while (-not $asyncTask.IsCompleted -and [DateTime]::UtcNow -lt $deadline) {
                        [System.Threading.Thread]::Sleep(1)
                    }
                    if ($client.Connected) { return $tIP }
                }
                catch { Write-Verbose "Suppressed error:                 catch {} finally { $client.Close() }"; } finally { $client.Close() }
                return $null
            }).AddArgument($ip).AddArgument($port).AddArgument($timeout)
        $ps.RunspacePool = $pool
        $handle = $ps.BeginInvoke()
        $null = $tasks.Add(@{ PS = $ps; Handle = $handle })
    }

    foreach ($t in $tasks) {
        $res = $t.PS.EndInvoke($t.Handle)
        if ($res) {
            $results += $res
            Publish-ScapeEvent -Type "NET_SCAN_RESULT" -Payload $res
        }
        $t.PS.Dispose()
    }

    $pool.Close()
    $pool.Dispose()

    return @($results)
}

function New-ScapeNetworkMount {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$RemoteVault,
        [Parameter(Mandatory = $true)][string]$DriveLetter,
        [Parameter(Mandatory = $false)][string]$UserName,
        [Parameter(Mandatory = $false)][SecureString]$Password
    )

    $netExe = Get-ScapeConstant -Path "system::TOOLS::NET_USE"

    $argsStr = "use $DriveLetter $RemoteVault"
    if (-not [string]::IsNullOrWhiteSpace($Password)) {
        $argsStr += " $Password"
    }
    if (-not [string]::IsNullOrWhiteSpace($UserName)) {
        $argsStr += " /user:$UserName"
    }
    $argsStr += " /persistent:yes"

    $proc = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo @{
                FileName = $netExe; Arguments = $argsStr
                RedirectStandardOutput = $true; RedirectStandardError = $true; UseShellExecute = $false; CreateNoWindow = $true
            }))
    while (-not $proc.HasExited) {
        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }

    }

    if ($proc.ExitCode -eq 0) {
        Publish-ScapeEvent -Type "NET_SMB_LOCK" -Severity "LOG_INFO" -Payload @{ Target = $RemoteVault; Drive = $DriveLetter }
        return $true
    }
    return $false
}

function Remove-ScapeNetworkMount {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$DriveLetter)

    $netExe = Get-ScapeConstant -Path "system::TOOLS::NET_USE"
    $proc = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo @{
                FileName = $netExe; Arguments = "use $DriveLetter /delete /yes"
                RedirectStandardOutput = $true; RedirectStandardError = $true; UseShellExecute = $false; CreateNoWindow = $true
            }))
    while (-not $proc.HasExited) {
        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }

    }

    if ($proc.ExitCode -eq 0) {
        Publish-ScapeEvent -Type "NET_SMB_UNMOUNT" -Severity "LOG_INFO" -Payload @{ Drive = $DriveLetter }
        return $true
    }
    return $false
}

function Clear-ScapeNetworkMount {
    [CmdletBinding()]
    param()

    $netExe = Get-ScapeConstant -Path "system::TOOLS::NET_USE"
    $proc = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo @{
                FileName = $netExe; Arguments = "use * /delete /yes"
                RedirectStandardOutput = $true; RedirectStandardError = $true; UseShellExecute = $false; CreateNoWindow = $true
            }))
    while (-not $proc.HasExited) {
        if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) { Invoke-ScapeIdlePump | Out-Null }

    }
    Publish-ScapeEvent -Type "NET_SMB_UNMOUNT_ALL" -Severity "LOG_INFO" -Payload @{}
    return ($proc.ExitCode -eq 0)
}

function Start-ScapeNetworkScan {
    [CmdletBinding()]
    param()

    $radarSweepMsg = Get-ScapeLogMsg -Key "NET_RADAR_SWEEP"
    Publish-ScapeActionProgress -Target "Scape.Extensions.Network" -Task "NetworkScan" -StatusText $radarSweepMsg -StatusFlag "INFO" -RunProgress 10 -StepProgress 10

    $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
    if (-not $gw) {
        $gwErr = Get-ScapeLogMsg -Key "NET_RADAR_GATEWAY_ERR"
        Publish-ScapeActionProgress -Target "Scape.Extensions.Network" -Task "NetworkScan" -StatusText $gwErr -StatusFlag "Failure" -RunProgress 100 -StepProgress 0
        return $null
    }

    $subnet = $gw -replace '\.\d+$', ''
    $scanMsg = Get-ScapeLogMsg -Key "NET_RADAR_SCAN" -MsgArgs @($subnet)
    Publish-ScapeActionProgress -Target "Scape.Extensions.Network" -Task "NetworkScan" -StatusText $scanMsg -StatusFlag "INFO" -RunProgress 50 -StepProgress 50

    $nodes = Find-ScapeNetworkNode -SubnetRoot $subnet
    return $nodes
}

function Invoke-ScapeNetworkRadarAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)][string]$TargetShare,
        [Parameter(Mandatory = $false)][string]$UserName,
        [Parameter(Mandatory = $false)][SecureString]$Password
    )

    if ([string]::IsNullOrWhiteSpace($TargetShare)) {
        $TargetShare = Get-ScapeConstant -Path "network::DEFAULT_SHARE"
    }

    $nodes = Start-ScapeNetworkScan
    if ($null -eq $nodes -or $nodes.Count -eq 0) {
        $noneMsg = Get-ScapeLogMsg -Key "NET_RADAR_NONE"
        Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $noneMsg }
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "NetworkRadar"
            TitleKey = "NET_MGR_TITLE"
            Status   = "NO_SERVERS"
        }
        return
    }

    Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
        ScreenId = "NetworkRadar"
        TitleKey = "NET_MGR_TITLE"
        Status   = "SERVERS_FOUND"
        Nodes    = $nodes
    }

    $targetNode = $nodes[0]
    $usedLetters = (Get-Volume).DriveLetter
    $driveLetter = $null
    $driveRange = Get-ScapeConstant -Path "network::PROTOCOLS::DRIVE_RANGE" -Fallback (([char]'Z')..([char]'D'))
    foreach ($l in $driveRange) {
        if ([char]$l -notin $usedLetters) {
            $driveLetter = "$([char]$l):"
            break
        }
    }

    if (-not $driveLetter) {
        $noDriveMsg = Invoke-ScapeI18NFormat -Key "NET_NO_FREE_DRIVES"
        Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = $noDriveMsg }
        return
    }

    $remotePath = "\\$targetNode\$TargetShare"
    $mapInitMsg = Get-ScapeLogMsg -Key "NET_MAP_INIT" -MsgArgs @($targetNode)
    Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = $mapInitMsg }

    $mountOk = New-ScapeNetworkMount -RemoteVault $remotePath -DriveLetter $driveLetter -UserName $UserName -Password $Password
    if ($mountOk) {
        Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_SUCCESS" -MsgArgs @($driveLetter)) }
        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "NetworkRadar"
            TitleKey = "NET_MGR_TITLE"
            Status   = "MOUNT_SUCCESS"
            Target   = $remotePath
            Drive    = $driveLetter
        }
    }
    else {
        if (Get-Command Mount-ScapeNetworkShareWithCredential -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_SMB_AUTH_REQUIRED") }
            $mountOk = Mount-ScapeNetworkShareWithCredential -RemoteVault $remotePath -DriveLetter $driveLetter
            if ($mountOk) {
                Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_SUCCESS" -MsgArgs @($driveLetter)) }
                Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                    ScreenId = "NetworkRadar"
                    TitleKey = "NET_MGR_TITLE"
                    Status   = "MOUNT_SUCCESS"
                    Target   = $remotePath
                    Drive    = $driveLetter
                }
            }
            else {
                Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_CANCELLED") }
                Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                    ScreenId = "NetworkRadar"
                    TitleKey = "NET_MGR_TITLE"
                    Status   = "AUTH_FAILED"
                }
            }
        }
        else {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MAP_CANCELLED") }
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                ScreenId = "NetworkRadar"
                TitleKey = "NET_MGR_TITLE"
                Status   = "MOUNT_FAILED"
            }
        }
    }
}

function Invoke-ScapeNetworkAction {
    [CmdletBinding()]
    param([string]$Task, [string]$Target)

    if (-not (Get-Command Find-ScapeNetworkNode -ErrorAction SilentlyContinue)) {
        throw "Not Implemented"
    }

    if ($Task -eq 'SCAN') {
        Invoke-ScapeNetworkRadarAction -TargetShare $Target
    }
    elseif ($Task -eq 'UNMOUNT_ALL') {
        $unmountOk = Clear-ScapeNetworkMount
        if ($unmountOk) {
            Publish-ScapeEvent -Type "SYSTEM" -Severity "INFO" -Payload @{ Message = (Get-ScapeLogMsg -Key "NET_MGR_ALL_REMOVED") }
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                ScreenId = "NetworkRadar"
                TitleKey = "NET_MGR_TITLE"
                Status   = "UNMOUNT_ALL_SUCCESS"
            }
        }
        else {
            $failMsg = Invoke-ScapeI18NFormat -Key "NET_UNMOUNT_FAIL"
            Publish-ScapeEvent -Type "SYSTEM" -Severity "ERROR" -Payload @{ Message = $failMsg }
            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "ERROR" -Payload @{
                ScreenId = "NetworkRadar"
                TitleKey = "NET_MGR_TITLE"
                Status   = "UNMOUNT_ALL_FAILED"
            }
        }
    }
    else {
        Find-ScapeNetworkNode | Out-Null
    }
}


# ==============================================================================
# ACTION REGISTRY BINDINGS (Pure & Decoupled)
# ==============================================================================

Export-ModuleMember -Function 'Find-ScapeNetworkNode',
'New-ScapeNetworkMount',
'Remove-ScapeNetworkMount',
'Clear-ScapeNetworkMount',
'Start-ScapeNetworkScan',
'Invoke-ScapeNetworkRadarAction',
'Invoke-ScapeNetworkAction'
