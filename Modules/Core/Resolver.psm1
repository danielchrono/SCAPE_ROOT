<#
.SYNOPSIS
    Domain: Foundation
    Module: Scape.Core.Resolver
    Description: Orchestrates the system's JIT/Lazy-Loading logic.
                 Ensures recursive dependency resolution and atomic payload injection for Monolithic deploys.
#>

function Assert-ScapeCapability {
    param([Parameter(Mandatory = $true)][string]$CapabilityName)

    $state = Get-ScapeColdState
    if ($CapabilityName -notin $state["LoadedLayers"]) {
        Publish-ScapeEvent -Type "SYSTEM_FAULT" -Severity "LOG_FATAL" -Payload "Capability $CapabilityName is not present in the current runspace."
        throw "CAPABILITY_FAULT: $CapabilityName"
    }
    return $true
}

function Invoke-ScapeResolveModule {
    param([Parameter(Mandatory = $true)][string]$ModuleName)

    $state = Get-ScapeColdState
    if ($ModuleName -in $state["LoadedLayers"]) { return $true }

    # 1. Localizar Definição no Manifesto Global
    $modDef = $null
    foreach ($layerKey in (Get-ScapeManifest).Keys) {
        $found = (Get-ScapeManifest)[$layerKey] | Where-Object { $_.Name -eq $ModuleName }
        if ($found) { $modDef = $found; break }
    }

    if ($null -eq $modDef) {
        throw "RESOLVER_ERROR: Module definition for '$ModuleName' not found in Global Manifest."
    }

    # 2. Resolução de Dependências (Recursiva)
    if ($null -ne $modDef.DependsOn) {
        foreach ($dep in $modDef.DependsOn) {
            Invoke-ScapeResolveModule -ModuleName $dep | Out-Null
        }
    }

    # 3. Injeção de Payload (Atomic Injection na RAM)
    # Ex: 'Scape.IO.RawReader' vira 'Scape_IO_RawReaderPayload'
    $payloadVarName = "$($ModuleName -replace '\.', '_')Payload"
    $payloadVar = Get-Variable -Name $payloadVarName -ErrorAction SilentlyContinue

    if ($null -eq $payloadVar) {
        if ($modDef.IsVital) { throw "FATAL_INJECTION_FAILURE: Missing payload for vital module $ModuleName" }
        Publish-ScapeEvent -Type "MODULE_MISSING" -Severity "LOG_WARN" -Payload "Payload not found for non-vital module: $ModuleName"
        return $false
    }

    try {
        # Execução Pura em Memória
        . ([ScriptBlock]::Create($payloadVar.Value))

        # 4. Registro de Sucesso no ColdState Thread-Safe
        $currentLayers = $state["LoadedLayers"]
        $currentLayers.Add($ModuleName)

        Publish-ScapeEvent -Type "MODULE_LOADED" -Severity "LOG_INFO" -Payload "Module $ModuleName injected and functional."
        return $true
    }
    catch {
        Publish-ScapeEvent -Type "INJECTION_FAULT" -Severity "LOG_FATAL" -Payload @{ Module = $ModuleName; Error = $_.Exception.Message }
        throw "INJECTION_ERROR: Failed to ignite $ModuleName"
    }
}

function Resolve-ScapeManifestLayer {
    param([Parameter(Mandatory = $true)][string]$LayerKey)

    if (-not (Get-ScapeManifest).ContainsKey($LayerKey)) {
        throw "RESOLVER_ERROR: Layer '$LayerKey' does not exist in Manifest."
    }

    Publish-ScapeEvent -Type "LAYER_IGNITION" -Severity "LOG_INFO" -Payload "Igniting Layer: $LayerKey"

    # Ordena pelos LoadOrder definidos no nosso manifesto
    $sortedModules = (Get-ScapeManifest)[$LayerKey] | Sort-Object LoadOrder

    foreach ($module in $sortedModules) {
        # Na inicialização, forçamos o carregamento de todos os módulos da Layer
        # O lazy-load (JIT) será acionado pelos Triggers na UI depois, mas a Layer 0 inteira sobe aqui.
        Invoke-ScapeResolveModule -ModuleName $module.Name | Out-Null
    }
}

