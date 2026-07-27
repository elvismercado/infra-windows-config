# 7-Zip - Archive utility
#
# Category: System
# Winget ID: 7zip.7zip

function Get-App-7Zip {
    return @{
        Id           = "7zip.7zip"
        Name         = "7-Zip"
        Category     = "System"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
