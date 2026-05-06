<#
.SYNOPSIS
    Auditoria de hardcoded (strings literais) e entradas não utilizadas nos assets i18n e constants.
#>
[CmdletBinding()]
param(
    [string]$ModulesPath = ".\Modules",
    [string]$DataPath = ".\Data",
    [string]$OutputReport = ".\AuditReport.json"
)

# 1. Coletar todas as strings literais nos arquivos .psm1 / .ps1
$stringsHardcoded = [System.Collections.Generic.List[PSCustomObject]]::new()
$psFiles = Get-ChildItem -Path $ModulesPath -Recurse -Include "*.psm1","*.ps1" -File
foreach ($file in $psFiles) {
    $lines = Get-Content $file.FullName -Encoding UTF8
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # Procura por strings entre aspas duplas ou simples (simples, sem escapar)
        if ($line -match '"(?<content>(?:[^"\\]|\\.)*)"' -or $line -match "'(?<content>(?:[^'\\]|\\.)*)'") {
            $content = $matches['content']
            # Ignora comentários e chamadas de funções i18n
            if ($line -notmatch '^\s*#' -and $content -notmatch '^\s*$' -and $line -notmatch 'Get-ScapeLogMsg|I18N|Get-ScapeLocalizedString') {
                $stringsHardcoded.Add([PSCustomObject]@{
                    File = $file.FullName
                    LineNumber = $i+1
                    Text = $content
                    Context = $line.Trim()
                })
            }
        }
    }
}

# 2. Coletar todas as chaves i18n usadas nos módulos
$usedI18nKeys = [System.Collections.Generic.HashSet[string]]::new()
foreach ($file in $psFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    # Captura argumentos de Get-ScapeLogMsg e I18N (alias)
    $matchesI18n = [regex]::Matches($content, '(?:Get-ScapeLogMsg|I18N)\s+-Key\s+"([^"]+)"')
    foreach ($m in $matchesI18n) { $usedI18nKeys.Add($m.Groups[1].Value) }
}

# 3. Coletar todas as chaves i18n disponíveis nos assets
$i18nAssets = Get-ChildItem -Path $DataPath -Recurse -Include "*.psd1" -File | Where-Object { $_.FullName -match '\\I18N\\' }
$availableI18nKeys = [System.Collections.Generic.HashSet[string]]::new()
foreach ($asset in $i18nAssets) {
    $data = Import-PowerShellDataFile $asset.FullName
    foreach ($key in $data.Keys) { $availableI18nKeys.Add($key) }
}

$unusedI18n = $availableI18nKeys | Where-Object { -not $usedI18nKeys.Contains($_) }

# 4. Relatório
$report = [PSCustomObject]@{
    HardcodedStrings = $stringsHardcoded
    UsedI18nKeys = $usedI18nKeys | Sort-Object
    UnusedI18nKeys = $unusedI18n | Sort-Object
    TotalHardcoded = $stringsHardcoded.Count
    TotalI18nKeysUsed = $usedI18nKeys.Count
    TotalI18nKeysAvailable = $availableI18nKeys.Count
}

$json = $report | ConvertTo-Json -Depth 10
Set-Content -Path $OutputReport -Value $json -Encoding UTF8

Write-Host "Auditoria concluída. Relatório em $OutputReport"
Write-Host "Hardcoded encontrados: $($report.TotalHardcoded)"
Write-Host "Chaves i18n não utilizadas: $($report.UnusedI18nKeys.Count)"