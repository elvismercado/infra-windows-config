# Steam - PC game store and launcher
#
# Category: Gaming
# Winget ID: Valve.Steam

function Get-App-Steam {
    return @{
        Id           = "Valve.Steam"
        Name         = "Steam"
        Category     = "Gaming"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
