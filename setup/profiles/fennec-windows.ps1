# Fennec Windows profile - gaming, media, hardware, and development apps
#
# Host: fennec-windows (profile ID; actual hostname comes from settings.json)

# System
. "$PSScriptRoot/../apps/sunshine.ps1"

# Development
. "$PSScriptRoot/../apps/vscode.ps1"

# Communication
. "$PSScriptRoot/../apps/vesktop.ps1"
. "$PSScriptRoot/../apps/beeper.ps1"

# Media
. "$PSScriptRoot/../apps/vlc.ps1"
. "$PSScriptRoot/../apps/shotcut.ps1"

# Gaming
. "$PSScriptRoot/../apps/steam.ps1"
. "$PSScriptRoot/../apps/ea-desktop.ps1"
. "$PSScriptRoot/../apps/ubisoft-connect.ps1"
. "$PSScriptRoot/../apps/heroic.ps1"
. "$PSScriptRoot/../apps/clone-hero.ps1"
. "$PSScriptRoot/../apps/dlss-swapper.ps1"

# Hardware
. "$PSScriptRoot/../apps/steelseries-engine.ps1"
. "$PSScriptRoot/../apps/logitech-ghub.ps1"
. "$PSScriptRoot/../apps/logitech-options-plus.ps1"
. "$PSScriptRoot/../apps/nanoleaf-desktop.ps1"
. "$PSScriptRoot/../apps/fan-control.ps1"
. "$PSScriptRoot/../apps/afterburner.ps1"
. "$PSScriptRoot/../apps/rtss.ps1"

function Get-FennecWindowsApps {
    return @(
        # System
        Get-App-Sunshine
        # Development
        Get-App-VSCode
        # Communication
        Get-App-Vesktop
        Get-App-Beeper
        # Media
        Get-App-VLC
        Get-App-Shotcut
        # Gaming
        Get-App-Steam
        Get-App-EADesktop
        Get-App-UbisoftConnect
        Get-App-Heroic
        Get-App-CloneHero
        Get-App-DLSSSwapper
        # Hardware
        Get-App-SteelSeriesEngine
        Get-App-LogitechGHub
        Get-App-LogitechOptionsPlus
        Get-App-NanoleafDesktop
        Get-App-FanControl
        Get-App-Afterburner
        Get-App-RTSS
    )
}
