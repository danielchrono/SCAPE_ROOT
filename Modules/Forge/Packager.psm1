<#
.SYNOPSIS
    Domain: Forge | Module: Scape.Forge.Packager
    Architecture: Dependency Acquisition | Isolation | Zero Compilation Logic
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ScapeFetchDependencies {
    [CmdletBinding()]
    param([string]$TargetDir)

    $forgeConfig = Get-ScapeConstant -Path "forge::Urls" -Fallback @{}
    if (-not $forgeConfig) { throw "Configurações do Forge ausentes no AssetManager." }

    $binDir = Join-ScapePath $TargetDir "Data\Bin"
    if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }

    # 1. Obter SQLite (x64)
    if (-not (Test-Path (Join-ScapePath $binDir "System.Data.SQLite.dll"))) {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "DEP_SQLITE_DOWNLOADING" }
        }
        $zip64 = Join-ScapePath $env:TEMP "sqlite64.zip"
        Invoke-WebRequest -Uri $forgeConfig.sqlite -OutFile $zip64
        Expand-Archive -Path $zip64 -DestinationPath (Join-ScapePath $env:TEMP "sqlite64_ext") -Force

        Copy-Item -Path (Join-ScapePath $env:TEMP "sqlite64_ext\System.Data.SQLite.dll") -Destination $binDir -Force
        Copy-Item -Path (Join-ScapePath $env:TEMP "sqlite64_ext\SQLite.Interop.dll") -Destination (Join-ScapePath $binDir "SQLite.Interop.x64.dll") -Force

        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "DEP_SQLITE_EXTRACTED" }
        }
    }

    # 2. Obter SQLite (x86 - Interop apenas)
    if (-not (Test-Path (Join-ScapePath $binDir "SQLite.Interop.x86.dll"))) {
        $zip86 = Join-ScapePath $env:TEMP "sqlite86.zip"
        Invoke-WebRequest -Uri $forgeConfig.sqlite86 -OutFile $zip86
        Expand-Archive -Path $zip86 -DestinationPath (Join-ScapePath $env:TEMP "sqlite86_ext") -Force
        Copy-Item -Path (Join-ScapePath $env:TEMP "sqlite86_ext\SQLite.Interop.dll") -Destination (Join-ScapePath $binDir "SQLite.Interop.x86.dll") -Force
    }

    # 3. Garantir WiX Toolset para o Compiler
    $wixBin = Join-ScapePath $env:TEMP 'wix_bin'
    if (-not (Test-Path (Join-ScapePath $wixBin 'candle.exe'))) {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "COMPILER_WIX_DOWNLOADING" }
        }
        $zipWix = Join-ScapePath $env:TEMP 'wix.zip'
        Invoke-WebRequest -Uri $forgeConfig.wix -OutFile $zipWix
        Expand-Archive -Path $zipWix -DestinationPath $wixBin -Force
        Remove-Item $zipWix -Force
    }

    # 4. Garantir PS2EXE
    if (-not (Get-Command 'ps2exe' -ErrorAction SilentlyContinue)) {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "COMPILER_INSTALL_PS2EXE" }
        }
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module ps2exe -Force -AcceptLicense | Out-Null
    }

    return @{ BinDir = $binDir; WixDir = $wixBin }
}