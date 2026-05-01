@{
    Segment = @{
        Name        = "behavior"
        Version     = "1.0.0"
        Description = "Operational limits, retry policies, timing, input handling (multi‑OS), and industrial automation constants"
        Dependencies = @("core")
        HashSHA256  = "PLACEHOLDER_BEHAVIOR_HASH"
    }

    # =========================================================================
    # OPERATIONAL LIMITS (Core system)
    # =========================================================================
    LIMITS = @{
        RAM_CRITICAL_PCT          = 0.20
        THERMAL_WARNING           = 75
        THERMAL_CRITICAL          = 85
        QUEUE_WARNING             = 5
        QUEUE_CRITICAL            = 10
        TIMEOUT_SECS              = 10
        SUCCESS_EXIT_MAX          = 8
        SUCCESS_EXIT_CODE_MAX     = 8
        MAX_DIR_DEPTH             = 20
        NET_SCAN_TIMEOUT_MS       = 80
        NET_SCAN_THREADS          = 256
        ROBOCOPY_RETRY_DEF        = 3
        ROBOCOPY_THREAD_AUTO      = 128
        ROBOCOPY_WAIT_DEF         = 10
        MAX_OPEN_FILES            = 256
        DB_TIMEOUT_MS             = 5000
        MAX_CONCURRENT_OPS        = 16
        OPERATION_QUEUE_SIZE      = 1000
        FILE_LOCK_RETRY_ATTEMPTS  = 3
        FILE_LOCK_RETRY_DELAY_MS  = 100
        CRITICAL_SECTION_TIMEOUT_MS = 5000
    }

    # =========================================================================
    # BEHAVIOR (Retry, timers, throttling, state machine)
    # =========================================================================
    BEHAVIOR = @{
        RETRY_MAX_ATTEMPTS        = 5
        RETRY_BASE_DELAY_MS       = 100
        RETRY_BACKOFF_FACTOR      = 2.0
        RETRY_MAX_DELAY_MS        = 30000
        RETRY_JITTER_MS           = 50
        RETRY_CONDITIONS          = @("transient", "timeout", "busy", "lock", "device_not_ready")

        TIMER_DEFAULT_MS          = 5000
        TIMER_SHORT_MS            = 500
        TIMER_LONG_MS             = 60000
        TIMER_VERYLONG_MS         = 300000
        WATCHDOG_INTERVAL_MS      = 1000
        HEARTBEAT_INTERVAL_MS     = 2000

        SLEEP_IO_WAIT_MS          = 10
        SLEEP_BACKOFF_MS          = 50
        SLEEP_THROTTLE_MS         = 250

        PROGRAM_STATES            = @("IDLE", "INIT", "SCAN", "EXTRACT", "VERIFY", "REPAIR", "ERROR", "RECOVER", "SHUTDOWN")
        DEFAULT_STATE_TIMEOUT_MS  = 30000

        HEARTBEAT_ENABLED         = $true
        WATCHDOG_ENABLED          = $true
        WATCHDOG_ACTION           = "RESTART"

        CPU_THROTTLE_PERCENT      = 30
        IO_THROTTLE_BYTES_PER_SEC = 10485760

        ASYNC_OP_TIMEOUT_MS       = 30000
        CANCELATION_TOKEN_MS      = 5000
        GRACEFUL_SHUTDOWN_MS      = 10000
    }

    # =========================================================================
    # INPUT HANDLING – Multi‑OS Virtual Key Codes & Behavior
    # Garantido para Windows, Linux e macOS (PowerShell Core 6+)
    # =========================================================================
    INPUT = @{
        # Mapeamento de nomes simbólicos para códigos de tecla (sistema independente)
        KEYS = @{
            # Navegação
            UP          = 38
            DOWN        = 40
            LEFT        = 37
            RIGHT       = 39
            HOME        = 36
            END         = 35
            PGUP        = 33
            PGDN        = 34

            # Edição e controle
            ENTER       = 13
            ESC         = 27
            BACKSPACE   = 8
            TAB         = 9
            SPACE       = 32
            DELETE      = 46
            INSERT      = 45

            # Modificadores (códigos virtuais)
            CTRL        = 17
            ALT         = 18
            SHIFT       = 16
            WIN         = 91   # Windows/Command

            # Teclas de função
            F1          = 112
            F2          = 113
            F3          = 114
            F4          = 115
            F5          = 116
            F6          = 117
            F7          = 118
            F8          = 119
            F9          = 120
            F10         = 121
            F11         = 122
            F12         = 123

            # Teclas de função estendidas (opcionais)
            F13         = 124
            F14         = 125
            F15         = 126
            F16         = 127
            F17         = 128
            F18         = 129
            F19         = 130
            F20         = 131

            # Teclado numérico (se houver NumLock)
            NUMPAD0     = 96
            NUMPAD1     = 97
            NUMPAD2     = 98
            NUMPAD3     = 99
            NUMPAD4     = 100
            NUMPAD5     = 101
            NUMPAD6     = 102
            NUMPAD7     = 103
            NUMPAD8     = 104
            NUMPAD9     = 105
            NUMPAD_MULT = 106
            NUMPAD_ADD  = 107
            NUMPAD_SUB  = 109
            NUMPAD_DOT  = 110
            NUMPAD_DIV  = 111

            # Teclas de mídia e sistema (suporte parcial em consoles)
            VOLUME_UP   = 175
            VOLUME_DOWN = 174
            MUTE        = 173
            PLAY_PAUSE  = 179
            STOP        = 178
            NEXT_TRACK  = 176
            PREV_TRACK  = 177
        }

        # Mapeamento adicional: códigos de tecla para strings legíveis (útil para debug)
        KEY_NAMES = @{
            38  = "UP";           40  = "DOWN";         37  = "LEFT";         39  = "RIGHT"
            36  = "HOME";         35  = "END";          33  = "PGUP";         34  = "PGDN"
            13  = "ENTER";        27  = "ESC";          8   = "BACKSPACE";    9   = "TAB"
            32  = "SPACE";        46  = "DELETE";       45  = "INSERT"
            17  = "CTRL";         18  = "ALT";          16  = "SHIFT";        91  = "WIN"
            112 = "F1";           113 = "F2";           114 = "F3";           115 = "F4"
            116 = "F5";           117 = "F6";           118 = "F7";           119 = "F8"
            120 = "F9";           121 = "F10";          122 = "F11";          123 = "F12"
        }

        # Comportamento de entrada
        TIMEOUT_MS                = 5000      # Aguardo de entrada assíncrona
        POLL_MS                   = 30        # Polling para leitura não‑bloqueante
        MENU_WRAP                 = $true     # Wrap-around em menus
        DEBOUNCE_MS               = 50        # Debounce para evitar repetição acidental
        HOLD_THRESHOLD_MS         = 500       # Tempo para considerar tecla pressionada "hold"
        REPEAT_DELAY_MS           = 200       # Inicial antes de repetir
        REPEAT_RATE_MS            = 50        # Intervalo entre repetições
        MOUSE_SUPPORT             = "auto"    # "auto", "enabled", "disabled"
        PASTE_TIMEOUT_MS          = 2000      # Tempo máximo para detectar colagem

        # Sequências ANSI comuns para terminais (escape)
        ANSI_KEYS = @{
            UP          = "`e[A"
            DOWN        = "`e[B"
            RIGHT       = "`e[C"
            LEFT        = "`e[D"
            HOME        = "`e[H"
            END         = "`e[F"
            PGUP        = "`e[5~"
            PGDN        = "`e[6~"
            DELETE      = "`e[3~"
            INSERT      = "`e[2~"
            F1          = "`eOP"
            F2          = "`eOQ"
            F3          = "`eOR"
            F4          = "`eOS"
            F5          = "`e[15~"
            F6          = "`e[17~"
            F7          = "`e[18~"
            F8          = "`e[19~"
            F9          = "`e[20~"
            F10         = "`e[21~"
            F11         = "`e[23~"
            F12         = "`e[24~"
        }
    }

    # =========================================================================
    # INDUSTRIAL / SCADA (mantido e expandido)
    # =========================================================================
    INDUSTRIAL = @{
        PLC_CYCLE_MS                = 100
        SCADA_POLL_INTERVAL_MS      = 500
        RTU_HEARTBEAT_MS            = 1000
        MODBUS_TIMEOUT_MS           = 200
        OPC_UA_SESSION_TIMEOUT      = 60000
        PROTOCOL_RETRY              = 3
        FIRMWARE_UPDATE_SLEEP_MS    = 500
        WATCHDOG_RESET_COUNT        = 5
        OPERATION_MODE              = @("AUTOMATIC", "SEMI_AUTOMATIC", "MANUAL", "MAINTENANCE")

        # Novos parâmetros para robustez industrial
        MODBUS_RETRY_DELAY_MS       = 50
        MODBUS_MAX_RETRIES          = 3
        OPC_UA_KEEPALIVE_MS         = 10000
        PROFINET_TIMEOUT_MS         = 100
        ETHERNETIP_CIP_TIMEOUT_MS   = 500
    }
}