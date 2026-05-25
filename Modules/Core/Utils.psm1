<#
.SYNOPSIS
    Domain: Foundation | Module: Scape.Core.Utils
    Pure logic helpers: mathematics, data transformation, safe extraction, and I/O Wrapper.
#>
[CmdletBinding()] param()

function Invoke-ScapeIO {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$Action,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][ScriptBlock]$Operation
    )
    process {
        if ($PSCmdlet.ShouldProcess("Target: $Target", "IO_ACTION: $Action")) {
            try {
                $result = & $Operation
                if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                    Publish-ScapeEvent -Type "IO_AUDIT_SUCCESS" -Severity "LOG_DEBUG" -Payload @{ Action = $Action; Target = $Target }
                }
                return @{ Success = $true; Data = $result; Error = $null }
            }
            catch {
                if (Get-Command Publish-ScapeEvent -ErrorAction SilentlyContinue) {
                    Publish-ScapeEvent -Type "IO_AUDIT_FAULT" -Severity "LOG_ERR" -Payload @{ Action = $Action; Target = $Target; Error = $_.Exception.Message }
                }
                throw $_
            }
        }
        return @{ Success = $false; Data = $null; Error = "SKIPPED_BY_SHOULDPROCESS" }
    }
}

function Get-ScapePlainTextLength {
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowEmptyString()][string]$Text = '')
    process {
        if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
        return ($Text -replace '\x1B\[[0-9;]*[a-zA-Z]', '').Length
    }
}

function Get-ScapeJustifiedPadding {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$LeftText,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$RightText,
        [Parameter(Mandatory = $true)][int]$TotalWidth
    )
    process {
        $lenL = Get-ScapePlainTextLength -Text $LeftText
        $lenR = Get-ScapePlainTextLength -Text $RightText
        $padCount = $TotalWidth - ($lenL + $lenR)
        if ($padCount -le 0) { return " " }
        return " " * $padCount
    }
}

function Get-ScapeProperty {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(ValueFromPipeline = $true)]$Object,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$PropertyName,
        [Parameter()][object]$Fallback = $null
    )
    process {
        if ($null -eq $Object) { return $Fallback }
        if ($Object -is [System.Collections.IDictionary] -and $Object.ContainsKey($PropertyName)) { return $Object[$PropertyName] }
        try {
            if ($Object -is [System.Collections.IDictionary]) {
                foreach ($key in $Object.Keys) {
                    if ($key -eq $PropertyName) { return $Object[$key] }
                }
            }
            elseif ($null -ne $Object.PSObject -and $null -ne $Object.PSObject.Properties[$PropertyName]) {
                return $Object.$PropertyName
            }
        }
        catch { Write-Verbose "Property missing: $($_.Exception.Message)" -ErrorAction SilentlyContinue }
        return $Fallback
    }
}

function Format-ScapeByte {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [long]$Bytes
    )
    process {
        try {
            $units = @('B', 'KB', 'MB', 'GB', 'TB', 'PB')
            $index = 0
            $calcBytes = [double]$Bytes
            while ($calcBytes -ge 1024 -and $index -lt ($units.Count - 1)) {
                $calcBytes /= 1024
                $index++
            }
            return '{0:N2} {1}' -f $calcBytes, $units[$index]
        }
        catch {
            Write-Verbose "Format-ScapeByte error: $($_.Exception.Message)"
            return "{0} B" -f $Bytes
        }
    }
}

function ConvertTo-ScapeHex {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][long]$Value,
        [Parameter()][int]$Padding = 8
    )
    process {
        try {
            return "0x{0}" -f $Value.ToString("X$Padding")
        }
        catch {
            return "0x0"
        }
    }
}

function ConvertTo-ScapeHexString {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][byte[]]$Data)
    process {
        if ($null -eq $Data -or $Data.Length -eq 0) { return [string]::Empty }
        return [System.BitConverter]::ToString($Data) -replace '-'
    }
}

function Convert-ScapeHexToByte {
    [CmdletBinding()]
    [OutputType([System.Object[]])] # ✅ PSRule detecta como Object[]
    param([Parameter(Mandatory = $true)][string]$Hex)
    process {
        if ([string]::IsNullOrWhiteSpace($Hex)) { return @() }
        $clean = $Hex -replace '\s|0x', ''
        $len = $clean.Length
        if ($len % 2 -ne 0) { throw "HEX_INVALID_LENGTH: $Hex" }
        $bytes = [byte[]]::new($len / 2)
        for ($i = 0; $i -lt $len; $i += 2) {
            $bytes[$i / 2] = [Convert]::ToByte($clean.Substring($i, 2), 16)
        }
        return [System.Object[]]$bytes
    }
}

function Test-ScapeAlignment {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][long]$Offset,
        [Parameter(Mandatory = $true)][int]$Alignment
    )
    process {
        if ($Alignment -eq 0) { return $false }
        return ($Offset % $Alignment) -eq 0
    }
}

function Invoke-ScapeMathClamp {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)][int]$Value,
        [Parameter(Mandatory = $true)][int]$Min,
        [Parameter(Mandatory = $true)][int]$Max
    )
    process {
        return [math]::Max($Min, [math]::Min($Max, $Value))
    }
}

function Join-ScapePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][AllowEmptyString()][string]$Base = "",
        [Parameter(Mandatory = $false)][AllowEmptyString()][string]$Child = ""
    )
    process {
        # Limpa barras sobrando para evitar \\ duplicadas
        $b = $Base.TrimEnd('\', '/')
        $c = $Child.TrimStart('\', '/')

        if ([string]::IsNullOrWhiteSpace($b)) { return $c }
        if ([string]::IsNullOrWhiteSpace($c)) { return $b }

        try {
            return [System.IO.Path]::Combine($b, $c)
        }
        catch {
            # Fallback absoluto caso a classe do .NET falhe por caractere ilegal
            return "$b\$c"
        }
    }
}

function Test-ScapePath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)][AllowEmptyString()][string]$Base,
        [Parameter(Mandatory = $false)][AllowEmptyString()][string]$Child,
        [switch]$Leaf
    )
    process {
        $full = Join-ScapePath -Base $Base -Child $Child
        if ([string]::IsNullOrWhiteSpace($full)) { return $false }
        if ($Leaf) {
            Test-Path -LiteralPath $full -PathType Leaf
        }
        else {
            Test-Path -LiteralPath $full
        }
    }
}

function Publish-ScapeTreeUpdate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$TreeId, # Ex: 'Build_Extract', 'Analysis_FS'
        [Parameter(Mandatory = $true)][hashtable[]]$Nodes,
        [string]$TitleKey = 'TREE_DEFAULT_TITLE'
    )
    process {
        Publish-ScapeEvent -Type "TREE_UPDATE" -Severity "INFO" -Payload @{
            TreeId   = $TreeId
            Nodes    = $Nodes
            TitleKey = $TitleKey
        }
    }
}

function Invoke-ScapeProgressWrapper {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)][array]$Items,
        [Parameter(Mandatory = $true)][string]$StageLabel,
        [Parameter(Mandatory = $true)][ScriptBlock]$ActionBlock
    )
    process {
        $total = $Items.Count
        if ($total -eq 0) { return @() }

        $results = New-Object System.Collections.Generic.List[object]
        for ($i = 0; $i -lt $total; $i++) {
            Publish-ScapeEvent -Type "PROGRESS" -Severity "LOG_INFO" -Payload @{
                Stage   = $StageLabel
                Current = $i
                Total   = $total
            }
            if (Get-Command Invoke-ScapeIdlePump -ErrorAction SilentlyContinue) {
                Invoke-ScapeIdlePump | Out-Null
            }
            $res = & $ActionBlock $Items[$i]
            if ($null -ne $res) { $results.Add($res) }
        }
        Publish-ScapeEvent -Type "PROGRESS" -Severity "LOG_INFO" -Payload @{
            Stage   = $StageLabel
            Current = $total
            Total   = $total
        }
        Invoke-ScapeIdlePump | Out-Null
        return $results.ToArray()
    }
}