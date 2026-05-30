<#
.SYNOPSIS
    Domain: Infrastructure | Module: Scape.Infrastructure.Pipeline
    Description: High-throughput, backpressure-aware memory data pipeline.
#>

$Script:PipelineBuffer = $null
$Script:Stats = @{ Received = 0; Dispatched = 0; Dropped = 0; Errors = 0 }

function Initialize-ScapePipeline {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $bufferSize = Get-ScapeConstant -Path "storage::Buffer::BATCH_SIZE" -Fallback 10000
    $Script:PipelineBuffer = [System.Collections.Concurrent.BlockingCollection[PSCustomObject]]::new($bufferSize)

    if (Get-Command Register-ScapeEventListener -ErrorAction SilentlyContinue) {
        Register-ScapeEventListener -EventMatch "CARVED_ARTIFACT_FOUND" -Action {
            param($evt) Add-ScapePipelineArtifact -IncomingEvt $evt
        }
        Register-ScapeEventListener -EventMatch "FS_RECORD_EXTRACTED" -Action {
            param($evt) Add-ScapePipelineRecord -IncomingEvt $evt
        }
    }

    $msgInit = Get-ScapeLogMsg -Key "CORE_ENGINE_START" -MsgArgs @()
    Publish-ScapeEvent -Type "SYSTEM_READY" -Payload @{
        Action   = "LogLine"
        Key      = "CORE_ENGINE_START"
        Args     = @("Capacity: $bufferSize")
        Severity = "LOG_INFO"
        Message  = $msgInit
    }
    return $true
}

function Add-ScapePipelineArtifact {
    param([PSCustomObject]$IncomingEvt)
    if (-not $IncomingEvt -or -not $IncomingEvt.Payload -or $Script:PipelineBuffer.IsAddingCompleted) { return }

    $artifact = $IncomingEvt.Payload
    $confidence = if ($null -ne $artifact.Confidence) { $artifact.Confidence } else { 1.0 }
    $minConf = Get-ScapeConstant -Path "network::FILEMAP::MIN_CONFIDENCE_THRESHOLD" -Fallback 0.6

    if ($confidence -lt $minConf -and $Script:PipelineBuffer.Count -ge $Script:PipelineBuffer.BoundedCapacity) {
        $Script:Stats.Dropped++
        $msgDrop = Get-ScapeLogMsg -Key "STATUS_FAILED" -MsgArgs @("LOW_CONFIDENCE_BUFFER_FULL")
        Publish-ScapeEvent -Type "PIPELINE_DROPPED" -Severity "LOG_DEBUG" -Payload @{ Reason = "STATUS_FAILED"; Message = $msgDrop }
        return
    }

    $envelope = [PSCustomObject]@{
        Source    = "CARVER"
        Type      = "ARTIFACT"
        Timestamp = [DateTime]::UtcNow
        Data      = $artifact
    }
    $timeoutMs = Get-ScapeConstant -Path "system::Limits::ASYNC_OP_TIMEOUT_MS" -Fallback 30000
    if ($Script:PipelineBuffer.TryAdd($envelope, $timeoutMs)) { $Script:Stats.Received++ } else { $Script:Stats.Dropped++ }
}

function Add-ScapePipelineRecord {
    param([PSCustomObject]$IncomingEvt)
    if (-not $IncomingEvt -or -not $IncomingEvt.Payload -or $Script:PipelineBuffer.IsAddingCompleted) { return }

    $record = if ($IncomingEvt.Payload.Record) { $IncomingEvt.Payload.Record } else { $IncomingEvt.Payload }
    $envelope = [PSCustomObject]@{
        Source    = "FS_PARSER"
        Type      = "METADATA"
        Timestamp = [DateTime]::UtcNow
        Data      = $record
    }
    $Script:PipelineBuffer.Add($envelope)
    $Script:Stats.Received++
}

function Get-ScapePipelineStat {
    [CmdletBinding()]
    [OutputType([psobject])]
    param()
    return [PSCustomObject]@{
        BufferCount    = $Script:PipelineBuffer.Count
        BufferCapacity = $Script:PipelineBuffer.BoundedCapacity
        Received       = $Script:Stats.Received
        Dropped        = $Script:Stats.Dropped
    }
}
Register-ScapeActionHandler -Target 'Scape.Infrastructure.Pipeline' -Handler {
    param($Task, $PayloadDef, $Target)
    Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "PIPELINE_INIT") -StatusFlag "INFO" -RunProgress 20 -StepProgress 30
    if (Get-Command Initialize-ScapePipeline -ErrorAction SilentlyContinue) {
        Initialize-ScapePipeline | Out-Null
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "PIPELINE_ACTIVE") -StatusFlag "Success" -RunProgress 100 -StepProgress 100
    } else {
        Publish-ScapeActionProgress -Target $Target -Task $Task -StatusText (Invoke-ScapeI18NFormat -Key "PIPELINE_NO_MODULE") -StatusFlag "Failure" -RunProgress 100 -StepProgress 0
        throw "Pipeline module not available."
    }
}

