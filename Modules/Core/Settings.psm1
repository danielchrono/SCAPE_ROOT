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
        $root = (Get-ScapeColdState)["ROOT"]
        if ($null -eq $root) { throw "ColdState ROOT not initialized" }
        $Script:SettingsPath = Join-Path -Path $root -ChildPath "Data\UserSettings.json"
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
            LogLevel                   = Get-ScapeConstant -Path "infrastructure::Audit::DEFAULT_LEVEL_NAME" # Corrigido
            MaxRetries                 = Get-ScapeConstant -Path "system::system::RETRY_MAX_ATTEMPTS"
            WatchdogAction             = Get-ScapeConstant -Path "system::system::WATCHDOG_ACTION"
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
            RC_E                       = $uiToggleLists.RC_E
            RC_ZB                      = $uiToggleLists.RC_ZB
            RC_M                       = $uiToggleLists.RC_M
            RC_B                       = $uiToggleLists.RC_B
            RC_COPYALL                 = $uiToggleLists.RC_COPYALL
            RC_DCOPY_T                 = $uiToggleLists.RC_DCOPY_T
            RC_NP                      = $uiToggleLists.RC_NP
            RC_FFT                     = $uiToggleLists.RC_FFT
            RC_XO                      = $uiToggleLists.RC_XO
            RC_XN                      = $uiToggleLists.RC_XN
            RC_XJ                      = $uiToggleLists.RC_XJ
            RC_L                       = $uiToggleLists.RC_L
            RC_V                       = $uiToggleLists.RC_V
            RC_MT                      = (Get-ScapeConstant -Path "ui::CycleLists::RC_MT")[0]
            RC_R                       = (Get-ScapeConstant -Path "ui::CycleLists::RC_R")[0]
            RC_W                       = (Get-ScapeConstant -Path "ui::CycleLists::RC_W")[0]
            # Terminal Capabilities
            Capability_TrueColor       = $termCaps.TrueColor
            Capability_Hyperlinks      = $termCaps.Hyperlinks
            Capability_BracketedPaste  = $termCaps.BracketedPaste
            Capability_MouseTracking   = $termCaps.MouseTracking
            Capability_AlternateScreen = $termCaps.AlternateScreen
            Capability_FocusEvents     = $termCaps.FocusEvents
            Capability_KittyKeyboard   = $termCaps.KittyKeyboard
            Capability_SixelGraphics   = $termCaps.SixelGraphics
            Capability_CSIuKeyboard    = $termCaps.CSIuKeyboard
            Capability_Fallback256     = $termCaps.Fallback256
            Capability_Fallback16      = $termCaps.Fallback16
        }
    }
}

function Initialize-ScapeSetting {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([switch]$ForceReset)
    process {
        $defaults = Get-ScapeSettingDefault
        $state = if ($ForceReset) {
            $defaults
        }
        else {
            _LoadSettingsFromJson -Defaults $defaults
        }
        $state = Optimize-ScapeSettingsState -State $state -Defaults $defaults
        Update-ScapeColdState -NewProperties $state | Out-Null
        Update-ScapeColdState -NewProperties @{ Config = @{ Language = $state["CurrentLanguage"] } } | Out-Null
        if (Get-Command Set-ScapePersona -ErrorAction SilentlyContinue) {
            Set-ScapePersona -Name $state["ThemePersona"] -Silent
        }
        $useTrueColor = $state["Capability_TrueColor"] -eq $true
        if (Get-Command Set-ScapeColorMode -ErrorAction SilentlyContinue) {
            Set-ScapeColorMode -UseTrueColor $useTrueColor
        }
        $msgInit = Get-ScapeLogMsg -Key "SETTINGS_ENGINE_ONLINE" -MsgArgs @()
        Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "SETTINGS_ENGINE_ONLINE"; Message = $msgInit }
        return $state
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
                Set-ScapePersona -Name $persona -Silent
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
                [System.IO.File]::WriteAllText((Get-ScapeSettingsPath), $json, [System.Text.UTF8Encoding]::new($false))
            } | Out-Null

            Update-ScapeColdState -NewProperties @{ $Key = $effectiveValue } | Out-Null

            # --- ROTEAMENTO E AÇÕES PÓS-MUTAÇÃO ---

            # 1. Idioma
            if ($Key -eq "CurrentLanguage") {
                $configObj = Get-ScapeProperty -Object $state -PropertyName "Config" -Fallback @{}
                $configObj["Language"] = $effectiveValue
                Update-ScapeColdState -NewProperties @{ Config = $configObj } | Out-Null
                Publish-ScapeEvent -Type "LANG_SWITCH" -Severity "INFO" -Payload @{ Language = $effectiveValue }
            }

            # 2. Persona de Tema
            if ($Key -eq "ThemePersona" -and (Get-Command Set-ScapePersona -ErrorAction SilentlyContinue)) {
                Set-ScapePersona -Name $effectiveValue
                Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{ Type = 'FULL'; MenuId = $state.CurrentMenu }
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
                Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{ Type = 'FULL'; MenuId = $state.CurrentMenu }
            }

            # 4. Modificadores Visuais Imediatos (Requerem repintura instantânea)
            if ($Key -match "^(IconLevel|FrameStyle|ProgressStyle)$") {
                Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{ Type = 'FULL'; MenuId = $state.CurrentMenu }
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
            Set-ScapePersona -Name $defaults["ThemePersona"] -Silent
        }
        $useTrueColor = $defaults["Capability_TrueColor"] -eq $true
        if (Get-Command Set-ScapeColorMode -ErrorAction SilentlyContinue) {
            Set-ScapeColorMode -UseTrueColor $useTrueColor
        }

        $msgReset = Get-ScapeLogMsg -Key "SETTINGS_RESET_SUCCESS" -MsgArgs @()
        Publish-ScapeEvent -Type "SYS_CORE" -Severity "LOG_WARN" -Payload @{ Key = "SETTINGS_RESET_SUCCESS"; Message = $msgReset }
        
        # Trigger full redraw to reflect reset defaults
        $state = Get-ScapeColdState
        if ($state -and $state.CurrentMenu) {
            Publish-ScapeEvent -Type "UI_REDRAW_REQUEST" -Severity "INFO" -Payload @{ Type = "FULL"; MenuId = $state.CurrentMenu }
        }
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

    $engineModes = Get-ScapeConstant -Path "ui::CycleLists::EngineMode" -Fallback @("EFFICIENCY", "REDUNDANCY")
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

    $colorModes = Get-ScapeConstant -Path "ui::CycleLists::ColorMode" -Fallback @("TrueColor", "ANSI16")
    $currColor = $normalized["ColorMode"]
    if ($currColor -is [bool]) {
        $normalized["ColorMode"] = if ($currColor) { "TrueColor" } else { "ANSI16" }
    }
    elseif ([string]::IsNullOrWhiteSpace([string]$currColor) -or ([string]$currColor -notin $colorModes)) {
        $normalized["ColorMode"] = if ($normalized["Capability_TrueColor"]) { "TrueColor" } else { "ANSI16" }
    }

    $i18nList = Get-ScapeConstant -Path "ui::CycleLists::I18N" -Fallback @("en-US")
    $currLang = [string]$normalized["CurrentLanguage"]
    if ([string]::IsNullOrWhiteSpace($currLang) -or $currLang -notin $i18nList) {
        $normalized["CurrentLanguage"] = if ($Defaults.Contains("CurrentLanguage")) { $Defaults["CurrentLanguage"] } else { "en-US" }
    }

    $personaList = Get-ScapeConstant -Path "ui::CycleLists::ThemePersona" -Fallback @("PowerShell")
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
