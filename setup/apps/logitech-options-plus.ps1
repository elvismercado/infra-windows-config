# Logitech Options+ - Logitech productivity device manager
#
# Category: Hardware
# Winget ID: Logitech.OptionsPlus

function Get-App-LogitechOptionsPlus {
    return @{
        Id           = "Logitech.OptionsPlus"
        Name         = "Logitech Options+"
        Category     = "Hardware"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
