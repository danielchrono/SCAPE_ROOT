$modulesDir = 'C:\Users\danie\SCAPE_ROOT\Modules'
Get-ChildItem -Path $modulesDir -Filter '*.psm1' -Recurse | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    
    # First pattern: array piped to ForEach-Object
    $newContent = $content -replace '(?s)\$Script:(?:LocalI18N|UnmappedI18N)\s*(?:\+?=)\s*@\([\s\S]*?\)\s*\|\s*ForEach-Object\s*\{\s*Get-ScapeI18NNode -Key \$_[\s\n\r]*\}', ''
    
    # Second pattern: standalone array (like in Logger.psm1 +=)
    $newContent = $newContent -replace '(?s)\$Script:(?:LocalI18N|UnmappedI18N)\s*(?:\+?=)\s*@\([\s\S]*?\)', ''
    
    if ($content -ne $newContent) {
        [System.IO.File]::WriteAllText($path, $newContent, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Purified: $($_.Name)"
    }
}
