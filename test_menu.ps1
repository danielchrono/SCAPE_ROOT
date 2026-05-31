. .\main.ps1 -SimulateUX
$menu = Get-ScapeMenuData -MenuId "MainMenu"
Write-Host "TitleKey is: $($menu.TitleKey)"
