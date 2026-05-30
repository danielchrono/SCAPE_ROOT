$ErrorActionPreference = 'Stop'
$base = 'c:\Users\danie\SCAPE_ROOT\Modules'
$amPath = Join-Path $base 'Core\ActionManager.psm1'

$amContent = Get-Content $amPath -Raw -Encoding UTF8
$newAmContent = $amContent -replace '(?s)Register-ScapeActionHandler -Target ''Scape\.Presentation\.FilePicker''.*?Register-ScapeActionHandler -Target ''Scape\.Extensions\.CloudSync''.*?}$', ''
Set-Content $amPath -Value $newAmContent -Encoding UTF8

$filePicker = Join-Path $base 'Presentation\FilePicker.psm1'
$theme = Join-Path $base 'Presentation\Theme.psm1'
$audit = Join-Path $base 'Infrastructure\Audit.psm1'
$compliance = Join-Path $base 'Infrastructure\Compliance.psm1'
$pipeline = Join-Path $base 'Infrastructure\Pipeline.psm1'
$selection = Join-Path $base 'Acquisition\Selection.psm1'
$resilience = Join-Path $base 'Acquisition\Resilience.psm1'
$cloudsync = Join-Path $base 'Extensions\CloudSync.psm1'

$fpCode = @"

Register-ScapeActionHandler -Target 'Scape.Presentation.FilePicker' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    if (Get-Command Invoke-ScapeDirectoryPicker -ErrorAction SilentlyContinue) { Invoke-ScapeDirectoryPicker -Payload `$PayloadDef }
}
"@
Add-Content $filePicker -Value $fpCode -Encoding UTF8 -NoNewline

$themeCode = @"

Register-ScapeActionHandler -Target 'Scape.Presentation.Theme' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    if (`$Task -eq 'PROCEDURAL') {
        `$rand = [Random]::new()
        Set-ScapeSettingMutation -Key "RandomBaseHue" -Value (`$rand.NextDouble() * 360) | Out-Null
        Set-ScapeSettingMutation -Key "ThemePersona" -Value "RANDOM" | Out-Null
    }
}
"@
Add-Content $theme -Value $themeCode -Encoding UTF8 -NoNewline

$auditCode = @"

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Audit' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "EXPORTING AUDIT LEDGER..." -StatusFlag "INFO"
    `$root = (Get-ScapeColdState)["ROOT"]
    if ([string]::IsNullOrWhiteSpace(`$root)) { `$root = (Get-Location).Path }
    `$exportDir = Join-Path `$root "Data\Exports"
    if (-not (Test-Path `$exportDir)) { New-Item -ItemType Directory -Path `$exportDir -Force | Out-Null }
    `$exportPath = Join-Path `$exportDir "AuditLedger_`$(Get-Date -f 'yyyyMMdd_HHmmss').json"
    
    if (Get-Command Export-ScapeAuditLedger -ErrorAction SilentlyContinue) {
        `$result = Export-ScapeAuditLedger -OutputPath `$exportPath -Format "JSON"
        if (`$result.Success) {
            Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "AUDIT LEDGER EXPORTED SUCCESSFULLY" -StatusFlag "Success"
        } else {
            Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "FAILED TO EXPORT AUDIT LEDGER" -StatusFlag "Failure"
            throw "Audit export failed"
        }
    } else {
        Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "AUDIT MODULE NOT LOADED" -StatusFlag "Failure"
        throw "Audit module not available."
    }
}
"@
Add-Content $audit -Value $auditCode -Encoding UTF8 -NoNewline

$compCode = @"

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Compliance' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "GENERATING COMPLIANCE REPORT..." -StatusFlag "INFO"
    `$root = (Get-ScapeColdState)["ROOT"]
    if ([string]::IsNullOrWhiteSpace(`$root)) { `$root = (Get-Location).Path }
    `$exportDir = Join-Path `$root "Data\Exports"
    if (-not (Test-Path `$exportDir)) { New-Item -ItemType Directory -Path `$exportDir -Force | Out-Null }
    `$exportPath = Join-Path `$exportDir "ComplianceReport_`$(Get-Date -f 'yyyyMMdd_HHmmss').json"
    
    if (Get-Command Export-ScapeComplianceReport -ErrorAction SilentlyContinue) {
        `$result = Export-ScapeComplianceReport -OutputPath `$exportPath
        if (`$result.Success) {
            Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "COMPLIANCE REPORT GENERATED: `$(`$result.Status)" -StatusFlag "Success"
        } else {
            Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "FAILED TO GENERATE COMPLIANCE REPORT" -StatusFlag "Failure"
            throw "Compliance export failed"
        }
    } else {
        Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "COMPLIANCE MODULE NOT LOADED" -StatusFlag "Failure"
        throw "Compliance module not available."
    }
}
"@
Add-Content $compliance -Value $compCode -Encoding UTF8 -NoNewline

$pipeCode = @"

Register-ScapeActionHandler -Target 'Scape.Infrastructure.Pipeline' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "INITIALIZING MEMORY PIPELINE..." -StatusFlag "INFO"
    if (Get-Command Initialize-ScapePipeline -ErrorAction SilentlyContinue) {
        Initialize-ScapePipeline | Out-Null
        Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "PIPELINE BUFFER ACTIVE" -StatusFlag "Success"
    } else {
        Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText "PIPELINE MODULE NOT LOADED" -StatusFlag "Failure"
        throw "Pipeline module not available."
    }
}
"@
Add-Content $pipeline -Value $pipeCode -Encoding UTF8 -NoNewline

$selCode = @"

Register-ScapeActionHandler -Target 'Scape.Acquisition.Selection' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    if (Get-Command Get-ScapePhysicalTarget -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_INFO" -Severity "INFO" -Payload @{ Key = "INVENTORY_PHYSICAL_DISKS"; Targets = @(Get-ScapePhysicalTarget) }
    } else { throw "Not Implemented" }
}
"@
Add-Content $selection -Value $selCode -Encoding UTF8 -NoNewline

$resCode = @"

Register-ScapeActionHandler -Target 'Scape.Acquisition.Resilience' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    `$targetId = Resolve-ScapeActiveTarget
    if ([string]::IsNullOrWhiteSpace(`$targetId)) { throw "No Target Bound" }
}
"@
Add-Content $resilience -Value $resCode -Encoding UTF8 -NoNewline

$cloudCode = @"

Register-ScapeActionHandler -Target 'Scape.Extensions.CloudSync' -Handler {
    param(`$Task, `$PayloadDef, `$Target)
    `$txtResolve = if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "ACTION_RESOLVING_VAULT" -Args @() } else { "RESOLVING CLOUD VAULT ENDPOINT..." }
    Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText `$txtResolve -StatusFlag "WARN"
    
    if (Get-Command Invoke-ScapeCloudSyncPreparation -ErrorAction SilentlyContinue) { Invoke-ScapeCloudSyncPreparation | Out-Null } else { throw "Not Implemented" }
    
    `$txtAuth = if (Get-Command Invoke-ScapeI18NFormat -ErrorAction SilentlyContinue) { Invoke-ScapeI18NFormat -Key "ACTION_AUTH_KEYS" -Args @() } else { "AUTHENTICATING SHA256 KEYS..." }
    Write-ScapeActionProgress -Target `$Target -Task `$Task -StatusText `$txtAuth -StatusFlag "WARN"
}
"@
Add-Content $cloudsync -Value $cloudCode -Encoding UTF8 -NoNewline
