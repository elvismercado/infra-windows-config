# Default profile - minimum apps for every managed Windows machine

# System
. "$PSScriptRoot/../apps/7zip.ps1"
. "$PSScriptRoot/../apps/synctrayzor.ps1"
. "$PSScriptRoot/../apps/powertoys.ps1"
. "$PSScriptRoot/../apps/windows-terminal.ps1"

# Browsers
. "$PSScriptRoot/../apps/brave.ps1"

function Get-DefaultApps {
    return @(
        # System
        Get-App-7Zip
        Get-App-SyncTrayzor
        Get-App-PowerToys
        Get-App-WindowsTerminal
        # Browsers
        Get-App-Brave
    )
}
