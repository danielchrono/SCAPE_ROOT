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
            ThemePersona               = $uiDefaults.ThemeProfile
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
            $settingsToSave[$Key] = $Value
            Invoke-ScapeIO -Action "WRITE_SETTINGS" -Target (Get-ScapeSettingsPath) -Operation {
                $json = $settingsToSave | ConvertTo-Json -Depth 3 -Compress -WarningAction SilentlyContinue
                $dir = Split-Path -Path (Get-ScapeSettingsPath) -Parent
                if (-not (Test-Path -Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                [System.IO.File]::WriteAllText((Get-ScapeSettingsPath), $json, [System.Text.UTF8Encoding]::new($false))
            } | Out-Null
            Update-ScapeColdState -NewProperties @{ $Key = $Value } | Out-Null
            if ($Key -eq "CurrentLanguage") {
                Update-ScapeColdState -NewProperties @{ Config = @{ Language = $Value } } | Out-Null
            }
            if ($Key -eq "ThemePersona" -and (Get-Command Set-ScapePersona -ErrorAction SilentlyContinue)) {
                Set-ScapePersona -Name $Value
            }
            if ($Key -match "^Capability_") {
                if ($Key -eq "Capability_TrueColor" -and (Get-Command Set-ScapeColorMode -ErrorAction SilentlyContinue)) {
                    Set-ScapeColorMode -UseTrueColor ([bool]$Value)
                }
                Publish-ScapeEvent -Type "CAPABILITY_UPDATED" -Severity "INFO" -Payload @{ Capability = $Key; Value = $Value }
            }
            $msgSuccess = Get-ScapeLogMsg -Key "SETTINGS_MUTATE_SUCCESS" -MsgArgs @($Key, $Value)
            Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Key = "SETTINGS_MUTATE_SUCCESS"; Tokens = @($Key, $Value); Message = $msgSuccess }
            return $true
        }
        return $false
    }
}

function Reset-ScapeSettingToFactory {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param()
    process {
        if ($PSCmdlet.ShouldProcess("ScapeSettings", "Reset to Factory Defaults")) {
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
