<#
.SYNOPSIS
    Domain: Extensions
    Module: Scape.Extensions.Database.Core
    Architecture: Zero-hardcode SQLite persistence engine. Transactional bulk writer and path resolver.
#>
#Requires -Version 5.1

$Script:C = $null          # Cached constants
$Script:Conn = $null       # Active SQLite Connection
$Script:DbPath = $null     # Active Database Path

function Initialize-ScapeDatabaseEngine {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $Script:C = @{
        DB      = Get-ScapeConstant -Path "network::DB" -Fallback @{}
        DDL     = Get-ScapeConstant -Path "network::DDL" -Fallback @{}
        LIMIT   = Get-ScapeConstant -Path "system::LIMITS" -Fallback @{}
        FS      = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
        Carving = Get-ScapeConstant -Path "storage::SIGNATURES" -Fallback @{}
    }

    $TypeName = "System.Data.SQLite.SQLiteConnection"
    if (-not ([System.Management.Automation.PSTypeName]$TypeName).Type) {
        try {
            $dll = Join-Path -Path $PSScriptRoot -ChildPath "..\..\1_System\Environment\System.Data.SQLite.dll"
            if (Test-Path -LiteralPath $dll) {
                [System.Reflection.Assembly]::LoadFile($dll) | Out-Null
            }
            else {
                throw "SQLite interop wrapper not found at $dll"
            }
        }
        catch {
            if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                Publish-ScapeEvent -Type "LOG_FATAL" -Payload @{ Action = "LogLine"; Key = "DB_ENGINE_LOAD_FAIL"; Args = @($_.Exception.Message) }
            }
            return $false
        }
    }

    $Script:C.DB.NTFS_SIG_BYTES = [System.Text.Encoding]::ASCII.GetBytes("FILE")

    if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
        Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "DB_ENGINE_INITIALIZED"; Severity = "LOG_INFO" }
    }
    return $true
}

function Open-ScapeSQLiteConnection {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][string]$DatabasePath)

    try {
        $timeout = if ($null -ne $Script:C.DB.BUSY_TIMEOUT) { $Script:C.DB.BUSY_TIMEOUT } else { 5000 }
        $connStr = ($Script:C.DB.CONN_STR_FMT -f $DatabasePath, $timeout)

        $conn = [System.Data.SQLite.SQLiteConnection]::new($connStr)
        $conn.Open()

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = if ($null -ne $Script:C.DB.PRAGMA_INIT) { $Script:C.DB.PRAGMA_INIT } else { "PRAGMA synchronous = OFF; PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;" }
        $cmd.ExecuteNonQuery() | Out-Null
        $cmd.Dispose()

        $Script:Conn = $conn
        $Script:DbPath = $DatabasePath
        return @{ Success = $true; Error = $null }
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_Open" }
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Invoke-ScapeDBSchema {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][string]$DatabasePath)

    $openRes = Open-ScapeSQLiteConnection -DatabasePath $DatabasePath
    if (-not $openRes.Success) { return $openRes }

    try {
        $cmd = $Script:Conn.CreateCommand()
        $tables = @(
            ($Script:C.DB.TABLE_SESSION -replace '^$', 'ScapeSession'),
            ($Script:C.DB.TABLE_MFT -replace '^$', 'ShadowMFT'),
            ($Script:C.DB.TABLE_UNIV -replace '^$', 'UniversalMetadata'),
            ($Script:C.DB.TABLE_FRAG -replace '^$', 'FragmentMap')
        )

        $idxVolFrn = ($Script:C.DB.IDX_MFT_VOL_FRN -replace '^$', 'idx_shdw_vol_frn')
        $idxPar = ($Script:C.DB.IDX_MFT_PAR -replace '^$', 'idx_shdw_par')
        $idxVolObj = ($Script:C.DB.IDX_UNIV_VOL_OBJ -replace '^$', 'idx_univ_vol_obj')
        $idxLookup = ($Script:C.DB.IDX_FRAG_LOOKUP -replace '^$', 'idx_frag_lookup')

        $ddlMft = $Script:C.DDL.MFT -replace '\{IDX_VOL_FRN\}', $idxVolFrn -replace '\{IDX_PAR\}', $idxPar
        $ddlUniv = $Script:C.DDL.UNIV -replace '\{IDX_VOL_OBJ\}', $idxVolObj -replace '\{IDX_PAR\}', $idxPar
        $ddlFrag = $Script:C.DDL.FRAG -replace '\{IDX_LOOKUP\}', $idxLookup
        $ddlSess = $Script:C.DDL.SESSION

        foreach ($tbl in $tables) {
            $cmd.CommandText = switch ($tbl) {
                ($Script:C.DB.TABLE_SESSION) { $ddlSess -f $tbl }
                ($Script:C.DB.TABLE_MFT) { $ddlMft -f $tbl }
                ($Script:C.DB.TABLE_UNIV) { $ddlUniv -f $tbl }
                ($Script:C.DB.TABLE_FRAG) { $ddlFrag -f $tbl }
            }
            if (-not [string]::IsNullOrWhiteSpace($cmd.CommandText)) {
                $cmd.ExecuteNonQuery() | Out-Null
            }
        }
        $cmd.Dispose()
        return @{ Success = $true; Error = $null }
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_Schema" }
        return @{ Success = $false; Error = $_.Exception.Message }
    }
    finally {
        Close-ScapeSQLiteConnection
    }
}

function Export-ScapeRecordsToDB {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[object]]$Records,
        [Parameter(Mandatory = $true)][string]$VolumeSerial
    )

    if (-not $Script:Conn -or $Records.Count -eq 0) {
        return @{ Success = $false; Count = 0; Error = "NO_CONNECTION_OR_DATA" }
    }

    $trans = $null
    $count = 0

    try {
        $trans = $Script:Conn.BeginTransaction()

        $cmdMft = _PrepareDbCommand -Query ($Script:C.DB.QUERY_INS_MFT -f $Script:C.DB.TABLE_MFT) -Trans $trans
        $cmdUniv = _PrepareDbCommand -Query ($Script:C.DB.QUERY_INS_UNIV -f $Script:C.DB.TABLE_UNIV) -Trans $trans
        $cmdFrag = _PrepareDbCommand -Query ($Script:C.DB.QUERY_INS_FRAG -f $Script:C.DB.TABLE_FRAG) -Trans $trans

        foreach ($rec in $Records) {
            $data = if ($rec -is [PSCustomObject] -and $null -ne $rec.RawRecord) { $rec.RawRecord } else { $rec }

            $sigMatch = $false
            if ($data -is [byte[]] -and $data.Length -ge 4) {
                if ($data[0] -eq 0x46 -and $data[1] -eq 0x49 -and $data[2] -eq 0x4C -and $data[3] -eq 0x45) {
                    $sigMatch = $true
                }
            }

            if ($sigMatch) {
                _InsertNtfsRecord -Cmd $cmdMft -CmdFrag $cmdFrag -VolumeSerial $VolumeSerial -Data $data -Trans $trans
            }
            else {
                $offset = if ($rec -is [PSCustomObject] -and $null -ne $rec.Offset) { $rec.Offset } else { 0 }
                $lcn = if ($rec -is [PSCustomObject] -and $null -ne $rec.LcnStart) { $rec.LcnStart } else { 0 }
                _InsertUniversalRecord -Cmd $cmdUniv -CmdFrag $cmdFrag -VolumeSerial $VolumeSerial -Data $data -Offset $offset -Lcn $lcn -Trans $trans
            }
            $count++
        }
        $trans.Commit()

        # Libera os comandos cacheados após o commit
        $cmdMft.Dispose(); $cmdUniv.Dispose(); $cmdFrag.Dispose()

        return @{ Success = $true; Count = $count; Error = $null }
    }
    catch {
        if ($null -ne $trans) { try { $trans.Rollback() } catch {} }
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_Export" }
        return @{ Success = $false; Count = 0; Error = $_.Exception.Message }
    }
}

function Resolve-ScapeFilePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][long]$ParentID,
        [Parameter(Mandatory = $true)][string]$VolumeSerial
    )

    if (-not $Script:Conn) { return "ROOT" }

    $chunks = [System.Collections.Generic.List[string]]::new()
    $curr = $ParentID
    $maxD = if ($null -ne $Script:C.LIMIT.MAX_DIR_DEPTH) { [int]$Script:C.LIMIT.MAX_DIR_DEPTH } else { 20 }
    $root = if ($null -ne $Script:C.FS.ROOT_DIR_ID) { [int]$Script:C.FS.ROOT_DIR_ID } else { 5 }
    $depth = 0

    $cmd = $Script:Conn.CreateCommand()
    $qMft = ($Script:C.DB.QUERY_PATH_MFT -f $Script:C.DB.TABLE_MFT)
    $qUni = ($Script:C.DB.QUERY_PATH_UNI -f $Script:C.DB.TABLE_UNIV)

    while ($curr -gt $root -and $depth -lt $maxD) {
        $found = $false

        $cmd.CommandText = $qMft
        $cmd.Parameters.Clear()
        $cmd.Parameters.AddWithValue("@id", $curr) | Out-Null
        $cmd.Parameters.AddWithValue("@vs", $VolumeSerial) | Out-Null

        $rdr = $cmd.ExecuteReader()
        if ($rdr.Read()) {
            $found = $true
            $name = $rdr["FileName"]
            if ($name -notmatch '^[\.]') { $chunks.Insert(0, $name) }
            $curr = [long]$rdr["PID"]
        }
        $rdr.Dispose()

        if (-not $found) {
            $cmd.CommandText = $qUni
            $cmd.Parameters.Clear()
            $cmd.Parameters.AddWithValue("@id", $curr) | Out-Null
            $cmd.Parameters.AddWithValue("@vs", $VolumeSerial) | Out-Null

            $rdr = $cmd.ExecuteReader()
            if ($rdr.Read()) {
                $found = $true
                $name = $rdr["FileName"]
                if ($name -notmatch '^[\.]') { $chunks.Insert(0, $name) }
                $curr = [long]$rdr["PID"]
                if ($curr -eq 0) { break }
            }
            $rdr.Dispose()
        }

        if (-not $found) { break }
        $depth++
    }
    $cmd.Dispose()

    if ($chunks.Count -eq 0) { return "ROOT" }
    return $chunks -join "\"
}

function Close-ScapeDatabaseEngine {
    [CmdletBinding()]
    param()

    try {
        if ($null -ne $Script:Conn -and $Script:Conn.State -eq 'Open') {
            $cmd = $Script:Conn.CreateCommand()
            $cmd.CommandText = if ($null -ne $Script:C.DB.PRAGMA_MAINT) { $Script:C.DB.PRAGMA_MAINT } else { "PRAGMA wal_checkpoint(TRUNCATE); VACUUM;" }
            $cmd.ExecuteNonQuery() | Out-Null
            $cmd.Dispose()
        }
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_EngineShutdown" }
    }
    finally {
        Close-ScapeSQLiteConnection
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
            Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{ Action = "LogLine"; Key = "DB_ENGINE_SHUTDOWN"; Severity = "LOG_INFO" }
        }
    }
}

function Close-ScapeSQLiteConnection {
    [CmdletBinding()]
    param()
    try {
        if ($null -ne $Script:Conn -and $Script:Conn.State -eq 'Open') {
            $Script:Conn.Close()
            $Script:Conn.Dispose()
        }
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_ConnClose" }
    }
    finally {
        $Script:Conn = $null
        $Script:DbPath = $null
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# INTERNAL HELPERS (Private scope)
# ─────────────────────────────────────────────────────────────────────────────

function _PrepareDbCommand {
    param([string]$Query, $Trans)
    $cmd = $Script:Conn.CreateCommand()
    $cmd.Transaction = $Trans
    $cmd.CommandText = $Query
    return $cmd
}

function _InsertNtfsRecord {
    param($Cmd, $CmdFrag, [string]$VolumeSerial, [byte[]]$Data, $Trans)
    try {
        $offFrn = if ($null -ne $Script:C.DB.NTFS_MFT_FRN_OFF) { $Script:C.DB.NTFS_MFT_FRN_OFF } else { 44 }
        $offBase = if ($null -ne $Script:C.DB.NTFS_MFT_BASE_OFF) { $Script:C.DB.NTFS_MFT_BASE_OFF } else { 32 }
        $offSeq = if ($null -ne $Script:C.DB.NTFS_MFT_SEQ_OFF) { $Script:C.DB.NTFS_MFT_SEQ_OFF } else { 16 }
        $frnMask = if ($null -ne $Script:C.FS.NTFS_FRN_MASK) { $Script:C.FS.NTFS_FRN_MASK } else { 0x0000FFFFFFFFFFFF }

        $frn = [BitConverter]::ToUInt32($Data, $offFrn)
        $base = [BitConverter]::ToUInt64($Data, $offBase)
        $seq = [BitConverter]::ToUInt16($Data, $offSeq)

        $isBase = if ($base -eq 0) { 1 } else { 0 }
        $parent = if ($isBase -eq 1) { 0 } else { $base -band $frnMask }

        $fn = "STATE_UNKNOWN"
        $cat = "SYS_CORE"
        if (Get-Command "Set-ScapeNTFSMFT" -ErrorAction SilentlyContinue) {
            $parsed = Set-ScapeNTFSMFT -Buffer $Data -Offset 0
            if ($parsed -and $parsed.FileName) { $fn = $parsed.FileName }
        }

        $status = if ($null -ne $Script:C.DB.STATUS_DISC) { $Script:C.DB.STATUS_DISC } else { "DISCOVERED" }

        $Cmd.Parameters.Clear()
        $Cmd.Parameters.AddWithValue("@VS", $VolumeSerial) | Out-Null
        $Cmd.Parameters.AddWithValue("@F", $frn) | Out-Null
        $Cmd.Parameters.AddWithValue("@B", $(if ($isBase -eq 1) { $frn } else { $parent })) | Out-Null
        $Cmd.Parameters.AddWithValue("@S", $seq) | Out-Null
        $Cmd.Parameters.AddWithValue("@ST", $status) | Out-Null
        $Cmd.Parameters.AddWithValue("@I", $isBase) | Out-Null
        $Cmd.Parameters.AddWithValue("@P", $parent) | Out-Null
        $Cmd.Parameters.AddWithValue("@FN", $fn) | Out-Null
        $Cmd.Parameters.AddWithValue("@Cat", $cat) | Out-Null
        $Cmd.Parameters.AddWithValue("@R", $Data) | Out-Null
        $Cmd.ExecuteNonQuery() | Out-Null
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_InsertNtfs" }
    }
}

function _InsertUniversalRecord {
    param($Cmd, $CmdFrag, [string]$VolumeSerial, [byte[]]$Data, [long]$Offset, [long]$Lcn, $Trans)
    try {
        $oid = 0
        if ($Data.Length -gt 0) {
            $md5 = [System.Security.Cryptography.MD5]::Create()
            $oid = [Math]::Abs([BitConverter]::ToInt32($md5.ComputeHash($Data), 0))
            $md5.Dispose()
        }

        $fn = "CARVED_$(Get-Date -Format 'HHmmss')"
        $cat = "Uncategorized"

        $jpg = if ($null -ne $Script:C.Carving.JPEG.HeaderBytes) { $Script:C.Carving.JPEG.HeaderBytes } else { @(0xFF, 0xD8, 0xFF) }
        $pdf = if ($null -ne $Script:C.Carving.PDF.HeaderBytes) { $Script:C.Carving.PDF.HeaderBytes } else { @(0x25, 0x50, 0x44, 0x46) }

        if ($Data.Length -ge $jpg.Length -and $Data[0] -eq $jpg[0] -and $Data[1] -eq $jpg[1]) {
            $cat = "Images"
            $fn = "Recovered_JPEG"
        }
        elseif ($Data.Length -ge $pdf.Length -and $Data[0] -eq $pdf[0] -and $Data[1] -eq $pdf[1]) {
            $cat = "Documents"
            $fn = "Recovered_PDF"
        }

        $status = if ($null -ne $Script:C.DB.STATUS_DISC_R) { $Script:C.DB.STATUS_DISC_R } else { "DISCOVERED_RAW" }

        $Cmd.Parameters.Clear()
        $Cmd.Parameters.AddWithValue("@VS", $VolumeSerial) | Out-Null
        $Cmd.Parameters.AddWithValue("@OID", $oid) | Out-Null
        $Cmd.Parameters.AddWithValue("@ST", $status) | Out-Null
        $Cmd.Parameters.AddWithValue("@FN", $fn) | Out-Null
        $Cmd.Parameters.AddWithValue("@Cat", $cat) | Out-Null
        $Cmd.Parameters.AddWithValue("@R", $Data) | Out-Null
        $Cmd.ExecuteNonQuery() | Out-Null

        if ($Lcn -gt 0 -or $Offset -gt 0) {
            $sz = if ($null -ne $Script:C.FS.BLOCK_SIZE) { [int]$Script:C.FS.BLOCK_SIZE } else { 4096 }
            $po = if ($Lcn -gt 0) { $Lcn * $sz } else { $Offset }

            $CmdFrag.Parameters.Clear()
            $CmdFrag.Parameters.AddWithValue("@VS", $VolumeSerial) | Out-Null
            $CmdFrag.Parameters.AddWithValue("@OID", $oid) | Out-Null
            $CmdFrag.Parameters.AddWithValue("@IDX", 0) | Out-Null
            $CmdFrag.Parameters.AddWithValue("@PO", $po) | Out-Null
            $CmdFrag.Parameters.AddWithValue("@LEN", $Data.Length) | Out-Null
            $CmdFrag.ExecuteNonQuery() | Out-Null
        }
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "Database_InsertUniv" }
    }
}
