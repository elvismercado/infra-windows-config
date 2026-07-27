# EA Desktop - Electronic Arts game client
#
# Category: Gaming
# Winget ID: ElectronicArts.EADesktop

function Get-App-EADesktop {
    return @{
        Id           = "ElectronicArts.EADesktop"
        Name         = "EA Desktop"
        Category     = "Gaming"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
