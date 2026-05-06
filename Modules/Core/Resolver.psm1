<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.Resolver
    .DESCRIPTION
    Orchestrates JIT loading of Modules (Topology) and Assets (Registry/I18N).
    Architecture: Hybrid Matrix (RAM) + Disk Fallback.
#>
[CmdletBinding()]
param()

function Assert-ScapeCapability {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)][string]$CapabilityName)

    $state = Get-ScapeColdState
    $loaded = if ($state.ContainsKey("LoadedLayers")) { $state["LoadedLayers"] } else { @() }

    if ($CapabilityName -notin $loaded) {
        Publish-ScapeEvent -Type "CAPABILITY_FAULT" -Severity "FATAL" -Payload "Capability '$CapabilityName' is not present"
        throw "CAPABILITY_FAULT: $CapabilityName"
    }
    return $true
}

function Invoke-ScapeResolveModule {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)][string]$ModuleName)

    $state = Get-ScapeColdState
    if ($null -eq $state) { throw "RESOLVER_FATAL: State engine not initialized." }

    if (-not $state.ContainsKey("LoadedLayers") -or $null -eq $state["LoadedLayers"]) {
        $state["LoadedLayers"] = New-Object 'System.Collections.Generic.List[string]'
    }

    if ($ModuleName -in $state["LoadedLayers"]) { return $true }

    $manifest = if ($state.ContainsKey("MANIFEST")) { $state["MANIFEST"] } else { $null }
    if ($null -eq $manifest) { throw "RESOLVER_FATAL: Global Manifest missing from state." }

    $modDef = $null
    foreach ($layerKey in $manifest.Keys) {
        if ($layerKey -eq '__Meta__') { continue }
        $found = $manifest[$layerKey] | Where-Object {
            $n = if ($_ -is [hashtable]) { $_['Name'] } elseif ($null -ne $_.PSObject) { $_.Name } else { '' }
            $n -eq $ModuleName
        }
        if ($found) { $modDef = $found; break }
    }

    if ($null -eq $modDef) { return $false }

    $deps = if ($modDef -is [hashtable]) { $modDef['DependsOn'] } elseif ($null -ne $modDef.PSObject) { $modDef.DependsOn } else { $null }
    if ($null -ne $deps) {
        foreach ($dep in $deps) { Invoke-ScapeResolveModule -ModuleName $dep | Out-Null }
    }

    $payloadContent = $null
    if ($Global:SCAPE_MEM -is [hashtable] -and $Global:SCAPE_MEM.ContainsKey($ModuleName)) {
        $payloadContent = $Global:SCAPE_MEM[$ModuleName]
    }
    else {
        $modName = if ($modDef -is [hashtable]) { $modDef['Name'] } elseif ($null -ne $modDef.PSObject) { $modDef.Name } else { '' }
        $fileName = ($modName -split '\.')[-1] + ".psm1"
        $baseRoot = if ($state.ContainsKey("ROOT") -and $state["ROOT"]) { $state["ROOT"] } else { $PSScriptRoot }

        if ($baseRoot -and (Test-Path $baseRoot)) {
            $modPath = Get-ChildItem -Path (Join-ScapePath $baseRoot "Modules") -Filter $fileName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($modPath) { $payloadContent = Get-Content $modPath.FullName -Raw -Encoding UTF8 }
        }
    }

    if ($null -eq $payloadContent) {
        $vital = if ($modDef -is [hashtable]) { $modDef['IsVital'] } elseif ($null -ne $modDef.PSObject) { $modDef.IsVital } else { $false }
        if ($vital) { throw "FATAL_INJECTION_FAILURE: Missing vital module '$ModuleName'" }
        return $false
    }

    try {
        $dynModule = New-Module -Name $ModuleName -ScriptBlock ([scriptblock]::Create($payloadContent))
        Import-Module -ModuleInfo $dynModule -Global -Force

        if ($state["LoadedLayers"] -is [array]) {
            $mutableList = [System.Collections.Generic.List[string]]::new([string[]]$state["LoadedLayers"])
            $mutableList.Add($ModuleName)
            $state["LoadedLayers"] = $mutableList
        }
        else {
            $state["LoadedLayers"].Add($ModuleName)
        }

        Publish-ScapeEvent -Type "MODULE_LOADED" -Severity "DEBUG" -Payload $ModuleName
        return $true
    }
    catch { throw "INJECTION_ERROR: Failed to ignite '$ModuleName' : $($_.Exception.Message)" }
}

function Resolve-ScapeManifestLayer {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$LayerKey)

    $manifest = Get-ScapeManifest
    if ($null -eq $manifest -or -not $manifest.ContainsKey($LayerKey)) {
        throw "RESOLVER_ERROR: Layer '$LayerKey' does not exist in Manifest."
    }

    Publish-ScapeEvent -Type "LAYER_IGNITION" -Severity "INFO" -Payload "Igniting Layer: $LayerKey"
    $sortedModules = $manifest[$LayerKey] | Sort-Object LoadOrder
    foreach ($module in $sortedModules) {
        $mName = if ($module -is [hashtable]) { $module['Name'] } elseif ($null -ne $module.PSObject) { $module.Name } else { '' }
        Invoke-ScapeResolveModule -ModuleName $mName | Out-Null
    }
}

function Invoke-ScapeWakeAssets {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Domain)

    $state = Get-ScapeColdState
    if (-not $state.ContainsKey("Registry")) { return }

    $reg = $state["Registry"]
    foreach ($key in $reg.Segments.Keys) {
        if ($key -eq '__Meta__') { continue }
        $seg = $reg.Segments[$key]

        $layer = if ($seg -is [hashtable]) { $seg['Layer'] } elseif ($null -ne $seg.PSObject) { $seg.Layer } else { '' }
        $isLazy = if ($seg -is [hashtable]) { $seg['IsLazy'] } elseif ($null -ne $seg.PSObject) { $seg.IsLazy } else { $false }

        if ($layer -ieq $Domain -and $isLazy -eq $true) {
            $file = if ($seg -is [hashtable]) { $seg['File'] } elseif ($null -ne $seg.PSObject) { $seg.File } else { '' }
            $cat = if ($seg -is [hashtable]) { $seg['Category'] } elseif ($null -ne $seg.PSObject) { $seg.Category } else { '' }

            $assetPath = Join-ScapePath -Base $state["ROOT"] -Child $file
            if ($assetPath -and (Test-Path $assetPath)) {
                Invoke-ScapeLoadAsset -Category $cat -AssetId $key -FilePath $assetPath -Silent | Out-Null
            }
        }
    }
}

function Resolve-ScapeAsset {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$AssetId,
        [string]$Category = $null,
        [switch]$Force
    )

    if (-not $Force) {
        $existing = Get-ScapeAsset -Category $Category -AssetId $AssetId
        if ($null -ne $existing) { return $true }
    }

    $result = Invoke-ScapeLazyLoadAsset -AssetId $AssetId -Category $Category
    if ($result) {
        Publish-ScapeEvent -Type "ASSET_READY" -Severity "INFO" -Payload @{
            AssetId  = $AssetId
            Category = $Category
        }
        return $true
    }
    return $false
}

function Initialize-ScapeResolver {
    [CmdletBinding()]
    param()

    # --- LISTENER 1: LANG_SWITCH ---
    Register-ScapeEventListener -EventMatch "LANG_SWITCH" -Action {
        param($EventFrame)
        $p = $EventFrame.Payload
        $newLang = if ($p -is [hashtable]) { $p['Language'] } elseif ($null -ne $p.PSObject) { $p.Language } else { '' }
        if ([string]::IsNullOrWhiteSpace($newLang)) { return }

        $success = Resolve-ScapeAsset -AssetId $newLang -Category "I18N"
        if (-not $success) {
            Publish-ScapeEvent -Type "LANG_SWITCH_FAILED" -Severity "ERROR" -Payload "Could not load language asset: $newLang"
            return
        }

        $state = Get-ScapeColdState
        $oldLang = Get-ScapeProperty -Object $state -PropertyName 'CurrentLanguage'
        if (-not [string]::IsNullOrWhiteSpace($oldLang) -and $oldLang -ne $newLang) {
            $removed = Remove-ScapeAsset -Category "I18N" -AssetId $oldLang
            if ($removed) {
                Publish-ScapeEvent -Type "LANG_FLUSHED" -Severity "DEBUG" -Payload "Old language '$oldLang' removed from cache."
            }
        }

        Update-ScapeColdState -NewProperties @{ CurrentLanguage = $newLang } | Out-Null

        Publish-ScapeEvent -Type "MENU_LANGUAGE_SWITCH" -Severity "TRACE" -Payload @{
            Key    = "MENU_LANGUAGE_SWITCH"
            Tokens = @($newLang)
        }
        Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "TRACE" -Payload @{ Reason = "Language changed to $newLang" }
    }

    # --- LISTENER 2: MENU_OPEN ---
    Register-ScapeEventListener -EventMatch "MENU_OPEN" -Action {
        param($EventFrame)
        $p = $EventFrame.Payload
        $menuId = if ($p -is [hashtable]) { $p['MenuId'] } elseif ($null -ne $p.PSObject) { $p.MenuId } else { '' }
        if ([string]::IsNullOrWhiteSpace($menuId)) { return }

        switch ($menuId) {
            'ThemeMenu' { Resolve-ScapeAsset -AssetId 'theme' -Category 'Constants' -Force:$false | Out-Null }
            'RobocopyMenu' { Resolve-ScapeAsset -AssetId 'fs' -Category 'Constants' -Force:$false | Out-Null }
        }
    }

    # --- LISTENER 3: UI_SELECTION (Híbrido) ---
    Register-ScapeEventListener -EventMatch "UI_SELECTION" -Action {
        param($EventFrame)
        $p = $EventFrame.Payload
        if ($null -eq $p) { return }
        $wake = if ($p -is [hashtable]) { $p['Layer'] } elseif ($null -ne $p.PSObject) { $p.Layer } else { $null }

        if (-not [string]::IsNullOrWhiteSpace($wake)) {
            if (Get-Command Resolve-ScapeManifestLayer -ErrorAction SilentlyContinue) {
                Resolve-ScapeManifestLayer -LayerKey $wake | Out-Null
            }
            Invoke-ScapeWakeAssets -Domain $wake | Out-Null
            Publish-ScapeEvent -Type "LAZY_WAKEUP" -Severity "DEBUG" -Payload "Hydrated Domain: $wake"
        }

        $action = if ($p -is [hashtable]) { $p['Action'] } else { $p.Action }
        $actionPayload = if ($p -is [hashtable]) { $p['ActionPayload'] } else { $p.ActionPayload }
        $menuId = if ($p -is [hashtable]) { $p['MenuId'] } else { $p.MenuId }
        $selectionId = if ($p -is [hashtable]) { $p['SelectionId'] } else { $p.SelectionId }

        if ($action -eq 'TRIGGER' -and $null -ne $actionPayload) {
            $domain = if ($actionPayload -is [hashtable]) { $actionPayload['Domain'] } else { $actionPayload.Domain }
            $target = if ($actionPayload -is [hashtable]) { $actionPayload['Target'] } else { $actionPayload.Target }
            $task = if ($actionPayload -is [hashtable]) { $actionPayload['Task'] } else { $actionPayload.Task }

            if ($target) {
                Invoke-ScapeResolveModule -ModuleName $target | Out-Null

                if ($target -eq "Scape.Forge.Deployer") {
                    Invoke-ScapeDeployWorkflow -Task $task
                }
                else {
                    Publish-ScapeEvent -Type "TRIGGER_DISPATCHED" -Severity "INFO" -Payload $target
                }
            }
        }
        elseif ($action -eq 'MUTATE' -and $null -ne $actionPayload) {
            if (Get-Command Invoke-ScapeStateMutation -ErrorAction SilentlyContinue) {
                Invoke-ScapeStateMutation -MenuId $menuId -SelectionId $selectionId -Payload $actionPayload
            }
        }
    }

    # --- LISTENER 4: UI_REDRAW_REQUEST (Híbrido) ---
    Register-ScapeEventListener -EventMatch "UI_REDRAW_REQUEST" -Action {
        param($EventFrame)
        $p = $EventFrame.Payload
        if ($null -eq $p) { return }

        $menuId = if ($p -is [hashtable]) { $p['MenuId'] } elseif ($null -ne $p.PSObject) { $p.MenuId } else { $null }
        $rawType = if ($p -is [hashtable]) { $p['Type'] } elseif ($null -ne $p.PSObject) { $p.Type } else { 'PARTIAL' }
        $isFull = ($rawType -eq 'FULL')

        if ($menuId -and $isFull) {
            $navData = Get-ScapeConstant -Path "navigation::$menuId" -Fallback @()

            $Layers = @($navData | ForEach-Object {
                    $val = if ($_ -is [hashtable]) { $_['Layer'] } elseif ($null -ne $_.PSObject) { $_.Layer } else { $null }
                } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

            foreach ($domain in $Layers) {
                Invoke-ScapeWakeAssets -Domain $domain | Out-Null
            }

            Publish-ScapeEvent -Type "RESOLVER_REDRAW_SYNC" -Severity "DEBUG" -Payload @{ Menu = $menuId; Domains = @($Layers) }
        }
    }
}
