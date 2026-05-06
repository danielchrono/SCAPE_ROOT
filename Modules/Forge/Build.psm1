<#
.SYNOPSIS
    Build.ps1 - SCAPE Monolith Forge (v1.0 - PATH RESOLVER & DICTIONARY SYNC)
    Architecture: Deterministic Tree | Subfolder Parsing | Safe Boot Sequence | TreeView-Ready
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = $(if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }),
    [string]$OutputPath = (Join-ScapePath $(if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }) 'Output\SCAPE_DEPLOY.ps1')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function Get-ModulePayloads($ModulesDir, $ProjectRoot, $Topology) {
    $list = @()
    $domains = @('Root', 'Core', 'Acquisition', 'Analysis', 'Infrastructure', 'Presentation', 'Extensions', 'Forge', 'Orphans')

    foreach ($domain in $domains) {
        $domainMods = $Topology[$domain]
        if ($null -eq $domainMods) { continue }

        foreach ($mod in @($domainMods)) {
            if ($null -eq $mod) { continue }

            $fileNameBase = ($mod.Name -split '\.')[-1]
            $foundFile = $null

            if ($domain -eq 'Root') {
                $foundFile = Get-ChildItem -Path $ProjectRoot -File | Where-Object { $_.BaseName -eq $fileNameBase -and $_.Extension -match '\.psm?1$' } | Select-Object -First 1
            }
            else {
                $searchPath = Join-ScapePath $ModulesDir $domain
                if (Test-Path $searchPath) {
                    $foundFile = Get-ChildItem -Path $searchPath -File -Recurse | Where-Object { $_.BaseName -eq $fileNameBase -and $_.Extension -match '\.psm?1$' } | Select-Object -First 1
                }
            }

            if ($foundFile) {
                $content = Get-FileContent -Path $foundFile.FullName
                if ($content) {
                    try { $null = [scriptblock]::Create($content) }
                    catch { throw ($(Get-Msg 'DEPLOYER_FATAL') -f "$($foundFile.Name) - $_") }
                    $list += [PSCustomObject]@{
                        Name    = if ($mod -is [hashtable]) { $mod['Name'] } else { $mod.Name }
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

                $fileNameBase = ($mod.Name -split '\.')[-1]
                $found = $null

                if ($domain -eq 'Root') {
                    $found = Get-ChildItem -Path $ProjPath -File | Where-Object { $_.BaseName -eq $fileNameBase -and $_.Extension -match '\.psm?1$' } | Select-Object -First 1
                }
                else {
                    $searchPath = Join-ScapePath $BasePath $domain
                    if (Test-Path $searchPath) {
                        $found = Get-ChildItem -Path $searchPath -File -Recurse | Where-Object { $_.BaseName -eq $fileNameBase -and $_.Extension -match '\.psm?1$' } | Select-Object -First 1
                    }
                }

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

    $igniteKey = $null
    foreach ($k in $Global:SCAPE_MEM.Keys) { if ($k -match '\.Ignite$' -or $k -eq 'Ignite') { $igniteKey = $k; break } }
    . ([ScriptBlock]::Create($Global:SCAPE_MEM[$igniteKey]))

    if (Get-Module PSReadLine -ErrorAction SilentlyContinue) { Remove-Module PSReadLine -Force }
    [Console]::TreatControlCAsInput = $true

    $registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Registry']))
    $topology = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Topology']))
    $navigation = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Navigation']))

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
    Update-ScapeColdState -NewProperties @{ ROOT = $Global:AppRoot; Registry = $registry; Topology = $topology; Navigation = $navigation } -Confirm:$false | Out-Null

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

    Initialize-ScapeSetting -ForceReset:$false | Out-Null
    # if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) { Initialize-ScapeLogger | Out-Null }
    if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) { Initialize-ScapeResolver | Out-Null }

    Resolve-ScapeManifestLayer -LayerKey "Presentation" | Out-Null
    Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null
    Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = "pt-BR" }

    Start-ScapeRouter -InitialMenu $InitialMenu
} catch {
    Write-Host ("[!] BOOT_FATAL_MATRIX: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Read-Host "BOOT_PRESS_ENTER_EXIT"
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
$OutputPath = Join-ScapePath $ProjectRoot "Output\SCAPE_DEPLOY.ps1"

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
    Write-Host "`n[!] $($(Get-Msg 'DEPLOYER_FATAL') -f 'Ignite module missing')" -ForegroundColor Red
    throw ($(Get-Msg 'DEPLOYER_FATAL') -f "Boot module missing.")
}

$dataAssets = Get-DataAssets -DataDir $dataDir

Write-Monolith -OutFile $OutputPath -ModulePayloads $modulePayloads -DataAssets $dataAssets

Write-Host "`n[+] $(Get-Msg 'DEPLOYER_SUCCESS') -> $OutputPath" -ForegroundColor (Get-Clr 'Base.Green')
Write-Host "[>] $(Get-Msg 'DEPLOYER_LAUNCH_SCAPE')" -ForegroundColor (Get-Clr 'Base.Amber')

Start-Sleep -Milliseconds 400
if (Test-Path $OutputPath) {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$OutputPath`""
    }
    else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$OutputPath`""
    }
}
