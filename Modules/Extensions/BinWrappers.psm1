<#
.SYNOPSIS
    Domain: Extensions | Module: Scape.Extensions.BinWrappers
    Architecture: Immutable execution of native forensic utilities with pure parsers.
#>

function Invoke-ScapeBinWrapper {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet("DISKPART", "WINFR", "CHKDSK", "FSUTIL", "STORDIAG")][string]$ToolId,
        [Parameter(Mandatory = $true)][hashtable]$Arguments,
        [string]$WorkingDir = $env:TEMP
    )

    $exeMap = @{
        "DISKPART" = "diskpart.exe"; "WINFR" = "winfr.exe"; "CHKDSK" = "chkdsk.exe"
        "FSUTIL" = "fsutil.exe"; "STORDIAG" = "stordiag.exe"
    }

    $finalArgs = [System.Collections.Generic.List[string]]::new()
    $Arguments.GetEnumerator() | ForEach-Object { $finalArgs.Add("/$($_.Key):$($_.Value)") }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $exeMap[$ToolId]
    $psi.Arguments = $finalArgs -join " "
    $psi.WorkingDirectory = $WorkingDir
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $encodingCode = Get-ScapeConstant -Path "env::OEM_CODEPAGE" -Fallback ([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage)
    $psi.StandardOutputEncoding = [System.Text.Encoding]::GetEncoding($encodingCode)

    $proc = [System.Diagnostics.Process]::Start($psi)
    $stdOut = $proc.StandardOutput.ReadToEnd()
    $stdErr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    $exitCode = $proc.ExitCode

    $parsedData = switch ($ToolId) {
        "DISKPART" { ConvertFrom-ScapeDiskpartOutput -Raw $stdOut }
        "WINFR" { ConvertFrom-ScapeWinFROutput -Raw $stdOut }
        "CHKDSK" { ConvertFrom-ScapeChkdskOutput -Raw $stdOut }
        "FSUTIL" { ConvertFrom-ScapeFsutilOutput -Raw $stdOut }
        "STORDIAG" { ConvertFrom-ScapeStordiagOutput -Raw $stdOut }
        default { @{ Raw = $stdOut } }
    }

    $limit = Get-ScapeConstant -Path "behavior::LIMITS::SUCCESS_EXIT_CODE_MAX" -Fallback 8
    return @{
        Success    = ($exitCode -lt $limit)
        StdOut     = $stdOut
        StdErr     = $stdErr
        ExitCode   = $exitCode
        ParsedData = $parsedData
        Tool       = $ToolId
    }
}

function ConvertFrom-ScapeDiskpartOutput { param([string]$Raw) return @{ Volumes = ([regex]::Matches($Raw, "(?im)Volume\s+(\d+)")).Count; Status = "OK" } }
function ConvertFrom-ScapeWinFROutput { param([string]$Raw) return @{ Recovered = if ($Raw -match "(?im)Recovered\s+(\d+)") { [int]$matches[1] } else { 0 }; Status = "OK" } }
function ConvertFrom-ScapeChkdskOutput { param([string]$Raw) return @{ BadSectors = if ($Raw -match "(?im)(\d+)\s+bad") { [int]$matches[1] } else { 0 }; Status = "OK" } }
function ConvertFrom-ScapeFsutilOutput { param([string]$Raw) return @{ Entries = ([regex]::Matches($Raw, "(?im)^\d+\s+")).Count; Status = "OK" } }
function ConvertFrom-ScapeStordiagOutput { param([string]$Raw) return @{ ReportPath = if ($Raw -match "(?im)Report\s+saved\s+to:\s+(.+)$") { $matches[1].Trim() } else { $null }; Status = "OK" } }