<#
.SYNOPSIS
    Domain: Core | Module: Scape.Core.I18N
    Architecture: Strictly Functional | Bucket-Aware Resolution | Encapsulated Decoupling
#>
[CmdletBinding()] param()

function _GetRawI18NEntry {
    [CmdletBinding()] [OutputType([object])]
    param([Parameter(Mandatory=$true)][string]$Key)

    try {
        $state = Get-ScapeColdState
        if ($null -eq $state -or $null -eq $state.Assets -or -not $state.Assets.ContainsKey("I18N")) { return $null }

        $lang = if ($state.ContainsKey("CurrentLanguage")) {
            $state["CurrentLanguage"]
        } else { "en-US" }

        $i18nBucket = $state.Assets["I18N"]
        if (-not $i18nBucket.ContainsKey($lang)) {
            if (Get-Command Resolve-ScapeAsset -ErrorAction SilentlyContinue) {
                Resolve-ScapeAsset -AssetId $lang -Category "I18N" | Out-Null
            }
            elseif (Get-Command Invoke-ScapeLazyLoadAsset -ErrorAction SilentlyContinue) {
                Invoke-ScapeLazyLoadAsset -AssetId $lang -Category "I18N" | Out-Null
            }
            $state = Get-ScapeColdState
            if ($null -eq $state -or $null -eq $state.Assets -or -not $state.Assets.ContainsKey("I18N")) { return $null }
            $i18nBucket = $state.Assets["I18N"]
            if (-not $i18nBucket.ContainsKey($lang)) { return $null }
        }
        $langDict = $i18nBucket[$lang]

        if ($langDict -is [System.Collections.IDictionary]) {
            if ($langDict.Contains($Key)) { return $langDict[$Key] }
            $foundKey = $langDict.Keys | Where-Object { $_ -eq $Key } | Select-Object -First 1
            if ($foundKey) { return $langDict[$foundKey] }
        } elseif ($langDict.PSObject.Properties[$Key]) {
            return $langDict.$($Key)
        } else {
            $prop = $langDict.PSObject.Properties | Where-Object { $_.Name -eq $Key } | Select-Object -First 1
            if ($prop) { return $prop.Value }
        }
    } catch {
        throw "I18N_ERROR: Failed to resolve key '$Key' -> $($_.Exception.Message)"
    }
    throw "I18N_MISSING_KEY: Translation key '$Key' not found in dictionary."
}

function Get-ScapeI18NNode {
    [CmdletBinding()] [OutputType([psobject])]
    param([Parameter(Mandatory=$true)][string]$Key)

    $entry = _GetRawI18NEntry -Key $Key
    $Node = [PSCustomObject]@{ Text = $Key; Hint = ""; Flag = "UI" }

    if ($null -eq $entry) { return $Node }

    if ($entry -is [System.Collections.IDictionary]) {
        if ($entry.Contains('T')) { $Node.Text = $entry['T'] } elseif ($entry.PSObject.Properties['T']) { $Node.Text = $entry.T }
        if ($entry.Contains('H')) { $Node.Hint = $entry['H'] } elseif ($entry.PSObject.Properties['H']) { $Node.Hint = $entry.H }
        if ($entry.Contains('F')) { $Node.Flag = $entry['F'] } elseif ($entry.PSObject.Properties['F']) { $Node.Flag = $entry.F }
    }
    elseif ($entry.PSObject.Properties['T']) {
        $Node.Text = $entry.T
        if ($entry.PSObject.Properties['H']) { $Node.Hint = $entry.H }
        if ($entry.PSObject.Properties['F']) { $Node.Flag = $entry.F }
    }
    else {
        $Node.Text = [string]$entry
    }
    return $Node
}

function Get-ScapeLogMsg {
    [CmdletBinding()] [OutputType([string])]
    param(
        [Parameter(Mandatory=$true)][string]$Key,
        [Parameter(Mandatory=$false)][array]$MsgArgs = @()
    )

    $Node = Get-ScapeI18NNode -Key $Key
    $rawText = $Node.Text

    if ($null -ne $MsgArgs -and $MsgArgs.Count -gt 0) {
        try { return $rawText -f ([object[]]$MsgArgs) } catch { return $rawText }
    }
    return $rawText
}

function Format-ScapeMenuLine {
    [CmdletBinding()] [OutputType([string])]
    param(
        [Parameter(Mandatory=$true)][string]$Key,
        [Parameter(Mandatory=$false)][array]$MsgArgs = @()
    )
    $text = Get-ScapeLogMsg -Key $Key -MsgArgs $MsgArgs
    $node = Get-ScapeI18NNode -Key $Key

    if ($node.Flag -ne "UI" -and $node.Flag -ne "" -and $null -ne $node.Flag) {
        return "[$($node.Flag)] $text"
    }
    return $text
}

if (-not (Get-Alias -Name "I18N" -ErrorAction SilentlyContinue)) {
    Set-Alias -Name "I18N" -Value "Get-ScapeLogMsg" -Scope Global -Force
}