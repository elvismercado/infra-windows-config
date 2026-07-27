# MSI Afterburner - GPU monitoring and tuning utility
#
# Category: Hardware
# Winget ID: Guru3D.Afterburner

function Get-App-Afterburner {
    return @{
        Id           = "Guru3D.Afterburner"
        Name         = "MSI Afterburner"
        Category     = "Hardware"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
