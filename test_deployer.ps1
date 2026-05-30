$ErrorActionPreference = 'Stop'

function Start-ScapeRouter {
    param($InitialMenu)
    Write-Output "Mock Router Reached."
    # Test Deployer
    $handler = Get-ScapeActionHandler -Target 'Scape.Forge.Deployer'
    if ($handler) {
        Write-Output "Calling Deployer Handler for INIT_AND_EXIT..."
        & $handler -Task 'INIT_AND_EXIT' -PayloadDef $null -Target 'Scape.Forge.Deployer'
    } else {
        Write-Output "Deployer handler not found."
    }
}

. .\deploy.ps1
