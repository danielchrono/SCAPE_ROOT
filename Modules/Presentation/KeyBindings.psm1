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

function Initialize-ScapeKeyBinding {
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

        Import-ScapeKeyBinding | Out-Null
    }
}

function Register-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$KeySequence,
        [Parameter(Mandatory = $true)][string]$ActionName,
        [string]$DftProfile = "Default",
        [scriptblock]$Callback,
        [switch]$Chord
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

        $key = $KeySequence
        if ($Chord) { $key = "CHORD:$KeySequence" }

        $binding = @{
            Sequence     = $KeySequence
            Action       = $ActionName
            Callback     = $Callback
            IsChord      = $Chord.IsPresent
            Profile      = $DftProfile
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
        [string]$DftProfile = "Default"
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { return $false }

        if ($Script:KeyBindingRegistry.ContainsKey($KeySequence)) {
            $Script:KeyBindingRegistry.Remove($KeySequence) | Out-Null
        }

        if ($Script:KeyBindingProfiles.ContainsKey($DftProfile)) {
            $Script:KeyBindingProfiles[$DftProfile].Remove($KeySequence) | Out-Null
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
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

        $key = $KeySequence
        if ($Chord) { $key = "CHORD:$KeySequence" }

        if ($Script:KeyBindingRegistry.ContainsKey($key)) {
            return $Script:KeyBindingRegistry[$key]
        }
        return $null
    }
}

function Get-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([array])]
    param([string]$DftProfile = "Default")
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

        if ($null -ne $DftProfile -and $Script:KeyBindingProfiles.ContainsKey($DftProfile)) {
            return @($Script:KeyBindingProfiles[$DftProfile].Values)
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
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

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
            if ((Test-ScapeKeyAvailable)) {
                $key = (Read-ScapeRawKey)
                $keyName = if ($key.Key -eq [ConsoleKey]::Enter) { 'Enter' } else { $key.KeyChar }
                $Script:ChordBuffer += $keyName
            }
            else {
                [System.Threading.Thread]::Sleep(10)
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
        [string]$DftProfile
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

        $prof = if ([string]::IsNullOrWhiteSpace($DftProfile)) { $Script:ActiveProfile } else { $DftProfile }
        [void]$prof

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
        [string]$DftProfile = "Default"
    )
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

        $existing = $Script:KeyBindingRegistry.Values | Where-Object { $_.Action -eq $ActionName }

        foreach ($binding in $existing) {
            Unregister-ScapeKeyBinding -KeySequence $binding.Sequence -Profile $DftProfile | Out-Null
        }

        return Register-ScapeKeyBinding -KeySequence $NewKeySequence -ActionName $ActionName -Profile $DftProfile
    }
}

function Export-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([bool])]
    param([string]$Path)
    process {
        if ($null -eq $Script:KeyBindingRegistry) { Initialize-ScapeKeyBinding }

        $configPath = if ([string]::IsNullOrWhiteSpace($Path)) {
            Join-Path -Path (Get-ScapeConstant -Path "project::home") -ChildPath ".scape/keybindings.json"
        }
        else {
            $Path
        }

        $dir = Split-Path -Parent $configPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

        $exportData = @{
            Profiles      = @{}
            ActiveProfile = $Script:ActiveProfile
        }

        foreach ($prof in $Script:KeyBindingProfiles.Keys) {
            $exportData.Profiles[$prof] = @()
            foreach ($binding in $Script:KeyBindingProfiles[$prof].Values) {
                $exportData.Profiles[$prof] += @{
                    Sequence = $binding.Sequence
                    Action   = $binding.Action
                    IsChord  = $binding.IsChord
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

function Import-ScapeKeyBinding {
    [CmdletBinding()]
    [OutputType([bool])]
    param([string]$Path)
    process {
        $configPath = if ([string]::IsNullOrWhiteSpace($Path)) {
            Join-Path -Path (Get-ScapeConstant -Path "project::home" -Fallback $env:USERPROFILE) -ChildPath ".scape/keybindings.json"
        }
        else {
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

Initialize-ScapeKeyBinding

function Invoke-ScapeKeyBindingAction {
    [CmdletBinding()]
    param([string]$Task, [hashtable]$PayloadDef, [string]$Target)

    $initText = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_INIT"
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $initText -StatusFlag "INFO"

    if (-not (Get-Command Initialize-ScapeKeyBinding -ErrorAction SilentlyContinue)) {
        $noModuleText = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_NO_MODULE"
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $noModuleText -StatusFlag "Failure"
        throw "KeyBindings module not available"
    }

    Initialize-ScapeKeyBinding | Out-Null

    if ($Task -eq 'REBIND_INTERACTIVE') {
        $actions = @('UP', 'DOWN', 'LEFT', 'RIGHT', 'SELECT', 'BACK')

        Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
            ScreenId = "KeyBindingsScreen"
            TitleKey = "KEYBINDINGS_CONFIG"
            Rows     = @(
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "KEYBINDINGS_MODE"); RightText = (Invoke-ScapeI18NFormat -Key "KEYBINDINGS_INTERACTIVE"); Flag = "Info"; RightFlag = "Info" }
                @{ LeftText = (Invoke-ScapeI18NFormat -Key "KEYBINDINGS_STATUS"); RightText = (Invoke-ScapeI18NFormat -Key "KEYBINDINGS_PRESS_KEY"); Flag = "Hint"; RightFlag = "Hint" }
            )
        }

        foreach ($action in $actions) {
            $currentBinding = Get-ScapeKeyBinding | Where-Object { $_.Action -eq $action } | Select-Object -First 1
            $currentSeq = if ($currentBinding) { $currentBinding.Sequence } else { "UNBOUND" }

            Publish-ScapeEvent -Type "ACTION_SCREEN_UPDATE" -Severity "INFO" -Payload @{
                Row = @{ LeftText = ((Invoke-ScapeI18NFormat -Key "KEYBINDINGS_ACTION") + " [$action]"); RightText = $currentSeq; Flag = "Hint"; RightFlag = "Info" }
            }
        }

        $readyText = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_READY"
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $readyText -StatusFlag "Success"

    }
    elseif ($Task -eq 'LOAD_PROFILE') {
        $TargetProfile = $PayloadDef['Profile']
        if ($null -ne $TargetProfile) {
            Set-ScapeKeyBindingProfile -ProfileName $TargetProfile | Out-Null
            $profLoaded = (Invoke-ScapeI18NFormat -Key "KEYBINDINGS_PROF_LOADED") -f "[$TargetProfile]"
            Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $profLoaded -StatusFlag "Success"
        }
        else {
            $noProf = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_NO_PROFILE"
            Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $noProf -StatusFlag "Failure"
        }
    }
    elseif ($Task -eq 'SAVE_BINDINGS') {
        $result = Export-ScapeKeyBinding
        if ($result) {
            $savedText = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_SAVED"
            Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $savedText -StatusFlag "Success"
        }
        else {
            $failedText = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_FAILED"
            Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $failedText -StatusFlag "Failure"
        }
    }
    else {
        $sysReadyText = Invoke-ScapeI18NFormat -Key "KEYBINDINGS_SYS_READY"
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText $sysReadyText -StatusFlag "Success"
    }
}

Export-ModuleMember -Function 'Initialize-ScapeKeyBinding',
'Import-ScapeKeyBindingss',
'Export-ScapeKeyBindingss',
'Get-ScapeKeyBindingss',
'Initialize-ScapeKeyBindingss',
'Register-ScapeKeyBinding',
'Unregister-ScapeKeyBinding',
'Get-ScapeKeyBinding',
'Get-ScapeKeyBinding',
'Set-ScapeKeyBindingProfile',
'Invoke-ScapeChordDetection',
'Resolve-ScapeInputToAction',
'Set-ScapeKeyBinding',
'Export-ScapeKeyBinding',
'Import-ScapeKeyBinding',
'Invoke-ScapeKeyBindingAction'
