# Install the built-in OpenSSH Client capability for the development profile.

if ($Profiles -notcontains 'development') {
    return
}

$capabilityName = 'OpenSSH.Client~~~~0.0.1.0'
$capability = Get-WindowsCapability -Online -Name $capabilityName
if ($capability.State -eq 'Installed') {
    Write-Info "OpenSSH Client is already installed"
    return
}

if ($DryRun) {
    Write-Info "Would install Windows capability $capabilityName"
    return
}

Add-WindowsCapability -Online -Name $capabilityName | Out-Null
Write-Info "Installed OpenSSH Client"
