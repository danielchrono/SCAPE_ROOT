<#
.SYNOPSIS
    Packager.psm1 - Gera instaladores: Setup.exe (Inno) e Setup.msi (WiX).
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ScapeInnoSetup($MainScriptPath, $OutputDir, $IconPath) {
    $iscc = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $iscc) { throw "Inno Setup 6 não encontrado. Instale em C:\Program Files (x86)\Inno Setup 6" }
    $appName = 'SCAPE Recovery Engine'
    $appVersion = '1.0.0'
    $staging = Join-Path $env:TEMP 'inno_staging'
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    Copy-Item -Path $MainScriptPath -Destination (Join-Path $staging 'main.ps1') -Force
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
    $issPath = Join-Path $OutputDir 'ScapeInstaller.iss'
    Set-Content -Path $issPath -Value $iss -Encoding UTF8
    $proc = Start-Process -FilePath $iscc -ArgumentList "`"$issPath`"" -Wait -NoNewWindow -PassThru
    Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $issPath -Force -ErrorAction SilentlyContinue
    if ($proc.ExitCode -ne 0) { throw "Inno Setup falhou código $($proc.ExitCode)" }
    return Join-Path $OutputDir 'SCAPE_Setup.exe'
}

function Invoke-ScapeWiXBuild($MainScriptPath, $OutputDir, $IconPath) {
    $wixBin = Join-Path $env:TEMP 'wix_bin'
    if (-not (Test-Path (Join-Path $wixBin 'candle.exe'))) {
        Write-Host "Baixando WiX Toolset..." -ForegroundColor Yellow
        $zip = Join-Path $env:TEMP 'wix.zip'
        Invoke-WebRequest -Uri 'https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip' -OutFile $zip
        Expand-Archive -Path $zip -DestinationPath $wixBin -Force
        Remove-Item $zip -Force
    }
    $appName = 'SCAPE Recovery Engine'
    $appVersion = '1.0.0.0'
    $guidUpgrade = [guid]::NewGuid().ToString().ToUpper()
    $guidComp = [guid]::NewGuid().ToString().ToUpper()
    $guidShortcut = [guid]::NewGuid().ToString().ToUpper()
    $iconMarkup = ''; $iconShortcut = ''
    if ($IconPath -and (Test-Path $IconPath)) {
        $iconFile = Split-Path $IconPath -Leaf
        $iconId = "Icon_$($iconFile -replace '[^a-zA-Z0-9_]','')"
        $iconMarkup = "<Icon Id=`"$iconId`" SourceFile=`"Assets\$iconFile`" /><Property Id=`"ARPPRODUCTICON`" Value=`"$iconId`" />"
        $iconShortcut = "Icon=`"$iconId`""
        $assetsDir = Join-Path $OutputDir 'Assets'
        if (-not (Test-Path $assetsDir)) { New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null }
        Copy-Item -Path $IconPath -Destination (Join-Path $assetsDir $iconFile) -Force
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
    $wxsPath = Join-Path $OutputDir 'Scape.wxs'
    Set-Content -Path $wxsPath -Value $wxs -Encoding UTF8
    $candle = Join-Path $wixBin 'candle.exe'
    $light = Join-Path $wixBin 'light.exe'
    $wixobj = Join-Path $OutputDir 'Scape.wixobj'
    $msiOut = Join-Path $OutputDir 'SCAPE_Setup.msi'
    $p1 = Start-Process -FilePath $candle -ArgumentList "-out `"$wixobj`" `"$wxsPath`"" -Wait -NoNewWindow -PassThru
    if ($p1.ExitCode -ne 0) { throw "WiX candle falhou" }
    $p2 = Start-Process -FilePath $light -ArgumentList "-out `"$msiOut`" `"$wixobj`"" -Wait -NoNewWindow -PassThru
    if ($p2.ExitCode -ne 0) { throw "WiX light falhou" }
    Remove-Item $wxsPath, $wixobj -Force -ErrorAction SilentlyContinue
    return $msiOut
}