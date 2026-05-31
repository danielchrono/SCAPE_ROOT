<#.SYNOPSIS
    Domain: Acquisition
    Module: Scape.Acquisition.Reader
    Description: Chunk-based raw disk reader. Aligns reads to sector boundaries and feeds the Analysis layer.
#>

$Script:C = $null

function Initialize-ScapeReader {
    $Script:C = @{
        IO = Get-ScapeConstant -Path "storage::BUFFER" -Fallback @{}
        FS = Get-ScapeConstant -Path "storage::FS" -Fallback @{}
    }
}

function Read-ScapeDiskStream {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DevicePath,

        [Parameter(Mandatory = $true)]
        [long]$StartOffset,

        [Parameter(Mandatory = $true)]
        [long]$EndOffset,

        [string]$VolumeSerial = "RAW_VOL"
    )

    if (-not $Script:C) { Initialize-ScapeReader }

    $handle = Open-ScapeRawHandle -DevicePath $DevicePath
    if ($null -eq $handle -or $handle.IsInvalid) { return }

    try {
        $chunkSize = [uint32]$Script:C.IO["CHUNK_READ"]
        $overlap = [uint32]$Script:C.IO["OVERLAP_BYTES"]

        # Buffer de trabalho fixo (Otimização do Garbage Collector)
        $buffer = [byte[]]::new($chunkSize + $overlap)

        $currentOffset = $StartOffset

        while ($currentOffset -lt $EndOffset) {

            # Garante que não vamos ler além do disco
            $bytesToRead = $chunkSize
            if (($currentOffset + $bytesToRead) -gt $EndOffset) {
                $bytesToRead = [uint32]($EndOffset - $currentOffset)
            }

            # Prepara a clausura (ScriptBlock) para o módulo de Resiliência injetar
            $readAction = {
                $newPointer = 0L
                $ptrSuccess = [ScapeWin32]::SetFilePointerEx($handle, $currentOffset, [ref]$newPointer, 0)
                if (-not $ptrSuccess) { return @{ Success = $false; ErrorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() } }

                $bytesRead = 0u
                # Lemos no buffer alocado, respeitando o overlap para não cortar assinaturas ao meio
                $readSuccess = [ScapeWin32]::ReadFile($handle, $buffer, $bytesToRead, [ref]$bytesRead, [IntPtr]::Zero)

                if ($readSuccess -and $bytesRead -gt 0) {
                    return @{ Success = $true; BytesRead = $bytesRead; Buffer = $buffer }
                }
                return @{ Success = $false; ErrorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() }
            }

            # Executa a leitura blindada
            $readResult = Invoke-ScapeResilientRead -ReadOperation $readAction -TargetOffset $currentOffset

            if ($readResult.Success) {
                # O buffer lido é enviado diretamente para a Layer 2 (Orquestrador)
                # Note que enviamos uma cópia exata apenas da porção válida lida (slice)
                $validSlice = [byte[]]::new($readResult.BytesRead)
                [System.Array]::Copy($readResult.Buffer, 0, $validSlice, 0, $readResult.BytesRead)

                if (Get-Command "Start-ScapeAnalysisStream" -ErrorAction SilentlyContinue) {
                    Start-ScapeAnalysisStream -SectorBuffer $validSlice -PhysicalOffset $currentOffset -VolumeSerial $VolumeSerial
                }

                # Avança o ponteiro. O overlap garante que assinaturas na borda não sejam perdidas
                $currentOffset += ($readResult.BytesRead - $overlap)

            }
            else {
                # Se falhou mesmo com resiliência, pulamos o chunk corrompido para o próximo bloco seguro (Max Orphan Gap)
                $currentOffset += $chunkSize
            }
        }
    }
    finally {
        Close-ScapeRawHandle -Handle $handle
    }
}

Export-ModuleMember -Function 'Initialize-ScapeReader',
    'Read-ScapeDiskStream'
