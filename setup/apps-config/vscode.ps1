# Post-install Visual Studio Code configuration

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Warn "code was not found in PATH. Skipping VS Code extension setup."
    return
}

$extensions = @()
if ($extensions.Count -eq 0) {
    Write-Info "No curated VS Code extensions are configured yet."
    return
}

foreach ($extension in $extensions) {
    if ($DryRun) {
        Write-Info "Would install VS Code extension: $extension"
        continue
    }
    code --install-extension $extension
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Failed to install VS Code extension: $extension"
    } else {
        Write-Info "Installed VS Code extension: $extension"
    }
}
