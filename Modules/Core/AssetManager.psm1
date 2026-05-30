<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.AssetManager
    Architecture: Zero-Recursion-Limit | Comment-Safe | Deterministic | Indexer-Safe
#>
#Requires -Version 5.1

function Invoke-ScapeLoadAsset {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$AssetId,
        [Parameter(Mandatory = $false)][string]$FilePath,
        [switch]$Silent
    )
    try {
        $state = Get-ScapeColdState
        if ($null -eq $state) { throw "STATE_UNINITIALIZED" }
        
        if (-not $state.ContainsKey("Assets")) { 
            $assetsContainer = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
            Update-ScapeColdState -NewProperties @{ Assets = $assetsContainer } | Out-Null
        }
        
        $assets = $state["Assets"]
        if (-not $assets.ContainsKey($Category)) { 
            $assets[$Category] = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
        }
        
        if ($assets[$Category].ContainsKey($AssetId)) { return $true }
        
        $rawData = $null
        $devMode = $state["DEV_MODE"] -eq $true
        if (-not $devMode) {
            $safeName = $FilePath -replace '^.*?[Dd]ata[/\\]', '' -replace '^[Dd]ata[/\\]', '' -replace '[/\\]', '_'
            $memKey = "Asset_$safeName"
            if (-not $Global:SCAPE_MEM.ContainsKey($memKey)) { throw "PAYLOAD_NOT_FOUND_IN_RAM: $memKey" }
            $rawData = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM[$memKey]))
        }
        else {
            if (-not (Test-Path -LiteralPath $FilePath)) { throw "FILE_NOT_FOUND: $FilePath" }
            $payload = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), ' '))
            $rawData = Invoke-Command -ScriptBlock ([scriptblock]::Create($payload))
        }
        if ($null -eq $rawData) { throw "PARSE_FAILED" }
        
        $assets[$Category][$AssetId] = $rawData
        
        if (-not $Silent) { Publish-ScapeEvent -Type "ASSET_LOADED" -Severity "INFO" -Payload "$Category/$AssetId" }
        return $true
    }
    catch {
        if (-not $Silent) { Publish-ScapeEvent -Type "ASSET_FAULT" -Severity "ERROR" -Payload "$Category\$AssetId - $($_.Exception.Message)" }
        return $false
    }
}

function Get-ScapeAsset {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)][string]$Category,
        [string]$AssetId = $null
    )
    $state = Get-ScapeColdState
    if ($null -eq $state -or -not $state.ContainsKey("Assets")) { return $null }

    # Busca Case-Insensitive manual para evitar quebras em transições de RAM
    $catKey = $state["Assets"].Keys | Where-Object { $_ -ieq $Category } | Select-Object -First 1
    if (-not $catKey) { return $null }

    $catAssets = $state["Assets"][$catKey]
    if ([string]::IsNullOrWhiteSpace($AssetId)) { return $catAssets }

    $assetKey = $catAssets.Keys | Where-Object { $_ -ieq $AssetId } | Select-Object -First 1
    if ($assetKey) { return $catAssets[$assetKey] }

    return $null
}

function Remove-ScapeAsset {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$AssetId
    )

    $state = Get-ScapeColdState
    if ($state.ContainsKey("Assets") -and $state["Assets"].ContainsKey($Category)) {
        $removed = $state["Assets"][$Category].TryRemove($AssetId, [ref]$null)
        if ($removed) {
            Publish-ScapeEvent -Type "ASSET_REMOVED" -Severity "TRACE" -Payload "$Category/$AssetId"
            return $true
        }
    }
    return $false
}

function Invoke-ScapeLazyLoadAsset {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$AssetId,
        [string]$Category = $null
    )

    $st = Get-ScapeColdState
    if ($null -eq $st) { return $false }

    $resolveByRegistry = {
        param([string]$Id, [string]$HintCategory)
        if (-not $st.ContainsKey("Registry")) { return $false }
        $segments = $st["Registry"].Segments
        if ($null -eq $segments) { return $false }

        $segKey = $segments.Keys | Where-Object { $_ -ieq $Id } | Select-Object -First 1
        if ([string]::IsNullOrWhiteSpace($segKey)) { return $false }

        $seg = $segments[$segKey]
        $cat = if (-not [string]::IsNullOrWhiteSpace($HintCategory)) { $HintCategory } elseif ($seg -is [hashtable]) { $seg['Category'] } elseif ($null -ne $seg.PSObject) { $seg.Category } else { $null }
        $file = if ($seg -is [hashtable]) { $seg['File'] } elseif ($null -ne $seg.PSObject) { $seg.File } else { $null }
        if ([string]::IsNullOrWhiteSpace($cat) -or [string]::IsNullOrWhiteSpace($file)) { return $false }

        $root = if ($st.ContainsKey("ROOT")) { [string]$st["ROOT"] } else { $null }
        if ([string]::IsNullOrWhiteSpace($root)) { return $false }
        $filePath = Join-ScapePath -Base $root -Child $file
        if (-not (Test-Path -LiteralPath $filePath)) { return $false }

        return (Invoke-ScapeLoadAsset -Category $cat -AssetId $segKey -FilePath $filePath -Silent)
    }

    if ($st.ContainsKey("Lazy") -and $st["Lazy"] -and $st["Lazy"].ContainsKey("Registry")) {
        $lazyMap = $st["Lazy"]["Registry"]
        if ($lazyMap.ContainsKey($AssetId)) {
            $entry = $lazyMap[$AssetId]
            if ($entry["Loaded"] -eq $true) { return $true }

            $content = $entry["Content"]
            $category = if ($Category) { $Category } else { $entry["Category"] }
            if ([string]::IsNullOrWhiteSpace($category)) { return $false }

            $null = Invoke-Command -ScriptBlock ([scriptblock]::Create($content))
            $result = Invoke-ScapeLoadAsset -Category $category -AssetId $AssetId -Silent
            if ($result) {
                $entry["Loaded"] = $true
                Publish-ScapeEvent -Type "LAZY_ASSET_HYDRATED" -Severity "INFO" -Payload "$category/$AssetId"
                return $true
            }
            return $false
        }
    }

    return (& $resolveByRegistry $AssetId $Category)
}