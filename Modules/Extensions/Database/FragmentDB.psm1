<#
.SYNOPSIS
    Domain: Extensions
    Module: Scape.Extensions.Database.FragmentDB
    Architecture: Density mapping for carved raw fragment offsets.
#>

function Write-ScapeFragmentMap {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Connection,
        [Parameter(Mandatory = $true)]$Transaction,
        [Parameter(Mandatory = $true)][hashtable]$FragMap
    )

    $table = Get-ScapeConstant -Path "network::DB::TABLE_FRAG" -Fallback "FragmentMap"
    $query = (Get-ScapeConstant -Path "network::DB::QUERY_INS_FRAG" -Fallback "") -f $table

    $cmd = $Connection.CreateCommand()
    $cmd.Transaction = $Transaction
    $cmd.CommandText = $query

    $FragMap.GetEnumerator() | ForEach-Object {
        $cmd.Parameters.AddWithValue($_.Name, $_.Value) | Out-Null
    }

    $cmd.ExecuteNonQuery() | Out-Null
    $cmd.Dispose()
}
Export-ModuleMember -Function 'Write-ScapeFragmentMap'
