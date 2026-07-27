# Visual Studio Code - Development editor
#
# Category: Development
# Winget ID: Microsoft.VisualStudioCode

function Get-App-VSCode {
    return @{
        Id           = "Microsoft.VisualStudioCode"
        Name         = "Visual Studio Code"
        Category     = "Development"
        ConfigScript = "$PSScriptRoot/../apps-config/vscode.ps1"
    }
}
