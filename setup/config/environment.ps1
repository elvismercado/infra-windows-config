# System environment setup

$directories = @(
    (Join-Path $HOME "git")
    (Join-Path $HOME "downloads")
    (Join-Path $HOME "documents")
    (Join-Path $HOME "projects")
    (Join-Path $HOME "scripts")
    (Join-Path $HOME "bin")
)

foreach ($directory in $directories) {
    if (Test-Path $directory) {
        Write-Info "Directory exists: $directory"
    } elseif ($DryRun) {
        Write-Info "Would create directory: $directory"
    } else {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        Write-Info "Created directory: $directory"
    }
}

$environmentVariables = @{
    DEV_HOME = Join-Path $HOME "git"
}
foreach ($entry in $environmentVariables.GetEnumerator()) {
    $currentValue = [Environment]::GetEnvironmentVariable($entry.Key, "User")
    if ($currentValue -eq $entry.Value) {
        continue
    }
    if ($DryRun) {
        Write-Info "Would set user environment variable $($entry.Key)=$($entry.Value)"
    } else {
        [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, "User")
        Set-Item -Path "Env:$($entry.Key)" -Value $entry.Value
        Write-Info "Set user environment variable $($entry.Key)=$($entry.Value)"
    }
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$currentPathEntries = @()
if (-not [string]::IsNullOrWhiteSpace($userPath)) {
    $currentPathEntries = @($userPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}
$pathEntries = @(
    (Join-Path $HOME "git")
    (Join-Path $HOME "bin")
)
$missingPathEntries = @($pathEntries | Where-Object { $_ -notin $currentPathEntries })
if ($missingPathEntries.Count -gt 0) {
    if ($DryRun) {
        Write-Info "Would add to user PATH: $($missingPathEntries -join '; ')"
    } else {
        $updatedUserPath = (($currentPathEntries + $missingPathEntries) -join ';')
        [Environment]::SetEnvironmentVariable("Path", $updatedUserPath, "User")
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $env:Path = @($updatedUserPath, $machinePath) -join ';'
        Write-Info "Added $($missingPathEntries.Count) user PATH entr(y/ies)"
    }
}

$expectedHostname = [string]$Settings.hostname
if (-not [string]::IsNullOrWhiteSpace($expectedHostname) -and $env:COMPUTERNAME -ine $expectedHostname) {
    if ($DryRun) {
        Write-Warn "Would rename computer to $expectedHostname"
    } elseif (Confirm-Step "Computer name is '$env:COMPUTERNAME'. Rename it to '$expectedHostname'?") {
        try {
            Rename-Computer -NewName $expectedHostname -Force -ErrorAction Stop
            Write-Info "Computer renamed to $expectedHostname. Reboot required for the change to take effect."
        } catch {
            Write-Warn "Could not rename computer to $expectedHostname. $($_.Exception.Message)"
        }
    }
}
