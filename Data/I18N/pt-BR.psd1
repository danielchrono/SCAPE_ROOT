@{
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # CORE ENGINE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "CORE_ENGINE_START"               = @{ T = 'SequÃªncia de Boot do Motor SCAPE Iniciada. Alocando recursos do nÃºcleo...'; H = 'Mensagem de inicializaÃ§Ã£o do motor'; F = 'SYSTEM' }
    "CORE_ENGINE_STOP"                = @{ T = 'Motor SCAPE Offline. SequÃªncia de encerramento e expurgo de memÃ³ria concluÃ­dos.'; H = 'ConfirmaÃ§Ã£o de desligamento do motor'; F = 'SYSTEM' }
    "CORE_KERNEL_SHIELD_ACTIVE"       = @{ T = 'SHIELD_ESTÃVEL: NT_IO_PRIORITY_HIGH acoplado. Threads de execuÃ§Ã£o elevadas.'; H = 'Sucesso na elevaÃ§Ã£o de prioridade do kernel'; F = 'KERNEL' }
    "CORE_KERNEL_SHIELD_FAIL"         = @{ T = 'FALHA_NO_SHIELD: Incapaz de elevar a prioridade do processo. {0}'; H = 'Falha na elevaÃ§Ã£o de prioridade com token de erro'; F = 'KERNEL_ERR' }
    "CORE_VALEDICTORY_CLEANUP"        = @{ T = 'Executando Limpeza de Despedida: Liberando handles e esvaziando buffers...'; H = 'Fase de limpeza de encerramento gracioso'; F = 'KERNEL' }
    "CORE_VALEDICTORY_DONE"           = @{ T = 'Limpeza de despedida concluÃ­da. Processos do motor suspensos com seguranÃ§a.'; H = 'ConfirmaÃ§Ã£o de conclusÃ£o da limpeza'; F = 'SYSTEM' }
    "CORE_VALEDICTORY_ERROR"          = @{ T = 'Falha crÃ­tica durante a fase de limpeza de despedida: {0}'; H = 'Erro na fase de limpeza com token'; F = 'ERR' }
    "CORE_ADMIN_REQUIRED"             = @{ T = 'PrivilÃ©gios de Administrador sÃ£o estritamente necessÃ¡rios para acesso bruto DASD. Reinicie o processo do host com direitos elevados.'; H = 'Requisito de elevaÃ§Ã£o para acesso DASD'; F = 'PRIVILEGE_FATAL' }
    "CORE_BACKUP_PRIV_GRANTED"        = @{ T = 'EscalaÃ§Ã£o de PrivilÃ©gios Bem-sucedida: SeBackupPrivilege e SeRestorePrivilege estÃ£o ativos.'; H = 'PrivilÃ©gios de backup elevados com sucesso'; F = 'SANCTUARY' }
    "CORE_BACKUP_PRIV_MISSING"        = @{ T = 'PrivilÃ©gios de backup nÃ£o habilitados totalmente. Capacidades de bypass de ACL do NTFS podem ser severamente restritas durante a extraÃ§Ã£o.'; H = 'Aviso de escalaÃ§Ã£o parcial de privilÃ©gios'; F = 'SANCTUARY_WARN' }
    "CORE_PRESERVATION_ACTIVE"        = @{ T = 'MODO DE PRESERVAÃ‡ÃƒO ATIVO - RESFRIANDO'; H = 'Indicador de status do modo de preservaÃ§Ã£o'; F = 'STATUS' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # SETTINGS ENGINE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "SETTINGS_ENGINE_ONLINE"          = @{ T = 'Motor de configuraÃ§Ãµes online. Sincronizando overrides...'; H = 'Mensagem de inicializaÃ§Ã£o do engine'; F = 'SYSTEM' }
    "SETTINGS_MUTATE_UNKNOWN"         = @{ T = 'Tentativa de alteraÃ§Ã£o em chave desconhecida: {0}'; H = 'Erro de mutaÃ§Ã£o para chave inexistente'; F = 'WARN' }
    "SETTINGS_IO_FAULT"               = @{ T = 'Falha de E/S: Chave {0} aplicada na RAM, mas nÃ£o persistida no disco.'; H = 'Falha de persistÃªncia no arquivo JSON'; F = 'ERROR' }
    "SETTINGS_MUTATE_SUCCESS"         = @{ T = 'ConfiguraÃ§Ã£o [{0}] alterada com sucesso para [{1}].'; H = 'NotificaÃ§Ã£o de sucesso de mutaÃ§Ã£o'; F = 'SYSTEM' }
    "SETTINGS_RESET_DEFAULTS"         = @{ T = 'Redefinir para PadrÃµes de FÃ¡brica'; H = 'OpÃ§Ã£o para redefinir todas as configuraÃ§Ãµes para os padrÃµes de fÃ¡brica'; F = 'UI' }
    "SETTINGS_RESET_SUCCESS"          = @{ T = 'Todas as configuraÃ§Ãµes restauradas para o padrÃ£o de fÃ¡brica (.psd1).'; H = 'ConfirmaÃ§Ã£o de redefiniÃ§Ã£o de fÃ¡brica'; F = 'SYSTEM' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # MAIN MENU
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "MENU_MAIN_TITLE"                 = @{ T = 'CONFIGURAÃ‡Ã•ES DO SISTEMA E DEFINIÃ‡Ã•ES DE AMBIENTE'; H = 'TÃ­tulo do menu principal'; F = $null }
    "MENU_MAIN_SCAN"                  = @{ T = 'SCAN COMPLETO & TOPOLOGIA DE INVENTÃRIO'; H = 'Auditoria de hardware e inventÃ¡rio de topologia de disco.'; F = '1' }
    "MENU_MAIN_PARSING"               = @{ T = 'RECUPERAÃ‡ÃƒO TARGETADA (Plano A - MFT/Inode)'; H = 'RecuperaÃ§Ã£o determinÃ­stica de registros MFT/Inode.'; F = '2' }
    "MENU_MAIN_ARCHAEOLOGY"           = @{ T = 'MODO ARQUEOLOGIA (Plano B - ExtraÃ§Ã£o Bruta)'; H = 'EscavaÃ§Ã£o profunda de assinaturas hexadecimais.'; F = '3' }
    "MENU_MAIN_HARVESTER"             = @{ T = 'EXTRAÃ‡ÃƒO EM MASSA HARVESTER'; H = 'ExtraÃ§Ã£o em lote de arquivos descobertos.'; F = '4' }
    "MENU_MAIN_FORENSICS"             = @{ T = 'DIAGNÃ“STICO FORENSE & FERRAMENTAS CLI'; H = 'Acessar utilitÃ¡rios nativos de CLI forense'; F = '5' }
    "MENU_MAIN_SETTINGS"              = @{ T = 'CONFIGURAÃ‡Ã•ES DO SISTEMA E AMBIENTE'; H = 'Ajustar parÃ¢metros do motor e da interface.'; F = '6' }
    "MENU_MAIN_LOGISTICS"             = @{ T = 'LOGÃSTICA & CLOUD SYNC'; H = 'Motor de sincronizaÃ§Ã£o em nuvem Robocopy.'; F = '7' }
    "MENU_MAIN_LAB"                   = @{ T = 'SCAPE LABORATORY (Reparo de Arquivos)'; H = 'Reparo de magic bytes e cirurgia de blocos.'; F = '8' }
    "MENU_MAIN_EXIT"                  = @{ T = 'ENCERRAR MOTOR SCAPE'; H = 'Fechar Scape Engine'; F = 'Q' }

    "MENU_OPTION_ENGINE_MODE"         = @{ T = 'MODO DO MOTOR (EficiÃªncia vs RedundÃ¢ncia)'; H = 'Alterna o modo entre EFICIÃŠNCIA (RÃ¡pido/Estrito) e REDUNDÃ‚NCIA (Profundo/Fallback).'; F = '1' }
    "MENU_OPTION_DEFAULT_OUT"         = @{ T = 'DIRETÃ“RIO DE SAÃDA PADRÃƒO'; H = 'Define o diretÃ³rio fÃ­sico global para o armazenamento (staging) das extraÃ§Ãµes.'; F = '2' }
    "MENU_OPTION_NETWORK_MGR"         = @{ T = 'CONFIGURAÃ‡Ã•ES DE REDE'; H = 'Gerenciar montagens de rede SMB/CIFS e credenciais ativas.'; F = '3' }
    "MENU_OPTION_ROBOCOPY"            = @{ T = 'CONFIGURAÃ‡Ã•ES GLOBAIS DO ROBOCOPY (SYNC)'; H = 'Flags avanÃ§adas de sincronizaÃ§Ã£o para o motor de Nuvem Robocopy.'; F = '4' }
    "MENU_OPTION_LANGUAGE"            = @{ T = 'IDIOMA DA INTERFACE'; H = 'Altera o idioma global da interface do SCAPE.'; F = '5' }
    "MENU_SETTINGS_THEME"             = @{ T = 'OPÃ‡Ã•ES DE TEMA'; H = 'Configurar o tema visual da interface.'; F = '6' }
    "MENU_OPTION_RETURN"              = @{ T = 'RETORNAR AO MENU ANTERIOR'; H = 'Retornar ao nÃ­vel anterior do menu'; F = 'R' }
    "MENU_OPTION_AUTODETECT"          = @{ T = 'AUTO-DETECTAR & MONTAR COFRE SAMBA'; H = 'Auto-descobrir e montar compartilhamentos Samba em rede'; F = 'S' }

    "MENU_MAESTRO_PROMPT"             = @{ T = 'Aguardando diretiva de comando operacional'; H = 'Prompt de status da rotina Maestro'; F = 'MAESTRO_ROUTINE' }
    "MENU_INPUT_PROMPT"               = @{ T = 'ENTRADA'; H = 'RÃ³tulo do campo de entrada'; F = $null }
    "MENU_VALUE_NOT_SET"              = @{ T = 'NÃƒO CONFIGURADO'; H = 'Indicador de configuraÃ§Ã£o nÃ£o definida'; F = $null }
    "MENU_VALUE_ENABLED"              = @{ T = 'ATIVADO ACTIVE'; H = 'Indicador de recurso habilitado'; F = $null }
    "MENU_VALUE_DISABLED"             = @{ T = 'DESATIVADO INACTIVE'; H = 'Indicador de recurso desabilitado'; F = $null }
    "MENU_CHOICE_INVALID"             = @{ T = 'ParÃ¢metro de comando nÃ£o reconhecido. Por favor, forneÃ§a um Ã­ndice vÃ¡lido.'; H = 'Erro de seleÃ§Ã£o invÃ¡lida no menu'; F = 'INPUT_ERR' }
    "MENU_LANGUAGE_SWITCH"            = @{ T = 'DicionÃ¡rio de idioma global alterado para {0}. Componentes de interface atualizados.'; H = 'ConfirmaÃ§Ã£o de troca de idioma com token de localidade'; F = 'UI' }
    "MENU_OPTION_ICON_LEVEL"          = @{ T = 'NÃVEL ÃCONE (GrÃ¡fico/Unicode/ASCII)'; H = 'Alternar entre Ã­cones grÃ¡ficos, Unicode sÃ³lido ou ASCII'; F = '1' }
    "MENU_OPTION_FRAME_STYLE"         = @{ T = 'ESTILO MOLDURA (Estilo de bordas)'; H = 'Alterar o estilo de borda dos menus'; F = '2' }
    "MENU_OPTION_PROGRESS_STYLE"      = @{ T = 'ESTILO PROGRESSO (Barra/Spinner)'; H = 'Selecionar estilo de barra de progresso ou spinner'; F = '3' }
    "MENU_OPTION_THEME_PERSONA"       = @{ T = 'PERSONA TEMA (Paleta de cores)'; H = 'Aplicar uma paleta de cores completa'; F = '4' }
    "MENU_OPTION_COLOR_MODE"          = @{ T = 'MODO COR (TrueColor/ANSI16)'; H = 'Alternar entre TrueColor de 24 bits e fallback de 16 cores ANSI'; F = '5' }
    "MENU_RANDOM_THEME"               = @{ T = 'NOVO TEMA RANDÃ”MICO (RGB DINÃ‚MICO)'; H = 'Aplica uma nova paleta de cores gerada algoritmicamente garantindo acessibilidade visual.'; F = '6' }
    "THEME_APPLIED"                   = @{ T = 'Tema QuÃ¢ntico de UI aplicado com sucesso. RGB Base: {0}'; H = 'Sucesso na aplicaÃ§Ã£o de tema com token RGB'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # DRIVE ACTIONS MENU
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "MENU_DRIVE_TARGET_LABEL"         = @{ T = '>> ALVO SELECIONADO: {0}'; H = 'RÃ³tulo do drive selecionado com token de dispositivo'; F = $null }
    "MENU_DRIVE_OPT_TARGETED"         = @{ T = 'RecuperaÃ§Ã£o Direcionada (SCAPE Plano A)'; H = 'Extrai caminhos especÃ­ficos ignorando APIs do Windows.'; F = '1' }
    "MENU_DRIVE_OPT_ARCHAEOLOGY"      = @{ T = 'Modo Arqueologia (SCAPE Plano B)'; H = 'EscavaÃ§Ã£o profunda de setores RAW por assinaturas perdidas.'; F = '2' }
    "MENU_DRIVE_OPT_ISOLATE"          = @{ T = 'Isolar Unidade (Diskpart - Modo Offline)'; H = 'ForÃ§a estado offline para prevenir interferÃªncia do SO.'; F = '3' }
    "MENU_DRIVE_OPT_JOURNAL"          = @{ T = 'Colher Journal (Fsutil - DeleÃ§Ãµes Recentes)'; H = 'Extrai deleÃ§Ãµes recentes via USN Journal.'; F = '4' }
    "MENU_DRIVE_OPT_HYBRID"           = @{ T = 'RecuperaÃ§Ã£o HÃ­brida (WinFR + SCAPE)'; H = 'Scan de motor duplo alavancando Windows File Recovery.'; F = '5' }
    "MENU_DRIVE_OPT_RETURN"           = @{ T = 'Retornar'; H = 'Retornar ao menu anterior.'; F = 'R' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # PIPELINE / COMPLIANCE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "TUI_PREFLIGHT"                   = @{ T = 'Iniciando sequÃªncia de diagnÃ³stico {0}...'; H = 'InÃ­cio de diagnÃ³stico prÃ©-voo com token de ferramenta'; F = 'PRE-FLIGHT' }
    "TUI_EXECUTION"                   = @{ T = 'Motor {0} operante. Processando fluxos...'; H = 'Status da fase de execuÃ§Ã£o com token de motor'; F = 'EXECUTION' }
    "TUI_POSTFLIGHT"                  = @{ T = 'SequÃªncia operacional {0} finalizada.'; H = 'ConclusÃ£o pÃ³s-voo com token de ferramenta'; F = 'POST-FLIGHT' }
    "TUI_CHKDSK"                      = @{ T = 'VerificaÃ§Ã£o de Integridade do Sistema de Arquivos (Chkdsk)'; H = 'Nome de exibiÃ§Ã£o da ferramenta Chkdsk'; F = $null }
    "TUI_STORDIAG"                    = @{ T = 'DiagnÃ³stico de Telemetria de Hardware (Stordiag)'; H = 'Nome de exibiÃ§Ã£o da ferramenta Stordiag'; F = $null }
    "TUI_FSUTIL"                      = @{ T = 'Colheita do USN Journal NTFS'; H = 'Nome de exibiÃ§Ã£o da ferramenta Fsutil'; F = $null }
    "TUI_ROBOCOPY"                    = @{ T = 'Motor de SincronizaÃ§Ã£o Robocopy'; H = 'Nome de exibiÃ§Ã£o da ferramenta Robocopy'; F = $null }
    "TUI_DISKPART"                    = @{ T = 'Motor de Isolamento Diskpart'; H = 'Nome de exibiÃ§Ã£o da ferramenta Diskpart'; F = $null }

    "LAB_START"                       = @{ T = 'Iniciando anÃ¡lise binÃ¡ria em: {0}'; H = 'InÃ­cio da anÃ¡lise de laboratÃ³rio com token de arquivo'; F = 'LAB' }
    "LAB_MAGIC_FIXED"                 = @{ T = 'Assinatura hexadecimal restaurada. Tipo: {0}'; H = 'ConfirmaÃ§Ã£o de reparo de magic bytes com token de tipo'; F = 'LAB' }
    "LAB_SUCCESS"                     = @{ T = 'Objeto reconstruÃ­do com sucesso em: {0}'; H = 'Sucesso na reconstruÃ§Ã£o com token de caminho'; F = 'LAB' }
    "LAB_SURGERY_CRITICAL"            = @{ T = 'O objeto alvo estÃ¡ 100% preenchido com zeros (Nulo). A reconstruÃ§Ã£o binÃ¡ria Ã© matematicamente impossÃ­vel.'; H = 'Estado crÃ­tico de dados irrecuperÃ¡veis'; F = 'LAB_FATAL' }
    "LAB_HEADER_MISMATCH"             = @{ T = 'Incompatibilidade de Magic Bytes detectada. Esperado {0}, Hex encontrado {1}.'; H = 'Falha na validaÃ§Ã£o de cabeÃ§alho com tokens esperado/encontrado'; F = 'LAB_WARN' }
    "LAB_BLOCK_SKIP"                  = @{ T = 'Setor ilegÃ­vel no offset de bloco {0}. Injetando sequÃªncia zero-fill de 64KB e saltando para o prÃ³ximo cluster.'; H = 'Tratamento de setor defeituoso com token de offset'; F = 'LAB_IO' }

    "UI_DIRTY_DISCARD"                = @{ T = 'AlteraÃ§Ãµes de configuraÃ§Ã£o nÃ£o salvas detectadas na matriz volÃ¡til. Descartar e retornar? (s/N): '; H = 'Prompt de confirmaÃ§Ã£o de alteraÃ§Ãµes nÃ£o salvas'; F = 'STATE_WARN' }
    "UI_LOCKDOWN_ACTIVE"              = @{ T = 'OperaÃ§Ã£o bloqueada pelo orquestrador devido a restriÃ§Ãµes de ambiente.'; H = 'Aviso de restriÃ§Ã£o de ambiente'; F = 'RESTRICTED' }
    "UI_CONFIRM_PROCEED"              = @{ T = 'ACEITAR RISCO & PROSSEGUIR'; H = 'Texto do botÃ£o de confirmaÃ§Ã£o para operaÃ§Ãµes arriscadas'; F = $null }
    "UI_CONFIRM_ABORT"                = @{ T = 'ABORTAR OPERAÃ‡ÃƒO'; H = 'Texto do botÃ£o de abortar para cancelamento'; F = $null }

    "SYNC_SUSPEND"                    = @{ T = 'Suspendendo Monitor Ao Vivo assÃ­ncrono para evitar colisÃµes COM/Handle.'; H = 'Aviso de suspensÃ£o de sincronismo para seguranÃ§a de recursos'; F = 'SYNC' }
    "SYNC_RESUME"                     = @{ T = 'Trava sÃ­ncrona liberada. Retomando thread do Monitor Ao Vivo.'; H = 'Aviso de retomada de sincronismo'; F = 'SYNC' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # STATUS ENUMERATIONS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "STATUS_DISCOVERED"               = @{ T = 'DESCOBERTO_PARSEADO'; H = 'Arquivo descoberto via parsing de metadados'; F = $null }
    "STATUS_DISCOVERED_RAW"           = @{ T = 'DESCOBERTO_ESCULPIDO'; H = 'Arquivo descoberto via carving bruto'; F = $null }
    "STATUS_EXTRACTED"                = @{ T = 'EXTRAÃDO_COM_SUCESSO'; H = 'ExtraÃ§Ã£o de arquivo concluÃ­da com sucesso'; F = $null }
    "STATUS_PARTIAL_CORRUPT"          = @{ T = 'EXTRAÃDO_CORRUPÃ‡ÃƒO_PARCIAL'; H = 'Arquivo extraÃ­do com corrupÃ§Ã£o parcial'; F = $null }
    "STATUS_ORPHAN"                   = @{ T = 'BLOCO_Ã“RFÃƒO'; H = 'Bloco de dados Ã³rfÃ£o sem metadados'; F = $null }
    "STATUS_FAILED"                   = @{ T = 'FALHA_NA_EXTRAÃ‡ÃƒO'; H = 'Falha na extraÃ§Ã£o do arquivo'; F = $null }
    "STATUS_READY"                    = @{ T = 'ALVO_PRONTO'; H = 'Dispositivo alvo pronto para operaÃ§Ãµes'; F = $null }
    "STATUS_PROCESSING"               = @{ T = 'PROCESSAMENTO_ATIVO'; H = 'OperaÃ§Ã£o atualmente em progresso'; F = $null }
    "STATUS_VERIFIED"                 = @{ T = 'INTEGRIDADE_VERIFICADA'; H = 'VerificaÃ§Ã£o de integridade de dados aprovada'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # TABLE HEADERS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "TABLE_HEADER_ID"                 = @{ T = 'ID_DO_OBJETO'; H = 'CabeÃ§alho de tabela: Identificador do objeto'; F = $null }
    "TABLE_HEADER_NAME"               = @{ T = 'NOME_DO_ARQUIVO'; H = 'CabeÃ§alho de tabela: Nome do arquivo'; F = $null }
    "TABLE_HEADER_SIZE"               = @{ T = 'TAMANHO_ALOCADO'; H = 'CabeÃ§alho de tabela: Tamanho alocado em bytes'; F = $null }
    "TABLE_HEADER_TYPE"               = @{ T = 'TIPO_FS'; H = 'CabeÃ§alho de tabela: Tipo de sistema de arquivos'; F = $null }
    "TABLE_HEADER_STATUS"             = @{ T = 'STATUS_DO_MOTOR'; H = 'CabeÃ§alho de tabela: Status de processamento'; F = $null }
    "TABLE_HEADER_CATEGORY"           = @{ T = 'CATEGORIA_MIME'; H = 'CabeÃ§alho de tabela: Categoria de tipo MIME'; F = $null }
    "TABLE_HEADER_HASH"               = @{ T = 'CHECKSUM_SHA256'; H = 'CabeÃ§alho de tabela: Valor de hash SHA256'; F = $null }
    "TABLE_HEADER_SCORE"              = @{ T = 'SCORE_DE_INTEGRIDADE'; H = 'CabeÃ§alho de tabela: PontuaÃ§Ã£o de integridade de dados'; F = $null }
    "TABLE_HEADER_OFFSET"             = @{ T = 'OFFSET_FÃSICO'; H = 'CabeÃ§alho de tabela: Offset fÃ­sico do disco'; F = $null }
    "TABLE_HEADER_LENGTH"             = @{ T = 'COMPRIMENTO_EM_BYTES'; H = 'CabeÃ§alho de tabela: Comprimento em bytes do objeto'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # INVENTORY & DISCOVERY
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "INVENTORY_PHYSICAL_DISKS"        = @{ T = 'ENUMERANDO TOPOLOGIA DE DISCOS FÃSICOS:'; H = 'Mensagem de inÃ­cio de enumeraÃ§Ã£o de discos fÃ­sicos'; F = 'GERENCIADOR_INVENTÃRIO' }
    "INVENTORY_LOGICAL_VOLUMES"       = @{ T = 'ENUMERANDO MONTAGENS DE VOLUMES LÃ“GICOS:'; H = 'Mensagem de inÃ­cio de enumeraÃ§Ã£o de volumes lÃ³gicos'; F = 'GERENCIADOR_INVENTÃRIO' }
    "INVENTORY_WMI_FAIL"              = @{ T = 'Subsistema WMI/CIM sem resposta. NÃ£o Ã© possÃ­vel enumerar a topologia de hardware.'; H = 'Erro fatal de falha do subsistema WMI'; F = 'INVENTÃRIO_FATAL' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # VOLUME TYPES & SELECTION
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "VOLUME_TYPE_NTFS"                = @{ T = 'NTFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_EXFAT"               = @{ T = 'exFAT'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_FAT32"               = @{ T = 'FAT32'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_EXT4"                = @{ T = 'ext4'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_BTRFS"               = @{ T = 'BTRFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_ZFS"                 = @{ T = 'ZFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_XFS"                 = @{ T = 'XFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_APFS"                = @{ T = 'APFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_UNKNOWN"             = @{ T = 'RAW_OU_DESCONHECIDO'; H = 'Indicador de sistema de arquivos nÃ£o reconhecido'; F = $null }

    "VOLUME_ACCESS_DENIED"            = @{ T = 'CRÃTICO: Acesso Negado (Verifique PrivilÃ©gios de Administrador)'; H = 'Erro de acesso negado ao volume'; F = $null }
    "VOLUME_SELECTION_PROMPT"         = @{ T = 'Identifique o alvo de armazenamento comprometido:'; H = 'InstruÃ§Ã£o de seleÃ§Ã£o de volume'; F = 'SELEÃ‡ÃƒO_DE_ALVO_VOLUME' }
    "VOLUME_SELECTION_INDEX"          = @{ T = 'ÃNDICE_DO_ALVO'; H = 'CabeÃ§alho de tabela de seleÃ§Ã£o de volume'; F = $null }
    "VOLUME_NO_TARGETS"               = @{ T = 'Nenhum alvo de armazenamento viÃ¡vel detectado na configuraÃ§Ã£o de hardware atual.'; H = 'Aviso de nenhum alvo encontrado'; F = 'SYSTEM_WARN' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # I/O OPERATIONS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "IO_CREATEFILE_FAIL"              = @{ T = 'A API Win32 CreateFile falhou em garantir o handle. CÃ³digo Win32Error: {0}'; H = 'Falha da API CreateFile com token de cÃ³digo de erro'; F = 'IO_FATAL' }
    "IO_READ_SUCCESS"                 = @{ T = 'Lidos com sucesso {0} bytes do offset fÃ­sico {1}'; H = 'ConfirmaÃ§Ã£o de leitura bem-sucedida com tokens de bytes/offset'; F = 'IO_STREAM' }
    "IO_READ_PARTIAL"                 = @{ T = 'Leitura parcial detectada: esperados {0} bytes, recuperados apenas {1} bytes. Preenchimento (padding) pode ocorrer.'; H = 'Aviso de leitura parcial com tokens esperado/recebido'; F = 'IO_STREAM_WARN' }
    "IO_RETRY_ATTEMPT"                = @{ T = 'Falha de E/S detectada. Tentando novamente {0}/{1} apÃ³s {2} segundos...'; H = 'NotificaÃ§Ã£o de tentativa de retry com tokens tentativa/max/atraso'; F = 'IO_RESILIÃŠNCIA' }
    "IO_RECONNECT_SUCCESS"            = @{ T = 'ConexÃ£o reestabelecida com a controladora de armazenamento com sucesso.'; H = 'Sucesso na reconexÃ£o da controladora'; F = 'IO_RESILIÃŠNCIA' }
    "IO_RECONNECT_FAIL"               = @{ T = 'Reset da controladora falhou. Dispositivo perdido permanentemente apÃ³s {0} tentativas.'; H = 'Falha na reconexÃ£o da controladora com token de contagem de tentativas'; F = 'IO_FATAL' }
    "IO_ALIGNMENT_SHIFT"              = @{ T = 'Deslocando offset de leitura {0} -> {1} para coincidir com a fronteira do setor fÃ­sico ({2} bytes).'; H = 'Ajuste de alinhamento de setor com tokens de offset'; F = 'IO_ALINHAMENTO' }
    "IO_DASD_HANDLE_CLOSED"           = @{ T = 'Handle do Dispositivo de Armazenamento de Acesso Direto (DASD) liberado de volta ao SO.'; H = 'ConfirmaÃ§Ã£o de liberaÃ§Ã£o de handle DASD'; F = 'IO_GERENCIADOR' }
    "IO_DEVICE_NOT_READY"             = @{ T = 'O dispositivo de armazenamento reportou status NÃ£o Pronto. Aguardando reconexÃ£o de hardware.'; H = 'Aviso de dispositivo nÃ£o pronto'; F = 'IO_WARN' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # SYSTEM TOPOLOGY & SPECS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "TOPOLOGY_TITLE"                  = @{ T = '[ TOPOLOGIA DE INFRAESTRUTURA DO SISTEMA ]'; H = 'CabeÃ§alho de exibiÃ§Ã£o de topologia'; F = $null }
    "SPEC_LABEL_CPU"                  = @{ T = 'PROCESSADOR'; H = 'RÃ³tulo de especificaÃ§Ã£o de hardware para CPU'; F = $null }
    "SPEC_LABEL_RAM"                  = @{ T = 'MEMÃ“RIA'; H = 'RÃ³tulo de especificaÃ§Ã£o de hardware para RAM'; F = $null }
    "SPEC_LABEL_OS"                   = @{ T = 'KERNEL'; H = 'RÃ³tulo de especificaÃ§Ã£o de hardware para kernel do SO'; F = $null }
    "SPEC_LABEL_VIRT"                 = @{ T = 'VIRT_LAYER'; H = 'RÃ³tulo de especificaÃ§Ã£o de hardware para camada de virtualizaÃ§Ã£o'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # HARDWARE METRICS & TELEMETRY
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "HW_SMART_FAIL"                   = @{ T = 'Limite de prÃ©-falha S.M.A.R.T. excedido para o atributo ID {0} (Valor Bruto: {1}). Falha mecÃ¢nica iminente.'; H = 'Aviso crÃ­tico S.M.A.R.T. com tokens de atributo/valor'; F = 'HW_METRICS_CRÃTICO' }
    "HW_TBW_WARN"                     = @{ T = 'AVISO DE RESISTÃŠNCIA NAND: O Total de Bytes Gravados (TBW) do SSD alvo estÃ¡ prÃ³ximo dos limites do fabricante. Risco de bloqueio de hardware para somente-leitura.'; H = 'Aviso de resistÃªncia de SSD'; F = 'HW_METRICS_AVISO' }
    "HW_TBW_CRITICAL"                 = @{ T = 'Limite TBW estritamente excedido. A unidade pode entrar em estado de proteÃ§Ã£o somente-leitura a qualquer momento.'; H = 'Falha crÃ­tica de resistÃªncia de SSD'; F = 'HW_METRICS_FATAL' }
    "HW_BAD_SECTOR_DETECT"            = @{ T = 'Erro de Leitura IncorrigÃ­vel (CRC) encontrado no LCN {0}. O setor estÃ¡ fisicamente degradado.'; H = 'DetecÃ§Ã£o de setor defeituoso com token LCN'; F = 'FALHA_IO_DETECTADA' }
    "HW_IO_THRASHING"                 = @{ T = 'Thrashing severo de E/S detectado. Comprimento da Fila do Disco Ã© {0}. Suspendendo barramento do motor para evitar morte do hardware.'; H = 'Alerta de thrashing de E/S com token de comprimento de fila'; F = 'ALERTA_TELEMETRIA' }
    "HW_IO_RECOVERY"                  = @{ T = 'A pressÃ£o de E/S normalizou abaixo dos limites crÃ­ticos. Retomando threads operacionais do kernel.'; H = 'NotificaÃ§Ã£o de recuperaÃ§Ã£o de E/S'; F = 'ATUALIZAÃ‡ÃƒO_TELEMETRIA' }
    "HW_THERMAL_CRIT"                 = @{ T = 'VIOLAÃ‡ÃƒO TÃ‰RMICA. A Sonda ACPI reporta {0}C. Acionando estrangulamento tÃ©rmico agressivo para prevenir dano ao silÃ­cio.'; H = 'Alerta tÃ©rmico crÃ­tico com token de temperatura'; F = 'HW_METRICS_CRÃTICO' }
    "HW_THERMAL_NORMALIZED"           = @{ T = 'PARÃ‚METROS TÃ‰RMICOS NORMALIZADOS. Retomando extraÃ§Ã£o padrÃ£o do pipeline.'; H = 'NotificaÃ§Ã£o de normalizaÃ§Ã£o tÃ©rmica'; F = 'HW_METRICS_ATUALIZAÃ‡ÃƒO' }
    "HW_CONTROLLER_RESET"             = @{ T = 'A Controladora DASD derrubou a conexÃ£o forÃ§adamente. Tentando recriar handle de baixo nÃ­vel (Tentativa {0}/6).'; H = 'Tentativa de reset da controladora com token de contador'; F = 'FALHA_IO_DETECTADA' }
    "HW_PRESSURE_SUSPEND"             = @{ T = 'PRESSÃƒO CRÃTICA NA FILA DE E/S DETECTADA. SUSPENDENDO TODA ATIVIDADE DO BARRAMENTO DO MOTOR IMEDIATAMENTE.'; H = 'SuspensÃ£o por pressÃ£o crÃ­tica de E/S'; F = 'TELEMETRIA_CRÃTICA' }
    "HW_PRESSURE_RESUME"              = @{ T = 'PRESSÃƒO NA FILA DE E/S NORMALIZADA. RETOMANDO BARRAMENTO DO MOTOR.'; H = 'Retomada por normalizaÃ§Ã£o de pressÃ£o de E/S'; F = 'ATUALIZAÃ‡ÃƒO_TELEMETRIA' }
    "HW_CACHE_FLUSH"                  = @{ T = 'Descarregando cache de gravaÃ§Ã£o volÃ¡til do disco para a NAND fÃ­sica para evitar perda de dados.'; H = 'NotificaÃ§Ã£o de operaÃ§Ã£o de flush de cache'; F = 'HW_GERENCIADOR' }
    "HW_STORAGE_HEALTH"               = @{ T = 'Aviso: LatÃªncia de resposta crÃ­tica detectada em {0}. Verifique a integridade fÃ­sica do cabo SATA/NVMe e da controladora.'; H = 'Aviso de saÃºde de armazenamento com token de dispositivo'; F = 'HW_DIAGNÃ“STICO' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # NETWORK / SAMBA OPERATIONS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "NET_SMB_LOCK"                    = @{ T = 'Cofre Samba mapeado e travado com sucesso na letra de unidade {0} (Alvo: {1}).'; H = 'Sucesso na montagem SMB com tokens de unidade/alvo'; F = 'NETWORK_SEGURO' }
    "NET_SMB_TIMEOUT"                 = @{ T = 'Varredura de sub-rede do Radar Samba esgotada. O IP alvo estÃ¡ inacessÃ­vel, bloqueado por firewall ou offline.'; H = 'Erro de timeout na descoberta SMB'; F = 'NETWORK_ERR' }
    "NET_SMB_UNMOUNT"                 = @{ T = 'Desmontando Unidade Samba {0} e destruindo credenciais de rede ativas...'; H = 'Desmontagem SMB com token de unidade'; F = 'NETWORK_CLEANUP' }
    "NET_RADAR_SWEEP"                 = @{ T = 'Iniciando Varredor Agressivo de Sub-rede FÃ­sica (Threads: 256 | Timeout do Socket: 80ms)'; H = 'InicializaÃ§Ã£o de varredura de radar de rede'; F = 'INFRA_RADAR' }
    "NET_RADAR_SCAN"                  = @{ T = 'Varrendo Base CIDR local: {0}.0/24 por portas SMB ativas...'; H = 'Progresso de scan de sub-rede com token de IP base'; F = 'FASE_SCAN' }
    "NET_RADAR_FOUND"                 = @{ T = 'NÃ³ Samba CompatÃ­vel Travado: {0} respondendo na Porta TCP 445.'; H = 'Descoberta de nÃ³ SMB com token de IP'; F = 'NETWORK_SUCESSO' }
    "NET_LATENCY_WARN"                = @{ T = 'LatÃªncia de rede instÃ¡vel detectada ({0}ms). O desempenho do fluxo de sincronizaÃ§Ã£o ativo pode degradar significativamente.'; H = 'Aviso de latÃªncia de rede com token em ms'; F = 'CLOUD_SYNC_WARN' }
    "NET_SYNC_START"                  = @{ T = 'Iniciando transferÃªncia de carga segura e multi-thread via Motor Robocopy. Destino Alvo: {0}'; H = 'InÃ­cio de sincronismo com token de destino'; F = 'CLOUD_SYNC_INIT' }
    "NET_SYNC_SUCCESS"                = @{ T = 'SequÃªncia de espelhamento concluÃ­da com sucesso. CÃ³digo de SaÃ­da do Robocopy: {0}.'; H = 'Sucesso no sincronismo com token de cÃ³digo de saÃ­da'; F = 'CLOUD_SYNC_CONCLUÃDO' }
    "NET_SYNC_FAIL"                   = @{ T = 'Espelhamento abortado ou encontrou erros crÃ­ticos. Robocopy retornou cÃ³digo de saÃ­da {0}.'; H = 'Falha no sincronismo com token de cÃ³digo de saÃ­da'; F = 'CLOUD_SYNC_FATAL' }
    "NET_PACKET_DROP"                 = @{ T = 'Perda de pacotes/Queda TCP detectada durante o upload do staging. Auto-retomando fluxo de bytes a partir do Ãºltimo bloco confirmado.'; H = 'NotificaÃ§Ã£o de recuperaÃ§Ã£o de perda de pacotes'; F = 'CLOUD_SYNC_WARN' }
    "NET_SMB_AUTH_REQUIRED"           = @{ T = 'O endpoint Samba requer autenticaÃ§Ã£o segura. Uma caixa de diÃ¡logo de SeguranÃ§a do Windows aparecerÃ¡ em breve.'; H = 'Aviso de prompt de autenticaÃ§Ã£o SMB'; F = 'NETWORK_AUTH' }

    "NET_RADAR_GATEWAY_ERR"           = @{ T = 'Nenhum gateway real encontrado! O host pode estar isolado.'; H = 'Erro na descoberta de gateway'; F = 'ERRO' }
    "NET_RADAR_GATEWAY_OK"            = @{ T = 'Gateway: {0} ({1})'; H = 'InformaÃ§Ãµes de gateway com tokens IP/nome'; F = 'NETWORK' }
    "NET_RADAR_SCAN_DETAIL"           = @{ T = 'Varredura assÃ­ncrona de alta velocidade ({0} conexÃµes por lote)...'; H = 'Detalhe de scan com token de tamanho de lote'; F = 'SCAN' }
    "NET_RADAR_TESTING"               = @{ T = 'Testando {0}.0/24...'; H = 'Progresso de teste de sub-rede com token base'; F = $null }
    "NET_RADAR_SWEEPING"              = @{ T = '-> Varrendo {0} IPs...'; H = 'Progresso de varredura com token de contagem de IPs'; F = $null }
    "NET_RADAR_FOUND_COUNT"           = @{ T = '[+] {0} servidor(es) encontrado(s)!'; H = 'Resultado de contagem de servidores com token'; F = $null }
    "NET_RADAR_NONE_COUNT"            = @{ T = '[-] Nenhum'; H = 'Indicador de nenhum servidor encontrado'; F = $null }
    "NET_RADAR_VALID"                 = @{ T = '[+] Servidor vÃ¡lido: {0}'; H = 'ConfirmaÃ§Ã£o de servidor vÃ¡lido com token de IP'; F = $null }
    "NET_RADAR_IGNORED"               = @{ T = '[!] Ignorado (Gateway Host): {0}'; H = 'Gateway ignorado com token de IP'; F = $null }
    "NET_RADAR_PROMPT"                = @{ T = 'MÃšLTIPLOS HOSTS SMB DETECTADOS. SELECIONE O ALVO:'; H = 'Prompt de seleÃ§Ã£o de mÃºltiplos hosts'; F = $null }
    "NET_RADAR_LOCATED"               = @{ T = 'SERVIDOR SAMBA LOCALIZADO COM SUCESSO!'; H = 'Banner de sucesso na localizaÃ§Ã£o de servidor'; F = $null }
    "NET_RADAR_ADDRESS"               = @{ T = 'ENDEREÃ‡O: \\{0}'; H = 'ExibiÃ§Ã£o de endereÃ§o de servidor com token UNC'; F = $null }
    "NET_RADAR_NONE"                  = @{ T = 'Nenhum servidor SMB encontrado na topologia atual.'; H = 'Erro de nenhum servidor encontrado'; F = 'ERRO' }

    "NET_MAP_INIT"                    = @{ T = 'Injetando credenciais e abrindo seletor de pasta para \\{0}...'; H = 'InicializaÃ§Ã£o de montagem com token UNC'; F = 'MAP' }
    "NET_MAP_OK"                      = @{ T = 'Vault de Destino Selecionado: {0}'; H = 'ConfirmaÃ§Ã£o de seleÃ§Ã£o de vault com token de caminho'; F = 'OK' }
    "NET_MAP_AUTH"                    = @{ T = 'AutenticaÃ§Ã£o explÃ­cita exigida pela controladora de domÃ­nio SMB.'; H = 'Aviso de requisito de autenticaÃ§Ã£o'; F = 'AUTH' }
    "NET_MAP_AUTH_PROMPT"             = @{ T = 'Insira as credenciais de rede para \\{0}'; H = 'Prompt de autenticaÃ§Ã£o com token UNC'; F = $null }
    "NET_MAP_ABORT"                   = @{ T = 'AutenticaÃ§Ã£o cancelada pelo operador.'; H = 'Aviso de cancelamento de autenticaÃ§Ã£o'; F = 'ABORT' }
    "NET_MAP_SUCCESS"                 = @{ T = 'UNIDADE {0} MAPEADA COM SUCESSO!'; H = 'Sucesso na montagem com token de letra de unidade'; F = $null }
    "NET_MAP_DENIED"                  = @{ T = 'Acesso negado. Credenciais invÃ¡lidas ou permissÃµes insuficientes.'; H = 'Erro de montagem negada'; F = 'ERRO' }
    "NET_MAP_CANCELLED"               = @{ T = 'OperaÃ§Ã£o cancelada pelo operador ou falha no mapeamento.'; H = 'Aviso de cancelamento/falha de montagem'; F = 'ABORT' }

    "NET_MGR_TITLE"                   = @{ T = 'GERENCIAMENTO DE UNIDADES DE REDE'; H = 'TÃ­tulo do menu de gerenciamento de rede'; F = $null }
    "NET_MGR_UNMOUNT"                 = @{ T = 'DESMONTAR: {0} -> {1}'; H = 'ExibiÃ§Ã£o de desmontagem com tokens unidade/caminho'; F = $null }
    "NET_MGR_UNMOUNT_DISP"            = @{ T = '[DESMONTAR] {0}: -> {1}'; H = 'Formato de log de desmontagem com tokens'; F = $null }
    "NET_MGR_UNMOUNT_ALL"             = @{ T = 'DESMONTAR TODAS AS UNIDADES DE REDE'; H = 'OpÃ§Ã£o de menu para desmontagem em massa'; F = $null }
    "NET_MGR_AUTO_MOUNT"              = @{ T = 'AUTO-DETECTAR & MONTAR NOVO COFRE SAMBA'; H = 'OpÃ§Ã£o de menu para auto-montagem'; F = $null }
    "NET_MGR_BACK"                    = @{ T = 'RETORNAR AO MENU ANTERIOR'; H = 'OpÃ§Ã£o de navegaÃ§Ã£o para voltar'; F = $null }
    "NET_MGR_MOUNT_SUCCESS"           = @{ T = 'Mapeado em {0}'; H = 'Sucesso na montagem com token de caminho'; F = $null }
    "NET_MGR_ALL_REMOVED"             = @{ T = 'Todas as unidades de rede foram removidas.'; H = 'ConfirmaÃ§Ã£o de desmontagem em massa'; F = $null }
    "NET_MGR_UNMOUNT_REGEX"           = @{ T = '^(?:UNMOUNT|DESMONTAR|\[DESMONTAR\]):\s*([A-Z]):'; H = 'PadrÃ£o regex para parsing de comando de desmontagem'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # SQLITE DATABASE ENGINE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "SQLITE_ENGINE_LOADED"            = @{ T = 'Motor de InteroperaÃ§Ã£o Nativa Carregado do caminho: {0}'; H = 'Sucesso no carregamento do motor SQLite com token de caminho'; F = 'SQLITE_ENGINE' }
    "SQLITE_ENGINE_FAIL"              = @{ T = 'Falha ao carregar ou vincular dependÃªncia DLL do SQLite: {0}'; H = 'Falha no carregamento do SQLite com token de erro'; F = 'SQLITE_FATAL' }
    "SQLITE_DB_INIT"                  = @{ T = 'Esquema do banco de dados e estruturas relacionais inicializados com sucesso em modo WAL.'; H = 'Sucesso na inicializaÃ§Ã£o do banco de dados'; F = 'SQLITE_CORE' }
    "SQLITE_DB_FAIL"                  = @{ T = 'A sequÃªncia de inicializaÃ§Ã£o do esquema do banco de dados falhou: {0}'; H = 'Falha na inicializaÃ§Ã£o do banco com token de erro'; F = 'SQLITE_ERR' }
    "SQLITE_MEMORY_SPILL"             = @{ T = 'Falha ao confirmar o despejo do buffer de memÃ³ria para o banco de dados fÃ­sico: {0}'; H = 'Falha no spill de memÃ³ria com token de erro'; F = 'SQLITE_ERR' }
    "SQLITE_WAL_CHECKPOINT"           = @{ T = 'SequÃªncias de SQLite WAL Checkpoint, Pragma Optimize e VACUUM reportaram: CONSISTENT.'; H = 'Sucesso na manutenÃ§Ã£o do banco de dados'; F = 'SQLITE_SUCESSO' }
    "SQLITE_INTEGRITY_CHECK"          = @{ T = 'A verificaÃ§Ã£o de integridade interna do banco de dados passou 100%.'; H = 'Sucesso na verificaÃ§Ã£o de integridade'; F = 'SQLITE_AUDITORIA' }
    "SQLITE_CONNECTION_BUSY"          = @{ T = 'A thread do banco de dados estÃ¡ atualmente travada/ocupada. Engajando recuo de tentativa...'; H = 'Aviso de banco de dados ocupado'; F = 'SQLITE_WARN' }

    "DB_LOCATION_INFO"                = @{ T = 'Banco de dados forense salvo com seguranÃ§a em: {0}'; H = 'InformaÃ§Ã£o de localizaÃ§Ã£o do banco com token de caminho'; F = 'DB' }
    "DB_QUERY_PROMPT"                 = @{ T = "Digite a Consulta SQL (ou 'exit' para voltar): "; H = 'Prompt de entrada do console SQL'; F = $null }
    "DB_QUERY_RESULT"                 = @{ T = 'Consulta Executada. Linhas afetadas/retornadas: {0}'; H = 'Resultado de consulta com token de contagem de linhas'; F = $null }
    "DB_QUERY_ERROR"                  = @{ T = 'Falha na execuÃ§Ã£o da consulta: {0}'; H = 'Erro de consulta com token de exceÃ§Ã£o'; F = 'DB_ERR' }
    "DB_MONITOR_STATS"                = @{ T = 'Registros: {0} | Ã“rfÃ£os: {1} | Gravado: {2} MB'; H = 'ExibiÃ§Ã£o de estatÃ­sticas ao vivo com tokens de registro/Ã³rfÃ£o/tamanho'; F = 'LIVE' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # INTEGRITY & FAILSAFE SYSTEMS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "INT_MFT_MIRROR_DIV"              = @{ T = 'DivergÃªncia entre a MFT primÃ¡ria e o MFTMirror detectada. A lÃ³gica subjacente do sistema de arquivos estÃ¡ comprometida.'; H = 'Alerta de integridade por divergÃªncia de MFT'; F = 'ALERTA_SANCTUARY' }
    "INT_SQLITE_CORRUPT"              = @{ T = 'CorrupÃ§Ã£o no Write-Ahead Log (WAL) do SQLite detectada. ForÃ§ando vacuum estrutural e reconstruÃ§Ã£o.'; H = 'RecuperaÃ§Ã£o de corrupÃ§Ã£o WAL do SQLite'; F = 'SQLITE_FATAL' }
    "INT_MODE_CONFLICT"               = @{ T = "O sistema de arquivos detectado '{0}' inerentemente nÃ£o suporta o modo de parsing de motor '{1}'."; H = 'Incompatibilidade filesystem/modo com tokens'; F = 'CONFLITO_CONFIG' }
    "INT_FAILSAFE_TRIG"               = @{ T = 'A trajetÃ³ria determinÃ­stica primÃ¡ria falhou. Engajando fallback de extraÃ§Ã£o ArqueolÃ³gica profunda em {0} segundos.'; H = 'Gatilho de fallback com token de contagem regressiva'; F = 'FAILSAFE_PIPELINE' }
    "INT_FALLBACK_ABORT"              = @{ T = 'OperaÃ§Ã£o forÃ§adamente cancelada pelo operador. O motor estritamente nÃ£o pode processar partiÃ§Ãµes RAW ou Linux enquanto travado no modo EFFICIENCY.'; H = 'Aviso de abort de fallback'; F = 'ABORTAR' }
    "INT_CONVERSION_AUTH"             = @{ T = 'Autoriza a conversÃ£o automÃ¡tica para o modo REDUNDANCY (Esquema UniversalMetadata)? [S/N]'; H = 'Prompt de autorizaÃ§Ã£o de conversÃ£o de modo'; F = 'INTERVENÃ‡ÃƒO_NECESSÃRIA' }
    "INT_CONVERSION_OK"               = @{ T = 'EngineMode alterado com sucesso para REDUNDANCY.'; H = 'ConfirmaÃ§Ã£o de conversÃ£o de modo'; F = 'ATUALIZAÃ‡ÃƒO_CONFIG' }
    "INT_CHECKPOINT_CREATED"          = @{ T = 'Ponto de verificaÃ§Ã£o operacional salvo no banco de dados. A capacidade de retomada do motor estÃ¡ agora ativa.'; H = 'ConfirmaÃ§Ã£o de criaÃ§Ã£o de checkpoint'; F = 'MÃQUINA_ESTADO' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # PIPELINE / EXTRACTION FLOW
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "PIPE_TRAVERSAL_START"            = @{ T = 'Caminhando a Ã¡rvore de metadados deterministicamente em {0}...'; H = 'InÃ­cio de travessia com token de alvo'; F = 'INIT_TRAVERSAL' }
    "PIPE_TRAVERSAL_COMPLETE"         = @{ T = 'Caminhada de metadados do sistema de arquivos concluÃ­da com sucesso.'; H = 'Aviso de conclusÃ£o de travessia'; F = 'TRAVERSAL_CONCLUÃDO' }
    "PIPE_ARCHAEOLOGY_START"          = @{ T = 'Varredura bruta de assinaturas hexadecimais iniciada para o motor: {0}.'; H = 'InÃ­cio de arqueologia com token de motor'; F = 'INIT_ARQUEOLOGIA' }
    "PIPE_ARCHAEOLOGY_COMPLETE"       = @{ T = 'ExtraÃ§Ã£o profunda da superfÃ­cie do disco concluÃ­da.'; H = 'Aviso de conclusÃ£o de arqueologia'; F = 'ARQUEOLOGIA_CONCLUÃDA' }
    "PIPE_BATCH_START"                = @{ T = 'Igniciando motor de extraÃ§Ã£o no modo [{0}] para a categoria ({1})...'; H = 'InÃ­cio de lote com tokens de modo/categoria'; F = 'MOTOR_LOTE' }
    "PIPE_BATCH_COMPLETE"             = @{ T = 'OperaÃ§Ãµes de extraÃ§Ã£o em lote Harvester finalizadas.'; H = 'Aviso de conclusÃ£o de lote'; F = 'MOTOR_LOTE' }
    "PIPE_EXTRACT_COUNTER"            = @{ T = '[{0}] Processando carga: {1}'; H = 'Progresso de extraÃ§Ã£o com tokens de Ã­ndice/arquivo'; F = 'FLUXO_EXTRAÃ‡ÃƒO' }
    "PIPE_STREAMING_DATA"             = @{ T = 'STREAMING_DATA_FOR_RECORD: InjeÃ§Ã£o de Buffer de E/S Sincronizada.'; H = 'Aviso de sincronizaÃ§Ã£o de streaming de dados'; F = 'SYNC_PIPELINE' }
    "PIPE_TARGETED_RECOVERY"          = @{ T = 'SEQUÃŠNCIA DE RECUPERAÃ‡ÃƒO TARGETADA ATIVADA E TRAVADA.'; H = 'AtivaÃ§Ã£o de recuperaÃ§Ã£o direcionada'; F = 'EXEC_PIPELINE' }

    "PIPE_FALLBACK_WARNING"           = @{ T = 'OS METADADOS DO SISTEMA DE ARQUIVOS ESTÃƒO CORROMPIDOS, CRIPTOGRAFADOS OU FISICAMENTE INACESSÃVEIS.'; H = 'Aviso crÃ­tico de corrupÃ§Ã£o de metadados'; F = 'AVISO_CRÃTICO' }
    "PIPE_FALLBACK_IMMINENT"          = @{ T = 'RECUANDO PARA EXTRAÃ‡ÃƒO DE DADOS BRUTOS (PLANO B). SOBRECARGA EXTREMA DE E/S Ã‰ IMINENTE.'; H = 'Aviso de fallback iminente'; F = 'AVISO_CRÃTICO' }
    "PIPE_FALLBACK_COUNTDOWN"         = @{ T = 'AGUARDANDO {0} SEGUNDOS PARA ABORTAR A OPERAÃ‡ÃƒO (PRESSIONE CTRL+C AGORA)...'; H = 'Contagem regressiva de fallback com token de segundos'; F = 'TIMER_FAILSAFE' }
    "PIPE_FALLBACK_ENGAGED"           = @{ T = 'TEMPO ESGOTADO. ENGATANDO MECANISMO DE VARREDURA ARQUEOLÃ“GICA.'; H = 'ConfirmaÃ§Ã£o de engajamento de fallback'; F = 'FAILSAFE_ACIONADO' }
    "PIPE_EXTRACTION_PHASE"           = @{ T = 'Iniciando a fase fÃ­sica de extraÃ§Ã£o de bytes...'; H = 'TransiÃ§Ã£o para fase de extraÃ§Ã£o'; F = 'TRANSIÃ‡ÃƒO_PIPELINE' }
    "PIPE_CARVING_PROGRESS"           = @{ T = 'Offset FÃ­sico: {0} GB | Taxa de Transf.: {1} MB/s | Ã“rfÃ£os Recuperados: {2}'; H = 'Telemetria de carving com tokens de offset/velocidade/contagem'; F = 'TELEMETRIA_CARVING' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # UI / INTERACTIVE EXPLORER
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "UI_ExplorerTitle"                = @{ T = 'EXPLORADOR DE ARQUIVOS INTERATIVO - SISTEMA DE RECUPERAÃ‡ÃƒO SCAPE'; H = 'TÃ­tulo da janela do explorador'; F = $null }
    "UI_BreadcrumbRoot"               = @{ T = 'RAIZ_VIRTUAL'; H = 'RÃ³tulo de breadcrumb raiz'; F = $null }
    "UI_NavHelp"                      = @{ T = 'ATALHOS: [CIMA/BAIXO] Navegar | [ENTER] Abrir Pasta | [ESPAÃ‡O] Alternar MarcaÃ§Ã£o | [E] Executar ExtraÃ§Ã£o | [B] Voltar | [Q] Sair do Explorador'; H = 'Texto de ajuda de navegaÃ§Ã£o do explorador'; F = $null }
    "UI_DirIcon"                      = @{ T = '[DIR ]'; H = 'Indicador de Ã­cone de diretÃ³rio'; F = $null }
    "UI_FileIcon"                     = @{ T = '[ARQ ]'; H = 'Indicador de Ã­cone de arquivo'; F = $null }
    "UI_Marked"                       = @{ T = '[X]'; H = 'Indicador de item marcado'; F = $null }
    "UI_Unmarked"                     = @{ T = '[ ]'; H = 'Indicador de item nÃ£o marcado'; F = $null }
    "UI_Cursor"                       = @{ T = '>>> '; H = 'Indicador de cursor de seleÃ§Ã£o'; F = $null }
    "UI_EmptyFolder"                  = @{ T = '[ DIRETÃ“RIO ESTÃ VAZIO OU ILEGÃVEL ]'; H = 'Aviso de pasta vazia/ilegÃ­vel'; F = $null }

    "UI_ConfirmExtract"               = @{ T = 'PERIGO: Confirmar extraÃ§Ã£o fÃ­sica de {0} itens selecionados (incluindo todos os filhos recursivos)? (s/N): '; H = 'ConfirmaÃ§Ã£o de extraÃ§Ã£o recursiva com token de contagem'; F = $null }
    "UI_Extracting"                   = @{ T = 'Processando extraÃ§Ã£o fÃ­sica para {0} objetos marcados...'; H = 'Progresso de extraÃ§Ã£o com token de contagem'; F = $null }
    "UI_ExtractComplete"              = @{ T = 'ExtraÃ§Ã£o targetada confirmada com sucesso para o caminho de staging: {0}'; H = 'Sucesso na extraÃ§Ã£o com token de caminho'; F = $null }
    "UI_LoadError"                    = @{ T = 'Erro fatal ao carregar os itens do nÃ³ de diretÃ³rio: {0}'; H = 'Erro de carregamento de diretÃ³rio com token de exceÃ§Ã£o'; F = $null }

    "UI_SelectFolder"                 = @{ T = 'SELECIONE SANDBOX DE DESTINO ISOLADO PARA STAGING'; H = 'CabeÃ§alho de seleÃ§Ã£o de pasta de staging'; F = $null }
    "UI_StagingFolderPrompt"          = @{ T = 'Digite o caminho completo da pasta de Staging (SSD Local recomendado)'; H = 'InstruÃ§Ã£o de entrada de caminho de staging'; F = $null }
    "UI_DestinationPrompt"            = @{ T = 'Digite o caminho completo do Destino final (OneDrive/Google Drive/Compartilhamento de Rede UNC)'; H = 'InstruÃ§Ã£o de entrada de caminho de destino'; F = $null }
    "UI_MarkRecursiveHint"            = @{ T = 'O modificador [R] indica uma marcaÃ§Ã£o recursiva - todos os objetos filhos dentro do diretÃ³rio serÃ£o extraÃ­dos.'; H = 'Dica de marcaÃ§Ã£o recursiva'; F = $null }
    "UI_SELECT_DIR_ERROR"             = @{ T = 'Falha ao iniciar seletor de diretÃ³rios: {0}'; H = 'Erro no seletor de diretÃ³rios com token de exceÃ§Ã£o'; F = $null }
    "UI_SELECT_DIR_PROMPT"            = @{ T = 'Selecione o diretÃ³rio de saÃ­da:'; H = 'Prompt de seleÃ§Ã£o de diretÃ³rio'; F = $null }
    "UI_SELECT_DIR_FALLBACK"          = @{ T = 'Digite o caminho do diretÃ³rio manualmente: '; H = 'Fallback para entrada manual de caminho'; F = $null }
    "UI_CANCEL_OP"                    = @{ T = '[CANCELAR OPERAÃ‡ÃƒO]'; H = 'RÃ³tulo do botÃ£o cancelar'; F = $null }
    "UI_BTN_BACK"                     = @{ T = '>> VOLTAR'; H = 'BotÃ£o de navegaÃ§Ã£o para voltar'; F = $null }

    "UI_COMPLIANCE_DISCLAIMER"        = @{ T = 'O acesso a setores RAW acarreta risco de estresse de hardware ou perda de dados. Aceitar? (s/N): '; H = 'Aviso de risco de acesso RAW'; F = 'COMPLIANCE DASD' }
    "UI_ABORT_CONFIRM_CRITICAL"       = @{ T = 'Abortar E/S ativa pode deixar handles abertos ou corromper o banco de dados. ForÃ§ar Abortar? (s/N): '; H = 'ConfirmaÃ§Ã£o de abort crÃ­tico'; F = 'AVISO CRÃTICO' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # VIEW / DASHBOARD UI
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "DASH_HEADER_NODE"                = @{ T = 'SYSTEM-CRITICAL ANALYSIS PARTITION EXTRACTOR | NÃ“: {0}'; H = 'CabeÃ§alho do dashboard com token de nÃ³'; F = $null }
    "BANNER_TITLE"                    = @{ T = 'SCAPE Recovery System - Motor Forense AvanÃ§ado v1.0'; H = 'TÃ­tulo do banner da aplicaÃ§Ã£o'; F = $null }

    "DASH_TASK"                       = @{ T = 'TAREFA: {0}'; H = 'ExibiÃ§Ã£o de tarefa do dashboard com token'; F = $null }
    "DASH_LINE1"                      = @{ T = 'DISK_QUEUE: {0} | THERMAL: {1}C | RAM_PRESSURE: {2}%'; H = 'Linha de mÃ©tricas do dashboard com tokens fila/temp/ram'; F = $null }
    "DASH_LINE2"                      = @{ T = 'DB_PARSED: {0} | DB_ORPHANS: {1} | DB_EXTRACTED: {2}'; H = 'Linha de mÃ©tricas do dashboard com tokens de estatÃ­sticas do BD'; F = $null }
    "DASH_LINE3"                      = @{ T = 'LCN_POS: {0} | PROG: {1} | RATE: {2} MB/s'; H = 'Linha de mÃ©tricas do dashboard com tokens de progresso/taxa'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # ROBOCOPY / CLOUD SYNC CONFIG
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "RC_TITLE"                        = @{ T = 'LOGÃSTICA & PAINEL DE CONTROLE DE CLOUD SYNC - SCAPE ROBOSYNC'; H = 'TÃ­tulo do painel Robocopy'; F = $null }
    "RC_STAGING_LABEL"                = @{ T = 'DiretÃ³rio de Staging Local'; H = 'RÃ³tulo do campo de caminho de staging'; F = $null }
    "RC_DEST_LABEL"                   = @{ T = 'Destino Final Cloud/UNC'; H = 'RÃ³tulo do campo de caminho de destino'; F = $null }

    "RC_FLAG_E"                       = @{ T = '/E : Copiar todos os subdiretÃ³rios (incluindo diretÃ³rios vazios)'; H = 'DescriÃ§Ã£o da flag /E do Robocopy'; F = $null }
    "RC_FLAG_ZB"                      = @{ T = '/ZB: Modo RestartÃ¡vel + Backup (ResiliÃªncia de rede)'; H = 'DescriÃ§Ã£o da flag /ZB do Robocopy'; F = $null }
    "RC_FLAG_M"                       = @{ T = '/M : Modo Archive Bit (Copiar apenas arquivos nÃ£o sincronizados)'; H = 'DescriÃ§Ã£o da flag /M do Robocopy'; F = $null }
    "RC_FLAG_MT"                      = @{ T = '/MT: TransferÃªncia Multithread (Valor auto-sensed: {0})'; H = 'DescriÃ§Ã£o da flag /MT do Robocopy com token de threads'; F = $null }
    "RC_FLAG_B"                       = @{ T = '/B : Modo Backup (Bypass estrito de ACLs/PermissÃµes NTFS)'; H = 'DescriÃ§Ã£o da flag /B do Robocopy'; F = $null }
    "RC_FLAG_COPYALL"                 = @{ T = '/COPYALL: Espelhar todos os metadados (Dados, Atributos, Timestamps, SeguranÃ§a, ProprietÃ¡rio, Auditoria)'; H = 'DescriÃ§Ã£o da flag /COPYALL do Robocopy'; F = $null }
    "RC_FLAG_DCOPY_T"                 = @{ T = '/DCOPY:T: Preservar estritamente os timestamps de diretÃ³rio'; H = 'DescriÃ§Ã£o da flag /DCOPY:T do Robocopy'; F = $null }
    "RC_FLAG_NP"                      = @{ T = '/NP: Suprimir porcentagem de progresso (ForÃ§a logs limpos para execuÃ§Ãµes industriais)'; H = 'DescriÃ§Ã£o da flag /NP do Robocopy'; F = $null }
    "RC_FLAG_FFT"                     = @{ T = '/FFT: ForÃ§ar tempos de arquivo FAT (TolerÃ¢ncia de granularidade de 2 segundos)'; H = 'DescriÃ§Ã£o da flag /FFT do Robocopy'; F = $null }
    "RC_FLAG_XO"                      = @{ T = '/XO: Excluir arquivos mais antigos (PrevenÃ§Ã£o de redundÃ¢ncia)'; H = 'DescriÃ§Ã£o da flag /XO do Robocopy'; F = $null }
    "RC_FLAG_XN"                      = @{ T = '/XN: Excluir arquivos mais novos (Espelhamento unidirecional)'; H = 'DescriÃ§Ã£o da flag /XN do Robocopy'; F = $null }
    "RC_FLAG_XJ"                      = @{ T = '/XJ: Excluir pontos de junÃ§Ã£o (Previne loops infinitos de symlink)'; H = 'DescriÃ§Ã£o da flag /XJ do Robocopy'; F = $null }
    "RC_FLAG_L"                       = @{ T = '/L : Modo SimulaÃ§Ã£o Apenas Leitura (Dry run, nenhum byte transferido)'; H = 'DescriÃ§Ã£o da flag /L do Robocopy'; F = $null }
    "RC_FLAG_V"                       = @{ T = '/V : SaÃ­da Verbosa (Habilita logs detalhados para cadeias de evidÃªncia judiciais)'; H = 'DescriÃ§Ã£o da flag /V do Robocopy'; F = $null }

    "RC_FLAG_E_DESC"                  = @{ T = 'Copia todos os subdiretÃ³rios, incluindo os vazios. Essencial para reconstruir a topologia exata de diretÃ³rios.'; H = 'ExplicaÃ§Ã£o detalhada da flag /E'; F = $null }
    "RC_FLAG_M_DESC"                  = @{ T = "Modo Archive Bit: Apenas espelha arquivos que nÃ£o foram previamente sincronizados. Reseta a flag 'Archive' apÃ³s cÃ³pia bem sucedida para minimizar desgaste no SSD."; H = 'ExplicaÃ§Ã£o detalhada da flag /M'; F = $null }
    "RC_FLAG_ZB_DESC"                 = @{ T = 'Modo ReiniciÃ¡vel: Altamente crÃ­tico para conexÃµes instÃ¡veis de rede ou nuvem. Previne corrupÃ§Ã£o de arquivos retomando transferÃªncias interrompidas.'; H = 'ExplicaÃ§Ã£o detalhada da flag /ZB'; F = $null }
    "RC_FLAG_MT_DESC"                 = @{ T = 'Capacidade Multi-Thread: Valores altos (64-128) recomendados para NVMe-para-NVMe. Valores baixos (8-16) requeridos para compartilhamentos de Rede/Samba instÃ¡veis.'; H = 'ExplicaÃ§Ã£o detalhada da flag /MT'; F = $null }
    "RC_FLAG_B_DESC"                  = @{ T = 'MODO BACKUP: Explora SeBackupPrivilege para ler arquivos bloqueados forÃ§adamente, independentemente de permissÃµes NTFS corrompidas ou restritivas.'; H = 'ExplicaÃ§Ã£o detalhada da flag /B'; F = $null }
    "RC_FLAG_FFT_DESC"                = @{ T = 'Tempos de Arquivo FAT: ObrigatÃ³rio ao espelhar dados entre volumes NTFS precisos e dispositivos FAT/exFAT menos precisos para evitar falsos positivos em diferenÃ§as de horÃ¡rio.'; H = 'ExplicaÃ§Ã£o detalhada da flag /FFT'; F = $null }
    "RC_FLAG_XO_DESC"                 = @{ T = 'Excluir Mais Antigos: Ignora arquivos que jÃ¡ existem e sÃ£o estritamente mais novos no alvo de destino. Excelente para prevenÃ§Ã£o de redundÃ¢ncia.'; H = 'ExplicaÃ§Ã£o detalhada da flag /XO'; F = $null }
    "RC_FLAG_XN_DESC"                 = @{ T = 'Excluir Mais Novos: Pula a cÃ³pia de arquivos que sÃ£o mais novos no alvo de destino. Ãštil para sincronizaÃ§Ã£o estrita de arquivo unidirecional.'; H = 'ExplicaÃ§Ã£o detalhada da flag /XN'; F = $null }
    "RC_FLAG_XJ_DESC"                 = @{ T = 'Excluir JunÃ§Ãµes: Previne o motor de cair em loops de recursÃ£o infinitos ao sincronizar diretÃ³rios contendo links simbÃ³licos quebrados.'; H = 'ExplicaÃ§Ã£o detalhada da flag /XJ'; F = $null }
    "RC_FLAG_NP_DESC"                 = @{ T = 'Sem Progresso: Suprime o contador de porcentagem na saÃ­da padrÃ£o. ObrigatÃ³rio para manter os arquivos de log legÃ­veis para scripts automatizados de parsing.'; H = 'ExplicaÃ§Ã£o detalhada da flag /NP'; F = $null }
    "RC_FLAG_L_DESC"                  = @{ T = 'MODO SIMULAÃ‡ÃƒO: Lista todos os arquivos que seriam processados sem realmente mover nenhum byte. Crucial para testes de sanidade antes de operaÃ§Ãµes massivas.'; H = 'ExplicaÃ§Ã£o detalhada da flag /L'; F = $null }
    "RC_FLAG_V_DESC"                  = @{ T = 'MODO VERBOSO: Gera logs altamente detalhados, detalhando cada arquivo pulado e cÃ³digos de erro exatos. Legalmente exigido para manter cadeia de custÃ³dia.'; H = 'ExplicaÃ§Ã£o detalhada da flag /V'; F = $null }

    "RC_RETRY_R"                      = @{ T = '/R : Contagem de tentativas de repetiÃ§Ã£o em falha'; H = 'RÃ³tulo da flag /R do Robocopy'; F = $null }
    "RC_RETRY_W"                      = @{ T = '/W : Tempo de limite de espera entre tentativas (em segundos)'; H = 'RÃ³tulo da flag /W do Robocopy'; F = $null }
    "RC_RETRY_R_DESC"                 = @{ T = 'Contagem de Tentativas: NÃºmero exato de vezes que o motor tentarÃ¡ novamente uma transferÃªncia de byte falha. O padrÃ£o Ã© 3. Aumente significativamente para redes WAN altamente instÃ¡veis.'; H = 'ExplicaÃ§Ã£o detalhada da flag /R'; F = $null }
    "RC_RETRY_W_DESC"                 = @{ T = 'Tempo de Espera: Segundos absolutos que o motor pausarÃ¡ antes de tentar novamente uma transferÃªncia falha. O padrÃ£o Ã© 10. Aumente para endpoints de nuvem instÃ¡veis.'; H = 'ExplicaÃ§Ã£o detalhada da flag /W'; F = $null }
    "RC_WAIT_RETRY"                   = @{ T = '/R:{0} /W:{1} (Tentativas Config.: {0} | Intervalo Espera: {1}s)'; H = 'ExibiÃ§Ã£o de configuraÃ§Ã£o de retry com tokens'; F = $null }

    "RC_CACHE_ADVISORY"               = @{ T = 'GUIA DE TOPOLOGIA DE CACHE: Certifique-se de que sua unidade de Staging designada tem pelo menos 200% do espaÃ§o livre do maior arquivo absoluto sendo recuperado para prevenir fatalidade por estouro de buffer durante o hashing do Robocopy.'; H = 'Aviso de espaÃ§o de staging'; F = $null }
    "RC_HW_WEAR_LONG"                 = @{ T = 'AVISO CRÃTICO DE RESISTÃŠNCIA: O movimento massivo de dados fÃ­sicos para um diretÃ³rio de Staging Cloud Local induz Ciclos de Escrita NAND extremamente altos (TBW). Certifique-se de que a unidade de staging Ã© classificada como Enterprise/Industrial.'; H = 'Aviso de resistÃªncia de hardware'; F = $null }
    "RC_ENV_GUIDE"                    = @{ T = "GUIA DE CONFIGURAÃ‡ÃƒO ROBOSYNC:`n 1. Defina 'Staging' para uma unidade NVMe/SSD local, fisicamente conectada.`n 2. Defina 'Destino' para a sua pasta de endpoint Sincronizada em Nuvem (ex: OneDrive, Google Drive).`n 3. CRÃTICO: Garanta que 'Arquivos Sob Demanda' da Nuvem (ou equivalente) esteja estritamente DESLIGADO para a pasta Staging para prevenir que o motor de sincronizaÃ§Ã£o entre em loop infinito."; H = 'Guia de configuraÃ§Ã£o do Robosync'; F = $null }

    "RC_START_SYNC"                   = @{ T = '[S] INICIAR MOTOR DE SINCRONIZAÃ‡ÃƒO'; H = 'OpÃ§Ã£o de menu para iniciar sincronismo'; F = $null }
    "RC_CANCEL"                       = @{ T = '[C] ABORTAR CONFIGURAÃ‡ÃƒO DE SINCRONIZAÃ‡ÃƒO'; H = 'OpÃ§Ã£o de menu para cancelar sincronismo'; F = $null }
    "RC_SPACE_CHECK"                  = @{ T = 'EspaÃ§o livre verificado no hardware de staging local: {0} GB'; H = 'VerificaÃ§Ã£o de espaÃ§o com token em GB'; F = $null }
    "RC_SPACE_LOW_CONFIRM"            = @{ T = 'PERIGO: EspaÃ§o em disco baixo detectado na unidade de staging. Prosseguir pode causar instabilidade no SO. Continuar mesmo assim? (s/N): '; H = 'Prompt de confirmaÃ§Ã£o de espaÃ§o baixo'; F = $null }
    "RC_ARCHIVE_MODE_INFO"            = @{ T = '[INFO_ADVISORY] A flag /M (Archive) reduz significativamente o desgaste do SSD pulando agressivamente cargas jÃ¡ sincronizadas.'; H = 'Aviso de benefÃ­cio do modo archive'; F = $null }
    "RC_INVALID_MT"                   = @{ T = 'EspecificaÃ§Ã£o de contagem de thread invÃ¡lida. ForÃ§ando valor Ã³timo auto-sensed.'; H = 'Tratamento de entrada MT invÃ¡lida'; F = 'INPUT_ERR' }
    "RC_AUTOSENSE"                    = @{ T = "Meio de destino '{0}' detectado -> Threads de transferÃªncia limitadas agressivamente a {1} para prevenir estrangulamento de I/O."; H = 'Aviso de auto-sense com tokens de meio/threads'; F = 'THROTTLE_AUTOSENSE' }

    "RC_SYNC_RUNNING"                 = @{ T = 'Pipeline de sincronizaÃ§Ã£o estÃ¡ atualmente quente. Motor Robocopy estÃ¡ executando...'; H = 'Aviso de sincronismo em progresso'; F = 'ROBOSYNC_ATIVO' }
    "RC_CALCULATING_SIZE"             = @{ T = 'Calculando footprint total de bytes dos objetos de carga selecionados...'; H = 'Aviso de cÃ¡lculo de tamanho de carga'; F = 'ROBOSYNC_PREFLIGHT' }
    "RC_BLOCKED_SPACE"                = @{ T = 'OPERAÃ‡ÃƒO BLOQUEADA: Tamanho da carga excede drasticamente o espaÃ§o fÃ­sico disponÃ­vel na unidade de staging.'; H = 'Erro de bloqueio por espaÃ§o'; F = 'ROBOSYNC_FATAL' }
    "RC_ROBOCOPY_NOT_FOUND"           = @{ T = 'O executÃ¡vel nativo Robocopy.exe nÃ£o foi encontrado no PATH do ambiente do sistema.'; H = 'Erro de Robocopy nÃ£o encontrado'; F = 'ROBOSYNC_FATAL' }
    "RC_EXIT_CODE_INFO"               = @{ T = 'Processo Robocopy terminou com cÃ³digo de saÃ­da {0}: {1}'; H = 'InformaÃ§Ã£o de cÃ³digo de saÃ­da com tokens cÃ³digo/desc'; F = 'ROBOSYNC_AUDITORIA' }
    "RC_LOG_SAVED"                    = @{ T = 'Log de transaÃ§Ã£o detalhado do Robocopy comitado com seguranÃ§a para: {0}'; H = 'Log salvo com token de caminho'; F = 'ROBOSYNC_AUDITORIA' }

    "RC_BTN_START"                    = @{ T = '[ INICIAR SINCRONIZAÃ‡ÃƒO ROBOSYNC ]'; H = 'RÃ³tulo do botÃ£o de iniciar sincronismo'; F = $null }
    "RC_BTN_CANCEL"                   = @{ T = '[ ABORTAR E VOLTAR ]'; H = 'RÃ³tulo do botÃ£o de cancelar'; F = $null }
    "RC_DEFAULTS_TITLE"               = @{ T = 'CONFIGURAÃ‡ÃƒO DE PARÃ‚METROS GLOBAIS DO ROBOCOPY'; H = 'TÃ­tulo do painel de configuraÃ§Ã£o de padrÃµes'; F = $null }
    "RC_SAVE_RETURN"                  = @{ T = '[ SALVAR CONFIGURAÃ‡ÃƒO E VOLTAR ]'; H = 'BotÃ£o de salvar e retornar'; F = $null }
    "RC_DEL_RTN"                      = @{ T = '[ DESCARTAR ALTERACOES E VOLTAR ]'; H = 'BotÃ£o de descartar e retornar'; F = $null }
    "RC_BTN_PREPARE_FLAGS"            = @{ T = 'PREPARAR_FLAGS_ARQUIVO (Bitwise Tagging)'; H = 'RÃ³tulo do botÃ£o preparar flags'; F = $null }
    "RC_BTN_PREPARE_FLAGS_DESC"       = @{ T = '[ PREPARAR FLAGS DE ARQUIVO (Bitwise Tagging) ]'; H = 'DescriÃ§Ã£o do botÃ£o preparar flags'; F = $null }
    "RC_BTN_EDIT_DESC"                = @{ T = '[ CONFIGURAR FLAGS DO ROBOCOPY ]'; H = 'BotÃ£o de configurar flags'; F = $null }
    "RC_TAGGING_START"                = @{ T = 'Iniciando Marcacao de Archive Bit em Alta Velocidade em {0}...'; H = 'InÃ­cio de tagging com token de alvo'; F = 'ROBOSYNC' }
    "RC_TAGGING_DONE"                 = @{ T = 'Marcacao de Archive Bit Concluida.'; H = 'Aviso de conclusÃ£o de tagging'; F = 'ROBOSYNC' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # DEPLOYER / COMPILER ENGINE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "DEPLOYER_START"                  = @{ T = 'Iniciando orquestraÃ§Ã£o estrutural dinÃ¢mica do Monolito SCAPE...'; H = 'InicializaÃ§Ã£o do deployer'; F = 'DEPLOYER_INIT' }
    "DEPLOYER_PURGE"                  = @{ T = 'Ãrvore de implantaÃ§Ã£o ativa anterior detectada. Purgando arquitetura antiga...'; H = 'Aviso de purga de build antigo'; F = 'DEPLOYER_WARN' }
    "DEPLOYER_EXTRACT"                = @{ T = 'Extraindo cargas modulares dinamicamente da matriz...'; H = 'InÃ­cio de extraÃ§Ã£o de mÃ³dulos'; F = 'DEPLOYER_EXEC' }
    "DEPLOYER_EXTRACT_OK"             = @{ T = '-> [DEPLOYER_OK] MÃ³dulo payload extraÃ­do perfeitamente: {0}'; H = 'Sucesso na extraÃ§Ã£o de mÃ³dulo com token de nome'; F = $null }
    "DEPLOYER_EXTRACT_FAIL"           = @{ T = "[DEPLOYER_ERROR] Falha catastrÃ³fica ao extrair o mÃ³dulo '{0}': {1}"; H = 'Falha na extraÃ§Ã£o de mÃ³dulo com tokens nome/erro'; F = $null }
    "DEPLOYER_GENERATE"               = @{ T = 'Gerando e linkando o bootloader Maestro (Main.ps1)...'; H = 'Aviso de geraÃ§Ã£o de bootloader'; F = 'DEPLOYER_LINK' }
    "DEPLOYER_SUCCESS"                = @{ T = 'Monolito de RecuperaÃ§Ã£o SCAPE gerado e compilado com sucesso!'; H = 'Banner de sucesso de build'; F = 'DEPLOYER_DONE' }
    "DEPLOYER_LOCATION"               = @{ T = 'Local de ExecuÃ§Ã£o FÃ­sica: {0}'; H = 'LocalizaÃ§Ã£o de build com token de caminho'; F = $null }
    "DEPLOYER_FATAL"                  = @{ T = 'CompilaÃ§Ã£o do sistema falhou criticamente: {0}'; H = 'Erro fatal de build com token de exceÃ§Ã£o'; F = 'DEPLOYER_FATAL' }
    "DEPLOYER_RUN_ADMIN"              = @{ T = 'DIRETIVA CRÃTICA: Execute o Main.ps1 como Administrador para funcionalidade de hardware completa.'; H = 'Diretiva de execuÃ§Ã£o como admin'; F = $null }

    "DEPLOYER_OPT_DEV"                = @{ T = 'DEV_MODE (Extrair mÃ³dulos e gerar Main.ps1)'; H = 'OpÃ§Ã£o de menu modo dev'; F = '1' }
    "DEPLOYER_OPT_EXE"                = @{ T = 'BUILD_EXE (Compilar via ps2exe)'; H = 'OpÃ§Ã£o de menu build portÃ¡til EXE'; F = '2' }
    "DEPLOYER_OPT_SETUP"              = @{ T = 'BUILD_EXE (Compilar via INNO Setup)'; H = 'OpÃ§Ã£o de menu instalador EXE'; F = '3' }
    "DEPLOYER_OPT_MSI"                = @{ T = 'BUILD_MSI (Compilar via WiX Toolset)'; H = 'OpÃ§Ã£o de menu build MSI'; F = '4' }
    "MENU_DEPLOY_TITLE"               = @{ T = '[ MATRIZ DE DEPLOY SCAPE ]'; H = 'CabeÃ§alho do menu deployer'; F = $null }
    "DEPLOYER_MATRIX_HEADER"          = @{ T = '[ MATRIZ DE VETORES DE DEPLOY SCAPE ]'; H = 'CabeÃ§alho de seleÃ§Ã£o do vetor de deploy'; F = $null }
    "DEPLOYER_MOD_DISCOVERY"          = @{ T = 'Varrendo escopo por assinaturas de mÃ³dulos...'; H = 'InÃ­cio de auto-descoberta'; F = 'DEPLOYER_AUTO_DESCOBERTA' }
    "DEPLOYER_ASSETS_DISCOVERY"       = @{ T = 'Varrendo escopo por assinaturas de ativos binÃ¡rios...'; H = 'InÃ­cio de descoberta de ativos'; F = 'DEPLOYER_AUTO_ASSETS' }

    "DEPLOYER_B64_START"              = @{ T = 'BinÃ¡rios SQLite encontrados. Convertendo para DNA (Base64)...'; H = 'InÃ­cio de conversÃ£o de binÃ¡rios'; F = 'DEPLOYER' }
    "DEPLOYER_B64_SUCCESS"            = @{ T = 'BinÃ¡rios convertidos e injetados no DNA do Core.'; H = 'Sucesso na injeÃ§Ã£o de binÃ¡rios'; F = 'DEPLOYER' }
    "DEPLOYER_B64_MISSING"            = @{ T = 'DLLs do SQLite nÃ£o encontradas. O Core tentarÃ¡ download em runtime.'; H = 'Aviso de fallback para DLLs ausentes'; F = 'WARN' }
    "DEPLOYER_B64_DOWNLOADING_BUNDLE" = @{ T = 'Baixando pacote SQLite de {0} ...'; H = 'Download de bundle com token de URL'; F = $null }
    "DEPLOYER_B64_BUNDLE_FAIL"        = @{ T = 'Falha no download do pacote. Tentando pacotes separados...'; H = 'Aviso de fallback de download de bundle'; F = $null }
    "DEPLOYER_B64_DOWNLOADING_X86"    = @{ T = 'Baixando pacote x86...'; H = 'Aviso de download x86'; F = $null }
    "DEPLOYER_B64_DOWNLOADING_X64"    = @{ T = 'Baixando pacote x64...'; H = 'Aviso de download x64'; F = $null }
    "DEPLOYER_B64_SEPARATE_FAIL"      = @{ T = 'Falha ao baixar pacotes separados: {0}'; H = 'Falha no download separado com token de erro'; F = $null }
    "DEPLOYER_B64_FOUND_FILES"        = @{ T = 'Arquivos encontrados no temporÃ¡rio:'; H = 'CabeÃ§alho de lista de arquivos temporÃ¡rios'; F = $null }
    "DEPLOYER_B64_NO_MANAGED"         = @{ T = 'System.Data.SQLite.dll nÃ£o encontrada no pacote baixado.'; H = 'Erro de DLL gerenciada ausente'; F = 'ERRO' }
    "DEPLOYER_B64_NO_INTEROP"         = @{ T = 'NÃ£o foi possÃ­vel localizar ambas SQLite.Interop.dll (x86 e x64).'; H = 'Erro de DLLs interop ausentes'; F = 'ERRO' }
    "DEPLOYER_B64_DOWNLOADING_ARM64"  = @{ T = 'Tentando download do ARM64...'; H = 'Tentativa de download ARM64'; F = $null }
    "DEPLOYER_B64_ARM64_OK"           = @{ T = 'DLL nativa ARM64 obtida.'; H = 'Aviso de sucesso ARM64'; F = $null }
    "DEPLOYER_B64_ARM64_MISSING"      = @{ T = 'DLL ARM64 nÃ£o encontrada no pacote. Fallback serÃ¡ usado.'; H = 'Fallback por DLL ARM64 ausente'; F = $null }
    "DEPLOYER_B64_ARM64_FAIL"         = @{ T = 'Pacote ARM64 nÃ£o disponÃ­vel (ou falha no download). Fallback para x64 serÃ¡ usado.'; H = 'Fallback por falha ARM64'; F = $null }
    "DEPLOYER_B64_PLACEMENT_FAIL"     = @{ T = 'Falha ao colocar todas as DLLs necessÃ¡rias em {0}.'; H = 'Falha no posicionamento de DLLs com token de caminho'; F = 'ERRO' }
    "DEPLOYER_B64_NO_INTEROP_X64"     = @{ T = 'NÃ£o foi possÃ­vel localizar SQLite.Interop.dll no pacote x64.'; H = 'Interop x64 ausente'; F = 'ERRO' }
    "DEPLOYER_B64_NO_INTEROP_X86"     = @{ T = 'NÃ£o foi possÃ­vel localizar SQLite.Interop.dll no pacote x86.'; H = 'Interop x86 ausente'; F = 'ERRO' }
    "DEPLOYER_CORE_RESTORED"          = @{ T = 'DLL Gerenciada restaurada: {0}'; H = 'RestauraÃ§Ã£o de DLL gerenciada com token de caminho'; F = 'SQLITE' }
    "DEPLOYER_NATIVE_RESTORED"        = @{ T = 'DLL Interop Nativa restaurada: {0}'; H = 'RestauraÃ§Ã£o de DLL nativa com token de caminho'; F = 'SQLITE' }
    "DEPLOYER_VETOR_SELECT"           = @{ T = '[+] SELECIONE O VETOR DE IMPLANTAÃ‡ÃƒO:'; H = 'Prompt de seleÃ§Ã£o de vetor'; F = $null }
    "DEPLOYER_CORE_INJECT"            = @{ T = 'Injetando motor de persistÃªncia...'; H = 'Aviso de injeÃ§Ã£o de persistÃªncia'; F = 'DEPLOYER' }
    "DEPLOYER_CORE_FAIL"              = @{ T = 'Falha ao provisionar SQLite. O Maestro pode falhar no boot.'; H = 'Aviso de falha no provisionamento SQLite'; F = 'WARN' }
    "DEPLOYER_DEV_MODE_FAILSAFE"      = @{ T = 'BinÃ¡rios do Core travados. Falha segura de renomeaÃ§Ã£o aplicada para DEV_MODE.'; H = 'Aviso de failsafe modo dev'; F = 'WARN' }
    "DEPLOYER_LAUNCH_SCAPE"           = @{ T = 'INICIANDO MOTOR DE RECUPERAÃ‡ÃƒO SCAPE...'; H = 'Banner de lanÃ§amento do motor'; F = $null }
    "DEPLOYER_RETRY_REMOVE"           = @{ T = 'Falha ao remover Ã¡rvore anterior. Tentando novamente em 2 segundos...'; H = 'Aviso de retry de purga'; F = $null }
    "DEPLOYER_CANNOT_REMOVE"          = @{ T = 'NÃ£o foi possÃ­vel remover o diretÃ³rio {0}. Prosseguindo com criaÃ§Ã£o forÃ§ada...'; H = 'Falha na purga com token de caminho'; F = $null }
    "DEPLOYER_ICON_ANCHORED"          = @{ T = 'Ãcone ({0}) ancorado.'; H = 'Ã‚ncora de Ã­cone com token de nome'; F = $null }
    "DEPLOYER_DEV_COPY_CORE"          = @{ T = 'Pastas fÃ­sicas do Core copiadas para arquitetura DEV.'; H = 'ConfirmaÃ§Ã£o de cÃ³pia dev'; F = $null }
    "DEPLOYER_ERR_NO_PAYLOADS"        = @{ T = 'Nenhum payload mapeado na memÃ³ria.'; H = 'Erro de nenhum payload'; F = $null }
    "DEPLOYER_ERR_DLL_EXTRACT"        = @{ T = 'Falha interna na extraÃ§Ã£o das DLLs.'; H = 'Erro interno de extraÃ§Ã£o de DLLs'; F = $null }
    "DEPLOYER_ERR_WIX_DOWNLOAD"       = @{ T = 'Falha no download portÃ¡til do WiX: {0}'; H = 'Falha no download do WiX com token de erro'; F = $null }
    "DEPLOYER_ERR_PS2EXE"             = @{ T = 'Falha de compilaÃ§Ã£o durante a execuÃ§Ã£o do PS2EXE: {0}'; H = 'Falha do PS2EXE com token de erro'; F = $null }
    "DEPLOYER_ERR_WIX_INSTALL"        = @{ T = 'Falha ao instalar WiX Toolset ou caminho nÃ£o resolvido. Instale manualmente.'; H = 'OrientaÃ§Ã£o de instalaÃ§Ã£o do WiX'; F = $null }
    "DEPLOYER_ERR_CANDLE"             = @{ T = 'Pipeline de compilaÃ§Ã£o Candle falhou.'; H = 'Erro do pipeline Candle'; F = $null }
    "DEPLOYER_ERR_LIGHT"              = @{ T = 'Pipeline de linkediÃ§Ã£o Light falhou.'; H = 'Erro do pipeline Light'; F = $null }
    "DEPLOYER_ERR_MSI_FORGE"          = @{ T = 'Falha de compilaÃ§Ã£o durante a forja do MSI WiX: {0}'; H = 'Falha na forja MSI com token de erro'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # COMPILER SUBSYSTEM
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "COMPILER_MSI_BASE_EXE"           = @{ T = 'Forjando o executÃ¡vel base para o payload MSI...'; H = 'Prep do EXE Base'; F = 'COMPILADOR' }
    "COMPILER_MSI_SUCCESS"            = @{ T = 'Instalador MSI gerado com sucesso: {0}'; H = 'Sucesso na geraÃ§Ã£o do MSI'; F = 'COMPILADOR' }
    "COMPILER_CHECK_PS2EXE"           = @{ T = 'Verificando mÃ³dulo ps2exe...'; H = 'Aviso de verificaÃ§Ã£o ps2exe'; F = 'COMPILADOR' }
    "COMPILER_INSTALL_PS2EXE"         = @{ T = 'ps2exe ausente. Tentando auto-reparo (Install-Module/winget)...'; H = 'Tentativa de auto-reparo ps2exe'; F = 'COMPILADOR' }
    "COMPILER_INSTALL_WIX"            = @{ T = 'WiX ausente. Tentando auto-reparo (winget)...'; H = 'Tentativa de auto-reparo WiX'; F = 'COMPILADOR' }
    "COMPILER_EXE_SUCCESS"            = @{ T = 'ExecutÃ¡vel gerado com sucesso: {0}'; H = 'Sucesso na geraÃ§Ã£o de EXE com token de caminho'; F = 'COMPILADOR' }
    "COMPILER_WIX_NOT_FOUND"          = @{ T = 'WiX nÃ£o encontrado. Tentando instalaÃ§Ã£o via winget...'; H = 'WiX winget fallback'; F = 'COMPILADOR' }
    "COMPILER_WIX_FALLBACK"           = @{ T = 'Fallback do WiX Toolset falhou. Emitindo ZIP PortÃ¡til.'; H = 'WiX fallback to ZIP'; F = 'COMPILADOR' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # SYSTEM & DEPENDENCIES (ADIÃ‡Ã•ES)
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "DEP_SQLITE_DOWNLOADING"          = @{ T = 'Baixando carga do SQLite...'; H = 'InÃ­cio do download do SQLite em background'; F = 'SYSTEM' }
    "DEP_SQLITE_EXTRACTED"            = @{ T = 'Carga do SQLite extraÃ­da para o mÃ³dulo Environment com sucesso.'; H = 'Sucesso na extraÃ§Ã£o pÃ³s-download'; F = 'SYSTEM' }
    "DEP_BINARIES_MISSING"            = @{ T = '[SISTEMA] MÃ³dulo de binÃ¡rios nÃ£o carregado.'; H = 'Falha na inicializaÃ§Ã£o do mÃ³dulo'; F = 'ERRO' }
    "DB_OFFLINE"                      = @{ T = 'Banco de Dados Offline.'; H = 'Perda de conectividade com o banco'; F = 'AVISO' }
    "SYS_MEM_CRITICAL"                = @{ T = 'MemÃ³ria do host crÃ­tica (<20%). ForÃ§ando despejo de memÃ³ria do banco.'; H = 'Gatilho de seguranÃ§a por baixa memÃ³ria'; F = 'PERF_WARN' }
    "SYS_ACCESS_DENIED_DRIVE"         = @{ T = 'Acesso Negado. Bloqueio de hardware em {0}'; H = 'Falha de acesso Ã  unidade com token'; F = 'PRIV_FATAL' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # COMPILER & MSI (ADIÃ‡Ã•ES)
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "COMPILER_WIX_DOWNLOADING"        = @{ T = 'Baixando binÃ¡rios do WiX Toolset (Silencioso)...'; H = 'Download do WiX em background'; F = 'COMPILADOR' }
    "COMPILER_MSI_DOWNGRADE"          = @{ T = 'Uma versÃ£o mais recente do SCAPE jÃ¡ estÃ¡ instalada.'; H = 'Erro de downgrade do instalador MSI'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # NATIVE & KERNEL (ADIÃ‡Ã•ES)
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "NATIVE_LINUX_DIAG"               = @{ T = '[LINUX] Roteando para pipeline smartctl / fsck...'; H = 'Redirecionamento de diagnÃ³stico Linux'; F = 'HINT' }
    "NATIVE_LINUX_ISOLATE"            = @{ T = '[LINUX] Roteando para pipeline nativa umount / dd...'; H = 'Redirecionamento de isolamento Linux'; F = 'HINT' }
    "NATIVE_JOURNAL_EXPORTED"         = @{ T = 'Journal exportado para {0}. Processando entradas...'; H = 'Sucesso na extraÃ§Ã£o do USN Journal'; F = 'FSUTIL' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # BOOT & IGNITION SEQUENCE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "ERR_ADMIN_REQUIRED"              = @{ T = 'PrivilÃ©gios de Administrador sÃ£o estritamente necessÃ¡rios.'; H = 'Erro de requisito de admin'; F = $null }
    "ERR_BOOT_SECTOR_READ"            = @{ T = 'Falha na leitura do Boot Sector.'; H = 'Erro de leitura de boot sector'; F = 'IO_FATAL' }
    "ERR_SUPERBLOCK_READ"             = @{ T = 'Falha na leitura do Superblock EXT.'; H = 'Erro de leitura de superblock EXT'; F = 'IO_FATAL' }
    "BOOT_FATAL_MATRIX"               = @{ T = 'Falha ao carregar matriz fundacional: {0}'; H = 'Fatal ao carregar matriz com token de erro'; F = 'FATAL' }
    "BOOT_PRESS_ENTER_EXIT"           = @{ T = 'Pressione ENTER para sair...'; H = 'Prompt de saÃ­da'; F = $null }
    "BOOT_FATAL_INTEROP"              = @{ T = 'Falha ao carregar matriz fundacional Interop ou de Idioma.'; H = 'Fatal ao carregar matriz Interop/Language'; F = 'FATAL' }
    "PROMPT_EXE_NAME"                 = @{ T = 'Nome de saÃ­da do executÃ¡vel (padrÃ£o: SCAPE.exe)'; H = 'Prompt de nome de EXE'; F = $null }
    "IO_RESILIENT_MISSING"            = @{ T = 'MÃ³dulo de I/O resiliente ausente.'; H = 'Erro de mÃ³dulo I/O ausente'; F = $null }

    "SYS_BOOT_OK"                     = @{ T = 'Engine pronto. Idioma: {0} | Modo: {1}'; F = 'INFO' }
    "SYS_ASSET_WARN"                  = @{ T = '[{0}] Asset ''{1}'' ignorado ou falhou no carregamento.'; F = 'WARN' }

    "BOOT_INIT_MODULES"               = @{ T = 'Inicializando malha dinÃ¢mica de mÃ³dulos PowerShell na memÃ³ria...'; H = 'InÃ­cio de inicializaÃ§Ã£o de mÃ³dulos'; F = 'BOOT_SEQ' }
    "BOOT_MODULE_LOADED"              = @{ T = "  [+] NÃ³ do mÃ³dulo '{0}' carregado com sucesso no tempo de execuÃ§Ã£o."; H = 'Sucesso no carregamento de mÃ³dulo com token de nome'; F = $null }
    "BOOT_MODULE_FAIL"                = @{ T = "[BOOT_CRITICAL] Falha ao carregar o nÃ³ do mÃ³dulo '{0}': {1}"; H = 'Falha no carregamento de mÃ³dulo com tokens nome/erro'; F = $null }
    "BOOT_IMPORT_FATAL"               = @{ T = '[BOOT_FATAL] Falha irrecuperÃ¡vel na arquitetura de importaÃ§Ã£o de mÃ³dulo: {0}'; H = 'Fatal de arquitetura de importaÃ§Ã£o com token de erro'; F = $null }
    "BOOT_VERIFY_ENV"                 = @{ T = 'Verificando infraestrutura de hardware e executando rotinas de escalonamento de privilÃ©gio...'; H = 'InÃ­cio de verificaÃ§Ã£o de ambiente'; F = 'BOOT_SEQ' }
    "BOOT_PRIV_ELEVATED"              = @{ T = 'Acesso Concedido: SeBackupPrivilege & SeRestorePrivilege escalados com seguranÃ§a.'; H = 'Sucesso na elevaÃ§Ã£o de privilÃ©gios'; F = 'BOOT_SANCTUARY' }
    "BOOT_PRIV_FAIL"                  = @{ T = 'Falha no Escalonamento de PrivilÃ©gio. O acesso a estruturas brutas travadas serÃ¡ negado.'; H = 'Falha na elevaÃ§Ã£o de privilÃ©gios'; F = 'BOOT_SANCTUARY_ERR' }
    "BOOT_ENV_PARTIAL"                = @{ T = 'Subsistema central inicializado, mas encontrou erros parciais nÃ£o fatais.'; H = 'Aviso de inicializaÃ§Ã£o parcial'; F = 'BOOT_WARN' }
    "BOOT_SAMBA_AUTO"                 = @{ T = 'Cofre Samba autodetectado e engajado com seguranÃ§a no ponto de montagem local {0}'; H = 'Sucesso no auto-mount Samba com token de unidade'; F = 'BOOT_NETWORK' }
    "BOOT_SAMBA_FAIL"                 = @{ T = 'Protocolo de autotravamento Samba falhou em proteger a conexÃ£o: {0}'; H = 'Falha no auto-mount Samba com token de erro'; F = 'BOOT_NETWORK' }
    "BOOT_READY"                      = @{ T = 'Motor Central SCAPE Offline e desanexado do hardware com seguranÃ§a.'; H = 'Aviso de motor pronto/offline'; F = 'SYSTEM_STATE' }
    "BOOT_WELCOME"                    = @{ T = 'Bem-vindo ao SCAPE Recovery System - Motor Forense AvanÃ§ado v1.0'; H = 'Banner de boas-vindas'; F = $null }
    "BOOT_ESC_ABORT"                  = @{ T = 'Pressione [ENTER] para aceitar o risco, ou [ESC] para abortar o boot com seguranÃ§a.'; H = 'Prompt de aceitaÃ§Ã£o de risco no boot'; F = $null }

    "IGNITE_INIT"                     = @{ T = 'Iniciando SequÃªncia de Boot DinÃ¢mica (v1.0.0)...'; H = 'InÃ­cio da igniÃ§Ã£o'; F = 'SYSTEM' }
    "IGNITE_PILAR_LOAD"               = @{ T = 'Ativando Pilar Fundamental: {0}...'; H = 'AtivaÃ§Ã£o de pilar com token de nome'; F = 'SYSTEM' }
    "IGNITE_PILAR_FAIL"               = @{ T = 'Falha crÃ­tica ao despertar pilar {0}: {1}'; H = 'Falha de pilar com tokens nome/erro'; F = 'FATAL' }
    "IGNITE_PILAR_MISSING"            = @{ T = "Pilar obrigatÃ³rio '{0}' nÃ£o encontrado no dicionÃ¡rio de Payloads!"; H = 'Fatal de pilar ausente com token de nome'; F = 'FATAL' }
    "IGNITE_MATRIX_VALIDATION"        = @{ T = 'Validando Matriz de Payloads...'; H = 'InÃ­cio de validaÃ§Ã£o de matriz'; F = 'SYSTEM' }
    "IGNITE_MODULE_MAPPED"            = @{ T = '  [+] MÃ³dulo mapeado para Deploy: {0}'; H = 'MÃ³dulo mapeado com token de nome'; F = $null }
    "IGNITE_DEPLOYER_INJECT"          = @{ T = 'Injetando motor da FÃ¡brica...'; H = 'Aviso de injeÃ§Ã£o da fÃ¡brica'; F = 'SYSTEM' }
    "IGNITE_LOG_FAIL"                 = @{ T = 'Sistema de logs nÃ£o responde apÃ³s injeÃ§Ã£o.'; H = 'Falha de log pÃ³s-injeÃ§Ã£o'; F = $null }
    "IGNITE_DEPLOY_FAIL"              = @{ T = 'Falha ao iniciar Start-ScapeDeployment: {0}'; H = 'Falha no lanÃ§amento do deploy com token de erro'; F = 'FATAL' }
    "IGNITE_DEPLOYER_MISSING"         = @{ T = 'DeployerPayload (A FÃ¡brica) nÃ£o foi encontrado na memÃ³ria!'; H = 'Fatal de deployer ausente'; F = 'FATAL' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # DEPLOYER PROCESS MANAGEMENT
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "DEPLOYER_PROCESS_CLEANUP"        = @{ T = 'InstÃ¢ncias ativas detectadas. Encerrando processos para limpeza...'; H = 'InÃ­cio de cleanup de processos'; F = 'DEPLOYER' }
    "DEPLOYER_PURGE_SUCCESS"          = @{ T = 'Arquitetura anterior removida com sucesso.'; H = 'Aviso de sucesso na purga'; F = 'DEPLOYER' }
    "DEPLOYER_PURGE_BUSY_WARN"        = @{ T = 'DiretÃ³rio de saÃ­da estÃ¡ ocupado. Build antigo movido para caminho temporÃ¡rio: {0}'; H = 'Fallback de purga ocupada com token de caminho'; F = 'DEPLOYER' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # AUDIT & FORENSIC MANIFEST
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "AUDIT_MANIFEST_DEPLOY"           = @{ T = 'Manifesto Forense JSON implantado com seguranÃ§a em: {0} [Status: {1}]'; H = 'Deploy de manifesto com tokens caminho/status'; F = 'AUDIT_SYSTEM' }
    "AUDIT_MANIFEST_FAIL"             = @{ T = 'Falha crÃ­tica ao gravar dados de manifesto/checksum JSON: {0}'; H = 'Falha na gravaÃ§Ã£o de manifesto com token de erro'; F = 'AUDIT_FATAL' }
    "AUDIT_REPORT_GEN"                = @{ T = 'RelatÃ³rio de Auditoria JSON Abrangente gerado de forma limpa em: {0}'; H = 'Sucesso na geraÃ§Ã£o de relatÃ³rio com token de caminho'; F = 'AUDIT_SYSTEM' }
    "AUDIT_REPORT_FAIL"               = @{ T = 'Falha crÃ­tica ao compilar o relatÃ³rio de auditoria JSON final: {0}'; H = 'Falha na compilaÃ§Ã£o de relatÃ³rio com token de erro'; F = 'AUDIT_FATAL' }
    "AUDIT_INIT_OK"                   = @{ T = 'Ledger forense de auditoria inicializado com sucesso em: {0}'; H = 'Sucesso de inicializaÃ§Ã£o do mÃ³dulo de auditoria com token de caminho de log'; F = 'AUDIT_SYSTEM' }
    "AUDIT_INTEGRITY_VERIFIED"        = @{ T = 'VERIFIED_EXACT_MATCH'; H = 'Indicador de sucesso na verificaÃ§Ã£o de integridade'; F = $null }
    "AUDIT_INTEGRITY_MISMATCH"        = @{ T = 'CRITICAL_SIZE_MISMATCH'; H = 'Indicador de erro de mismatch de integridade'; F = $null }
    "AUDIT_HASH_COMPUTED"             = @{ T = 'Checksum CriptogrÃ¡fico SHA256: {0}'; H = 'ExibiÃ§Ã£o de hash com token de checksum'; F = 'AUDIT_HASH' }
    "COMPLIANCE_INIT_OK"              = @{ T = 'Motor de compliance online. Segmentos carregados: {0} | Algoritmo de hash: {1}.'; H = 'Sucesso de inicializaÃ§Ã£o de compliance com contagem de segmentos e algoritmo'; F = 'COMPLIANCE' }
    "COMPLIANCE_MISSING"              = @{ T = 'Segmento de compliance [{0}] ausente ({1}). Algoritmo: {2}.'; H = 'Aviso de segmento de compliance ausente com segmento/motivo/algoritmo'; F = 'COMPLIANCE_WARN' }
    "COMPLIANCE_MISMATCH"             = @{ T = 'Mismatch de integridade no segmento [{0}] | Esperado: {1} | Atual: {2} | Algoritmo: {3}.'; H = 'Mismatch de hash de compliance com detalhes do segmento e hash'; F = 'COMPLIANCE_ERR' }
    "IO_BIT_ERROR"                    = @{ T = 'OperaÃ§Ã£o bitwise resiliente de leitura/escrita falhou apÃ³s esgotar orÃ§amento de tentativas.'; H = 'Erro fatal de operaÃ§Ã£o bitwise/resiliÃªncia'; F = 'IO_FATAL' }
    "LOG_ROTATED"                     = @{ T = 'RotaÃ§Ã£o de log concluÃ­da. Arquivado: {0} | Ativo: {1} | RotaÃ§Ã£o: {2}.'; H = 'ConclusÃ£o de rotaÃ§Ã£o de logger com arquivo antigo/novo e contador'; F = 'LOGGER' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # ARCHIVE / CARVING ENGINE
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "ARCHIVE_ENUMERATING"             = @{ T = 'Enumerando nÃ³s de banco de dados para arquivos direcionados...'; H = 'InÃ­cio de enumeraÃ§Ã£o de archive'; F = 'ARCHIVE_ENGINE' }
    "ARCHIVE_BAR_TOTAL"               = @{ T = 'NÃ“S_DB_TOTAIS: {0} | MARCADOS_ATIVAMENTE: {1} | ERROS_CORRUPÃ‡ÃƒO: {2} | TAXA_SCAN: {3} nÃ³s/seg'; H = 'Barra de progresso de archive com tokens de estatÃ­sticas'; F = $null }
    "ARCHIVE_COMPLETE"                = @{ T = 'Ciclo de marcaÃ§Ã£o direcionada do banco de dados concluÃ­do inteiramente.'; H = 'ConclusÃ£o de ciclo de archive'; F = 'ARCHIVE_ENGINE' }
    "ARCHIVE_NO_FILES"                = @{ T = 'Nenhum arquivo correspondente aos critÃ©rios encontrado para processar na seleÃ§Ã£o atual.'; H = 'Aviso de nenhum arquivo encontrado'; F = 'ARCHIVE_WARN' }

    "CARVE_NTFS_SIG"                  = @{ T = "Estrutura de registro 'FILE' vÃ¡lida do NTFS identificada no offset fÃ­sico {0}"; H = 'Hit de assinatura NTFS com token de offset'; F = 'CARVE_HIT' }
    "CARVE_EXT4_SIG"                  = @{ T = 'MÃ¡gica de inode EXT4 vÃ¡lida (0xEF53/0xF30A) identificada no offset fÃ­sico {0}'; H = 'Hit de assinatura EXT4 com token de offset'; F = 'CARVE_HIT' }
    "CARVE_BTRFS_SIG"                 = @{ T = 'Estrutura node/leaf BTRFS vÃ¡lida identificada no offset fÃ­sico {0}'; H = 'Hit de assinatura BTRFS com token de offset'; F = 'CARVE_HIT' }
    "CARVE_ZFS_SIG"                   = @{ T = 'MÃ¡gica label/uberblock ZFS vÃ¡lida identificada no offset fÃ­sico {0}'; H = 'Hit de assinatura ZFS com token de offset'; F = 'CARVE_HIT' }
    "CARVE_RECORD_ADDED"              = @{ T = 'Registro Ã³rfÃ£o bruto bufferizado com seguranÃ§a para o motor de persistÃªncia SQL.'; H = 'Sucesso no buffer de registro'; F = 'CARVE_STATE' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # ERROR HANDLING & MISC
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "MANIFEST_NOT_FOUND"              = @{ T = 'NÃ³ do manifesto nÃ£o encontrado: {0}'; H = 'NÃ³ de manifesto ausente com token de chave'; F = 'ORCH_FATAL' }
    "ROUTER_FATAL"                    = @{ T = '{0}'; H = 'Fatal genÃ©rico de router com token de erro'; F = 'ROUTER_FATAL' }
    "ROUTE_EXEC_FAIL"                 = @{ T = '{0}'; H = 'Falha de execuÃ§Ã£o de rota com token de erro'; F = 'ROUTE_EXEC_FAIL' }
    "ORCH_MISSING_BINDING"            = @{ T = 'VÃ­nculo do Controlador Ausente: {0}'; H = 'VÃ­nculo ausente com token de chave'; F = 'ORCH_FATAL' }
    "CONFIRM_REGEX"                   = @{ T = '^[sS]'; H = 'PadrÃ£o regex para confirmaÃ§Ã£o em portuguÃªs'; F = $null }

    "ERR_DRIVE_SELECTION_NONE"        = @{ T = 'Nenhum alvo de armazenamento montado viÃ¡vel detectado pelo subsistema WMI.'; H = 'Erro de nenhum drive detectado'; F = 'INPUT_ERR' }
    "ERR_DRIVE_LETTERS_EXHAUSTED"     = @{ T = 'NO_AVAILABLE_DRIVE_LETTERS: O sistema operacional esgotou o pool de letras de unidade A-Z.'; H = 'Erro de letras de unidade esgotadas'; F = 'OS_LIMIT_ERR' }
    "ERR_PATH_INVALID"                = @{ T = 'Caminho de diretÃ³rio fornecido invÃ¡lido, malformado ou totalmente inacessÃ­vel.'; H = 'Erro de caminho invÃ¡lido'; F = 'PATH_ERR' }
    "ERR_NO_ITEMS_SELECTED"           = @{ T = 'Nenhum item lÃ³gico ou Ã¡rvores de diretÃ³rio selecionadas para a sequÃªncia de extraÃ§Ã£o.'; H = 'Erro de nenhuma seleÃ§Ã£o'; F = 'LOGIC_ERR' }
    "ERR_NO_STAGING"                  = @{ T = 'Pasta de staging local estritamente nÃ£o definida. VocÃª deve executar uma sequÃªncia de extraÃ§Ã£o primeiro.'; H = 'Erro de staging ausente'; F = 'LOGIC_ERR' }
    "ERR_DEPENDENCY_FAIL"             = @{ T = 'Falha permanente na resoluÃ§Ã£o de rede de dependÃªncia central apÃ³s {0} tentativas estritas.'; H = 'Falha na resoluÃ§Ã£o de dependÃªncia com token de contagem'; F = 'NET_FATAL' }
    "ERR_INTEGRITY_CHECK"             = @{ T = 'VerificaÃ§Ã£o de integridade de seguranÃ§a falhou gravemente. A dependÃªncia DLL baixada estÃ¡ ausente ou catastroficamente corrompida pÃ³s-extraÃ§Ã£o.'; H = 'Falha na verificaÃ§Ã£o de integridade'; F = 'BIN_FATAL' }
    "ERR_PERMISSION_DENIED"           = @{ T = 'Acesso negado forÃ§adamente pelo SO. VocÃª deve re-inicializar o terminal SCAPE como Administrador.'; H = 'Erro de permissÃ£o negada'; F = 'PRIV_FATAL' }
    "ERR_DISK_FULL"                   = @{ T = 'EspaÃ§o em disco fÃ­sico insuficiente detectado na mÃ­dia de destino. OperaÃ§Ã£o abortada com seguranÃ§a para prevenir crash.'; H = 'Erro de disco cheio'; F = 'IO_FATAL' }
    "ERR_CORRUPTED_RECORD"            = @{ T = 'Registro estrutural MFT/Inode severamente corrompido detectado. Pulando o parsing para prevenir falha do motor.'; H = 'Aviso de registro corrompido'; F = 'PARSE_WARN' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # MISCELLANEOUS & PROMPTS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "MISC_OR"                         = @{ T = ' ou '; H = 'Separador lÃ³gico OU'; F = $null }
    "MISC_PROGRESS"                   = @{ T = 'PROGRESSO_OPERACAO'; H = 'Indicador visual de atividade'; F = 'UI' }
    "MISC_PRESS_ENTER"                = @{ T = 'Pressione a tecla [ENTER] para retornar com seguranÃ§a ao menu principal do Maestro...'; H = 'Prompt de retorno'; F = $null }
    "MISC_PRESS_ENTER_CONTINUE"       = @{ T = 'Pressione a tecla [ENTER] para confirmar e continuar a operaÃ§Ã£o...'; H = 'Prompt de continuar'; F = $null }
    "MISC_PRESS_ENTER_TERMINAL"       = @{ T = 'Pressione a tecla [ENTER] para sair...'; H = 'Prompt de saÃ­da do terminal'; F = $null }
    "MISC_ABORT_PROMPT"               = @{ T = 'Pressione a tecla [ENTER] para abortar imediatamente a sequÃªncia atual...'; H = 'Prompt de abortar'; F = $null }
    "MISC_EXIT_CONFIRM"               = @{ T = 'PERIGO: VocÃª tem certeza de que deseja sair do SCAPE Engine? Fluxos nÃ£o salvos podem terminar. (s/N): '; H = 'Prompt de confirmaÃ§Ã£o de saÃ­da'; F = $null }
    "MISC_DOWNLOAD_RETRY"             = @{ T = 'ConexÃ£o de download caiu. Protocolo de repetiÃ§Ã£o acionado... ({0} tentativas seguras restantes)'; H = 'Retry de download com token de contagem'; F = 'NET_WARN' }
    "MISC_YES"                        = @{ T = 's'; H = 'Token de resposta sim'; F = $null }
    "MISC_NO"                         = @{ T = 'n'; H = 'Token de resposta nÃ£o'; F = $null }
    "MISC_YES_NO"                     = @{ T = '(s/N): '; H = 'Prompt sim/nÃ£o padrÃ£o minÃºsculo'; F = $null }
    "MISC_YES_NO_UPPER"               = @{ T = '(S/N): '; H = 'Prompt sim/nÃ£o maiÃºsculo'; F = $null }
    "MISC_OPERATION_SUCCESS"          = @{ T = 'A pipeline da operaÃ§Ã£o solicitada foi concluÃ­da com sucesso com zero erros fatais.'; H = 'Aviso de sucesso na operaÃ§Ã£o'; F = 'SYS_OK' }
    "MISC_OPERATION_FAILED"           = @{ T = 'A pipeline da operaÃ§Ã£o solicitada falhou. Por favor, revise os logs de exceÃ§Ã£o detalhados impressos acima.'; H = 'Aviso de falha na operaÃ§Ã£o'; F = 'SYS_FAIL' }
    "MISC_WAITING"                    = @{ T = 'O sistema estÃ¡ aguardando liberaÃ§Ã£o operacional...'; H = 'Status de espera'; F = $null }
    "MISC_CANCELLED"                  = @{ T = 'OperaÃ§Ã£o intencionalmente cancelada por substituiÃ§Ã£o do usuÃ¡rio.'; H = 'Aviso de cancelamento pelo usuÃ¡rio'; F = 'SYS_HALT' }
    "MISC_PRESS_ENTER_DEGRADED"       = @{ T = 'Pressione a tecla [ENTER] para logar a falha e tentar continuaÃ§Ã£o em modo de motor DEGRADADO...'; H = 'Prompt de modo degradado'; F = $null }
    "MISC_ENTER_PATH_MANUALLY"        = @{ T = 'Auto-picker falhou. Por favor, insira o caminho de destino absoluto manualmente (ex: D:\BackupSeguro): '; H = 'Prompt de fallback manual de caminho'; F = $null }
    "MISC_ACCEPT_RISK"                = @{ T = 'Pressione a tecla [ENTER] para aceitar oficialmente o risco operacional e prosseguir forÃ§adamente...'; H = 'Prompt de aceitaÃ§Ã£o de risco'; F = $null }
    "MISC_LOG_AND_CONTINUE"           = @{ T = 'Pressione a tecla [ENTER] para gravar a falha no log e continuar forÃ§adamente a compilaÃ§Ã£o...'; H = 'Prompt de log e continuaÃ§Ã£o'; F = $null }
    "MISC_PRESS_ENTER_EXIT"           = @{ T = 'Pressione a tecla [ENTER] para fechar o terminal e sair...'; H = 'Prompt de saÃ­da do terminal'; F = $null }
    "MISC_RESTART_STATE_MACHINE"      = @{ T = 'Pressione a tecla [ENTER] para reiniciar forÃ§adamente a MÃ¡quina de Estados Maestro...'; H = 'Prompt de reinÃ­cio da mÃ¡quina de estados'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # PERFORMANCE METRICS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "PERF_RAM_STRATEGY"               = @{ T = 'RAM validada disponÃ­vel: {0} GB | Tamanho Alvo Estimado: {1} GB -> EstratÃ©gia de AlocaÃ§Ã£o AtribuÃ­da: {2}'; H = 'EstratÃ©gia de RAM com tokens disponÃ­vel/alvo/estratÃ©gia'; F = 'PERF_METRIC' }
    "PERF_THREAD_AUTO"                = @{ T = 'Auto-ajustando threads de transferÃªncia de dados dinamicamente para {0} com base no meio de destino analisado.'; H = 'Auto-ajuste de threads com token de contagem'; F = 'PERF_TUNE' }
    "PERF_LOW_MEM_WARNING"            = @{ T = 'MemÃ³ria fÃ­sica extremamente baixa detectada no host. ForÃ§ando mudanÃ§a da pipeline para modo DISK_SPOOL para prevenir crash por falta de memÃ³ria.'; H = 'Aviso de memÃ³ria baixa'; F = 'PERF_WARN' }
    "PERF_HIGH_IO_WARNING"            = @{ T = 'Carga I/O excepcionalmente alta registrada na controladora de armazenamento. Protocolos de estrangulamento automatizados engajados.'; H = 'Aviso de carga I/O alta'; F = 'PERF_WARN' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # DEPENDENCY MANAGEMENT
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "DEP_ARM64_FALLBACK"              = @{ T = 'DLL nativa ARM64 ausente. Utilizando fallback x64 (emulaÃ§Ã£o).'; H = 'Aviso de fallback ARM64'; F = 'SQLITE' }
    "DEP_EXTRACT_SUCCESS"             = @{ T = 'DependÃªncias nativas extraÃ­das da matriz de memÃ³ria com sucesso.'; H = 'Sucesso na extraÃ§Ã£o de dependÃªncias'; F = 'SYSTEM' }
    "DEP_LOCAL_DETECTED"              = @{ T = 'DependÃªncias detectadas localmente (DEV_MODE).'; H = 'DependÃªncias locais detectadas'; F = 'SYSTEM' }
    "DEP_MISSING_ERROR"               = @{ T = 'ERRO: Arquivos nÃ£o encontrados no disco e nÃ£o embutidos na memÃ³ria.'; H = 'Erro de dependÃªncias ausentes'; F = 'SQLITE' }
    "DEP_SIZE_MISMATCH"               = @{ T = 'InconsistÃªncia no tamanho da DLL gerenciada apÃ³s extraÃ§Ã£o.'; H = 'Erro de mismatch de tamanho de DLL'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # CONFIGURATION VALUES
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "CONFIG_VAL_EFFICIENCY"           = @{ T = 'EFICIÃŠNCIA'; H = 'Modo do motor: EficiÃªncia'; F = $null }
    "CONFIG_VAL_REDUNDANCY"           = @{ T = 'REDUNDÃ‚NCIA'; H = 'Modo do motor: RedundÃ¢ncia'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # WAIT / RETURN PROMPTS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "WAIT_ENTER_CONTINUE"             = @{ T = 'Pressione ENTER para continuar...'; H = 'Prompt de espera para continuar'; F = $null }
    "WAIT_ENTER_ESC_PROMPT"           = @{ T = 'Pressione [ENTER] para prosseguir, ou [ESC] para cancelar.'; H = 'Prompt prosseguir/cancelar'; F = $null }
    "WAIT_ENTER_ACCEPT_RISK"          = @{ T = 'Pressione [ENTER] para aceitar o risco e continuar, ou [ESC] para abortar.'; H = 'Prompt aceitar risco/abortar'; F = $null }
    "WAIT_ENTER_RETURN"               = @{ T = 'Pressione ENTER para retornar...'; H = 'Prompt de espera para retornar'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # SYSTEM DETECTION
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "SYS_BARE_METAL"                  = @{ T = 'Bare Metal'; H = 'Indicador de host fÃ­sico'; F = $null }
    "SYS_NA"                          = @{ T = 'N/A'; H = 'Indicador nÃ£o aplicÃ¡vel'; F = $null }
    "SYS_VM_DETECTED"                 = @{ T = 'Maquina Virtual Detectada (Hypervisor: {0})'; H = 'DetecÃ§Ã£o de VM com token de hypervisor'; F = 'SYSTEM' }
    "SYS_HOST_DETECTED"               = @{ T = 'Host Fisico Detectado (Bare Metal)'; H = 'DetecÃ§Ã£o de bare metal'; F = 'SYSTEM' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # FORENSIC WALK / TRAVERSAL
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "FOR_MFT_WALK"                    = @{ T = 'Mapeando arvore MFT deterministicamente... Registro {0} / {1}'; H = 'Progresso de caminhada MFT com tokens atual/total'; F = $null }
    "FOR_EXT_WALK"                    = @{ T = 'Mapeando arvore Inode deterministicamente... Inode {0} / {1}'; H = 'Progresso de caminhada Inode com tokens atual/total'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # SAMBA / NETWORK MOUNT REMOVAL
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "SAMBA_UNMOUNT_ALL"               = @{ T = 'Removendo todas as unidades de rede...'; H = 'InÃ­cio de desmontagem em massa'; F = $null }
    "SAMBA_UNMOUNT_SINGLE"            = @{ T = 'Removendo unidade mapeada {0}...'; H = 'Desmontagem Ãºnica com token de unidade'; F = $null }
    "SAMBA_SELECT_IP"                 = @{ T = 'MÃšLTIPLOS HOSTS SMB DETECTADOS. SELECIONE O ALVO:'; H = 'SeleÃ§Ã£o de mÃºltiplos hosts'; F = $null }
    "SAMBA_MGR_TITLE"                 = @{ T = 'GERENCIAMENTO DE UNIDADES DE REDE'; H = 'TÃ­tulo do gerenciador de montagens'; F = $null }
    "SAMBA_MGR_REMOVE_ALL"            = @{ T = '[ DESMONTAR TODAS AS UNIDADES DE REDE ]'; H = 'OpÃ§Ã£o de menu remover todas'; F = $null }
    "SAMBA_MGR_NONE"                  = @{ T = 'Nenhuma unidade de rede ativa detectada.'; H = 'Aviso de nenhuma montagem'; F = $null }
    "SAMBA_MGR_REMOVED"               = @{ T = 'Unidade {0} ({1}) desmontada com sucesso.'; H = 'Sucesso na desmontagem com tokens unidade/caminho'; F = $null }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # NATIVE BRIDGE / SAFETY CONTROLS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "ERR_SYSTEM_DRIVE_LOCK"           = @{ T = 'OperaÃ§Ã£o bloqueada: ImpossÃ­vel isolar ou reparar o disco ativo do Sistema.'; H = 'Erro de proteÃ§Ã£o do disco do sistema'; F = 'ERRO_SEGURANÃ‡A' }
    "NET_NATIVE_ISOLATION_OK"         = @{ T = 'Drive isolado com sucesso. Acesso exclusivo DASD garantido.'; H = 'Sucesso no isolamento de disco'; F = 'DISKPART' }
    "NET_NATIVE_JOURNAL_START"        = @{ T = 'Colhendo USN Journal do NTFS para deleÃ§Ãµes recentes...'; H = 'InÃ­cio de colheita de journal'; F = 'FSUTIL' }
    "UI_NATIVE_HYBRID_RUNNING"        = @{ T = 'Scan dual SCAPE + WinFR em progresso. Aguarde...'; H = 'Scan hÃ­brido em progresso'; F = 'HÃBRIDO' }
    "UI_NATIVE_DIAG_FAIL"             = @{ T = 'O hardware reporta falhas crÃ­ticas. Recomenda-se I/O mÃ­nimo.'; H = 'Falha no diagnÃ³stico de hardware'; F = 'ALERTA_STORDIAG' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # THIRD_PARTY_TOOLS
    "TOOL_AUTOSPSY" = @{ T = "AUTOSPSY (Terceiros)"; H = "Executar a ferramenta forense AUTOSPSY"; F = "1" }
    "TOOL_VOLATILITY" = @{ T = "VOLATILITY (Terceiros)"; H = "Executar a ferramenta forense VOLATILITY"; F = "1" }
    "TOOL_FTKIMAGER" = @{ T = "FTKIMAGER (Terceiros)"; H = "Executar a ferramenta forense FTKIMAGER"; F = "1" }
    "TOOL_KAPE" = @{ T = "KAPE (Terceiros)"; H = "Executar a ferramenta forense KAPE"; F = "1" }
    "TOOL_TESTDISK" = @{ T = "TESTDISK (Terceiros)"; H = "Executar a ferramenta forense TESTDISK"; F = "1" }
    "TOOL_PHOTOREC" = @{ T = "PHOTOREC (Terceiros)"; H = "Executar a ferramenta forense PHOTOREC"; F = "1" }
    "TOOL_MAGNET" = @{ T = "MAGNET (Terceiros)"; H = "Executar a ferramenta forense MAGNET"; F = "1" }
    "TOOL_WIRESHARK" = @{ T = "WIRESHARK (Terceiros)"; H = "Executar a ferramenta forense WIRESHARK"; F = "1" }
    "TOOL_TCPDUMP" = @{ T = "TCPDUMP (Terceiros)"; H = "Executar a ferramenta forense TCPDUMP"; F = "1" }
    "TOOL_NMAP" = @{ T = "NMAP (Terceiros)"; H = "Executar a ferramenta forense NMAP"; F = "1" }
    "TOOL_SYSINTERNALS" = @{ T = "SYSINTERNALS (Terceiros)"; H = "Executar a ferramenta forense SYSINTERNALS"; F = "1" }
    "TOOL_REGCFG" = @{ T = "REGCFG (Terceiros)"; H = "Executar a ferramenta forense REGCFG"; F = "1" }
    "TOOL_MEMORYZE" = @{ T = "MEMORYZE (Terceiros)"; H = "Executar a ferramenta forense MEMORYZE"; F = "1" }
    "TOOL_REDLINE" = @{ T = "REDLINE (Terceiros)"; H = "Executar a ferramenta forense REDLINE"; F = "1" }
    "TOOL_PLASO" = @{ T = "PLASO (Terceiros)"; H = "Executar a ferramenta forense PLASO"; F = "1" }
    "TOOL_LOG2TIMELINE" = @{ T = "LOG2TIMELINE (Terceiros)"; H = "Executar a ferramenta forense LOG2TIMELINE"; F = "1" }
    "TOOL_XWAYS" = @{ T = "XWAYS (Terceiros)"; H = "Executar a ferramenta forense XWAYS"; F = "1" }
    "TOOL_SLEUTHKIT" = @{ T = "SLEUTHKIT (Terceiros)"; H = "Executar a ferramenta forense SLEUTHKIT"; F = "1" }
    "TOOL_DD" = @{ T = "DD (Terceiros)"; H = "Executar a ferramenta forense DD"; F = "1" }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "TOOL_DISKPART"                   = @{ T = 'DISKPART (Isolamento & Particionamento)'; H = 'ForÃ§ar offline ou gerenciar partiÃ§Ãµes'; F = '1' }
    "TOOL_DISKPART_DESC"              = @{ T = 'ForÃ§a o drive offline para evitar interferÃªncia do SO. AVISO: Desconecta todas as sessÃµes ativas.'; H = 'Dica de aviso DiskPart'; F = 'WARN' }
    "TOOL_CHKDSK"                     = @{ T = 'CHKDSK (Reparo de Sistema de Arquivos)'; H = 'Escanear e corrigir erros lÃ³gicos do sistema de arquivos'; F = '2' }
    "TOOL_CHKDSK_DESC"                = @{ T = 'Varredura profunda de estruturas de metadados. Pode iniciar operaÃ§Ãµes de disco demoradas.'; H = 'Dica ChkDsk'; F = 'LOG' }
    "TOOL_WINFR"                      = @{ T = 'WINFR (Microsoft File Recovery)'; H = 'Motor de recuperaÃ§Ã£o profunda baseado em assinatura'; F = '3' }
    "TOOL_WINFR_DESC"                 = @{ T = 'Utiliza algoritmos de recuperaÃ§Ã£o da Microsoft. Requer drive de destino para extraÃ§Ã£o segura.'; H = 'Dica WinFR'; F = 'LOG' }
    "TOOL_FSUTIL"                     = @{ T = 'FSUTIL (Coleta de USN Journal)'; H = 'Extrair logs de deleÃ§Ãµes recentes do NTFS'; F = '4' }
    "TOOL_FSUTIL_DESC"                = @{ T = 'Analisa o USN journal do NTFS para recuperar entradas de metadados de arquivos deletados recentemente.'; H = 'Dica Fsutil'; F = 'LOG' }
    "TOOL_STORDIAG"                   = @{ T = 'STORDIAG (DiagnÃ³stico de Hardware)'; H = 'Gerar relatÃ³rio abrangente de integridade de armazenamento'; F = '5' }
    "TOOL_STORDIAG_DESC"              = @{ T = 'Executa diagnÃ³sticos de armazenamento integrados. Gera relatÃ³rio detalhado de telemetria de hardware.'; H = 'Dica Stordiag'; F = 'LOG' }
    "TOOL_SFC"                        = @{ T = 'SFC (Verificador de Arquivos do Sistema)'; H = 'Verificar e restaurar arquivos corrompidos do Windows'; F = '6' }
    "TOOL_DISM"                       = @{ T = 'DISM (Gerenciamento de Imagem de ImplantaÃ§Ã£o)'; H = 'Reparar imagem e componentes do Windows'; F = '7' }
    "TOOL_EVENTVWR"                   = @{ T = 'EVENTVWR (Visualizador de Eventos)'; H = 'Acessar logs de eventos do sistema para forense'; F = '8' }
    "TOOL_FILEHASH"                   = @{ T = 'FILEHASH (GeraÃ§Ã£o de Checksum)'; H = 'Calcular hashes para integridade de arquivos'; F = '9' }
    "TOOL_NATIVE_FORENSICS"           = @{ T = 'FERRAMENTAS NATIVAS (Embutidas no Windows)'; H = 'Acessar ferramentas de sistema integradas'; F = 'N' }
    "TOOL_THIRDPARTY_FORENSICS"       = @{ T = 'FERRAMENTAS DE TERCEIROS (Sysinternals e Externas)'; H = 'Acessar utilitÃ¡rios forenses externos especializados'; F = 'T' }
    "TOOL_WINDIRSTAT"                 = @{ T = 'WINDIRSTAT (Uso de Disco e Limpeza)'; H = 'EstatÃ­sticas visuais de uso de disco e limpeza'; F = 'W' }
    "TOOL_PROCEXP"                    = @{ T = 'PROCESS EXPLORER (Sysinternals)'; H = 'Gerenciamento e rastreamento avanÃ§ado de processos'; F = 'P' }
    "TOOL_AUTORUNS"                   = @{ T = 'AUTORUNS (Sysinternals)'; H = 'Gerenciar programas e serviÃ§os de inicializaÃ§Ã£o automÃ¡tica'; F = 'A' }
    "TOOL_EVERYTHING"                 = @{ T = 'EVERYTHING (Voidtools)'; H = 'Mecanismo de busca instantÃ¢nea de arquivos e pastas'; F = 'E' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # LOGGING & TELEMETRY
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "LOG_INFO"                        = @{ T = 'INFO_MENSAGEM_OPERACIONAL'; H = 'Mensagem operacional padrÃ£o'; F = 'INFO' }
    "LOG_DEBUG"                       = @{ T = 'DEBUG_RASTRO_DIAGNOSTICO'; H = 'Rastro de diagnÃ³stico profundo'; F = 'DEBUG' }
    "LOG_WARN"                        = @{ T = 'AVISO_ANOMALIA_EXECUCAO'; H = 'Anomalia de execuÃ§Ã£o nÃ£o-fatal'; F = 'WARN' }
    "LOG_ERR"                         = @{ T = 'ERRO_FALHA_OPERACIONAL'; H = 'Falha em operaÃ§Ã£o especÃ­fica'; F = 'ERROR' }
    "LOG_FATAL"                       = @{ T = 'FATAL_PARADA_MOTOR'; H = 'InterrupÃ§Ã£o crÃ­tica do motor'; F = 'FATAL' }
    "LOG_SYSTEM"                      = @{ T = 'SISTEMA_MENSAGEM_NUCLEO'; H = 'Mensagem de nÃºcleo nÃ­vel kernel'; F = 'SYSTEM' }
    "LOG_METRIC"                      = @{ T = 'METRICA_TELEMETRIA_PERF'; H = 'Dados de telemetria de desempenho'; F = 'METRIC' }
    "LOG_TRACE"                       = @{ T = 'RASTRO_NIVEL_INSTRUCAO'; H = 'Rastreamento de nÃ­vel de instruÃ§Ã£o'; F = 'TRACE' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # FILE SYSTEMS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "FS_NTFS"                         = @{ T = 'SISTEMA_ARQUIVOS_NTFS'; H = 'Sistema de arquivos New Technology (NTFS)'; F = 'FS' }
    "FS_APFS"                         = @{ T = 'CONTEINER_APPLE_APFS'; H = 'Sistema de arquivos Apple (APFS)'; F = 'FS' }
    "FS_EXT4"                         = @{ T = 'LINUX_NATIVO_EXT4'; H = 'Sistema de arquivos Fourth Extended (EXT4)'; F = 'FS' }
    "FS_BTRFS"                        = @{ T = 'NODO_B_TREE_BTRFS'; H = 'Sistema de arquivos B-Tree (BTRFS)'; F = 'FS' }
    "FS_ZFS"                          = @{ T = 'POOL_ZETTABYTE_ZFS'; H = 'Sistema de arquivos Zettabyte (ZFS)'; F = 'FS' }
    "FS_REFS"                         = @{ T = 'RESILIENTE_REFS'; H = 'Sistema de arquivos resiliente (ReFS)'; F = 'FS' }
    "FS_XFS"                          = @{ T = 'EXTENDIDO_XFS'; H = 'Sistema de arquivos estendido (XFS)'; F = 'FS' }
    "FS_HFS"                          = @{ T = 'HIERARQUICO_HFS'; H = 'Sistema de arquivos hierÃ¡rquico (HFS)'; F = 'FS' }
    "FS_HFSX"                         = @{ T = 'HFSX_CASE_SENSITIVE'; H = 'HFS Plus (SensÃ­vel a maiÃºscu(exFAT)'; F = 'FS' }
    "FS_EXFAT"                        = @{ T = 'TABELA_FLASH_EXFAT'; H = 'Tabela de alocaÃ§Ã£o de arquivos estendida (exFAT)'; F = 'FS' }
    "FS_FAT32"                        = @{ T = 'LEGADO_FAT32'; H = 'Tabela de alocaÃ§Ã£o de arquivos legada (FAT32)'; F = 'FS' }
    "FS_UDF"                          = @{ T = 'FORMATO_UNIVERSAL_UDF'; H = 'Formato de disco universal (Ã“ptico)'; F = 'FS' }
    "FS_JFS"                          = @{ T = 'JOURNALED_JFS'; H = 'Sistema de arquivos Journaled (IBM)'; F = 'FS' }
    "FS_F2FS"                         = @{ T = 'F2FS_FLASH_NAND'; H = 'Sistema de arquivos flash NAND (F2FS)'; F = 'FS' }
    "FS_ISO9660"                      = @{ T = 'ISO9660_CD_ROM'; H = 'PadrÃ£o de sistema de arquivos de CD-ROM'; F = 'FS' }
    "FS_PART_TABLE"                   = @{ T = 'PARTITION_TABLE_STRUCT'; H = 'Estrutura de tabela de partiÃ§Ãµes'; F = 'META' }
    "FS_DISK_IMAGE"                   = @{ T = 'VIRTUAL_DISK_IMAGE'; H = 'Container de imagem de disco (VMDK/VHDX/DMG)'; F = 'VIRT' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # HARDWARE & TOPOLOGY
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "HW_CPU"                          = @{ T = 'UNIDADE_PROCESSAMENTO_CPU'; H = 'Unidade Central de Processamento'; F = 'HW' }
    "HW_RAM"                          = @{ T = 'MEMORIA_RAM_VOLATIL'; H = 'MemÃ³ria volÃ¡til do sistema'; F = 'HW' }
    "HW_HDD"                          = @{ T = 'DISCO_MECANICO_HDD'; H = 'Armazenamento mecÃ¢nico'; F = 'HW' }
    "HW_SSD"                          = @{ T = 'ESTADO_SOLIDO_SSD'; H = 'Armazenamento de estado sÃ³lido'; F = 'HW' }
    "HW_NVME"                         = @{ T = 'EXPRESSO_NVME'; H = 'Armazenamento expresso de alta velocidade'; F = 'HW' }
    "HW_USB"                          = @{ T = 'DISCO_EXTERNO_USB'; H = 'Armazenamento USB (Universal Serial Bus)'; F = 'HW' }
    "HW_GPU"                          = @{ T = 'UNIDADE_GRAFICA_GPU'; H = 'Unidade de Processamento GrÃ¡fico'; F = 'HW' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # STATUS & ENGINE STATES
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "STATUS_SUCCESS"                  = @{ T = 'SUCESSO_OPERACAO'; H = 'OperaÃ§Ã£o concluÃ­da sem erros'; F = 'OK' }
    "STATUS_UNKNOWN"                  = @{ T = 'ESTADO_DESCONHECIDO'; H = 'Objeto ou estado nÃ£o identificado'; F = 'WARN' }
    "STATUS_BUSY"                     = @{ T = 'PROCESSAMENTO_ATIVO'; H = 'Fluxo de E/S ativamente engajado'; F = 'PROC' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # METADATA LABELS
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "META_ACCESSED"                   = @{ T = 'TIMESTAMP_ACESSO'; H = 'Timestamp de Ãºltimo acesso'; F = 'META' }
    "META_CREATED"                    = @{ T = 'TIMESTAMP_CRIACAO'; H = 'Timestamp de criaÃ§Ã£o'; F = 'META' }
    "META_MODIFIED"                   = @{ T = 'TIMESTAMP_MODIFICACAO'; H = 'Timestamp de Ãºltima modificaÃ§Ã£o'; F = 'META' }
    "META_MFT_CHANGED"                = @{ T = 'REGISTRO_MFT_ALTERADO'; H = 'Timestamp de alteraÃ§Ã£o de registro MFT'; F = 'META' }
    "META_FILENAME"                   = @{ T = 'NOME_ARQUIVO_FISICO'; H = 'Nome no meio de armazenamento'; F = 'META' }
    "META_PID"                        = @{ T = 'ID_PROCESSO'; H = 'Identificador de Processo do Sistema'; F = 'SYS' }
    "META_OFFSET"                     = @{ T = 'OFFSET_FISICO'; H = 'Offset de bytes brutos no disco'; F = 'DASD' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # DOMAINS & MODULES
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "DOMAIN_ANALYSIS"                 = @{ T = 'SUBSISTEMA_ANALISE'; H = 'Motor de anÃ¡lise central'; F = 'SYS' }
    "DOMAIN_PARSING"                  = @{ T = 'PARSING_METADADOS'; H = 'Processamento determinÃ­stico de registros'; F = 'SYS' }
    "DOMAIN_ARCHAEOLOGY"              = @{ T = 'MODO_ARQUEOLOGIA'; H = 'Carving profundo de setores brutos'; F = 'SYS' }
    "DOMAIN_HARVESTER"                = @{ T = 'MOTOR_HARVESTER'; H = 'Motor de extraÃ§Ã£o em lote'; F = 'SYS' }
    "DOMAIN_INFRA"                    = @{ T = 'CAMADA_INFRAESTRUTURA'; H = 'Camada de suporte do sistema'; F = 'SYS' }

    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # ALTERNATIVAS DE CAPACIDADE DO TERMINAL
    # â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    "CAP_MENU_TITLE"                  = @{ T = 'CONFIGURAÃ‡Ã•ES DE CAPACIDADE DO TERMINAL'; H = 'TÃ­tulo do menu de capacidades do terminal'; F = 'UI' }
    "CAP_TRUECOLOR"                   = @{ T = 'TrueColor (RGB de 24 bits)'; H = 'Ativa suporte a cores reais de 24 bits. Desative para reverter Ã  paleta ANSI de 16 cores.'; F = 'UI' }
    "CAP_HYPERLINKS"                  = @{ T = 'Hiperlinks (OSC 8)'; H = 'Ativa links clicÃ¡veis no terminal. Requer um emulador de terminal moderno.'; F = 'UI' }
    "CAP_BRACKETEDPASTE"              = @{ T = 'Modo de Colagem com Colchetes'; H = 'Distingue texto colado de entrada digitada. Previne a execuÃ§Ã£o acidental.'; F = 'UI' }
    "CAP_MOUSETRACKING"               = @{ T = 'Rastreamento de Mouse'; H = 'Ativa eventos de clique e movimento do mouse para interaÃ§Ã£o com a UI.'; F = 'UI' }
    "CAP_ALTERNATESCREEN"             = @{ T = 'Buffer de Tela Alternativo'; H = 'Usa um buffer de tela separado para TUIs em tela cheia. Preserva o histÃ³rico do shell.'; F = 'UI' }
    "CAP_FOCUSEVENTS"                 = @{ T = 'Eventos de Foco (In/Out)'; H = 'Detecta quando o terminal ganha ou perde o foco.'; F = 'UI' }
    "CAP_KITTYKEYBOARD"               = @{ T = 'Protocolo de Teclado Kitty'; H = 'Protocolo de teclado aprimorado para combinaÃ§Ãµes de teclas avanÃ§adas. Experimental.'; F = 'UI' }
    "CAP_SIXELGRAPHICS"               = @{ T = 'GrÃ¡ficos Sixel'; H = 'Exibe grÃ¡ficos de bitmap inline. Requer um terminal compatÃ­vel com Sixel.'; F = 'UI' }
    "CAP_CSIUKEYBOARD"                = @{ T = 'Protocolo de Teclado CSIu'; H = 'Protocolo moderno de entrada de teclado para melhor tratamento de teclas modificadoras.'; F = 'UI' }
    "CAP_FALLBACK256"                 = @{ T = 'Permitir fallback de 256 cores'; H = 'Usa a paleta de 256 cores quando TrueColor nÃ£o estiver disponÃ­vel.'; F = 'UI' }
    "CAP_FALLBACK16"                  = @{ T = 'Permitir fallback de 16 cores'; H = 'Usa a paleta ANSI de 16 cores quando a de 256 cores nÃ£o estiver disponÃ­vel.'; F = 'UI' }

    "MENU_MAIN_RECOVERY"              = @{ T = 'MOTOR DE RECUPERAÃ‡ÃƒO'; H = 'Painel de fluxo de recuperaÃ§Ã£o completo do SCAPE.'; F = '6' }
    "MENU_RECOVERY_TITLE"             = @{ T = 'MOTOR DE RECUPERAÃ‡ÃƒO DO SISTEMA & FORENSE'; H = 'TÃ­tulo para o menu de recuperaÃ§Ã£o'; F = 'UI' }
    "RC_BITWISE_TAGGING"              = @{ T = 'MARCAÃ‡ÃƒO BITWISE'; H = 'Menu de operaÃ§Ãµes bitwise'; F = 'A' }
    "RC_TOPOLOGY_SCAN"                = @{ T = 'VARREDURA DE TOPOLOGIA'; H = 'Escanear topologia'; F = 'T' }
    "RC_BATCH_PROCESSING"             = @{ T = 'PROCESSAMENTO EM LOTE'; H = 'OperaÃ§Ãµes em lote'; F = 'B' }
    "RC_TARGET_ARCHAEOLOGY"           = @{ T = 'ARQUEOLOGIA DE ALVO'; H = 'RecuperaÃ§Ã£o profunda'; F = 'R' }
    "RC_FILE_LABORATORY"              = @{ T = 'LABORATÃ“RIO DE ARQUIVOS'; H = 'AnÃ¡lise de arquivos'; F = 'L' }
    "RC_FORENSIC_TOOLS"               = @{ T = 'FERRAMENTAS FORENSES'; H = 'Menu de ferramentas forenses'; F = 'F' }
    "RC_ROBOCOPY_ENGINE"              = @{ T = 'MOTOR ROBOCOPY'; H = 'Menu do motor robocopy'; F = 'E' }
    "RC_TELEMETRY_SCAN"               = @{ T = 'VARREDURA DE TELEMETRIA'; H = 'Varredura de telemetria de hardware'; F = 'S' }
    "RC_CLOUD_SYNC"                   = @{ T = 'CLOUD SYNC'; H = 'Subsistema de sincronizaÃ§Ã£o em nuvem'; F = '7' }

    # --- ORCHESTRATION & ACTIONS ---
    CORE_ACTION_TARGET_MODULE = "Módulo Alvo"
    CORE_ACTION_ACTIVE_TASK = "Tarefa Ativa"
    CORE_ACTION_STATUS = "Status"
    CORE_ACTION_SYSTEM_TASK = "Tarefa de Sistema"
    CORE_ACTION_DEFAULT = "Padrão"
    CORE_ACTION_INITIALIZING = "INICIALIZANDO..."
    CORE_ACTION_COMPLETED = "CONCLUÍDO - PRESSIONE QUALQUER TECLA"
    CORE_ACTION_FAILED = "FALHA"

    KEYBINDINGS_INIT = "INICIALIZANDO GERENCIADOR DE ATALHOS..."
    KEYBINDINGS_NO_MODULE = "MÓDULO DE ATALHOS NÃO CARREGADO"
    KEYBINDINGS_MODE = "Modo"
    KEYBINDINGS_INTERACTIVE = "REMAPEAMENTO INTERATIVO"
    KEYBINDINGS_STATUS = "Status"
    KEYBINDINGS_PRESS_KEY = "PRESSIONE UMA TECLA PARA REMAPEAR"
    KEYBINDINGS_ACTION = "Ação"
    KEYBINDINGS_READY = "ATALHOS PRONTOS"
    KEYBINDINGS_PROF_LOADED = "PERFIL {0} CARREGADO"
    KEYBINDINGS_NO_PROFILE = "NENHUM PERFIL ESPECIFICADO"
    KEYBINDINGS_SAVED = "ATALHOS SALVOS"
    KEYBINDINGS_FAILED = "FALHA AO SALVAR ATALHOS"
    KEYBINDINGS_SYS_READY = "SISTEMA DE ATALHOS PRONTO"

    FILEPICKER_INIT = "Inicializando sandbox de seleção de diretório..."
    FILEPICKER_DIALOG = "SCAPE STAGING: Selecione Sandbox de Destino"
    FILEPICKER_COM_FAIL = "Interface COM falhou. Engajando prompt manual de CLI."
    FILEPICKER_CANCEL = "Operação cancelada pelo operador."
    FILEPICKER_INVALID = "Não foi possível criar o caminho de staging: {0}"
    FILEPICKER_LOCKED = "Staging travado em: {0}"

    ACTION_TOOL_LAUNCH = "LANÇANDO {0}..."
    ACTION_TOOL_SUCCESS = "{0} executado com sucesso."
    ACTION_TOOL_FAIL = "Falha ao lançar {0}"
    ACTION_TOOL_COMPLETE = "AUDITORIA {0} CONCLUÍDA"
    ACTION_TOOL_PACKAGER = "INVOCANDO EMPACOTADOR PARA {0}..."
    ACTION_PACKAGER_SUCCESS = "{0} implantado com sucesso! Execute novamente para lançar."
    ACTION_PACKAGER_FAIL = "Configuração falhou ou requer licença manual"
    ACTION_TOOL_MISSING = "{0} ({1}) não está instalado neste sistema."
    ACTION_TOOL_MISSING_HINT = "Use o empacotador embutido ou instale manualmente."
    TOOL_ERROR_LBL = "Erro"
    ACTION_FILEHASH_WARN = "Por favor, especifique um caminho de arquivo para o hash. Este módulo requer argumentos de CLI ou integração com FilePicker."

    CORE_INTEROP_FAIL = "Core.Interop não disponível"
    ROBOCOPY_PREPARING = "PREPARANDO CONFIGURAÇÃO ROBOCOPY..."
    ROBOCOPY_READY = "CONFIGURAÇÃO ROBOCOPY PRONTA"
    ACTION_RESOLVING_VAULT = "RESOLVENDO ENDPOINT DO CLOUD VAULT..."
    ACTION_AUTH_KEYS = "AUTENTICANDO CHAVES SHA256..."
    CORE_NOT_IMPLEMENTED = "Não Implementado"
    NET_NO_FREE_DRIVES = "Nenhuma letra de unidade livre disponível."
    NET_UNMOUNT_FAIL = "Falha ao limpar montagens de rede."
    AUDIT_EXPORTING = "EXPORTANDO LEDGER DE AUDITORIA..."
    AUDIT_EXPORT_SUCCESS = "LEDGER DE AUDITORIA EXPORTADO COM SUCESSO"
    AUDIT_EXPORT_FAILED = "FALHA AO EXPORTAR LEDGER DE AUDITORIA"
    AUDIT_MODULE_NOT_LOADED = "MÓDULO DE AUDITORIA NÃO CARREGADO"

    COMPLIANCE_GENERATING = "GERANDO RELATÓRIO DE CONFORMIDADE..."
    COMPLIANCE_GENERATED = "RELATÓRIO DE CONFORMIDADE GERADO"
    COMPLIANCE_FAILED = "FALHA AO GERAR RELATÓRIO DE CONFORMIDADE"
    COMPLIANCE_NO_MODULE = "MÓDULO DE CONFORMIDADE NÃO CARREGADO"

    PIPELINE_INIT = "INICIALIZANDO PIPELINE DE MEMÓRIA..."
    PIPELINE_ACTIVE = "BUFFER DE PIPELINE ATIVO"
    PIPELINE_NO_MODULE = "MÓDULO DE PIPELINE NÃO CARREGADO"
}
