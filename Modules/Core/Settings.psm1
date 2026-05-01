<#
.SYNOPSIS
    Domain: Foundation | Module: Scape.Core.Settings
    Architecture: Dynamic State Mutator | JSON Portable Persistence | SSOT Compliant
#>

$Script:SettingsPath = Join-Path -Path $global:BootRoot -ChildPath "Data\UserSettings.json"

function Get-ScapeSettingDefault {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()
    process {
        return [ordered]@{
            Theme           = Get-ScapeConstant -Path "theme::DynamicTheme::Fallback" -Fallback "Dark"
            CurrentLanguage = Get-ScapeConstant -Path "dir::DEFAULTS::LANG" -Fallback "en-US"
            UiMargin        = Get-ScapeConstant -Path "ui::Layout::Margin" -Fallback 2
            EngineMode      = Get-ScapeConstant -Path "dir::DEFAULTS::MODE" -Fallback "EFFICIENCY"
            OutPath         = Get-ScapeConstant -Path "dir::DEFAULTS::OUT_DIR" -Fallback "Desktop\SCAPE_Recovery"
            LogLevel        = Get-ScapeConstant -Path "compliance::AUDIT::DEFAULT_LEVEL" -Fallback 1
            MaxRetries      = Get-ScapeConstant -Path "behavior::BEHAVIOR::RETRY_MAX_ATTEMPTS" -Fallback 5
            WatchdogAction  = Get-ScapeConstant -Path "behavior::BEHAVIOR::WATCHDOG_ACTION" -Fallback "RESTART"
            SmbTimeoutMs    = Get-ScapeConstant -Path "net::PROTOCOLS::TIMEOUT_MS" -Fallback 100
            IoChunkSize     = Get-ScapeConstant -Path "io::BUFFER::CHUNK_READ" -Fallback 65536
            RobocopyThreads = Get-ScapeConstant -Path "behavior::LIMITS::ROBOCOPY_THREAD_AUTO" -Fallback 128
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

        Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Action = "LogLine"; Key = "SETTINGS_ENGINE_ONLINE" }
        return $state
    }
}

function Set-ScapeSettingMutation {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][string]$Value
    )
    process {
        if ($PSCmdlet.ShouldProcess("ScapeSettings", "Set $Key to $Value")) {
            $defaults = Get-ScapeSettingDefault

            if (-not $defaults.Contains($Key)) {
                Publish-ScapeEvent -Type "LOG_DEBUG" -Severity "LOG_WARN" -Payload @{ Key = "SETTINGS_MUTATE_UNKNOWN"; Tokens = @($Key) }
                return $false
            }

            $state = Get-ScapeColdState
            $settingsToSave = @{}
            foreach ($k in $defaults.Keys) {
                $settingsToSave[$k] = Get-ScapeProperty -Object $state -PropertyName $k -Fallback $defaults[$k]
            }

            $settingsToSave[$Key] = $Value

            # Envelopado no I/O Wrapper para Compliance
            Invoke-ScapeIO -Action "WRITE_SETTINGS" -Target $Script:SettingsPath -Operation {
                $json = $settingsToSave | ConvertTo-Json -Depth 3 -Compress
                $dir = Split-Path -Path $Script:SettingsPath
                if (-not (Test-Path -Path $dir)) {
                    New-Item -ItemType Directory -Path $dir -Force | Out-Null
                }
                Set-Content -Path $Script:SettingsPath -Value $json -Encoding UTF8 -Force
            } | Out-Null

            Update-ScapeColdState -NewProperties @{ $Key = $Value } | Out-Null

            if ($Key -eq "CurrentLanguage") {
                Update-ScapeColdState -NewProperties @{ Config = @{ Language = $Value } } | Out-Null
            }

            Publish-ScapeEvent -Type "SYS_CORE" -Payload @{ Key = "SETTINGS_MUTATE_SUCCESS"; Tokens = @($Key, $Value) }
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
            if (Test-Path -Path $Script:SettingsPath) {
                Invoke-ScapeIO -Action "DELETE_SETTINGS" -Target $Script:SettingsPath -Operation {
                    Remove-Item -Path $Script:SettingsPath -Force
                } | Out-Null
            }

            $defaults = Get-ScapeSettingDefault
            Update-ScapeColdState -NewProperties $defaults | Out-Null
            Update-ScapeColdState -NewProperties @{ Config = @{ Language = $defaults["CurrentLanguage"] } } | Out-Null

            Publish-ScapeEvent -Type "SYS_CORE" -Severity "LOG_WARN" -Payload @{ Key = "SETTINGS_RESET_SUCCESS" }
        }
    }
}

function _LoadSettingsFromJson {
    param([hashtable]$Defaults)
    process {
        try {
            if (-not (Test-Path -Path $Script:SettingsPath)) { return $Defaults.Clone() }

            $jsonRaw = Get-Content -Path $Script:SettingsPath -Raw -Encoding UTF8 -ErrorAction Stop
            if ([string]::IsNullOrWhiteSpace($jsonRaw)) { return $Defaults.Clone() }

            $loaded = $jsonRaw | ConvertFrom-Json -ErrorAction Stop
            $merged = $Defaults.Clone()

            foreach ($k in $Defaults.Keys) {
                $val = Get-ScapeProperty -Object $loaded -PropertyName $k
                if ($val -ne "") { $merged[$k] = $val }
            }
            return $merged
        }
        catch {
            Publish-ScapeEvent -Type "SETTINGS_LOAD_FALLBACK" -Severity "LOG_DEBUG" -Payload @{ Reason = $_.Exception.Message } -ErrorAction SilentlyContinue
            return $Defaults.Clone()
        }
    }
}