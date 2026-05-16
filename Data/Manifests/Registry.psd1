@{
    __Meta__ = @{
        Name    = "Registry"
        Version = "1.0"
        Author  = "Scape.Core"
        Purpose = "System registry manifest. Define assets, constants, and manifests available for loading."
    }

    Segments = @{
        # Core
        "system"         = @{ File = "Data\Constants\system.psd1"; Category = "Constants"; Layer = "Core"; LoadOrder = 1; IsLazy = $false }
        # Presentation
        "ui"             = @{ File = "Data\Constants\ui.psd1"; Category = "Constants"; Layer = "Presentation"; LoadOrder = 31; IsLazy = $false }
        "theme"          = @{ File = "Data\Constants\theme.psd1"; Category = "Constants"; Layer = "Presentation"; LoadOrder = 30; IsLazy = $false }
        # Infrastructure
        "infrastructure" = @{ File = "Data\Constants\infrastructure.psd1"; Category = "Constants"; Layer = "Infrastructure"; LoadOrder = 20; IsLazy = $false }
        # Storage
        "storage"        = @{ File = "Data\Constants\storage.psd1"; Category = "Constants"; Layer = "Acquisition"; LoadOrder = 23; IsLazy = $true }
        # Network & DB
        "network"        = @{ File = "Data\Constants\network.psd1"; Category = "Constants"; Layer = "Extended"; LoadOrder = 24; IsLazy = $true }
        # Forge
        "forge"          = @{ File = "Data\Constants\forge.psd1"; Category = "Constants"; Layer = "Forge"; LoadOrder = 26; IsLazy = $false }
        # i18n (lazy)
        "en-US"          = @{ File = "Data\I18N\en-US.psd1"; Category = "I18N"; Layer = "Presentation"; LoadOrder = 10; IsLazy = $false }
        "pt-BR"          = @{ File = "Data\I18N\pt-BR.psd1"; Category = "I18N"; Layer = "Presentation"; LoadOrder = 11; IsLazy = $true }
        # Routing (não lazy)
        "topology"       = @{ File = "Data\Manifests\Topology.psd1"; Category = "Manifests"; Layer = "Routing"; LoadOrder = 4; IsLazy = $false }
        "navigation"     = @{ File = "Data\Manifests\Navigation.psd1"; Category = "Manifests"; Layer = "Routing"; LoadOrder = 5; IsLazy = $false }
        "registry"       = @{ File = "Data\Manifests\Registry.psd1"; Category = "Manifests"; Layer = "Routing"; LoadOrder = 6; IsLazy = $false }
    }
}