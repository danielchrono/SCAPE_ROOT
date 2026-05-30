Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\Constants.psm1"
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\State.psm1"
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\I18N.psm1"
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Theme.psm1"
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Controller.psm1"

Initialize-ScapeConstants
Initialize-ScapeColdState
Initialize-ScapeI18N

$raw = @( @{ Id = 'Test'; TitleKey = 'MENU_MAIN_TARGET'; Type = 'ACTION' } )
$hydrated = Update-ScapeMenuViewModel -MenuId 'MainMenu' -RawOptions $raw
Write-Output "Hydrated count: $($hydrated.Count)"
if ($hydrated) {
    Write-Output "First item title: $($hydrated[0].Text)"
}
