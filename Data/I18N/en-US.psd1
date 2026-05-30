@{
    # ─────────────────────────────────────────────────────────────────────
    # CORE ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "CORE_ENGINE_START"               = @{ T = 'SCAPE Recovery Engine Boot Sequence Initiated. Allocating core resources...'; H = 'Engine initialization message'; F = 'SYSTEM' }
    "CORE_ENGINE_STOP"                = @{ T = 'SCAPE Engine Offline. Valedictory sequence and memory purge completed.'; H = 'Engine shutdown confirmation'; F = 'SYSTEM' }
    "CORE_KERNEL_SHIELD_ACTIVE"       = @{ T = 'SHIELD_STABLE: NT_IO_PRIORITY_HIGH engaged. Execution threads elevated.'; H = 'Kernel priority elevation success'; F = 'KERNEL' }
    "CORE_KERNEL_SHIELD_FAIL"         = @{ T = 'SHIELD_FAIL: Unable to elevate process priority. {0}'; H = 'Kernel priority elevation failure with error token'; F = 'KERNEL_ERR' }
    "CORE_VALEDICTORY_CLEANUP"        = @{ T = 'Executing Valedictory Cleanup: Releasing handles and flushing buffers...'; H = 'Graceful shutdown cleanup phase'; F = 'KERNEL' }
    "CORE_VALEDICTORY_DONE"           = @{ T = 'Valedictory cleanup complete. Engine processes suspended safely.'; H = 'Cleanup completion confirmation'; F = 'SYSTEM' }
    "CORE_VALEDICTORY_ERROR"          = @{ T = 'Critical failure during Valedictory cleanup phase: {0}'; H = 'Cleanup phase error with token'; F = 'ERR' }
    "CORE_ADMIN_REQUIRED"             = @{ T = 'Administrator privileges are strictly required for raw DASD access. Please restart the host process with elevated rights.'; H = 'Elevation requirement for DASD access'; F = 'PRIVILEGE_FATAL' }
    "CORE_BACKUP_PRIV_GRANTED"        = @{ T = 'Privilege Escalation Successful: SeBackupPrivilege and SeRestorePrivilege are active.'; H = 'Backup privileges successfully elevated'; F = 'SANCTUARY' }
    "CORE_BACKUP_PRIV_MISSING"        = @{ T = 'Backup privileges not fully enabled. NTFS ACL bypass capabilities may be heavily restricted during extraction.'; H = 'Partial privilege escalation warning'; F = 'SANCTUARY_WARN' }
    "CORE_PRESERVATION_ACTIVE"        = @{ T = 'PRESERVATION MODE ACTIVE - COOLING DOWN'; H = 'Preservation mode status indicator'; F = 'STATUS' }
    "CORE_INTEROP_FAIL"               = @{ T = 'Core.Interop not available. Native bridge unavailable.'; H = 'Core interop module missing error'; F = 'INTEROP_ERR' }

    # ─────────────────────────────────────────────────────────────────────
    # ACTION MANAGER
    # ─────────────────────────────────────────────────────────────────────
    "CORE_ACTION_STATUS"              = @{ T = 'Status'; H = 'Action status label'; F = 'HINT' }
    "CORE_ACTION_SYSTEM_TASK"         = @{ T = 'System Task'; H = 'Fallback target display for system-level tasks'; F = 'HINT' }
    "CORE_ACTION_DEFAULT"             = @{ T = 'Processing...'; H = 'Fallback task name'; F = 'HINT' }
    "CORE_ACTION_TARGET_MODULE"       = @{ T = 'Target Module'; H = 'Action panel left label for target'; F = 'HINT' }
    "CORE_ACTION_ACTIVE_TASK"         = @{ T = 'Active Task'; H = 'Action panel left label for task'; F = 'HINT' }
    "CORE_ACTION_INITIALIZING"        = @{ T = 'Initializing...'; H = 'Action initialization phase status text'; F = 'STATUS' }
    "CORE_ACTION_COMPLETED"           = @{ T = 'Completed'; H = 'Action completed status text'; F = 'SUCCESS' }
    "CORE_ACTION_FAILED"              = @{ T = 'Failed'; H = 'Action failure status text'; F = 'ERR' }

    # ─────────────────────────────────────────────────────────────────────
    # SETTINGS ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "SETTINGS_ENGINE_ONLINE"          = @{ T = 'Settings Engine online. Synchronizing overrides...'; H = 'Engine initialization message'; F = 'SYSTEM' }
    "SETTINGS_MUTATE_UNKNOWN"         = @{ T = 'Attempted to mutate unknown setting key: {0}'; H = 'Mutation error for unknown key'; F = 'WARN' }
    "SETTINGS_IO_FAULT"               = @{ T = 'I/O fault: Key {0} applied in RAM but failed to persist to disk.'; H = 'Persistence failure in JSON file'; F = 'ERROR' }
    "SETTINGS_MUTATE_SUCCESS"         = @{ T = 'Setting [{0}] successfully mutated to [{1}].'; H = 'Mutation success notification'; F = 'SYSTEM' }
    "SETTINGS_RESET_DEFAULTS"         = @{ T = 'Reset to Factory Defaults'; H = 'Option to reset all settings to defaults'; F = 'UI' }
    "SETTINGS_RESET_SUCCESS"          = @{ T = 'All settings restored to engine factory defaults (.psd1).'; H = 'Factory reset confirmation'; F = 'SYSTEM' }

    # ─────────────────────────────────────────────────────────────────────
    # MAIN MENU
    # ─────────────────────────────────────────────────────────────────────
    "MENU_MAIN_TITLE"                 = @{ T = 'SYSTEM SETTINGS & ENVIRONMENT CONFIGURATION'; H = 'Main menu header title'; F = $null }
    "MENU_MAIN_TARGET"                = @{ T = 'SELECT TARGET DRIVE/IMAGE'; H = 'Main menu target selection'; F = $null }
    "TREE_DEFAULT_TITLE"              = @{ T = 'FILE SYSTEM TREE'; H = 'Default title for tree view'; F = $null }
    "ERR_NOT_IMPLEMENTED"             = @{ T = 'Not Implemented'; H = 'Error for unimplemented feature'; F = 'ERR' }
    "MENU_MAIN_SCAN"                  = @{ T = 'FULL SCAN & INVENTORY TOPOLOGY'; H = 'Hardware audit and disk topology inventory.'; F = '1' }
    "MENU_MAIN_PARSING"               = @{ T = 'TARGETED RECOVERY (Plan A - MFT/Inode)'; H = 'Deterministic MFT/Inode record recovery.'; F = '2' }
    "MENU_MAIN_ARCHAEOLOGY"           = @{ T = 'ARCHAEOLOGY MODE (Plan B - Raw Carving)'; H = 'Deep hexadecimal signature carving (Plan B).'; F = '3' }
    "MENU_MAIN_HARVESTER"             = @{ T = 'HARVESTER BATCH EXTRACTION'; H = 'Bulk extraction of discovered files.'; F = '4' }
    "MENU_MAIN_FORENSICS"             = @{ T = 'FORENSIC DIAGNOSTICS & CLI TOOLS'; H = 'Access native forensic CLI utilities'; F = '5' }
    "MENU_MAIN_SETTINGS"              = @{ T = 'SYSTEM SETTINGS & CONFIGURATION'; H = 'Adjust system engine and interface parameters.'; F = '6' }
    "MENU_MAIN_LOGISTICS"             = @{ T = 'LOGISTICS & CLOUD SYNC'; H = 'Robocopy cloud synchronization engine.'; F = '7' }
    "MENU_MAIN_LAB"                   = @{ T = 'SCAPE LABORATORY (File Repair)'; H = 'Hexadecimal magic repair and block-skip surgery.'; F = '8' }
    "MENU_MAIN_EXIT"                  = @{ T = 'TERMINATE SCAPE ENGINE'; H = 'Quit Scape Engine'; F = 'Q' }

    "MENU_OPTION_ENGINE_MODE"         = @{ T = 'ENGINE MODE (Efficiency vs Redundancy)'; H = 'Toggles parsing mode between EFFICIENCY (Fast/Strict) and REDUNDANCY (Deep/Fallback).'; F = '1' }
    "MENU_OPTION_DEFAULT_OUT"         = @{ T = 'DEFAULT OUTPUT DIRECTORY'; H = 'Defines the global physical staging directory for extractions.'; F = '2' }
    "MENU_OPTION_NETWORK_MGR"         = @{ T = 'NETWORK OPTIONS'; H = 'Manage active SMB/CIFS network mounts and credentials.'; F = '3' }
    "MENU_OPTION_ROBOCOPY"            = @{ T = 'ROBOCOPY DEFAULTS & CLOUD SYNC CONFIG'; H = 'Advanced synchronization flags for the Robocopy Cloud engine.'; F = '4' }
    "MENU_OPTION_LANGUAGE"            = @{ T = 'INTERFACE LANGUAGE'; H = 'Switches the global SCAPE UI language.'; F = '5' }
    "MENU_SETTINGS_THEME"             = @{ T = 'THEME OPTIONS'; H = 'Configure the visual theme of the interface.'; F = '6' }
    "MENU_OPTION_RETURN"              = @{ T = 'RETURN TO PREVIOUS MENU'; H = 'Return to previous menu level'; F = 'R' }
    "MENU_OPTION_AUTODETECT"          = @{ T = 'AUTO-DETECT & MOUNT SAMBA VAULT'; H = 'Auto-discover and mount network Samba shares'; F = 'S' }

    "MENU_MAESTRO_PROMPT"             = @{ T = 'Awaiting operational command directive'; H = 'Maestro routine status prompt'; F = 'MAESTRO_ROUTINE' }
    "MENU_INPUT_PROMPT"               = @{ T = 'INPUT'; H = 'Input field label'; F = $null }
    "MENU_VALUE_NOT_SET"              = @{ T = 'NOT CONFIGURED'; H = 'Configuration value unset indicator'; F = $null }
    "MENU_VALUE_ENABLED"              = @{ T = 'ENABLED ACTIVE'; H = 'Feature enabled status indicator'; F = $null }
    "MENU_VALUE_DISABLED"             = @{ T = 'DISABLED INACTIVE'; H = 'Feature disabled status indicator'; F = $null }
    "MENU_CHOICE_INVALID"             = @{ T = 'Unrecognized command parameter. Please provide a valid index.'; H = 'Invalid menu selection error'; F = 'INPUT_ERR' }
    "MENU_LANGUAGE_SWITCH"            = @{ T = 'Global language dictionary switched to {0}. Interface components updated.'; H = 'Language change confirmation with locale token'; F = 'UI' }
    "MENU_OPTION_ICON_LEVEL"          = @{ T = 'ICON LEVEL (Graphic/Unicode/ASCII)'; H = 'Switch between graphic, solid unicode, or ASCII icons'; F = '1' }
    "MENU_OPTION_FRAME_STYLE"         = @{ T = 'FRAME STYLE (Box drawing style)'; H = 'Change the border style of menus'; F = '2' }
    "MENU_OPTION_PROGRESS_STYLE"      = @{ T = 'PROGRESS STYLE (Bar/Spinner)'; H = 'Select progress bar or spinner style'; F = '3' }
    "MENU_OPTION_THEME_PERSONA"       = @{ T = 'THEME PERSONA (Color palette)'; H = 'Apply a complete color persona'; F = '4' }
    "MENU_OPTION_COLOR_MODE"          = @{ T = 'COLOR MODE (TrueColor/ANSI16)'; H = 'Toggle between 24-bit true color and ANSI 16-color fallback'; F = '5' }
    "MENU_RANDOM_THEME"               = @{ T = 'NEW RANDOM THEME (DYNAMIC RGB)'; H = 'Applies a new algorithmically generated color palette.'; F = '6' }
    "THEME_APPLIED"                   = @{ T = 'Quantum UI theme applied successfully. Base RGB: {0}'; H = 'Theme application success with RGB token'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # DRIVE ACTIONS MENU
    # ─────────────────────────────────────────────────────────────────────
    "MENU_DRIVE_TARGET_LABEL"         = @{ T = '>> SELECTED TARGET: {0}'; H = 'Selected drive label with device token'; F = $null }
    "MENU_DRIVE_OPT_TARGETED"         = @{ T = 'Targeted Recovery (SCAPE Plan A)'; H = 'Extract specific paths bypassing Windows APIs.'; F = '1' }
    "MENU_DRIVE_OPT_ARCHAEOLOGY"      = @{ T = 'Archaeology Mode (SCAPE Plan B)'; H = 'Deep raw sector carving for lost signatures.'; F = '2' }
    "MENU_DRIVE_OPT_ISOLATE"          = @{ T = 'Isolate Drive (Diskpart - Offline Mode)'; H = 'Force offline state to prevent OS tampering.'; F = '3' }
    "MENU_DRIVE_OPT_JOURNAL"          = @{ T = 'Journal Harvest (Fsutil - Recent Deletions)'; H = 'Extract recent deletions via USN Journal.'; F = '4' }
    "MENU_DRIVE_OPT_HYBRID"           = @{ T = 'Hybrid Recovery (WinFR + SCAPE)'; H = 'Dual-engine scan leveraging Windows File Recovery.'; F = '5' }
    "MENU_DRIVE_OPT_RETURN"           = @{ T = 'Return'; H = 'Return to previous menu.'; F = 'R' }

    # ─────────────────────────────────────────────────────────────────────
    # PIPELINE / COMPLIANCE
    # ─────────────────────────────────────────────────────────────────────
    "TUI_PREFLIGHT"                   = @{ T = 'Initiating {0} diagnostic and isolation sequence...'; H = 'Pre-flight diagnostic start with tool token'; F = 'PRE-FLIGHT' }
    "TUI_EXECUTION"                   = @{ T = '{0} engine active. Processing I/O streams.'; H = 'Execution phase status with engine token'; F = 'EXECUTION' }
    "TUI_POSTFLIGHT"                  = @{ T = '{0} operational sequence finalized.'; H = 'Post-flight completion with tool token'; F = 'POST-FLIGHT' }
    "TUI_CHKDSK"                      = @{ T = 'File System Integrity Verification (Chkdsk)'; H = 'Chkdsk tool display name'; F = $null }
    "TUI_STORDIAG"                    = @{ T = 'Hardware Telemetry Diagnostic (Stordiag)'; H = 'Stordiag tool display name'; F = $null }
    "TUI_FSUTIL"                      = @{ T = 'NTFS USN Journal Harvest'; H = 'Fsutil tool display name'; F = $null }
    "TUI_ROBOCOPY"                    = @{ T = 'Robocopy Cloud Sync Engine'; H = 'Robocopy tool display name'; F = $null }
    "TUI_DISKPART"                    = @{ T = 'Diskpart Isolation Engine'; H = 'Diskpart tool display name'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # NATIVE & THIRD-PARTY TOOL ACTIONS
    # ─────────────────────────────────────────────────────────────────────
    "ACTION_TOOL_LAUNCH"              = @{ T = 'Launching {0}...'; H = 'Tool launch status with tool name token'; F = 'EXEC' }
    "ACTION_TOOL_COMPLETE"            = @{ T = '{0} completed.'; H = 'Tool completion with tool name token'; F = 'SUCCESS' }
    "ACTION_TOOL_SUCCESS"             = @{ T = '{0} finished successfully.'; H = 'Tool success with tool name token'; F = 'SUCCESS' }
    "ACTION_TOOL_FAIL"                = @{ T = '{0} failed'; H = 'Tool failure with tool name token'; F = 'ERR' }
    "ACTION_TOOL_MISSING"             = @{ T = '{0} ({1}) not found in PATH.'; H = 'Missing tool with name/command tokens'; F = 'TOOL_WARN' }
    "ACTION_TOOL_MISSING_HINT"        = @{ T = 'Install it via winget, choco, or place the binary in PATH.'; H = 'Missing tool installation hint'; F = 'HINT' }
    "ACTION_TOOL_PACKAGER"            = @{ T = 'Packaging {0} via auto-installer...'; H = 'Packager launch with tool name token'; F = 'EXEC' }
    "ACTION_PACKAGER_SUCCESS"         = @{ T = '{0} installed successfully via packager.'; H = 'Packager success with tool name token'; F = 'SUCCESS' }
    "ACTION_PACKAGER_FAIL"            = @{ T = 'Packager failed to install {0}.'; H = 'Packager failure with tool name token'; F = 'ERR' }
    "ACTION_FILEHASH_WARN"            = @{ T = 'Hash computed via PowerShell Get-FileHash (non-forensic mode).'; H = 'Get-FileHash warning about non-forensic mode'; F = 'WARN' }
    "TOOL_ERROR_LBL"                  = @{ T = 'Error'; H = 'Generic error row left label for tool panels'; F = 'ERR' }

    "LAB_START"                       = @{ T = 'Initiating binary analysis on: {0}'; H = 'Lab analysis start with file token'; F = 'LAB' }
    "LAB_MAGIC_FIXED"                 = @{ T = 'Hex signature restored. Type: {0}'; H = 'Magic byte repair confirmation with type token'; F = 'LAB' }
    "LAB_SUCCESS"                     = @{ T = 'Object reconstructed successfully at: {0}'; H = 'Reconstruction success with path token'; F = 'LAB' }
    "LAB_SURGERY_CRITICAL"            = @{ T = 'Target object is 100% Zero-Filled (Null). Binary reconstruction is mathematically impossible.'; H = 'Critical unrecoverable data state'; F = 'LAB_FATAL' }
    "LAB_HEADER_MISMATCH"             = @{ T = 'Magic bytes mismatch detected. Expected {0}, Hex Found {1}.'; H = 'Header validation failure with expected/found tokens'; F = 'LAB_WARN' }
    "LAB_BLOCK_SKIP"                  = @{ T = 'Unreadable sector at block offset {0}. Injecting 64KB zero-fill sequence and jumping to next cluster.'; H = 'Bad sector handling with offset token'; F = 'LAB_IO' }

    "UI_DIRTY_DISCARD"                = @{ T = 'Unsaved configuration changes detected in the volatile matrix. Discard and return? (y/N): '; H = 'Unsaved changes confirmation prompt'; F = 'STATE_WARN' }
    "UI_LOCKDOWN_ACTIVE"              = @{ T = 'Operation locked by the orchestrator due to environment constraints.'; H = 'Environment restriction notice'; F = 'RESTRICTED' }
    "UI_CONFIRM_PROCEED"              = @{ T = 'ACCEPT RISK & PROCEED'; H = 'Confirmation button text for risky operations'; F = $null }
    "UI_CONFIRM_ABORT"                = @{ T = 'ABORT OPERATION'; H = 'Abort button text for cancellation'; F = $null }

    "SYNC_SUSPEND"                    = @{ T = 'Suspending asynchronous LiveMonitor to prevent COM/Handle collisions.'; H = 'Sync suspension notice for resource safety'; F = 'SYNC' }
    "SYNC_RESUME"                     = @{ T = 'Synchronous lock released. Resuming LiveMonitor thread.'; H = 'Sync resumption notice'; F = 'SYNC' }

    # ─────────────────────────────────────────────────────────────────────
    # STATUS ENUMERATIONS
    # ─────────────────────────────────────────────────────────────────────
    "STATUS_DISCOVERED"               = @{ T = 'DISCOVERED_PARSED'; H = 'File discovered via metadata parsing'; F = $null }
    "STATUS_DISCOVERED_RAW"           = @{ T = 'DISCOVERED_CARVED'; H = 'File discovered via raw carving'; F = $null }
    "STATUS_EXTRACTED"                = @{ T = 'SUCCESSFULLY_EXTRACTED'; H = 'File extraction completed successfully'; F = $null }
    "STATUS_PARTIAL_CORRUPT"          = @{ T = 'EXTRACTED_PARTIAL_CORRUPTION'; H = 'File extracted with partial corruption'; F = $null }
    "STATUS_ORPHAN"                   = @{ T = 'ORPHANED_BLOCK'; H = 'Orphaned data block without metadata'; F = $null }
    "STATUS_FAILED"                   = @{ T = 'EXTRACTION_FAILED'; H = 'File extraction failed'; F = $null }
    "STATUS_READY"                    = @{ T = 'TARGET_READY'; H = 'Target device ready for operations'; F = $null }
    "STATUS_PROCESSING"               = @{ T = 'ACTIVE_PROCESSING'; H = 'Operation currently in progress'; F = $null }
    "STATUS_VERIFIED"                 = @{ T = 'INTEGRITY_VERIFIED'; H = 'Data integrity verification passed'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # TABLE HEADERS
    # ─────────────────────────────────────────────────────────────────────
    "TABLE_HEADER_ID"                 = @{ T = 'OBJECT_ID'; H = 'Table column: Object identifier'; F = $null }
    "TABLE_HEADER_NAME"               = @{ T = 'FILE_NAME'; H = 'Table column: File name'; F = $null }
    "TABLE_HEADER_SIZE"               = @{ T = 'ALLOCATED_SIZE'; H = 'Table column: Allocated size in bytes'; F = $null }
    "TABLE_HEADER_TYPE"               = @{ T = 'FS_TYPE'; H = 'Table column: File system type'; F = $null }
    "TABLE_HEADER_STATUS"             = @{ T = 'ENGINE_STATUS'; H = 'Table column: Processing status'; F = $null }
    "TABLE_HEADER_CATEGORY"           = @{ T = 'MIME_CATEGORY'; H = 'Table column: MIME type category'; F = $null }
    "TABLE_HEADER_HASH"               = @{ T = 'SHA256_CHECKSUM'; H = 'Table column: SHA256 hash value'; F = $null }
    "TABLE_HEADER_SCORE"              = @{ T = 'INTEGRITY_SCORE'; H = 'Table column: Data integrity score'; F = $null }
    "TABLE_HEADER_OFFSET"             = @{ T = 'PHYSICAL_OFFSET'; H = 'Table column: Physical disk offset'; F = $null }
    "TABLE_HEADER_LENGTH"             = @{ T = 'BYTE_LENGTH'; H = 'Table column: Byte length of object'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # INVENTORY & DISCOVERY
    # ─────────────────────────────────────────────────────────────────────
    "INVENTORY_PHYSICAL_DISKS"        = @{ T = 'ENUMERATING PHYSICAL DISK TOPOLOGY:'; H = 'Physical disk enumeration start message'; F = 'INVENTORY_MANAGER' }
    "INVENTORY_LOGICAL_VOLUMES"       = @{ T = 'ENUMERATING LOGICAL VOLUME MOUNTS:'; H = 'Logical volume enumeration start message'; F = 'INVENTORY_MANAGER' }
    "INVENTORY_WMI_FAIL"              = @{ T = 'WMI/CIM Subsystem unresponsive. Cannot enumerate hardware topology.'; H = 'WMI subsystem failure fatal error'; F = 'INVENTORY_FATAL' }

    # ─────────────────────────────────────────────────────────────────────
    # VOLUME TYPES & SELECTION
    # ─────────────────────────────────────────────────────────────────────
    "VOLUME_TYPE_NTFS"                = @{ T = 'NTFS'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_EXFAT"               = @{ T = 'exFAT'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_FAT32"               = @{ T = 'FAT32'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_EXT4"                = @{ T = 'ext4'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_BTRFS"               = @{ T = 'BTRFS'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_ZFS"                 = @{ T = 'ZFS'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_XFS"                 = @{ T = 'XFS'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_APFS"                = @{ T = 'APFS'; H = 'File system type identifier'; F = $null }
    "VOLUME_TYPE_UNKNOWN"             = @{ T = 'RAW_OR_UNKNOWN'; H = 'Unrecognized file system indicator'; F = $null }

    "VOLUME_ACCESS_DENIED"            = @{ T = 'CRITICAL: Access Denied (Check Admin Privileges)'; H = 'Volume access denied error'; F = $null }
    "VOLUME_SELECTION_PROMPT"         = @{ T = 'Identify the compromised storage target:'; H = 'Volume selection instruction'; F = 'VOLUME_TARGET_SELECTION' }
    "VOLUME_SELECTION_INDEX"          = @{ T = 'TARGET_INDEX'; H = 'Volume selection table header'; F = $null }
    "VOLUME_NO_TARGETS"               = @{ T = 'No viable storage targets detected in the current hardware configuration.'; H = 'No targets found warning'; F = 'SYSTEM_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # I/O OPERATIONS
    # ─────────────────────────────────────────────────────────────────────
    "IO_CREATEFILE_FAIL"              = @{ T = 'Win32 CreateFile API Failed to secure handle. Win32Error Code: {0}'; H = 'CreateFile API failure with error code token'; F = 'IO_FATAL' }
    "IO_READ_SUCCESS"                 = @{ T = 'Successfully read {0} bytes from physical offset {1}'; H = 'Successful read confirmation with byte/offset tokens'; F = 'IO_STREAM' }
    "IO_READ_PARTIAL"                 = @{ T = 'Partial read detected: expected {0} bytes, retrieved only {1} bytes. Padding may occur.'; H = 'Partial read warning with expected/received tokens'; F = 'IO_STREAM_WARN' }
    "IO_RETRY_ATTEMPT"                = @{ T = 'I/O failure detected. Attempting retry {0}/{1} after {2} seconds...'; H = 'Retry attempt notification with attempt/max/delay tokens'; F = 'IO_RESILIENCE' }
    "IO_RECONNECT_SUCCESS"            = @{ T = 'Connection re-established with storage controller successfully.'; H = 'Controller reconnection success'; F = 'IO_RESILIENCE' }
    "IO_RECONNECT_FAIL"               = @{ T = 'Controller reset failed. Device permanently lost after {0} attempts.'; H = 'Controller reconnection failure with attempt count token'; F = 'IO_FATAL' }
    "IO_ALIGNMENT_SHIFT"              = @{ T = 'Shifting read offset {0} -> {1} to match physical sector boundary ({2} bytes).'; H = 'Sector alignment adjustment with offset tokens'; F = 'IO_ALIGNMENT' }
    "IO_DASD_HANDLE_CLOSED"           = @{ T = 'Direct-Access Storage Device (DASD) handle released back to OS.'; H = 'DASD handle release confirmation'; F = 'IO_MANAGER' }
    "IO_DEVICE_NOT_READY"             = @{ T = 'Storage device reported Not Ready status. Standing by for hardware reconnection.'; H = 'Device not ready warning'; F = 'IO_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # SYSTEM TOPOLOGY & SPECS
    # ─────────────────────────────────────────────────────────────────────
    "TOPOLOGY_TITLE"                  = @{ T = '[ HOST SYSTEM INFRASTRUCTURE TOPOLOGY ]'; H = 'Topology display header'; F = $null }
    "SPEC_LABEL_CPU"                  = @{ T = 'PROCESSOR'; H = 'Hardware spec label for CPU'; F = $null }
    "SPEC_LABEL_RAM"                  = @{ T = 'MEMORY'; H = 'Hardware spec label for RAM'; F = $null }
    "SPEC_LABEL_OS"                   = @{ T = 'KERNEL'; H = 'Hardware spec label for OS kernel'; F = $null }
    "SPEC_LABEL_VIRT"                 = @{ T = 'VIRT_LAYER'; H = 'Hardware spec label for virtualization layer'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # HARDWARE METRICS & TELEMETRY
    # ─────────────────────────────────────────────────────────────────────
    "HW_SMART_FAIL"                   = @{ T = 'S.M.A.R.T. pre-fail threshold exceeded for attribute ID {0} (Raw Value: {1}). Mechanical failure imminent.'; H = 'S.M.A.R.T. critical warning with attribute/value tokens'; F = 'HW_METRICS_CRITICAL' }
    "HW_TBW_WARN"                     = @{ T = 'NAND ENDURANCE WARNING: Target SSD Total Bytes Written (TBW) is nearing manufacturer limits. Risk of read-only hardware lockdown.'; H = 'SSD endurance warning'; F = 'HW_METRICS_WARN' }
    "HW_TBW_CRITICAL"                 = @{ T = 'TBW limit strictly exceeded. Drive may enter protective read-only state at any moment.'; H = 'SSD endurance critical failure'; F = 'HW_METRICS_FATAL' }
    "HW_BAD_SECTOR_DETECT"            = @{ T = 'Uncorrectable Read Error (CRC) encountered at LCN {0}. Sector is physically degraded.'; H = 'Bad sector detection with LCN token'; F = 'IO_FAULT_DETECTED' }
    "HW_IO_THRASHING"                 = @{ T = 'Severe I/O Thrashing detected. Disk Queue Length is {0}. Suspending engine bus to prevent hardware death.'; H = 'I/O thrashing alert with queue length token'; F = 'TELEMETRY_ALERT' }
    "HW_IO_RECOVERY"                  = @{ T = 'I/O Pressure has normalized below critical thresholds. Resuming kernel operational threads.'; H = 'I/O recovery notification'; F = 'TELEMETRY_UPDATE' }
    "HW_THERMAL_CRIT"                 = @{ T = 'THERMAL BREACH. ACPI Probe reports {0}C. Engaging aggressive thermal throttle to prevent silicon damage.'; H = 'Thermal critical alert with temperature token'; F = 'HW_METRICS_CRITICAL' }
    "HW_THERMAL_NORMALIZED"           = @{ T = 'THERMAL PARAMETERS NORMALIZED. Resuming standard pipeline extraction.'; H = 'Thermal normalization notification'; F = 'HW_METRICS_UPDATE' }
    "HW_CONTROLLER_RESET"             = @{ T = 'DASD Controller forcefully dropped connection. Attempting low-level handle recreation (Attempt {0}/6).'; H = 'Controller reset attempt with counter token'; F = 'IO_FAULT_DETECTED' }
    "HW_PRESSURE_SUSPEND"             = @{ T = 'CRITICAL I/O QUEUE PRESSURE DETECTED. SUSPENDING ALL ENGINE BUS ACTIVITY IMMEDIATELY.'; H = 'Critical I/O pressure suspension'; F = 'TELEMETRY_CRITICAL' }
    "HW_PRESSURE_RESUME"              = @{ T = 'I/O QUEUE PRESSURE NORMALIZED. RESUMING ENGINE BUS.'; H = 'I/O pressure normalization resumption'; F = 'TELEMETRY_UPDATE' }
    "HW_CACHE_FLUSH"                  = @{ T = 'Flushing volatile disk write cache to physical NAND to prevent data loss.'; H = 'Cache flush operation notice'; F = 'HW_MANAGER' }
    "HW_STORAGE_HEALTH"               = @{ T = 'Warning: Critical response latency detected on {0}. Check physical SATA/NVMe cable and controller integrity.'; H = 'Storage health warning with device token'; F = 'HW_DIAGNOSTICS' }

    # ─────────────────────────────────────────────────────────────────────
    # NETWORK / SAMBA OPERATIONS
    # ─────────────────────────────────────────────────────────────────────
    "NET_SMB_LOCK"                    = @{ T = 'Samba Vault successfully mapped and locked to drive letter {0} (Target: {1}).'; H = 'SMB mount success with drive/target tokens'; F = 'NETWORK_SECURE' }
    "NET_SMB_TIMEOUT"                 = @{ T = 'Samba Radar subnet sweep exhausted. Target IP is unreachable, firewalled, or offline.'; H = 'SMB discovery timeout error'; F = 'NETWORK_ERR' }
    "NET_SMB_UNMOUNT"                 = @{ T = 'Unmounting Samba Drive {0} and destroying active network credentials...'; H = 'SMB unmount with drive token'; F = 'NETWORK_CLEANUP' }
    "NET_RADAR_SWEEP"                 = @{ T = 'Initiating Aggressive Physical Subnet Sweeper (Threads: 256 | Socket Timeout: 80ms)'; H = 'Network radar sweep initialization'; F = 'INFRA_RADAR' }
    "NET_RADAR_SCAN"                  = @{ T = 'Sweeping local CIDR Base: {0}.0/24 for active SMB ports...'; H = 'Subnet scan progress with base IP token'; F = 'SCAN_PHASE' }
    "NET_RADAR_FOUND"                 = @{ T = 'Compatible Samba Node Locked: {0} responding on TCP Port 445.'; H = 'SMB node discovery with IP token'; F = 'NETWORK_SUCCESS' }
    "NET_LATENCY_WARN"                = @{ T = 'Unstable network latency detected ({0}ms). Active sync stream performance may degrade significantly.'; H = 'Network latency warning with ms token'; F = 'CLOUD_SYNC_WARN' }
    "NET_SYNC_START"                  = @{ T = 'Initiating secure, multi-threaded payload transfer via Robocopy Engine. Target Destination: {0}'; H = 'Sync start with destination token'; F = 'CLOUD_SYNC_INIT' }
    "NET_SYNC_SUCCESS"                = @{ T = 'Mirroring sequence successfully completed. Robocopy Exit Code: {0}.'; H = 'Sync success with exit code token'; F = 'CLOUD_SYNC_DONE' }
    "NET_SYNC_FAIL"                   = @{ T = 'Mirroring aborted or encountered critical errors. Robocopy returned exit code {0}.'; H = 'Sync failure with exit code token'; F = 'CLOUD_SYNC_FATAL' }
    "NET_PACKET_DROP"                 = @{ T = 'Packet loss/TCP drop detected during staging upload. Auto-resuming byte stream from last acknowledged block.'; H = 'Packet loss recovery notice'; F = 'CLOUD_SYNC_WARN' }
    "NET_SMB_AUTH_REQUIRED"           = @{ T = 'Samba endpoint requires secure authentication. A Windows Security dialog will appear shortly.'; H = 'SMB authentication prompt notice'; F = 'NETWORK_AUTH' }
    "NET_NO_FREE_DRIVES"              = @{ T = 'No free drive letters available to mount the network share.'; H = 'Drive letter exhaustion error'; F = 'NETWORK_ERR' }
    "NET_UNMOUNT_FAIL"                = @{ T = 'Failed to unmount network drive. Handle may still be open.'; H = 'Network drive unmount failure'; F = 'NETWORK_ERR' }
    "ROBOCOPY_PREPARING"              = @{ T = 'Preparing Robocopy environment and validating paths...'; H = 'Robocopy pre-flight preparation text'; F = 'CLOUD_SYNC_INIT' }
    "ROBOCOPY_READY"                  = @{ T = 'Robocopy engine armed. Target locked.'; H = 'Robocopy ready status'; F = 'CLOUD_SYNC_INIT' }
    "ACTION_RESOLVING_VAULT"          = @{ T = 'RESOLVING CLOUD VAULT ENDPOINT...'; H = 'Cloud vault resolution status'; F = 'CLOUD_SYNC_INIT' }
    "ACTION_AUTH_KEYS"                = @{ T = 'AUTHENTICATING SHA256 KEYS...'; H = 'SHA256 key authentication status'; F = 'CLOUD_SYNC_INIT' }

    "NET_RADAR_GATEWAY_ERR"           = @{ T = 'No real gateway found! Host might be isolated.'; H = 'Gateway discovery failure'; F = 'ERROR' }
    "NET_RADAR_GATEWAY_OK"            = @{ T = 'Gateway: {0} ({1})'; H = 'Gateway info with IP/hostname tokens'; F = 'NETWORK' }
    "NET_RADAR_SCAN_DETAIL"           = @{ T = 'High-speed async sweep ({0} connections per batch)...'; H = 'Scan detail with batch size token'; F = 'SCAN' }
    "NET_RADAR_TESTING"               = @{ T = 'Testing {0}.0/24...'; H = 'Subnet test progress with base token'; F = $null }
    "NET_RADAR_SWEEPING"              = @{ T = '-> Sweeping {0} IPs...'; H = 'Sweep progress with IP count token'; F = $null }
    "NET_RADAR_FOUND_COUNT"           = @{ T = '[+] {0} server(s) found!'; H = 'Server count result with token'; F = $null }
    "NET_RADAR_NONE_COUNT"            = @{ T = '[-] None'; H = 'No servers found indicator'; F = $null }
    "NET_RADAR_VALID"                 = @{ T = '[+] Valid server: {0}'; H = 'Valid server confirmation with IP token'; F = $null }
    "NET_RADAR_IGNORED"               = @{ T = '[!] Ignored (Gateway Host): {0}'; H = 'Ignored gateway with IP token'; F = $null }
    "NET_RADAR_PROMPT"                = @{ T = 'MULTIPLE SMB HOSTS DETECTED. SELECT TARGET:'; H = 'Multi-host selection prompt'; F = $null }
    "NET_RADAR_LOCATED"               = @{ T = 'SAMBA SERVER LOCATED SUCCESSFULLY!'; H = 'Server location success banner'; F = $null }
    "NET_RADAR_ADDRESS"               = @{ T = 'ADDRESS: \\{0}'; H = 'Server address display with UNC token'; F = $null }
    "NET_RADAR_NONE"                  = @{ T = 'No SMB servers found in the current topology.'; H = 'No servers found error'; F = 'ERROR' }

    "NET_MAP_INIT"                    = @{ T = 'Injecting credentials and opening folder picker for \\{0}...'; H = 'Mount initialization with UNC token'; F = 'MAP' }
    "NET_MAP_OK"                      = @{ T = 'Destination Vault Selected: {0}'; H = 'Vault selection confirmation with path token'; F = 'OK' }
    "NET_MAP_AUTH"                    = @{ T = 'Explicit authentication required by SMB domain controller.'; H = 'Auth requirement notice'; F = 'AUTH' }
    "NET_MAP_AUTH_PROMPT"             = @{ T = 'Enter network credentials for \\{0}'; H = 'Auth prompt with UNC token'; F = $null }
    "NET_MAP_ABORT"                   = @{ T = 'Authentication cancelled by operator.'; H = 'Auth cancellation notice'; F = 'ABORT' }
    "NET_MAP_SUCCESS"                 = @{ T = 'DRIVE {0} MAPPED SUCCESSFULLY!'; H = 'Mount success with drive letter token'; F = $null }
    "NET_MAP_DENIED"                  = @{ T = 'Access denied. Invalid credentials or insufficient permissions.'; H = 'Mount denied error'; F = 'ERROR' }
    "NET_MAP_CANCELLED"               = @{ T = 'Operation cancelled by operator or mapping failed.'; H = 'Mount cancellation/failure notice'; F = 'ABORT' }

    "NET_MGR_TITLE"                   = @{ T = 'NETWORK DRIVE MANAGEMENT'; H = 'Network manager menu title'; F = $null }
    "NET_MGR_UNMOUNT"                 = @{ T = 'UNMOUNT: {0} -> {1}'; H = 'Unmount display with drive/path tokens'; F = $null }
    "NET_MGR_UNMOUNT_DISP"            = @{ T = '[UNMOUNT] {0}: -> {1}'; H = 'Unmount log format with tokens'; F = $null }
    "NET_MGR_UNMOUNT_ALL"             = @{ T = 'UNMOUNT ALL NETWORK DRIVES'; H = 'Bulk unmount menu option'; F = $null }
    "NET_MGR_AUTO_MOUNT"              = @{ T = 'AUTO-DETECT & MOUNT NEW SAMBA VAULT'; H = 'Auto-mount menu option'; F = $null }
    "NET_MGR_BACK"                    = @{ T = 'RETURN TO PREVIOUS MENU'; H = 'Back navigation option'; F = $null }
    "NET_MGR_MOUNT_SUCCESS"           = @{ T = 'Mapped to {0}'; H = 'Mount success with path token'; F = $null }
    "NET_MGR_ALL_REMOVED"             = @{ T = 'All network drives removed.'; H = 'Bulk unmount confirmation'; F = $null }
    "NET_MGR_UNMOUNT_REGEX"           = @{ T = '^(?:UNMOUNT|DESMONTAR|\[DESMONTAR\]):\s*([A-Z]):'; H = 'Regex pattern for unmount command parsing'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # SQLITE DATABASE ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "SQLITE_ENGINE_LOADED"            = @{ T = 'Native Interop Engine Loaded from path: {0}'; H = 'SQLite engine load success with path token'; F = 'SQLITE_ENGINE' }
    "SQLITE_ENGINE_FAIL"              = @{ T = 'Failed to load or link SQLite DLL dependency: {0}'; H = 'SQLite load failure with error token'; F = 'SQLITE_FATAL' }
    "SQLITE_DB_INIT"                  = @{ T = 'Database schema and relational structures initialized successfully in WAL mode.'; H = 'Database initialization success'; F = 'SQLITE_CORE' }
    "SQLITE_DB_FAIL"                  = @{ T = 'Database schema initialization sequence failed: {0}'; H = 'Database init failure with error token'; F = 'SQLITE_ERR' }
    "SQLITE_MEMORY_SPILL"             = @{ T = 'Failed to commit memory buffer spill to physical database: {0}'; H = 'Memory spill failure with error token'; F = 'SQLITE_ERR' }
    "SQLITE_WAL_CHECKPOINT"           = @{ T = 'SQLite WAL Checkpoint, Pragma Optimize, and VACUUM sequences reported: CONSISTENT.'; H = 'Database maintenance success'; F = 'SQLITE_SUCCESS' }
    "SQLITE_INTEGRITY_CHECK"          = @{ T = 'Database internal integrity check passed 100%.'; H = 'Integrity check success'; F = 'SQLITE_AUDIT' }
    "SQLITE_CONNECTION_BUSY"          = @{ T = 'Database thread is currently locked/busy. Engaging retry backoff...'; H = 'Database busy warning'; F = 'SQLITE_WARN' }

    "DB_LOCATION_INFO"                = @{ T = 'Forensic database safely saved at: {0}'; H = 'Database location info with path token'; F = 'DB' }
    "DB_QUERY_PROMPT"                 = @{ T = "Enter SQL Query (or 'exit' to return): "; H = 'SQL console input prompt'; F = $null }
    "DB_QUERY_RESULT"                 = @{ T = 'Query Executed. Rows affected/returned: {0}'; H = 'Query result with row count token'; F = $null }
    "DB_QUERY_ERROR"                  = @{ T = 'Query execution failed: {0}'; H = 'Query error with exception token'; F = 'DB_ERR' }
    "DB_MONITOR_STATS"                = @{ T = 'Records: {0} | Orphans: {1} | Written: {2} MB'; H = 'Live stats display with record/orphan/size tokens'; F = 'LIVE' }

    # ─────────────────────────────────────────────────────────────────────
    # INTEGRITY & FAILSAFE SYSTEMS
    # ─────────────────────────────────────────────────────────────────────
    "INT_MFT_MIRROR_DIV"              = @{ T = 'Divergence between primary MFT and MFTMirror detected. Underlying file system logic is compromised.'; H = 'MFT divergence integrity alert'; F = 'SANCTUARY_ALERT' }
    "INT_SQLITE_CORRUPT"              = @{ T = 'SQLite Write-Ahead Log (WAL) corruption detected. Forcing structural vacuum and rebuild.'; H = 'SQLite WAL corruption recovery'; F = 'SQLITE_FATAL' }
    "INT_MODE_CONFLICT"               = @{ T = "The detected file system '{0}' inherently does not support the '{1}' engine parsing mode."; H = 'Filesystem/mode incompatibility with tokens'; F = 'CONFIG_CONFLICT' }
    "INT_FAILSAFE_TRIG"               = @{ T = 'Primary deterministic trajectory failed. Engaging deep Archaeology carving fallback in {0} seconds.'; H = 'Fallback trigger with countdown token'; F = 'PIPELINE_FAILSAFE' }
    "INT_FALLBACK_ABORT"              = @{ T = 'Operation forcefully cancelled by operator. Engine strictly cannot process RAW or Linux partitions while locked in EFFICIENCY mode.'; H = 'Fallback abort notice'; F = 'ABORT' }
    "INT_CONVERSION_AUTH"             = @{ T = 'Authorize automatic conversion to REDUNDANCY mode (UniversalMetadata Schema)? [Y/N]'; H = 'Mode conversion authorization prompt'; F = 'INTERVENTION_REQUIRED' }
    "INT_CONVERSION_OK"               = @{ T = 'EngineMode successfully altered to REDUNDANCY.'; H = 'Mode conversion confirmation'; F = 'CONFIG_UPDATE' }
    "INT_CHECKPOINT_CREATED"          = @{ T = 'Operational checkpoint saved to database. Engine resume capability is now active.'; H = 'Checkpoint creation confirmation'; F = 'STATE_MACHINE' }

    # ─────────────────────────────────────────────────────────────────────
    # PIPELINE / EXTRACTION FLOW
    # ─────────────────────────────────────────────────────────────────────
    "PIPE_TRAVERSAL_START"            = @{ T = 'Walking metadata tree deterministically on {0}...'; H = 'Traversal start with target token'; F = 'TRAVERSAL_INIT' }
    "PIPE_TRAVERSAL_COMPLETE"         = @{ T = 'File system metadata traversal completed successfully.'; H = 'Traversal completion notice'; F = 'TRAVERSAL_DONE' }
    "PIPE_ARCHAEOLOGY_START"          = @{ T = 'Raw hexadecimal signature sweep started for engine: {0}.'; H = 'Archaeology start with engine token'; F = 'ARCHAEOLOGY_INIT' }
    "PIPE_ARCHAEOLOGY_COMPLETE"       = @{ T = 'Deep disk surface carving completed.'; H = 'Archaeology completion notice'; F = 'ARCHAEOLOGY_DONE' }
    "PIPE_BATCH_START"                = @{ T = 'Igniting extraction engine on mode [{0}] for category ({1})...'; H = 'Batch start with mode/category tokens'; F = 'BATCH_ENGINE' }
    "PIPE_BATCH_COMPLETE"             = @{ T = 'Harvester batch extraction operations finished.'; H = 'Batch completion notice'; F = 'BATCH_ENGINE' }
    "PIPE_EXTRACT_COUNTER"            = @{ T = '[{0}] Processing payload: {1}'; H = 'Extraction progress with index/file tokens'; F = 'EXTRACT_STREAM' }
    "PIPE_STREAMING_DATA"             = @{ T = 'STREAMING_DATA_FOR_RECORD: I/O Buffer Injection Synchronized.'; H = 'Data streaming sync notice'; F = 'PIPELINE_SYNC' }
    "PIPE_TARGETED_RECOVERY"          = @{ T = 'TARGETED RECOVERY SEQUENCE ACTIVATED AND LOCKED.'; H = 'Targeted recovery activation'; F = 'PIPELINE_EXEC' }

    # ─────────────────────────────────────────────────────────────────────
    # PIPELINE ENGINE / AUDIT / COMPLIANCE
    # ─────────────────────────────────────────────────────────────────────
    "PIPELINE_INIT"                   = @{ T = 'Pipeline engine initializing...'; H = 'Pipeline startup status'; F = 'PIPELINE' }
    "PIPELINE_ACTIVE"                 = @{ T = 'Pipeline engine active and processing.'; H = 'Pipeline active status'; F = 'PIPELINE' }
    "PIPELINE_NO_MODULE"              = @{ T = 'Pipeline module not available.'; H = 'Pipeline module missing error'; F = 'PIPELINE_ERR' }
    "AUDIT_EXPORTING"                 = @{ T = 'Exporting audit report...'; H = 'Audit export in-progress status'; F = 'AUDIT' }
    "AUDIT_EXPORT_SUCCESS"            = @{ T = 'Audit report exported successfully.'; H = 'Audit export success'; F = 'AUDIT_SUCCESS' }
    "AUDIT_EXPORT_FAILED"             = @{ T = 'Audit report export failed.'; H = 'Audit export failure'; F = 'AUDIT_ERR' }
    "AUDIT_MODULE_NOT_LOADED"         = @{ T = 'Audit module not loaded.'; H = 'Audit module unavailable error'; F = 'AUDIT_ERR' }
    "COMPLIANCE_GENERATING"           = @{ T = 'Generating compliance report...'; H = 'Compliance generation in-progress'; F = 'COMPLIANCE' }
    "COMPLIANCE_GENERATED"            = @{ T = 'Compliance report generated.'; H = 'Compliance generation success'; F = 'COMPLIANCE' }
    "COMPLIANCE_FAILED"               = @{ T = 'Compliance report generation failed.'; H = 'Compliance generation failure'; F = 'COMPLIANCE_ERR' }
    "COMPLIANCE_NO_MODULE"            = @{ T = 'Compliance module not loaded.'; H = 'Compliance module unavailable error'; F = 'COMPLIANCE_ERR' }

    "PIPE_FALLBACK_WARNING"           = @{ T = 'FILE SYSTEM METADATA IS CORRUPTED, ENCRYPTED, OR PHYSICALLY INACCESSIBLE.'; H = 'Metadata corruption critical warning'; F = 'CRITICAL_WARNING' }
    "PIPE_FALLBACK_IMMINENT"          = @{ T = 'FALLING BACK TO RAW DATA CARVING (PLAN B). EXTREME I/O THRASHING IS IMMINENT.'; H = 'Fallback imminent warning'; F = 'CRITICAL_WARNING' }
    "PIPE_FALLBACK_COUNTDOWN"         = @{ T = 'WAITING {0} SECONDS TO ABORT OPERATION (PRESS CTRL+C NOW)...'; H = 'Fallback countdown with seconds token'; F = 'FAILSAFE_TIMER' }
    "PIPE_FALLBACK_ENGAGED"           = @{ T = 'TIMER EXPIRED. ENGAGING ARCHAEOLOGY SWEEP MECHANISM.'; H = 'Fallback engagement confirmation'; F = 'FAILSAFE_TRIGGERED' }
    "PIPE_EXTRACTION_PHASE"           = @{ T = 'Initiating physical byte-extraction phase...'; H = 'Extraction phase transition'; F = 'PIPELINE_TRANSITION' }
    "PIPE_CARVING_PROGRESS"           = @{ T = 'Physical Offset: {0} GB | Throughput: {1} MB/s | Orphans Recovered: {2}'; H = 'Carving telemetry with offset/speed/count tokens'; F = 'CARVING_TELEMETRY' }

    # ─────────────────────────────────────────────────────────────────────
    # UI / INTERACTIVE EXPLORER
    # ─────────────────────────────────────────────────────────────────────
    "UI_ExplorerTitle"                = @{ T = 'INTERACTIVE FILE EXPLORER - SCAPE RECOVERY SYSTEM'; H = 'Explorer window title'; F = $null }
    "UI_BreadcrumbRoot"               = @{ T = 'VIRTUAL_ROOT'; H = 'Root breadcrumb label'; F = $null }
    "UI_NavHelp"                      = @{ T = 'HOTKEYS: [UP/DOWN] Navigate | [ENTER] Open Folder | [SPACE] Toggle Mark | [E] Execute Extraction | [B] Go Back | [Q] Quit Explorer'; H = 'Explorer navigation help text'; F = $null }
    "UI_DirIcon"                      = @{ T = '[DIR ]'; H = 'Directory icon indicator'; F = $null }
    "UI_FileIcon"                     = @{ T = '[FILE]'; H = 'File icon indicator'; F = $null }
    "UI_Marked"                       = @{ T = '[X]'; H = 'Marked item indicator'; F = $null }
    "UI_Unmarked"                     = @{ T = '[ ]'; H = 'Unmarked item indicator'; F = $null }
    "UI_Cursor"                       = @{ T = '>>> '; H = 'Selection cursor indicator'; F = $null }
    "UI_EmptyFolder"                  = @{ T = '[ DIRECTORY IS EMPTY OR UNREADABLE ]'; H = 'Empty/unreadable folder notice'; F = $null }

    "UI_ConfirmExtract"               = @{ T = 'DANGER: Confirm physical extraction of {0} selected items (including all recursive children)? (y/N): '; H = 'Recursive extraction confirmation with count token'; F = $null }
    "UI_Extracting"                   = @{ T = 'Processing physical extraction for {0} marked objects...'; H = 'Extraction progress with count token'; F = $null }
    "UI_ExtractComplete"              = @{ T = 'Targeted extraction successfully committed to staging path: {0}'; H = 'Extraction success with path token'; F = $null }
    "UI_LoadError"                    = @{ T = 'Fatal error loading directory node items: {0}'; H = 'Directory load error with exception token'; F = $null }

    "UI_SelectFolder"                 = @{ T = 'SELECT DESTINATION SANDBOX FOR STAGING'; H = 'Staging folder selection header'; F = $null }
    "UI_StagingFolderPrompt"          = @{ T = 'Enter fully qualified Staging folder path (Local SSD recommended)'; H = 'Staging path input instruction'; F = $null }
    "UI_DestinationPrompt"            = @{ T = 'Enter final Destination path (OneDrive/Google Drive/UNC Network Share)'; H = 'Destination path input instruction'; F = $null }
    "UI_MarkRecursiveHint"            = @{ T = '[R] modifier indicates a recursive mark - all child objects within the directory will be extracted.'; H = 'Recursive marking hint'; F = $null }
    "UI_SELECT_DIR_ERROR"             = @{ T = 'Failed to launch directory picker: {0}'; H = 'Directory picker error with exception token'; F = $null }
    "UI_SELECT_DIR_PROMPT"            = @{ T = 'Select output directory:'; H = 'Directory selection prompt'; F = $null }
    "UI_SELECT_DIR_FALLBACK"          = @{ T = 'Type output directory path manually: '; H = 'Manual path input fallback'; F = $null }
    "UI_CANCEL_OP"                    = @{ T = '[CANCEL OPERATION]'; H = 'Cancel button label'; F = $null }
    "UI_BTN_BACK"                     = @{ T = '>> GO BACK'; H = 'Back navigation button'; F = $null }

    "UI_COMPLIANCE_DISCLAIMER"        = @{ T = 'Accessing RAW sectors carries risk of hardware stress or data loss. Accept? (y/N): '; H = 'RAW access risk disclaimer'; F = 'DASD COMPLIANCE' }
    "UI_ABORT_CONFIRM_CRITICAL"       = @{ T = 'Aborting active I/O may leave handles open or corrupt the database. Force Abort? (y/N): '; H = 'Critical abort confirmation'; F = 'CRITICAL WARNING' }

    # ─────────────────────────────────────────────────────────────────────
    # PRESENTATION UI — DISPATCHER, FILEPICKER, KEYBINDINGS, PROGRESS
    # ─────────────────────────────────────────────────────────────────────
    "DISPATCHER_TARGET_LABEL"         = @{ T = 'Dispatching to: {0}'; H = 'Dispatcher target label with target token'; F = 'UI' }
    "FILEPICKER_INIT"                 = @{ T = 'Launching file picker dialog...'; H = 'FilePicker initialization status'; F = 'UI' }
    "FILEPICKER_DIALOG"               = @{ T = 'Select a file'; H = 'FilePicker dialog title'; F = 'UI' }
    "KEYBINDINGS_INIT"                = @{ T = 'Initializing key binding configuration...'; H = 'KeyBindings init message'; F = 'UI' }
    "KEYBINDINGS_NO_MODULE"           = @{ T = 'Key binding module not available.'; H = 'KeyBindings module missing error'; F = 'UI_ERR' }
    "KEYBINDINGS_MODE"                = @{ T = 'Mode'; H = 'Key binding mode label'; F = 'UI' }
    "KEYBINDINGS_INTERACTIVE"         = @{ T = 'Interactive'; H = 'Interactive mode label'; F = 'UI' }
    "KEYBINDINGS_STATUS"              = @{ T = 'Status'; H = 'Key binding status label'; F = 'UI' }
    "KEYBINDINGS_PRESS_KEY"           = @{ T = 'Press a key to bind...'; H = 'Prompt for key press during binding'; F = 'UI' }
    "KEYBINDINGS_ACTION"              = @{ T = 'Action'; H = 'Binding action label'; F = 'UI' }
    "KEYBINDINGS_READY"               = @{ T = 'Key bindings ready.'; H = 'KeyBindings ready status'; F = 'UI' }
    "KEYBINDINGS_PROF_LOADED"         = @{ T = 'Profile loaded: {0}'; H = 'Profile load confirmation with name token'; F = 'UI' }
    "KEYBINDINGS_NO_PROFILE"          = @{ T = 'No profile found. Using defaults.'; H = 'No profile found notice'; F = 'UI' }
    "KEYBINDINGS_SAVED"               = @{ T = 'Key bindings saved successfully.'; H = 'KeyBindings save success'; F = 'UI' }
    "KEYBINDINGS_FAILED"              = @{ T = 'Failed to save key bindings.'; H = 'KeyBindings save failure'; F = 'UI_ERR' }
    "KEYBINDINGS_SYS_READY"           = @{ T = 'System key bindings are ready.'; H = 'System-level bindings active'; F = 'UI' }
    "LBL_OVERALL_PROGRESS"            = @{ T = 'OVERALL RUN PROGRESS'; H = 'Overall progress bar label'; F = 'UI' }
    "LBL_CURRENT_PROGRESS"            = @{ T = 'CURRENT TASK PROGRESS'; H = 'Current task progress bar label'; F = 'UI' }

    # ─────────────────────────────────────────────────────────────────────
    # VIEW / DASHBOARD UI
    # ─────────────────────────────────────────────────────────────────────
    "DASH_HEADER_NODE"                = @{ T = 'SYSTEM-CRITICAL ANALYSIS PARTITION EXTRACTOR | NODE: {0}'; H = 'Dashboard header with node token'; F = $null }
    "BANNER_TITLE"                    = @{ T = 'SCAPE Recovery System - Advanced Forensic Engine v1.0'; H = 'Application banner title'; F = $null }

    "DASH_TASK"                       = @{ T = 'TASK: {0}'; H = 'Dashboard task display with token'; F = $null }
    "DASH_LINE1"                      = @{ T = 'DISK_QUEUE: {0} | THERMAL: {1}C | RAM_PRESSURE: {2}%'; H = 'Dashboard metrics line 1 with queue/temp/ram tokens'; F = $null }
    "DASH_LINE2"                      = @{ T = 'DB_PARSED: {0} | DB_ORPHANS: {1} | DB_EXTRACTED: {2}'; H = 'Dashboard metrics line 2 with db stat tokens'; F = $null }
    "DASH_LINE3"                      = @{ T = 'LCN_POS: {0} | PROG: {1} | RATE: {2} MB/s'; H = 'Dashboard metrics line 3 with progress/rate tokens'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # ROBOCOPY / CLOUD SYNC CONFIG
    # ─────────────────────────────────────────────────────────────────────
    "RC_TITLE"                        = @{ T = 'LOGISTICS & CLOUD SYNC CONTROL PANEL - SCAPE ROBOSYNC'; H = 'Robocopy panel title'; F = $null }
    "RC_STAGING_LABEL"                = @{ T = 'Local Staging Directory'; H = 'Staging path field label'; F = $null }
    "RC_DEST_LABEL"                   = @{ T = 'Final Cloud/UNC Destination'; H = 'Destination path field label'; F = $null }

    "RC_FLAG_E"                       = @{ T = '/E : Copy all subdirectories (including empty directories)'; H = 'Robocopy /E flag description'; F = $null }
    "RC_FLAG_ZB"                      = @{ T = '/ZB: Restartable + Backup mode (Network resilience)'; H = 'Robocopy /ZB flag description'; F = $null }
    "RC_FLAG_M"                       = @{ T = '/M : Archive Bit Mode (Only copy un-synced files)'; H = 'Robocopy /M flag description'; F = $null }
    "RC_FLAG_MT"                      = @{ T = '/MT: Multithreaded Transfer (Auto-sensed value: {0})'; H = 'Robocopy /MT flag with thread token'; F = $null }
    "RC_FLAG_B"                       = @{ T = '/B : Backup Mode (Strictly Bypass NTFS ACLs/Permissions)'; H = 'Robocopy /B flag description'; F = $null }
    "RC_FLAG_COPYALL"                 = @{ T = '/COPYALL: Mirror all metadata (Data, Attributes, Timestamps, Security, Owner, Auditing)'; H = 'Robocopy /COPYALL flag description'; F = $null }
    "RC_FLAG_DCOPY_T"                 = @{ T = '/DCOPY:T: Strictly preserve directory timestamps'; H = 'Robocopy /DCOPY:T flag description'; F = $null }
    "RC_FLAG_NP"                      = @{ T = '/NP: Suppress Progress percentage (Forces clean logging for industrial runs)'; H = 'Robocopy /NP flag description'; F = $null }
    "RC_FLAG_FFT"                     = @{ T = '/FFT: Force FAT file times (2-second granularity tolerance)'; H = 'Robocopy /FFT flag description'; F = $null }
    "RC_FLAG_XO"                      = @{ T = '/XO: Exclude older files (Redundancy prevention)'; H = 'Robocopy /XO flag description'; F = $null }
    "RC_FLAG_XN"                      = @{ T = '/XN: Exclude newer files (One-way mirroring)'; H = 'Robocopy /XN flag description'; F = $null }
    "RC_FLAG_XJ"                      = @{ T = '/XJ: Exclude junction points (Prevents infinite symlink loops)'; H = 'Robocopy /XJ flag description'; F = $null }
    "RC_FLAG_L"                       = @{ T = '/L : List-Only Simulation Mode (Dry run, no bytes transferred)'; H = 'Robocopy /L flag description'; F = $null }
    "RC_FLAG_V"                       = @{ T = '/V : Verbose Output (Enables detailed logging for judicial evidence chains)'; H = 'Robocopy /V flag description'; F = $null }

    "RC_FLAG_E_DESC"                  = @{ T = 'Copy all subdirectories, including empty ones. Essential for reconstructing exact directory topology.'; H = 'Detailed /E explanation'; F = $null }
    "RC_FLAG_M_DESC"                  = @{ T = "Archive Bit Mode: Only mirrors files that haven't been previously synced. Resets the 'Archive' flag after successful copy to minimize SSD wear."; H = 'Detailed /M explanation'; F = $null }
    "RC_FLAG_ZB_DESC"                 = @{ T = 'Restartable Mode: Highly critical for unstable network or cloud connections. Prevents file corruption by resuming dropped transfers.'; H = 'Detailed /ZB explanation'; F = $null }
    "RC_FLAG_MT_DESC"                 = @{ T = 'Multi-Threading Capability: High values (64-128) recommended for NVMe-to-NVMe. Low values (8-16) required for unstable Network/Samba shares.'; H = 'Detailed /MT explanation'; F = $null }
    "RC_FLAG_B_DESC"                  = @{ T = 'BACKUP MODE: Exploits SeBackupPrivilege to forcefully read locked files regardless of corrupted or restrictive NTFS permissions.'; H = 'Detailed /B explanation'; F = $null }
    "RC_FLAG_FFT_DESC"                = @{ T = 'FAT File Times: Mandatory when mirroring data between precise NTFS volumes and loose FAT/exFAT devices to avoid false-positive time mismatches.'; H = 'Detailed /FFT explanation'; F = $null }
    "RC_FLAG_XO_DESC"                 = @{ T = 'Exclude Older: Ignores files that already exist and are strictly newer in the destination target. Excellent for redundancy prevention.'; H = 'Detailed /XO explanation'; F = $null }
    "RC_FLAG_XN_DESC"                 = @{ T = 'Exclude Newer: Skips copying files that are newer in the destination target. Useful for strict one-way archival sync.'; H = 'Detailed /XN explanation'; F = $null }
    "RC_FLAG_XJ_DESC"                 = @{ T = 'Exclude Junctions: Prevents the engine from falling into infinite recursion loops when syncing directories containing broken symbolic links.'; H = 'Detailed /XJ explanation'; F = $null }
    "RC_FLAG_NP_DESC"                 = @{ T = 'No Progress: Suppresses the percentage counter on standard output. Mandatory to keep log files readable for automated parser scripts.'; H = 'Detailed /NP explanation'; F = $null }
    "RC_FLAG_L_DESC"                  = @{ T = 'SIMULATION MODE: Lists all files that would be processed without actually moving any bytes. Crucial for sanity-checking before massive operations.'; H = 'Detailed /L explanation'; F = $null }
    "RC_FLAG_V_DESC"                  = @{ T = 'VERBOSE MODE: Generates highly detailed logs, detailing every skipped file and exact error codes. Legally required for maintaining chain of custody.'; H = 'Detailed /V explanation'; F = $null }

    "RC_RETRY_R"                      = @{ T = '/R : Retry attempt count on failure'; H = 'Robocopy /R flag label'; F = $null }
    "RC_RETRY_W"                      = @{ T = '/W : Wait timeout between retries (in seconds)'; H = 'Robocopy /W flag label'; F = $null }
    "RC_RETRY_R_DESC"                 = @{ T = 'Retry Count: Exact number of times the engine will retry a failed byte transfer. Default is 3. Increase significantly for highly unstable WAN networks.'; H = 'Detailed /R explanation'; F = $null }
    "RC_RETRY_W_DESC"                 = @{ T = 'Wait Time: Absolute seconds the engine will pause before re-attempting a failed transfer. Default is 10. Increase for flaky cloud endpoints.'; H = 'Detailed /W explanation'; F = $null }
    "RC_WAIT_RETRY"                   = @{ T = '/R:{0} /W:{1} (Configured Retries: {0} | Wait Interval: {1}s)'; H = 'Retry config display with tokens'; F = $null }

    "RC_CACHE_ADVISORY"               = @{ T = 'CACHE TOPOLOGY GUIDE: Ensure your designated Staging drive has at least 200% the free space of the absolute largest single file being recovered to prevent fatal buffer overflows during Robocopy hashing.'; H = 'Staging space advisory'; F = $null }
    "RC_HW_WEAR_LONG"                 = @{ T = 'CRITICAL ENDURANCE WARNING: Mass physical data movement to a Local Cloud Staging directory induces extremely high NAND Write Cycles (TBW). Ensure the staging drive is Enterprise/Industrial rated.'; H = 'Hardware endurance warning'; F = $null }
    "RC_ENV_GUIDE"                    = @{ T = "ROBOSYNC CONFIGURATION GUIDE:`n 1. Set 'Staging' to a local, physically connected NVMe/SSD drive.`n 2. Set 'Destination' to your Cloud-Synced endpoint folder (e.g., OneDrive, Google Drive).`n 3. CRITICAL: Ensure Cloud 'Files On-Demand' (or equivalent) is strictly OFF for the Staging folder to prevent the sync engine from looping infinitely."; H = 'Robosync setup guide'; F = $null }

    "RC_START_SYNC"                   = @{ T = '[S] IGNITE SYNCHRONIZATION ENGINE'; H = 'Start sync menu option'; F = $null }
    "RC_CANCEL"                       = @{ T = '[C] ABORT SYNC CONFIGURATION'; H = 'Cancel sync menu option'; F = $null }
    "RC_SPACE_CHECK"                  = @{ T = 'Verified free space on local staging hardware: {0} GB'; H = 'Space check with GB token'; F = $null }
    "RC_SPACE_LOW_CONFIRM"            = @{ T = 'DANGER: Low disk space detected on staging drive. Proceeding may cause OS instability. Continue anyway? (y/N): '; H = 'Low space confirmation prompt'; F = $null }
    "RC_ARCHIVE_MODE_INFO"            = @{ T = '[INFO_ADVISORY] The /M (Archive) flag significantly reduces SSD TBW wear by aggressively skipping already synchronized payloads.'; H = 'Archive mode benefit notice'; F = $null }
    "RC_INVALID_MT"                   = @{ T = 'Invalid thread count specification. Enforcing auto-sensed optimal value.'; H = 'Invalid MT input handling'; F = 'INPUT_ERR' }
    "RC_AUTOSENSE"                    = @{ T = "Destination medium '{0}' detected -> Transfer threads aggressively limited to {1} to prevent I/O choke."; H = 'Auto-sense notice with medium/thread tokens'; F = 'THROTTLE_AUTOSENSE' }

    "RC_SYNC_RUNNING"                 = @{ T = 'Synchronization pipeline is currently hot. Robocopy engine is executing...'; H = 'Sync in progress notice'; F = 'ROBOSYNC_ACTIVE' }
    "RC_CALCULATING_SIZE"             = @{ T = 'Calculating total byte footprint of selected payload objects...'; H = 'Payload size calculation notice'; F = 'ROBOSYNC_PREFLIGHT' }
    "RC_BLOCKED_SPACE"                = @{ T = 'OPERATION BLOCKED: Payload size drastically exceeds physically available space on the staging drive.'; H = 'Space blocking error'; F = 'ROBOSYNC_FATAL' }
    "RC_ROBOCOPY_NOT_FOUND"           = @{ T = 'Native Robocopy.exe executable not found in system environment PATH.'; H = 'Robocopy missing error'; F = 'ROBOSYNC_FATAL' }
    "RC_EXIT_CODE_INFO"               = @{ T = 'Robocopy process terminated with exit code {0}: {1}'; H = 'Exit code info with code/desc tokens'; F = 'ROBOSYNC_AUDIT' }
    "RC_LOG_SAVED"                    = @{ T = 'Detailed Robocopy transaction log safely committed to: {0}'; H = 'Log saved with path token'; F = 'ROBOSYNC_AUDIT' }

    "RC_BTN_START"                    = @{ T = '[ START ROBOSYNC SYNCHRONIZATION ]'; H = 'Start sync button label'; F = $null }
    "RC_BTN_CANCEL"                   = @{ T = '[ ABORT AND RETURN ]'; H = 'Cancel button label'; F = $null }
    "RC_DEFAULTS_TITLE"               = @{ T = 'ROBOCOPY GLOBAL DEFAULTS CONFIGURATION'; H = 'Defaults config panel title'; F = $null }
    "RC_SAVE_RETURN"                  = @{ T = '[ SAVE CONFIGURATION AND RETURN ]'; H = 'Save and return button'; F = $null }
    "RC_DEL_RTN"                      = @{ T = '[ RETURN WITHOUT SAVING ]'; H = 'Discard and return button'; F = $null }
    "RC_BTN_PREPARE_FLAGS"            = @{ T = 'PREPARE_ARCHIVE_FLAGS (Bitwise Tagging)'; H = 'Prepare flags button label'; F = $null }
    "RC_BTN_PREPARE_FLAGS_DESC"       = @{ T = '[ PREPARE ARCHIVE FLAGS (Bitwise Tagging) ]'; H = 'Prepare flags button description'; F = $null }
    "RC_BTN_EDIT_DESC"                = @{ T = '[ CONFIGURE ROBOCOPY FLAGS ]'; H = 'Configure flags button'; F = $null }
    "RC_TAGGING_START"                = @{ T = 'Initiating High-Speed Archive Bit Tagging on {0}...'; H = 'Tagging start with target token'; F = 'ROBOSYNC' }
    "RC_TAGGING_DONE"                 = @{ T = 'Archive Bit Tagging Complete.'; H = 'Tagging completion notice'; F = 'ROBOSYNC' }

    # ─────────────────────────────────────────────────────────────────────
    # DEPLOYER / COMPILER ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "DEPLOYER_START"                  = @{ T = 'Initiating dynamic structural orchestration of the SCAPE Monolith...'; H = 'Deployer initialization'; F = 'DEPLOYER_INIT' }
    "DEPLOYER_PURGE"                  = @{ T = 'Previous active deployment tree detected. Purging old architecture...'; H = 'Old build purge notice'; F = 'DEPLOYER_WARN' }
    "DEPLOYER_EXTRACT"                = @{ T = 'Extracting modular payloads dynamically from matrix...'; H = 'Module extraction start'; F = 'DEPLOYER_EXEC' }
    "DEPLOYER_EXTRACT_OK"             = @{ T = '-> [DEPLOYER_OK] Payload module extracted perfectly: {0}'; H = 'Module extract success with name token'; F = $null }
    "DEPLOYER_EXTRACT_FAIL"           = @{ T = "[DEPLOYER_ERROR] Catastrophic failure extracting module '{0}': {1}"; H = 'Module extract failure with name/error tokens'; F = $null }
    "DEPLOYER_GENERATE"               = @{ T = 'Generating and linking bootloader Maestro (Main.ps1)...'; H = 'Bootloader generation notice'; F = 'DEPLOYER_LINK' }
    "DEPLOYER_SUCCESS"                = @{ T = 'SCAPE Recovery Monolith generated and compiled successfully!'; H = 'Build success banner'; F = 'DEPLOYER_DONE' }
    "DEPLOYER_LOCATION"               = @{ T = 'Physical Execution Location: {0}'; H = 'Build location with path token'; F = $null }
    "DEPLOYER_FATAL"                  = @{ T = 'System compilation failed critically: {0}'; H = 'Build fatal error with exception token'; F = 'DEPLOYER_FATAL' }
    "DEPLOYER_RUN_ADMIN"              = @{ T = 'CRITICAL DIRECTIVE: Execute Main.ps1 as Administrator for full hardware functionality.'; H = 'Admin execution directive'; F = $null }

    "DEPLOYER_OPT_DEV"                = @{ T = 'DEV_MODE (Extract modules & generate Main.ps1)'; H = 'Dev mode menu option'; F = '1' }
    "DEPLOYER_OPT_EXE"                = @{ T = 'BUILD_EXE (Compile via ps2exe)'; H = 'Portable EXE build menu option'; F = '2' }
    "DEPLOYER_OPT_SETUP"              = @{ T = 'BUILD_EXE (Compile via INNO Setup)'; H = 'Setup EXE Installer menu option'; F = '3' }
    "DEPLOYER_OPT_MSI"                = @{ T = 'BUILD_MSI (Compile via WiX Toolset)'; H = 'MSI build menu option'; F = '4' }
    "MENU_DEPLOY_TITLE"               = @{ T = '[ SCAPE DEPLOYMENT MATRIX ]'; H = 'Deployer menu header'; F = $null }
    "DEPLOYER_MATRIX_HEADER"          = @{ T = '[ SCAPE DEPLOYMENT VECTOR MATRIX ]'; H = 'Deployment vector selection header'; F = $null }
    "DEPLOYER_MOD_DISCOVERY"          = @{ T = 'Scanning scope for module signatures...'; H = 'Auto-discovery start'; F = 'DEPLOYER_MOD_DISCOVERY' }
    "DEPLOYER_ASSETS_DISCOVERY"       = @{ T = 'Scanning scope for data assets...'; H = 'Auto-discovery start'; F = 'DEPLOYER_ASSETS_DISCOVERY' }

    "DEPLOYER_B64_START"              = @{ T = 'SQLite binaries found. Converting to DNA (Base64)...'; H = 'Binary conversion start'; F = 'DEPLOYER' }
    "DEPLOYER_B64_SUCCESS"            = @{ T = 'Binaries converted and injected into Core DNA.'; H = 'Binary injection success'; F = 'DEPLOYER' }
    "DEPLOYER_B64_MISSING"            = @{ T = 'SQLite DLLs not found in root. Core will attempt fallback download.'; H = 'Missing DLL fallback notice'; F = 'WARN' }
    "DEPLOYER_B64_DOWNLOADING_BUNDLE" = @{ T = 'Downloading SQLite bundle from {0} ...'; H = 'Bundle download with URL token'; F = $null }
    "DEPLOYER_B64_BUNDLE_FAIL"        = @{ T = 'Bundle download failed. Trying separate packages...'; H = 'Bundle fail fallback notice'; F = $null }
    "DEPLOYER_B64_DOWNLOADING_X86"    = @{ T = 'Downloading x86 package...'; H = 'x86 download notice'; F = $null }
    "DEPLOYER_B64_DOWNLOADING_X64"    = @{ T = 'Downloading x64 package...'; H = 'x64 download notice'; F = $null }
    "DEPLOYER_B64_SEPARATE_FAIL"      = @{ T = 'Failed to download separate packages: {0}'; H = 'Separate download fail with error token'; F = $null }
    "DEPLOYER_B64_FOUND_FILES"        = @{ T = 'Found files in temp:'; H = 'Temp files list header'; F = $null }
    "DEPLOYER_B64_NO_MANAGED"         = @{ T = 'System.Data.SQLite.dll not found in downloaded package.'; H = 'Managed DLL missing error'; F = 'ERROR' }
    "DEPLOYER_B64_NO_INTEROP"         = @{ T = 'Could not locate both x86 and x64 SQLite.Interop.dll.'; H = 'Interop DLLs missing error'; F = 'ERROR' }
    "DEPLOYER_B64_DOWNLOADING_ARM64"  = @{ T = 'Attempting ARM64 download...'; H = 'ARM64 download attempt'; F = $null }
    "DEPLOYER_B64_ARM64_OK"           = @{ T = 'ARM64 native DLL obtained.'; H = 'ARM64 success notice'; F = $null }
    "DEPLOYER_B64_ARM64_MISSING"      = @{ T = 'ARM64 DLL not found in package. Fallback will be used.'; H = 'ARM64 missing fallback'; F = $null }
    "DEPLOYER_B64_ARM64_FAIL"         = @{ T = 'ARM64 package not available (or download failed). x64 fallback will be used.'; H = 'ARM64 fail fallback'; F = $null }
    "DEPLOYER_B64_PLACEMENT_FAIL"     = @{ T = 'Failed to place all required DLLs in {0}.'; H = 'DLL placement fail with path token'; F = 'ERROR' }
    "DEPLOYER_B64_NO_INTEROP_X64"     = @{ T = 'Could not find SQLite.Interop.dll in x64 package.'; H = 'x64 interop missing'; F = 'ERROR' }
    "DEPLOYER_B64_NO_INTEROP_X86"     = @{ T = 'Could not find SQLite.Interop.dll in x86 package.'; H = 'x86 interop missing'; F = 'ERROR' }
    "DEPLOYER_CORE_RESTORED"          = @{ T = 'Managed DLL restored: {0}'; H = 'Managed DLL restore with path token'; F = 'SQLITE' }
    "DEPLOYER_NATIVE_RESTORED"        = @{ T = 'Native Interop DLL restored: {0}'; H = 'Native DLL restore with path token'; F = 'SQLITE' }
    "DEPLOYER_VETOR_SELECT"           = @{ T = '[+] SELECT DEPLOYMENT VECTOR:'; H = 'Vector selection prompt'; F = $null }
    "DEPLOYER_CORE_INJECT"            = @{ T = 'Injecting persistence engine...'; H = 'Persistence injection notice'; F = 'DEPLOYER' }
    "DEPLOYER_CORE_FAIL"              = @{ T = 'Failed to provision SQLite. Maestro may fail at boot.'; H = 'SQLite provision warning'; F = 'WARN' }
    "DEPLOYER_DEV_MODE_FAILSAFE"      = @{ T = 'Core binaries locked. Applied hot-rename failsafe for DEV_MODE.'; H = 'Dev mode failsafe notice'; F = 'WARN' }
    "DEPLOYER_LAUNCH_SCAPE"           = @{ T = 'LAUNCHING SCAPE RECOVERY ENGINE...'; H = 'Engine launch banner'; F = $null }
    "DEPLOYER_RETRY_REMOVE"           = @{ T = 'Failed to remove previous tree. Retrying in 2 seconds...'; H = 'Purge retry notice'; F = $null }
    "DEPLOYER_CANNOT_REMOVE"          = @{ T = 'Could not remove directory {0}. Proceeding with forced creation...'; H = 'Purge fail with path token'; F = $null }
    "DEPLOYER_ICON_ANCHORED"          = @{ T = 'Icon ({0}) anchored.'; H = 'Icon anchor with name token'; F = $null }
    "DEPLOYER_DEV_COPY_CORE"          = @{ T = 'Core physical folders copied to DEV architecture.'; H = 'Dev copy confirmation'; F = $null }
    "DEPLOYER_ERR_NO_PAYLOADS"        = @{ T = 'No payloads mapped in memory.'; H = 'No payloads error'; F = $null }
    "DEPLOYER_ERR_DLL_EXTRACT"        = @{ T = 'DLL extraction failed internally.'; H = 'DLL extract internal error'; F = $null }
    "DEPLOYER_ERR_WIX_DOWNLOAD"       = @{ T = 'WiX portable download failed: {0}'; H = 'WiX download fail with error token'; F = $null }
    "DEPLOYER_ERR_PS2EXE"             = @{ T = 'Compilation failed during PS2EXE execution: {0}'; H = 'PS2EXE fail with error token'; F = $null }
    "DEPLOYER_ERR_WIX_INSTALL"        = @{ T = 'WiX Toolset failed to install or path not resolved. Install WiX v3.11 manually from wixtoolset.org'; H = 'WiX install guidance'; F = $null }
    "DEPLOYER_ERR_CANDLE"             = @{ T = 'Candle compilation pipeline crashed.'; H = 'Candle pipeline error'; F = $null }
    "DEPLOYER_ERR_LIGHT"              = @{ T = 'Light linking pipeline crashed.'; H = 'Light pipeline error'; F = $null }
    "DEPLOYER_ERR_MSI_FORGE"          = @{ T = 'Compilation failed during WiX MSI forging: {0}'; H = 'MSI forge fail with error token'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # COMPILER SUBSYSTEM
    # ─────────────────────────────────────────────────────────────────────
    "COMPILER_MSI_BASE_EXE"           = @{ T = 'Forging base executable for MSI payload...'; H = 'Base EXE prep'; F = 'COMPILER' }
    "COMPILER_MSI_SUCCESS"            = @{ T = 'MSI Installer successfully generated: {0}'; H = 'MSI generation success'; F = 'COMPILER' }
    "COMPILER_CHECK_PS2EXE"           = @{ T = 'Checking for ps2exe module...'; H = 'ps2exe check notice'; F = 'COMPILER' }
    "COMPILER_INSTALL_PS2EXE"         = @{ T = 'ps2exe missing. Attempting self-healing (Install-Module/winget)...'; H = 'ps2exe auto-install attempt'; F = 'COMPILER' }
    "COMPILER_INSTALL_WIX"            = @{ T = 'WiX missing. Attempting self-healing (winget)...'; H = 'WiX auto-install attempt'; F = 'COMPILER' }
    "COMPILER_EXE_SUCCESS"            = @{ T = 'Executable successfully generated: {0}'; H = 'EXE generation success with path token'; F = 'COMPILER' }
    "COMPILER_WIX_NOT_FOUND"          = @{ T = 'WiX not found. Attempting winget install...'; H = 'WiX winget fallback'; F = 'COMPILER' }
    "COMPILER_WIX_FALLBACK"           = @{ T = 'WiX Toolset fallback failed. Emitting Portable ZIP.'; H = 'WiX fallback to ZIP'; F = 'COMPILER' }

    # ─────────────────────────────────────────────────────────────────────
    # SYSTEM & DEPENDENCIES (ADDITIONS)
    # ─────────────────────────────────────────────────────────────────────
    "DEP_SQLITE_DOWNLOADING"          = @{ T = 'Downloading SQLite payload...'; H = 'SQLite background download start'; F = 'SYSTEM' }
    "DEP_SQLITE_EXTRACTED"            = @{ T = 'SQLite payload extracted to Environment module successfully.'; H = 'Post-download extraction success'; F = 'SYSTEM' }
    "DEP_BINARIES_MISSING"            = @{ T = '[SYSTEM] Binaries module not loaded.'; H = 'Module initialization failure'; F = 'ERROR' }
    "DB_OFFLINE"                      = @{ T = 'Database Offline.'; H = 'Database connectivity lost'; F = 'WARN' }
    "SYS_MEM_CRITICAL"                = @{ T = 'Host memory critical (<20%). Forcing database memory spill.'; H = 'Low memory safety trigger'; F = 'PERF_WARN' }
    "SYS_ACCESS_DENIED_DRIVE"         = @{ T = 'Access Denied. Hardware lockdown on {0}'; H = 'Drive access failure with token'; F = 'PRIV_FATAL' }

    # ─────────────────────────────────────────────────────────────────────
    # COMPILER & MSI (ADDITIONS)
    # ─────────────────────────────────────────────────────────────────────
    "COMPILER_WIX_DOWNLOADING"        = @{ T = 'Downloading WiX Toolset binaries (Silent)...'; H = 'WiX background download'; F = 'COMPILER' }
    "COMPILER_MSI_DOWNGRADE"          = @{ T = 'A newer version of SCAPE is already installed.'; H = 'MSI Installer downgrade error'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # NATIVE & KERNEL (ADDITIONS)
    # ─────────────────────────────────────────────────────────────────────
    "NATIVE_LINUX_DIAG"               = @{ T = '[LINUX] Routing to smartctl / fsck pipeline...'; H = 'Linux diagnostic redirection'; F = 'HINT' }
    "NATIVE_LINUX_ISOLATE"            = @{ T = '[LINUX] Routing to umount / dd native pipeline...'; H = 'Linux isolation redirection'; F = 'HINT' }
    "NATIVE_JOURNAL_EXPORTED"         = @{ T = 'Journal exported to {0}. Processing entries...'; H = 'USN Journal extraction success'; F = 'FSUTIL' }

    # ─────────────────────────────────────────────────────────────────────
    # BOOT & IGNITION SEQUENCE
    # ─────────────────────────────────────────────────────────────────────
    "ERR_ADMIN_REQUIRED"              = @{ T = 'Administrator privileges are strictly required.'; H = 'Admin requirement error'; F = $null }
    "ERR_BOOT_SECTOR_READ"            = @{ T = 'Failed to read Boot Sector.'; H = 'Boot sector read error'; F = 'IO_FATAL' }
    "ERR_SUPERBLOCK_READ"             = @{ T = 'Failed to read EXT Superblock.'; H = 'EXT superblock read error'; F = 'IO_FATAL' }
    "BOOT_FATAL_MATRIX"               = @{ T = 'Failed to load foundational matrix: {0}'; H = 'Matrix load fatal with error token'; F = 'FATAL' }
    "BOOT_PRESS_ENTER_EXIT"           = @{ T = 'Press ENTER to exit...'; H = 'Exit prompt'; F = $null }
    "BOOT_FATAL_INTEROP"              = @{ T = 'Failed to load foundational Interop or Language matrix.'; H = 'Interop/Language matrix fatal'; F = 'FATAL' }
    "PROMPT_EXE_NAME"                 = @{ T = 'Output executable name (default: SCAPE.exe)'; H = 'EXE name input prompt'; F = $null }
    "IO_RESILIENT_MISSING"            = @{ T = 'Resilient I/O module missing.'; H = 'Missing I/O module error'; F = $null }

    "SYS_BOOT_OK"                     = @{ T = 'Engine ready. Lang: {0} | Mode: {1}'; F = 'INFO' }
    "SYS_ASSET_WARN"                  = @{ T = '[{0}] Asset ''{1}'' skipped or failed to load.'; F = 'WARN' }

    "BOOT_INIT_MODULES"               = @{ T = 'Initializing dynamic PowerShell module mesh into memory...'; H = 'Module init start'; F = 'BOOT_SEQ' }
    "BOOT_MODULE_LOADED"              = @{ T = "  [+] Module node '{0}' successfully loaded into runtime."; H = 'Module load success with name token'; F = $null }
    "BOOT_MODULE_FAIL"                = @{ T = "[BOOT_CRITICAL] Failed to load module node '{0}': {1}"; H = 'Module load fail with name/error tokens'; F = $null }
    "BOOT_IMPORT_FATAL"               = @{ T = '[BOOT_FATAL] Unrecoverable module import architecture failure: {0}'; H = 'Import architecture fatal with error token'; F = $null }
    "BOOT_VERIFY_ENV"                 = @{ T = 'Verifying hardware infrastructure and executing privilege escalation routines...'; H = 'Environment verification start'; F = 'BOOT_SEQ' }
    "BOOT_PRIV_ELEVATED"              = @{ T = 'Access Granted: SeBackupPrivilege & SeRestorePrivilege securely elevated.'; H = 'Privilege elevation success'; F = 'BOOT_SANCTUARY' }
    "BOOT_PRIV_FAIL"                  = @{ T = 'Privilege Escalation Failed. Access to locked raw structures will be denied.'; H = 'Privilege elevation failure'; F = 'BOOT_SANCTUARY_ERR' }
    "BOOT_ENV_PARTIAL"                = @{ T = 'Core subsystem initialized, but encountered non-fatal partial errors.'; H = 'Partial init warning'; F = 'BOOT_WARN' }
    "BOOT_SAMBA_AUTO"                 = @{ T = 'Samba Vault auto-detected and securely engaged at local mount {0}'; H = 'Samba auto-mount success with drive token'; F = 'BOOT_NETWORK' }
    "BOOT_SAMBA_FAIL"                 = @{ T = 'Samba auto-lock protocol failed to secure connection: {0}'; H = 'Samba auto-mount fail with error token'; F = 'BOOT_NETWORK' }
    "BOOT_READY"                      = @{ T = 'SCAPE Core Engine Offline and safely detached from hardware.'; H = 'Engine ready/offline notice'; F = 'SYSTEM_STATE' }
    "BOOT_WELCOME"                    = @{ T = 'Welcome to SCAPE Recovery System - Advanced Forensic Engine v1.0'; H = 'Welcome banner'; F = $null }
    "BOOT_ESC_ABORT"                  = @{ T = 'Press [ENTER] to accept risk, or [ESC] to safely abort boot sequence.'; H = 'Boot risk acceptance prompt'; F = $null }

    "IGNITE_INIT"                     = @{ T = 'Booting SCAPE Matrix (v1.0.0)...'; H = 'Ignition start'; F = 'SYSTEM' }
    "IGNITE_PILAR_LOAD"               = @{ T = 'Activating Foundational Pillar: {0}...'; H = 'Pillar activation with name token'; F = 'SYSTEM' }
    "IGNITE_PILAR_FAIL"               = @{ T = 'Critical failure awakening pillar {0}: {1}'; H = 'Pillar fail with name/error tokens'; F = 'FATAL' }
    "IGNITE_PILAR_MISSING"            = @{ T = "Mandatory pillar '{0}' not found in Payload dictionary!"; H = 'Missing pillar fatal with name token'; F = 'FATAL' }
    "IGNITE_MATRIX_VALIDATION"        = @{ T = 'Validating Payload Matrix...'; H = 'Matrix validation start'; F = 'SYSTEM' }
    "IGNITE_MODULE_MAPPED"            = @{ T = '  [+] Module mapped for Deploy: {0}'; H = 'Module mapped with name token'; F = $null }
    "IGNITE_DEPLOYER_INJECT"          = @{ T = 'Injecting Factory engine...'; H = 'Factory injection notice'; F = 'SYSTEM' }
    "IGNITE_LOG_FAIL"                 = @{ T = 'Log system unresponsive after injection.'; H = 'Log injection failure'; F = $null }
    "IGNITE_DEPLOY_FAIL"              = @{ T = 'Failed to launch Start-ScapeDeployment: {0}'; H = 'Deploy launch fail with error token'; F = 'FATAL' }
    "IGNITE_DEPLOYER_MISSING"         = @{ T = 'DeployerPayload (The Factory) not found in memory!'; H = 'Missing deployer fatal'; F = 'FATAL' }

    # ─────────────────────────────────────────────────────────────────────
    # DEPLOYER PROCESS MANAGEMENT
    # ─────────────────────────────────────────────────────────────────────
    "DEPLOYER_PROCESS_CLEANUP"        = @{ T = 'Active instances detected. Terminating processes for clean purge...'; H = 'Process cleanup start'; F = 'DEPLOYER' }
    "DEPLOYER_PURGE_SUCCESS"          = @{ T = 'Previous architecture purged successfully.'; H = 'Purge success notice'; F = 'DEPLOYER' }
    "DEPLOYER_PURGE_BUSY_WARN"        = @{ T = 'Output directory is busy. Old build moved to temporary trash path: {0}'; H = 'Purge busy fallback with path token'; F = 'DEPLOYER' }

    # ─────────────────────────────────────────────────────────────────────
    # AUDIT & FORENSIC MANIFEST
    # ─────────────────────────────────────────────────────────────────────
    "AUDIT_MANIFEST_DEPLOY"           = @{ T = 'Forensic JSON Manifest deployed securely to: {0} [Status: {1}]'; H = 'Manifest deploy with path/status tokens'; F = 'AUDIT_SYSTEM' }
    "AUDIT_MANIFEST_FAIL"             = @{ T = 'Critical failure writing JSON manifest/checksum data: {0}'; H = 'Manifest write fail with error token'; F = 'AUDIT_FATAL' }
    "AUDIT_REPORT_GEN"                = @{ T = 'Comprehensive JSON Audit Report cleanly generated at: {0}'; H = 'Report generation success with path token'; F = 'AUDIT_SYSTEM' }
    "AUDIT_REPORT_FAIL"               = @{ T = 'Critical failure compiling final JSON audit report: {0}'; H = 'Report compile fail with error token'; F = 'AUDIT_FATAL' }
    "AUDIT_INIT_OK"                   = @{ T = 'Forensic audit ledger initialized successfully at: {0}'; H = 'Audit module initialization success with log path token'; F = 'AUDIT_SYSTEM' }
    "AUDIT_INTEGRITY_VERIFIED"        = @{ T = 'VERIFIED_EXACT_MATCH'; H = 'Integrity verification success indicator'; F = $null }
    "AUDIT_INTEGRITY_MISMATCH"        = @{ T = 'CRITICAL_SIZE_MISMATCH'; H = 'Integrity mismatch error indicator'; F = $null }
    "AUDIT_HASH_COMPUTED"             = @{ T = 'SHA256 Cryptographic Checksum: {0}'; H = 'Hash display with checksum token'; F = 'AUDIT_HASH' }
    "COMPLIANCE_INIT_OK"              = @{ T = 'Compliance engine online. Segments loaded: {0} | Hash algorithm: {1}.'; H = 'Compliance initialization success with segment count and algorithm'; F = 'COMPLIANCE' }
    "COMPLIANCE_MISSING"              = @{ T = 'Compliance segment [{0}] missing ({1}). Algorithm: {2}.'; H = 'Compliance missing segment warning with segment/reason/algorithm'; F = 'COMPLIANCE_WARN' }
    "COMPLIANCE_MISMATCH"             = @{ T = 'Integrity mismatch in segment [{0}] | Expected: {1} | Actual: {2} | Algorithm: {3}.'; H = 'Compliance hash mismatch with segment and hash details'; F = 'COMPLIANCE_ERR' }
    "IO_BIT_ERROR"                    = @{ T = 'Resilient bitwise read/write operation failed after retry budget exhaustion.'; H = 'Bitwise/resilience operation fatal error'; F = 'IO_FATAL' }
    "LOG_ROTATED"                     = @{ T = 'Log rotation completed. Archived: {0} | Active: {1} | Rotation: {2}.'; H = 'Logger rotation completion with archive/new file and counter'; F = 'LOGGER' }

    # ─────────────────────────────────────────────────────────────────────
    # ARCHIVE / CARVING ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "ARCHIVE_ENUMERATING"             = @{ T = 'Enumerating database nodes for targeted files...'; H = 'Archive enumeration start'; F = 'ARCHIVE_ENGINE' }
    "ARCHIVE_BAR_TOTAL"               = @{ T = 'TOTAL_DB_NODES: {0} | ACTIVELY_TAGGED: {1} | CORRUPT_ERRORS: {2} | SCAN_RATE: {3} nodes/sec'; H = 'Archive progress bar with stat tokens'; F = $null }
    "ARCHIVE_COMPLETE"                = @{ T = 'Database targeted tagging cycle completely finished.'; H = 'Archive cycle completion'; F = 'ARCHIVE_ENGINE' }
    "ARCHIVE_NO_FILES"                = @{ T = 'No files matching criteria found to process in the current selection.'; H = 'No matching files warning'; F = 'ARCHIVE_WARN' }

    "CARVE_NTFS_SIG"                  = @{ T = "Valid NTFS 'FILE' record structure identified at physical offset {0}"; H = 'NTFS signature hit with offset token'; F = 'CARVE_HIT' }
    "CARVE_EXT4_SIG"                  = @{ T = 'Valid EXT4 inode magic (0xEF53/0xF30A) identified at physical offset {0}'; H = 'EXT4 signature hit with offset token'; F = 'CARVE_HIT' }
    "CARVE_BTRFS_SIG"                 = @{ T = 'Valid BTRFS node/leaf structure identified at physical offset {0}'; H = 'BTRFS signature hit with offset token'; F = 'CARVE_HIT' }
    "CARVE_ZFS_SIG"                   = @{ T = 'Valid ZFS label/uberblock magic identified at physical offset {0}'; H = 'ZFS signature hit with offset token'; F = 'CARVE_HIT' }
    "CARVE_RECORD_ADDED"              = @{ T = 'Raw orphaned record safely buffered to SQL persistence engine.'; H = 'Record buffer success'; F = 'CARVE_STATE' }

    # ─────────────────────────────────────────────────────────────────────
    # ERROR HANDLING & MISC
    # ─────────────────────────────────────────────────────────────────────
    "MANIFEST_NOT_FOUND"              = @{ T = 'Manifest node not found: {0}'; H = 'Missing manifest node with key token'; F = 'ORCH_FATAL' }
    "ROUTER_FATAL"                    = @{ T = '{0}'; H = 'Generic router fatal with error token'; F = 'ROUTER_FATAL' }
    "ROUTE_EXEC_FAIL"                 = @{ T = '{0}'; H = 'Route execution fail with error token'; F = 'ROUTE_EXEC_FAIL' }
    "ORCH_MISSING_BINDING"            = @{ T = 'Missing Controller Binding: {0}'; H = 'Missing binding with key token'; F = 'ORCH_FATAL' }
    "CONFIRM_REGEX"                   = @{ T = '^[yY]'; H = 'Regex pattern for English confirmation'; F = $null }

    "ERR_DRIVE_SELECTION_NONE"        = @{ T = 'No viable, mounted storage targets detected by the WMI subsystem.'; H = 'No drives detected error'; F = 'INPUT_ERR' }
    "ERR_DRIVE_LETTERS_EXHAUSTED"     = @{ T = 'NO_AVAILABLE_DRIVE_LETTERS: The operating system has exhausted the A-Z drive letter pool.'; H = 'Drive letters exhausted error'; F = 'OS_LIMIT_ERR' }
    "ERR_PATH_INVALID"                = @{ T = 'Invalid, malformed, or entirely inaccessible directory path provided.'; H = 'Invalid path error'; F = 'PATH_ERR' }
    "ERR_NO_ITEMS_SELECTED"           = @{ T = 'No logical items or directory trees selected for the extraction sequence.'; H = 'No selection error'; F = 'LOGIC_ERR' }
    "ERR_NO_STAGING"                  = @{ T = 'Local staging folder is strictly not defined. You must run an extraction sequence first.'; H = 'Missing staging error'; F = 'LOGIC_ERR' }
    "ERR_DEPENDENCY_FAIL"             = @{ T = 'Core dependency network resolution permanently failed after {0} strict retry attempts.'; H = 'Dependency resolution fail with count token'; F = 'NET_FATAL' }
    "ERR_INTEGRITY_CHECK"             = @{ T = 'Security integrity check heavily failed. The downloaded DLL dependency is either missing or catastrophically corrupted post-extraction.'; H = 'Integrity check failure'; F = 'BIN_FATAL' }
    "ERR_PERMISSION_DENIED"           = @{ T = 'Access forcefully denied by OS. You must re-initialize the SCAPE terminal as an Administrator.'; H = 'Permission denied error'; F = 'PRIV_FATAL' }
    "ERR_DISK_FULL"                   = @{ T = 'Insufficient physical disk space detected on target medium. Operation safely aborted to prevent crash.'; H = 'Disk full error'; F = 'IO_FATAL' }
    "ERR_CORRUPTED_RECORD"            = @{ T = 'Severely corrupted MFT/Inode record structurally detected. Skipping parsing to prevent engine fault.'; H = 'Corrupted record warning'; F = 'PARSE_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # MISCELLANEOUS & USER PROMPTS
    # ─────────────────────────────────────────────────────────────────────
    "MISC_OR"                         = @{ T = ' ou '; H = 'Logical OR separator'; F = $null }
    "MISC_PROGRESS"                   = @{ T = 'OPERATION_PROGRESS'; H = 'Visual activity indicator'; F = 'UI' }
    "MISC_PRESS_ENTER"                = @{ T = 'Press the [ENTER] key to safely return to the Maestro main menu...'; H = 'Return prompt'; F = $null }
    "MISC_PRESS_ENTER_CONTINUE"       = @{ T = 'Press the [ENTER] key to acknowledge and continue operation...'; H = 'Continue prompt'; F = $null }
    "MISC_PRESS_ENTER_TERMINAL"       = @{ T = 'Press the [ENTER] key to exit...'; H = 'Terminal exit prompt'; F = $null }
    "MISC_ABORT_PROMPT"               = @{ T = 'Press the [ENTER] key to immediately abort the current sequence...'; H = 'Abort prompt'; F = $null }
    "MISC_EXIT_CONFIRM"               = @{ T = 'DANGER: Are you certain you want to exit the SCAPE Engine? Unsaved streams may terminate. (y/N): '; H = 'Exit confirmation prompt'; F = $null }
    "MISC_DOWNLOAD_RETRY"             = @{ T = 'Download connection dropped. Retry protocol triggered... ({0} safe attempts remaining)'; H = 'Download retry with count token'; F = 'NET_WARN' }
    "MISC_YES"                        = @{ T = 'y'; H = 'Yes response token'; F = $null }
    "MISC_NO"                         = @{ T = 'n'; H = 'No response token'; F = $null }
    "MISC_YES_NO"                     = @{ T = '(y/N): '; H = 'Yes/No prompt lowercase default'; F = $null }
    "MISC_YES_NO_UPPER"               = @{ T = '(Y/N): '; H = 'Yes/No prompt uppercase'; F = $null }
    "MISC_OPERATION_SUCCESS"          = @{ T = 'The requested operation pipeline completed successfully with zero fatal errors.'; H = 'Operation success notice'; F = 'SYS_OK' }
    "MISC_OPERATION_FAILED"           = @{ T = 'The requested operation pipeline failed. Please review the detailed exception logs printed above.'; H = 'Operation failure notice'; F = 'SYS_FAIL' }
    "MISC_WAITING"                    = @{ T = 'System is waiting for operational clearance...'; H = 'Waiting status'; F = $null }
    "MISC_CANCELLED"                  = @{ T = 'Operation intentionally cancelled by user override.'; H = 'User cancellation notice'; F = 'SYS_HALT' }
    "MISC_PRESS_ENTER_DEGRADED"       = @{ T = 'Press the [ENTER] key to log the fault and attempt continuation in DEGRADED engine mode...'; H = 'Degraded mode prompt'; F = $null }
    "MISC_ENTER_PATH_MANUALLY"        = @{ T = 'Auto-picker failed. Please enter the absolute destination path manually (e.g., D:\SecureBackup): '; H = 'Manual path fallback prompt'; F = $null }
    "MISC_ACCEPT_RISK"                = @{ T = 'Press the [ENTER] key to officially accept the operational risk and forcefully proceed...'; H = 'Risk acceptance prompt'; F = $null }
    "MISC_LOG_AND_CONTINUE"           = @{ T = 'Press the [ENTER] key to write the fault to the log and forcefully continue the compilation...'; H = 'Log and continue prompt'; F = $null }
    "MISC_PRESS_ENTER_EXIT"           = @{ T = 'Press the [ENTER] key to close the terminal and exit...'; H = 'Terminal exit prompt'; F = $null }
    "MISC_RESTART_STATE_MACHINE"      = @{ T = 'Press the [ENTER] key to forcefully restart the Maestro State Machine...'; H = 'State machine restart prompt'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # PERFORMANCE METRICS
    # ─────────────────────────────────────────────────────────────────────
    "PERF_RAM_STRATEGY"               = @{ T = 'Validated RAM available: {0} GB | Estimated Target size: {1} GB -> Assigned Allocation Strategy: {2}'; H = 'RAM strategy with avail/target/strategy tokens'; F = 'PERF_METRIC' }
    "PERF_THREAD_AUTO"                = @{ T = 'Auto-tuning data transfer threads dynamically to {0} based on analyzed destination medium.'; H = 'Thread auto-tune with count token'; F = 'PERF_TUNE' }
    "PERF_LOW_MEM_WARNING"            = @{ T = 'Extremely low physical memory detected on host. Force-switching pipeline to DISK_SPOOL mode to prevent OOM crash.'; H = 'Low memory warning'; F = 'PERF_WARN' }
    "PERF_HIGH_IO_WARNING"            = @{ T = 'Exceptionally high I/O load registered on storage controller. Automated throttling protocols engaged.'; H = 'High I/O warning'; F = 'PERF_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # DEPENDENCY MANAGEMENT
    # ─────────────────────────────────────────────────────────────────────
    "DEP_ARM64_FALLBACK"              = @{ T = 'ARM64 native DLL not embedded. Falling back to x64 (emulation).'; H = 'ARM64 fallback notice'; F = 'SQLITE' }
    "DEP_EXTRACT_SUCCESS"             = @{ T = 'Native dependencies extracted from memory matrix successfully.'; H = 'Dependency extract success'; F = 'SYSTEM' }
    "DEP_LOCAL_DETECTED"              = @{ T = 'Local dependencies detected (DEV_MODE).'; H = 'Local deps detected'; F = 'SYSTEM' }
    "DEP_MISSING_ERROR"               = @{ T = 'ERROR: Files not found on disk and not embedded in memory.'; H = 'Missing dependencies error'; F = 'SQLITE' }
    "DEP_SIZE_MISMATCH"               = @{ T = 'Managed DLL size mismatch post-extraction.'; H = 'DLL size mismatch error'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # CONFIGURATION VALUES
    # ─────────────────────────────────────────────────────────────────────
    "CONFIG_VAL_EFFICIENCY"           = @{ T = 'EFFICIENCY'; H = 'Engine mode: Efficiency'; F = $null }
    "CONFIG_VAL_REDUNDANCY"           = @{ T = 'REDUNDANCY'; H = 'Engine mode: Redundancy'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # WAIT / RETURN PROMPTS
    # ─────────────────────────────────────────────────────────────────────
    "WAIT_ENTER_CONTINUE"             = @{ T = 'Press ENTER to continue...'; H = 'Continue wait prompt'; F = $null }
    "WAIT_ENTER_ESC_PROMPT"           = @{ T = 'Press [ENTER] to proceed, or [ESC] to cancel.'; H = 'Proceed/cancel prompt'; F = $null }
    "WAIT_ENTER_ACCEPT_RISK"          = @{ T = 'Press [ENTER] to accept the risk and proceed, or [ESC] to abort.'; H = 'Risk accept/abort prompt'; F = $null }
    "WAIT_ENTER_RETURN"               = @{ T = 'Press ENTER to return...'; H = 'Return wait prompt'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # SYSTEM DETECTION
    # ─────────────────────────────────────────────────────────────────────
    "SYS_BARE_METAL"                  = @{ T = 'Bare Metal'; H = 'Physical host indicator'; F = $null }
    "SYS_NA"                          = @{ T = 'N/A'; H = 'Not applicable indicator'; F = $null }
    "SYS_VM_DETECTED"                 = @{ T = 'Virtual Machine Detected (Hypervisor: {0})'; H = 'VM detection with hypervisor token'; F = 'SYSTEM' }
    "SYS_HOST_DETECTED"               = @{ T = 'Physical Host Detected (Bare Metal)'; H = 'Bare metal detection'; F = 'SYSTEM' }

    # ─────────────────────────────────────────────────────────────────────
    # FORENSIC WALK / TRAVERSAL
    # ─────────────────────────────────────────────────────────────────────
    "FOR_MFT_WALK"                    = @{ T = 'Walking MFT tree deterministically... Record {0} / {1}'; H = 'MFT walk progress with current/total tokens'; F = $null }
    "FOR_EXT_WALK"                    = @{ T = 'Walking Inode tree deterministically... Inode {0} / {1}'; H = 'Inode walk progress with current/total tokens'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # SAMBA / NETWORK MOUNT REMOVAL
    # ─────────────────────────────────────────────────────────────────────
    "SAMBA_UNMOUNT_ALL"               = @{ T = 'Removing all network mounts...'; H = 'Bulk unmount start'; F = $null }
    "SAMBA_UNMOUNT_SINGLE"            = @{ T = 'Removing mapped drive {0}...'; H = 'Single unmount with drive token'; F = $null }
    "SAMBA_SELECT_IP"                 = @{ T = 'MULTIPLE SMB HOSTS DETECTED. SELECT TARGET:'; H = 'Multi-host selection'; F = $null }
    "SAMBA_MGR_TITLE"                 = @{ T = 'NETWORK MOUNT MANAGEMENT'; H = 'Mount manager title'; F = $null }
    "SAMBA_MGR_REMOVE_ALL"            = @{ T = '[ REMOVE ALL NETWORK DRIVES ]'; H = 'Remove all menu option'; F = $null }
    "SAMBA_MGR_NONE"                  = @{ T = 'No active network mounts detected.'; H = 'No mounts notice'; F = $null }
    "SAMBA_MGR_REMOVED"               = @{ T = 'Drive {0} ({1}) successfully unmounted.'; H = 'Unmount success with drive/path tokens'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # NATIVE BRIDGE / SAFETY CONTROLS
    # ─────────────────────────────────────────────────────────────────────
    "ERR_SYSTEM_DRIVE_LOCK"           = @{ T = 'Operation blocked: Cannot offline or repair the active System Drive.'; H = 'System drive protection error'; F = 'SAFETY_CRITICAL' }
    "NET_NATIVE_ISOLATION_OK"         = @{ T = 'Target disk is now OFFLINE. Exclusive DASD access granted.'; H = 'Disk isolation success'; F = 'DISKPART' }
    "NET_NATIVE_JOURNAL_START"        = @{ T = 'Harvesting NTFS USN Journal for recent deletions...'; H = 'Journal harvest start'; F = 'FSUTIL' }
    "UI_NATIVE_HYBRID_RUNNING"        = @{ T = 'SCAPE + WinFR dual-engine scan in progress. Please standby...'; H = 'Hybrid scan in progress'; F = 'HYBRID' }
    "UI_NATIVE_DIAG_FAIL"             = @{ T = 'Hardware reports critical failures. Minimal I/O recommended.'; H = 'Hardware diagnostic failure'; F = 'STORDIAG_ALERT' }

    # ─────────────────────────────────────────────────────────────────────   
    # THIRD_PARTY_TOOLS
    "TOOL_AUTOSPSY"                   = @{ T = "AUTOSPSY (Third-Party)"; H = "Launch AUTOSPSY forensics tool"; F = "1" }
    "TOOL_VOLATILITY"                 = @{ T = "VOLATILITY (Third-Party)"; H = "Launch VOLATILITY forensics tool"; F = "1" }
    "TOOL_FTKIMAGER"                  = @{ T = "FTKIMAGER (Third-Party)"; H = "Launch FTKIMAGER forensics tool"; F = "1" }
    "TOOL_KAPE"                       = @{ T = "KAPE (Third-Party)"; H = "Launch KAPE forensics tool"; F = "1" }
    "TOOL_TESTDISK"                   = @{ T = "TESTDISK (Third-Party)"; H = "Launch TESTDISK forensics tool"; F = "1" }
    "TOOL_PHOTOREC"                   = @{ T = "PHOTOREC (Third-Party)"; H = "Launch PHOTOREC forensics tool"; F = "1" }
    "TOOL_MAGNET"                     = @{ T = "MAGNET (Third-Party)"; H = "Launch MAGNET forensics tool"; F = "1" }
    "TOOL_WIRESHARK"                  = @{ T = "WIRESHARK (Third-Party)"; H = "Launch WIRESHARK forensics tool"; F = "1" }
    "TOOL_TCPDUMP"                    = @{ T = "TCPDUMP (Third-Party)"; H = "Launch TCPDUMP forensics tool"; F = "1" }
    "TOOL_NMAP"                       = @{ T = "NMAP (Third-Party)"; H = "Launch NMAP forensics tool"; F = "1" }
    "TOOL_SYSINTERNALS"               = @{ T = "SYSINTERNALS (Third-Party)"; H = "Launch SYSINTERNALS forensics tool"; F = "1" }
    "TOOL_REGCFG"                     = @{ T = "REGCFG (Third-Party)"; H = "Launch REGCFG forensics tool"; F = "1" }
    "TOOL_MEMORYZE"                   = @{ T = "MEMORYZE (Third-Party)"; H = "Launch MEMORYZE forensics tool"; F = "1" }
    "TOOL_REDLINE"                    = @{ T = "REDLINE (Third-Party)"; H = "Launch REDLINE forensics tool"; F = "1" }
    "TOOL_PLASO"                      = @{ T = "PLASO (Third-Party)"; H = "Launch PLASO forensics tool"; F = "1" }
    "TOOL_LOG2TIMELINE"               = @{ T = "LOG2TIMELINE (Third-Party)"; H = "Launch LOG2TIMELINE forensics tool"; F = "1" }
    "TOOL_XWAYS"                      = @{ T = "XWAYS (Third-Party)"; H = "Launch XWAYS forensics tool"; F = "1" }
    "TOOL_SLEUTHKIT"                  = @{ T = "SLEUTHKIT (Third-Party)"; H = "Launch SLEUTHKIT forensics tool"; F = "1" }
    "TOOL_DD"                         = @{ T = "DD (Third-Party)"; H = "Launch DD forensics tool"; F = "1" }

    # ─────────────────────────────────────────────────────────────────────
    "TOOL_DISKPART"                   = @{ T = 'DISKPART (Isolation & Partitioning)'; H = 'Force offline or manage partitions'; F = '1' }
    "TOOL_DISKPART_DESC"              = @{ T = 'Force drive offline to prevent OS interference. WARNING: Disconnects all active sessions.'; H = 'DiskPart warning hint'; F = 'WARN' }
    "TOOL_CHKDSK"                     = @{ T = 'CHKDSK (File System Repair)'; H = 'Scan and fix logical file system errors'; F = '2' }
    "TOOL_CHKDSK_DESC"                = @{ T = 'Deep scan of metadata structures. May trigger long-running disk operations.'; H = 'ChkDsk hint'; F = 'LOG' }
    "TOOL_WINFR"                      = @{ T = 'WINFR (Microsoft File Recovery)'; H = 'Deep signature-based recovery engine'; F = '3' }
    "TOOL_WINFR_DESC"                 = @{ T = 'Leverages Microsoft recovery algorithms. Requires destination drive for safe extraction.'; H = 'WinFR hint'; F = 'LOG' }
    "TOOL_FSUTIL"                     = @{ T = 'FSUTIL (USN Journal Harvest)'; H = 'Extract recent deletion logs from NTFS'; F = '4' }
    "TOOL_FSUTIL_DESC"                = @{ T = 'Parses NTFS USN journal to recover recently deleted file metadata entries.'; H = 'Fsutil hint'; F = 'LOG' }
    "TOOL_STORDIAG"                   = @{ T = 'STORDIAG (Hardware Diagnostics)'; H = 'Generate comprehensive storage health report'; F = '5' }
    "TOOL_STORDIAG_DESC"              = @{ T = 'Runs built-in storage diagnostics. Generates detailed hardware telemetry report.'; H = 'Stordiag hint'; F = 'LOG' }
    "TOOL_SFC"                        = @{ T = 'SFC (System File Checker)'; H = 'Scan and restore corrupted Windows system files'; F = '6' }
    "TOOL_DISM"                       = @{ T = 'DISM (Deployment Image Servicing)'; H = 'Repair Windows image and components'; F = '7' }
    "TOOL_EVENTVWR"                   = @{ T = 'EVENTVWR (Event Viewer)'; H = 'Access system event logs for forensics'; F = '8' }
    "TOOL_FILEHASH"                   = @{ T = 'FILEHASH (Checksum Generation)'; H = 'Calculate hashes for file integrity'; F = '9' }
    "TOOL_NATIVE_FORENSICS"           = @{ T = 'NATIVE TOOLS (Windows Built-in)'; H = 'Access built-in system tools'; F = 'N' }
    "TOOL_THIRDPARTY_FORENSICS"       = @{ T = 'THIRD-PARTY TOOLS (Sysinternals & Externals)'; H = 'Access specialized external forensic utilities'; F = 'T' }
    "TOOL_WINDIRSTAT"                 = @{ T = 'WINDIRSTAT (Disk Usage & Cleanup)'; H = 'Visual disk usage statistics and cleanup'; F = 'W' }
    "TOOL_PROCEXP"                    = @{ T = 'PROCESS EXPLORER (Sysinternals)'; H = 'Advanced process management and tracking'; F = 'P' }
    "TOOL_AUTORUNS"                   = @{ T = 'AUTORUNS (Sysinternals)'; H = 'Manage auto-starting programs and services'; F = 'A' }
    "TOOL_EVERYTHING"                 = @{ T = 'EVERYTHING (Voidtools)'; H = 'Instant file and folder search engine'; F = 'E' }

    # ─────────────────────────────────────────────────────────────────────
    # LOGGING & TELEMETRY
    # ─────────────────────────────────────────────────────────────────────
    "LOG_INFO"                        = @{ T = 'INFO_OPERATIONAL_MSG'; H = 'Standard operational message'; F = 'INFO' }
    "LOG_DEBUG"                       = @{ T = 'DEBUG_DIAGNOSTIC_TRACE'; H = 'Deep diagnostic trace'; F = 'DEBUG' }
    "LOG_WARN"                        = @{ T = 'WARNING_EXECUTION_ANOMALY'; H = 'Non-fatal execution anomaly'; F = 'WARN' }
    "LOG_ERR"                         = @{ T = 'ERROR_OPERATIONAL_FAILURE'; H = 'Specific operation failure'; F = 'ERROR' }
    "LOG_FATAL"                       = @{ T = 'FATAL_ENGINE_HALT'; H = 'Critical engine halt'; F = 'FATAL' }
    "LOG_SYSTEM"                      = @{ T = 'SYSTEM_KERNEL_MSG'; H = 'Kernel-level core message'; F = 'SYSTEM' }
    "LOG_METRIC"                      = @{ T = 'METRIC_PERF_TELEMETRY'; H = 'Performance telemetry data'; F = 'METRIC' }
    "LOG_TRACE"                       = @{ T = 'TRACE_INST_TRACKING'; H = 'Instruction level tracking'; F = 'TRACE' }

    # ─────────────────────────────────────────────────────────────────────
    # FILE SYSTEMS
    # ─────────────────────────────────────────────────────────────────────
    "FS_NTFS"                         = @{ T = 'NTFS_FILE_SYSTEM'; H = 'New Technology File System'; F = 'FS' }
    "FS_APFS"                         = @{ T = 'APFS_APPLE_CONTAINER'; H = 'Apple File System'; F = 'FS' }
    "FS_EXT4"                         = @{ T = 'EXT4_LINUX_NATIVE'; H = 'Fourth Extended Filesystem'; F = 'FS' }
    "FS_BTRFS"                        = @{ T = 'BTRFS_B_TREE_NODE'; H = 'B-Tree File System'; F = 'FS' }
    "FS_ZFS"                          = @{ T = 'ZFS_ZETTABYTE_POOL'; H = 'Zettabyte File System'; F = 'FS' }
    "FS_REFS"                         = @{ T = 'REFS_RESILIENT_FS'; H = 'Resilient File System'; F = 'FS' }
    "FS_XFS"                          = @{ T = 'XFS_EXTENDED_FS'; H = 'Extended File System (SGI)'; F = 'FS' }
    "FS_HFS"                          = @{ T = 'HFS_HIERARCHICAL_FS'; H = 'Hierarchical File System'; F = 'FS' }
    "FS_HFSX"                         = @{ T = 'HFSX_CASE_SENSITIVE'; H = 'HFS Plus (Case-sensitive)'; F = 'FS' }
    "FS_EXFAT"                        = @{ T = 'EXFAT_FLASH_TABLE'; H = 'Extended File Allocation Table'; F = 'FS' }
    "FS_FAT32"                        = @{ T = 'FAT32_LEGACY_TABLE'; H = 'Legacy File Allocation Table'; F = 'FS' }
    "FS_UDF"                          = @{ T = 'UDF_UNIVERSAL_FORMAT'; H = 'Universal Disk Format (Optical)'; F = 'FS' }
    "FS_JFS"                          = @{ T = 'JFS_JOURNALED_FS'; H = 'Journaled File System (IBM)'; F = 'FS' }
    "FS_F2FS"                         = @{ T = 'F2FS_FLASH_FRIENDLY'; H = 'Flash-Friendly File System'; F = 'FS' }
    "FS_ISO9660"                      = @{ T = 'ISO9660_STANDARD'; H = 'Standard CD-ROM File System'; F = 'FS' }
    "FS_PART_TABLE"                   = @{ T = 'PARTITION_TABLE_STRUCT'; H = 'Disk partition structure'; F = 'META' }
    "FS_DISK_IMAGE"                   = @{ T = 'VIRTUAL_DISK_IMAGE'; H = 'Disk image container (VMDK/VHDX/DMG)'; F = 'VIRT' }

    # ─────────────────────────────────────────────────────────────────────
    # HARDWARE & TOPOLOGY
    # ─────────────────────────────────────────────────────────────────────
    "HW_CPU"                          = @{ T = 'CPU_PROCESSOR_UNIT'; H = 'Central Processing Unit'; F = 'HW' }
    "HW_RAM"                          = @{ T = 'MEMORY_RAM_VOLATILE'; H = 'System volatile memory'; F = 'HW' }
    "HW_HDD"                          = @{ T = 'DISK_HDD_MECHANICAL'; H = 'Mechanical storage'; F = 'HW' }
    "HW_SSD"                          = @{ T = 'DISK_SSD_SOLID_STATE'; H = 'Solid state storage'; F = 'HW' }
    "HW_NVME"                         = @{ T = 'DISK_NVME_EXPRESS'; H = 'High-speed express storage'; F = 'HW' }
    "HW_USB"                          = @{ T = 'DISK_USB_EXTERNAL'; H = 'Universal Serial Bus Storage'; F = 'HW' }
    "HW_GPU"                          = @{ T = 'GPU_GRAPHICS_UNIT'; H = 'Graphics Processing Unit'; F = 'HW' }

    # ─────────────────────────────────────────────────────────────────────
    # STATUS & ENGINE STATES
    # ─────────────────────────────────────────────────────────────────────
    "STATUS_SUCCESS"                  = @{ T = 'OPERATION_SUCCESS'; H = 'Operation completed with no errors'; F = 'OK' }
    "STATUS_UNKNOWN"                  = @{ T = 'STATE_UNKNOWN'; H = 'Unidentified object or state'; F = 'WARN' }
    "STATUS_BUSY"                     = @{ T = 'ACTIVE_PROCESSING'; H = 'I/O stream actively engaged'; F = 'PROC' }

    # ─────────────────────────────────────────────────────────────────────
    # METADATA LABELS
    # ─────────────────────────────────────────────────────────────────────
    "META_ACCESSED"                   = @{ T = 'TIMESTAMP_ACCESSED'; H = 'Last access time'; F = 'META' }
    "META_CREATED"                    = @{ T = 'TIMESTAMP_CREATED'; H = 'Creation time'; F = 'META' }
    "META_MODIFIED"                   = @{ T = 'TIMESTAMP_MODIFIED'; H = 'Last modification time'; F = 'META' }
    "META_MFT_CHANGED"                = @{ T = 'MFT_RECORD_CHANGED'; H = 'MFT entry update timestamp'; F = 'META' }
    "META_FILENAME"                   = @{ T = 'PHYSICAL_FILENAME'; H = 'Name on storage medium'; F = 'META' }
    "META_PID"                        = @{ T = 'PROCESS_ID'; H = 'System Process Identifier'; F = 'SYS' }
    "META_OFFSET"                     = @{ T = 'PHYSICAL_OFFSET'; H = 'Raw byte offset on disk'; F = 'DASD' }

    # ─────────────────────────────────────────────────────────────────────
    # DOMAINS & MODULES
    # ─────────────────────────────────────────────────────────────────────
    "DOMAIN_ANALYSIS"                 = @{ T = 'ANALYSIS_SUBSYSTEM'; H = 'Core analysis engine'; F = 'SYS' }
    "DOMAIN_PARSING"                  = @{ T = 'METADATA_PARSING'; H = 'Deterministic record parsing'; F = 'SYS' }
    "DOMAIN_ARCHAEOLOGY"              = @{ T = 'ARCHAEOLOGY_MODE'; H = 'Deep raw sector carving'; F = 'SYS' }
    "DOMAIN_HARVESTER"                = @{ T = 'HARVESTER_ENGINE'; H = 'Bulk extraction engine'; F = 'SYS' }
    "DOMAIN_INFRA"                    = @{ T = 'INFRASTRUCTURE_LAYER'; H = 'System support layer'; F = 'SYS' }

    # ─────────────────────────────────────────────────────────────────────
    # TERMINAL CAPABILITIES TOGGLES
    # ─────────────────────────────────────────────────────────────────────
    "CAP_MENU_TITLE"                  = @{ T = 'TERMINAL CAPABILITIES'; H = 'Terminal capabilities menu title'; F = 'UI' }
    "CAP_TRUECOLOR"                   = @{ T = 'TrueColor (24-bit RGB)'; H = 'Enable full 24-bit color support. Disable to fallback to ANSI 16-color palette.'; F = 'UI' }
    "CAP_HYPERLINKS"                  = @{ T = 'Hyperlinks (OSC 8)'; H = 'Enable clickable hyperlinks in the terminal. Requires modern terminal emulator.'; F = 'UI' }
    "CAP_BRACKETEDPASTE"              = @{ T = 'Bracketed Paste Mode'; H = 'Distinguish pasted text from typed input. Prevents accidental execution.'; F = 'UI' }
    "CAP_MOUSETRACKING"               = @{ T = 'Mouse Tracking'; H = 'Enable mouse click and movement events for UI interaction.'; F = 'UI' }
    "CAP_ALTERNATESCREEN"             = @{ T = 'Alternate Screen Buffer'; H = 'Use separate screen buffer for full-screen TUIs. Preserves shell history.'; F = 'UI' }
    "CAP_FOCUSEVENTS"                 = @{ T = 'Focus In/Out Events'; H = 'Detect when terminal gains or loses focus.'; F = 'UI' }
    "CAP_KITTYKEYBOARD"               = @{ T = 'Kitty Keyboard Protocol'; H = 'Enhanced keyboard protocol for advanced key combinations. Experimental.'; F = 'UI' }
    "CAP_SIXELGRAPHICS"               = @{ T = 'Sixel Graphics'; H = 'Display bitmap graphics inline. Requires Sixel-capable terminal.'; F = 'UI' }
    "CAP_CSIUKEYBOARD"                = @{ T = 'CSIu Keyboard Protocol'; H = 'Modern keyboard input protocol for better modifier key handling.'; F = 'UI' }
    "CAP_FALLBACK256"                 = @{ T = 'Allow 256-color fallback'; H = 'Use 256-color palette when TrueColor is unavailable.'; F = 'UI' }
    "CAP_FALLBACK16"                  = @{ T = 'Allow 16-color fallback'; H = 'Use ANSI 16-color palette when 256-color is unavailable.'; F = 'UI' }

    "MENU_MAIN_RECOVERY"              = @{ T = 'RECOVERY ENGINE'; H = 'Full SCAPE recovery workflow panel.'; F = '6' }
    "MENU_RECOVERY_TITLE"             = @{ T = 'SYSTEM RECOVERY ENGINE & FORENSICS'; H = 'Title for the recovery menu'; F = 'UI' }
    "RC_BITWISE_TAGGING"              = @{ T = 'BITWISE TAGGING'; H = 'Bitwise operations menu'; F = 'A' }
    "RC_TOPOLOGY_SCAN"                = @{ T = 'TOPOLOGY SCAN'; H = 'Scan topology'; F = 'T' }
    "RC_BATCH_PROCESSING"             = @{ T = 'BATCH PROCESSING'; H = 'Batch operations'; F = 'B' }
    "RC_TARGET_ARCHAEOLOGY"           = @{ T = 'TARGET ARCHAEOLOGY'; H = 'Deep recovery'; F = 'R' }
    "RC_FILE_LABORATORY"              = @{ T = 'FILE LABORATORY'; H = 'File analysis'; F = 'L' }
    "RC_FORENSIC_TOOLS"               = @{ T = 'FORENSIC TOOLS'; H = 'Forensics tools menu'; F = 'F' }
    "RC_ROBOCOPY_ENGINE"              = @{ T = 'ROBOCOPY ENGINE'; H = 'Robocopy engine menu'; F = 'E' }
    "RC_TELEMETRY_SCAN"               = @{ T = 'TELEMETRY SCAN'; H = 'Hardware telemetry scan'; F = 'S' }
    "RC_CLOUD_SYNC"                   = @{ T = 'CLOUD SYNC'; H = 'Cloud synchronization subsystem'; F = '7' }
}