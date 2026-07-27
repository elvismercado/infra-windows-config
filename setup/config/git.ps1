# Interactive git identity and defaults setup

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Warn "git was not found in PATH. Skipping git configuration."
    return
}

$currentName = (& git config --global user.name 2>$null | Out-String).Trim()
$currentEmail = (& git config --global user.email 2>$null | Out-String).Trim()

if ($DryRun) {
    Write-Info "Current git user.name: $(if ($currentName) { $currentName } else { '<not set>' })"
    Write-Info "Current git user.email: $(if ($currentEmail) { $currentEmail } else { '<not set>' })"
    if (-not $currentName) {
        Write-Info "Would prompt to set git user.name, suggesting '$($Settings.username)'"
    }
    if (-not $currentEmail) {
        Write-Info "Would prompt to set git user.email"
    }
    Write-Info "Would set git init.defaultBranch to main"
    $dryRunEditor = if (Get-Command code -ErrorAction SilentlyContinue) { 'code --wait' } else { 'notepad.exe' }
    Write-Info "Would set git core.editor to $dryRunEditor"
    return
}

if (-not $currentName) {
    $suggestedName = [string]$Settings.username
    $nameAnswer = Read-Host "Git user.name [$suggestedName]"
    if ([string]::IsNullOrWhiteSpace($nameAnswer)) {
        $nameAnswer = $suggestedName
    }
    if (-not [string]::IsNullOrWhiteSpace($nameAnswer)) {
        git config --global user.name $nameAnswer
        Write-Info "Set git user.name to $nameAnswer"
    }
} else {
    Write-Info "Keeping existing git user.name: $currentName"
}

if (-not $currentEmail) {
    $emailAnswer = Read-Host "Git user.email"
    if (-not [string]::IsNullOrWhiteSpace($emailAnswer)) {
        git config --global user.email $emailAnswer
        Write-Info "Set git user.email"
    }
} else {
    Write-Info "Keeping existing git user.email: $currentEmail"
}

git config --global init.defaultBranch main
$preferredEditor = if (Get-Command code -ErrorAction SilentlyContinue) { 'code --wait' } else { 'notepad.exe' }
git config --global core.editor $preferredEditor
Write-Info "Configured git default branch and editor: $preferredEditor"
