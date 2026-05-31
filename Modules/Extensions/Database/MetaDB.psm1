<#
.SYNOPSIS
    Domain: Extensions
    Module: Scape.Extensions.Database.MetaDB
    Architecture: Shadow MFT metadata manager. Transactional and Memory-Safe.
#>

function Write-ScapeShadowRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Connection,
        [Parameter(Mandatory = $true)]$Transaction,
        [Parameter(Mandatory = $true)][hashtable]$RecordMap
    )

    $cmd = $null
    try {
        $table = Get-ScapeConstant -Path "network::DB::TABLE_MFT" -Fallback "ShadowMFT"
        $query = (Get-ScapeConstant -Path "network::DB::QUERY_INS_MFT" -Fallback "INSERT OR IGNORE INTO {0} (VolumeSerial, FRN, BaseFRN, SequenceNumber, Status, IsBaseRecord, ParentFRN, FileName, Category, RawRecord) VALUES (@VS, @F, @B, @S, @ST, @I, @P, @FN, @Cat, @R)") -f $table

        $cmd = $Connection.CreateCommand()
        $cmd.Transaction = $Transaction
        $cmd.CommandText = $query

        $RecordMap.GetEnumerator() | ForEach-Object {
            $cmd.Parameters.AddWithValue($_.Name, $_.Value) | Out-Null
        }

        $cmd.ExecuteNonQuery() | Out-Null
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "MetaDB_Write" }
        throw $_ # Repassa a exceção para o Core.psm1 acionar o Rollback da Transação
    }
    finally {
        if ($null -ne $cmd) { $cmd.Dispose() }
    }
}

function Resolve-ScapeShadowPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]$Connection,
        [Parameter(Mandatory = $true)][long]$ParentNode,
        [Parameter(Mandatory = $true)][string]$VolumeId
    )

    $cmd = $null
    try {
        $maxDepth = Get-ScapeConstant -Path "system::LIMITS::MAX_DIR_DEPTH" -Fallback 20
        $rootId = Get-ScapeConstant -Path "storage::FS::ROOT_DIR_ID" -Fallback 5
        $queryMft = (Get-ScapeConstant -Path "network::DB::QUERY_PATH_MFT" -Fallback "SELECT ParentFRN as PID, FileName FROM {0} WHERE FRN = @id AND VolumeSerial = @vs") -f (Get-ScapeConstant -Path "network::DB::TABLE_MFT" -Fallback "ShadowMFT")

        $chunks = [System.Collections.Generic.List[string]]::new()
        $current = $ParentNode
        $depth = 0

        $cmd = $Connection.CreateCommand()
        $cmd.CommandText = $queryMft

        while ($current -gt $rootId -and $depth -lt $maxDepth) {
            $cmd.Parameters.Clear()
            $cmd.Parameters.AddWithValue("@id", $current) | Out-Null
            $cmd.Parameters.AddWithValue("@vs", $VolumeId) | Out-Null

            $reader = $cmd.ExecuteReader()
            if ($reader.Read()) {
                $name = $reader["FileName"]
                if ($name -notmatch '^\.') { $chunks.Insert(0, $name) }
                $current = [long]$reader["PID"]
                $reader.Dispose()
            }
            else {
                $reader.Dispose()
                break
            }
            $depth++
        }
        return $(if ($chunks.Count -eq 0) { "ROOT" } else { $chunks -join "\" })
    }
    catch {
        if (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue) { Publish-ScapeFault -ErrorRecord $_ -Context "MetaDB_ResolvePath" }
        return "ROOT"
    }
    finally {
        if ($null -ne $cmd) { $cmd.Dispose() }
    }
}

Export-ModuleMember -Function 'Write-ScapeShadowRecord',
'Resolve-ScapeShadowPath'
