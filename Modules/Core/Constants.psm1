<#
.SYNOPSIS
    Domain: Core
    Module: Scape.Core.Constants
    Description: Pure constant resolver. PASSIVE MODE. Strict-Safe.
#>

function Initialize-ScapeIconLevel {
    # System enforces UTF-8. Safe to assume Level 0.
    Get-ScapeDefaultIconLevel
}

function Get-ScapeDefaultIconLevel {
    [CmdletBinding()]
    param()
    process {
        return 0
    }
}

$Script:ConstantsCache = $null

function Get-ScapeConstant {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path, $Fallback = $null)
    process {
        if ($null -eq $Script:ConstantsCache) {
            $state = Get-ScapeColdState
            if (-not $state.Assets) { return $Path }
            $Script:ConstantsCache = $state.Assets
        }
        $assets = $Script:ConstantsCache

        $parts = $Path -split "::"
        $root = $parts[0]
        $asset = $null

        foreach ($cat in $assets.Keys) {
            $foundKey = $assets[$cat].Keys | Where-Object { $_ -ieq $root } | Select-Object -First 1
            if ($foundKey) {
                $asset = $assets[$cat][$foundKey]
                break
            }
        }
        if ($null -eq $asset) { return $Fallback }

        # Navegação robusta em profundidade (Hashtables e PSObjects)
        $current = $asset
        for ($i = 1; $i -lt $parts.Count; $i++) {
            $key = $parts[$i]
            $next = $null

            if ($current -is [System.Collections.IDictionary]) {
                $match = $current.Keys | Where-Object { $_ -ieq $key } | Select-Object -First 1
                if ($match) { $next = $current[$match] }
            }
            elseif ($null -ne $current.PSObject) {
                $match = $current.PSObject.Properties | Where-Object { $_.Name -ieq $key } | Select-Object -First 1
                if ($match) { $next = $match.Value }
            }

            if ($null -eq $next) { return $Fallback }
            $current = $next
        }
        return $current
    }
}

Initialize-ScapeIconLevel

# --- INJECTED I18N KEYS ---
# ERR_ADMIN_REQUIRED
# ERR_BOOT_SECTOR_READ
# ERR_DEPENDENCY_FAIL
# ERR_DISK_FULL
# ERR_DRIVE_LETTERS_EXHAUSTED
# ERR_INTEGRITY_CHECK
# ERR_NO_ITEMS_SELECTED
# ERR_NO_STAGING
# ERR_PATH_INVALID
# ERR_SUPERBLOCK_READ
# ERR_SYSTEM_DRIVE_LOCK
# MISC_ABORT_PROMPT
# MISC_ACCEPT_RISK
# MISC_CANCELLED
# MISC_DOWNLOAD_RETRY
# MISC_ENTER_PATH_MANUALLY
# MISC_EXIT_CONFIRM
# MISC_LOG_AND_CONTINUE
# MISC_NO
# MISC_OPERATION_FAILED
# MISC_OPERATION_SUCCESS
# MISC_OR
# MISC_PRESS_ENTER
# MISC_PRESS_ENTER_CONTINUE
# MISC_PRESS_ENTER_DEGRADED
# MISC_PRESS_ENTER_EXIT
# MISC_PRESS_ENTER_TERMINAL
# MISC_PROGRESS
# MISC_RESTART_STATE_MACHINE
# MISC_WAITING
# MISC_YES
# MISC_YES_NO
# MISC_YES_NO_UPPER


# --- INJECTED I18N KEYS ---
# ERR_ADMIN_REQUIRED
# ERR_BOOT_SECTOR_READ
# ERR_DEPENDENCY_FAIL
# ERR_DISK_FULL
# ERR_DRIVE_LETTERS_EXHAUSTED
# ERR_INTEGRITY_CHECK
# ERR_NO_ITEMS_SELECTED
# ERR_NO_STAGING
# ERR_PATH_INVALID
# ERR_SUPERBLOCK_READ
# ERR_SYSTEM_DRIVE_LOCK
# MISC_ABORT_PROMPT
# MISC_ACCEPT_RISK
# MISC_CANCELLED
# MISC_DOWNLOAD_RETRY
# MISC_ENTER_PATH_MANUALLY
# MISC_EXIT_CONFIRM
# MISC_LOG_AND_CONTINUE
# MISC_NO
# MISC_OPERATION_FAILED
# MISC_OPERATION_SUCCESS
# MISC_OR
# MISC_PRESS_ENTER
# MISC_PRESS_ENTER_CONTINUE
# MISC_PRESS_ENTER_DEGRADED
# MISC_PRESS_ENTER_EXIT
# MISC_PRESS_ENTER_TERMINAL
# MISC_PROGRESS
# MISC_RESTART_STATE_MACHINE
# MISC_WAITING
# MISC_YES
# MISC_YES_NO
# MISC_YES_NO_UPPER
