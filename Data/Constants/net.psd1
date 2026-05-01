@{
    Segment = @{
        Name = "net"
        Version = "1.0.0"
        Description = "Network connectivity, SMB/CIFS, and remote acquisition constants"
        Dependencies = @("core", "behavior")
        HashSHA256 = "PLACEHOLDER_NET_HASH"
    }

    PROTOCOLS = @{
        SMB_PORT      = 445
        TIMEOUT_MS    = 100
        SUBNET_MAX    = 254
        DEFAULT_SHARE = "public"
    }

    MAPPING = @{
        DRIVE_LETTERS = @("Z","Y","X","W","V","U","T","S","R","Q","P","O","N","M","L","K","J","I","H","G","F","E","D")
        UNC_PREFIX    = "\\"
        SHARE_SEP     = "\"
    }

    CREDENTIALS = @{
        DOMAIN_FMT    = "{0}\{1}"       # Formato DOMAIN\user
        UPN_FMT       = "{0}@{1}"       # Formato user@domain
        ANON_USER     = "anonymous"
        GUEST_USER    = "guest"
    }

    TRANSFER = @{
        MAX_RETRIES      = 3
        RETRY_DELAY_MS   = 500
        CHUNK_SIZE_BYTES = 1048576      # 1 MB chunks para transferência de rede
        KEEPALIVE_SEC    = 30
        BANDWIDTH_LIMIT_BPS = 0         # 0 = ilimitado
    }

    DISCOVERY = @{
        PING_TIMEOUT_MS    = 80
        ARP_CACHE_TTL_SEC  = 300
        NETBIOS_ENABLED    = $true
        SSDP_ENABLED       = $false
    }
}