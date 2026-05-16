<#
.SYNOPSIS
    Domain: Forge | Module: Scape.Forge.Deployer
.DESCRIPTION
    Monolith Extraction | Entry Point (main.ps1) Generation | Execution Flow
    PRESERVED LEGACY: PSReadLine cleanup, Console encoding, Core/Interop/Settings/Logger init,
                      explicit lazy-load registration, Test-Path asset safety, SCAPE_HANDOVER flow.
    IMPROVEMENTS: $OutDir creation safety, cleaner switch syntax, robust StringBuilder generation,
                  $Global:SCAPE_MEM validation, and standardized event payloads.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Expand-MonolithToDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$TargetDir,
        [hashtable]$Topology,
        [hashtable]$Registry
    )

    if ($null -eq $Global:SCAPE_MEM -or $Global:SCAPE_MEM -isnot [hashtable]) {
        throw "EXPAND_FATAL: Global memory matrix (SCAPE_MEM) is not initialized."
    }

    # 1. Extrai Módulos respeitando a Topologia
    foreach ($domain in $Topology.Keys) {
        if ($domain -eq '__Meta__' -or $domain -eq 'Root') { continue }
        foreach ($mod in $Topology[$domain]) {
            $modName = if ($mod -is [hashtable]) { $mod['Name'] } else { $mod.Name }
            $memKey = $modName
            if ($Global:SCAPE_MEM.ContainsKey($memKey)) {
                $parts = $modName -split '\.'
                $moduleDomain = if ($parts.Count -ge 2 -and -not [string]::IsNullOrWhiteSpace($parts[1])) { $parts[1] } else { $domain }
                $relativeLeaf = if ($parts.Count -ge 3) { (($parts[2..($parts.Count - 1)] -join '\') + '.psm1') } else { (($parts[-1]) + '.psm1') }
                $dest = Join-ScapePath $TargetDir "Modules\$moduleDomain\$relativeLeaf"
                $dir = Split-Path $dest -Parent
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                Set-Content -Path $dest -Value $Global:SCAPE_MEM[$memKey] -Encoding UTF8 -NoNewline
            }
        }
    }

    # 2. Extrai Assets do Registry
    foreach ($key in $Registry.Segments.Keys) {
        if ($key -eq '__Meta__') { continue }
        $seg = $Registry.Segments[$key]
        $safeName = $seg.File -replace '^[Dd]ata\\', '' -replace '\\', '_'
        $memKey = "Asset_$safeName"

        if ($Global:SCAPE_MEM.ContainsKey($memKey)) {
            $dest = Join-ScapePath $TargetDir $seg.File
            $dir = Split-Path $dest -Parent
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            Set-Content -Path $dest -Value $Global:SCAPE_MEM[$memKey] -Encoding UTF8 -NoNewline
        }
    }

    # 3. Grava os Manifestos
    $topoDest = Join-ScapePath $TargetDir "Data\Manifests\Topology.psd1"
    $regDest = Join-ScapePath $TargetDir "Data\Manifests\Registry.psd1"
    if ($Global:SCAPE_MEM.ContainsKey('Asset_Topology')) {
        Set-Content -Path $topoDest -Value $Global:SCAPE_MEM['Asset_Topology'] -Encoding UTF8 -NoNewline
    }
    if ($Global:SCAPE_MEM.ContainsKey('Asset_Registry')) {
        Set-Content -Path $regDest -Value $Global:SCAPE_MEM['Asset_Registry'] -Encoding UTF8 -NoNewline
    }
}

function Set-MainScript {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$TargetDir, [hashtable]$Topology)

    $mainPath = Join-Path $TargetDir 'main.ps1'
    if (Test-Path $mainPath) { Remove-Item $mainPath -Force -ErrorAction SilentlyContinue }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('<# SCAPE OPERATIONAL MAIN #>')
    [void]$sb.AppendLine('$ErrorActionPreference = "Stop"')
    [void]$sb.AppendLine('Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue')
    [void]$sb.AppendLine('')

    [void]$sb.AppendLine('$Global:AppRoot = $PSScriptRoot')
    [void]$sb.AppendLine('if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }')
    [void]$sb.AppendLine('if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = (Get-Location).Path }')
    [void]$sb.AppendLine('$Global:BootRoot = $Global:AppRoot')
    [void]$sb.AppendLine('$workspaceRootName = "SCAPE_Storage"; $workspaceLogsName = "Logs"; $workspaceTempName = "Temp"; $workspaceDeployName = "Build"')
    [void]$sb.AppendLine('$systemConstPath = Join-Path $Global:AppRoot "Data\Constants\system.psd1"')
    [void]$sb.AppendLine('$forgeConstPath = Join-Path $Global:AppRoot "Data\Constants\forge.psd1"')
    [void]$sb.AppendLine('if (Test-Path -LiteralPath $systemConstPath) {')
    [void]$sb.AppendLine('    $rawSystem = [System.IO.File]::ReadAllText($systemConstPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('    if (-not [string]::IsNullOrWhiteSpace($rawSystem)) {')
    [void]$sb.AppendLine('        $systemConst = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawSystem))')
    [void]$sb.AppendLine('        if ($systemConst -and $systemConst.Workspace) {')
    [void]$sb.AppendLine('            $workspaceRootName = if ($systemConst.Workspace.ROOT) { [string]$systemConst.Workspace.ROOT } else { $workspaceRootName }')
    [void]$sb.AppendLine('            $workspaceLogsName = if ($systemConst.Workspace.LOGS) { [string]$systemConst.Workspace.LOGS } else { $workspaceLogsName }')
    [void]$sb.AppendLine('            $workspaceTempName = if ($systemConst.Workspace.TEMP) { [string]$systemConst.Workspace.TEMP } else { $workspaceTempName }')
    [void]$sb.AppendLine('            $workspaceDeployName = if ($systemConst.Workspace.DEPLOY) { [string]$systemConst.Workspace.DEPLOY } else { $workspaceDeployName }')
    [void]$sb.AppendLine('        }')
    [void]$sb.AppendLine('    }')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('if (Test-Path -LiteralPath $forgeConstPath) {')
    [void]$sb.AppendLine('    $rawForge = [System.IO.File]::ReadAllText($forgeConstPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('    if (-not [string]::IsNullOrWhiteSpace($rawForge)) {')
    [void]$sb.AppendLine('        $forgeConst = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawForge))')
    [void]$sb.AppendLine('        if ($forgeConst -and $forgeConst.Paths -and $forgeConst.Paths.DeployWorkspaceDir) { $workspaceDeployName = [string]$forgeConst.Paths.DeployWorkspaceDir }')
    [void]$sb.AppendLine('    }')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('$workspaceRoot = Join-Path $Global:AppRoot $workspaceRootName')
    [void]$sb.AppendLine('$preferredWorkspace = Join-Path $Global:AppRoot "Workspace"')
    [void]$sb.AppendLine('if (Test-Path -LiteralPath $preferredWorkspace) { $workspaceRoot = $preferredWorkspace }')
    [void]$sb.AppendLine('$workspaceLogs = Join-Path $workspaceRoot $workspaceLogsName')
    [void]$sb.AppendLine('$workspaceTemp = Join-Path $workspaceRoot $workspaceTempName')
    [void]$sb.AppendLine('$workspaceDeploy = Join-Path $workspaceRoot $workspaceDeployName')
    [void]$sb.AppendLine('@($workspaceRoot, $workspaceLogs, $workspaceTemp, $workspaceDeploy) | ForEach-Object { if (-not (Test-Path -LiteralPath $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null } }')

    [void]$sb.AppendLine('if (Get-Module PSReadLine -ErrorAction SilentlyContinue) { Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue }')
    [void]$sb.AppendLine('[Console]::OutputEncoding = [System.Text.Encoding]::UTF8')
    [void]$sb.AppendLine('')

    [void]$sb.AppendLine('$topoPath = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Topology.psd1"')
    [void]$sb.AppendLine('$regPath  = Join-Path -Path $Global:AppRoot -ChildPath "Data\Manifests\Registry.psd1"')
    [void]$sb.AppendLine('if (-not (Test-Path $topoPath)) { throw "HANDOFF_FATAL: Topology.psd1 not found at $topoPath" }')
    [void]$sb.AppendLine('if (-not (Test-Path $regPath)) { throw "HANDOFF_FATAL: Registry.psd1 not found at $regPath" }')
    [void]$sb.AppendLine('$rawTopo = [System.IO.File]::ReadAllText($topoPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('$rawReg  = [System.IO.File]::ReadAllText($regPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('$manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawTopo))')
    [void]$sb.AppendLine('$registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawReg))')
    [void]$sb.AppendLine('if ($null -eq $manifest) { throw "HANDOFF_FATAL: Failed to parse Topology.psd1." }')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('function Resolve-ScapeModulePath {')
    [void]$sb.AppendLine('    param([string]$ModuleName)')
    [void]$sb.AppendLine('    $parts = $ModuleName -split "\."')
    [void]$sb.AppendLine('    if ($parts.Count -lt 3) { return $null }')
    [void]$sb.AppendLine('    $domain = $parts[1]')
    [void]$sb.AppendLine('    $leaf = (($parts[2..($parts.Count - 1)] -join "\") + ".psm1")')
    [void]$sb.AppendLine('    $candidate = Join-Path -Path $Global:AppRoot -ChildPath ("Modules\" + $domain + "\" + $leaf)')
    [void]$sb.AppendLine('    if (Test-Path -LiteralPath $candidate) { return $candidate }')
    [void]$sb.AppendLine('    return $null')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('')

    [void]$sb.AppendLine('$coreMods = $manifest["Core"] | Sort-Object LoadOrder')
    [void]$sb.AppendLine('$loadedCore = [System.Collections.Generic.List[string]]::new()')
    [void]$sb.AppendLine('foreach ($mod in $coreMods) {')
    [void]$sb.AppendLine('    $modName = if ($mod -is [hashtable]) { $mod["Name"] } else { $mod.Name }')
    [void]$sb.AppendLine('    $foundPath = Resolve-ScapeModulePath -ModuleName $modName')
    [void]$sb.AppendLine('    if ($foundPath) { Import-Module $foundPath -Global -Force; $loadedCore.Add($modName) }')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('')

    # 1. INICIALIZAÇÃO EXPLÍCITA DO ESTADO
    [void]$sb.AppendLine('Initialize-ScapeState | Out-Null')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeInterop -ErrorAction SilentlyContinue) { Initialize-ScapeInterop | Out-Null }')
    [void]$sb.AppendLine('Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot; Registry = $registry; MANIFEST = $manifest; LoadedLayers = $loadedCore; WORKSPACE_ROOT = $workspaceRoot; WORKSPACE_LOGS = $workspaceLogs; WORKSPACE_TEMP = $workspaceTemp; WORKSPACE_DEPLOY = $workspaceDeploy } -Confirm:$false | Out-Null')
    [void]$sb.AppendLine('')

    # 2. CARGA DE ASSETS (AGORA O STATE JÁ EXISTE)
    [void]$sb.AppendLine('if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {')
    [void]$sb.AppendLine('    $state = Get-ScapeColdState')
    [void]$sb.AppendLine('    if (-not $state.ContainsKey("Assets")) { $state["Assets"] = @{} }')
    [void]$sb.AppendLine('    foreach ($key in $registry.Segments.Keys) {')
    [void]$sb.AppendLine('        if ($key -eq "__Meta__") { continue }')
    [void]$sb.AppendLine('        $seg = $registry.Segments[$key]')
    [void]$sb.AppendLine('        $isLazy = if ($seg -is [hashtable]) { $seg["IsLazy"] } else { $seg.IsLazy }')
    [void]$sb.AppendLine('        if ($isLazy -eq $false) {')
    [void]$sb.AppendLine('            $file = if ($seg -is [hashtable]) { $seg["File"] } else { $seg.File }')
    [void]$sb.AppendLine('            $cat  = if ($seg -is [hashtable]) { $seg["Category"] } else { $seg.Category }')
    [void]$sb.AppendLine('            $assetPath = Join-Path -Path $Global:AppRoot -ChildPath $file')
    [void]$sb.AppendLine('            if (Test-Path -LiteralPath $assetPath) {')
    [void]$sb.AppendLine('                $rawAsset = [System.IO.File]::ReadAllText($assetPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))')
    [void]$sb.AppendLine('                $parsedAsset = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawAsset))')
    [void]$sb.AppendLine('                if (-not $state["Assets"].ContainsKey($cat)) { $state["Assets"][$cat] = @{} }')
    [void]$sb.AppendLine('                $state["Assets"][$cat][$key] = $parsedAsset')
    [void]$sb.AppendLine('            }')
    [void]$sb.AppendLine('        }')
    [void]$sb.AppendLine('    }')
    [void]$sb.AppendLine('}')
    [void]$sb.AppendLine('')

    # 3. SETTINGS & LOGGER
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeSetting -ErrorAction SilentlyContinue) { Initialize-ScapeSetting -ForceReset:$false | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeTheme -ErrorAction SilentlyContinue) { Initialize-ScapeTheme | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Initialize-ScapeRenderer -ErrorAction SilentlyContinue) { Initialize-ScapeRenderer | Out-Null }')
    [void]$sb.AppendLine('')

    # 4. PREPARA A UI E INICIA O ROTEADOR
    [void]$sb.AppendLine('if (Get-Command Resolve-ScapeManifestLayer -ErrorAction SilentlyContinue) { Resolve-ScapeManifestLayer -LayerKey "Presentation" | Out-Null }')
    [void]$sb.AppendLine('if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) { Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null }')
    [void]$sb.AppendLine('$defaultLang = Get-ScapeConstant -Path "system::Defaults::LANG" -Fallback "en-US"')
    [void]$sb.AppendLine('Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = $defaultLang }')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('$navCheck = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"')
    [void]$sb.AppendLine('if ($null -eq $navCheck) { throw "HANDOFF_FATAL: Navigation manifest failed to mount in RAM." }')
    [void]$sb.AppendLine('Start-ScapeRouter -InitialMenu "MainMenu"')

    Set-Content -Path $mainPath -Value $sb.ToString() -Encoding UTF8 -Force
    return $mainPath
}

function New-ScapeHandoverArgument {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [string]$LogFilePath
    )

    if (-not [string]::IsNullOrWhiteSpace($LogFilePath)) {
        $safeLog = $LogFilePath -replace "'", "''"
        $safeScript = $ScriptPath -replace "'", "''"
        $command = "`$env:SCAPE_LOG_PARENT_FILE = '$safeLog'; & '$safeScript'"
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encoded = [Convert]::ToBase64String($bytes)
        return "-NoProfile -ExecutionPolicy Bypass -NoExit -EncodedCommand $encoded"
    }

    return "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$ScriptPath`""
}

function Invoke-ScapeDeployWorkflow {
    [CmdletBinding()]
    param(
        [ValidateSet('INIT_AND_EXIT', 'BUILD_AND_LAUNCH_MONOLITH', 'EXE_PORTABLE', 'EXE_SETUP', 'MSI')]
        [string]$Task,
        [string]$IconPath = ''
    )

    $state = Get-ScapeColdState
    if (-not $state.ContainsKey("ROOT") -or [string]::IsNullOrWhiteSpace($state["ROOT"])) {
        Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot } -Confirm:$false | Out-Null
    }
    if (-not $state.ContainsKey("DEV_MODE")) {
        # legacy default
        Update-ScapeColdState -NewProperties @{ DEV_MODE = $true } -Confirm:$false | Out-Null
    }

    # Option 1 (Monolith): RAM-only, não extrair/generar Main.ps1
    if ($Task -eq 'BUILD_AND_LAUNCH_MONOLITH') {
        Update-ScapeColdState -NewProperties @{ DEV_MODE = $false } -Confirm:$false | Out-Null
    }

    $navLoaded = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
    if ($null -eq $navLoaded) {
        Publish-ScapeEvent -Type "BOOT_FATAL" -Severity "FATAL" -Payload "Navigation manifest failed to load. Router cannot start."
        throw "ROUTER_PRECONDITION_FAIL: Navigation asset missing"
    }

    # ========================================================
    # CORREÇÃO: Variável $root declarada a partir do estado
    # ========================================================
    $root = $state["ROOT"]

    $topology = $state["MANIFEST"]
    $registry = $state["Registry"]
    $targetBase = $state["WORKSPACE_TEMP"]
    $sysWorkspace = Get-ScapeConstant -Path "system::Workspace" -Fallback @{}
    $forgePaths = Get-ScapeConstant -Path "forge::Paths" -Fallback @{}

    $workspaceRootName = if ($sysWorkspace -is [hashtable] -and $sysWorkspace.ContainsKey("ROOT")) { $sysWorkspace["ROOT"] } else { "SCAPE_Storage" }
    $deployDirName = if ($sysWorkspace -is [hashtable] -and $sysWorkspace.ContainsKey("DEPLOY")) { $sysWorkspace["DEPLOY"] } else { "Build" }
    if ($forgePaths -is [hashtable] -and $forgePaths.ContainsKey("DeployWorkspaceDir") -and -not [string]::IsNullOrWhiteSpace($forgePaths["DeployWorkspaceDir"])) {
        $deployDirName = $forgePaths["DeployWorkspaceDir"]
    }

    $workspaceRootPath = Join-ScapePath $root $workspaceRootName
    $outDir = Join-ScapePath $workspaceRootPath $deployDirName
    $pwsh = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }
    $activeLogFile = if (Get-Command Get-ScapeActiveLogFile -ErrorAction SilentlyContinue) { Get-ScapeActiveLogFile } else { $null }

    switch ($Task) {
        'INIT_AND_EXIT' {
            Expand-MonolithToDirectory -TargetDir $root -Topology $topology -Registry $registry
            $mainPath = Set-MainScript -TargetDir $root -Topology $topology
            $handoverArgs = New-ScapeHandoverArgument -ScriptPath $mainPath -LogFilePath $activeLogFile
            Start-Process $pwsh -WorkingDirectory (Split-Path -Parent $mainPath) -ArgumentList $handoverArgs
            throw "SCAPE_HANDOVER"
        }
        'BUILD_AND_LAUNCH_MONOLITH' {
            $monolithDir = if ($forgePaths -is [hashtable] -and $forgePaths.ContainsKey("MonolithDir")) { $forgePaths["MonolithDir"] } else { "Output" }
            $monolithFile = if ($forgePaths -is [hashtable] -and $forgePaths.ContainsKey("MonolithFile")) { $forgePaths["MonolithFile"] } else { "SCAPE_DEPLOY.ps1" }
            $monolithPath = Join-ScapePath (Join-ScapePath $root $monolithDir) $monolithFile
            
            $buildScript = Join-ScapePath $root 'Modules\Forge\Build.psm1'
            if (-not (Test-Path -LiteralPath $buildScript)) {
                throw "BUILD_SCRIPT_NOT_FOUND: $buildScript"
            }

            $buildContent = [System.IO.File]::ReadAllText($buildScript, [System.Text.Encoding]::UTF8)
            $buildRunner = [scriptblock]::Create($buildContent)
            & $buildRunner -ProjectRoot $root -OutputPath $monolithPath

            if (-not (Test-Path -LiteralPath $monolithPath)) {
                throw "MONOLITH_BUILD_FAILED: Expected output file not found at $monolithPath"
            }

            $handoverArgs = New-ScapeHandoverArgument -ScriptPath $monolithPath -LogFilePath $activeLogFile
            Start-Process $pwsh -WorkingDirectory (Split-Path -Parent $monolithPath) -ArgumentList $handoverArgs
            throw "SCAPE_HANDOVER"
        }
        'EXE_PORTABLE' { _ExecuteAtomicBuild -Task $Task -TargetBase $targetBase -Topology $topology -Registry $registry -OutDir $outDir -IconPath $IconPath }
        'EXE_SETUP' { _ExecuteAtomicBuild -Task $Task -TargetBase $targetBase -Topology $topology -Registry $registry -OutDir $outDir -IconPath $IconPath }
        'MSI' { _ExecuteAtomicBuild -Task $Task -TargetBase $targetBase -Topology $topology -Registry $registry -OutDir $outDir -IconPath $IconPath }
    }
}

function _ExecuteAtomicBuild {
    [CmdletBinding()]
    param(
        [string]$Task,
        [string]$TargetBase,
        [hashtable]$Topology,
        [hashtable]$Registry,
        [string]$OutDir,
        [string]$IconPath
    )

    $atomicDir = Join-ScapePath $TargetBase ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $atomicDir -Force | Out-Null

    try {
        Expand-MonolithToDirectory -TargetDir $atomicDir -Topology $Topology -Registry $Registry
        $tempMain = Set-MainScript -TargetDir $atomicDir -Topology $Topology

        # Garante diretório de saída (IMPROVEMENT PRESERVED)
        if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

        switch ($Task) {
            'EXE_PORTABLE' { Invoke-ScapeCompileExe -MainScriptPath $tempMain -OutputDir $OutDir -IconPath $IconPath | Out-Null }
            'EXE_SETUP' { Invoke-ScapeCompileInno -MainScriptPath $tempMain -OutputDir $OutDir -IconPath $IconPath | Out-Null }
            'MSI' {
                $deps = Invoke-ScapeFetchDependencies -TargetDir $atomicDir
                Invoke-ScapeCompileMsi -MainScriptPath $tempMain -OutputDir $OutDir -IconPath $IconPath -WixBinDir $deps.WixDir | Out-Null
            }
        }

        Publish-ScapeEvent -Type "BUILD_COMPLETED" -Severity "INFO" -Payload @{ Task = $Task; OutDir = $OutDir }
    }
    finally {
        # LEGACY PRESERVED: Limpeza atômica
        Remove-Item $atomicDir -Recurse -Force -ErrorAction SilentlyContinue
        if ($PSCommandPath -match 'SCAPE_DEPLOY\.ps1$') { Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue }
    }
}