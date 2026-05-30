@
$ctrlPath = "c:\Users\danie\SCAPE_ROOT\Modules\Presentation\Controller.psm1"
$rndPath = "c:\Users\danie\SCAPE_ROOT\Modules\Presentation\Renderer.psm1"

$ctrl = Get-Content $ctrlPath
$start = 240
$end = 354
$toMove = $ctrl[$start..$end]
$newCtrl = $ctrl[0..($start-1)] + $ctrl[($end+1)..($ctrl.Count-1)]

$newCtrl = $newCtrl -replace "'Format-ScapeGridLayout',\s*", "" -replace "'Format-ScapeThemifiedMenuBuffer'", "" -replace ",\s*$", ""
$newCtrl | Out-File $ctrlPath -Encoding UTF8

$rnd = Get-Content $rndPath
$expIndex = -1
for ($i=$rnd.Count-1; $i -ge 0; $i--) {
    if ($rnd[$i] -match "^Export-ModuleMember") { $expIndex = $i; break }
}

$newRnd = $rnd[0..($expIndex-1)] + $toMove

$exportLine = "Export-ModuleMember -Function 'Initialize-ScapeRenderer', 'Close-ScapeRenderer', 'Write-ScapeMenuBuffer', 'Write-ScapeTransientView', 'Write-ScapeTreeView', 'Write-ScapeActionScreen', 'Format-ScapeGridLayout', 'Format-ScapeThemifiedMenuBuffer'"

$newRnd += $exportLine
$newRnd | Out-File $rndPath -Encoding UTF8
@
