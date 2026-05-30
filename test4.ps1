Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\Constants.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\State.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\EventBus.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\AssetManager.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Core\I18N.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Theme.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Controller.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Geometry.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\TUI.psm1" -Global
Import-Module "C:\Users\danie\SCAPE_ROOT\Modules\Presentation\Renderer.psm1" -Global

Initialize-ScapeState
Initialize-ScapeTheme

$manifest = @{
    MainMenu = @{
        TitleKey = "MENU_MAIN_TITLE"
        Items = @(
            @{ Id = "SCAN"; TitleKey = "MENU_MAIN_SCAN"; Type = "Highlight"; Action = "TRIGGER"; Payload = @{} }
            @{ Id = "PARSING"; TitleKey = "MENU_MAIN_PARSING"; Type = "Normal"; Action = "TRIGGER"; Payload = @{} }
        )
    }
}
Update-ScapeColdState -NewProperties @{ Assets = @{ Manifests = @{ navigation = $manifest } } } -Confirm:$false

$hydrated = Update-ScapeMenuViewModel -MenuId 'MainMenu' -RawOptions $manifest.MainMenu.Items

Write-ScapeMenuBuffer -Options $hydrated -CursorIndex 0 -LastCursorIndex -1 -TitleKey "MENU_MAIN_TITLE" -FullRedraw $true
