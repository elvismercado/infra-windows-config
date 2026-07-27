# Beeper - Unified messaging client
#
# Category: Communication
# Winget ID: Beeper.Beeper

function Get-App-Beeper {
    return @{
        Id           = "Beeper.Beeper"
        Name         = "Beeper"
        Category     = "Communication"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
