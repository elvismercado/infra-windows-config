# Development profile - editor, version managers, and source control

. "$PSScriptRoot/../apps/fnm.ps1"
. "$PSScriptRoot/../apps/git.ps1"
. "$PSScriptRoot/../apps/github-cli.ps1"
. "$PSScriptRoot/../apps/python.ps1"
. "$PSScriptRoot/../apps/uv.ps1"
. "$PSScriptRoot/../apps/vscode.ps1"

function Get-DevelopmentApps {
    return @(
        Get-App-Fnm
        Get-App-Git
        Get-App-GitHubCli
        Get-App-Python
        Get-App-Uv
        Get-App-VSCode
    )
}
