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

$Script:UnmappedI18N = @(
    "ARCHIVE_BAR_TOTAL",
    "ARCHIVE_COMPLETE",
    "ARCHIVE_ENUMERATING",
    "ARCHIVE_NO_FILES",
    "AUDIT_HASH_COMPUTED",
    "AUDIT_INTEGRITY_MISMATCH",
    "AUDIT_INTEGRITY_VERIFIED",
    "AUDIT_MANIFEST_DEPLOY",
    "AUDIT_MANIFEST_FAIL",
    "AUDIT_REPORT_FAIL",
    "BANNER_TITLE",
    "BOOT_ENV_PARTIAL",
    "BOOT_ESC_ABORT",
    "BOOT_FATAL_INTEROP",
    "BOOT_INIT_MODULES",
    "BOOT_MODULE_FAIL",
    "BOOT_MODULE_LOADED",
    "BOOT_PRIV_ELEVATED",
    "BOOT_PRIV_FAIL",
    "BOOT_READY",
    "BOOT_SAMBA_AUTO",
    "BOOT_SAMBA_FAIL",
    "BOOT_VERIFY_ENV",
    "BOOT_WELCOME",
    "CAP_ALTERNATESCREEN",
    "CAP_BRACKETEDPASTE",
    "CAP_CSIUKEYBOARD",
    "CAP_FALLBACK16",
    "CAP_FALLBACK256",
    "CAP_FOCUSEVENTS",
    "CAP_HYPERLINKS",
    "CAP_KITTYKEYBOARD",
    "CAP_MENU_TITLE",
    "CAP_MOUSETRACKING",
    "CAP_SIXELGRAPHICS",
    "CAP_TRUECOLOR",
    "CARVE_BTRFS_SIG",
    "CARVE_EXT4_SIG",
    "CARVE_NTFS_SIG",
    "CARVE_ZFS_SIG",
    "COMPILER_CHECK_PS2EXE",
    "COMPILER_INSTALL_WIX",
    "COMPILER_MSI_DOWNGRADE",
    "COMPILER_WIX_FALLBACK",
    "COMPILER_WIX_NOT_FOUND",
    "CONFIG_VAL_EFFICIENCY",
    "CONFIG_VAL_REDUNDANCY",
    "CONFIRM_REGEX",
    "CORE_ADMIN_REQUIRED",
    "CORE_BACKUP_PRIV_GRANTED",
    "CORE_BACKUP_PRIV_MISSING",
    "CORE_ENGINE_STOP",
    "CORE_KERNEL_SHIELD_FAIL",
    "CORE_PRESERVATION_ACTIVE",
    "CORE_VALEDICTORY_CLEANUP",
    "CORE_VALEDICTORY_DONE",
    "CORE_VALEDICTORY_ERROR",
    "DASH_HEADER_NODE",
    "DASH_LINE1",
    "DASH_LINE2",
    "DASH_LINE3",
    "DASH_TASK",
    "DB_LOCATION_INFO",
    "DB_MONITOR_STATS",
    "DB_OFFLINE",
    "DB_QUERY_ERROR",
    "DB_QUERY_PROMPT",
    "DB_QUERY_RESULT",
    "DEPLOYER_B64_ARM64_FAIL",
    "DEPLOYER_B64_ARM64_MISSING",
    "DEPLOYER_B64_ARM64_OK",
    "DEPLOYER_B64_BUNDLE_FAIL",
    "DEPLOYER_B64_DOWNLOADING_ARM64",
    "DEPLOYER_B64_DOWNLOADING_BUNDLE",
    "DEPLOYER_B64_DOWNLOADING_X64",
    "DEPLOYER_B64_DOWNLOADING_X86",
    "DEPLOYER_B64_FOUND_FILES",
    "DEPLOYER_B64_MISSING",
    "DEPLOYER_B64_NO_INTEROP",
    "DEPLOYER_B64_NO_INTEROP_X64",
    "DEPLOYER_B64_NO_INTEROP_X86",
    "DEPLOYER_B64_NO_MANAGED",
    "DEPLOYER_B64_PLACEMENT_FAIL",
    "DEPLOYER_B64_SEPARATE_FAIL",
    "DEPLOYER_B64_START",
    "DEPLOYER_B64_SUCCESS",
    "DEPLOYER_CANNOT_REMOVE",
    "DEPLOYER_CORE_FAIL",
    "DEPLOYER_CORE_INJECT",
    "DEPLOYER_CORE_RESTORED",
    "DEPLOYER_DEV_COPY_CORE",
    "DEPLOYER_DEV_MODE_FAILSAFE",
    "DEPLOYER_ERR_DLL_EXTRACT",
    "DEPLOYER_ERR_MSI_FORGE",
    "DEPLOYER_ERR_NO_PAYLOADS",
    "DEPLOYER_ERR_PS2EXE",
    "DEPLOYER_ERR_WIX_DOWNLOAD",
    "DEPLOYER_ERR_WIX_INSTALL",
    "DEPLOYER_EXTRACT_OK",
    "DEPLOYER_GENERATE",
    "DEPLOYER_ICON_ANCHORED",
    "DEPLOYER_LAUNCH_SCAPE",
    "DEPLOYER_LOCATION",
    "DEPLOYER_MATRIX_HEADER",
    "DEPLOYER_NATIVE_RESTORED",
    "DEPLOYER_OPT_DEV",
    "DEPLOYER_OPT_EXE",
    "DEPLOYER_OPT_MSI",
    "DEPLOYER_OPT_SETUP",
    "DEPLOYER_PROCESS_CLEANUP",
    "DEPLOYER_PURGE",
    "DEPLOYER_PURGE_BUSY_WARN",
    "DEPLOYER_PURGE_SUCCESS",
    "DEPLOYER_RETRY_REMOVE",
    "DEPLOYER_RUN_ADMIN",
    "DEPLOYER_VETOR_SELECT",
    "DEP_ARM64_FALLBACK",
    "DEP_BINARIES_MISSING",
    "DEP_EXTRACT_SUCCESS",
    "DEP_LOCAL_DETECTED",
    "DEP_MISSING_ERROR",
    "DEP_SIZE_MISMATCH",
    "IGNITE_DEPLOYER_INJECT",
    "IGNITE_DEPLOY_FAIL",
    "IGNITE_INIT",
    "IGNITE_LOG_FAIL",
    "IGNITE_MATRIX_VALIDATION",
    "IGNITE_MODULE_MAPPED",
    "IGNITE_PILAR_FAIL",
    "IGNITE_PILAR_LOAD",
    "IGNITE_PILAR_MISSING",
    "IO_ALIGNMENT_SHIFT",
    "IO_DASD_HANDLE_CLOSED",
    "IO_DEVICE_NOT_READY",
    "IO_READ_PARTIAL",
    "IO_READ_SUCCESS",
    "IO_RECONNECT_FAIL",
    "IO_RECONNECT_SUCCESS",
    "IO_RESILIENT_MISSING",
    "LAB_BLOCK_SKIP",
    "LAB_HEADER_MISMATCH",
    "LAB_MAGIC_FIXED",
    "LAB_START",
    "LAB_SUCCESS",
    "LAB_SURGERY_CRITICAL",
    "NET_LATENCY_WARN",
    "NET_MAP_ABORT",
    "NET_MAP_AUTH",
    "NET_MAP_AUTH_PROMPT",
    "NET_MAP_DENIED",
    "NET_MAP_OK",
    "NET_MGR_AUTO_MOUNT",
    "NET_MGR_BACK",
    "NET_MGR_MOUNT_SUCCESS",
    "NET_MGR_UNMOUNT",
    "NET_MGR_UNMOUNT_ALL",
    "NET_MGR_UNMOUNT_DISP",
    "NET_MGR_UNMOUNT_REGEX",
    "NET_NATIVE_ISOLATION_OK",
    "NET_NATIVE_JOURNAL_START",
    "NET_PACKET_DROP",
    "NET_RADAR_ADDRESS",
    "NET_RADAR_FOUND",
    "NET_RADAR_FOUND_COUNT",
    "NET_RADAR_GATEWAY_OK",
    "NET_RADAR_IGNORED",
    "NET_RADAR_LOCATED",
    "NET_RADAR_NONE_COUNT",
    "NET_RADAR_PROMPT",
    "NET_RADAR_SCAN_DETAIL",
    "NET_RADAR_SWEEPING",
    "NET_RADAR_TESTING",
    "NET_RADAR_VALID",
    "NET_SMB_TIMEOUT",
    "NET_SYNC_FAIL",
    "RC_ARCHIVE_MODE_INFO",
    "RC_AUTOSENSE",
    "RC_BATCH_PROCESSING",
    "RC_BITWISE_TAGGING",
    "RC_BLOCKED_SPACE",
    "RC_BTN_CANCEL",
    "RC_BTN_EDIT_DESC",
    "RC_BTN_PREPARE_FLAGS",
    "RC_BTN_PREPARE_FLAGS_DESC",
    "RC_BTN_START",
    "RC_CACHE_ADVISORY",
    "RC_CALCULATING_SIZE",
    "RC_CANCEL",
    "RC_CLOUD_SYNC",
    "RC_DEFAULTS_TITLE",
    "RC_DEL_RTN",
    "RC_DEST_LABEL",
    "RC_ENV_GUIDE",
    "RC_EXIT_CODE_INFO",
    "RC_FILE_LABORATORY",
    "RC_FLAG_B",
    "RC_FLAG_B_DESC",
    "RC_FLAG_COPYALL",
    "RC_FLAG_DCOPY_T",
    "RC_FLAG_E",
    "RC_FLAG_E_DESC",
    "RC_FLAG_FFT",
    "RC_FLAG_FFT_DESC",
    "RC_FLAG_L",
    "RC_FLAG_L_DESC",
    "RC_FLAG_M",
    "RC_FLAG_MT",
    "RC_FLAG_MT_DESC",
    "RC_FLAG_M_DESC",
    "RC_FLAG_NP",
    "RC_FLAG_NP_DESC",
    "RC_FLAG_V",
    "RC_FLAG_V_DESC",
    "RC_FLAG_XJ",
    "RC_FLAG_XJ_DESC",
    "RC_FLAG_XN",
    "RC_FLAG_XN_DESC",
    "RC_FLAG_XO",
    "RC_FLAG_XO_DESC",
    "RC_FLAG_ZB",
    "RC_FLAG_ZB_DESC",
    "RC_FORENSIC_TOOLS",
    "RC_HW_WEAR_LONG",
    "RC_INVALID_MT",
    "RC_LOG_SAVED",
    "RC_RETRY_R",
    "RC_RETRY_R_DESC",
    "RC_RETRY_W",
    "RC_RETRY_W_DESC",
    "RC_ROBOCOPY_ENGINE",
    "RC_ROBOCOPY_NOT_FOUND",
    "RC_SAVE_RETURN",
    "RC_SPACE_CHECK",
    "RC_SPACE_LOW_CONFIRM",
    "RC_STAGING_LABEL",
    "RC_START_SYNC",
    "RC_SYNC_RUNNING",
    "RC_TAGGING_DONE",
    "RC_TAGGING_START",
    "RC_TARGET_ARCHAEOLOGY",
    "RC_TELEMETRY_SCAN",
    "RC_TITLE",
    "RC_TOPOLOGY_SCAN",
    "RC_WAIT_RETRY",
    "SAMBA_MGR_NONE",
    "SAMBA_MGR_REMOVED",
    "SAMBA_MGR_REMOVE_ALL",
    "SAMBA_MGR_TITLE",
    "SAMBA_SELECT_IP",
    "SAMBA_UNMOUNT_ALL",
    "SAMBA_UNMOUNT_SINGLE",
    "SQLITE_CONNECTION_BUSY",
    "SQLITE_DB_FAIL",
    "SQLITE_DB_INIT",
    "SQLITE_ENGINE_FAIL",
    "SQLITE_ENGINE_LOADED",
    "SQLITE_INTEGRITY_CHECK",
    "SQLITE_MEMORY_SPILL",
    "SQLITE_WAL_CHECKPOINT",
    "TOOL_AUTORUNS",
    "TOOL_CHKDSK_DESC",
    "TOOL_DISKPART_DESC",
    "TOOL_EVERYTHING",
    "TOOL_FSUTIL_DESC",
    "TOOL_NATIVE_FORENSICS",
    "TOOL_PROCEXP",
    "TOOL_STORDIAG",
    "TOOL_STORDIAG_DESC",
    "TOOL_THIRDPARTY_FORENSICS",
    "TOOL_WINDIRSTAT",
    "TOOL_WINFR_DESC",
) | ForEach-Object { Get-ScapeI18NNode -Key $_ }

