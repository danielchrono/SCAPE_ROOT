$appRoot = "C:\Users\danie\SCAPE_ROOT"
$mainContent = Get-Content -Path "$appRoot\main.ps1" -Raw

# Replace the specific lines inside try block
$mainContent = $mainContent -replace '(?s)try \{.*?catch \{', @"
try {
    # Queue 100 virtual events
    for (`$i=0; `$i -lt 100; `$i++) {
        Send-ScapeVirtualInput -Key 'DOWN'
    }
    Send-ScapeVirtualInput -Key 'EXIT'

    Write-Host ">>> STARTING STRESS TEST <<<"
    `$sw = [System.Diagnostics.Stopwatch]::StartNew()
    Start-ScapeRouter -InitialMenu 'MainMenu'
    `$sw.Stop()
    Write-Host ">>> STRESS TEST COMPLETE <<<"
    Write-Host "Total Time for 100 Actions: `$(`$sw.ElapsedMilliseconds) ms"
    Write-Host "Average Latency per Action: `$([math]::Round(`$sw.ElapsedMilliseconds / 100, 2)) ms"
    if (`$sw.ElapsedMilliseconds -gt 2000) {
        Write-Host "[!] SEVERE LAG DETECTED!" -ForegroundColor Red
    } else {
        Write-Host "[+] LATENCY IS OPTIMAL!" -ForegroundColor Green
    }
}
catch {
"@

Set-Content -Path "$appRoot\run_stress.ps1" -Value $mainContent -Encoding UTF8
powershell -NoProfile -ExecutionPolicy Bypass -File "$appRoot\run_stress.ps1"
