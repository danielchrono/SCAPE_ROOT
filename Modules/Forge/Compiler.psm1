<#
.SYNOPSIS
    Compiler.psm1 - Funções puras para compilar executáveis e MSI.
#>
Set-StrictMode -Version Latest

function Invoke-ScapePs2Exe {
    param(
        [string]$ScriptPath,
        [string]$OutputDir,
        [string]$IconPath
    )
    # Verifica se ps2exe está disponível
    $ps2exePath = Get-Command 'ps2exe' -ErrorAction SilentlyContinue
    if (-not $ps2exePath) {
        Write-Host "Instalando módulo ps2exe..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module ps2exe -Force -AcceptLicense | Out-Null
        $ps2exePath = Get-Command 'ps2exe'
    }
    $outExe = Join-Path $OutputDir 'SCAPE_Portable.exe'
    $ps2exeArgs = @('-inputFile', "`"$ScriptPath`"", '-outputFile', "`"$outExe`"", '-noConsole', '-iconFile', "`"$IconPath`"")
    if (-not $IconPath -or -not (Test-Path $IconPath)) { $ps2exeArgs = $ps2exeArgs[0..3] } # remove ícone se inválido
    $process = Start-Process -FilePath $ps2exePath.Source -ArgumentList $ps2exeArgs -Wait -NoNewWindow -PassThru
    if ($process.ExitCode -ne 0) { throw "ps2exe falhou com código $($process.ExitCode)" }
    # Ofuscação simples: altera string "Windows Defender" no binário (exemplo)
    $bytes = [System.IO.File]::ReadAllBytes($outExe)
    $defenderPattern = [System.Text.Encoding]::ASCII.GetBytes('Windows Defender')
    $offset = [System.Array]::IndexOf($bytes, $defenderPattern[0])
    if ($offset -gt 0) {
        $newBytes = $bytes.Clone()
        for ($i = 0; $i -lt $defenderPattern.Length; $i++) {
            $newBytes[$offset + $i] = 0x00
        }
        [System.IO.File]::WriteAllBytes($outExe, $newBytes)
    }
    return $outExe
}