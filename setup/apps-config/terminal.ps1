# Windows Terminal post-install configuration placeholder

$terminalCommand = Get-Command wt -ErrorAction SilentlyContinue
$terminalPackage = $null
if (-not $terminalCommand -and (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue)) {
    $terminalPackage = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
}

if (-not $terminalCommand -and -not $terminalPackage) {
    Write-Warn "Windows Terminal was not found. Skipping terminal configuration."
    return
}

Write-Info "Windows Terminal is installed. Importing terminal settings is intentionally a placeholder."
