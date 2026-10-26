param(
    [Parameter(Mandatory)]
    [string[]]$Profiles,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\helpers.ps1"

Start-Log
$timer = Start-SetupTimer
$Settings = Get-Settings

Write-Info "Host:     $($Settings.hostname)"
Write-Info "Profiles: $($Profiles -join ', ')"
if ($DryRun) { Write-Warn "DRY RUN - no changes will be made" }

$script:Apps = @()

function Step-CollectApps {
    $availableProfiles = @(Get-ChildItem "$PSScriptRoot\profiles\*.ps1" | ForEach-Object { $_.BaseName })
    if ($Profiles -notcontains 'default') {
        Write-Err "The default profile is required for every managed Windows machine. Select 'default' explicitly."
        exit 1
    }
    foreach ($p in $Profiles) {
        if ($p -notmatch '^[a-z]+(?:-[a-z]+)*$') {
            Write-Err "Invalid profile name '$p'. Profile names must use lowercase words separated by single hyphens."
            exit 1
        }
        if ($p -notin $availableProfiles) {
            Write-Err "Unknown profile '$p'. Available: $($availableProfiles -join ', ')"
            exit 1
        }
    }

    $allApps = @()
    foreach ($p in $Profiles) {
        . "$PSScriptRoot\profiles\$p.ps1"
        # Convert a profile such as "fennec-windows" to "Get-FennecWindowsApps".
        $nameParts = $p -split '-'
        $functionSuffix = ($nameParts | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) }) -join ''
        $funcName = "Get-${functionSuffix}Apps"
        if (-not (Get-Command $funcName -CommandType Function -ErrorAction SilentlyContinue)) {
            Write-Err "Profile function '$funcName' was not found in '$p.ps1'"
            exit 1
        }
        $allApps += & $funcName
    }

    $seenIds = @{}
    $script:Apps = @(
        foreach ($app in $allApps) {
            if (-not $seenIds.ContainsKey($app.Id)) {
                $seenIds[$app.Id] = $true
                $app
            }
        }
    )
    if ($Settings.PSObject.Properties['excludeApps'] -and $Settings.excludeApps.Count -gt 0) {
        $script:Apps = @($script:Apps | Where-Object { $_.Id -notin $Settings.excludeApps })
        Write-Info "Excluded $($Settings.excludeApps.Count) app(s) per settings"
    }

    Write-Info "Apps to install ($($script:Apps.Count)):"
    foreach ($app in $script:Apps) {
        Write-Info "  - $($app.Name) ($($app.Id))"
    }
    if (-not $DryRun -and -not (Confirm-Step "Proceed with installation?")) {
        Write-Warn "Aborted by user."
        exit 0
    }
}

function Step-InstallApps {
    $failures = @()
    foreach ($app in $script:Apps) {
        $listOutput = winget list --id $app.Id --accept-source-agreements 2>&1 | Out-String
        $isInstalled = $listOutput -match "(?m)(^|\s)$([regex]::Escape($app.Id))(\s|$)"
        if ($isInstalled) {
            Write-Info "Already installed: $($app.Name)"
            continue
        }
        if ($DryRun) {
            Write-Info "Would install: $($app.Name) ($($app.Id))"
            continue
        }
        winget install --id $app.Id --accept-source-agreements --accept-package-agreements 2>&1
        $installExitCode = $LASTEXITCODE
        if ($installExitCode -ne 0) {
            $failures += $app.Name
            Write-Warn "Failed to install $($app.Name) (exit code $installExitCode)"
        } else {
            Write-Info "Installed: $($app.Name)"
        }
    }
    if ($failures.Count -gt 0) {
        Write-Warn "Failed to install $($failures.Count) app(s): $($failures -join ', ')"
    }
}

function Step-ConfigureSystem {
    $configScripts = @(
        (Join-Path $PSScriptRoot "config\environment.ps1")
        (Join-Path $PSScriptRoot "config\git.ps1")
        (Join-Path $PSScriptRoot "config\openssh.ps1")
        (Join-Path $PSScriptRoot "config\powershell-profile.ps1")
    )
    foreach ($configScript in $configScripts) {
        if ($DryRun) {
            Write-Info "Would execute: $configScript"
            continue
        }
        try {
            . $configScript
        } catch {
            Write-Warn "Config script failed: $configScript. $($_.Exception.Message)"
        }
    }
}

function Resolve-AppConfigScript {
    param([string]$ConfigScript)
    if (Test-Path $ConfigScript) {
        return (Resolve-Path $ConfigScript).Path
    }
    $fallback = Join-Path (Join-Path $PSScriptRoot "apps-config") ([IO.Path]::GetFileName($ConfigScript))
    if (Test-Path $fallback) {
        return (Resolve-Path $fallback).Path
    }
    return $ConfigScript
}

function Step-RunConfigScripts {
    foreach ($app in $script:Apps) {
        if ($null -eq $app.ConfigScript) {
            continue
        }
        $configScript = Resolve-AppConfigScript $app.ConfigScript
        if (-not (Test-Path $configScript)) {
            Write-Warn "Config script not found for $($app.Name): $configScript"
            continue
        }
        if ($DryRun) {
            Write-Info "Would execute: $configScript"
            continue
        }
        try {
            . $configScript
        } catch {
            Write-Warn "App config script failed for $($app.Name): $($_.Exception.Message)"
        }
    }
}

Step-CollectApps
Step-InstallApps
Step-ConfigureSystem
Step-RunConfigScripts
Write-Elapsed $timer
