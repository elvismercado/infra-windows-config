# SyncTrayzor - Syncthing tray application
#
# Category: System
# Winget ID: GermanCoding.SyncTrayzor

function Get-App-SyncTrayzor {
    return @{
        Id           = "GermanCoding.SyncTrayzor"
        Name         = "SyncTrayzor"
        Category     = "System"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
