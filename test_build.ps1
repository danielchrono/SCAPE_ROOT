$ErrorActionPreference = 'Stop'

function Start-ScapeRouter {
    param($InitialMenu)
    Write-Output "Mock Router Reached."
    # Test Monolith Build
    $handler = Get-ScapeActionHandler -Target 'Scape.Forge.Deployer'
    if ($handler) {
        Write-Output "Calling Deployer Handler for BUILD_AND_LAUNCH_MONOLITH..."
        try {
            & $handler -Task 'BUILD_AND_LAUNCH_MONOLITH' -PayloadDef $null -Target 'Scape.Forge.Deployer'
        } catch {
            Write-Output "Error: $($_.Exception.Message)"
        }
    } else {
        Write-Output "Deployer handler not found."
    }
}

. .\deploy.ps1
