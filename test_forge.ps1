Import-Module .\Modules\Forge\Deployer.psm1; Invoke-ScapeDeployWorkflow -Target 'main' -Force; Import-Module .\Modules\Forge\Packager.psm1; Publish-ScapeMonolith
