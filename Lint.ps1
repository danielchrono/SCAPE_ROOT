function Get-ScapeAssetAudit {
    Write-Host "[*] Iniciando Auditoria de Ativos (Modo Silencioso)..." -ForegroundColor Cyan
    $modules = Get-ChildItem -Path ".\Modules" -Recurse -Filter "*.psm1"
    $code = $modules | Get-Content
    $psdFiles = Get-ChildItem -Path ".\Data" -Recurse -Filter "*.psd1"

    $results = @()

    foreach ($file in $psdFiles) {
        # Importação silenciosa para não poluir o log
        $content = Import-PowerShellDataFile $file.FullName
        $keys = $content.Keys | Where-Object { $_ -notin @('Segment', '__Meta__') }

        foreach ($k in $keys) {
            $count = ($code | Select-String -Pattern $k -AllMatches).Matches.Count
            if ($count -eq 0) {
                Write-Host "[ÓRFÃO] '$k' em $($file.Name)" -ForegroundColor Yellow
            }
        }
    }

    # Busca por Hardcode (Strings literais em comandos de saída)
    Write-Host "[*] Analisando possíveis hardcodes em Write-Host/Console..." -ForegroundColor Cyan
    $code | Select-String -Pattern 'Write-Host\s+["'']([^$].*?)["'']', '\[Console\]::Write\(["'']([^$].*?)["'']\)' | ForEach-Object {
        Write-Host "[HARDCODE] No arquivo: $($_.Filename) -> $($_.Line.Trim())" -ForegroundColor Red
    }
}