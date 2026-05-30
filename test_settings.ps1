$ErrorActionPreference = 'Stop'

function Start-ScapeRouter {
    param($InitialMenu)
    Write-Output "Mock Router Reached."
    # Test Settings Random Theme
    $handler = Get-ScapeActionHandler -Target 'Scape.Presentation.Theme'
    if ($handler) {
        & $handler -Task 'PROCEDURAL' -PayloadDef $null -Target 'Scape.Presentation.Theme'
    }

    $path = Get-ScapeSettingsPath
    Write-Output "Settings Path: $path"
    if (Test-Path $path) {
        Write-Output "File exists!"
        Get-Content $path
    } else {
        Write-Output "File does NOT exist!"
    }

    Write-Output "--- Testing Hydration ---"
    Initialize-ScapeSetting -ForceReset:$false | Out-Null
    $state = Get-ScapeColdState
    Write-Output "RandomBaseHue hydrated: $($state.RandomBaseHue)"
}

# Run the normal deploy script which initializes everything
. .\deploy.ps1
