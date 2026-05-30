<#
.SYNOPSIS
    Build.ps1 - SCAPE Monolith Forge (v1.0 - PATH RESOLVER & DICTIONARY SYNC)
    Architecture: Deterministic Tree | Subfolder Parsing | Safe Boot Sequence | TreeView-Ready
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = $(if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }),
    [string]$OutputPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ForgeMonolithPath {
    param([Parameter(Mandatory = $true)][string]$RootPath)
    $forgePath = Join-ScapePath $RootPath "Data\Constants\forge.psd1"
    $defaultDir = "Output"
    $defaultFile = "SCAPE_DEPLOY.ps1"
    if (-not (Test-Path -LiteralPath $forgePath)) {
        return Join-ScapePath $RootPath (Join-ScapePath $defaultDir $defaultFile)
    }

    try {
        $bytes = [System.IO.File]::ReadAllBytes($forgePath)
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $raw = $utf8NoBom.GetString($bytes).Trim()
        if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
        $forgeConst = if ([string]::IsNullOrWhiteSpace($raw)) { @{} } else { Invoke-Command -ScriptBlock ([scriptblock]::Create($raw)) }
        $paths = if ($forgeConst -and $forgeConst.Paths) { $forgeConst.Paths } else { @{} }
        $dir = if ($paths -and $paths.MonolithDir) { [string]$paths.MonolithDir } else { $defaultDir }
        $file = if ($paths -and $paths.MonolithFile) { [string]$paths.MonolithFile } else { $defaultFile }
        return Join-ScapePath $RootPath (Join-ScapePath $dir $file)
    }
    catch {
        return Join-ScapePath $RootPath (Join-ScapePath $defaultDir $defaultFile)
    }
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Resolve-ForgeMonolithPath -RootPath $ProjectRoot
}

# =============================================================================
# MICRO-RESOLVER (Sincronizado com o i18n)
# =============================================================================
$i18nPath = Join-ScapePath $ProjectRoot "Data\I18N\en-US.psd1"
$themePath = Join-ScapePath $ProjectRoot "Data\Constants\theme.psd1"

$i18n = if (Test-Path $i18nPath) {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($i18nPath)
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        Invoke-Command -ScriptBlock ([scriptblock]::Create($utf8.GetString($bytes)))
    }
    catch { @{} }
}
else { @{} }

$theme = if (Test-Path $themePath) {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($themePath)
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        Invoke-Command -ScriptBlock ([scriptblock]::Create($utf8.GetString($bytes)))
    }
    catch { @{} }
}
else { @{} }

function Get-Msg($Key) {
    if ($i18n.Contains($Key) -and $i18n[$Key].T) { return $i18n[$Key].T }
    return $Key
}

function Get-Clr($Key) {
    $mapped = "Gray"
    if ($theme.Fallback.ANSI16Map.Contains($Key)) {
        $ansiName = ($theme.Fallback.ANSI16Map[$Key] -split '\.')[-1]
        $mapped = switch ($ansiName) {
            "BrightBlack" { "DarkGray" } "BrightRed" { "Red" } "BrightGreen" { "Green" }
            "BrightYellow" { "Yellow" } "BrightBlue" { "Blue" } "BrightMagenta" { "Magenta" }
            "BrightCyan" { "Cyan" } "BrightWhite" { "White" } "Black" { "Black" }
            "Red" { "DarkRed" } "Green" { "DarkGreen" } "Yellow" { "DarkYellow" }
            "Blue" { "DarkBlue" } "Magenta" { "DarkMagenta" } "Cyan" { "DarkCyan" }
            "White" { "Gray" } default { "Gray" }
        }
    }
    return $mapped
}

# =============================================================================
# UTILS (ENCODING + NULL-SAFE)
# =============================================================================
function Get-FileContent($Path) {
    if (-not $Path -or -not (Test-Path -LiteralPath $Path)) { return $null }
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $raw = $utf8NoBom.GetString($bytes)
        if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
        return $raw.Trim()
    }
    catch { return $null }
}

function Resolve-ForgeModuleRelativePath {
    param([string]$ModuleName)
    $parts = $ModuleName -split '\.'
    if ($parts.Count -lt 3) { return $null }
    $domain = $parts[1]
    $leaf = (($parts[2..($parts.Count - 1)] -join '\') + '.psm1')
    return "Modules\$domain\$leaf"
}

function Resolve-ForgeModuleFile {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$ModuleName
    )
    $relative = Resolve-ForgeModuleRelativePath -ModuleName $ModuleName
    if ([string]::IsNullOrWhiteSpace($relative)) { return $null }
    $candidate = Join-ScapePath $ProjectRoot $relative
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        return Get-Item -LiteralPath $candidate -ErrorAction SilentlyContinue
    }
    return $null
}

function Get-ModulePayloads($ModulesDir, $ProjectRoot, $Topology) {
    $list = @()
    $domains = @('Root', 'Core', 'Acquisition', 'Analysis', 'Infrastructure', 'Presentation', 'Extensions', 'Forge', 'Orphans')

    foreach ($domain in $domains) {
        $domainMods = $Topology[$domain]
        if ($null -eq $domainMods) { continue }

        foreach ($mod in @($domainMods)) {
            if ($null -eq $mod) { continue }

            $modName = if ($mod -is [hashtable]) { $mod['Name'] } else { $mod.Name }
            $foundFile = Resolve-ForgeModuleFile -ProjectRoot $ProjectRoot -ModuleName $modName

            if ($foundFile) {
                $content = Get-FileContent -Path $foundFile.FullName
                if ($content) {
                    try { $null = [scriptblock]::Create($content) }
                    catch { throw ($(Get-Msg 'DEPLOYER_FATAL') -f "$($foundFile.Name) - $_") }
                    $list += [PSCustomObject]@{
                        Name    = $modName
                        Content = $content
                        Source  = $foundFile.FullName
                    }
                }
            }
        }
    }
    return $list
}

function Get-DataAssets($DataDir) {
    $assets = @()
    if ($DataDir -and (Test-Path $DataDir)) {
        Get-ChildItem -Path $DataDir -Recurse -File -Include '*.psd1', '*.json' -ErrorAction SilentlyContinue | ForEach-Object {
            $content = Get-FileContent -Path $_.FullName
            if ($content) {
                $relPath = $_.FullName.Substring($DataDir.Length).TrimStart('\')
                $safeName = $relPath -replace '\\', '_'
                $assets += [PSCustomObject]@{
                    Name    = "Asset_$safeName"
                    Content = $content
                }
            }
        }
    }
    return $assets
}

# =============================================================================
# SHOW-MANIFEST-TREE + TreeView Publishing (SOC-Compliant)
# =============================================================================
function Show-ManifestTree {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Manifest,
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$ProjPath,
        [ValidateSet("Topology", "Registry")][string]$ManifestType = "Topology"
    )

    $lineColor = Get-Clr 'Base.Amber'
    $headerKey = if ($ManifestType -eq "Topology") { 'DEPLOYER_MOD_DISCOVERY' } else { 'DEPLOYER_ASSETS_DISCOVERY' }
    $failKey = 'DEPLOYER_EXTRACT_FAIL'

    Write-Host "`n$(Get-Msg $headerKey)" -ForegroundColor (Get-Clr 'Base.Gray')

    if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
        Publish-ScapeTreeUpdate -TreeId "Build_$ManifestType" -TitleKey $headerKey -Nodes @(
            @{ Path = "$ManifestType/Scan/Start"; Icon = "Processing"; Status = 'Loading' }
        )
    }

    if ($ManifestType -eq "Topology") {
        $orderedDomains = @('Root', 'Core', 'Acquisition', 'Analysis', 'Infrastructure', 'Presentation', 'Extensions', 'Forge', 'Orphans')
        $visibleDomains = @()

        foreach ($dom in $orderedDomains) {
            $node = $Manifest[$dom]
            if ($null -ne $node -and @($node).Count -gt 0) { $visibleDomains += $dom }
        }

        $total = $visibleDomains.Count
        for ($d = 0; $d -lt $total; $d++) {
            $domain = $visibleDomains[$d]
            $isLast = ($d -eq $total - 1)
            $prefix = if ($isLast) { "└── " } else { "├── " }
            $indent = if ($isLast) { "    " } else { "│   " }

            Write-Host $prefix -NoNewline -ForegroundColor $lineColor
            Write-Host $domain -ForegroundColor $lineColor

            $mods = @($Manifest[$domain] | Where-Object { $null -ne $_ }) | Sort-Object LoadOrder
            $modCount = $mods.Count

            for ($m = 0; $m -lt $modCount; $m++) {
                $mod = $mods[$m]
                $isLastM = ($m -eq $modCount - 1)
                $corner = if ($isLastM) { "└── " } else { "├── " }

                $moduleName = if ($mod -is [hashtable]) { $mod['Name'] } else { $mod.Name }
                $found = Resolve-ForgeModuleFile -ProjectRoot $ProjPath -ModuleName $moduleName

                $status = if ($found) { "✓" } else { "✗" }
                $clr = if ($found) { "Green" } else { "Red" }

                Write-Host "$indent$corner" -NoNewline -ForegroundColor $lineColor
                Write-Host "$status $($mod.Name) [$($mod.LoadOrder)]" -ForegroundColor $clr

                if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
                    Publish-ScapeTreeUpdate -TreeId "Build_Topology" -TitleKey 'DEPLOYER_MOD_DISCOVERY' -Nodes @(
                        @{ Path = "Modules/$domain/$($mod.Name)"; Icon = "PSModule"; Status = $(if ($found) { 'Ready' } else { 'Error' }) }
                    )
                }

                if (-not $found -and $mod.IsVital) {
                    $errIndent = " " * ($indent.Length + $corner.Length)
                    $errMsgRaw = $(Get-Msg $failKey) -f $($mod.Name), "NotFound"
                    Write-Host "$errIndent [$errMsgRaw]" -ForegroundColor (Get-Clr 'Base.Red')
                }
            }
        }
    }
    else {
        $segments = $Manifest.Segments
        if (-not $segments) { return }
        $assets = @($segments.GetEnumerator() | Where-Object { $_.Name -ne '__Meta__' -and $null -ne $_.Value })
        if ($assets.Count -eq 0) { return }

        $groups = $assets | Group-Object { $_.Value.Layer }
        $sortedGroups = $groups | Sort-Object {
            $min = ($_.Group | ForEach-Object { $_.Value.LoadOrder } | Where-Object { $null -ne $_ } | Measure-Object -Minimum).Minimum
            if ($null -eq $min) { 9999 } else { $min }
        }

        $catCount = $sortedGroups.Count
        for ($c = 0; $c -lt $catCount; $c++) {
            $grp = $sortedGroups[$c]
            $layer = $grp.Name
            $isLastC = ($c -eq $catCount - 1)
            $prefix = if ($isLastC) { "└── " } else { "├── " }
            $indent = if ($isLastC) { "    " } else { "│   " }

            Write-Host $prefix -NoNewline -ForegroundColor $lineColor
            Write-Host "$layer Layer" -ForegroundColor $lineColor

            $catAssets = @($grp.Group | Sort-Object { if ($null -eq $_.Value.LoadOrder) { 9999 } else { $_.Value.LoadOrder } })
            $assetCount = $catAssets.Count

            for ($a = 0; $a -lt $assetCount; $a++) {
                $asset = $catAssets[$a]
                $isLastA = ($a -eq $assetCount - 1)
                $corner = if ($isLastA) { "└── " } else { "├── " }

                $relPath = $asset.Value.File
                $clean = $relPath -replace '^[Dd]ata\\', ''
                $searchPath = Join-ScapePath $BasePath $clean
                $found = if ($searchPath -and -not [string]::IsNullOrWhiteSpace($searchPath) -and (Test-Path $searchPath -PathType Leaf)) { $true } else { $false }

                $load = if ($null -ne $asset.Value.LoadOrder) { " [L:$($asset.Value.LoadOrder)]" } else { "" }
                $lazyTag = if ($asset.Value.IsLazy -eq $true) { " ⏱" } else { "" }
                $status = if ($found) { "✓" } else { "✗" }
                $clr = if ($found) { "Green" } else { "Red" }

                Write-Host "$indent$corner" -NoNewline -ForegroundColor $lineColor
                Write-Host "$status $relPath$load$lazyTag" -ForegroundColor $clr

                if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
                    Publish-ScapeTreeUpdate -TreeId "Build_Registry" -TitleKey 'DEPLOYER_ASSETS_DISCOVERY' -Nodes @(
                        @{ Path = "Assets/$layer/$($asset.Name)"; Icon = "File"; Status = $(if ($found) { 'Ready' } else { 'Error' }) }
                    )
                }

                if (-not $found) {
                    $errIndent = " " * ($indent.Length + $corner.Length)
                    $errMsgRaw = $(Get-Msg 'DEPLOYER_EXTRACT_FAIL') -f $relPath, "NotFound"
                    Write-Host "$errIndent [$errMsgRaw]" -ForegroundColor (Get-Clr 'Base.Red')
                }
            }
        }
    }

    if (Get-Command Publish-ScapeTreeUpdate -ErrorAction SilentlyContinue) {
        Publish-ScapeTreeUpdate -TreeId "Build_$ManifestType" -TitleKey $headerKey -Nodes @(
            @{ Path = "$ManifestType/Scan/Complete"; Icon = "Success"; Status = 'Ready' }
        )
    }

    Write-Host ""
}

function Write-Monolith($OutFile, $ModulePayloads, $DataAssets) {
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# SCAPE DEPLOY MONOLITH - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$sb.AppendLine('param([string]$InitialMenu = ''ForgeMenu'')')
    [void]$sb.AppendLine('$ErrorActionPreference = "Stop"')
    [void]$sb.AppendLine('[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8')
    [void]$sb.AppendLine('$Global:SCAPE_MEM = @{}')
    [void]$sb.AppendLine('')

    foreach ($a in $DataAssets) {
        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($a.Content))
        $keyName = if ($a.Name -match 'Topology\.psd1$') { 'Asset_Topology' } elseif ($a.Name -match 'Registry\.psd1$') { 'Asset_Registry' } else { $a.Name }
        [void]$sb.AppendLine("`$Global:SCAPE_MEM['$keyName'] = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$b64'))")
    }
    foreach ($m in $ModulePayloads) {
        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($m.Content))
        [void]$sb.AppendLine("`$Global:SCAPE_MEM['$($m.Name)'] = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$b64'))")
    }

    [void]$sb.AppendLine(@'
try {
    $Global:AppRoot = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { try { $Global:AppRoot = Split-Path -Parent $PSCommandPath -ErrorAction Stop } catch {} }
    if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) { $Global:AppRoot = (Get-Location).Path }
    $workspaceRootName = "Workspace"; $workspaceLogsName = "Logs"; $workspaceTempName = "Temp"; $workspaceDeployName = "Build"
    $systemConstPath = Join-Path $Global:AppRoot "Data\Constants\system.psd1"
    $forgeConstPath = Join-Path $Global:AppRoot "Data\Constants\forge.psd1"
    if (Test-Path -LiteralPath $systemConstPath) {
        $rawSystem = [System.IO.File]::ReadAllText($systemConstPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
        if (-not [string]::IsNullOrWhiteSpace($rawSystem)) {
            $systemConst = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawSystem))
            if ($systemConst -and $systemConst.Workspace) {
                $workspaceRootName = if ($systemConst.Workspace.ROOT) { [string]$systemConst.Workspace.ROOT } else { $workspaceRootName }
                $workspaceLogsName = if ($systemConst.Workspace.LOGS) { [string]$systemConst.Workspace.LOGS } else { $workspaceLogsName }
                $workspaceTempName = if ($systemConst.Workspace.TEMP) { [string]$systemConst.Workspace.TEMP } else { $workspaceTempName }
                $workspaceDeployName = if ($systemConst.Workspace.DEPLOY) { [string]$systemConst.Workspace.DEPLOY } else { $workspaceDeployName }
            }
        }
    }
    if (Test-Path -LiteralPath $forgeConstPath) {
        $rawForge = [System.IO.File]::ReadAllText($forgeConstPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
        if (-not [string]::IsNullOrWhiteSpace($rawForge)) {
            $forgeConst = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawForge))
            if ($forgeConst -and $forgeConst.Paths -and $forgeConst.Paths.DeployWorkspaceDir) { $workspaceDeployName = [string]$forgeConst.Paths.DeployWorkspaceDir }
        }
    }
    $workspaceRoot = Join-Path $Global:AppRoot $workspaceRootName
    $preferredWorkspace = Join-Path $Global:AppRoot "Workspace"
    if (Test-Path -LiteralPath $preferredWorkspace) { $workspaceRoot = $preferredWorkspace }
    $workspaceLogs = Join-Path $workspaceRoot $workspaceLogsName
    $workspaceTemp = Join-Path $workspaceRoot $workspaceTempName
    $workspaceDeploy = Join-Path $workspaceRoot $workspaceDeployName
    @($workspaceRoot, $workspaceLogs, $workspaceTemp, $workspaceDeploy) | ForEach-Object {
        if (-not (Test-Path -LiteralPath $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
    }

    $igniteKey = $null
    foreach ($k in $Global:SCAPE_MEM.Keys) { if ($k -match '\.Ignite$' -or $k -eq 'Ignite') { $igniteKey = $k; break } }
    . ([ScriptBlock]::Create($Global:SCAPE_MEM[$igniteKey]))

    if (Get-Module PSReadLine -ErrorAction SilentlyContinue) { Remove-Module PSReadLine -Force }
    [Console]::TreatControlCAsInput = $true

    $registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Registry']))
    $topology = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Topology']))
    $navSeg = if ($registry -and $registry.Segments -and $registry.Segments.ContainsKey('navigation')) { $registry.Segments['navigation'] } else { $null }
    $navRelPath = if ($navSeg -is [hashtable]) { $navSeg['File'] } else { $navSeg.File }
    $navMemKey = if ($navRelPath) { "Asset_$($navRelPath -replace '^[Dd]ata[/\\]', '' -replace '[/\\]', '_')" } else { $null }
    if ($navMemKey -and $Global:SCAPE_MEM.ContainsKey($navMemKey)) {
        $navigation = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM[$navMemKey]))
    } else {
        throw "HANDOFF_FATAL: Navigation asset payload missing in memory."
    }

    $modulesToLoad = @()
    foreach ($k in $topology.Keys) {
        if ($k -eq '__Meta__') { continue }
        $modulesToLoad += @($topology[$k] | Where-Object { $_.IsVital -eq $true -or $_.Domain -in @('Core','Forge', 'Infrastructure', 'Presentation') } | Sort-Object LoadOrder)
    }

    foreach ($mod in ($modulesToLoad | Sort-Object LoadOrder)) {
        Import-Module (New-Module -Name $mod.Name -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM[$mod.Name]))) -Global -Force
    }

        if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) {
        Initialize-ScapeLogger | Out-Null
        Invoke-ScapeIdlePump | Out-Null
    }

    # INICIALIZA O ESTADO PRIMEIRO
    Initialize-ScapeState | Out-Null
    Initialize-ScapeInterop | Out-Null
    Update-ScapeColdState -NewProperties @{
        ROOT = $Global:AppRoot
        Registry = $registry
        MANIFEST = $topology
        Topology = $topology
        Navigation = $navigation
        WORKSPACE_ROOT = $workspaceRoot
        WORKSPACE_LOGS = $workspaceLogs
        WORKSPACE_TEMP = $workspaceTemp
        WORKSPACE_DEPLOY = $workspaceDeploy
        DEV_MODE = $false
    } -Confirm:$false | Out-Null

    # CARREGA OS ASSETS (AGORA O STATE EXISTE)
    if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
        $state = Get-ScapeColdState
        if (-not $state.ContainsKey("Assets")) { $state["Assets"] = @{} }
        foreach ($key in $registry.Segments.Keys) {
            if ($key -eq "__Meta__") { continue }
            $seg = $registry.Segments[$key]
            $isLazy = if ($seg -is [hashtable]) { $seg["IsLazy"] } else { $seg.IsLazy }
            if ($isLazy -eq $false) {
                $file = if ($seg -is [hashtable]) { $seg["File"] } else { $seg.File }
                $cat  = if ($seg -is [hashtable]) { $seg["Category"] } else { $seg.Category }
                $assetPath = Join-Path $Global:AppRoot $file
                if (Test-Path $assetPath) {
                    $rawAsset = [System.IO.File]::ReadAllText($assetPath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), " "))
                    $parsedAsset = Invoke-Command -ScriptBlock ([scriptblock]::Create($rawAsset))
                    if (-not $state["Assets"].ContainsKey($cat)) { $state["Assets"][$cat] = @{} }
                    $state["Assets"][$cat][$key] = $parsedAsset
                }
            }
        }
    }

    # CARGA FORÇADA DE ASSETS CRÍTICOS (para ícones/ui/theme funcionarem no RAM-only monolith)
    if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
        $assetsToForce = @('ui', 'theme', 'en-US', 'infrastructure')
        foreach ($key in $registry.Segments.Keys) {
            if ($key -eq '__Meta__') { continue }
            if ($key -in $assetsToForce) {
                $seg = $registry.Segments[$key]
                $file = if ($seg -is [hashtable]) { $seg['File'] } else { $seg.File }
                $cat  = if ($seg -is [hashtable]) { $seg['Category'] } else { $seg.Category }
                $assetPath = Join-Path $Global:AppRoot $file
                if (Test-Path -LiteralPath $assetPath) {
                    Invoke-ScapeLoadAsset -Category $cat -AssetId $key -FilePath $assetPath -Silent | Out-Null
                }
            }
        }
    }

    Initialize-ScapeSetting -ForceReset:$false | Out-Null
    if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }
    if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }

    Resolve-ScapeManifestLayer -LayerKey "Presentation" | Out-Null
    Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null
    $defaultLang = Get-ScapeConstant -Path "system::Defaults::LANG" -Fallback "en-US"
    Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = $defaultLang }

    Start-ScapeRouter -InitialMenu $InitialMenu
} catch {
    $bootMsg = Get-Msg 'BOOT_FATAL_MATRIX'
    Write-Host ($bootMsg -f $_.Exception.Message) -ForegroundColor Red
    Read-Host (Get-Msg 'BOOT_PRESS_ENTER_EXIT')
}
'@)

    $outDir = Split-Path $OutFile -Parent
    if (-not (Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory -Force | Out-Null }
    [System.IO.File]::WriteAllText($OutFile, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
}

# =============================================================================
# MAIN PIPELINE
# =============================================================================
[Console]::CursorVisible = $true
[Console]::Clear()
Write-Host "[*] $(Get-Msg 'DEPLOYER_START')" -ForegroundColor (Get-Clr 'Base.Cyan')

$dataDir = Join-ScapePath $ProjectRoot 'Data'
$modulesDir = Join-ScapePath $ProjectRoot 'Modules'
$topoPath = Join-ScapePath $dataDir 'Manifests\Topology.psd1'
$registryPath = Join-ScapePath $dataDir 'Manifests\Registry.psd1'
$outDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $outDir)) { $null = New-Item -Path $outDir -ItemType Directory -Force }

if (-not (Test-Path $topoPath)) { throw ($(Get-Msg 'MANIFEST_NOT_FOUND') -f $topoPath) }
if (-not (Test-Path $registryPath)) { Write-Warning ($(Get-Msg 'MANIFEST_NOT_FOUND') -f 'Registry.psd1') }

$LoadManifest = { param($Path) $raw = Get-FileContent -Path $Path; return [scriptblock]::Create($raw).Invoke() }

$rawTopo = & $LoadManifest $topoPath
$topology = if ($rawTopo -is [array]) { $rawTopo[0] } else { $rawTopo }

$rawReg = if (Test-Path $registryPath) { & $LoadManifest $registryPath } else { @{ Segments = @{} } }
$registry = if ($rawReg -is [array]) { $rawReg[0] } else { $rawReg }

Show-ManifestTree -Manifest $topology -BasePath $modulesDir -ProjPath $ProjectRoot -ManifestType "Topology"
Show-ManifestTree -Manifest $registry -BasePath $dataDir -ProjPath $ProjectRoot -ManifestType "Registry"

$modulePayloads = Get-ModulePayloads -ModulesDir $modulesDir -ProjectRoot $ProjectRoot -Topology $topology

$igniteFound = $modulePayloads | Where-Object { $_.Name -match 'Ignite' }
if (-not $igniteFound) {
    $igniteMissing = Get-Msg 'IGNITE_DEPLOYER_MISSING'
    Write-Host "`n[!] $igniteMissing" -ForegroundColor Red
    throw (Get-Msg 'BOOT_IMPORT_FATAL' -f $igniteMissing)
}

$dataAssets = Get-DataAssets -DataDir $dataDir

Write-Monolith -OutFile $OutputPath -ModulePayloads $modulePayloads -DataAssets $dataAssets

Write-Host "`n[+] $(Get-Msg 'DEPLOYER_SUCCESS') -> $OutputPath" -ForegroundColor (Get-Clr 'Base.Green')
Write-Host "[>] Monolith compilation complete." -ForegroundColor (Get-Clr 'Base.Amber')

Start-Sleep -Milliseconds 400