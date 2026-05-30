@{
    __Meta__       = @{
        Name    = "Topology"
        Version = "1.0"
        Author  = "Scape.Core"
        Purpose = "System topology manifest. Load order defines sequence; no circular dependencies."
    }

    # Root           = @(
    #     @{ Name = "Scape.Deploy"; LoadOrder = 1; IsVital = $false; IsDeployEssential = $true; Domain = "Root"; BuildTimeOnly = $true }
    # )

    Core           = @(
        @{ Name = "Scape.Core.State"; LoadOrder = 10; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.EventBus"; LoadOrder = 11; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.AssetManager"; LoadOrder = 12; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Constants"; LoadOrder = 13; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Utils"; LoadOrder = 14; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Settings"; LoadOrder = 15; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.I18N"; LoadOrder = 16; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Interop"; LoadOrder = 17; IsVital = $true; Domain = "Core"; CompileOnce = $true }
        @{ Name = "Scape.Core.Security"; LoadOrder = 18; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.Resolver"; LoadOrder = 19; IsVital = $true; Domain = "Core" }
        @{ Name = "Scape.Core.ActionManager"; LoadOrder = 20; IsVital = $true; Domain = "Core"; DependsOn = @("Scape.Core.EventBus", "Scape.Core.Constants") }
        @{ Name = "Scape.Core.HardwareProfile"; LoadOrder = 21; IsVital = $false; Domain = "Core" }
    )

    Acquisition    = @(
        @{ Name = "Scape.Acquisition.Bridge"; LoadOrder = 20; IsVital = $true; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Reader"; LoadOrder = 21; IsVital = $true; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Resilience"; LoadOrder = 22; IsVital = $true; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Selection"; LoadOrder = 23; IsVital = $false; Domain = "Acquisition" }
        @{ Name = "Scape.Acquisition.Bitwise"; LoadOrder = 24; IsVital = $false; Domain = "Acquisition" }
    )

    Analysis       = @(
        @{ Name = "Scape.Analysis.FS.Abstraction"; LoadOrder = 30; IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Carving.Signature"; LoadOrder = 31; IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Carving.Carver"; LoadOrder = 32; IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Carving.Healer"; LoadOrder = 33; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Parser.Core"; LoadOrder = 34; IsVital = $true; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.NTFS"; LoadOrder = 40; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.FAT"; LoadOrder = 41; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.EXT"; LoadOrder = 42; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.BTRFS"; LoadOrder = 43; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.XFS"; LoadOrder = 44; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.ZFS"; LoadOrder = 45; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.APFS"; LoadOrder = 46; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.REFS"; LoadOrder = 47; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.HFS"; LoadOrder = 48; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.F2FS"; LoadOrder = 49; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.JFS"; LoadOrder = 50; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.UDF"; LoadOrder = 51; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.ISO9660"; LoadOrder = 52; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.DiskImage"; LoadOrder = 53; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.PartitionTable"; LoadOrder = 54; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.FS.Metadata"; LoadOrder = 55; IsVital = $false; Domain = "Analysis" }
        @{ Name = "Scape.Analysis.Analyzer"; LoadOrder = 56; IsVital = $false; Domain = "Analysis" }
    )

    Diagnostics    = @(
        @{ Name = "Scape.Diagnostics.UXSimulator"; LoadOrder = 58; IsVital = $false; Domain = "Diagnostics" }
    )

    Infrastructure = @(
        @{ Name = "Scape.Infrastructure.Logger"; LoadOrder = 60; IsVital = $true; Domain = "Infrastructure"; ThreadSafe = $true }
        @{ Name = "Scape.Infrastructure.Audit"; LoadOrder = 61; IsVital = $true; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Compliance"; LoadOrder = 62; IsVital = $true; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Telemetry"; LoadOrder = 63; IsVital = $false; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Pipeline"; LoadOrder = 64; IsVital = $true; Domain = "Infrastructure" }
        @{ Name = "Scape.Infrastructure.Watchdog"; LoadOrder = 65; IsVital = $true; Domain = "Infrastructure"; ThreadSafe = $true }
    )

    Presentation   = @(
        @{ Name = "Scape.Presentation.Theme"; LoadOrder = 70; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Geometry"; LoadOrder = 71; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.TUI"; LoadOrder = 72; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Dispatcher"; LoadOrder = 73; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Renderer"; LoadOrder = 74; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.FilePicker"; LoadOrder = 75; IsVital = $false; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.ViewModel"; LoadOrder = 76; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Responsivity"; LoadOrder = 77; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.Router"; LoadOrder = 78; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.StateObserver"; LoadOrder = 79; IsVital = $true; Domain = "Presentation" }
        @{ Name = "Scape.Presentation.KeyBindings"; LoadOrder = 80; IsVital = $false; Domain = "Presentation" }
    )

    Extensions     = @(
        @{ Name = "Scape.Extensions.Database.Core"; LoadOrder = 80; IsVital = $true; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.Database.FragmentDB"; LoadOrder = 81; IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.Database.MetaDB"; LoadOrder = 82; IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.Network"; LoadOrder = 83; IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.CloudSync"; LoadOrder = 84; IsVital = $false; Domain = "Extensions" }
        @{ Name = "Scape.Extensions.BinWrappers"; LoadOrder = 85; IsVital = $false; Domain = "Extensions" }
    )

    Forensics      = @(
        @{ Name = "Scape.Forensics.NativeTools"; LoadOrder = 85; IsVital = $true; Domain = "Forensics" }
        @{ Name = "Scape.Forensics.ThirdPartyTools"; LoadOrder = 86; IsVital = $false; Domain = "Forensics" }
    )

    Forge          = @(
        @{ Name = "Scape.Forge.Ignite"; LoadOrder = 88; IsVital = $false; IsDeployEssential = $true; Domain = "Forge"; BuildTimeOnly = $true }
        @{ Name = "Scape.Forge.Build"; LoadOrder = 89; IsVital = $false; IsDeployEssential = $true; Domain = "Forge"; BuildTimeOnly = $true }
        @{ Name = "Scape.Forge.Compiler"; LoadOrder = 90; IsVital = $false; IsDeployEssential = $true; Domain = "Forge" }
        @{ Name = "Scape.Forge.Packager"; LoadOrder = 91; IsVital = $false; IsDeployEssential = $true; Domain = "Forge" }
        @{ Name = "Scape.Forge.Deployer"; LoadOrder = 92; IsVital = $true; IsDeployEssential = $true; Domain = "Forge" }
    )

    Orphans        = @()
}