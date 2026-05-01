@{
    "Core"           = @(
        @{ Name = "Scape.Core.State"; LoadOrder = 1; DependsOn = @(); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.EventBus"; LoadOrder = 2; DependsOn = @("Scape.Core.State"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Constants"; LoadOrder = 3; DependsOn = @("Scape.Core.State"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Settings"; LoadOrder = 4; DependsOn = @("Scape.Core.EventBus"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.AssetManager"; LoadOrder = 5; DependsOn = @("Scape.Core.Settings", "Scape.Core.Constants"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Utils"; LoadOrder = 6; DependsOn = @("Scape.Core.Constants"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.I18N"; LoadOrder = 7; DependsOn = @("Scape.Core.Settings", "Scape.Core.Constants"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Interop"; LoadOrder = 8; DependsOn = @("Scape.Core.Constants"); IsVital = $true; Domain = "Core"; CompileOnce = $true }
        @{ Name = "Scape.Core.Security"; LoadOrder = 9; DependsOn = @("Scape.Core.Interop"); IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Resolver"; LoadOrder = 10; DependsOn = @("Scape.Core.State"); IsVital = $true; Domain = "Core" }
    )

    "Acquisition"    = @(
        @{ Name = "Scape.Acquisition.Bridge"; LoadOrder = 10; DependsOn = @("Scape.Core.Interop"); IsVital = $true; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Reader"; LoadOrder = 11; DependsOn = @("Scape.Acquisition.Bridge"); IsVital = $true; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Resilience"; LoadOrder = 12; DependsOn = @("Scape.Acquisition.Reader"); IsVital = $true; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Selection"; LoadOrder = 13; DependsOn = @("Scape.Acquisition.Reader"); IsVital = $false; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Bitwise"; LoadOrder = 14; DependsOn = @("Scape.Acquisition.Reader"); IsVital = $false; Domain = "Acquisition" }
    )

    "Analysis"       = @(
        @{ Name = "Scape.Analysis.FS.Abstraction"; LoadOrder = 20; DependsOn = @("Scape.Acquisition.Reader"); IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Carving.Signature"; LoadOrder = 21; DependsOn = @("Scape.Core.Constants"); IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Carving.Carver"; LoadOrder = 22; DependsOn = @("Scape.Analysis.Carving.Signature", "Scape.Acquisition.Reader"); IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Carving.Healer"; LoadOrder = 23; DependsOn = @("Scape.Analysis.Carving.Signature"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.NTFS"; LoadOrder = 30; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.FAT"; LoadOrder = 31; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.EXT"; LoadOrder = 32; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.BTRFS"; LoadOrder = 33; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.XFS"; LoadOrder = 34; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.ZFS"; LoadOrder = 35; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.APFS"; LoadOrder = 36; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.REFS"; LoadOrder = 37; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.HFS"; LoadOrder = 38; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.F2FS"; LoadOrder = 39; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.JFS"; LoadOrder = 40; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.UDF"; LoadOrder = 41; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.ISO9660"; LoadOrder = 42; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.DiskImage"; LoadOrder = 43; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.PartitionTable"; LoadOrder = 44; DependsOn = @("Scape.Analysis.FS.Abstraction"); IsVital = $false; Domain = "Analysis" }
    )

    "Infrastructure" = @(
        @{ Name = "Scape.Infrastructure.Audit"; LoadOrder = 50; DependsOn = @("Scape.Core.EventBus"); IsVital = $true; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Compliance"; LoadOrder = 51; DependsOn = @("Scape.Infrastructure.Audit"); IsVital = $true; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Telemetry"; LoadOrder = 52; DependsOn = @("Scape.Core.Interop"); IsVital = $false; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Pipeline"; LoadOrder = 53; DependsOn = @("Scape.Infrastructure.Audit", "Scape.Analysis.Carving.Carver"); IsVital = $true; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Watchdog"; LoadOrder = 54; DependsOn = @("Scape.Core.EventBus"); IsVital = $true; Domain = "Infrastructure"; ThreadSafe = $true }
        @{ Name = "Scape.Infrastructure.Logger"; LoadOrder = 55; DependsOn = @("Scape.Core.EventBus", "Scape.Core.Constants", "Scape.Core.Utils"); IsVital = $true; Domain = "Infrastructure"; ThreadSafe = $true }
    )

    "Presentation"   = @(
        @{ Name = "Scape.Presentation.Theme"; LoadOrder = 60; DependsOn = @("Scape.Core.Constants", "Scape.Core.Utils"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Geometry"; LoadOrder = 61; DependsOn = @("Scape.Core.Utils", "Scape.Presentation.Config"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.TUI"; LoadOrder = 62; DependsOn = @("Scape.Presentation.Geometry", "Scape.Presentation.Theme", "Scape.Presentation.Config"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Renderer"; LoadOrder = 63; DependsOn = @("Scape.Presentation.TUI", "Scape.Presentation.Theme", "Scape.Presentation.Config"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Controller"; LoadOrder = 64; DependsOn = @("Scape.Core.State", "Scape.Presentation.Theme"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Responsivity"; LoadOrder = 65; DependsOn = @("Scape.Presentation.TUI", "Scape.Core.EventBus"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Router"; LoadOrder = 66; DependsOn = @("Scape.Presentation.Controller", "Scape.Presentation.Responsivity", "Scape.Presentation.Renderer"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Dispatcher"; LoadOrder = 67; DependsOn = @("Scape.Core.EventBus", "Scape.Presentation.Renderer"); IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.StateObserver"; LoadOrder = 68; DependsOn = @("Scape.Presentation.Dispatcher", "Scape.Core.State"); IsVital = $true; Domain = "Presentation" }
    )

    "Extensions"     = @(
        @{ Name = "Scape.Extensions.Database.Core"; LoadOrder = 70; DependsOn = @("Scape.Core.Interop"); IsVital = $true; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.Database.FragmentDB"; LoadOrder = 71; DependsOn = @("Scape.Extensions.Database.Core"); IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.Database.MetaDB"; LoadOrder = 72; DependsOn = @("Scape.Extensions.Database.Core"); IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.Network"; LoadOrder = 73; DependsOn = @("Scape.Core.Interop"); IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.CloudSync"; LoadOrder = 74; DependsOn = @("Scape.Core.Utils"); IsVital = $false; Domain = "Extensions" }
    )

    "Forge"          = @(
        @{ Name = "Scape.Forge.Compiler"; LoadOrder = 80; DependsOn = @("Scape.Core.Constants"); IsVital = $false; Domain = "Forge" }
        @{ Name = "Scape.Forge.Packager"; LoadOrder = 81; DependsOn = @("Scape.Forge.Compiler"); IsVital = $false; Domain = "Forge" }
        @{ Name = "Scape.Forge.Deployer"; LoadOrder = 82; DependsOn = @(); IsVital = $true; Domain = "Forge" }
    )

    "Orphans"        = @()
}