<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.AssetManager
    Architecture: Zero-Recursion-Limit | Comment-Safe | Deterministic
#>
#Requires -Version 5.1

function Invoke-ScapeLoadAsset {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,

        [Parameter(Mandatory = $true)]
        [string]$AssetId,

        [Parameter(Mandatory = $false)]
        [string]$FilePath,

        [switch]$Silent
    )

    try {
        $state = Get-ScapeColdState
        if ($null -eq $state) { throw "STATE_UNINITIALIZED" }

        $rawData = $null
        $devMode = $state["DEV_MODE"] -eq $true

        # 1. RESOLUÇÃO DO CONTEÚDO
        if (-not $devMode) {
            $varName = "Asset_$($Category)_$($AssetId -replace '[\\\-]', '_')_Payload"
            $payload = Get-Variable -Name $varName -ValueOnly -ErrorAction SilentlyContinue
            if ($null -eq $payload) { throw "PAYLOAD_NOT_FOUND: $varName" }
        }
        else {
            if ([string]::IsNullOrWhiteSpace($FilePath) -or -not (Test-Path -LiteralPath $FilePath)) {
                throw "FILE_NOT_FOUND: $FilePath"
            }
            $payload = Get-Content -Path $FilePath -Raw -Encoding UTF8
            # Remove BOM se presente
            if ($payload.Length -gt 0 -and $payload[0] -eq [char]0xFEFF) {
                $payload = $payload.Substring(1)
            }
        }

        # Sanitização de comentários (segura para .psd1 estruturados)
        $clean = $payload -replace '(?m)(?<=^|\s)#.*?(?=\r?\n|$)', ''

        # 2. PARSE SEGURO (AST Only | IEX Removido)
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($clean, [ref]$null, [ref]$parseErrors)
        if ($parseErrors.Count -gt 0) {
            throw "AST_PARSE_FAILURE: $($parseErrors[0].Message)"
        }

        $hashtableAst = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.HashtableAst] }, $true) | Select-Object -First 1
        if ($null -eq $hashtableAst) {
            throw "NO_ROOT_HASHTABLE_IN_ASSET"
        }

        $rawData = $hashtableAst.SafeGetValue()

        if ($null -eq $rawData -or $rawData -isnot [System.Collections.IDictionary]) {
            throw "PARSE_RETURNED_NULL_OR_INVALID_TYPE"
        }

        # 3. INJEÇÃO NO COLDSTATE
        if (-not $state.Assets.ContainsKey($Category)) {
            $state.Assets.TryAdd($Category, [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()) | Out-Null
        }
        $state.Assets[$Category][$AssetId] = $rawData

        return $true

    }
    catch {
        if (-not $Silent) {
            Write-Output " 🔴 [ASSET FAULT] $Category\$AssetId : $($_.Exception.Message)" -ForegroundColor Red
        }
        return $false
    }
}

function Get-ScapeAsset {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,

        [string]$AssetId = $null
    )

    $state = Get-ScapeColdState
    # Removido check obsoleto 'SYS_ASSETS_DIR'. Foco direto na estrutura de Assets.
    if ($null -eq $state -or -not $state.ContainsKey("Assets") -or -not $state.Assets.ContainsKey($Category)) {
        return $null
    }

    if ([string]::IsNullOrWhiteSpace($AssetId)) {
        return $state.Assets[$Category]
    }

    return $state.Assets[$Category][$AssetId]
}