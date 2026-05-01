<#
.SYNOPSIS
    Ignite.ps1 - Centelha. Em modo monolito, carrega payloads e chama Deployer.
#>
[CmdletBinding()]
param(
    [ValidateSet('None', 'StandaloneExe', 'SetupExe', 'SetupMsi', 'All')]
    [string]$BuildType = 'None',
    [string]$OutputBase = '',
    [string]$IconPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Define OutputBase se vazio
if ([string]::IsNullOrWhiteSpace($OutputBase)) {
    $OutputBase = Join-Path $PSScriptRoot 'SCAPE_RELEASE'
}

# DEFINE O GLOBAL BOOTROOT AQUI (crítico!)
if (-not $global:BootRoot) {
    $global:BootRoot = $PSScriptRoot
}
if (-not $script:BootRoot) {
    $script:BootRoot = $PSScriptRoot
}

$isMonolith = (Get-Variable -Name 'Asset_Topology_Payload' -Scope Global -ErrorAction SilentlyContinue) -ne $null

if ($isMonolith) {
    Write-Host "Modo Monolito: carregando payloads..." -ForegroundColor Cyan

    $oldErrorPref = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    Get-Variable -Scope Global | Where-Object { $_.Name -match 'Payload$' -and $_.Name -ne 'IgniteScriptContent' } | ForEach-Object {
        try {
            . ([ScriptBlock]::Create($_.Value))
        }
        catch {
            # Ignorar erros de Export-ModuleMember
        }
    }
    $ErrorActionPreference = $oldErrorPref

    if (Get-Command Start-ScapeDeployment -ErrorAction SilentlyContinue) {
        Start-ScapeDeployment -WorkspacePath $PSScriptRoot -OutputBase $OutputBase -IconPath $IconPath -BuildType $BuildType
    }
    else {
        throw "Start-ScapeDeployment não encontrado após carregar payloads."
    }
}
else {
    Write-Host "Modo Desenvolvimento: importando módulos..." -ForegroundColor Cyan
    $modulesDir = Join-Path $PSScriptRoot 'Modules'
    if (-not (Test-Path $modulesDir)) { throw "Pasta Modules não encontrada." }

    Get-ChildItem -Path $modulesDir -Recurse -Filter '*.psm1' | ForEach-Object {
        Import-Module $_.FullName -Force -ErrorAction Stop
    }

    Initialize-ScapeState | Out-Null
    Update-ScapeColdState -NewProperties @{ ROOT = $PSScriptRoot; DEV_MODE = $true } -Confirm:$false | Out-Null

    $regPath = Join-Path $PSScriptRoot 'Data\Registry.psd1'
    if (Test-Path $regPath) {
        $regData = Import-PowerShellDataFile $regPath
        Update-ScapeColdState -NewProperties @{ Registry = $regData } -Confirm:$false | Out-Null
        if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
            $regData.Segments.Keys | Where-Object { $regData.Segments[$_].Category -in @('Constants', 'I18N') } | ForEach-Object {
                $seg = $regData.Segments[$_]
                $fp = Join-Path $PSScriptRoot $seg.File
                if (Test-Path $fp) { $null = Invoke-ScapeLoadAsset -Category $seg.Category -AssetId $_ -FilePath $fp -Silent }
            }
        }
    }

    if (Get-Command Start-ScapeRouter -ErrorAction SilentlyContinue) {
        Start-ScapeRouter -InitialMenu "MainMenu"
    }
    else {
        Write-Host "Router não disponível em modo dev." -ForegroundColor Yellow
    }
}