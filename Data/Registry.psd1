@{
    SchemaVersion = "1.0"
    Segments      = @{
        # --- Categoria: Constants ---
        "core"       = @{ File = "Data\Constants\core.psd1"; Category = "Constants" }
        "dir"        = @{ File = "Data\Constants\dir.psd1"; Category = "Constants" }
        "compliance" = @{ File = "Data\Constants\compliance.psd1"; Category = "Constants" }
        "behavior"   = @{ File = "Data\Constants\behavior.psd1"; Category = "Constants" }
        "fs"         = @{ File = "Data\Constants\fs.psd1"; Category = "Constants" }
        "carving"    = @{ File = "Data\Constants\carving.psd1"; Category = "Constants" }
        "db"         = @{ File = "Data\Constants\db.psd1"; Category = "Constants" }
        "hardware"   = @{ File = "Data\Constants\hardware.psd1"; Category = "Constants" }
        "io"         = @{ File = "Data\Constants\io.psd1"; Category = "Constants" }
        "net"        = @{ File = "Data\Constants\net.psd1"; Category = "Constants" }
        "theme"      = @{ File = "Data\Constants\theme.psd1"; Category = "Constants" }
        "ui"         = @{ File = "Data\Constants\ui.psd1"; Category = "Constants" }
        "events"     = @{ File = "Data\Constants\events.psd1"; Category = "Constants" }
        "deploy"     = @{ File = "Data\Constants\deploy.psd1"; Category = "Constants" }

        # --- Categoria: I18N ---
        "en-US"      = @{ File = "Data\I18N\en-US.psd1"; Category = "I18N" }
        "pt-BR"      = @{ File = "Data\I18N\pt-BR.psd1"; Category = "I18N" }

        # --- Categoria: Manifests ---
        "menu"       = @{ File = "Data\Manifests\Menu.psd1"; Category = "Manifests" }
        "topology"   = @{ File = "Data\Manifests\Topology.psd1"; Category = "Manifests" }
    }
}