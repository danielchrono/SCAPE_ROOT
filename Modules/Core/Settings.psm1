<#
.SYNOPSIS
    Domain: Foundation | Module: Scape.Core.Settings
    Architecture: Dynamic State Mutator | JSON Portable Persistence | SSOT Compliant
    FIX: Unified version with JSON stream trimming, depth safety, UTF8NoBOM, and zero hardcoded messages.
    CRITICAL: $global:BootRoot REMOVED → Uses Get-ScapeColdState["ROOT"] for lazy resolution.
#>

# Caminho resolvido de forma lazy via estado hidratado (não via global)
$Script:SettingsPath = $null

function Get-ScapeSettingsPath {
    [CmdletBinding()] [OutputType([string])]
    param()
    if ($null -eq $Script:SettingsPath) {
        $state = Get-ScapeColdState
        $wsRoot = $state["WORKSPACE_ROOT"]
        if ($null -eq $wsRoot) { throw "WORKSPACE_ROOT not initialized" }
        $settingsDirName = Get-ScapeConstant -Path "system::Directories::SETTINGS" -Fallback "Config"
        $settingsFileName = Get-ScapeConstant -Path "system::Defaults::SETTINGS" -Fallback "user-settings.json"
        $Script:SettingsPath = Join-Path -Path $wsRoot -ChildPath "$settingsDirName\$settingsFileName"
    }
    return $Script:SettingsPath
}

function Get-ScapeSettingDefault {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()
    process {
        $uiDefaults = Get-ScapeConstant -Path "ui::Defaults"
        $uiToggleLists = Get-ScapeConstant -Path "ui::ToggleLists"
        $termCaps = Get-ScapeConstant -Path "ui::TerminalCapabilities"
        $defaultPersona = if ($uiDefaults.ThemeProfile) { $uiDefaults.ThemeProfile } else { "PowerShell" }
        return [ordered]@{
            # Configurações não-UI
            Theme                      = Get-ScapeConstant -Path "theme::DynamicTheme::Fallback"
            CurrentLanguage            = Get-ScapeConstant -Path "system::DEFAULTS::LANG"
            UiMargin                   = Get-ScapeConstant -Path "ui::Layout::Margin"
            EngineMode                 = Get-ScapeConstant -Path "system::DEFAULTS::MODE"
            OutPath                    = Get-ScapeConstant -Path "system::DEFAULTS::OUT_DIR"
            LogLevel                   = Get-ScapeConstant -Path "infrastructure::Logger::DEFAULT_LEVEL_NAME"
            MaxRetries                 = Get-ScapeConstant -Path "system::Behavior::RETRY_MAX_ATTEMPTS"
            WatchdogAction             = Get-ScapeConstant -Path "system::Behavior::WATCHDOG_ACTION"
            SmbTimeoutMs               = Get-ScapeConstant -Path "network::PROTOCOLS::TIMEOUT_MS"
            IoChunkSize                = Get-ScapeConstant -Path "storage::BUFFER::CHUNK_READ"
            RobocopyThreads            = Get-ScapeConstant -Path "system::LIMITS::ROBOCOPY_THREAD_AUTO"
            # Configurações de UI
            IconLevel                  = $uiDefaults.IconLevel
            FrameStyle                 = $uiDefaults.FrameStyle
            ProgressStyle              = $uiDefaults.ProgressStyle
            ThemePersona               = $defaultPersona
            RandomBaseHue              = $null
            ColorMode                  = $uiDefaults.ColorMode
            # Toggles do Robocopy
            RC_E                       = $uiToggleLists.RC_E.Value
            RC_ZB                      = $uiToggleLists.RC_ZB.Value
            RC_M                       = $uiToggleLists.RC_M.Value
            RC_B                       = $uiToggleLists.RC_B.Value
            RC_COPYALL                 = $uiToggleLists.RC_COPYALL.Value
            RC_DCOPY_T                 = $uiToggleLists.RC_DCOPY_T.Value
            RC_NP                      = $uiToggleLists.RC_NP.Value
            RC_FFT                     = $uiToggleLists.RC_FFT.Value
            RC_XO                      = $uiToggleLists.RC_XO.Value
            RC_XN                      = $uiToggleLists.RC_XN.Value
            RC_XJ                      = $uiToggleLists.RC_XJ.Value
            RC_L                       = $uiToggleLists.RC_L.Value
            RC_V                       = $uiToggleLists.RC_V.Value
            RC_MT                      = (Get-ScapeConstant -Path "ui::CycleLists::RC_MT").Options[0]
            RC_R                       = (Get-ScapeConstant -Path "ui::CycleLists::RC_R").Options[0]
            RC_W                       = (Get-ScapeConstant -Path "ui::CycleLists::RC_W").Options[0]
            # Terminal Capabilities
            Capability_TrueColor       = $termCaps.TrueColor.Value
            Capability_Hyperlinks      = $termCaps.Hyperlinks.Value
            Capability_BracketedPaste  = $termCaps.BracketedPaste.Value
            Capability_MouseTracking   = $termCaps.MouseTracking.Value
            Capability_AlternateScreen = $termCaps.AlternateScreen.Value
            Capability_FocusEvents     = $termCaps.FocusEvents.Value
            Capability_KittyKeyboard   = $termCaps.KittyKeyboard.Value
            Capability_SixelGraphics   = $termCaps.SixelGraphics.Value
            Capability_CSIuKeyboard    = $termCaps.CSIuKeyboard.Value
            Capability_Fallback256     = $termCaps.Fallback256.Value
            Capability_Fallback16      = $termCaps.Fallback16.Value
        }
    }
}


function Sync-ScapeThemeHydration {
    [CmdletBinding()]
    param()
    process {
        $state = Get-ScapeColdState
        if ($null -eq $state) { return }

        $persona = [string](Get-ScapeProperty -Object $state -PropertyName "ThemePersona")
        if (-not [string]::IsNullOrWhiteSpace($persona)) {
            if ($persona -eq "RANDOM") {
                $rawHue = Get-ScapeProperty -Object $state -PropertyName "RandomBaseHue"
                $baseHue = $null
                $hasHue = $false
                if ($rawHue -is [double] -or $rawHue -is [float] -or $rawHue -is [int] -or $rawHue -is [decimal]) {
                    $baseHue = [double]$rawHue
                    $hasHue = $true
                } elseif ($rawHue -is [string]) {
                    $hasHue = [double]::TryParse($rawHue, [ref]$baseHue)
                }

                if (-not $hasHue -or [double]::IsNaN($baseHue) -or [double]::IsInfinity($baseHue)) {
                    $baseHue = ([Random]::new()).NextDouble() * 360
                    if (Get-Command Set-ScapeSettingMutation -ErrorAction SilentlyContinue) {
                        Set-ScapeSettingMutation -Key "RandomBaseHue" -Value $baseHue | Out-Null
                    } else {
                        Update-ScapeColdState -NewProperties @{ RandomBaseHue = $baseHue } | Out-Null
                    }
                }

                if (Get-Command Invoke-ScapeProceduralTheme -ErrorAction SilentlyContinue) {
                    Invoke-ScapeProceduralTheme -BaseHue $baseHue
                }
            } elseif (Get-Command Set-ScapePersona -ErrorAction SilentlyContinue) {
                $personaData = Set-ScapePersona -Name $persona -Silent
                if ($null -ne $personaData -and $personaData.Count -gt 0) {
                    Update-ScapeColdState -NewProperties $personaData | Out-Null
                }
            }
        }

        $useTrueColor = $false
        $colorMode = Get-ScapeProperty -Object $state -PropertyName "ColorMode"
        if ($colorMode -is [string]) {
            $useTrueColor = $colorMode -ieq "TrueColor"
        } elseif ($colorMode -is [bool]) {
            $useTrueColor = [bool]$colorMode
        } else {
            $useTrueColor = (Get-ScapeProperty -Object $state -PropertyName "Capability_TrueColor" -Fallback $true) -eq $true
        }

        if (Get-Command Set-ScapeColorMode -ErrorAction SilentlyContinue) {
            Set-ScapeColorMode -UseTrueColor $useTrueColor -Silent
        }
    }
}

function Set-ScapeSettingMutation {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][object]$Value
    )
    process {
        if ($PSCmdlet.ShouldProcess("ScapeSettings", "Set $Key to $Value")) {
            $defaults = Get-ScapeSettingDefault
            if (-not $defaults.Contains($Key)) {
                Publish-ScapeEvent -Type "LOG_DEBUG" -Severity "LOG_WARN" -Payload @{ Key = "SETTINGS_MUTATE_UNKNOWN"; Tokens = @($Key) }
                return $false
            }
            $state = Get-ScapeColdState
            $settingsToSave = [ordered]@{}
            foreach ($k in $defaults.Keys) {
                $settingsToSave[$k] = Get-ScapeProperty -Object $state -PropertyName $k -Fallback $defaults[$k]
            }
            $effectiveValue = $Value
            if ($Key -eq "EngineMode") {
                if ($Value -is [bool]) { $effectiveValue = if ($Value) { "REDUNDANCY" } else { "EFFICIENCY" } }
                elseif (-not [string]::IsNullOrWhiteSpace([string]$Value)) { $effectiveValue = ([string]$Value).ToUpperInvariant() }
            }
            $settingsToSave[$Key] = $effectiveValue

            Invoke-ScapeIO -Action "WRITE_SETTINGS" -Target (Get-ScapeSettingsPath) -Operation {
                $json = $settingsToSave | ConvertTo-Json -Depth 3 -Compress -WarningAction SilentlyContinue
                $dir = Split-Path -Path (Get-ScapeSettingsPath) -Parent
                if (-not (Test-Path -Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                [System.IO.File]::WriteAllTextAsync((Get-ScapeSettingsPath), $json, [System.Text.UTF8Encoding]::new($false)) | Out-Null
            } | Out-Null

            Update-ScapeColdState -NewProperties @{ $Key = $effectiveValue } | Out-Null

            # --- ROTEAMENTO E AÇÕES PÓS-MUTAÇÃO ---

            Publish-ScapeEvent -Type "SETTING_MUTATED" -Severity "TRACE" -Payload @{ Key = $Key; Value = $effectiveValue }

            # 1. Idioma
            if ($Key -eq "CurrentLanguage") {
                $configObj = Get-ScapeProperty -Object $state -PropertyName "Config" -Fallback @{}
                $configObj["Language"] = $effectiveValue
                Update-ScapeColdState -NewProperties @{ Config = $configObj } | Out-Null
                Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = $effectiveValue }
            }

            # 2. Persona de Tema
            if ($Key -eq "ThemePersona") {
                if ($effectiveValue -eq "RANDOM") {
                    $rawHue = Get-ScapeProperty -Object $state -PropertyName "RandomBaseHue"
                    $baseHue = if ($rawHue -is [double] -or $rawHue -is [float] -or $rawHue -is [int]) { [double]$rawHue } else { ([Random]::new()).NextDouble() * 360 }
                    if (Get-Command Invoke-ScapeProceduralTheme -ErrorAction SilentlyContinue) {
                        Invoke-ScapeProceduralTheme -BaseHue $baseHue
                    }
                } elseif (Get-Command Set-ScapePersona -ErrorAction SilentlyContinue) {
                    $personaData = Set-ScapePersona -Name $effectiveValue
                    if ($null -ne $personaData -and $personaData.Count -gt 0) {
                        Update-ScapeColdState -NewProperties $personaData | Out-Null
                    }
                }
            }

            # 3. Color Mode e Capabilities Visuais (Sincronização Bidirecional)
            if ($Key -eq "ColorMode" -or $Key -eq "Capability_TrueColor") {
                $useTrueColor = $false
                if ($Key -eq "ColorMode") {
                    if ($effectiveValue -is [bool]) { $useTrueColor = $effectiveValue }
                    elseif ($effectiveValue -is [string]) {
                        if ($effectiveValue -ieq "TrueColor") { $useTrueColor = $true }
                        elseif ($effectiveValue -ieq "ANSI16") { $useTrueColor = $false }
                        else {
                            $currCapability = Get-ScapeProperty -Object $state -PropertyName "Capability_TrueColor" -Fallback $true
                            $useTrueColor = [bool]$currCapability
                        }
                    }
                    else {
                        $useTrueColor = [bool]$effectiveValue
                    }
                }
                else {
                    $useTrueColor = [bool]$effectiveValue
                }

                if (Get-Command Set-ScapeColorMode -ErrorAction SilentlyContinue) {
                    Set-ScapeColorMode -UseTrueColor $useTrueColor
                }
                $strMode = if ($useTrueColor) { "TrueColor" } else { "ANSI16" }
                Update-ScapeColdState -NewProperties @{ ColorMode = $strMode; Capability_TrueColor = $useTrueColor } | Out-Null
            }

            # 5. Outras Capabilities
            if ($Key -match "^Capability_" -and $Key -ne "Capability_TrueColor") {
                Publish-ScapeEvent -Type "CAPABILITY_UPDATED" -Severity "INFO" -Payload @{ Capability = $Key; Value = $Value }
            }

            $msgSuccess = Get-ScapeLogMsg -Key "SETTINGS_MUTATE_SUCCESS" -MsgArgs @($Key, $effectiveValue)
            Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Key = "SETTINGS_MUTATE_SUCCESS"; Tokens = @($Key, $effectiveValue); Message = $msgSuccess }

            return $true
        }
        return $false
    }
}

function Reset-ScapeSettingToFactory {
    [CmdletBinding()]
    Param()
    process {
        $settingsPath = Get-ScapeSettingsPath
        if (Test-Path -Path $settingsPath) {
            Invoke-ScapeIO -Action "DELETE_SETTINGS" -Target $settingsPath -Operation {
                Remove-Item -Path $settingsPath -Force -ErrorAction SilentlyContinue
            } | Out-Null
        }
        $defaults = Get-ScapeSettingDefault
        Update-ScapeColdState -NewProperties $defaults | Out-Null
        Update-ScapeColdState -NewProperties @{ Config = @{ Language = $defaults["CurrentLanguage"] } } | Out-Null
        if (Get-Command Set-ScapePersona -ErrorAction SilentlyContinue) {
            $personaData = Set-ScapePersona -Name $defaults["ThemePersona"] -Silent
            if ($null -ne $personaData -and $personaData.Count -gt 0) {
                Update-ScapeColdState -NewProperties $personaData | Out-Null
            }
        }
        $useTrueColor = $defaults["Capability_TrueColor"] -eq $true
        if (Get-Command Set-ScapeColorMode -ErrorAction SilentlyContinue) {
            Set-ScapeColorMode -UseTrueColor $useTrueColor
        }

        $msgReset = Get-ScapeLogMsg -Key "SETTINGS_RESET_SUCCESS" -MsgArgs @()
        Publish-ScapeEvent -Type "SYS_CORE" -Severity "LOG_WARN" -Payload @{ Key = "SETTINGS_RESET_SUCCESS"; Message = $msgReset }
        
        # Trigger generic state mutation instead of hardcoding UI Redraw
        Publish-ScapeEvent -Type "SETTING_MUTATED" -Severity "INFO" -Payload @{ Key = "ThemePersona" }
    }
}

function _LoadSettingsFromJson {
    param([hashtable]$Defaults)
    process {
        try {
            $settingsPath = Get-ScapeSettingsPath
            if (-not (Test-Path -Path $settingsPath)) { return $Defaults.Clone() }
            $jsonRaw = (Get-Content -Path $settingsPath -Raw -Encoding UTF8 -ErrorAction Stop).Trim()
            if ([string]::IsNullOrWhiteSpace($jsonRaw)) { return $Defaults.Clone() }
            if ($jsonRaw[0] -ne '{') {
                throw "Invalid JSON structure: Expected '{' at index 0, found '$($jsonRaw[0])'"
            }
            $loaded = $jsonRaw | ConvertFrom-Json -WarningAction SilentlyContinue
            $merged = $Defaults.Clone()
            foreach ($k in $Defaults.Keys) {
                $val = Get-ScapeProperty -Object $loaded -PropertyName $k
                if ($null -ne $val -and $val -ne "") { $merged[$k] = $val }
            }
            return $merged
        }
        catch {
            if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                Publish-ScapeEvent -Type "SETTINGS_LOAD_FAULT" -Severity "LOG_WARN" -Payload @{
                    Reason = $_.Exception.Message
                    File   = (Get-ScapeSettingsPath)
                }
            }
            return $Defaults.Clone()
        }
    }
}

function Optimize-ScapeSettingsState {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$State,
        [Parameter(Mandatory = $true)][hashtable]$Defaults
    )

    $normalized = [ordered]@{}
    foreach ($k in $State.Keys) { $normalized[$k] = $State[$k] }

    $engineModesRaw = Get-ScapeConstant -Path "ui::CycleLists::EngineMode"
    $engineModes = if ($null -ne $engineModesRaw.Options) { $engineModesRaw.Options } else { @("EFFICIENCY", "REDUNDANCY") }
    $defaultEngine = if ($Defaults.Contains("EngineMode")) { [string]$Defaults["EngineMode"] } else { "EFFICIENCY" }
    $currEngine = $normalized["EngineMode"]
    if ($currEngine -is [bool]) {
        $normalized["EngineMode"] = if ($currEngine) { "REDUNDANCY" } else { "EFFICIENCY" }
    }
    elseif ([string]::IsNullOrWhiteSpace([string]$currEngine)) {
        $normalized["EngineMode"] = $defaultEngine
    }
    else {
        $engineCandidate = ([string]$currEngine).ToUpperInvariant()
        $normalized["EngineMode"] = if ($engineCandidate -in $engineModes) { $engineCandidate } else { $defaultEngine }
    }

    $colorModesRaw = Get-ScapeConstant -Path "ui::CycleLists::ColorMode"
    $colorModes = if ($null -ne $colorModesRaw.Options) { $colorModesRaw.Options } else { @("TrueColor", "ANSI16") }
    $currColor = $normalized["ColorMode"]
    if ($currColor -is [bool]) {
        $normalized["ColorMode"] = if ($currColor) { "TrueColor" } else { "ANSI16" }
    }
    elseif ([string]::IsNullOrWhiteSpace([string]$currColor) -or ([string]$currColor -notin $colorModes)) {
        $normalized["ColorMode"] = if ($normalized["Capability_TrueColor"]) { "TrueColor" } else { "ANSI16" }
    }

    $i18nListRaw = Get-ScapeConstant -Path "ui::CycleLists::I18N"
    $i18nList = if ($null -ne $i18nListRaw.Options) { $i18nListRaw.Options } else { @("en-US") }
    $currLang = [string]$normalized["CurrentLanguage"]
    if ([string]::IsNullOrWhiteSpace($currLang) -or $currLang -notin $i18nList) {
        $normalized["CurrentLanguage"] = if ($Defaults.Contains("CurrentLanguage")) { $Defaults["CurrentLanguage"] } else { "en-US" }
    }

    $personaListRaw = Get-ScapeConstant -Path "ui::CycleLists::ThemePersona"
    $personaList = if ($null -ne $personaListRaw.Options) { $personaListRaw.Options } else { @("PowerShell") }
    $currPersona = [string]$normalized["ThemePersona"]
    if ([string]::IsNullOrWhiteSpace($currPersona) -or ($currPersona -notin $personaList -and $currPersona -ne "RANDOM")) {
        $normalized["ThemePersona"] = if ($Defaults.Contains("ThemePersona")) { $Defaults["ThemePersona"] } else { "PowerShell" }
    }

    $rawHue = $normalized["RandomBaseHue"]
    if ($null -ne $rawHue -and $rawHue -ne "") {
        $parsedHue = $null
        $isNumeric = $false
        if ($rawHue -is [double] -or $rawHue -is [float] -or $rawHue -is [int] -or $rawHue -is [decimal]) {
            $parsedHue = [double]$rawHue
            $isNumeric = $true
        } elseif ($rawHue -is [string]) {
            $isNumeric = [double]::TryParse($rawHue, [ref]$parsedHue)
        }

        if ($isNumeric -and -not [double]::IsNaN($parsedHue) -and -not [double]::IsInfinity($parsedHue)) {
            $normalized["RandomBaseHue"] = ((($parsedHue % 360) + 360) % 360)
        } else {
            $normalized["RandomBaseHue"] = $null
        }
    } else {
        $normalized["RandomBaseHue"] = $null
    }

    return $normalized
}



