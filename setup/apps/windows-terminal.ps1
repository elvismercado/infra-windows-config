# Windows Terminal - Modern terminal emulator
#
# Category: System
# Winget ID: Microsoft.WindowsTerminal

function Get-App-WindowsTerminal {
    return @{
        Id           = "Microsoft.WindowsTerminal"
        Name         = "Windows Terminal"
        Category     = "System"
        ConfigScript = "$PSScriptRoot/../apps-config/terminal.ps1"
    }
}
