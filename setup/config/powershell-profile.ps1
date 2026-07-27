# Bootstrap the user's PowerShell profile without replacing existing content

if ([string]::IsNullOrWhiteSpace($PROFILE)) {
    Write-Warn "PowerShell profile path is unavailable. Skipping profile setup."
    return
}

$contentScriptPath = (Resolve-Path (Join-Path $PSScriptRoot "powershell-profile-content.ps1")).Path
$sourceLine = ". `"$contentScriptPath`""
$profileExists = Test-Path $PROFILE
$existingContent = if ($profileExists) { Get-Content $PROFILE -Raw } else { '' }

if ($existingContent -match [regex]::Escape($sourceLine)) {
    Write-Info "PowerShell profile already loads $contentScriptPath"
    return
}

if ($DryRun) {
    Write-Info "Would add to PowerShell profile ${PROFILE}: $sourceLine"
    return
}

if (-not $profileExists) {
    $profileDirectory = Split-Path -Parent $PROFILE
    if (-not (Test-Path $profileDirectory)) {
        New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    }
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$updatedContent = if ([string]::IsNullOrEmpty($existingContent)) {
    $sourceLine + [Environment]::NewLine
} else {
    $existingContent.TrimEnd() + [Environment]::NewLine + $sourceLine + [Environment]::NewLine
}
Set-Content -Path $PROFILE -Value $updatedContent -Encoding UTF8
Write-Info "Added repository PowerShell profile content to $PROFILE"
