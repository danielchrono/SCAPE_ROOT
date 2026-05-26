<#
.SYNOPSIS
    Domain: Presentation\KeyBindings
    Module: Scape.Presentation.KeyBindings
    Architecture: Dynamic Key Registry | Chord Detection | Profile-Based Bindings
    Description: Runtime keybinding registration, persistence, and customization system
#>
[CmdletBinding()] param()

$Script:KeyBindingRegistry = @{}
$Script:KeyBindingProfiles = @{}
$Script:ActiveProfile = "Default"
$Script:ChordBuffer = @()
$Script:ChordTimeoutMs = 500

function Initialize-ScapeKeyBindings {
    [CmdletBinding()]
    param()
    process {
        $Script:KeyBindingRegistry = @{}
        $Script:KeyBindingProfiles = @{}
        $Script:ActiveProfile = "Default"

        $uiConsts = Get-ScapeConstant -Path "ui::Input::PSCombos"
        if ($null -ne $uiConsts) {
            $defaultProfile = @{}
            foreach ($key in $uiConsts.Keys) {
                $defaultProfile[$key] = $uiConsts[$key]
            }
            $Script:KeyBindingProfiles["Default"] = $defaultProfile
            $Script:KeyBindingRegistry = [hashtable]$defaultProfile
        }

        Load-ScapeKeyBindingsFromFile | Out-Null
    }
}

function Register-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$KeySequence,
        [Parameter(Mandatory = $true)][string]$ActionName,
        [string]$Profile = "Default",
        [scriptblock]$Callback,
        [switch]$Chord
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        $key = $KeySequence
        if ($Chord) { $key = "CHORD:$KeySequence" }

        $binding = @{
            Sequence = $KeySequence
            Action = $ActionName
            Callback = $Callback
            IsChord = $Chord.IsPresent
            Profile = $Profile
            RegisteredAt = [DateTime]::Now
        }

        $Script:KeyBindingRegistry[$key] = $binding

        if (-not $Script:KeyBindingProfiles.ContainsKey($Profile)) {
            $Script:KeyBindingProfiles[$Profile] = @{}
        }
        $Script:KeyBindingProfiles[$Profile][$key] = $binding

        return $true
    }
}

function Unregister-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$KeySequence,
        [string]$Profile = "Default"
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { return $false }

        if ($Script:KeyBindingRegistry.ContainsKey($KeySequence)) {
            $Script:KeyBindingRegistry.Remove($KeySequence) | Out-Null
        }

        if ($Script:KeyBindingProfiles.ContainsKey($Profile)) {
            $Script:KeyBindingProfiles[$Profile].Remove($KeySequence) | Out-Null
        }

        return $true
    }
}

function Get-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$KeySequence,
        [switch]$Chord
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        $key = $KeySequence
        if ($Chord) { $key = "CHORD:$KeySequence" }

        if ($Script:KeyBindingRegistry.ContainsKey($key)) {
            return $Script:KeyBindingRegistry[$key]
        }
        return $null
    }
}

function Get-ScapeKeyBindings {
    [CmdletBinding()]
    [OutputType([array])]
    param([string]$Profile = "Default")
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        if ($null -ne $Profile -and $Script:KeyBindingProfiles.ContainsKey($Profile)) {
            return @($Script:KeyBindingProfiles[$Profile].Values)
        }
        return @($Script:KeyBindingRegistry.Values)
    }
}

function Set-ScapeKeyBindingProfile {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$ProfileName,
        [ValidateSet('Default', 'Vim', 'Emacs', 'Windows')][string]$Preset
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        $Script:ActiveProfile = $ProfileName

        if ($null -ne $Preset) {
            switch ($Preset) {
                'Vim' {
                    Register-ScapeKeyBinding -KeySequence 'j' -ActionName 'DOWN' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'k' -ActionName 'UP' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'h' -ActionName 'LEFT' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'l' -ActionName 'RIGHT' -Profile $ProfileName
                }
                'Emacs' {
                    Register-ScapeKeyBinding -KeySequence 'Ctrl+N' -ActionName 'DOWN' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'Ctrl+P' -ActionName 'UP' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'Ctrl+B' -ActionName 'LEFT' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'Ctrl+F' -ActionName 'RIGHT' -Profile $ProfileName
                }
                'Windows' {
                    Register-ScapeKeyBinding -KeySequence 'UpArrow' -ActionName 'UP' -Profile $ProfileName
                    Register-ScapeKeyBinding -KeySequence 'DownArrow' -ActionName 'DOWN' -Profile $ProfileName
                }
            }
        }

        if ($Script:KeyBindingProfiles.ContainsKey($ProfileName)) {
            $Script:KeyBindingRegistry = [hashtable]$Script:KeyBindingProfiles[$ProfileName]
        }

        return $true
    }
}

function Invoke-ScapeChordDetection {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$InitialKey,
        [int]$TimeoutMs = 500
    )
    process {
        $Script:ChordBuffer = @($InitialKey)
        $startTime = [DateTime]::Now

        while (([DateTime]::Now - $startTime).TotalMilliseconds -lt $TimeoutMs) {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                $keyName = if ($key.Key -eq [ConsoleKey]::Enter) { 'Enter' } else { $key.KeyChar }
                $Script:ChordBuffer += $keyName
            } else {
                Start-Sleep -Milliseconds 10
            }
        }

        $chord = $Script:ChordBuffer -join "+"
        $Script:ChordBuffer = @()
        return $chord
    }
}

function Resolve-ScapeInputToAction {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$KeyInput,
        [string]$Profile
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        $prof = if ([string]::IsNullOrWhiteSpace($Profile)) { $Script:ActiveProfile } else { $Profile }

        $binding = Get-ScapeKeyBinding -KeySequence $KeyInput
        if ($null -ne $binding) {
            if ($null -ne $binding.Callback) {
                & $binding.Callback | Out-Null
            }
            return $binding.Action
        }

        return 'IDLE'
    }
}

function Set-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$ActionName,
        [Parameter(Mandatory = $true)][string]$NewKeySequence,
        [string]$Profile = "Default"
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        $existing = $Script:KeyBindingRegistry.Values | Where-Object { $_.Action -eq $ActionName }

        foreach ($binding in $existing) {
            Unregister-ScapeKeyBinding -KeySequence $binding.Sequence -Profile $Profile | Out-Null
        }

        return Register-ScapeKeyBinding -KeySequence $NewKeySequence -ActionName $ActionName -Profile $Profile
    }
}

function Export-ScapeKeyBindings {
    [CmdletBinding()]
    [OutputType([bool])]
    param([string]$Path)
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBindings }

        $configPath = if ([string]::IsNullOrWhiteSpace($Path)) {
            Join-Path -Path (Get-ScapeConstant -Path "project::home") -ChildPath ".scape/keybindings.json"
        } else {
            $Path
        }

        $dir = Split-Path -Parent $configPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

        $exportData = @{
            Profiles = @{}
            ActiveProfile = $Script:ActiveProfile
        }

        foreach ($prof in $Script:KeyBindingProfiles.Keys) {
            $exportData.Profiles[$prof] = @()
            foreach ($binding in $Script:KeyBindingProfiles[$prof].Values) {
                $exportData.Profiles[$prof] += @{
                    Sequence = $binding.Sequence
                    Action = $binding.Action
                    IsChord = $binding.IsChord
                }
            }
        }

        try {
            $json = $exportData | ConvertTo-Json -Depth 5
            Set-Content -Path $configPath -Value $json -Encoding UTF8 -NoNewline
            return $true
        }
        catch {
            Write-Error "Failed to save keybindings: $_"
            return $false
        }
    }
}

function Import-ScapeKeyBindings {
    [CmdletBinding()]
    [OutputType([bool])]
    param([string]$Path)
    process {
        $configPath = if ([string]::IsNullOrWhiteSpace($Path)) {
            Join-Path -Path (Get-ScapeConstant -Path "project::home" -Fallback $env:USERPROFILE) -ChildPath ".scape/keybindings.json"
        } else {
            $Path
        }

        if (-not (Test-Path $configPath)) { return $false }

        try {
            $json = Get-Content -Path $configPath -Raw -Encoding UTF8
            $data = $json | ConvertFrom-Json

            foreach ($prof in $data.Profiles.PSObject.Properties) {
                $profileName = $prof.Name
                Set-ScapeKeyBindingProfile -ProfileName $profileName | Out-Null

                foreach ($binding in $prof.Value) {
                    Register-ScapeKeyBinding -KeySequence $binding.Sequence -ActionName $binding.Action -Profile $profileName -Chord:$binding.IsChord | Out-Null
                }
            }

            if ($data.ActiveProfile) {
                $Script:ActiveProfile = $data.ActiveProfile
            }

            return $true
        }
        catch {
            Write-Error "Failed to load keybindings: $_"
            return $false
        }
    }
}

Initialize-ScapeKeyBindings

Export-ModuleMember -Function 'Initialize-ScapeKeyBindings',
                              'Register-ScapeKeyBinding',
                              'Unregister-ScapeKeyBinding',
                              'Get-ScapeKeyBinding',
                              'Get-ScapeKeyBindings',
                              'Set-ScapeKeyBindingProfile',
                              'Invoke-ScapeChordDetection',
                              'Resolve-ScapeInputToAction',
                              'Set-ScapeKeyBinding',
                              'Export-ScapeKeyBindings',
                              'Import-ScapeKeyBindings'