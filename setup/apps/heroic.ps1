# Heroic Games Launcher - Open-source game launcher
#
# Category: Gaming
# Winget ID: HeroicGamesLauncher.HeroicGamesLauncher

function Get-App-Heroic {
    return @{
        Id           = "HeroicGamesLauncher.HeroicGamesLauncher"
        Name         = "Heroic Games Launcher"
        Category     = "Gaming"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
