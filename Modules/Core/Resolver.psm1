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

function Resolve-ScapeModuleDiskPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$ModuleName,
        [Parameter(Mandatory = $true)][string]$BaseRoot
    )

    $parts = $ModuleName -split '\.'
    if ($parts.Count -lt 3) { return $null }

    $domain = $parts[1]
    if ([string]::IsNullOrWhiteSpace($domain)) { return $null }

    if ($parts.Count -ge 3) {
        $leafParts = @($parts[2..($parts.Count - 1)])
        $relative = "Modules\$domain\$(($leafParts -join '\')).psm1"
    }
    else {
        $relative = "Modules\$domain\$($parts[-1]).psm1"
    }

    $candidate = Join-ScapePath -Base $BaseRoot -Child $relative
    if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        return $candidate
    }
    return $null
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
        $baseRoot = if ($state.ContainsKey("ROOT") -and $state["ROOT"]) { $state["ROOT"] } else { $PSScriptRoot }

        if ($baseRoot -and (Test-Path $baseRoot)) {
            $exactPath = Resolve-ScapeModuleDiskPath -ModuleName $modName -BaseRoot $baseRoot
            if ($exactPath) {
                $payloadContent = Get-Content -LiteralPath $exactPath -Raw -Encoding UTF8
            }
            else {
                $modParts = $modName -split '\.'
                $fileName = ($modParts[-1]) + ".psm1"
                $domainPath = if ($modParts.Count -ge 2) { Join-ScapePath -Base $baseRoot -Child ("Modules\" + $modParts[1]) } else { Join-ScapePath -Base $baseRoot -Child "Modules" }
                if ($domainPath -and (Test-Path -LiteralPath $domainPath)) {
                    $modPath = Get-ChildItem -LiteralPath $domainPath -Filter $fileName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($modPath) { $payloadContent = Get-Content -LiteralPath $modPath.FullName -Raw -Encoding UTF8 }
                }
            }
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

        Publish-ScapeEvent -Type "MODULE_LOADED" -Severity "TRACE" -Payload $ModuleName
        return $true
    }
    catch { throw "INJECTION_ERROR: Failed to ignite '$ModuleName' : $($_.Exception.Message)" }
}

function Resolve-ScapeManifestLayer {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$LayerKey)

    $manifest = Get-ScapeManifest
    if ($null -eq $manifest) {
        throw "RESOLVER_ERROR: Manifest is null in Get-ScapeManifest."
    }

    if (-not ($manifest -is [hashtable] -or $manifest -is [System.Collections.IDictionary])) {
        try {
            $mType = $manifest.GetType().FullName
            throw "RESOLVER_ERROR: Manifest has invalid type '$mType' (expected hashtable/dictionary)."
        }
        catch {
            throw $_
        }
    }

    # debug/diagnóstico: sempre listar keys quando falhar
    if (-not $manifest.ContainsKey($LayerKey)) {
        $keys = @()
        try { $keys = @($manifest.Keys) } catch {}
        $keysPreview = if ($keys.Count -gt 50) { (($keys[0..49]) -join ',') + ',...' } else { ($keys -join ',') }
        throw "RESOLVER_ERROR: Layer '$LayerKey' does not exist in Manifest. ManifestKeys=[$keysPreview]"
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
    $requestedDomain = [string]$Domain
    $domainAliases = @{
        "Extensions" = @("Extensions", "Extended")
        "Extended"   = @("Extensions", "Extended")
        "Extension"  = @("Extensions", "Extended")
        "Network"    = @("Network", "Extensions", "Extended")
    }
    $domainCandidates = if ($domainAliases.ContainsKey($requestedDomain)) { $domainAliases[$requestedDomain] } else { @($requestedDomain) }

    foreach ($key in $reg.Segments.Keys) {
        if ($key -eq '__Meta__') { continue }
        $seg = $reg.Segments[$key]

        $layer = if ($seg -is [hashtable]) { $seg['Layer'] } elseif ($null -ne $seg.PSObject) { $seg.Layer } else { '' }
        $isLazy = if ($seg -is [hashtable]) { $seg['IsLazy'] } elseif ($null -ne $seg.PSObject) { $seg.IsLazy } else { $false }

        if (($domainCandidates | Where-Object { $_ -ieq $layer }).Count -gt 0 -and $isLazy -eq $true) {
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
                Publish-ScapeEvent -Type "LANG_FLUSHED" -Severity "TRACE" -Payload "Old language '$oldLang' removed from cache."
            }
        }

        Update-ScapeColdState -NewProperties @{ CurrentLanguage = $newLang } -Confirm:$false | Out-Null

        Publish-ScapeEvent -Type "MENU_LANGUAGE_SWITCH" -Severity "TRACE" -Payload @{
            Key    = "MENU_LANGUAGE_SWITCH"
            Tokens = @($newLang)
        }
        $currentMenu = Get-ScapeProperty -Object $state -PropertyName 'CurrentMenu'
        $redrawPayload = @{ Reason = "Language changed to $newLang" }
        if (-not [string]::IsNullOrWhiteSpace($currentMenu)) {
            $redrawPayload['MenuId'] = $currentMenu
            $redrawPayload['Type'] = "FULL"
        }
        Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "TRACE" -Payload $redrawPayload
    }

    # --- LISTENER 2: MENU_OPEN ---
    Register-ScapeEventListener -EventMatch "MENU_OPEN" -Action {
        param($EventFrame)
        $p = $EventFrame.Payload
        $menuId = if ($p -is [hashtable]) { $p['MenuId'] } elseif ($null -ne $p.PSObject) { $p.MenuId } else { '' }
        if ([string]::IsNullOrWhiteSpace($menuId)) { return }

        switch ($menuId) {
            'ThemeMenu' { Resolve-ScapeAsset -AssetId 'theme' -Category 'Constants' -Force:$false | Out-Null }
            'RobocopyMenu' { Resolve-ScapeAsset -AssetId 'storage' -Category 'Constants' -Force:$false | Out-Null }
        }
    }

    # --- LISTENER 3: UI_SELECTION ---
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
            Publish-ScapeEvent -Type "LAZY_WAKEUP" -Severity "TRACE" -Payload "Hydrated Domain: $wake"
        }

        $action = if ($p -is [hashtable]) { $p['Action'] } elseif ($null -ne $p.PSObject) { $p.Action } else { $null }

        $actionPayload = if ($p -is [hashtable]) {
            if ($p.ContainsKey('Payload')) { $p['Payload'] } else { $p['ActionPayload'] }
        }
        elseif ($null -ne $p.PSObject) {
            if ($p.PSObject.Properties['Payload']) { $p.Payload } elseif ($p.PSObject.Properties['ActionPayload']) { $p.ActionPayload } else { $null }
        }
        else { $null }

        if ($action -eq 'TRIGGER' -and $null -ne $actionPayload) {
            # Resolução flexível dependendo se é hashtable ou psobject
            $target = if ($actionPayload -is [hashtable]) { $actionPayload['Target'] } elseif ($null -ne $actionPayload.PSObject) { $actionPayload.Target } else { $null }

            if ($target) {
                Invoke-ScapeResolveModule -ModuleName $target | Out-Null
                Publish-ScapeEvent -Type "MODULE_WAKED" -Severity "TRACE" -Payload "Resolver hydrated target module: $target"
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
            $navData = Get-ScapeConstant -Path "navigation::$menuId" -Fallback @{}
            $navItems = if ($navData -is [hashtable] -and $navData.ContainsKey('Items')) { @($navData['Items']) }
            elseif ($null -ne $navData.PSObject -and $navData.PSObject.Properties['Items']) { @($navData.Items) }
            else { @() }

            $Layers = @($navItems | ForEach-Object {
                    $val = if ($_ -is [hashtable]) { $_['Layer'] } elseif ($null -ne $_.PSObject) { $_.Layer } else { $null }
                } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

            foreach ($domain in $Layers) {
                Invoke-ScapeWakeAssets -Domain $domain | Out-Null
            }

            Publish-ScapeEvent -Type "RESOLVER_REDRAW_SYNC" -Severity "TRACE" -Payload @{ Menu = $menuId; Domains = @($Layers) }
        }
    }
}

