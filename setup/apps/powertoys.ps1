# PowerToys - Windows productivity utilities
#
# Category: System
# Winget ID: Microsoft.PowerToys

function Get-App-PowerToys {
    return @{
        Id           = "Microsoft.PowerToys"
        Name         = "PowerToys"
        Category     = "System"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
