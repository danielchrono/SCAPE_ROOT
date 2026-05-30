$ErrorActionPreference = 'SilentlyContinue'

$constantsPath = "c:\Users\danie\SCAPE_ROOT\Data\Constants"
$i18nPath = "c:\Users\danie\SCAPE_ROOT\Data\I18N"

function Get-HashByPath($hash, $path) {
    if (!$hash -or !$path) { return $null }
    $parts = $path -split '::'
    $curr = $hash
    foreach ($p in $parts) {
        if ($curr -is [System.Collections.Hashtable] -and $curr.ContainsKey($p)) {
            $curr = $curr[$p]
        } else {
            return $null
        }
    }
    return $curr
}

$files = Get-ChildItem "$constantsPath\*.psd1" | Select-Object -ExpandProperty Name
$Hashes = @{}
foreach ($f in $files) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($f)
    $Hashes[$name] = Invoke-Expression (Get-Content "$constantsPath\$f" -Raw -Encoding UTF8)
}

$keysToCheck = @(
    "ui::Defaults",
    "ui::ToggleLists",
    "ui::TerminalCapabilities",
    "theme::DynamicTheme::Fallback",
    "system::DEFAULTS::LANG",
    "ui::Layout::Margin",
    "system::DEFAULTS::MODE",
    "system::DEFAULTS::OUT_DIR",
    "system::system::RETRY_MAX_ATTEMPTS",
    "system::system::WATCHDOG_ACTION",
    "ui::CycleLists::RC_MT",
    "ui::CycleLists::EngineMode",
    "ui::CycleLists::ColorMode",
    "ui::CycleLists::I18N",
    "ui::CycleLists::ThemePersona",
    "ui::Layout",
    "ui::Input::PollMs",
    "ui::Input::PSCombos",
    "ui::Art::Variants",
    "ui::ANSI::Screen::ClearFull",
    "ui::Icons::Submenu",
    "ui::ANSI::Screen::ClearLineFull",
    "ui::Feedback::TransientActionHoldMs",
    "ui::Input::VirtualKeyMap",
    "theme::Fallback::ANSI16Map",
    "system::ActionManager::SilentTargets",
    "system::DomainAliases"
)

Write-Output "### Missing Configuration Check"
foreach ($k in $keysToCheck) {
    $root = ($k -split '::')[0]
    if ($Hashes.ContainsKey($root)) {
        $val = Get-HashByPath $Hashes[$root] ($k -replace "^$root::", "")
        if ($null -eq $val) {
            Write-Output "MISSING: $k"
        }
    } else {
        Write-Output "ROOT MISSING: $root"
    }
}
