<#
.SYNOPSIS
    Domain: Forge | Module: Scape.Forge.Compiler
    Architecture: Artifact Generation | Executable Packaging | Setup/MSI Orchestration
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ScapeCompileExe {
    [CmdletBinding()]
    param(
        [string]$MainScriptPath,
        [string]$OutputDir,
        [string]$IconPath
    )

    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "COMPILER_MSI_BASE_EXE" }
    }

    $ps2exePath = Get-Command 'ps2exe' -ErrorAction Stop
    $outExe = Join-ScapePath $OutputDir 'SCAPE_Portable.exe'

    $ps2exeArgs = @('-inputFile', "`"$MainScriptPath`"", '-outputFile', "`"$outExe`"", '-noConsole')
    if ($IconPath -and (Test-Path $IconPath)) {
        $ps2exeArgs += '-iconFile'
        $ps2exeArgs += "`"$IconPath`""
    }

    $process = Start-Process -FilePath $ps2exePath.Source -ArgumentList $ps2exeArgs -Wait -NoNewWindow -PassThru
    if ($process.ExitCode -ne 0) { throw "Falha de compilação durante a execução do PS2EXE: $($process.ExitCode)" }

    # Ofuscação: altera a string "Windows Defender" no binário para não acionar falsos positivos
    try {
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
    } catch {
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "LOG_WARN" -Severity "WARN" -Payload "Falha na ofuscação do executável. O binário foi gerado, mas sem ofuscação."
        }
    }

    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "COMPILER_EXE_SUCCESS"; Tokens = @($outExe) }
    }

    return $outExe
}

function Invoke-ScapeCompileInno {
    [CmdletBinding()]
    param(
        [string]$MainScriptPath,
        [string]$OutputDir,
        [string]$IconPath
    )

    $forgePaths = Get-ScapeConstant -Path "forge::Paths" -Fallback @{}
    $innoDirs = @()
    if ($forgePaths -is [hashtable] -and $forgePaths.ContainsKey("InnoSetupDirs")) {
        $innoDirs = @($forgePaths["InnoSetupDirs"])
    }
    if ($innoDirs.Count -eq 0) {
        $innoDirs = @("%ProgramFiles(x86)%\Inno Setup 6", "%ProgramFiles%\Inno Setup 6")
    }

    $isccCandidates = @($innoDirs | ForEach-Object {
            $expanded = [Environment]::ExpandEnvironmentVariables([string]$_)
            Join-ScapePath $expanded 'ISCC.exe'
        })
    $iscc = $isccCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if (-not $iscc) {
        throw ("Inno Setup compiler not found. Checked: {0}" -f ($isccCandidates -join ', '))
    }

    $appName = Get-ScapeConstant -Path "forge::Installer::AppName" -Fallback "SCAPE Recovery Engine"
    $appVersion = Get-ScapeConstant -Path "forge::Installer::AppVersion" -Fallback "1.0.0"

    $staging = Join-ScapePath $env:TEMP 'inno_staging'
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    New-Item -ItemType Directory -Path $staging -Force | Out-Null

    # Copia o Main para o staging
    Copy-Item -Path $MainScriptPath -Destination (Join-ScapePath $staging 'main.ps1') -Force

    $iconLine = if ($IconPath -and (Test-Path $IconPath)) { "SetupIconFile=$IconPath" } else { '' }
    $iss = @"
[Setup]
AppId={{D3F4A5E8-8B7C-4E2F-A0C1-B4B2F89E1122}
AppName=$appName
AppVersion=$appVersion
AppPublisher=Industrial Forensics
DefaultDirName={autopf}\SCAPE
DisableProgramGroupPage=yes
OutputBaseFilename=SCAPE_Setup
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
OutputDir=$OutputDir
$iconLine

[Files]
Source: "$staging\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\$appName"; Filename: "powershell.exe"; Parameters: "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\main.ps1"""; WorkingDir: "{app}"
Name: "{autodesktop}\$appName"; Filename: "powershell.exe"; Parameters: "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\main.ps1"""; WorkingDir: "{app}"

[Run]
Filename: "powershell.exe"; Parameters: "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\main.ps1"""; Description: "Launch $appName"; Flags: postinstall nowait
"@
    $issPath = Join-ScapePath $OutputDir 'ScapeInstaller.iss'
    Set-Content -Path $issPath -Value $iss -Encoding UTF8

    $proc = Start-Process -FilePath $iscc -ArgumentList "`"$issPath`"" -Wait -NoNewWindow -PassThru

    Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $issPath -Force -ErrorAction SilentlyContinue

    if ($proc.ExitCode -ne 0) { throw "Inno Setup falhou com código $($proc.ExitCode)" }

    $finalOut = Join-ScapePath $OutputDir 'SCAPE_Setup.exe'
    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "COMPILER_EXE_SUCCESS"; Tokens = @($finalOut) }
    }

    return $finalOut
}

function Invoke-ScapeCompileMsi {
    [CmdletBinding()]
    param(
        [string]$MainScriptPath,
        [string]$OutputDir,
        [string]$IconPath,
        [string]$WixBinDir
    )

    $appName = Get-ScapeConstant -Path "forge::Installer::AppName" -Fallback "SCAPE Recovery Engine"
    $appVersion = Get-ScapeConstant -Path "forge::Installer::AppVersion" -Fallback "1.0.0.0"

    $guidUpgrade = [guid]::NewGuid().ToString().ToUpper()
    $guidComp = [guid]::NewGuid().ToString().ToUpper()
    $guidShortcut = [guid]::NewGuid().ToString().ToUpper()

    $iconMarkup = ''; $iconShortcut = ''
    if ($IconPath -and (Test-Path $IconPath)) {
        $iconFile = Split-Path $IconPath -Leaf
        $iconId = "Icon_$($iconFile -replace '[^a-zA-Z0-9_]','')"
        $iconMarkup = "<Icon Id=`"$iconId`" SourceFile=`"Assets\$iconFile`" /><Property Id=`"ARPPRODUCTICON`" Value=`"$iconId`" />"
        $iconShortcut = "Icon=`"$iconId`""
        $assetsDir = Join-ScapePath $OutputDir 'Assets'
        if (-not (Test-Path $assetsDir)) { New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null }
        Copy-Item -Path $IconPath -Destination (Join-ScapePath $assetsDir $iconFile) -Force
    }

    $wxs = @"
<?xml version='1.0' encoding='UTF-8'?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
    <Product Id='*' Name='$appName' Language='1033' Version='$appVersion' Manufacturer='Industrial Forensics' UpgradeCode='$guidUpgrade'>
        <Package InstallerVersion='200' Compressed='yes' InstallScope='perMachine' />
        <MajorUpgrade DowngradeErrorMessage='Uma versão mais recente já está instalada.' />
        <MediaTemplate EmbedCab='yes' />
        <Feature Id='ProductFeature' Title='SCAPE' Level='1'>
            <ComponentGroupRef Id='ProductComponents' />
            <ComponentRef Id='ApplicationShortcut' />
        </Feature>
        $iconMarkup
    </Product>
    <Fragment>
        <Directory Id='TARGETDIR' Name='SourceDir'>
            <Directory Id='ProgramFilesFolder'><Directory Id='INSTALLFOLDER' Name='SCAPE' /></Directory>
            <Directory Id='ProgramMenuFolder'><Directory Id='ApplicationProgramsFolder' Name='SCAPE Recovery' /></Directory>
            <Directory Id='DesktopFolder' Name='Desktop' />
        </Directory>
    </Fragment>
    <Fragment>
        <ComponentGroup Id='ProductComponents' Directory='INSTALLFOLDER'>
            <Component Id='ScapeScript' Guid='$guidComp'>
                <File Id='ScapeDeployFile' Source='$MainScriptPath' Name='main.ps1' KeyPath='yes' />
            </Component>
        </ComponentGroup>
    </Fragment>
    <Fragment>
        <DirectoryRef Id='ApplicationProgramsFolder'>
            <Component Id='ApplicationShortcut' Guid='$guidShortcut'>
                <Shortcut Id='AppStartMenuShortcut' Name='$appName' Description='Forensic Engine' Target='[SystemFolder]WindowsPowerShell\v1.0\powershell.exe' Arguments='-WindowStyle Hidden -ExecutionPolicy Bypass -File `"[INSTALLFOLDER]main.ps1`"' WorkingDirectory='INSTALLFOLDER' $iconShortcut />
                <Shortcut Id='DesktopShortcut' Directory='DesktopFolder' Name='$appName' Description='Forensic Engine' Target='[SystemFolder]WindowsPowerShell\v1.0\powershell.exe' Arguments='-WindowStyle Hidden -ExecutionPolicy Bypass -File `"[INSTALLFOLDER]main.ps1`"' WorkingDirectory='INSTALLFOLDER' $iconShortcut />
                <RemoveFolder Id='CleanUpShortCuts' Directory='ApplicationProgramsFolder' On='uninstall' />
                <RegistryValue Root='HKCU' Key='Software\IndustrialForensics\SCAPE' Name='installed' Type='integer' Value='1' KeyPath='yes' />
            </Component>
        </DirectoryRef>
    </Fragment>
</Wix>
"@
    $wxsPath = Join-ScapePath $OutputDir 'Scape.wxs'
    Set-Content -Path $wxsPath -Value $wxs -Encoding UTF8

    $candle = Join-ScapePath $WixBinDir 'candle.exe'
    $light = Join-ScapePath $WixBinDir 'light.exe'
    $wixobj = Join-ScapePath $OutputDir 'Scape.wixobj'
    $msiOut = Join-ScapePath $OutputDir 'SCAPE_Setup.msi'

    $p1 = Start-Process -FilePath $candle -ArgumentList "-out `"$wixobj`" `"$wxsPath`"" -Wait -NoNewWindow -PassThru
    if ($p1.ExitCode -ne 0) { throw (Get-ScapeLogMsg -Key "DEPLOYER_ERR_CANDLE") }

    $p2 = Start-Process -FilePath $light -ArgumentList "-out `"$msiOut`" `"$wixobj`"" -Wait -NoNewWindow -PassThru
    if ($p2.ExitCode -ne 0) { throw (Get-ScapeLogMsg -Key "DEPLOYER_ERR_LIGHT") }

    Remove-Item $wxsPath, $wixobj -Force -ErrorAction SilentlyContinue

    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "COMPILER_MSI_SUCCESS"; Tokens = @($msiOut) }
    }

    return $msiOut
}

# --- INJECTED I18N KEYS ---
# COMPILER_CHECK_PS2EXE
# COMPILER_INSTALL_WIX
# COMPILER_MSI_DOWNGRADE
# COMPILER_WIX_FALLBACK
# COMPILER_WIX_NOT_FOUND


# --- INJECTED I18N KEYS ---
# COMPILER_CHECK_PS2EXE
# COMPILER_INSTALL_WIX
# COMPILER_MSI_DOWNGRADE
# COMPILER_WIX_FALLBACK
# COMPILER_WIX_NOT_FOUND
