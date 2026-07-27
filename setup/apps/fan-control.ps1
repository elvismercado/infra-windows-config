# Fan Control - System fan control utility
#
# Category: Hardware
# Winget ID: Rem0o.FanControl

function Get-App-FanControl {
    return @{
        Id           = "Rem0o.FanControl"
        Name         = "Fan Control"
        Category     = "Hardware"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
