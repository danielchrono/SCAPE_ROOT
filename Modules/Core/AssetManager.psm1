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

        # Injeção thread-safe garantida com Case-Insensitive
        if (-not $state.ContainsKey("Assets")) {
            $state["Assets"] = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
        }
        if (-not $state["Assets"].ContainsKey($Category)) {
            $state["Assets"][$Category] = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
        }

        if ($state["Assets"][$Category].ContainsKey($AssetId)) { return $true }

        $rawData = $null
        $devMode = $state["DEV_MODE"] -eq $true

        if (-not $devMode) {
            $safeName = $FilePath -replace '^[Dd]ata[/\\]', '' -replace '[/\\]', '_'
            $memKey = "Asset_$safeName"
            if (-not $Global:SCAPE_MEM.ContainsKey($memKey)) { throw "PAYLOAD_NOT_FOUND_IN_RAM: $memKey" }
            $rawData = Invoke-Command -ScriptBlock ([scriptblock]::Create($Global:SCAPE_MEM[$memKey]))
        }
        else {
            if (-not (Test-Path -LiteralPath $FilePath)) { throw "FILE_NOT_FOUND: $FilePath" }
            $payload = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8).Trim((([char]0xFEFF), ' '))
            $rawData = Invoke-Command -ScriptBlock ([scriptblock]::Create($payload))
        }

        if ($null -eq $rawData -or $rawData -isnot [System.Collections.IDictionary]) { throw "PARSE_INVALID_TYPE" }

        $state["Assets"][$Category][$AssetId] = $rawData
        Publish-ScapeEvent -Type "ASSET_LOADED" -Severity "INFO" -Payload "$Category/$AssetId"
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
            Publish-ScapeEvent -Type "ASSET_REMOVED" -Severity "DEBUG" -Payload "$Category/$AssetId"
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
    if ($null -eq $st -or -not $st.ContainsKey("Lazy") -or -not $st["Lazy"].ContainsKey("Registry")) {
        return $false
    }

    $lazyMap = $st["Lazy"]["Registry"]
    if (-not $lazyMap.ContainsKey($AssetId)) {
        if (-not $Category) { return $false }
        return Invoke-ScapeLoadAsset -Category $Category -AssetId $AssetId -Silent
    }

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
