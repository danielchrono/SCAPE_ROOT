@{
    Segment = @{
        Name = "compliance"
        Version = "1.0.0"
        Description = "Security policies, cryptographic standards, audit logging, and regulatory constants"
        Dependencies = @("core")
        HashSHA256 = "PLACEHOLDER_COMPLIANCE_HASH"
    }

    CRYPTO = @{
        DEFAULT_HASH       = "SHA256"
        DEFAULT_ENCRYPTION = "AES"
        AES_KEY_SIZE       = 256
        AES_BLOCK_SIZE     = 128
        PBKDF2_ITERATIONS  = 10000
        SALT_LENGTH        = 32
        IV_LENGTH          = 16
    }

    SIGNATURES = @{
        # Assinaturas textuais de artefatos criptográficos
        X509_CERT_BEGIN = "-----BEGIN CERTIFICATE-----"
        X509_CERT_END   = "-----END CERTIFICATE-----"
        PRIV_KEY_BEGIN  = "-----BEGIN PRIVATE KEY-----"
        PRIV_KEY_END    = "-----END PRIVATE KEY-----"
        RSA_PRIV_BEGIN  = "-----BEGIN RSA PRIVATE KEY-----"
        RSA_PRIV_END    = "-----END RSA PRIVATE KEY-----"
        SSH_PUB_KEY     = "ssh-rsa AAAAB3"
        PGP_PUB_BLOCK   = "-----BEGIN PGP PUBLIC KEY BLOCK-----"
        GPG_ARMORED_START = "-----BEGIN PGP MESSAGE-----"
    }

    AUDIT = @{
        LOG_LEVELS = @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 }
        DEFAULT_LEVEL = 1
        MAX_LOG_SIZE_MB = 100
        ROTATION_COUNT = 5
        TIMESTAMP_FORMAT = "yyyy-MM-ddTHH:mm:ss.fffZ"
        HASH_ALGORITHM = "SHA256"
        LOG_IMMUTABLE = $true
    }

    STANDARDS = @{
        NIST_800_88      = $true   # Conformidade com sanitização de mídia
        FIPS_140_2       = $false  # Validação de módulo criptográfico
        CHAIN_OF_CUSTODY = $true   # Forçar rastreamento de evidência
        WRITE_BLOCKER    = $true   # Exigir write-blocker hardware para aquisição
    }

    INTEGRITY = @{
        MANIFEST_HASH_ALG = "SHA256"
        SEGMENT_VERIFY_ON_LOAD = $true
        ANTI_TAMPER_ENABLED    = $true
        SIGNATURE_CHECK_FREQ   = 100  # Verificar a cada N operações
        SEAL_EVIDENCE_ON_CLOSE = $true
    }

    ACCESS = @{
        REQUIRE_ELEVATION    = $true
        LOG_ALL_ACCESSES     = $true
        SESSION_TIMEOUT_MIN  = 30
        MAX_FAILED_AUTH      = 3
        LOCKOUT_DURATION_MIN = 15
    }
}