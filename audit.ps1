$enUsPath = "c:\Users\danie\SCAPE_ROOT\Data\I18N\en-US.psd1"
$ptBrPath = "c:\Users\danie\SCAPE_ROOT\Data\I18N\pt-BR.psd1"

$enUsText = Get-Content $enUsPath -Raw -Encoding UTF8
$ptBrText = Get-Content $ptBrPath -Raw -Encoding UTF8

$enUsHash = Invoke-Expression $enUsText
$ptBrHash = Invoke-Expression $ptBrText

function Get-AllKeys {
    param($hash, $prefix = "")
    $keys = @()
    if ($null -eq $hash) { return $keys }
    foreach ($key in $hash.Keys) {
        $fullKey = if ($prefix) { "$prefix.$key" } else { $key }
        if ($hash[$key] -is [System.Collections.Hashtable]) {
            $keys += Get-AllKeys -hash $hash[$key] -prefix $fullKey
        } else {
            $keys += $fullKey
        }
    }
    return $keys
}

$enKeys = Get-AllKeys $enUsHash
$ptKeys = Get-AllKeys $ptBrHash

Write-Output "### I18N Mismatched Keys"
if ($enKeys.Count -gt 0 -and $ptKeys.Count -gt 0) {
    $missingInPt = Compare-Object -ReferenceObject $enKeys -DifferenceObject $ptKeys | Where-Object {$_.SideIndicator -eq "<="} | Select-Object -ExpandProperty InputObject
    $missingInEn = Compare-Object -ReferenceObject $enKeys -DifferenceObject $ptKeys | Where-Object {$_.SideIndicator -eq "=>"} | Select-Object -ExpandProperty InputObject

    Write-Output "Missing in PT-BR:"
    if ($missingInPt) { $missingInPt } else { "None" }
    Write-Output "Missing in EN-US:"
    if ($missingInEn) { $missingInEn } else { "None" }
} else {
    Write-Output "Failed to parse keys"
}

Write-Output ""
Write-Output "### Broken ANSI Sequences in Constants"
$constantsFiles = @("ui.psd1", "system.psd1", "theme.psd1")
foreach ($f in $constantsFiles) {
    Write-Output "Checking $f..."
    $lines = Get-Content "c:\Users\danie\SCAPE_ROOT\Data\Constants\$f" -Encoding UTF8
    for ($i=0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # Regex to find `e[ something not ending with m, but wait: what if they use `e[0m to close it?
        # A valid ANSI escape sequence starts with `e[ or \e[ or \x1b[ and ends with m.
        # But actually in PowerShell it's usually ``e[
        # Let's just find anything like ``e[ and verify it ends with m somewhere in the same word
        # An easier way: Match all occurrences of ``e[.*?m. If there are occurrences of ``e[ that DO NOT have an m, flag it.
        $matches = [regex]::Matches($line, "``e\[[^m`"]*(`"|$)")
        foreach ($m in $matches) {
            if ($m.Value -notmatch "m") {
                Write-Output "$f line $($i+1): Broken ANSI (missing m): $($m.Value) in line: $line"
            }
        }
    }
}
