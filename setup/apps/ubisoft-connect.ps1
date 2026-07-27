# Ubisoft Connect - Ubisoft game client
#
# Category: Gaming
# Winget ID: Ubisoft.Connect

function Get-App-UbisoftConnect {
    return @{
        Id           = "Ubisoft.Connect"
        Name         = "Ubisoft Connect"
        Category     = "Gaming"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
