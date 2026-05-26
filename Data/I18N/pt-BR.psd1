@{
    # ─────────────────────────────────────────────────────────────────────
    # CORE ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "CORE_ENGINE_START"               = @{ T = 'Sequência de Boot do Motor SCAPE Iniciada. Alocando recursos do núcleo...'; H = 'Mensagem de inicialização do motor'; F = 'SYSTEM' }
    "CORE_ENGINE_STOP"                = @{ T = 'Motor SCAPE Offline. Sequência de encerramento e expurgo de memória concluídos.'; H = 'Confirmação de desligamento do motor'; F = 'SYSTEM' }
    "CORE_KERNEL_SHIELD_ACTIVE"       = @{ T = 'SHIELD_ESTÁVEL: NT_IO_PRIORITY_HIGH acoplado. Threads de execução elevadas.'; H = 'Sucesso na elevação de prioridade do kernel'; F = 'KERNEL' }
    "CORE_KERNEL_SHIELD_FAIL"         = @{ T = 'FALHA_NO_SHIELD: Incapaz de elevar a prioridade do processo. {0}'; H = 'Falha na elevação de prioridade com token de erro'; F = 'KERNEL_ERR' }
    "CORE_VALEDICTORY_CLEANUP"        = @{ T = 'Executando Limpeza de Despedida: Liberando handles e esvaziando buffers...'; H = 'Fase de limpeza de encerramento gracioso'; F = 'KERNEL' }
    "CORE_VALEDICTORY_DONE"           = @{ T = 'Limpeza de despedida concluída. Processos do motor suspensos com segurança.'; H = 'Confirmação de conclusão da limpeza'; F = 'SYSTEM' }
    "CORE_VALEDICTORY_ERROR"          = @{ T = 'Falha crítica durante a fase de limpeza de despedida: {0}'; H = 'Erro na fase de limpeza com token'; F = 'ERR' }
    "CORE_ADMIN_REQUIRED"             = @{ T = 'Privilégios de Administrador são estritamente necessários para acesso bruto DASD. Reinicie o processo do host com direitos elevados.'; H = 'Requisito de elevação para acesso DASD'; F = 'PRIVILEGE_FATAL' }
    "CORE_BACKUP_PRIV_GRANTED"        = @{ T = 'Escalação de Privilégios Bem-sucedida: SeBackupPrivilege e SeRestorePrivilege estão ativos.'; H = 'Privilégios de backup elevados com sucesso'; F = 'SANCTUARY' }
    "CORE_BACKUP_PRIV_MISSING"        = @{ T = 'Privilégios de backup não habilitados totalmente. Capacidades de bypass de ACL do NTFS podem ser severamente restritas durante a extração.'; H = 'Aviso de escalação parcial de privilégios'; F = 'SANCTUARY_WARN' }
    "CORE_PRESERVATION_ACTIVE"        = @{ T = 'MODO DE PRESERVAÇÃO ATIVO - RESFRIANDO'; H = 'Indicador de status do modo de preservação'; F = 'STATUS' }

    # ─────────────────────────────────────────────────────────────────────
    # SETTINGS ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "SETTINGS_ENGINE_ONLINE"          = @{ T = 'Motor de configurações online. Sincronizando overrides...'; H = 'Mensagem de inicialização do engine'; F = 'SYSTEM' }
    "SETTINGS_MUTATE_UNKNOWN"         = @{ T = 'Tentativa de alteração em chave desconhecida: {0}'; H = 'Erro de mutação para chave inexistente'; F = 'WARN' }
    "SETTINGS_IO_FAULT"               = @{ T = 'Falha de E/S: Chave {0} aplicada na RAM, mas não persistida no disco.'; H = 'Falha de persistência no arquivo JSON'; F = 'ERROR' }
    "SETTINGS_MUTATE_SUCCESS"         = @{ T = 'Configuração [{0}] alterada com sucesso para [{1}].'; H = 'Notificação de sucesso de mutação'; F = 'SYSTEM' }
    "SETTINGS_RESET_DEFAULTS"         = @{ T = 'Redefinir para Padrões de Fábrica'; H = 'Opção para redefinir todas as configurações para os padrões de fábrica'; F = 'UI' }
    "SETTINGS_RESET_SUCCESS"          = @{ T = 'Todas as configurações restauradas para o padrão de fábrica (.psd1).'; H = 'Confirmação de redefinição de fábrica'; F = 'SYSTEM' }

    # ─────────────────────────────────────────────────────────────────────
    # MAIN MENU
    # ─────────────────────────────────────────────────────────────────────
    "MENU_MAIN_TITLE"                 = @{ T = 'CONFIGURAÇÕES DO SISTEMA E DEFINIÇÕES DE AMBIENTE'; H = 'Título do menu principal'; F = $null }
    "MENU_MAIN_SCAN"                  = @{ T = 'SCAN COMPLETO & TOPOLOGIA DE INVENTÁRIO'; H = 'Auditoria de hardware e inventário de topologia de disco.'; F = '1' }
    "MENU_MAIN_PARSING"               = @{ T = 'RECUPERAÇÃO TARGETADA (Plano A - MFT/Inode)'; H = 'Recuperação determinística de registros MFT/Inode.'; F = '2' }
    "MENU_MAIN_ARCHAEOLOGY"           = @{ T = 'MODO ARQUEOLOGIA (Plano B - Extração Bruta)'; H = 'Escavação profunda de assinaturas hexadecimais.'; F = '3' }
    "MENU_MAIN_HARVESTER"             = @{ T = 'EXTRAÇÃO EM MASSA HARVESTER'; H = 'Extração em lote de arquivos descobertos.'; F = '4' }
    "MENU_MAIN_FORENSICS"             = @{ T = 'DIAGNÓSTICO FORENSE & FERRAMENTAS CLI'; H = 'Acessar utilitários nativos de CLI forense'; F = '5' }
    "MENU_MAIN_SETTINGS"              = @{ T = 'CONFIGURAÇÕES DO SISTEMA E AMBIENTE'; H = 'Ajustar parâmetros do motor e da interface.'; F = '6' }
    "MENU_MAIN_LOGISTICS"             = @{ T = 'LOGÍSTICA & CLOUD SYNC'; H = 'Motor de sincronização em nuvem Robocopy.'; F = '7' }
    "MENU_MAIN_LAB"                   = @{ T = 'SCAPE LABORATORY (Reparo de Arquivos)'; H = 'Reparo de magic bytes e cirurgia de blocos.'; F = '8' }
    "MENU_MAIN_EXIT"                  = @{ T = 'ENCERRAR MOTOR SCAPE'; H = 'Fechar Scape Engine'; F = 'Q' }

    "MENU_OPTION_ENGINE_MODE"         = @{ T = 'MODO DO MOTOR (Eficiência vs Redundância)'; H = 'Alterna o modo entre EFICIÊNCIA (Rápido/Estrito) e REDUNDÂNCIA (Profundo/Fallback).'; F = '1' }
    "MENU_OPTION_DEFAULT_OUT"         = @{ T = 'DIRETÓRIO DE SAÍDA PADRÃO'; H = 'Define o diretório físico global para o armazenamento (staging) das extrações.'; F = '2' }
    "MENU_OPTION_NETWORK_MGR"         = @{ T = 'CONFIGURAÇÕES DE REDE'; H = 'Gerenciar montagens de rede SMB/CIFS e credenciais ativas.'; F = '3' }
    "MENU_OPTION_ROBOCOPY"            = @{ T = 'CONFIGURAÇÕES GLOBAIS DO ROBOCOPY (SYNC)'; H = 'Flags avançadas de sincronização para o motor de Nuvem Robocopy.'; F = '4' }
    "MENU_OPTION_LANGUAGE"            = @{ T = 'IDIOMA DA INTERFACE'; H = 'Altera o idioma global da interface do SCAPE.'; F = '5' }
    "MENU_SETTINGS_THEME"             = @{ T = 'OPÇÕES DE TEMA'; H = 'Configurar o tema visual da interface.'; F = '6' }
    "MENU_OPTION_RETURN"              = @{ T = 'RETORNAR AO MENU ANTERIOR'; H = 'Retornar ao nível anterior do menu'; F = 'R' }
    "MENU_OPTION_AUTODETECT"          = @{ T = 'AUTO-DETECTAR & MONTAR COFRE SAMBA'; H = 'Auto-descobrir e montar compartilhamentos Samba em rede'; F = 'S' }

    "MENU_MAESTRO_PROMPT"             = @{ T = 'Aguardando diretiva de comando operacional'; H = 'Prompt de status da rotina Maestro'; F = 'MAESTRO_ROUTINE' }
    "MENU_INPUT_PROMPT"               = @{ T = 'ENTRADA'; H = 'Rótulo do campo de entrada'; F = $null }
    "MENU_VALUE_NOT_SET"              = @{ T = 'NÃO CONFIGURADO'; H = 'Indicador de configuração não definida'; F = $null }
    "MENU_VALUE_ENABLED"              = @{ T = 'ATIVADO ACTIVE'; H = 'Indicador de recurso habilitado'; F = $null }
    "MENU_VALUE_DISABLED"             = @{ T = 'DESATIVADO INACTIVE'; H = 'Indicador de recurso desabilitado'; F = $null }
    "MENU_CHOICE_INVALID"             = @{ T = 'Parâmetro de comando não reconhecido. Por favor, forneça um índice válido.'; H = 'Erro de seleção inválida no menu'; F = 'INPUT_ERR' }
    "MENU_LANGUAGE_SWITCH"            = @{ T = 'Dicionário de idioma global alterado para {0}. Componentes de interface atualizados.'; H = 'Confirmação de troca de idioma com token de localidade'; F = 'UI' }
    "MENU_OPTION_ICON_LEVEL"          = @{ T = 'NÍVEL ÍCONE (Gráfico/Unicode/ASCII)'; H = 'Alternar entre ícones gráficos, Unicode sólido ou ASCII'; F = '1' }
    "MENU_OPTION_FRAME_STYLE"         = @{ T = 'ESTILO MOLDURA (Estilo de bordas)'; H = 'Alterar o estilo de borda dos menus'; F = '2' }
    "MENU_OPTION_PROGRESS_STYLE"      = @{ T = 'ESTILO PROGRESSO (Barra/Spinner)'; H = 'Selecionar estilo de barra de progresso ou spinner'; F = '3' }
    "MENU_OPTION_THEME_PERSONA"       = @{ T = 'PERSONA TEMA (Paleta de cores)'; H = 'Aplicar uma paleta de cores completa'; F = '4' }
    "MENU_OPTION_COLOR_MODE"          = @{ T = 'MODO COR (TrueColor/ANSI16)'; H = 'Alternar entre TrueColor de 24 bits e fallback de 16 cores ANSI'; F = '5' }
    "MENU_RANDOM_THEME"               = @{ T = 'NOVO TEMA RANDÔMICO (RGB DINÂMICO)'; H = 'Aplica uma nova paleta de cores gerada algoritmicamente garantindo acessibilidade visual.'; F = '6' }
    "THEME_APPLIED"                   = @{ T = 'Tema Quântico de UI aplicado com sucesso. RGB Base: {0}'; H = 'Sucesso na aplicação de tema com token RGB'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # DRIVE ACTIONS MENU
    # ─────────────────────────────────────────────────────────────────────
    "MENU_DRIVE_TARGET_LABEL"         = @{ T = '>> ALVO SELECIONADO: {0}'; H = 'Rótulo do drive selecionado com token de dispositivo'; F = $null }
    "MENU_DRIVE_OPT_TARGETED"         = @{ T = 'Recuperação Direcionada (SCAPE Plano A)'; H = 'Extrai caminhos específicos ignorando APIs do Windows.'; F = '1' }
    "MENU_DRIVE_OPT_ARCHAEOLOGY"      = @{ T = 'Modo Arqueologia (SCAPE Plano B)'; H = 'Escavação profunda de setores RAW por assinaturas perdidas.'; F = '2' }
    "MENU_DRIVE_OPT_ISOLATE"          = @{ T = 'Isolar Unidade (Diskpart - Modo Offline)'; H = 'Força estado offline para prevenir interferência do SO.'; F = '3' }
    "MENU_DRIVE_OPT_JOURNAL"          = @{ T = 'Colher Journal (Fsutil - Deleções Recentes)'; H = 'Extrai deleções recentes via USN Journal.'; F = '4' }
    "MENU_DRIVE_OPT_HYBRID"           = @{ T = 'Recuperação Híbrida (WinFR + SCAPE)'; H = 'Scan de motor duplo alavancando Windows File Recovery.'; F = '5' }
    "MENU_DRIVE_OPT_RETURN"           = @{ T = 'Retornar'; H = 'Retornar ao menu anterior.'; F = 'R' }

    # ─────────────────────────────────────────────────────────────────────
    # PIPELINE / COMPLIANCE
    # ─────────────────────────────────────────────────────────────────────
    "TUI_PREFLIGHT"                   = @{ T = 'Iniciando sequência de diagnóstico {0}...'; H = 'Início de diagnóstico pré-voo com token de ferramenta'; F = 'PRE-FLIGHT' }
    "TUI_EXECUTION"                   = @{ T = 'Motor {0} operante. Processando fluxos...'; H = 'Status da fase de execução com token de motor'; F = 'EXECUTION' }
    "TUI_POSTFLIGHT"                  = @{ T = 'Sequência operacional {0} finalizada.'; H = 'Conclusão pós-voo com token de ferramenta'; F = 'POST-FLIGHT' }
    "TUI_CHKDSK"                      = @{ T = 'Verificação de Integridade do Sistema de Arquivos (Chkdsk)'; H = 'Nome de exibição da ferramenta Chkdsk'; F = $null }
    "TUI_STORDIAG"                    = @{ T = 'Diagnóstico de Telemetria de Hardware (Stordiag)'; H = 'Nome de exibição da ferramenta Stordiag'; F = $null }
    "TUI_FSUTIL"                      = @{ T = 'Colheita do USN Journal NTFS'; H = 'Nome de exibição da ferramenta Fsutil'; F = $null }
    "TUI_ROBOCOPY"                    = @{ T = 'Motor de Sincronização Robocopy'; H = 'Nome de exibição da ferramenta Robocopy'; F = $null }
    "TUI_DISKPART"                    = @{ T = 'Motor de Isolamento Diskpart'; H = 'Nome de exibição da ferramenta Diskpart'; F = $null }

    "LAB_START"                       = @{ T = 'Iniciando análise binária em: {0}'; H = 'Início da análise de laboratório com token de arquivo'; F = 'LAB' }
    "LAB_MAGIC_FIXED"                 = @{ T = 'Assinatura hexadecimal restaurada. Tipo: {0}'; H = 'Confirmação de reparo de magic bytes com token de tipo'; F = 'LAB' }
    "LAB_SUCCESS"                     = @{ T = 'Objeto reconstruído com sucesso em: {0}'; H = 'Sucesso na reconstrução com token de caminho'; F = 'LAB' }
    "LAB_SURGERY_CRITICAL"            = @{ T = 'O objeto alvo está 100% preenchido com zeros (Nulo). A reconstrução binária é matematicamente impossível.'; H = 'Estado crítico de dados irrecuperáveis'; F = 'LAB_FATAL' }
    "LAB_HEADER_MISMATCH"             = @{ T = 'Incompatibilidade de Magic Bytes detectada. Esperado {0}, Hex encontrado {1}.'; H = 'Falha na validação de cabeçalho com tokens esperado/encontrado'; F = 'LAB_WARN' }
    "LAB_BLOCK_SKIP"                  = @{ T = 'Setor ilegível no offset de bloco {0}. Injetando sequência zero-fill de 64KB e saltando para o próximo cluster.'; H = 'Tratamento de setor defeituoso com token de offset'; F = 'LAB_IO' }

    "UI_DIRTY_DISCARD"                = @{ T = 'Alterações de configuração não salvas detectadas na matriz volátil. Descartar e retornar? (s/N): '; H = 'Prompt de confirmação de alterações não salvas'; F = 'STATE_WARN' }
    "UI_LOCKDOWN_ACTIVE"              = @{ T = 'Operação bloqueada pelo orquestrador devido a restrições de ambiente.'; H = 'Aviso de restrição de ambiente'; F = 'RESTRICTED' }
    "UI_CONFIRM_PROCEED"              = @{ T = 'ACEITAR RISCO & PROSSEGUIR'; H = 'Texto do botão de confirmação para operações arriscadas'; F = $null }
    "UI_CONFIRM_ABORT"                = @{ T = 'ABORTAR OPERAÇÃO'; H = 'Texto do botão de abortar para cancelamento'; F = $null }

    "SYNC_SUSPEND"                    = @{ T = 'Suspendendo Monitor Ao Vivo assíncrono para evitar colisões COM/Handle.'; H = 'Aviso de suspensão de sincronismo para segurança de recursos'; F = 'SYNC' }
    "SYNC_RESUME"                     = @{ T = 'Trava síncrona liberada. Retomando thread do Monitor Ao Vivo.'; H = 'Aviso de retomada de sincronismo'; F = 'SYNC' }

    # ─────────────────────────────────────────────────────────────────────
    # STATUS ENUMERATIONS
    # ─────────────────────────────────────────────────────────────────────
    "STATUS_DISCOVERED"               = @{ T = 'DESCOBERTO_PARSEADO'; H = 'Arquivo descoberto via parsing de metadados'; F = $null }
    "STATUS_DISCOVERED_RAW"           = @{ T = 'DESCOBERTO_ESCULPIDO'; H = 'Arquivo descoberto via carving bruto'; F = $null }
    "STATUS_EXTRACTED"                = @{ T = 'EXTRAÍDO_COM_SUCESSO'; H = 'Extração de arquivo concluída com sucesso'; F = $null }
    "STATUS_PARTIAL_CORRUPT"          = @{ T = 'EXTRAÍDO_CORRUPÇÃO_PARCIAL'; H = 'Arquivo extraído com corrupção parcial'; F = $null }
    "STATUS_ORPHAN"                   = @{ T = 'BLOCO_ÓRFÃO'; H = 'Bloco de dados órfão sem metadados'; F = $null }
    "STATUS_FAILED"                   = @{ T = 'FALHA_NA_EXTRAÇÃO'; H = 'Falha na extração do arquivo'; F = $null }
    "STATUS_READY"                    = @{ T = 'ALVO_PRONTO'; H = 'Dispositivo alvo pronto para operações'; F = $null }
    "STATUS_PROCESSING"               = @{ T = 'PROCESSAMENTO_ATIVO'; H = 'Operação atualmente em progresso'; F = $null }
    "STATUS_VERIFIED"                 = @{ T = 'INTEGRIDADE_VERIFICADA'; H = 'Verificação de integridade de dados aprovada'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # TABLE HEADERS
    # ─────────────────────────────────────────────────────────────────────
    "TABLE_HEADER_ID"                 = @{ T = 'ID_DO_OBJETO'; H = 'Cabeçalho de tabela: Identificador do objeto'; F = $null }
    "TABLE_HEADER_NAME"               = @{ T = 'NOME_DO_ARQUIVO'; H = 'Cabeçalho de tabela: Nome do arquivo'; F = $null }
    "TABLE_HEADER_SIZE"               = @{ T = 'TAMANHO_ALOCADO'; H = 'Cabeçalho de tabela: Tamanho alocado em bytes'; F = $null }
    "TABLE_HEADER_TYPE"               = @{ T = 'TIPO_FS'; H = 'Cabeçalho de tabela: Tipo de sistema de arquivos'; F = $null }
    "TABLE_HEADER_STATUS"             = @{ T = 'STATUS_DO_MOTOR'; H = 'Cabeçalho de tabela: Status de processamento'; F = $null }
    "TABLE_HEADER_CATEGORY"           = @{ T = 'CATEGORIA_MIME'; H = 'Cabeçalho de tabela: Categoria de tipo MIME'; F = $null }
    "TABLE_HEADER_HASH"               = @{ T = 'CHECKSUM_SHA256'; H = 'Cabeçalho de tabela: Valor de hash SHA256'; F = $null }
    "TABLE_HEADER_SCORE"              = @{ T = 'SCORE_DE_INTEGRIDADE'; H = 'Cabeçalho de tabela: Pontuação de integridade de dados'; F = $null }
    "TABLE_HEADER_OFFSET"             = @{ T = 'OFFSET_FÍSICO'; H = 'Cabeçalho de tabela: Offset físico do disco'; F = $null }
    "TABLE_HEADER_LENGTH"             = @{ T = 'COMPRIMENTO_EM_BYTES'; H = 'Cabeçalho de tabela: Comprimento em bytes do objeto'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # INVENTORY & DISCOVERY
    # ─────────────────────────────────────────────────────────────────────
    "INVENTORY_PHYSICAL_DISKS"        = @{ T = 'ENUMERANDO TOPOLOGIA DE DISCOS FÍSICOS:'; H = 'Mensagem de início de enumeração de discos físicos'; F = 'GERENCIADOR_INVENTÁRIO' }
    "INVENTORY_LOGICAL_VOLUMES"       = @{ T = 'ENUMERANDO MONTAGENS DE VOLUMES LÓGICOS:'; H = 'Mensagem de início de enumeração de volumes lógicos'; F = 'GERENCIADOR_INVENTÁRIO' }
    "INVENTORY_WMI_FAIL"              = @{ T = 'Subsistema WMI/CIM sem resposta. Não é possível enumerar a topologia de hardware.'; H = 'Erro fatal de falha do subsistema WMI'; F = 'INVENTÁRIO_FATAL' }

    # ─────────────────────────────────────────────────────────────────────
    # VOLUME TYPES & SELECTION
    # ─────────────────────────────────────────────────────────────────────
    "VOLUME_TYPE_NTFS"                = @{ T = 'NTFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_EXFAT"               = @{ T = 'exFAT'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_FAT32"               = @{ T = 'FAT32'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_EXT4"                = @{ T = 'ext4'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_BTRFS"               = @{ T = 'BTRFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_ZFS"                 = @{ T = 'ZFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_XFS"                 = @{ T = 'XFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_APFS"                = @{ T = 'APFS'; H = 'Identificador de tipo de sistema de arquivos'; F = $null }
    "VOLUME_TYPE_UNKNOWN"             = @{ T = 'RAW_OU_DESCONHECIDO'; H = 'Indicador de sistema de arquivos não reconhecido'; F = $null }

    "VOLUME_ACCESS_DENIED"            = @{ T = 'CRÍTICO: Acesso Negado (Verifique Privilégios de Administrador)'; H = 'Erro de acesso negado ao volume'; F = $null }
    "VOLUME_SELECTION_PROMPT"         = @{ T = 'Identifique o alvo de armazenamento comprometido:'; H = 'Instrução de seleção de volume'; F = 'SELEÇÃO_DE_ALVO_VOLUME' }
    "VOLUME_SELECTION_INDEX"          = @{ T = 'ÍNDICE_DO_ALVO'; H = 'Cabeçalho de tabela de seleção de volume'; F = $null }
    "VOLUME_NO_TARGETS"               = @{ T = 'Nenhum alvo de armazenamento viável detectado na configuração de hardware atual.'; H = 'Aviso de nenhum alvo encontrado'; F = 'SYSTEM_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # I/O OPERATIONS
    # ─────────────────────────────────────────────────────────────────────
    "IO_CREATEFILE_FAIL"              = @{ T = 'A API Win32 CreateFile falhou em garantir o handle. Código Win32Error: {0}'; H = 'Falha da API CreateFile com token de código de erro'; F = 'IO_FATAL' }
    "IO_READ_SUCCESS"                 = @{ T = 'Lidos com sucesso {0} bytes do offset físico {1}'; H = 'Confirmação de leitura bem-sucedida com tokens de bytes/offset'; F = 'IO_STREAM' }
    "IO_READ_PARTIAL"                 = @{ T = 'Leitura parcial detectada: esperados {0} bytes, recuperados apenas {1} bytes. Preenchimento (padding) pode ocorrer.'; H = 'Aviso de leitura parcial com tokens esperado/recebido'; F = 'IO_STREAM_WARN' }
    "IO_RETRY_ATTEMPT"                = @{ T = 'Falha de E/S detectada. Tentando novamente {0}/{1} após {2} segundos...'; H = 'Notificação de tentativa de retry com tokens tentativa/max/atraso'; F = 'IO_RESILIÊNCIA' }
    "IO_RECONNECT_SUCCESS"            = @{ T = 'Conexão reestabelecida com a controladora de armazenamento com sucesso.'; H = 'Sucesso na reconexão da controladora'; F = 'IO_RESILIÊNCIA' }
    "IO_RECONNECT_FAIL"               = @{ T = 'Reset da controladora falhou. Dispositivo perdido permanentemente após {0} tentativas.'; H = 'Falha na reconexão da controladora com token de contagem de tentativas'; F = 'IO_FATAL' }
    "IO_ALIGNMENT_SHIFT"              = @{ T = 'Deslocando offset de leitura {0} -> {1} para coincidir com a fronteira do setor físico ({2} bytes).'; H = 'Ajuste de alinhamento de setor com tokens de offset'; F = 'IO_ALINHAMENTO' }
    "IO_DASD_HANDLE_CLOSED"           = @{ T = 'Handle do Dispositivo de Armazenamento de Acesso Direto (DASD) liberado de volta ao SO.'; H = 'Confirmação de liberação de handle DASD'; F = 'IO_GERENCIADOR' }
    "IO_DEVICE_NOT_READY"             = @{ T = 'O dispositivo de armazenamento reportou status Não Pronto. Aguardando reconexão de hardware.'; H = 'Aviso de dispositivo não pronto'; F = 'IO_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # SYSTEM TOPOLOGY & SPECS
    # ─────────────────────────────────────────────────────────────────────
    "TOPOLOGY_TITLE"                  = @{ T = '[ TOPOLOGIA DE INFRAESTRUTURA DO SISTEMA ]'; H = 'Cabeçalho de exibição de topologia'; F = $null }
    "SPEC_LABEL_CPU"                  = @{ T = 'PROCESSADOR'; H = 'Rótulo de especificação de hardware para CPU'; F = $null }
    "SPEC_LABEL_RAM"                  = @{ T = 'MEMÓRIA'; H = 'Rótulo de especificação de hardware para RAM'; F = $null }
    "SPEC_LABEL_OS"                   = @{ T = 'KERNEL'; H = 'Rótulo de especificação de hardware para kernel do SO'; F = $null }
    "SPEC_LABEL_VIRT"                 = @{ T = 'VIRT_LAYER'; H = 'Rótulo de especificação de hardware para camada de virtualização'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # HARDWARE METRICS & TELEMETRY
    # ─────────────────────────────────────────────────────────────────────
    "HW_SMART_FAIL"                   = @{ T = 'Limite de pré-falha S.M.A.R.T. excedido para o atributo ID {0} (Valor Bruto: {1}). Falha mecânica iminente.'; H = 'Aviso crítico S.M.A.R.T. com tokens de atributo/valor'; F = 'HW_METRICS_CRÍTICO' }
    "HW_TBW_WARN"                     = @{ T = 'AVISO DE RESISTÊNCIA NAND: O Total de Bytes Gravados (TBW) do SSD alvo está próximo dos limites do fabricante. Risco de bloqueio de hardware para somente-leitura.'; H = 'Aviso de resistência de SSD'; F = 'HW_METRICS_AVISO' }
    "HW_TBW_CRITICAL"                 = @{ T = 'Limite TBW estritamente excedido. A unidade pode entrar em estado de proteção somente-leitura a qualquer momento.'; H = 'Falha crítica de resistência de SSD'; F = 'HW_METRICS_FATAL' }
    "HW_BAD_SECTOR_DETECT"            = @{ T = 'Erro de Leitura Incorrigível (CRC) encontrado no LCN {0}. O setor está fisicamente degradado.'; H = 'Detecção de setor defeituoso com token LCN'; F = 'FALHA_IO_DETECTADA' }
    "HW_IO_THRASHING"                 = @{ T = 'Thrashing severo de E/S detectado. Comprimento da Fila do Disco é {0}. Suspendendo barramento do motor para evitar morte do hardware.'; H = 'Alerta de thrashing de E/S com token de comprimento de fila'; F = 'ALERTA_TELEMETRIA' }
    "HW_IO_RECOVERY"                  = @{ T = 'A pressão de E/S normalizou abaixo dos limites críticos. Retomando threads operacionais do kernel.'; H = 'Notificação de recuperação de E/S'; F = 'ATUALIZAÇÃO_TELEMETRIA' }
    "HW_THERMAL_CRIT"                 = @{ T = 'VIOLAÇÃO TÉRMICA. A Sonda ACPI reporta {0}C. Acionando estrangulamento térmico agressivo para prevenir dano ao silício.'; H = 'Alerta térmico crítico com token de temperatura'; F = 'HW_METRICS_CRÍTICO' }
    "HW_THERMAL_NORMALIZED"           = @{ T = 'PARÂMETROS TÉRMICOS NORMALIZADOS. Retomando extração padrão do pipeline.'; H = 'Notificação de normalização térmica'; F = 'HW_METRICS_ATUALIZAÇÃO' }
    "HW_CONTROLLER_RESET"             = @{ T = 'A Controladora DASD derrubou a conexão forçadamente. Tentando recriar handle de baixo nível (Tentativa {0}/6).'; H = 'Tentativa de reset da controladora com token de contador'; F = 'FALHA_IO_DETECTADA' }
    "HW_PRESSURE_SUSPEND"             = @{ T = 'PRESSÃO CRÍTICA NA FILA DE E/S DETECTADA. SUSPENDENDO TODA ATIVIDADE DO BARRAMENTO DO MOTOR IMEDIATAMENTE.'; H = 'Suspensão por pressão crítica de E/S'; F = 'TELEMETRIA_CRÍTICA' }
    "HW_PRESSURE_RESUME"              = @{ T = 'PRESSÃO NA FILA DE E/S NORMALIZADA. RETOMANDO BARRAMENTO DO MOTOR.'; H = 'Retomada por normalização de pressão de E/S'; F = 'ATUALIZAÇÃO_TELEMETRIA' }
    "HW_CACHE_FLUSH"                  = @{ T = 'Descarregando cache de gravação volátil do disco para a NAND física para evitar perda de dados.'; H = 'Notificação de operação de flush de cache'; F = 'HW_GERENCIADOR' }
    "HW_STORAGE_HEALTH"               = @{ T = 'Aviso: Latência de resposta crítica detectada em {0}. Verifique a integridade física do cabo SATA/NVMe e da controladora.'; H = 'Aviso de saúde de armazenamento com token de dispositivo'; F = 'HW_DIAGNÓSTICO' }

    # ─────────────────────────────────────────────────────────────────────
    # NETWORK / SAMBA OPERATIONS
    # ─────────────────────────────────────────────────────────────────────
    "NET_SMB_LOCK"                    = @{ T = 'Cofre Samba mapeado e travado com sucesso na letra de unidade {0} (Alvo: {1}).'; H = 'Sucesso na montagem SMB com tokens de unidade/alvo'; F = 'NETWORK_SEGURO' }
    "NET_SMB_TIMEOUT"                 = @{ T = 'Varredura de sub-rede do Radar Samba esgotada. O IP alvo está inacessível, bloqueado por firewall ou offline.'; H = 'Erro de timeout na descoberta SMB'; F = 'NETWORK_ERR' }
    "NET_SMB_UNMOUNT"                 = @{ T = 'Desmontando Unidade Samba {0} e destruindo credenciais de rede ativas...'; H = 'Desmontagem SMB com token de unidade'; F = 'NETWORK_CLEANUP' }
    "NET_RADAR_SWEEP"                 = @{ T = 'Iniciando Varredor Agressivo de Sub-rede Física (Threads: 256 | Timeout do Socket: 80ms)'; H = 'Inicialização de varredura de radar de rede'; F = 'INFRA_RADAR' }
    "NET_RADAR_SCAN"                  = @{ T = 'Varrendo Base CIDR local: {0}.0/24 por portas SMB ativas...'; H = 'Progresso de scan de sub-rede com token de IP base'; F = 'FASE_SCAN' }
    "NET_RADAR_FOUND"                 = @{ T = 'Nó Samba Compatível Travado: {0} respondendo na Porta TCP 445.'; H = 'Descoberta de nó SMB com token de IP'; F = 'NETWORK_SUCESSO' }
    "NET_LATENCY_WARN"                = @{ T = 'Latência de rede instável detectada ({0}ms). O desempenho do fluxo de sincronização ativo pode degradar significativamente.'; H = 'Aviso de latência de rede com token em ms'; F = 'CLOUD_SYNC_WARN' }
    "NET_SYNC_START"                  = @{ T = 'Iniciando transferência de carga segura e multi-thread via Motor Robocopy. Destino Alvo: {0}'; H = 'Início de sincronismo com token de destino'; F = 'CLOUD_SYNC_INIT' }
    "NET_SYNC_SUCCESS"                = @{ T = 'Sequência de espelhamento concluída com sucesso. Código de Saída do Robocopy: {0}.'; H = 'Sucesso no sincronismo com token de código de saída'; F = 'CLOUD_SYNC_CONCLUÍDO' }
    "NET_SYNC_FAIL"                   = @{ T = 'Espelhamento abortado ou encontrou erros críticos. Robocopy retornou código de saída {0}.'; H = 'Falha no sincronismo com token de código de saída'; F = 'CLOUD_SYNC_FATAL' }
    "NET_PACKET_DROP"                 = @{ T = 'Perda de pacotes/Queda TCP detectada durante o upload do staging. Auto-retomando fluxo de bytes a partir do último bloco confirmado.'; H = 'Notificação de recuperação de perda de pacotes'; F = 'CLOUD_SYNC_WARN' }
    "NET_SMB_AUTH_REQUIRED"           = @{ T = 'O endpoint Samba requer autenticação segura. Uma caixa de diálogo de Segurança do Windows aparecerá em breve.'; H = 'Aviso de prompt de autenticação SMB'; F = 'NETWORK_AUTH' }

    "NET_RADAR_GATEWAY_ERR"           = @{ T = 'Nenhum gateway real encontrado! O host pode estar isolado.'; H = 'Erro na descoberta de gateway'; F = 'ERRO' }
    "NET_RADAR_GATEWAY_OK"            = @{ T = 'Gateway: {0} ({1})'; H = 'Informações de gateway com tokens IP/nome'; F = 'NETWORK' }
    "NET_RADAR_SCAN_DETAIL"           = @{ T = 'Varredura assíncrona de alta velocidade ({0} conexões por lote)...'; H = 'Detalhe de scan com token de tamanho de lote'; F = 'SCAN' }
    "NET_RADAR_TESTING"               = @{ T = 'Testando {0}.0/24...'; H = 'Progresso de teste de sub-rede com token base'; F = $null }
    "NET_RADAR_SWEEPING"              = @{ T = '-> Varrendo {0} IPs...'; H = 'Progresso de varredura com token de contagem de IPs'; F = $null }
    "NET_RADAR_FOUND_COUNT"           = @{ T = '[+] {0} servidor(es) encontrado(s)!'; H = 'Resultado de contagem de servidores com token'; F = $null }
    "NET_RADAR_NONE_COUNT"            = @{ T = '[-] Nenhum'; H = 'Indicador de nenhum servidor encontrado'; F = $null }
    "NET_RADAR_VALID"                 = @{ T = '[+] Servidor válido: {0}'; H = 'Confirmação de servidor válido com token de IP'; F = $null }
    "NET_RADAR_IGNORED"               = @{ T = '[!] Ignorado (Gateway Host): {0}'; H = 'Gateway ignorado com token de IP'; F = $null }
    "NET_RADAR_PROMPT"                = @{ T = 'MÚLTIPLOS HOSTS SMB DETECTADOS. SELECIONE O ALVO:'; H = 'Prompt de seleção de múltiplos hosts'; F = $null }
    "NET_RADAR_LOCATED"               = @{ T = 'SERVIDOR SAMBA LOCALIZADO COM SUCESSO!'; H = 'Banner de sucesso na localização de servidor'; F = $null }
    "NET_RADAR_ADDRESS"               = @{ T = 'ENDEREÇO: \\{0}'; H = 'Exibição de endereço de servidor com token UNC'; F = $null }
    "NET_RADAR_NONE"                  = @{ T = 'Nenhum servidor SMB encontrado na topologia atual.'; H = 'Erro de nenhum servidor encontrado'; F = 'ERRO' }

    "NET_MAP_INIT"                    = @{ T = 'Injetando credenciais e abrindo seletor de pasta para \\{0}...'; H = 'Inicialização de montagem com token UNC'; F = 'MAP' }
    "NET_MAP_OK"                      = @{ T = 'Vault de Destino Selecionado: {0}'; H = 'Confirmação de seleção de vault com token de caminho'; F = 'OK' }
    "NET_MAP_AUTH"                    = @{ T = 'Autenticação explícita exigida pela controladora de domínio SMB.'; H = 'Aviso de requisito de autenticação'; F = 'AUTH' }
    "NET_MAP_AUTH_PROMPT"             = @{ T = 'Insira as credenciais de rede para \\{0}'; H = 'Prompt de autenticação com token UNC'; F = $null }
    "NET_MAP_ABORT"                   = @{ T = 'Autenticação cancelada pelo operador.'; H = 'Aviso de cancelamento de autenticação'; F = 'ABORT' }
    "NET_MAP_SUCCESS"                 = @{ T = 'UNIDADE {0} MAPEADA COM SUCESSO!'; H = 'Sucesso na montagem com token de letra de unidade'; F = $null }
    "NET_MAP_DENIED"                  = @{ T = 'Acesso negado. Credenciais inválidas ou permissões insuficientes.'; H = 'Erro de montagem negada'; F = 'ERRO' }
    "NET_MAP_CANCELLED"               = @{ T = 'Operação cancelada pelo operador ou falha no mapeamento.'; H = 'Aviso de cancelamento/falha de montagem'; F = 'ABORT' }

    "NET_MGR_TITLE"                   = @{ T = 'GERENCIAMENTO DE UNIDADES DE REDE'; H = 'Título do menu de gerenciamento de rede'; F = $null }
    "NET_MGR_UNMOUNT"                 = @{ T = 'DESMONTAR: {0} -> {1}'; H = 'Exibição de desmontagem com tokens unidade/caminho'; F = $null }
    "NET_MGR_UNMOUNT_DISP"            = @{ T = '[DESMONTAR] {0}: -> {1}'; H = 'Formato de log de desmontagem com tokens'; F = $null }
    "NET_MGR_UNMOUNT_ALL"             = @{ T = 'DESMONTAR TODAS AS UNIDADES DE REDE'; H = 'Opção de menu para desmontagem em massa'; F = $null }
    "NET_MGR_AUTO_MOUNT"              = @{ T = 'AUTO-DETECTAR & MONTAR NOVO COFRE SAMBA'; H = 'Opção de menu para auto-montagem'; F = $null }
    "NET_MGR_BACK"                    = @{ T = 'RETORNAR AO MENU ANTERIOR'; H = 'Opção de navegação para voltar'; F = $null }
    "NET_MGR_MOUNT_SUCCESS"           = @{ T = 'Mapeado em {0}'; H = 'Sucesso na montagem com token de caminho'; F = $null }
    "NET_MGR_ALL_REMOVED"             = @{ T = 'Todas as unidades de rede foram removidas.'; H = 'Confirmação de desmontagem em massa'; F = $null }
    "NET_MGR_UNMOUNT_REGEX"           = @{ T = '^(?:UNMOUNT|DESMONTAR|\[DESMONTAR\]):\s*([A-Z]):'; H = 'Padrão regex para parsing de comando de desmontagem'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # SQLITE DATABASE ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "SQLITE_ENGINE_LOADED"            = @{ T = 'Motor de Interoperação Nativa Carregado do caminho: {0}'; H = 'Sucesso no carregamento do motor SQLite com token de caminho'; F = 'SQLITE_ENGINE' }
    "SQLITE_ENGINE_FAIL"              = @{ T = 'Falha ao carregar ou vincular dependência DLL do SQLite: {0}'; H = 'Falha no carregamento do SQLite com token de erro'; F = 'SQLITE_FATAL' }
    "SQLITE_DB_INIT"                  = @{ T = 'Esquema do banco de dados e estruturas relacionais inicializados com sucesso em modo WAL.'; H = 'Sucesso na inicialização do banco de dados'; F = 'SQLITE_CORE' }
    "SQLITE_DB_FAIL"                  = @{ T = 'A sequência de inicialização do esquema do banco de dados falhou: {0}'; H = 'Falha na inicialização do banco com token de erro'; F = 'SQLITE_ERR' }
    "SQLITE_MEMORY_SPILL"             = @{ T = 'Falha ao confirmar o despejo do buffer de memória para o banco de dados físico: {0}'; H = 'Falha no spill de memória com token de erro'; F = 'SQLITE_ERR' }
    "SQLITE_WAL_CHECKPOINT"           = @{ T = 'Sequências de SQLite WAL Checkpoint, Pragma Optimize e VACUUM reportaram: CONSISTENT.'; H = 'Sucesso na manutenção do banco de dados'; F = 'SQLITE_SUCESSO' }
    "SQLITE_INTEGRITY_CHECK"          = @{ T = 'A verificação de integridade interna do banco de dados passou 100%.'; H = 'Sucesso na verificação de integridade'; F = 'SQLITE_AUDITORIA' }
    "SQLITE_CONNECTION_BUSY"          = @{ T = 'A thread do banco de dados está atualmente travada/ocupada. Engajando recuo de tentativa...'; H = 'Aviso de banco de dados ocupado'; F = 'SQLITE_WARN' }

    "DB_LOCATION_INFO"                = @{ T = 'Banco de dados forense salvo com segurança em: {0}'; H = 'Informação de localização do banco com token de caminho'; F = 'DB' }
    "DB_QUERY_PROMPT"                 = @{ T = "Digite a Consulta SQL (ou 'exit' para voltar): "; H = 'Prompt de entrada do console SQL'; F = $null }
    "DB_QUERY_RESULT"                 = @{ T = 'Consulta Executada. Linhas afetadas/retornadas: {0}'; H = 'Resultado de consulta com token de contagem de linhas'; F = $null }
    "DB_QUERY_ERROR"                  = @{ T = 'Falha na execução da consulta: {0}'; H = 'Erro de consulta com token de exceção'; F = 'DB_ERR' }
    "DB_MONITOR_STATS"                = @{ T = 'Registros: {0} | Órfãos: {1} | Gravado: {2} MB'; H = 'Exibição de estatísticas ao vivo com tokens de registro/órfão/tamanho'; F = 'LIVE' }

    # ─────────────────────────────────────────────────────────────────────
    # INTEGRITY & FAILSAFE SYSTEMS
    # ─────────────────────────────────────────────────────────────────────
    "INT_MFT_MIRROR_DIV"              = @{ T = 'Divergência entre a MFT primária e o MFTMirror detectada. A lógica subjacente do sistema de arquivos está comprometida.'; H = 'Alerta de integridade por divergência de MFT'; F = 'ALERTA_SANCTUARY' }
    "INT_SQLITE_CORRUPT"              = @{ T = 'Corrupção no Write-Ahead Log (WAL) do SQLite detectada. Forçando vacuum estrutural e reconstrução.'; H = 'Recuperação de corrupção WAL do SQLite'; F = 'SQLITE_FATAL' }
    "INT_MODE_CONFLICT"               = @{ T = "O sistema de arquivos detectado '{0}' inerentemente não suporta o modo de parsing de motor '{1}'."; H = 'Incompatibilidade filesystem/modo com tokens'; F = 'CONFLITO_CONFIG' }
    "INT_FAILSAFE_TRIG"               = @{ T = 'A trajetória determinística primária falhou. Engajando fallback de extração Arqueológica profunda em {0} segundos.'; H = 'Gatilho de fallback com token de contagem regressiva'; F = 'FAILSAFE_PIPELINE' }
    "INT_FALLBACK_ABORT"              = @{ T = 'Operação forçadamente cancelada pelo operador. O motor estritamente não pode processar partições RAW ou Linux enquanto travado no modo EFFICIENCY.'; H = 'Aviso de abort de fallback'; F = 'ABORTAR' }
    "INT_CONVERSION_AUTH"             = @{ T = 'Autoriza a conversão automática para o modo REDUNDANCY (Esquema UniversalMetadata)? [S/N]'; H = 'Prompt de autorização de conversão de modo'; F = 'INTERVENÇÃO_NECESSÁRIA' }
    "INT_CONVERSION_OK"               = @{ T = 'EngineMode alterado com sucesso para REDUNDANCY.'; H = 'Confirmação de conversão de modo'; F = 'ATUALIZAÇÃO_CONFIG' }
    "INT_CHECKPOINT_CREATED"          = @{ T = 'Ponto de verificação operacional salvo no banco de dados. A capacidade de retomada do motor está agora ativa.'; H = 'Confirmação de criação de checkpoint'; F = 'MÁQUINA_ESTADO' }

    # ─────────────────────────────────────────────────────────────────────
    # PIPELINE / EXTRACTION FLOW
    # ─────────────────────────────────────────────────────────────────────
    "PIPE_TRAVERSAL_START"            = @{ T = 'Caminhando a árvore de metadados deterministicamente em {0}...'; H = 'Início de travessia com token de alvo'; F = 'INIT_TRAVERSAL' }
    "PIPE_TRAVERSAL_COMPLETE"         = @{ T = 'Caminhada de metadados do sistema de arquivos concluída com sucesso.'; H = 'Aviso de conclusão de travessia'; F = 'TRAVERSAL_CONCLUÍDO' }
    "PIPE_ARCHAEOLOGY_START"          = @{ T = 'Varredura bruta de assinaturas hexadecimais iniciada para o motor: {0}.'; H = 'Início de arqueologia com token de motor'; F = 'INIT_ARQUEOLOGIA' }
    "PIPE_ARCHAEOLOGY_COMPLETE"       = @{ T = 'Extração profunda da superfície do disco concluída.'; H = 'Aviso de conclusão de arqueologia'; F = 'ARQUEOLOGIA_CONCLUÍDA' }
    "PIPE_BATCH_START"                = @{ T = 'Igniciando motor de extração no modo [{0}] para a categoria ({1})...'; H = 'Início de lote com tokens de modo/categoria'; F = 'MOTOR_LOTE' }
    "PIPE_BATCH_COMPLETE"             = @{ T = 'Operações de extração em lote Harvester finalizadas.'; H = 'Aviso de conclusão de lote'; F = 'MOTOR_LOTE' }
    "PIPE_EXTRACT_COUNTER"            = @{ T = '[{0}] Processando carga: {1}'; H = 'Progresso de extração com tokens de índice/arquivo'; F = 'FLUXO_EXTRAÇÃO' }
    "PIPE_STREAMING_DATA"             = @{ T = 'STREAMING_DATA_FOR_RECORD: Injeção de Buffer de E/S Sincronizada.'; H = 'Aviso de sincronização de streaming de dados'; F = 'SYNC_PIPELINE' }
    "PIPE_TARGETED_RECOVERY"          = @{ T = 'SEQUÊNCIA DE RECUPERAÇÃO TARGETADA ATIVADA E TRAVADA.'; H = 'Ativação de recuperação direcionada'; F = 'EXEC_PIPELINE' }

    "PIPE_FALLBACK_WARNING"           = @{ T = 'OS METADADOS DO SISTEMA DE ARQUIVOS ESTÃO CORROMPIDOS, CRIPTOGRAFADOS OU FISICAMENTE INACESSÍVEIS.'; H = 'Aviso crítico de corrupção de metadados'; F = 'AVISO_CRÍTICO' }
    "PIPE_FALLBACK_IMMINENT"          = @{ T = 'RECUANDO PARA EXTRAÇÃO DE DADOS BRUTOS (PLANO B). SOBRECARGA EXTREMA DE E/S É IMINENTE.'; H = 'Aviso de fallback iminente'; F = 'AVISO_CRÍTICO' }
    "PIPE_FALLBACK_COUNTDOWN"         = @{ T = 'AGUARDANDO {0} SEGUNDOS PARA ABORTAR A OPERAÇÃO (PRESSIONE CTRL+C AGORA)...'; H = 'Contagem regressiva de fallback com token de segundos'; F = 'TIMER_FAILSAFE' }
    "PIPE_FALLBACK_ENGAGED"           = @{ T = 'TEMPO ESGOTADO. ENGATANDO MECANISMO DE VARREDURA ARQUEOLÓGICA.'; H = 'Confirmação de engajamento de fallback'; F = 'FAILSAFE_ACIONADO' }
    "PIPE_EXTRACTION_PHASE"           = @{ T = 'Iniciando a fase física de extração de bytes...'; H = 'Transição para fase de extração'; F = 'TRANSIÇÃO_PIPELINE' }
    "PIPE_CARVING_PROGRESS"           = @{ T = 'Offset Físico: {0} GB | Taxa de Transf.: {1} MB/s | Órfãos Recuperados: {2}'; H = 'Telemetria de carving com tokens de offset/velocidade/contagem'; F = 'TELEMETRIA_CARVING' }

    # ─────────────────────────────────────────────────────────────────────
    # UI / INTERACTIVE EXPLORER
    # ─────────────────────────────────────────────────────────────────────
    "UI_ExplorerTitle"                = @{ T = 'EXPLORADOR DE ARQUIVOS INTERATIVO - SISTEMA DE RECUPERAÇÃO SCAPE'; H = 'Título da janela do explorador'; F = $null }
    "UI_BreadcrumbRoot"               = @{ T = 'RAIZ_VIRTUAL'; H = 'Rótulo de breadcrumb raiz'; F = $null }
    "UI_NavHelp"                      = @{ T = 'ATALHOS: [CIMA/BAIXO] Navegar | [ENTER] Abrir Pasta | [ESPAÇO] Alternar Marcação | [E] Executar Extração | [B] Voltar | [Q] Sair do Explorador'; H = 'Texto de ajuda de navegação do explorador'; F = $null }
    "UI_DirIcon"                      = @{ T = '[DIR ]'; H = 'Indicador de ícone de diretório'; F = $null }
    "UI_FileIcon"                     = @{ T = '[ARQ ]'; H = 'Indicador de ícone de arquivo'; F = $null }
    "UI_Marked"                       = @{ T = '[X]'; H = 'Indicador de item marcado'; F = $null }
    "UI_Unmarked"                     = @{ T = '[ ]'; H = 'Indicador de item não marcado'; F = $null }
    "UI_Cursor"                       = @{ T = '>>> '; H = 'Indicador de cursor de seleção'; F = $null }
    "UI_EmptyFolder"                  = @{ T = '[ DIRETÓRIO ESTÁ VAZIO OU ILEGÍVEL ]'; H = 'Aviso de pasta vazia/ilegível'; F = $null }

    "UI_ConfirmExtract"               = @{ T = 'PERIGO: Confirmar extração física de {0} itens selecionados (incluindo todos os filhos recursivos)? (s/N): '; H = 'Confirmação de extração recursiva com token de contagem'; F = $null }
    "UI_Extracting"                   = @{ T = 'Processando extração física para {0} objetos marcados...'; H = 'Progresso de extração com token de contagem'; F = $null }
    "UI_ExtractComplete"              = @{ T = 'Extração targetada confirmada com sucesso para o caminho de staging: {0}'; H = 'Sucesso na extração com token de caminho'; F = $null }
    "UI_LoadError"                    = @{ T = 'Erro fatal ao carregar os itens do nó de diretório: {0}'; H = 'Erro de carregamento de diretório com token de exceção'; F = $null }

    "UI_SelectFolder"                 = @{ T = 'SELECIONE SANDBOX DE DESTINO ISOLADO PARA STAGING'; H = 'Cabeçalho de seleção de pasta de staging'; F = $null }
    "UI_StagingFolderPrompt"          = @{ T = 'Digite o caminho completo da pasta de Staging (SSD Local recomendado)'; H = 'Instrução de entrada de caminho de staging'; F = $null }
    "UI_DestinationPrompt"            = @{ T = 'Digite o caminho completo do Destino final (OneDrive/Google Drive/Compartilhamento de Rede UNC)'; H = 'Instrução de entrada de caminho de destino'; F = $null }
    "UI_MarkRecursiveHint"            = @{ T = 'O modificador [R] indica uma marcação recursiva - todos os objetos filhos dentro do diretório serão extraídos.'; H = 'Dica de marcação recursiva'; F = $null }
    "UI_SELECT_DIR_ERROR"             = @{ T = 'Falha ao iniciar seletor de diretórios: {0}'; H = 'Erro no seletor de diretórios com token de exceção'; F = $null }
    "UI_SELECT_DIR_PROMPT"            = @{ T = 'Selecione o diretório de saída:'; H = 'Prompt de seleção de diretório'; F = $null }
    "UI_SELECT_DIR_FALLBACK"          = @{ T = 'Digite o caminho do diretório manualmente: '; H = 'Fallback para entrada manual de caminho'; F = $null }
    "UI_CANCEL_OP"                    = @{ T = '[CANCELAR OPERAÇÃO]'; H = 'Rótulo do botão cancelar'; F = $null }
    "UI_BTN_BACK"                     = @{ T = '>> VOLTAR'; H = 'Botão de navegação para voltar'; F = $null }

    "UI_COMPLIANCE_DISCLAIMER"        = @{ T = 'O acesso a setores RAW acarreta risco de estresse de hardware ou perda de dados. Aceitar? (s/N): '; H = 'Aviso de risco de acesso RAW'; F = 'COMPLIANCE DASD' }
    "UI_ABORT_CONFIRM_CRITICAL"       = @{ T = 'Abortar E/S ativa pode deixar handles abertos ou corromper o banco de dados. Forçar Abortar? (s/N): '; H = 'Confirmação de abort crítico'; F = 'AVISO CRÍTICO' }

    # ─────────────────────────────────────────────────────────────────────
    # VIEW / DASHBOARD UI
    # ─────────────────────────────────────────────────────────────────────
    "DASH_HEADER_NODE"                = @{ T = 'SYSTEM-CRITICAL ANALYSIS PARTITION EXTRACTOR | NÓ: {0}'; H = 'Cabeçalho do dashboard com token de nó'; F = $null }
    "BANNER_TITLE"                    = @{ T = 'SCAPE Recovery System - Motor Forense Avançado v1.0'; H = 'Título do banner da aplicação'; F = $null }

    "DASH_TASK"                       = @{ T = 'TAREFA: {0}'; H = 'Exibição de tarefa do dashboard com token'; F = $null }
    "DASH_LINE1"                      = @{ T = 'DISK_QUEUE: {0} | THERMAL: {1}C | RAM_PRESSURE: {2}%'; H = 'Linha de métricas do dashboard com tokens fila/temp/ram'; F = $null }
    "DASH_LINE2"                      = @{ T = 'DB_PARSED: {0} | DB_ORPHANS: {1} | DB_EXTRACTED: {2}'; H = 'Linha de métricas do dashboard com tokens de estatísticas do BD'; F = $null }
    "DASH_LINE3"                      = @{ T = 'LCN_POS: {0} | PROG: {1} | RATE: {2} MB/s'; H = 'Linha de métricas do dashboard com tokens de progresso/taxa'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # ROBOCOPY / CLOUD SYNC CONFIG
    # ─────────────────────────────────────────────────────────────────────
    "RC_TITLE"                        = @{ T = 'LOGÍSTICA & PAINEL DE CONTROLE DE CLOUD SYNC - SCAPE ROBOSYNC'; H = 'Título do painel Robocopy'; F = $null }
    "RC_STAGING_LABEL"                = @{ T = 'Diretório de Staging Local'; H = 'Rótulo do campo de caminho de staging'; F = $null }
    "RC_DEST_LABEL"                   = @{ T = 'Destino Final Cloud/UNC'; H = 'Rótulo do campo de caminho de destino'; F = $null }

    "RC_FLAG_E"                       = @{ T = '/E : Copiar todos os subdiretórios (incluindo diretórios vazios)'; H = 'Descrição da flag /E do Robocopy'; F = $null }
    "RC_FLAG_ZB"                      = @{ T = '/ZB: Modo Restartável + Backup (Resiliência de rede)'; H = 'Descrição da flag /ZB do Robocopy'; F = $null }
    "RC_FLAG_M"                       = @{ T = '/M : Modo Archive Bit (Copiar apenas arquivos não sincronizados)'; H = 'Descrição da flag /M do Robocopy'; F = $null }
    "RC_FLAG_MT"                      = @{ T = '/MT: Transferência Multithread (Valor auto-sensed: {0})'; H = 'Descrição da flag /MT do Robocopy com token de threads'; F = $null }
    "RC_FLAG_B"                       = @{ T = '/B : Modo Backup (Bypass estrito de ACLs/Permissões NTFS)'; H = 'Descrição da flag /B do Robocopy'; F = $null }
    "RC_FLAG_COPYALL"                 = @{ T = '/COPYALL: Espelhar todos os metadados (Dados, Atributos, Timestamps, Segurança, Proprietário, Auditoria)'; H = 'Descrição da flag /COPYALL do Robocopy'; F = $null }
    "RC_FLAG_DCOPY_T"                 = @{ T = '/DCOPY:T: Preservar estritamente os timestamps de diretório'; H = 'Descrição da flag /DCOPY:T do Robocopy'; F = $null }
    "RC_FLAG_NP"                      = @{ T = '/NP: Suprimir porcentagem de progresso (Força logs limpos para execuções industriais)'; H = 'Descrição da flag /NP do Robocopy'; F = $null }
    "RC_FLAG_FFT"                     = @{ T = '/FFT: Forçar tempos de arquivo FAT (Tolerância de granularidade de 2 segundos)'; H = 'Descrição da flag /FFT do Robocopy'; F = $null }
    "RC_FLAG_XO"                      = @{ T = '/XO: Excluir arquivos mais antigos (Prevenção de redundância)'; H = 'Descrição da flag /XO do Robocopy'; F = $null }
    "RC_FLAG_XN"                      = @{ T = '/XN: Excluir arquivos mais novos (Espelhamento unidirecional)'; H = 'Descrição da flag /XN do Robocopy'; F = $null }
    "RC_FLAG_XJ"                      = @{ T = '/XJ: Excluir pontos de junção (Previne loops infinitos de symlink)'; H = 'Descrição da flag /XJ do Robocopy'; F = $null }
    "RC_FLAG_L"                       = @{ T = '/L : Modo Simulação Apenas Leitura (Dry run, nenhum byte transferido)'; H = 'Descrição da flag /L do Robocopy'; F = $null }
    "RC_FLAG_V"                       = @{ T = '/V : Saída Verbosa (Habilita logs detalhados para cadeias de evidência judiciais)'; H = 'Descrição da flag /V do Robocopy'; F = $null }

    "RC_FLAG_E_DESC"                  = @{ T = 'Copia todos os subdiretórios, incluindo os vazios. Essencial para reconstruir a topologia exata de diretórios.'; H = 'Explicação detalhada da flag /E'; F = $null }
    "RC_FLAG_M_DESC"                  = @{ T = "Modo Archive Bit: Apenas espelha arquivos que não foram previamente sincronizados. Reseta a flag 'Archive' após cópia bem sucedida para minimizar desgaste no SSD."; H = 'Explicação detalhada da flag /M'; F = $null }
    "RC_FLAG_ZB_DESC"                 = @{ T = 'Modo Reiniciável: Altamente crítico para conexões instáveis de rede ou nuvem. Previne corrupção de arquivos retomando transferências interrompidas.'; H = 'Explicação detalhada da flag /ZB'; F = $null }
    "RC_FLAG_MT_DESC"                 = @{ T = 'Capacidade Multi-Thread: Valores altos (64-128) recomendados para NVMe-para-NVMe. Valores baixos (8-16) requeridos para compartilhamentos de Rede/Samba instáveis.'; H = 'Explicação detalhada da flag /MT'; F = $null }
    "RC_FLAG_B_DESC"                  = @{ T = 'MODO BACKUP: Explora SeBackupPrivilege para ler arquivos bloqueados forçadamente, independentemente de permissões NTFS corrompidas ou restritivas.'; H = 'Explicação detalhada da flag /B'; F = $null }
    "RC_FLAG_FFT_DESC"                = @{ T = 'Tempos de Arquivo FAT: Obrigatório ao espelhar dados entre volumes NTFS precisos e dispositivos FAT/exFAT menos precisos para evitar falsos positivos em diferenças de horário.'; H = 'Explicação detalhada da flag /FFT'; F = $null }
    "RC_FLAG_XO_DESC"                 = @{ T = 'Excluir Mais Antigos: Ignora arquivos que já existem e são estritamente mais novos no alvo de destino. Excelente para prevenção de redundância.'; H = 'Explicação detalhada da flag /XO'; F = $null }
    "RC_FLAG_XN_DESC"                 = @{ T = 'Excluir Mais Novos: Pula a cópia de arquivos que são mais novos no alvo de destino. Útil para sincronização estrita de arquivo unidirecional.'; H = 'Explicação detalhada da flag /XN'; F = $null }
    "RC_FLAG_XJ_DESC"                 = @{ T = 'Excluir Junções: Previne o motor de cair em loops de recursão infinitos ao sincronizar diretórios contendo links simbólicos quebrados.'; H = 'Explicação detalhada da flag /XJ'; F = $null }
    "RC_FLAG_NP_DESC"                 = @{ T = 'Sem Progresso: Suprime o contador de porcentagem na saída padrão. Obrigatório para manter os arquivos de log legíveis para scripts automatizados de parsing.'; H = 'Explicação detalhada da flag /NP'; F = $null }
    "RC_FLAG_L_DESC"                  = @{ T = 'MODO SIMULAÇÃO: Lista todos os arquivos que seriam processados sem realmente mover nenhum byte. Crucial para testes de sanidade antes de operações massivas.'; H = 'Explicação detalhada da flag /L'; F = $null }
    "RC_FLAG_V_DESC"                  = @{ T = 'MODO VERBOSO: Gera logs altamente detalhados, detalhando cada arquivo pulado e códigos de erro exatos. Legalmente exigido para manter cadeia de custódia.'; H = 'Explicação detalhada da flag /V'; F = $null }

    "RC_RETRY_R"                      = @{ T = '/R : Contagem de tentativas de repetição em falha'; H = 'Rótulo da flag /R do Robocopy'; F = $null }
    "RC_RETRY_W"                      = @{ T = '/W : Tempo de limite de espera entre tentativas (em segundos)'; H = 'Rótulo da flag /W do Robocopy'; F = $null }
    "RC_RETRY_R_DESC"                 = @{ T = 'Contagem de Tentativas: Número exato de vezes que o motor tentará novamente uma transferência de byte falha. O padrão é 3. Aumente significativamente para redes WAN altamente instáveis.'; H = 'Explicação detalhada da flag /R'; F = $null }
    "RC_RETRY_W_DESC"                 = @{ T = 'Tempo de Espera: Segundos absolutos que o motor pausará antes de tentar novamente uma transferência falha. O padrão é 10. Aumente para endpoints de nuvem instáveis.'; H = 'Explicação detalhada da flag /W'; F = $null }
    "RC_WAIT_RETRY"                   = @{ T = '/R:{0} /W:{1} (Tentativas Config.: {0} | Intervalo Espera: {1}s)'; H = 'Exibição de configuração de retry com tokens'; F = $null }

    "RC_CACHE_ADVISORY"               = @{ T = 'GUIA DE TOPOLOGIA DE CACHE: Certifique-se de que sua unidade de Staging designada tem pelo menos 200% do espaço livre do maior arquivo absoluto sendo recuperado para prevenir fatalidade por estouro de buffer durante o hashing do Robocopy.'; H = 'Aviso de espaço de staging'; F = $null }
    "RC_HW_WEAR_LONG"                 = @{ T = 'AVISO CRÍTICO DE RESISTÊNCIA: O movimento massivo de dados físicos para um diretório de Staging Cloud Local induz Ciclos de Escrita NAND extremamente altos (TBW). Certifique-se de que a unidade de staging é classificada como Enterprise/Industrial.'; H = 'Aviso de resistência de hardware'; F = $null }
    "RC_ENV_GUIDE"                    = @{ T = "GUIA DE CONFIGURAÇÃO ROBOSYNC:`n 1. Defina 'Staging' para uma unidade NVMe/SSD local, fisicamente conectada.`n 2. Defina 'Destino' para a sua pasta de endpoint Sincronizada em Nuvem (ex: OneDrive, Google Drive).`n 3. CRÍTICO: Garanta que 'Arquivos Sob Demanda' da Nuvem (ou equivalente) esteja estritamente DESLIGADO para a pasta Staging para prevenir que o motor de sincronização entre em loop infinito."; H = 'Guia de configuração do Robosync'; F = $null }

    "RC_START_SYNC"                   = @{ T = '[S] INICIAR MOTOR DE SINCRONIZAÇÃO'; H = 'Opção de menu para iniciar sincronismo'; F = $null }
    "RC_CANCEL"                       = @{ T = '[C] ABORTAR CONFIGURAÇÃO DE SINCRONIZAÇÃO'; H = 'Opção de menu para cancelar sincronismo'; F = $null }
    "RC_SPACE_CHECK"                  = @{ T = 'Espaço livre verificado no hardware de staging local: {0} GB'; H = 'Verificação de espaço com token em GB'; F = $null }
    "RC_SPACE_LOW_CONFIRM"            = @{ T = 'PERIGO: Espaço em disco baixo detectado na unidade de staging. Prosseguir pode causar instabilidade no SO. Continuar mesmo assim? (s/N): '; H = 'Prompt de confirmação de espaço baixo'; F = $null }
    "RC_ARCHIVE_MODE_INFO"            = @{ T = '[INFO_ADVISORY] A flag /M (Archive) reduz significativamente o desgaste do SSD pulando agressivamente cargas já sincronizadas.'; H = 'Aviso de benefício do modo archive'; F = $null }
    "RC_INVALID_MT"                   = @{ T = 'Especificação de contagem de thread inválida. Forçando valor ótimo auto-sensed.'; H = 'Tratamento de entrada MT inválida'; F = 'INPUT_ERR' }
    "RC_AUTOSENSE"                    = @{ T = "Meio de destino '{0}' detectado -> Threads de transferência limitadas agressivamente a {1} para prevenir estrangulamento de I/O."; H = 'Aviso de auto-sense com tokens de meio/threads'; F = 'THROTTLE_AUTOSENSE' }

    "RC_SYNC_RUNNING"                 = @{ T = 'Pipeline de sincronização está atualmente quente. Motor Robocopy está executando...'; H = 'Aviso de sincronismo em progresso'; F = 'ROBOSYNC_ATIVO' }
    "RC_CALCULATING_SIZE"             = @{ T = 'Calculando footprint total de bytes dos objetos de carga selecionados...'; H = 'Aviso de cálculo de tamanho de carga'; F = 'ROBOSYNC_PREFLIGHT' }
    "RC_BLOCKED_SPACE"                = @{ T = 'OPERAÇÃO BLOQUEADA: Tamanho da carga excede drasticamente o espaço físico disponível na unidade de staging.'; H = 'Erro de bloqueio por espaço'; F = 'ROBOSYNC_FATAL' }
    "RC_ROBOCOPY_NOT_FOUND"           = @{ T = 'O executável nativo Robocopy.exe não foi encontrado no PATH do ambiente do sistema.'; H = 'Erro de Robocopy não encontrado'; F = 'ROBOSYNC_FATAL' }
    "RC_EXIT_CODE_INFO"               = @{ T = 'Processo Robocopy terminou com código de saída {0}: {1}'; H = 'Informação de código de saída com tokens código/desc'; F = 'ROBOSYNC_AUDITORIA' }
    "RC_LOG_SAVED"                    = @{ T = 'Log de transação detalhado do Robocopy comitado com segurança para: {0}'; H = 'Log salvo com token de caminho'; F = 'ROBOSYNC_AUDITORIA' }

    "RC_BTN_START"                    = @{ T = '[ INICIAR SINCRONIZAÇÃO ROBOSYNC ]'; H = 'Rótulo do botão de iniciar sincronismo'; F = $null }
    "RC_BTN_CANCEL"                   = @{ T = '[ ABORTAR E VOLTAR ]'; H = 'Rótulo do botão de cancelar'; F = $null }
    "RC_DEFAULTS_TITLE"               = @{ T = 'CONFIGURAÇÃO DE PARÂMETROS GLOBAIS DO ROBOCOPY'; H = 'Título do painel de configuração de padrões'; F = $null }
    "RC_SAVE_RETURN"                  = @{ T = '[ SALVAR CONFIGURAÇÃO E VOLTAR ]'; H = 'Botão de salvar e retornar'; F = $null }
    "RC_DEL_RTN"                      = @{ T = '[ DESCARTAR ALTERACOES E VOLTAR ]'; H = 'Botão de descartar e retornar'; F = $null }
    "RC_BTN_PREPARE_FLAGS"            = @{ T = 'PREPARAR_FLAGS_ARQUIVO (Bitwise Tagging)'; H = 'Rótulo do botão preparar flags'; F = $null }
    "RC_BTN_PREPARE_FLAGS_DESC"       = @{ T = '[ PREPARAR FLAGS DE ARQUIVO (Bitwise Tagging) ]'; H = 'Descrição do botão preparar flags'; F = $null }
    "RC_BTN_EDIT_DESC"                = @{ T = '[ CONFIGURAR FLAGS DO ROBOCOPY ]'; H = 'Botão de configurar flags'; F = $null }
    "RC_TAGGING_START"                = @{ T = 'Iniciando Marcacao de Archive Bit em Alta Velocidade em {0}...'; H = 'Início de tagging com token de alvo'; F = 'ROBOSYNC' }
    "RC_TAGGING_DONE"                 = @{ T = 'Marcacao de Archive Bit Concluida.'; H = 'Aviso de conclusão de tagging'; F = 'ROBOSYNC' }

    # ─────────────────────────────────────────────────────────────────────
    # DEPLOYER / COMPILER ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "DEPLOYER_START"                  = @{ T = 'Iniciando orquestração estrutural dinâmica do Monolito SCAPE...'; H = 'Inicialização do deployer'; F = 'DEPLOYER_INIT' }
    "DEPLOYER_PURGE"                  = @{ T = 'Árvore de implantação ativa anterior detectada. Purgando arquitetura antiga...'; H = 'Aviso de purga de build antigo'; F = 'DEPLOYER_WARN' }
    "DEPLOYER_EXTRACT"                = @{ T = 'Extraindo cargas modulares dinamicamente da matriz...'; H = 'Início de extração de módulos'; F = 'DEPLOYER_EXEC' }
    "DEPLOYER_EXTRACT_OK"             = @{ T = '-> [DEPLOYER_OK] Módulo payload extraído perfeitamente: {0}'; H = 'Sucesso na extração de módulo com token de nome'; F = $null }
    "DEPLOYER_EXTRACT_FAIL"           = @{ T = "[DEPLOYER_ERROR] Falha catastrófica ao extrair o módulo '{0}': {1}"; H = 'Falha na extração de módulo com tokens nome/erro'; F = $null }
    "DEPLOYER_GENERATE"               = @{ T = 'Gerando e linkando o bootloader Maestro (Main.ps1)...'; H = 'Aviso de geração de bootloader'; F = 'DEPLOYER_LINK' }
    "DEPLOYER_SUCCESS"                = @{ T = 'Monolito de Recuperação SCAPE gerado e compilado com sucesso!'; H = 'Banner de sucesso de build'; F = 'DEPLOYER_DONE' }
    "DEPLOYER_LOCATION"               = @{ T = 'Local de Execução Física: {0}'; H = 'Localização de build com token de caminho'; F = $null }
    "DEPLOYER_FATAL"                  = @{ T = 'Compilação do sistema falhou criticamente: {0}'; H = 'Erro fatal de build com token de exceção'; F = 'DEPLOYER_FATAL' }
    "DEPLOYER_RUN_ADMIN"              = @{ T = 'DIRETIVA CRÍTICA: Execute o Main.ps1 como Administrador para funcionalidade de hardware completa.'; H = 'Diretiva de execução como admin'; F = $null }

    "DEPLOYER_OPT_DEV"                = @{ T = 'DEV_MODE (Extrair módulos e gerar Main.ps1)'; H = 'Opção de menu modo dev'; F = '1' }
    "DEPLOYER_OPT_EXE"                = @{ T = 'BUILD_EXE (Compilar via ps2exe)'; H = 'Opção de menu build portátil EXE'; F = '2' }
    "DEPLOYER_OPT_SETUP"              = @{ T = 'BUILD_EXE (Compilar via INNO Setup)'; H = 'Opção de menu instalador EXE'; F = '3' }
    "DEPLOYER_OPT_MSI"                = @{ T = 'BUILD_MSI (Compilar via WiX Toolset)'; H = 'Opção de menu build MSI'; F = '4' }
    "MENU_DEPLOY_TITLE"               = @{ T = '[ MATRIZ DE DEPLOY SCAPE ]'; H = 'Cabeçalho do menu deployer'; F = $null }
    "DEPLOYER_MATRIX_HEADER"          = @{ T = '[ MATRIZ DE VETORES DE DEPLOY SCAPE ]'; H = 'Cabeçalho de seleção do vetor de deploy'; F = $null }
    "DEPLOYER_MOD_DISCOVERY"          = @{ T = 'Varrendo escopo por assinaturas de módulos...'; H = 'Início de auto-descoberta'; F = 'DEPLOYER_AUTO_DESCOBERTA' }
    "DEPLOYER_ASSETS_DISCOVERY"       = @{ T = 'Varrendo escopo por assinaturas de ativos binários...'; H = 'Início de descoberta de ativos'; F = 'DEPLOYER_AUTO_ASSETS' }

    "DEPLOYER_B64_START"              = @{ T = 'Binários SQLite encontrados. Convertendo para DNA (Base64)...'; H = 'Início de conversão de binários'; F = 'DEPLOYER' }
    "DEPLOYER_B64_SUCCESS"            = @{ T = 'Binários convertidos e injetados no DNA do Core.'; H = 'Sucesso na injeção de binários'; F = 'DEPLOYER' }
    "DEPLOYER_B64_MISSING"            = @{ T = 'DLLs do SQLite não encontradas. O Core tentará download em runtime.'; H = 'Aviso de fallback para DLLs ausentes'; F = 'WARN' }
    "DEPLOYER_B64_DOWNLOADING_BUNDLE" = @{ T = 'Baixando pacote SQLite de {0} ...'; H = 'Download de bundle com token de URL'; F = $null }
    "DEPLOYER_B64_BUNDLE_FAIL"        = @{ T = 'Falha no download do pacote. Tentando pacotes separados...'; H = 'Aviso de fallback de download de bundle'; F = $null }
    "DEPLOYER_B64_DOWNLOADING_X86"    = @{ T = 'Baixando pacote x86...'; H = 'Aviso de download x86'; F = $null }
    "DEPLOYER_B64_DOWNLOADING_X64"    = @{ T = 'Baixando pacote x64...'; H = 'Aviso de download x64'; F = $null }
    "DEPLOYER_B64_SEPARATE_FAIL"      = @{ T = 'Falha ao baixar pacotes separados: {0}'; H = 'Falha no download separado com token de erro'; F = $null }
    "DEPLOYER_B64_FOUND_FILES"        = @{ T = 'Arquivos encontrados no temporário:'; H = 'Cabeçalho de lista de arquivos temporários'; F = $null }
    "DEPLOYER_B64_NO_MANAGED"         = @{ T = 'System.Data.SQLite.dll não encontrada no pacote baixado.'; H = 'Erro de DLL gerenciada ausente'; F = 'ERRO' }
    "DEPLOYER_B64_NO_INTEROP"         = @{ T = 'Não foi possível localizar ambas SQLite.Interop.dll (x86 e x64).'; H = 'Erro de DLLs interop ausentes'; F = 'ERRO' }
    "DEPLOYER_B64_DOWNLOADING_ARM64"  = @{ T = 'Tentando download do ARM64...'; H = 'Tentativa de download ARM64'; F = $null }
    "DEPLOYER_B64_ARM64_OK"           = @{ T = 'DLL nativa ARM64 obtida.'; H = 'Aviso de sucesso ARM64'; F = $null }
    "DEPLOYER_B64_ARM64_MISSING"      = @{ T = 'DLL ARM64 não encontrada no pacote. Fallback será usado.'; H = 'Fallback por DLL ARM64 ausente'; F = $null }
    "DEPLOYER_B64_ARM64_FAIL"         = @{ T = 'Pacote ARM64 não disponível (ou falha no download). Fallback para x64 será usado.'; H = 'Fallback por falha ARM64'; F = $null }
    "DEPLOYER_B64_PLACEMENT_FAIL"     = @{ T = 'Falha ao colocar todas as DLLs necessárias em {0}.'; H = 'Falha no posicionamento de DLLs com token de caminho'; F = 'ERRO' }
    "DEPLOYER_B64_NO_INTEROP_X64"     = @{ T = 'Não foi possível localizar SQLite.Interop.dll no pacote x64.'; H = 'Interop x64 ausente'; F = 'ERRO' }
    "DEPLOYER_B64_NO_INTEROP_X86"     = @{ T = 'Não foi possível localizar SQLite.Interop.dll no pacote x86.'; H = 'Interop x86 ausente'; F = 'ERRO' }
    "DEPLOYER_CORE_RESTORED"          = @{ T = 'DLL Gerenciada restaurada: {0}'; H = 'Restauração de DLL gerenciada com token de caminho'; F = 'SQLITE' }
    "DEPLOYER_NATIVE_RESTORED"        = @{ T = 'DLL Interop Nativa restaurada: {0}'; H = 'Restauração de DLL nativa com token de caminho'; F = 'SQLITE' }
    "DEPLOYER_VETOR_SELECT"           = @{ T = '[+] SELECIONE O VETOR DE IMPLANTAÇÃO:'; H = 'Prompt de seleção de vetor'; F = $null }
    "DEPLOYER_CORE_INJECT"            = @{ T = 'Injetando motor de persistência...'; H = 'Aviso de injeção de persistência'; F = 'DEPLOYER' }
    "DEPLOYER_CORE_FAIL"              = @{ T = 'Falha ao provisionar SQLite. O Maestro pode falhar no boot.'; H = 'Aviso de falha no provisionamento SQLite'; F = 'WARN' }
    "DEPLOYER_DEV_MODE_FAILSAFE"      = @{ T = 'Binários do Core travados. Falha segura de renomeação aplicada para DEV_MODE.'; H = 'Aviso de failsafe modo dev'; F = 'WARN' }
    "DEPLOYER_LAUNCH_SCAPE"           = @{ T = 'INICIANDO MOTOR DE RECUPERAÇÃO SCAPE...'; H = 'Banner de lançamento do motor'; F = $null }
    "DEPLOYER_RETRY_REMOVE"           = @{ T = 'Falha ao remover árvore anterior. Tentando novamente em 2 segundos...'; H = 'Aviso de retry de purga'; F = $null }
    "DEPLOYER_CANNOT_REMOVE"          = @{ T = 'Não foi possível remover o diretório {0}. Prosseguindo com criação forçada...'; H = 'Falha na purga com token de caminho'; F = $null }
    "DEPLOYER_ICON_ANCHORED"          = @{ T = 'Ícone ({0}) ancorado.'; H = 'Âncora de ícone com token de nome'; F = $null }
    "DEPLOYER_DEV_COPY_CORE"          = @{ T = 'Pastas físicas do Core copiadas para arquitetura DEV.'; H = 'Confirmação de cópia dev'; F = $null }
    "DEPLOYER_ERR_NO_PAYLOADS"        = @{ T = 'Nenhum payload mapeado na memória.'; H = 'Erro de nenhum payload'; F = $null }
    "DEPLOYER_ERR_DLL_EXTRACT"        = @{ T = 'Falha interna na extração das DLLs.'; H = 'Erro interno de extração de DLLs'; F = $null }
    "DEPLOYER_ERR_WIX_DOWNLOAD"       = @{ T = 'Falha no download portátil do WiX: {0}'; H = 'Falha no download do WiX com token de erro'; F = $null }
    "DEPLOYER_ERR_PS2EXE"             = @{ T = 'Falha de compilação durante a execução do PS2EXE: {0}'; H = 'Falha do PS2EXE com token de erro'; F = $null }
    "DEPLOYER_ERR_WIX_INSTALL"        = @{ T = 'Falha ao instalar WiX Toolset ou caminho não resolvido. Instale manualmente.'; H = 'Orientação de instalação do WiX'; F = $null }
    "DEPLOYER_ERR_CANDLE"             = @{ T = 'Pipeline de compilação Candle falhou.'; H = 'Erro do pipeline Candle'; F = $null }
    "DEPLOYER_ERR_LIGHT"              = @{ T = 'Pipeline de linkedição Light falhou.'; H = 'Erro do pipeline Light'; F = $null }
    "DEPLOYER_ERR_MSI_FORGE"          = @{ T = 'Falha de compilação durante a forja do MSI WiX: {0}'; H = 'Falha na forja MSI com token de erro'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # COMPILER SUBSYSTEM
    # ─────────────────────────────────────────────────────────────────────
    "COMPILER_MSI_BASE_EXE"           = @{ T = 'Forjando o executável base para o payload MSI...'; H = 'Prep do EXE Base'; F = 'COMPILADOR' }
    "COMPILER_MSI_SUCCESS"            = @{ T = 'Instalador MSI gerado com sucesso: {0}'; H = 'Sucesso na geração do MSI'; F = 'COMPILADOR' }
    "COMPILER_CHECK_PS2EXE"           = @{ T = 'Verificando módulo ps2exe...'; H = 'Aviso de verificação ps2exe'; F = 'COMPILADOR' }
    "COMPILER_INSTALL_PS2EXE"         = @{ T = 'ps2exe ausente. Tentando auto-reparo (Install-Module/winget)...'; H = 'Tentativa de auto-reparo ps2exe'; F = 'COMPILADOR' }
    "COMPILER_INSTALL_WIX"            = @{ T = 'WiX ausente. Tentando auto-reparo (winget)...'; H = 'Tentativa de auto-reparo WiX'; F = 'COMPILADOR' }
    "COMPILER_EXE_SUCCESS"            = @{ T = 'Executável gerado com sucesso: {0}'; H = 'Sucesso na geração de EXE com token de caminho'; F = 'COMPILADOR' }
    "COMPILER_WIX_NOT_FOUND"          = @{ T = 'WiX não encontrado. Tentando instalação via winget...'; F = 'COMPILADOR' }
    "COMPILER_WIX_FALLBACK"           = @{ T = 'Fallback do WiX Toolset falhou. Emitindo ZIP Portátil.'; F = 'COMPILADOR' }

    # ─────────────────────────────────────────────────────────────────────
    # SYSTEM & DEPENDENCIES (ADIÇÕES)
    # ─────────────────────────────────────────────────────────────────────
    "DEP_SQLITE_DOWNLOADING"          = @{ T = 'Baixando carga do SQLite...'; H = 'Início do download do SQLite em background'; F = 'SYSTEM' }
    "DEP_SQLITE_EXTRACTED"            = @{ T = 'Carga do SQLite extraída para o módulo Environment com sucesso.'; H = 'Sucesso na extração pós-download'; F = 'SYSTEM' }
    "DEP_BINARIES_MISSING"            = @{ T = '[SISTEMA] Módulo de binários não carregado.'; H = 'Falha na inicialização do módulo'; F = 'ERRO' }
    "DB_OFFLINE"                      = @{ T = 'Banco de Dados Offline.'; H = 'Perda de conectividade com o banco'; F = 'AVISO' }
    "SYS_MEM_CRITICAL"                = @{ T = 'Memória do host crítica (<20%). Forçando despejo de memória do banco.'; H = 'Gatilho de segurança por baixa memória'; F = 'PERF_WARN' }
    "SYS_ACCESS_DENIED_DRIVE"         = @{ T = 'Acesso Negado. Bloqueio de hardware em {0}'; H = 'Falha de acesso à unidade com token'; F = 'PRIV_FATAL' }

    # ─────────────────────────────────────────────────────────────────────
    # COMPILER & MSI (ADIÇÕES)
    # ─────────────────────────────────────────────────────────────────────
    "COMPILER_WIX_DOWNLOADING"        = @{ T = 'Baixando binários do WiX Toolset (Silencioso)...'; H = 'Download do WiX em background'; F = 'COMPILADOR' }
    "COMPILER_MSI_DOWNGRADE"          = @{ T = 'Uma versão mais recente do SCAPE já está instalada.'; H = 'Erro de downgrade do instalador MSI'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # NATIVE & KERNEL (ADIÇÕES)
    # ─────────────────────────────────────────────────────────────────────
    "NATIVE_LINUX_DIAG"               = @{ T = '[LINUX] Roteando para pipeline smartctl / fsck...'; H = 'Redirecionamento de diagnóstico Linux'; F = 'HINT' }
    "NATIVE_LINUX_ISOLATE"            = @{ T = '[LINUX] Roteando para pipeline nativa umount / dd...'; H = 'Redirecionamento de isolamento Linux'; F = 'HINT' }
    "NATIVE_JOURNAL_EXPORTED"         = @{ T = 'Journal exportado para {0}. Processando entradas...'; H = 'Sucesso na extração do USN Journal'; F = 'FSUTIL' }

    # ─────────────────────────────────────────────────────────────────────
    # BOOT & IGNITION SEQUENCE
    # ─────────────────────────────────────────────────────────────────────
    "ERR_ADMIN_REQUIRED"              = @{ T = 'Privilégios de Administrador são estritamente necessários.'; H = 'Erro de requisito de admin'; F = $null }
    "ERR_BOOT_SECTOR_READ"            = @{ T = 'Falha na leitura do Boot Sector.'; H = 'Erro de leitura de boot sector'; F = 'IO_FATAL' }
    "ERR_SUPERBLOCK_READ"             = @{ T = 'Falha na leitura do Superblock EXT.'; H = 'Erro de leitura de superblock EXT'; F = 'IO_FATAL' }
    "BOOT_FATAL_MATRIX"               = @{ T = 'Falha ao carregar matriz fundacional: {0}'; H = 'Fatal ao carregar matriz com token de erro'; F = 'FATAL' }
    "BOOT_PRESS_ENTER_EXIT"           = @{ T = 'Pressione ENTER para sair...'; H = 'Prompt de saída'; F = $null }
    "BOOT_FATAL_INTEROP"              = @{ T = 'Falha ao carregar matriz fundacional Interop ou de Idioma.'; H = 'Fatal ao carregar matriz Interop/Language'; F = 'FATAL' }
    "PROMPT_EXE_NAME"                 = @{ T = 'Nome de saída do executável (padrão: SCAPE.exe)'; H = 'Prompt de nome de EXE'; F = $null }
    "IO_RESILIENT_MISSING"            = @{ T = 'Módulo de I/O resiliente ausente.'; H = 'Erro de módulo I/O ausente'; F = $null }

    "SYS_BOOT_OK"                     = @{ T = 'Engine pronto. Idioma: {0} | Modo: {1}'; F = 'INFO' }
    "SYS_ASSET_WARN"                  = @{ T = '[{0}] Asset ''{1}'' ignorado ou falhou no carregamento.'; F = 'WARN' }

    "BOOT_INIT_MODULES"               = @{ T = 'Inicializando malha dinâmica de módulos PowerShell na memória...'; H = 'Início de inicialização de módulos'; F = 'BOOT_SEQ' }
    "BOOT_MODULE_LOADED"              = @{ T = "  [+] Nó do módulo '{0}' carregado com sucesso no tempo de execução."; H = 'Sucesso no carregamento de módulo com token de nome'; F = $null }
    "BOOT_MODULE_FAIL"                = @{ T = "[BOOT_CRITICAL] Falha ao carregar o nó do módulo '{0}': {1}"; H = 'Falha no carregamento de módulo com tokens nome/erro'; F = $null }
    "BOOT_IMPORT_FATAL"               = @{ T = '[BOOT_FATAL] Falha irrecuperável na arquitetura de importação de módulo: {0}'; H = 'Fatal de arquitetura de importação com token de erro'; F = $null }
    "BOOT_VERIFY_ENV"                 = @{ T = 'Verificando infraestrutura de hardware e executando rotinas de escalonamento de privilégio...'; H = 'Início de verificação de ambiente'; F = 'BOOT_SEQ' }
    "BOOT_PRIV_ELEVATED"              = @{ T = 'Acesso Concedido: SeBackupPrivilege & SeRestorePrivilege escalados com segurança.'; H = 'Sucesso na elevação de privilégios'; F = 'BOOT_SANCTUARY' }
    "BOOT_PRIV_FAIL"                  = @{ T = 'Falha no Escalonamento de Privilégio. O acesso a estruturas brutas travadas será negado.'; H = 'Falha na elevação de privilégios'; F = 'BOOT_SANCTUARY_ERR' }
    "BOOT_ENV_PARTIAL"                = @{ T = 'Subsistema central inicializado, mas encontrou erros parciais não fatais.'; H = 'Aviso de inicialização parcial'; F = 'BOOT_WARN' }
    "BOOT_SAMBA_AUTO"                 = @{ T = 'Cofre Samba autodetectado e engajado com segurança no ponto de montagem local {0}'; H = 'Sucesso no auto-mount Samba com token de unidade'; F = 'BOOT_NETWORK' }
    "BOOT_SAMBA_FAIL"                 = @{ T = 'Protocolo de autotravamento Samba falhou em proteger a conexão: {0}'; H = 'Falha no auto-mount Samba com token de erro'; F = 'BOOT_NETWORK' }
    "BOOT_READY"                      = @{ T = 'Motor Central SCAPE Offline e desanexado do hardware com segurança.'; H = 'Aviso de motor pronto/offline'; F = 'SYSTEM_STATE' }
    "BOOT_WELCOME"                    = @{ T = 'Bem-vindo ao SCAPE Recovery System - Motor Forense Avançado v1.0'; H = 'Banner de boas-vindas'; F = $null }
    "BOOT_ESC_ABORT"                  = @{ T = 'Pressione [ENTER] para aceitar o risco, ou [ESC] para abortar o boot com segurança.'; H = 'Prompt de aceitação de risco no boot'; F = $null }

    "IGNITE_INIT"                     = @{ T = 'Iniciando Sequência de Boot Dinâmica (v1.0.0)...'; H = 'Início da ignição'; F = 'SYSTEM' }
    "IGNITE_PILAR_LOAD"               = @{ T = 'Ativando Pilar Fundamental: {0}...'; H = 'Ativação de pilar com token de nome'; F = 'SYSTEM' }
    "IGNITE_PILAR_FAIL"               = @{ T = 'Falha crítica ao despertar pilar {0}: {1}'; H = 'Falha de pilar com tokens nome/erro'; F = 'FATAL' }
    "IGNITE_PILAR_MISSING"            = @{ T = "Pilar obrigatório '{0}' não encontrado no dicionário de Payloads!"; H = 'Fatal de pilar ausente com token de nome'; F = 'FATAL' }
    "IGNITE_MATRIX_VALIDATION"        = @{ T = 'Validando Matriz de Payloads...'; H = 'Início de validação de matriz'; F = 'SYSTEM' }
    "IGNITE_MODULE_MAPPED"            = @{ T = '  [+] Módulo mapeado para Deploy: {0}'; H = 'Módulo mapeado com token de nome'; F = $null }
    "IGNITE_DEPLOYER_INJECT"          = @{ T = 'Injetando motor da Fábrica...'; H = 'Aviso de injeção da fábrica'; F = 'SYSTEM' }
    "IGNITE_LOG_FAIL"                 = @{ T = 'Sistema de logs não responde após injeção.'; H = 'Falha de log pós-injeção'; F = $null }
    "IGNITE_DEPLOY_FAIL"              = @{ T = 'Falha ao iniciar Start-ScapeDeployment: {0}'; H = 'Falha no lançamento do deploy com token de erro'; F = 'FATAL' }
    "IGNITE_DEPLOYER_MISSING"         = @{ T = 'DeployerPayload (A Fábrica) não foi encontrado na memória!'; H = 'Fatal de deployer ausente'; F = 'FATAL' }

    # ─────────────────────────────────────────────────────────────────────
    # DEPLOYER PROCESS MANAGEMENT
    # ─────────────────────────────────────────────────────────────────────
    "DEPLOYER_PROCESS_CLEANUP"        = @{ T = 'Instâncias ativas detectadas. Encerrando processos para limpeza...'; H = 'Início de cleanup de processos'; F = 'DEPLOYER' }
    "DEPLOYER_PURGE_SUCCESS"          = @{ T = 'Arquitetura anterior removida com sucesso.'; H = 'Aviso de sucesso na purga'; F = 'DEPLOYER' }
    "DEPLOYER_PURGE_BUSY_WARN"        = @{ T = 'Diretório de saída está ocupado. Build antigo movido para caminho temporário: {0}'; H = 'Fallback de purga ocupada com token de caminho'; F = 'DEPLOYER' }

    # ─────────────────────────────────────────────────────────────────────
    # AUDIT & FORENSIC MANIFEST
    # ─────────────────────────────────────────────────────────────────────
    "AUDIT_MANIFEST_DEPLOY"           = @{ T = 'Manifesto Forense JSON implantado com segurança em: {0} [Status: {1}]'; H = 'Deploy de manifesto com tokens caminho/status'; F = 'AUDIT_SYSTEM' }
    "AUDIT_MANIFEST_FAIL"             = @{ T = 'Falha crítica ao gravar dados de manifesto/checksum JSON: {0}'; H = 'Falha na gravação de manifesto com token de erro'; F = 'AUDIT_FATAL' }
    "AUDIT_REPORT_GEN"                = @{ T = 'Relatório de Auditoria JSON Abrangente gerado de forma limpa em: {0}'; H = 'Sucesso na geração de relatório com token de caminho'; F = 'AUDIT_SYSTEM' }
    "AUDIT_REPORT_FAIL"               = @{ T = 'Falha crítica ao compilar o relatório de auditoria JSON final: {0}'; H = 'Falha na compilação de relatório com token de erro'; F = 'AUDIT_FATAL' }
    "AUDIT_INIT_OK"                   = @{ T = 'Ledger forense de auditoria inicializado com sucesso em: {0}'; H = 'Sucesso de inicialização do módulo de auditoria com token de caminho de log'; F = 'AUDIT_SYSTEM' }
    "AUDIT_INTEGRITY_VERIFIED"        = @{ T = 'VERIFIED_EXACT_MATCH'; H = 'Indicador de sucesso na verificação de integridade'; F = $null }
    "AUDIT_INTEGRITY_MISMATCH"        = @{ T = 'CRITICAL_SIZE_MISMATCH'; H = 'Indicador de erro de mismatch de integridade'; F = $null }
    "AUDIT_HASH_COMPUTED"             = @{ T = 'Checksum Criptográfico SHA256: {0}'; H = 'Exibição de hash com token de checksum'; F = 'AUDIT_HASH' }
    "COMPLIANCE_INIT_OK"              = @{ T = 'Motor de compliance online. Segmentos carregados: {0} | Algoritmo de hash: {1}.'; H = 'Sucesso de inicialização de compliance com contagem de segmentos e algoritmo'; F = 'COMPLIANCE' }
    "COMPLIANCE_MISSING"              = @{ T = 'Segmento de compliance [{0}] ausente ({1}). Algoritmo: {2}.'; H = 'Aviso de segmento de compliance ausente com segmento/motivo/algoritmo'; F = 'COMPLIANCE_WARN' }
    "COMPLIANCE_MISMATCH"             = @{ T = 'Mismatch de integridade no segmento [{0}] | Esperado: {1} | Atual: {2} | Algoritmo: {3}.'; H = 'Mismatch de hash de compliance com detalhes do segmento e hash'; F = 'COMPLIANCE_ERR' }
    "IO_BIT_ERROR"                    = @{ T = 'Operação bitwise resiliente de leitura/escrita falhou após esgotar orçamento de tentativas.'; H = 'Erro fatal de operação bitwise/resiliência'; F = 'IO_FATAL' }
    "LOG_ROTATED"                     = @{ T = 'Rotação de log concluída. Arquivado: {0} | Ativo: {1} | Rotação: {2}.'; H = 'Conclusão de rotação de logger com arquivo antigo/novo e contador'; F = 'LOGGER' }

    # ─────────────────────────────────────────────────────────────────────
    # ARCHIVE / CARVING ENGINE
    # ─────────────────────────────────────────────────────────────────────
    "ARCHIVE_ENUMERATING"             = @{ T = 'Enumerando nós de banco de dados para arquivos direcionados...'; H = 'Início de enumeração de archive'; F = 'ARCHIVE_ENGINE' }
    "ARCHIVE_BAR_TOTAL"               = @{ T = 'NÓS_DB_TOTAIS: {0} | MARCADOS_ATIVAMENTE: {1} | ERROS_CORRUPÇÃO: {2} | TAXA_SCAN: {3} nós/seg'; H = 'Barra de progresso de archive com tokens de estatísticas'; F = $null }
    "ARCHIVE_COMPLETE"                = @{ T = 'Ciclo de marcação direcionada do banco de dados concluído inteiramente.'; H = 'Conclusão de ciclo de archive'; F = 'ARCHIVE_ENGINE' }
    "ARCHIVE_NO_FILES"                = @{ T = 'Nenhum arquivo correspondente aos critérios encontrado para processar na seleção atual.'; H = 'Aviso de nenhum arquivo encontrado'; F = 'ARCHIVE_WARN' }

    "CARVE_NTFS_SIG"                  = @{ T = "Estrutura de registro 'FILE' válida do NTFS identificada no offset físico {0}"; H = 'Hit de assinatura NTFS com token de offset'; F = 'CARVE_HIT' }
    "CARVE_EXT4_SIG"                  = @{ T = 'Mágica de inode EXT4 válida (0xEF53/0xF30A) identificada no offset físico {0}'; H = 'Hit de assinatura EXT4 com token de offset'; F = 'CARVE_HIT' }
    "CARVE_BTRFS_SIG"                 = @{ T = 'Estrutura node/leaf BTRFS válida identificada no offset físico {0}'; H = 'Hit de assinatura BTRFS com token de offset'; F = 'CARVE_HIT' }
    "CARVE_ZFS_SIG"                   = @{ T = 'Mágica label/uberblock ZFS válida identificada no offset físico {0}'; H = 'Hit de assinatura ZFS com token de offset'; F = 'CARVE_HIT' }
    "CARVE_RECORD_ADDED"              = @{ T = 'Registro órfão bruto bufferizado com segurança para o motor de persistência SQL.'; H = 'Sucesso no buffer de registro'; F = 'CARVE_STATE' }

    # ─────────────────────────────────────────────────────────────────────
    # ERROR HANDLING & MISC
    # ─────────────────────────────────────────────────────────────────────
    "MANIFEST_NOT_FOUND"              = @{ T = 'Nó do manifesto não encontrado: {0}'; H = 'Nó de manifesto ausente com token de chave'; F = 'ORCH_FATAL' }
    "ROUTER_FATAL"                    = @{ T = '{0}'; H = 'Fatal genérico de router com token de erro'; F = 'ROUTER_FATAL' }
    "ROUTE_EXEC_FAIL"                 = @{ T = '{0}'; H = 'Falha de execução de rota com token de erro'; F = 'ROUTE_EXEC_FAIL' }
    "ORCH_MISSING_BINDING"            = @{ T = 'Vínculo do Controlador Ausente: {0}'; H = 'Vínculo ausente com token de chave'; F = 'ORCH_FATAL' }
    "CONFIRM_REGEX"                   = @{ T = '^[sS]'; H = 'Padrão regex para confirmação em português'; F = $null }

    "ERR_DRIVE_SELECTION_NONE"        = @{ T = 'Nenhum alvo de armazenamento montado viável detectado pelo subsistema WMI.'; H = 'Erro de nenhum drive detectado'; F = 'INPUT_ERR' }
    "ERR_DRIVE_LETTERS_EXHAUSTED"     = @{ T = 'NO_AVAILABLE_DRIVE_LETTERS: O sistema operacional esgotou o pool de letras de unidade A-Z.'; H = 'Erro de letras de unidade esgotadas'; F = 'OS_LIMIT_ERR' }
    "ERR_PATH_INVALID"                = @{ T = 'Caminho de diretório fornecido inválido, malformado ou totalmente inacessível.'; H = 'Erro de caminho inválido'; F = 'PATH_ERR' }
    "ERR_NO_ITEMS_SELECTED"           = @{ T = 'Nenhum item lógico ou árvores de diretório selecionadas para a sequência de extração.'; H = 'Erro de nenhuma seleção'; F = 'LOGIC_ERR' }
    "ERR_NO_STAGING"                  = @{ T = 'Pasta de staging local estritamente não definida. Você deve executar uma sequência de extração primeiro.'; H = 'Erro de staging ausente'; F = 'LOGIC_ERR' }
    "ERR_DEPENDENCY_FAIL"             = @{ T = 'Falha permanente na resolução de rede de dependência central após {0} tentativas estritas.'; H = 'Falha na resolução de dependência com token de contagem'; F = 'NET_FATAL' }
    "ERR_INTEGRITY_CHECK"             = @{ T = 'Verificação de integridade de segurança falhou gravemente. A dependência DLL baixada está ausente ou catastroficamente corrompida pós-extração.'; H = 'Falha na verificação de integridade'; F = 'BIN_FATAL' }
    "ERR_PERMISSION_DENIED"           = @{ T = 'Acesso negado forçadamente pelo SO. Você deve re-inicializar o terminal SCAPE como Administrador.'; H = 'Erro de permissão negada'; F = 'PRIV_FATAL' }
    "ERR_DISK_FULL"                   = @{ T = 'Espaço em disco físico insuficiente detectado na mídia de destino. Operação abortada com segurança para prevenir crash.'; H = 'Erro de disco cheio'; F = 'IO_FATAL' }
    "ERR_CORRUPTED_RECORD"            = @{ T = 'Registro estrutural MFT/Inode severamente corrompido detectado. Pulando o parsing para prevenir falha do motor.'; H = 'Aviso de registro corrompido'; F = 'PARSE_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # MISCELLANEOUS & PROMPTS
    # ─────────────────────────────────────────────────────────────────────
    "MISC_OR"                         = @{ T = ' ou '; H = 'Separador lógico OU'; F = $null }
    "MISC_PROGRESS"                   = @{ T = 'PROGRESSO_OPERACAO'; H = 'Indicador visual de atividade'; F = 'UI' }
    "MISC_PRESS_ENTER"                = @{ T = 'Pressione a tecla [ENTER] para retornar com segurança ao menu principal do Maestro...'; H = 'Prompt de retorno'; F = $null }
    "MISC_PRESS_ENTER_CONTINUE"       = @{ T = 'Pressione a tecla [ENTER] para confirmar e continuar a operação...'; H = 'Prompt de continuar'; F = $null }
    "MISC_PRESS_ENTER_TERMINAL"       = @{ T = 'Pressione a tecla [ENTER] para sair...'; H = 'Prompt de saída do terminal'; F = $null }
    "MISC_ABORT_PROMPT"               = @{ T = 'Pressione a tecla [ENTER] para abortar imediatamente a sequência atual...'; H = 'Prompt de abortar'; F = $null }
    "MISC_EXIT_CONFIRM"               = @{ T = 'PERIGO: Você tem certeza de que deseja sair do SCAPE Engine? Fluxos não salvos podem terminar. (s/N): '; H = 'Prompt de confirmação de saída'; F = $null }
    "MISC_DOWNLOAD_RETRY"             = @{ T = 'Conexão de download caiu. Protocolo de repetição acionado... ({0} tentativas seguras restantes)'; H = 'Retry de download com token de contagem'; F = 'NET_WARN' }
    "MISC_YES"                        = @{ T = 's'; H = 'Token de resposta sim'; F = $null }
    "MISC_NO"                         = @{ T = 'n'; H = 'Token de resposta não'; F = $null }
    "MISC_YES_NO"                     = @{ T = '(s/N): '; H = 'Prompt sim/não padrão minúsculo'; F = $null }
    "MISC_YES_NO_UPPER"               = @{ T = '(S/N): '; H = 'Prompt sim/não maiúsculo'; F = $null }
    "MISC_OPERATION_SUCCESS"          = @{ T = 'A pipeline da operação solicitada foi concluída com sucesso com zero erros fatais.'; H = 'Aviso de sucesso na operação'; F = 'SYS_OK' }
    "MISC_OPERATION_FAILED"           = @{ T = 'A pipeline da operação solicitada falhou. Por favor, revise os logs de exceção detalhados impressos acima.'; H = 'Aviso de falha na operação'; F = 'SYS_FAIL' }
    "MISC_WAITING"                    = @{ T = 'O sistema está aguardando liberação operacional...'; H = 'Status de espera'; F = $null }
    "MISC_CANCELLED"                  = @{ T = 'Operação intencionalmente cancelada por substituição do usuário.'; H = 'Aviso de cancelamento pelo usuário'; F = 'SYS_HALT' }
    "MISC_PRESS_ENTER_DEGRADED"       = @{ T = 'Pressione a tecla [ENTER] para logar a falha e tentar continuação em modo de motor DEGRADADO...'; H = 'Prompt de modo degradado'; F = $null }
    "MISC_ENTER_PATH_MANUALLY"        = @{ T = 'Auto-picker falhou. Por favor, insira o caminho de destino absoluto manualmente (ex: D:\BackupSeguro): '; H = 'Prompt de fallback manual de caminho'; F = $null }
    "MISC_ACCEPT_RISK"                = @{ T = 'Pressione a tecla [ENTER] para aceitar oficialmente o risco operacional e prosseguir forçadamente...'; H = 'Prompt de aceitação de risco'; F = $null }
    "MISC_LOG_AND_CONTINUE"           = @{ T = 'Pressione a tecla [ENTER] para gravar a falha no log e continuar forçadamente a compilação...'; H = 'Prompt de log e continuação'; F = $null }
    "MISC_PRESS_ENTER_EXIT"           = @{ T = 'Pressione a tecla [ENTER] para fechar o terminal e sair...'; H = 'Prompt de saída do terminal'; F = $null }
    "MISC_RESTART_STATE_MACHINE"      = @{ T = 'Pressione a tecla [ENTER] para reiniciar forçadamente a Máquina de Estados Maestro...'; H = 'Prompt de reinício da máquina de estados'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # PERFORMANCE METRICS
    # ─────────────────────────────────────────────────────────────────────
    "PERF_RAM_STRATEGY"               = @{ T = 'RAM validada disponível: {0} GB | Tamanho Alvo Estimado: {1} GB -> Estratégia de Alocação Atribuída: {2}'; H = 'Estratégia de RAM com tokens disponível/alvo/estratégia'; F = 'PERF_METRIC' }
    "PERF_THREAD_AUTO"                = @{ T = 'Auto-ajustando threads de transferência de dados dinamicamente para {0} com base no meio de destino analisado.'; H = 'Auto-ajuste de threads com token de contagem'; F = 'PERF_TUNE' }
    "PERF_LOW_MEM_WARNING"            = @{ T = 'Memória física extremamente baixa detectada no host. Forçando mudança da pipeline para modo DISK_SPOOL para prevenir crash por falta de memória.'; H = 'Aviso de memória baixa'; F = 'PERF_WARN' }
    "PERF_HIGH_IO_WARNING"            = @{ T = 'Carga I/O excepcionalmente alta registrada na controladora de armazenamento. Protocolos de estrangulamento automatizados engajados.'; H = 'Aviso de carga I/O alta'; F = 'PERF_WARN' }

    # ─────────────────────────────────────────────────────────────────────
    # DEPENDENCY MANAGEMENT
    # ─────────────────────────────────────────────────────────────────────
    "DEP_ARM64_FALLBACK"              = @{ T = 'DLL nativa ARM64 ausente. Utilizando fallback x64 (emulação).'; H = 'Aviso de fallback ARM64'; F = 'SQLITE' }
    "DEP_EXTRACT_SUCCESS"             = @{ T = 'Dependências nativas extraídas da matriz de memória com sucesso.'; H = 'Sucesso na extração de dependências'; F = 'SYSTEM' }
    "DEP_LOCAL_DETECTED"              = @{ T = 'Dependências detectadas localmente (DEV_MODE).'; H = 'Dependências locais detectadas'; F = 'SYSTEM' }
    "DEP_MISSING_ERROR"               = @{ T = 'ERRO: Arquivos não encontrados no disco e não embutidos na memória.'; H = 'Erro de dependências ausentes'; F = 'SQLITE' }
    "DEP_SIZE_MISMATCH"               = @{ T = 'Inconsistência no tamanho da DLL gerenciada após extração.'; H = 'Erro de mismatch de tamanho de DLL'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # CONFIGURATION VALUES
    # ─────────────────────────────────────────────────────────────────────
    "CONFIG_VAL_EFFICIENCY"           = @{ T = 'EFICIÊNCIA'; H = 'Modo do motor: Eficiência'; F = $null }
    "CONFIG_VAL_REDUNDANCY"           = @{ T = 'REDUNDÂNCIA'; H = 'Modo do motor: Redundância'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # WAIT / RETURN PROMPTS
    # ─────────────────────────────────────────────────────────────────────
    "WAIT_ENTER_CONTINUE"             = @{ T = 'Pressione ENTER para continuar...'; H = 'Prompt de espera para continuar'; F = $null }
    "WAIT_ENTER_ESC_PROMPT"           = @{ T = 'Pressione [ENTER] para prosseguir, ou [ESC] para cancelar.'; H = 'Prompt prosseguir/cancelar'; F = $null }
    "WAIT_ENTER_ACCEPT_RISK"          = @{ T = 'Pressione [ENTER] para aceitar o risco e continuar, ou [ESC] para abortar.'; H = 'Prompt aceitar risco/abortar'; F = $null }
    "WAIT_ENTER_RETURN"               = @{ T = 'Pressione ENTER para retornar...'; H = 'Prompt de espera para retornar'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # SYSTEM DETECTION
    # ─────────────────────────────────────────────────────────────────────
    "SYS_BARE_METAL"                  = @{ T = 'Bare Metal'; H = 'Indicador de host físico'; F = $null }
    "SYS_NA"                          = @{ T = 'N/A'; H = 'Indicador não aplicável'; F = $null }
    "SYS_VM_DETECTED"                 = @{ T = 'Maquina Virtual Detectada (Hypervisor: {0})'; H = 'Detecção de VM com token de hypervisor'; F = 'SYSTEM' }
    "SYS_HOST_DETECTED"               = @{ T = 'Host Fisico Detectado (Bare Metal)'; H = 'Detecção de bare metal'; F = 'SYSTEM' }

    # ─────────────────────────────────────────────────────────────────────
    # FORENSIC WALK / TRAVERSAL
    # ─────────────────────────────────────────────────────────────────────
    "FOR_MFT_WALK"                    = @{ T = 'Mapeando arvore MFT deterministicamente... Registro {0} / {1}'; H = 'Progresso de caminhada MFT com tokens atual/total'; F = $null }
    "FOR_EXT_WALK"                    = @{ T = 'Mapeando arvore Inode deterministicamente... Inode {0} / {1}'; H = 'Progresso de caminhada Inode com tokens atual/total'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # SAMBA / NETWORK MOUNT REMOVAL
    # ─────────────────────────────────────────────────────────────────────
    "SAMBA_UNMOUNT_ALL"               = @{ T = 'Removendo todas as unidades de rede...'; H = 'Início de desmontagem em massa'; F = $null }
    "SAMBA_UNMOUNT_SINGLE"            = @{ T = 'Removendo unidade mapeada {0}...'; H = 'Desmontagem única com token de unidade'; F = $null }
    "SAMBA_SELECT_IP"                 = @{ T = 'MÚLTIPLOS HOSTS SMB DETECTADOS. SELECIONE O ALVO:'; H = 'Seleção de múltiplos hosts'; F = $null }
    "SAMBA_MGR_TITLE"                 = @{ T = 'GERENCIAMENTO DE UNIDADES DE REDE'; H = 'Título do gerenciador de montagens'; F = $null }
    "SAMBA_MGR_REMOVE_ALL"            = @{ T = '[ DESMONTAR TODAS AS UNIDADES DE REDE ]'; H = 'Opção de menu remover todas'; F = $null }
    "SAMBA_MGR_NONE"                  = @{ T = 'Nenhuma unidade de rede ativa detectada.'; H = 'Aviso de nenhuma montagem'; F = $null }
    "SAMBA_MGR_REMOVED"               = @{ T = 'Unidade {0} ({1}) desmontada com sucesso.'; H = 'Sucesso na desmontagem com tokens unidade/caminho'; F = $null }

    # ─────────────────────────────────────────────────────────────────────
    # NATIVE BRIDGE / SAFETY CONTROLS
    # ─────────────────────────────────────────────────────────────────────
    "ERR_SYSTEM_DRIVE_LOCK"           = @{ T = 'Operação bloqueada: Impossível isolar ou reparar o disco ativo do Sistema.'; H = 'Erro de proteção do disco do sistema'; F = 'ERRO_SEGURANÇA' }
    "NET_NATIVE_ISOLATION_OK"         = @{ T = 'Drive isolado com sucesso. Acesso exclusivo DASD garantido.'; H = 'Sucesso no isolamento de disco'; F = 'DISKPART' }
    "NET_NATIVE_JOURNAL_START"        = @{ T = 'Colhendo USN Journal do NTFS para deleções recentes...'; H = 'Início de colheita de journal'; F = 'FSUTIL' }
    "UI_NATIVE_HYBRID_RUNNING"        = @{ T = 'Scan dual SCAPE + WinFR em progresso. Aguarde...'; H = 'Scan híbrido em progresso'; F = 'HÍBRIDO' }
    "UI_NATIVE_DIAG_FAIL"             = @{ T = 'O hardware reporta falhas críticas. Recomenda-se I/O mínimo.'; H = 'Falha no diagnóstico de hardware'; F = 'ALERTA_STORDIAG' }

    # ─────────────────────────────────────────────────────────────────────
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

    # ─────────────────────────────────────────────────────────────────────
    "TOOL_DISKPART"                   = @{ T = 'DISKPART (Isolamento & Particionamento)'; H = 'Forçar offline ou gerenciar partições'; F = '1' }
    "TOOL_DISKPART_DESC"              = @{ T = 'Força o drive offline para evitar interferência do SO. AVISO: Desconecta todas as sessões ativas.'; H = 'Dica de aviso DiskPart'; F = 'WARN' }
    "TOOL_CHKDSK"                     = @{ T = 'CHKDSK (Reparo de Sistema de Arquivos)'; H = 'Escanear e corrigir erros lógicos do sistema de arquivos'; F = '2' }
    "TOOL_CHKDSK_DESC"                = @{ T = 'Varredura profunda de estruturas de metadados. Pode iniciar operações de disco demoradas.'; H = 'Dica ChkDsk'; F = 'LOG' }
    "TOOL_WINFR"                      = @{ T = 'WINFR (Microsoft File Recovery)'; H = 'Motor de recuperação profunda baseado em assinatura'; F = '3' }
    "TOOL_WINFR_DESC"                 = @{ T = 'Utiliza algoritmos de recuperação da Microsoft. Requer drive de destino para extração segura.'; H = 'Dica WinFR'; F = 'LOG' }
    "TOOL_FSUTIL"                     = @{ T = 'FSUTIL (Coleta de USN Journal)'; H = 'Extrair logs de deleções recentes do NTFS'; F = '4' }
    "TOOL_FSUTIL_DESC"                = @{ T = 'Analisa o USN journal do NTFS para recuperar entradas de metadados de arquivos deletados recentemente.'; H = 'Dica Fsutil'; F = 'LOG' }
    "TOOL_STORDIAG"                   = @{ T = 'STORDIAG (Diagnóstico de Hardware)'; H = 'Gerar relatório abrangente de integridade de armazenamento'; F = '5' }
    "TOOL_STORDIAG_DESC"              = @{ T = 'Executa diagnósticos de armazenamento integrados. Gera relatório detalhado de telemetria de hardware.'; H = 'Dica Stordiag'; F = 'LOG' }
    "TOOL_SFC"                        = @{ T = 'SFC (Verificador de Arquivos do Sistema)'; H = 'Verificar e restaurar arquivos corrompidos do Windows'; F = '6' }
    "TOOL_DISM"                       = @{ T = 'DISM (Gerenciamento de Imagem de Implantação)'; H = 'Reparar imagem e componentes do Windows'; F = '7' }
    "TOOL_EVENTVWR"                   = @{ T = 'EVENTVWR (Visualizador de Eventos)'; H = 'Acessar logs de eventos do sistema para forense'; F = '8' }
    "TOOL_FILEHASH"                   = @{ T = 'FILEHASH (Geração de Checksum)'; H = 'Calcular hashes para integridade de arquivos'; F = '9' }
    "TOOL_NATIVE_FORENSICS"           = @{ T = 'FERRAMENTAS NATIVAS (Embutidas no Windows)'; H = 'Acessar ferramentas de sistema integradas'; F = 'N' }
    "TOOL_THIRDPARTY_FORENSICS"       = @{ T = 'FERRAMENTAS DE TERCEIROS (Sysinternals e Externas)'; H = 'Acessar utilitários forenses externos especializados'; F = 'T' }
    "TOOL_WINDIRSTAT"                 = @{ T = 'WINDIRSTAT (Uso de Disco e Limpeza)'; H = 'Estatísticas visuais de uso de disco e limpeza'; F = 'W' }
    "TOOL_PROCEXP"                    = @{ T = 'PROCESS EXPLORER (Sysinternals)'; H = 'Gerenciamento e rastreamento avançado de processos'; F = 'P' }
    "TOOL_AUTORUNS"                   = @{ T = 'AUTORUNS (Sysinternals)'; H = 'Gerenciar programas e serviços de inicialização automática'; F = 'A' }
    "TOOL_EVERYTHING"                 = @{ T = 'EVERYTHING (Voidtools)'; H = 'Mecanismo de busca instantânea de arquivos e pastas'; F = 'E' }

    # ─────────────────────────────────────────────────────────────────────
    # LOGGING & TELEMETRY
    # ─────────────────────────────────────────────────────────────────────
    "LOG_INFO"                        = @{ T = 'INFO_MENSAGEM_OPERACIONAL'; H = 'Mensagem operacional padrão'; F = 'INFO' }
    "LOG_DEBUG"                       = @{ T = 'DEBUG_RASTRO_DIAGNOSTICO'; H = 'Rastro de diagnóstico profundo'; F = 'DEBUG' }
    "LOG_WARN"                        = @{ T = 'AVISO_ANOMALIA_EXECUCAO'; H = 'Anomalia de execução não-fatal'; F = 'WARN' }
    "LOG_ERR"                         = @{ T = 'ERRO_FALHA_OPERACIONAL'; H = 'Falha em operação específica'; F = 'ERROR' }
    "LOG_FATAL"                       = @{ T = 'FATAL_PARADA_MOTOR'; H = 'Interrupção crítica do motor'; F = 'FATAL' }
    "LOG_SYSTEM"                      = @{ T = 'SISTEMA_MENSAGEM_NUCLEO'; H = 'Mensagem de núcleo nível kernel'; F = 'SYSTEM' }
    "LOG_METRIC"                      = @{ T = 'METRICA_TELEMETRIA_PERF'; H = 'Dados de telemetria de desempenho'; F = 'METRIC' }
    "LOG_TRACE"                       = @{ T = 'RASTRO_NIVEL_INSTRUCAO'; H = 'Rastreamento de nível de instrução'; F = 'TRACE' }

    # ─────────────────────────────────────────────────────────────────────
    # FILE SYSTEMS
    # ─────────────────────────────────────────────────────────────────────
    "FS_NTFS"                         = @{ T = 'SISTEMA_ARQUIVOS_NTFS'; H = 'Sistema de arquivos New Technology (NTFS)'; F = 'FS' }
    "FS_APFS"                         = @{ T = 'CONTEINER_APPLE_APFS'; H = 'Sistema de arquivos Apple (APFS)'; F = 'FS' }
    "FS_EXT4"                         = @{ T = 'LINUX_NATIVO_EXT4'; H = 'Sistema de arquivos Fourth Extended (EXT4)'; F = 'FS' }
    "FS_BTRFS"                        = @{ T = 'NODO_B_TREE_BTRFS'; H = 'Sistema de arquivos B-Tree (BTRFS)'; F = 'FS' }
    "FS_ZFS"                          = @{ T = 'POOL_ZETTABYTE_ZFS'; H = 'Sistema de arquivos Zettabyte (ZFS)'; F = 'FS' }
    "FS_REFS"                         = @{ T = 'RESILIENTE_REFS'; H = 'Sistema de arquivos resiliente (ReFS)'; F = 'FS' }
    "FS_XFS"                          = @{ T = 'EXTENDIDO_XFS'; H = 'Sistema de arquivos estendido (XFS)'; F = 'FS' }
    "FS_HFS"                          = @{ T = 'HIERARQUICO_HFS'; H = 'Sistema de arquivos hierárquico (HFS)'; F = 'FS' }
    "FS_HFSX"                         = @{ T = 'HFSX_CASE_SENSITIVE'; H = 'HFS Plus (Sensível a maiúscu(exFAT)'; F = 'FS' }
    "FS_EXFAT"                        = @{ T = 'TABELA_FLASH_EXFAT'; H = 'Tabela de alocação de arquivos estendida (exFAT)'; F = 'FS' }
    "FS_FAT32"                        = @{ T = 'LEGADO_FAT32'; H = 'Tabela de alocação de arquivos legada (FAT32)'; F = 'FS' }
    "FS_UDF"                          = @{ T = 'FORMATO_UNIVERSAL_UDF'; H = 'Formato de disco universal (Óptico)'; F = 'FS' }
    "FS_JFS"                          = @{ T = 'JOURNALED_JFS'; H = 'Sistema de arquivos Journaled (IBM)'; F = 'FS' }
    "FS_F2FS"                         = @{ T = 'F2FS_FLASH_NAND'; H = 'Sistema de arquivos flash NAND (F2FS)'; F = 'FS' }
    "FS_ISO9660"                      = @{ T = 'ISO9660_CD_ROM'; H = 'Padrão de sistema de arquivos de CD-ROM'; F = 'FS' }
    "FS_PART_TABLE"                   = @{ T = 'PARTITION_TABLE_STRUCT'; H = 'Estrutura de tabela de partições'; F = 'META' }
    "FS_DISK_IMAGE"                   = @{ T = 'VIRTUAL_DISK_IMAGE'; H = 'Container de imagem de disco (VMDK/VHDX/DMG)'; F = 'VIRT' }

    # ─────────────────────────────────────────────────────────────────────
    # HARDWARE & TOPOLOGY
    # ─────────────────────────────────────────────────────────────────────
    "HW_CPU"                          = @{ T = 'UNIDADE_PROCESSAMENTO_CPU'; H = 'Unidade Central de Processamento'; F = 'HW' }
    "HW_RAM"                          = @{ T = 'MEMORIA_RAM_VOLATIL'; H = 'Memória volátil do sistema'; F = 'HW' }
    "HW_HDD"                          = @{ T = 'DISCO_MECANICO_HDD'; H = 'Armazenamento mecânico'; F = 'HW' }
    "HW_SSD"                          = @{ T = 'ESTADO_SOLIDO_SSD'; H = 'Armazenamento de estado sólido'; F = 'HW' }
    "HW_NVME"                         = @{ T = 'EXPRESSO_NVME'; H = 'Armazenamento expresso de alta velocidade'; F = 'HW' }
    "HW_USB"                          = @{ T = 'DISCO_EXTERNO_USB'; H = 'Armazenamento USB (Universal Serial Bus)'; F = 'HW' }
    "HW_GPU"                          = @{ T = 'UNIDADE_GRAFICA_GPU'; H = 'Unidade de Processamento Gráfico'; F = 'HW' }

    # ─────────────────────────────────────────────────────────────────────
    # STATUS & ENGINE STATES
    # ─────────────────────────────────────────────────────────────────────
    "STATUS_SUCCESS"                  = @{ T = 'SUCESSO_OPERACAO'; H = 'Operação concluída sem erros'; F = 'OK' }
    "STATUS_UNKNOWN"                  = @{ T = 'ESTADO_DESCONHECIDO'; H = 'Objeto ou estado não identificado'; F = 'WARN' }
    "STATUS_BUSY"                     = @{ T = 'PROCESSAMENTO_ATIVO'; H = 'Fluxo de E/S ativamente engajado'; F = 'PROC' }

    # ─────────────────────────────────────────────────────────────────────
    # METADATA LABELS
    # ─────────────────────────────────────────────────────────────────────
    "META_ACCESSED"                   = @{ T = 'TIMESTAMP_ACESSO'; H = 'Timestamp de último acesso'; F = 'META' }
    "META_CREATED"                    = @{ T = 'TIMESTAMP_CRIACAO'; H = 'Timestamp de criação'; F = 'META' }
    "META_MODIFIED"                   = @{ T = 'TIMESTAMP_MODIFICACAO'; H = 'Timestamp de última modificação'; F = 'META' }
    "META_MFT_CHANGED"                = @{ T = 'REGISTRO_MFT_ALTERADO'; H = 'Timestamp de alteração de registro MFT'; F = 'META' }
    "META_FILENAME"                   = @{ T = 'NOME_ARQUIVO_FISICO'; H = 'Nome no meio de armazenamento'; F = 'META' }
    "META_PID"                        = @{ T = 'ID_PROCESSO'; H = 'Identificador de Processo do Sistema'; F = 'SYS' }
    "META_OFFSET"                     = @{ T = 'OFFSET_FISICO'; H = 'Offset de bytes brutos no disco'; F = 'DASD' }

    # ─────────────────────────────────────────────────────────────────────
    # DOMAINS & MODULES
    # ─────────────────────────────────────────────────────────────────────
    "DOMAIN_ANALYSIS"                 = @{ T = 'SUBSISTEMA_ANALISE'; H = 'Motor de análise central'; F = 'SYS' }
    "DOMAIN_PARSING"                  = @{ T = 'PARSING_METADADOS'; H = 'Processamento determinístico de registros'; F = 'SYS' }
    "DOMAIN_ARCHAEOLOGY"              = @{ T = 'MODO_ARQUEOLOGIA'; H = 'Carving profundo de setores brutos'; F = 'SYS' }
    "DOMAIN_HARVESTER"                = @{ T = 'MOTOR_HARVESTER'; H = 'Motor de extração em lote'; F = 'SYS' }
    "DOMAIN_INFRA"                    = @{ T = 'CAMADA_INFRAESTRUTURA'; H = 'Camada de suporte do sistema'; F = 'SYS' }

    # ─────────────────────────────────────────────────────────────────────
    # ALTERNATIVAS DE CAPACIDADE DO TERMINAL
    # ─────────────────────────────────────────────────────────────────────
    "CAP_MENU_TITLE"                  = @{ T = 'CONFIGURAÇÕES DE CAPACIDADE DO TERMINAL'; H = 'Título do menu de capacidades do terminal'; F = 'UI' }
    "CAP_TRUECOLOR"                   = @{ T = 'TrueColor (RGB de 24 bits)'; H = 'Ativa suporte a cores reais de 24 bits. Desative para reverter à paleta ANSI de 16 cores.'; F = 'UI' }
    "CAP_HYPERLINKS"                  = @{ T = 'Hiperlinks (OSC 8)'; H = 'Ativa links clicáveis no terminal. Requer um emulador de terminal moderno.'; F = 'UI' }
    "CAP_BRACKETEDPASTE"              = @{ T = 'Modo de Colagem com Colchetes'; H = 'Distingue texto colado de entrada digitada. Previne a execução acidental.'; F = 'UI' }
    "CAP_MOUSETRACKING"               = @{ T = 'Rastreamento de Mouse'; H = 'Ativa eventos de clique e movimento do mouse para interação com a UI.'; F = 'UI' }
    "CAP_ALTERNATESCREEN"             = @{ T = 'Buffer de Tela Alternativo'; H = 'Usa um buffer de tela separado para TUIs em tela cheia. Preserva o histórico do shell.'; F = 'UI' }
    "CAP_FOCUSEVENTS"                 = @{ T = 'Eventos de Foco (In/Out)'; H = 'Detecta quando o terminal ganha ou perde o foco.'; F = 'UI' }
    "CAP_KITTYKEYBOARD"               = @{ T = 'Protocolo de Teclado Kitty'; H = 'Protocolo de teclado aprimorado para combinações de teclas avançadas. Experimental.'; F = 'UI' }
    "CAP_SIXELGRAPHICS"               = @{ T = 'Gráficos Sixel'; H = 'Exibe gráficos de bitmap inline. Requer um terminal compatível com Sixel.'; F = 'UI' }
    "CAP_CSIUKEYBOARD"                = @{ T = 'Protocolo de Teclado CSIu'; H = 'Protocolo moderno de entrada de teclado para melhor tratamento de teclas modificadoras.'; F = 'UI' }
    "CAP_FALLBACK256"                 = @{ T = 'Permitir fallback de 256 cores'; H = 'Usa a paleta de 256 cores quando TrueColor não estiver disponível.'; F = 'UI' }
    "CAP_FALLBACK16"                  = @{ T = 'Permitir fallback de 16 cores'; H = 'Usa a paleta ANSI de 16 cores quando a de 256 cores não estiver disponível.'; F = 'UI' }

    "MENU_MAIN_RECOVERY"              = @{ T = 'MOTOR DE RECUPERAÇÃO'; H = 'Painel de fluxo de recuperação completo do SCAPE.'; F = '6' }
    "MENU_RECOVERY_TITLE"             = @{ T = 'MOTOR DE RECUPERAÇÃO DO SISTEMA & FORENSE'; H = 'Título para o menu de recuperação'; F = 'UI' }
    "RC_BITWISE_TAGGING"              = @{ T = 'MARCAÇÃO BITWISE'; H = 'Menu de operações bitwise'; F = 'A' }
    "RC_TOPOLOGY_SCAN"                = @{ T = 'VARREDURA DE TOPOLOGIA'; H = 'Escanear topologia'; F = 'T' }
    "RC_BATCH_PROCESSING"             = @{ T = 'PROCESSAMENTO EM LOTE'; H = 'Operações em lote'; F = 'B' }
    "RC_TARGET_ARCHAEOLOGY"           = @{ T = 'ARQUEOLOGIA DE ALVO'; H = 'Recuperação profunda'; F = 'R' }
    "RC_FILE_LABORATORY"              = @{ T = 'LABORATÓRIO DE ARQUIVOS'; H = 'Análise de arquivos'; F = 'L' }
    "RC_FORENSIC_TOOLS"               = @{ T = 'FERRAMENTAS FORENSES'; H = 'Menu de ferramentas forenses'; F = 'F' }
    "RC_ROBOCOPY_ENGINE"              = @{ T = 'MOTOR ROBOCOPY'; H = 'Menu do motor robocopy'; F = 'E' }
    "RC_TELEMETRY_SCAN"               = @{ T = 'VARREDURA DE TELEMETRIA'; H = 'Varredura de telemetria de hardware'; F = 'S' }
    "RC_CLOUD_SYNC"                   = @{ T = 'CLOUD SYNC'; H = 'Subsistema de sincronização em nuvem'; F = '7' }
}