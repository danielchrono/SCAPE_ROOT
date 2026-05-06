<#
.SYNOPSIS
    deploy.ps1 - O Único Ponto de Entrada (The SCAPE Spark)
    Versão final com diagnóstico e força de assets essenciais.
#>
$ErrorActionPreference = 'Stop'

# 0. Limpeza de memória de módulos anteriores
Get-Module -Name "Scape.*" | Remove-Module -Force -ErrorAction SilentlyContinue
[System.GC]::Collect()

# 1. Root e workspace
$Global:AppRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Global:AppRoot)) {
    $Global:AppRoot = (Get-Location).Path
}
$Global:BootRoot = $Global:AppRoot

# Remove main.ps1 residual
if (Test-Path "$Global:AppRoot\main.ps1") {
    Remove-Item "$Global:AppRoot\main.ps1" -Force -ErrorAction SilentlyContinue
}

# Prepara diretórios de workspace
$logsDir = Join-Path $Global:AppRoot "workspace\logs"
$tempDir = Join-Path $Global:AppRoot "workspace\temp"
@($logsDir, $tempDir) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

# 2. Hidratação da RAM (Ignite – lê Topology, Registry, assets e módulos do disco)
$Global:SCAPE_MEM = @{}
. (Join-Path $Global:AppRoot 'Modules\Forge\Ignite.ps1') | Out-Null

# 3. Parse dos manifestos (já estão em memória)
$manifest = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Topology']))
$registry = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Registry']))
$navigation = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM['Asset_Navigation']))

# 4. Injeção dinâmica dos módulos vitais + Core (ordem do Topology)
$modulesToLoad = @()
foreach ($domain in $manifest.Keys) {
    if ($domain -eq '__Meta__') { continue }
    $modulesToLoad += @($manifest[$domain] | Where-Object {
            $isVital = if ($_ -is [hashtable]) { $_['IsVital'] } else { $_.IsVital }
            $dom = if ($_ -is [hashtable]) { $_['Domain'] } else { $_.Domain }
            $isVital -eq $true -or $dom -in @('Core')
        })
}

foreach ($mod in ($modulesToLoad | Sort-Object LoadOrder)) {
    $modName = if ($mod -is [hashtable]) { $mod['Name'] } else { $mod.Name }
    $domain = if ($mod -is [hashtable]) { $mod['Domain'] } else { $mod.Domain }

    $fileName = ($modName -split '\.')[-1] + ".psm1"
    $diskPath = Join-Path $Global:AppRoot "Modules\$domain\$fileName"

    $scriptContent = $null
    if (Test-Path -LiteralPath $diskPath) {
        # Leitura segura UTF-8 sem BOM
        $bytes = [System.IO.File]::ReadAllBytes($diskPath)
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        $raw = $utf8.GetString($bytes).Trim()
        if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
        $scriptContent = $raw
        $Global:SCAPE_MEM[$modName] = $scriptContent
    }
    elseif ($Global:SCAPE_MEM.ContainsKey($modName)) {
        $scriptContent = $Global:SCAPE_MEM[$modName]
    }

    if ($scriptContent) {
        Import-Module (New-Module -Name $modName -ScriptBlock ([scriptblock]::Create($scriptContent))) -Global -Force
        # Atualiza LoadedLayers
        $st = Get-ScapeColdState
        if ($st.ContainsKey("LoadedLayers")) {
            $st["LoadedLayers"].Add($modName)
        }
    }
}

# 5. Inicialização do estado imutável (COLD STATE) e Interop
Initialize-ScapeState | Out-Null
Initialize-ScapeInterop | Out-Null

Update-ScapeColdState -NewProperties @{
    ROOT            = $Global:AppRoot
    Registry        = $registry
    Manifest        = $manifest
    Navigation      = $navigation
    WORKSPACE_TEMP  = $tempDir
    WORKSPACE_LOGS  = $logsDir
    DEV_MODE        = $true
    CurrentLanguage = "en-US"
} -Confirm:$false | Out-Null

# Após o foreach que importa os módulos, adicione:
if (Get-Command Initialize-ScapeLogger -ErrorAction SilentlyContinue) {
    Initialize-ScapeLogger | Out-Null
    # Drena a fila para processar eventos de log
    Invoke-ScapeIdlePump | Out-Null
    # Publica um evento de teste
    Publish-ScapeEvent -Type "TEST_LOG" -Severity "INFO" -Payload "Logger ativo antes do State"
    Invoke-ScapeIdlePump | Out-Null
    Write-Host "[LOGGER] Inicializado e testado." -ForegroundColor Green
}

# 6. CARGA FORÇADA DE ASSETS ESSENCIAIS (ignora IsLazy)
if (Get-Command Invoke-ScapeLoadAsset -ErrorAction SilentlyContinue) {
    $assetsToForce = @('ui', 'theme', 'en-US', 'infrastructure')
    foreach ($key in $registry.Segments.Keys) {
        if ($key -eq '__Meta__') { continue }
        $seg = $registry.Segments[$key]
        $isLazy = if ($seg -is [hashtable]) { $seg['IsLazy'] } else { $seg.IsLazy }
        # Carrega se não for lazy OU se estiver na lista de forçados
        if (-not $isLazy -or ($key -in $assetsToForce)) {
            $file = if ($seg -is [hashtable]) { $seg['File'] } else { $seg.File }
            $cat = if ($seg -is [hashtable]) { $seg['Category'] } else { $seg.Category }
            $assetPath = Join-Path $Global:AppRoot $file
            if (Test-Path -LiteralPath $assetPath) {
                Invoke-ScapeLoadAsset -Category $cat -AssetId $key -FilePath $assetPath -Silent | Out-Null
                Write-Host "  Asset carregado: $cat/$key" -ForegroundColor DarkGray
            }
            else {
                Write-Warning "Asset file not found: $assetPath (key=$key)"
            }
        }
    }
}

# 7. Inicialização do Settings (aplica defaults ou carrega JSON)
Initialize-ScapeSetting -ForceReset:$false | Out-Null

# 8. Inicialização do Logger, Theme e Resolver (ordem importante!)
if (Get-Command Initialize-ScapeTheme -ErrorAction SilentlyContinue) {
    Initialize-ScapeTheme | Out-Null
}
if (Get-Command Initialize-ScapeResolver -ErrorAction SilentlyContinue) {
    Initialize-ScapeResolver | Out-Null
}

# 9. Acorda assets da Presentation (que podem ser lazy) e dispara idioma
if (Get-Command Invoke-ScapeWakeAssets -ErrorAction SilentlyContinue) {
    Invoke-ScapeWakeAssets -Domain "Presentation" | Out-Null
    $st = Get-ScapeColdState
    $lang = if ($st.ContainsKey('CurrentLanguage')) { $st['CurrentLanguage'] } else { 'en-US' }
    Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = $lang }
}

# 10. STATE OBSERVER
if (Get-Command Initialize-ScapeStateObserver -ErrorAction SilentlyContinue) {
    Initialize-ScapeStateObserver -AutoRegister -Confirm:$false | Out-Null
}

# 11. VERIFICAÇÃO PRÉ-BOOT (DIAGNÓSTICO)
$hasRedrawListener = $false
$subsCount = 0
if (Get-Module Scape.Core.EventBus) {
    try {
        $busModule = Get-Module Scape.Core.EventBus
        $subs = $busModule.SessionState.PSVariable.GetValue('EventSubscribers', @())
        $subsCount = $subs.Count
        $hasRedrawListener = ($null -ne $subs) -and ($subs | Where-Object { $_.Match -eq 'UI_REDRAW_REQUEST' })
    }
    catch {}
}

# 12. FAIL-FAST: função de ícone disponível
if (-not (Get-Command Get-ScapeResolvedIcon -ErrorAction SilentlyContinue)) {
    throw "BOOT_FATAL_MATRIX: Get-ScapeResolvedIcon not available. Presentation.Theme failed to load or initialize."
}

# 13. DIAGNÓSTICO PRÉ-BOOT (Pre-Flight Dashboard)
[Console]::CursorVisible = $true
[Console]::Clear()
$st = Get-ScapeColdState
$treeItems = @()
$treeItems += @{ Text = "$(Get-ScapeResolvedIcon -RouteId 'Folder') SYSTEM_ROOT: $($st['ROOT'])"; Depth = 0; StatusFlag = "HINT" }

# Árvore de assets
$treeItems += @{ Text = "$(Get-ScapeResolvedIcon -RouteId 'Database') ASSETS_MOUNTED"; Depth = 0; StatusFlag = "STATUS" }
$assetsCat = if ($st.ContainsKey('Assets')) { @($st['Assets'].Keys) } else { @() }
for ($i = 0; $i -lt $assetsCat.Count; $i++) {
    $cat = $assetsCat[$i]
    $isLastCat = ($i -eq $assetsCat.Count - 1)
    $prefixCat = if ($isLastCat) { "└── " } else { "├── " }
    $treeItems += @{ Text = "$prefixCat$(Get-ScapeResolvedIcon -RouteId 'Folder') $cat"; Depth = 1; StatusFlag = "INFO" }
    $asts = @($st['Assets'][$cat].Keys)
    for ($j = 0; $j -lt $asts.Count; $j++) {
        $ast = $asts[$j]
        $isLastAst = ($j -eq $asts.Count - 1)
        $prefixAst = if ($isLastAst) { "└── " } else { "├── " }
        $indent = if ($isLastCat) { "    " } else { "│   " }
        $treeItems += @{ Text = "$indent$prefixAst$(Get-ScapeResolvedIcon -RouteId 'File') $ast"; Depth = 1; StatusFlag = "Success" }
    }
}

# Módulos carregados
$loadedMods = if ($st.ContainsKey('LoadedLayers')) { @($st['LoadedLayers']) } else { @() }
$treeItems += @{ Text = "$(Get-ScapeResolvedIcon -RouteId 'PSModule') MODULES_BOUND ($($loadedMods.Count) injected)"; Depth = 0; StatusFlag = "STATUS" }
for ($m = 0; $m -lt $loadedMods.Count; $m++) {
    $mod = $loadedMods[$m]
    $isLastMod = ($m -eq $loadedMods.Count - 1)
    $prefixMod = if ($isLastMod) { "└── " } else { "├── " }
    $treeItems += @{ Text = "$prefixMod$(Get-ScapeResolvedIcon -RouteId 'Success') $mod"; Depth = 1; StatusFlag = "Success" }
}

# Roteamento e eventos
$nav = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
$navFlag = if ($nav -and $nav['DeployMenu']) { "Success" } else { "Failure" }
$treeItems += @{ Text = "├── $(Get-ScapeResolvedIcon -RouteId 'Compass') ROUTING_TABLE: DeployMenu resolved"; Depth = 0; StatusFlag = $navFlag }
$busFlag = if ($hasRedrawListener) { "Success" } else { "Failure" }
$treeItems += @{ Text = "├── $(Get-ScapeResolvedIcon -RouteId 'Lightning') EVENT_BUS: $subsCount active listeners attached"; Depth = 0; StatusFlag = $busFlag }
$treeItems += @{ Text = "└── $(Get-ScapeResolvedIcon -RouteId 'Shield') ENVIRONMENT: DEV_MODE=$($st['DEV_MODE'])"; Depth = 0; StatusFlag = "WARN" }

$renderConfig = @{
    Type         = 'TreeView'
    ShouldRender = $true
    Config       = @{ TitleKey = "MENU_DEPLOY_TITLE"; Items = $treeItems }
}
Write-ScapeTransientView -RenderConfig $renderConfig

$promptConfig = @{
    Type         = 'Transient'
    ShouldRender = $true
    Text         = "Press [ENTER] to ignite the SCAPE Router..."
    Flag         = 'MENU'
    Priority     = 1
}

Write-ScapeTransientView -RenderConfig $promptConfig
Read-Host

[Console]::CursorVisible = $true
[Console]::Clear()

# Verificação final antes do Router
$navAsset = Get-ScapeAsset -Category "Manifests" -AssetId "navigation"
if (-not $navAsset) {
    Write-Host "[ERRO] Navigation asset não encontrado!" -ForegroundColor Red
    $st = Get-ScapeColdState
    if ($st.ContainsKey("Assets") -and $st["Assets"].ContainsKey("Manifests")) {
        Write-Host "Assets carregados em Manifests: $($st['Assets']['Manifests'].Keys -join ', ')"
    }
    else {
        Write-Host "Nenhum asset da categoria Manifests foi carregado."
    }
    throw "Navigation ausente"
}
if (-not $navAsset.ContainsKey("DeployMenu")) {
    Write-Host "[ERRO] DeployMenu não encontrado no Navigation.psd1" -ForegroundColor Red
    Write-Host "Chaves disponíveis: $($navAsset.Keys -join ', ')"
    throw "DeployMenu missing"
}

# 14. Limpeza do buffer de entrada (apenas uma vez)
if (Get-Command Clear-ScapeInputBuffer -ErrorAction SilentlyContinue) {
    Clear-ScapeInputBuffer
}

# 15. Inicia o Router com o menu DeployMenu
Write-Host "[DEBUG] Iniciando o Router..." -ForegroundColor Yellow
try {
    Start-ScapeRouter -InitialMenu 'DeployMenu'
}
catch [System.Management.Automation.RuntimeException] {
    if ($_.Exception.Message -eq "SCAPE_HANDOVER") {
        Write-Host "Handing over to new SCAPE instance..." -ForegroundColor Cyan
        # Opcional: pausa rápida
        Start-Sleep -Seconds 1
        # Não exibe crash
    }
    else {
        throw $_
    }
}
catch {
    Write-Host "`n[💀 CRASH]" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor White
    Write-Host "Stack: $($_.ScriptStackTrace)" -ForegroundColor Gray
    Read-Host "Press ENTER to exit..."
}
finally {
    if (Get-Command Close-ScapeLogStream -ErrorAction SilentlyContinue) {
        Close-ScapeLogStream
    }
    [System.GC]::Collect()
}
