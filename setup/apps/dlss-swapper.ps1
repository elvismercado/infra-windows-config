# DLSS Swapper - NVIDIA DLSS version manager
#
# Category: Gaming
# Winget ID: beeradmoore.dlss-swapper

function Get-App-DLSSSwapper {
    return @{
        Id           = "beeradmoore.dlss-swapper"
        Name         = "DLSS Swapper"
        Category     = "Gaming"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
