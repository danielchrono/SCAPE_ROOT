Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\Constants.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\State.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\EventBus.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\AssetManager.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\I18N.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Theme.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Controller.psm1" -Global

Initialize-ScapeState
Initialize-ScapeTheme
Initialize-ScapeConstants

$manifest = @{
    MainMenu = @{
        TitleKey = "MENU_MAIN_TITLE"
        Items = @(
            @{ Id = "SCAN"; TitleKey = "MENU_MAIN_SCAN"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{} }
        )
    }
}
Update-ScapeColdState -NewProperties @{ Assets = @{ Manifests = @{ navigation = $manifest } } } -Confirm:$false

$hydrated = Update-ScapeMenuViewModel -MenuId 'MainMenu' -RawOptions $manifest.MainMenu.Items
Write-Output "Hydrated Count: $($hydrated.Count)"
Write-Output "Hydrated Object Type: $($hydrated.GetType().Name)"
Write-Output "First item text: $($hydrated[0].Text)"
