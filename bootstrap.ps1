# bootstrap.ps1 - Entry point for declarative Windows setup
#
# Usage:
#   .\bootstrap.ps1
#   .\bootstrap.ps1 -DryRun

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    Write-Host "[setup] ERROR: This setup is only supported on Windows." -ForegroundColor Red
    exit 1
}

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "[setup] ERROR: PowerShell 5.1 or newer is required." -ForegroundColor Red
    exit 1
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[setup] Restarting as administrator..." -ForegroundColor Yellow
    $psExe = (Get-Process -Id $PID).Path
    if (-not $psExe) {
        $psExe = (Get-Command powershell -ErrorAction Stop).Source
    }
    $argList = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $(if ($DryRun) { '-DryRun' })"
    Start-Process $psExe $argList -Verb RunAs
    exit
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[setup] ERROR: winget was not found. Install App Installer before running setup." -ForegroundColor Red
    exit 1
}

winget list --accept-source-agreements 2>&1 | Out-Null

try {
    $networkAvailable = Test-NetConnection cdn.winget.microsoft.com -Port 443 -InformationLevel Quiet
} catch {
    $networkAvailable = $false
}
if (-not $networkAvailable) {
    Write-Host "[setup] ERROR: Cannot reach the winget package service. Check your network connection." -ForegroundColor Red
    exit 1
}

$settingsPath = Join-Path $PSScriptRoot "settings.json"
if (-not (Test-Path $settingsPath)) {
    Write-Host "[setup] ERROR: settings.json not found. Copy settings.example.json to settings.json and fill in the machine settings." -ForegroundColor Red
    exit 1
}
try {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
} catch {
    Write-Host "[setup] ERROR: settings.json contains invalid JSON. $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$configuredProfiles = @($settings.profiles | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$selectedProfiles = @()
if ($configuredProfiles.Count -gt 0) {
    $selectedProfiles = @($configuredProfiles | ForEach-Object { [string]$_ })
} else {
    $availableProfiles = @(Get-ChildItem (Join-Path $PSScriptRoot "setup\profiles\*.ps1") | Sort-Object Name | ForEach-Object { $_.BaseName })
    Write-Host "[setup] No profiles are configured in settings.json. Select profiles to preview or apply." -ForegroundColor Yellow
    if ($DryRun) {
        Write-Host "[setup] Dry run: profile selection only controls the preview; no changes will be made." -ForegroundColor Yellow
    }
    Write-Host "[setup] Available profiles:" -ForegroundColor Cyan
    foreach ($profile in $availableProfiles) {
        if ($profile -eq 'default') {
            Write-Host "  * $profile (selected initially)" -ForegroundColor Cyan
        } else {
            $answer = Read-Host "Include profile '$profile'? [y/N]"
            if ($answer -eq 'y' -or $answer -eq 'Y') {
                $selectedProfiles += $profile
            }
        }
    }
    if ($availableProfiles -contains 'default') {
        $selectedProfiles = @('default') + @($selectedProfiles | Where-Object { $_ -ne 'default' })
    }
}

if ($selectedProfiles -notcontains 'default') {
    Write-Host "[setup] ERROR: The default profile is required for every managed Windows machine." -ForegroundColor Red
    exit 1
}

& "$PSScriptRoot\setup\setup.ps1" -Profiles $selectedProfiles -DryRun:$DryRun
