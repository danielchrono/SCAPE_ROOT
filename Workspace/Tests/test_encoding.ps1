$b = [System.IO.File]::ReadAllBytes("$PSScriptRoot\..\..\Modules\Presentation\Renderer.psm1")
Write-Host "BOM bytes: $($b[0]) $($b[1]) $($b[2])"
Write-Host "File size: $($b.Length)"
