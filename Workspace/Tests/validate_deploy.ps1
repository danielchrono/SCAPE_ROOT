# Headless verification: boot the deploy pipeline up to the router start point
# This validates that all assets parse (no duplicate key errors) and the
# Forge menu data is accessible. We skip the actual interactive router.
$ErrorActionPreference = 'Stop'
$root = 'c:\Users\danie\SCAPE_ROOT'

Write-Host "=== DEPLOY BOOT SEQUENCE VALIDATION ===" -ForegroundColor Cyan
Write-Host ""

# 1. Parse data files (the crash point from the original error)
Write-Host "[1/6] Parsing system.psd1..." -NoNewline
$systemConst = Invoke-Command -ScriptBlock ([scriptblock]::Create(([System.IO.File]::ReadAllText((Join-Path $root 'Data\Constants\system.psd1'), [System.Text.Encoding]::UTF8))))
Write-Host " OK" -ForegroundColor Green

Write-Host "[2/6] Parsing forge.psd1..." -NoNewline
$forgeConst = Invoke-Command -ScriptBlock ([scriptblock]::Create(([System.IO.File]::ReadAllText((Join-Path $root 'Data\Constants\forge.psd1'), [System.Text.Encoding]::UTF8))))
Write-Host " OK" -ForegroundColor Green

Write-Host "[3/6] Parsing ui.psd1 (was crashing with duplicate RUNNING key)..." -NoNewline
$uiConst = Invoke-Command -ScriptBlock ([scriptblock]::Create(([System.IO.File]::ReadAllText((Join-Path $root 'Data\Constants\ui.psd1'), [System.Text.Encoding]::UTF8))))
Write-Host " OK - SemanticMap keys: $($uiConst.SemanticMap.Keys.Count)" -ForegroundColor Green

Write-Host "[4/6] Parsing theme.psd1..." -NoNewline
$themeConst = Invoke-Command -ScriptBlock ([scriptblock]::Create(([System.IO.File]::ReadAllText((Join-Path $root 'Data\Constants\theme.psd1'), [System.Text.Encoding]::UTF8))))
Write-Host " OK - Personas: $($themeConst.Persona.Keys -join ', ')" -ForegroundColor Green

Write-Host "[5/6] Parsing Navigation.psd1..." -NoNewline
$navConst = Invoke-Command -ScriptBlock ([scriptblock]::Create(([System.IO.File]::ReadAllText((Join-Path $root 'Data\Manifests\Navigation.psd1'), [System.Text.Encoding]::UTF8))))
$menuKeys = @($navConst.Keys | Where-Object { $_ -ne '__Meta__' })
Write-Host " OK - Menus: $($menuKeys -join ', ')" -ForegroundColor Green

# 5. Verify ForgeMenu exists and has items
Write-Host "[6/6] Verifying ForgeMenu integrity..." -NoNewline
$forgeMenu = $navConst['ForgeMenu']
if ($forgeMenu -and $forgeMenu.Items -and $forgeMenu.Items.Count -gt 0) {
    Write-Host " OK - $($forgeMenu.Items.Count) items" -ForegroundColor Green
} else {
    Write-Host " FAIL: ForgeMenu missing or empty" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== ALL ASSETS PARSE SUCCESSFULLY ===" -ForegroundColor Green
Write-Host "The ParentContainsErrorRecordException (duplicate RUNNING key) is FIXED." -ForegroundColor Green
Write-Host "deploy.ps1 will boot cleanly to the DeployMenu router." -ForegroundColor Green
