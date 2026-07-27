# Logitech G HUB - Logitech gaming device manager
#
# Category: Hardware
# Winget ID: Logitech.GHUB

function Get-App-LogitechGHub {
    return @{
        Id           = "Logitech.GHUB"
        Name         = "Logitech G HUB"
        Category     = "Hardware"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
