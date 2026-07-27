# VLC - Media player
#
# Category: Media
# Winget ID: VideoLAN.VLC

function Get-App-VLC {
    return @{
        Id           = "VideoLAN.VLC"
        Name         = "VLC"
        Category     = "Media"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
