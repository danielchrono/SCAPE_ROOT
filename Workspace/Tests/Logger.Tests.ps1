$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# ============================================================================
# Pester v3 Bootstrap
# Logger.psm1 calls functions from other modules (Get-ScapeConstant, etc.).
# In Pester v3, Mock inside InModuleScope targets the module's own scope,
# which is the ONLY way to intercept calls from within a module.
# ============================================================================

# Load real Core modules so functions exist at module-load time
$coreMods = @('State','Utils','EventBus','Constants','I18N')
foreach ($m in $coreMods) {
    $p = Join-Path $repoRoot "Modules\Core\$m.psm1"
    if (Test-Path $p) { Import-Module $p -Global -Force -ErrorAction SilentlyContinue }
}
# Initialize state so Get-ScapeColdState works at Logger import time
try { Initialize-ScapeState | Out-Null } catch {}

# Stub any missing functions
if (-not (Get-Command Publish-ScapeFault -ErrorAction SilentlyContinue)) {
    function global:Publish-ScapeFault { param($ErrorRecord, $Context, $Message) }
}

# Import Logger (binds to real functions)
Import-Module (Join-Path $repoRoot "Modules\Infrastructure\Logger.psm1") -Force

Describe "Logger Continuity" {
    BeforeAll {
        $script:logDir = Join-Path $env:TEMP "ScapeTests"
        if (Test-Path $script:logDir) { Remove-Item $script:logDir -Recurse -Force }
        New-Item -ItemType Directory -Path $script:logDir -Force | Out-Null

        $env:SCAPE_LOG_PARENT_FILE = $null
        $env:SCAPE_LOG_FILE_OVERRIDE = $null
    }

    It "Should initialize and set SCAPE_LOG_PARENT_FILE" {
        InModuleScope Logger {
            Mock Get-ScapeConstant {
                param($Path, $Fallback)
                if ($Path -eq "infrastructure::Logger") {
                    return @{
                        LOG_LEVELS          = @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 }
                        DEFAULT_LEVEL_NAME  = "INFO"
                        LOG_FILE_PATTERN    = "test_{0:yyyyMMdd_HHmmss}.log"
                        MAX_LOG_SIZE_MB     = 10
                        LOG_IMMEDIATE_FLUSH = $true
                    }
                }
                if ($Path -eq "infrastructure::LogSeverity") { return @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 } }
                if ($Path -eq "system::LIMITS") { return @{ MAX_CONCURRENT_OPS = 100 } }
                if ($Path -eq "system::Workspace") { return @{ LOGS = "Logs" } }
                return $Fallback
            }
            Mock Get-ScapeColdState {
                return @{ WORKSPACE_LOGS = (Join-Path $env:TEMP "ScapeTests") }
            }
            Mock Get-ScapeLogMsg { param($Key, $MsgArgs) return $Key }
            Mock Publish-ScapeEvent { }
            Mock Publish-ScapeFault { }
            Mock Register-ScapeEventListener { }

            $Script:Initialized = $false; $Script:LogStream = $null; $Script:CurrentLogFile = $null

            $result = Initialize-ScapeLogger
            $result | Should Be $true

            $logFile = Get-ScapeActiveLogFile
            $logFile | Should Not BeNullOrEmpty
            $env:SCAPE_LOG_PARENT_FILE | Should Be $logFile

            Close-ScapeLogStream
        }
    }

    It "Child process should reuse parent log file" {
        InModuleScope Logger {
            Mock Get-ScapeConstant {
                param($Path, $Fallback)
                if ($Path -eq "infrastructure::Logger") {
                    return @{
                        LOG_LEVELS          = @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 }
                        DEFAULT_LEVEL_NAME  = "INFO"
                        LOG_FILE_PATTERN    = "test_{0:yyyyMMdd_HHmmss}.log"
                        MAX_LOG_SIZE_MB     = 10
                        LOG_IMMEDIATE_FLUSH = $true
                    }
                }
                if ($Path -eq "infrastructure::LogSeverity") { return @{ DEBUG = 0; INFO = 1; WARNING = 2; ERROR = 3; FATAL = 4 } }
                if ($Path -eq "system::LIMITS") { return @{ MAX_CONCURRENT_OPS = 100 } }
                if ($Path -eq "system::Workspace") { return @{ LOGS = "Logs" } }
                return $Fallback
            }
            Mock Get-ScapeColdState {
                return @{ WORKSPACE_LOGS = (Join-Path $env:TEMP "ScapeTests") }
            }
            Mock Get-ScapeLogMsg { param($Key, $MsgArgs) return $Key }
            Mock Publish-ScapeEvent { }
            Mock Publish-ScapeFault { }
            Mock Register-ScapeEventListener { }

            $parentLog = Join-Path (Join-Path $env:TEMP "ScapeTests") "parent.log"
            Set-Content -Path $parentLog -Value "Parent Start"

            $env:SCAPE_LOG_PARENT_FILE = $parentLog
            $env:SCAPE_LOG_FILE_OVERRIDE = $null

            $Script:Initialized = $false; $Script:LogStream = $null; $Script:CurrentLogFile = $null

            $result = Initialize-ScapeLogger
            $result | Should Be $true

            $activeLog = Get-ScapeActiveLogFile
            $activeLog | Should Be $env:SCAPE_LOG_PARENT_FILE

            Close-ScapeLogStream
        }
    }
}
