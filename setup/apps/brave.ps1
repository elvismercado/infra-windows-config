# Brave - Privacy-focused web browser
#
# Category: Browsers
# Winget ID: Brave.Brave

function Get-App-Brave {
    return @{
        Id           = "Brave.Brave"
        Name         = "Brave"
        Category     = "Browsers"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
