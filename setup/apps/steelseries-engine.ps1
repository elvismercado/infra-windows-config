# SteelSeries Engine - SteelSeries device manager
#
# Category: Hardware
# Winget ID: SteelSeries.SteelSeriesEngine

function Get-App-SteelSeriesEngine {
    return @{
        Id           = "SteelSeries.SteelSeriesEngine"
        Name         = "SteelSeries Engine"
        Category     = "Hardware"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
