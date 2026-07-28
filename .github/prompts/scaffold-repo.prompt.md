---
description: "Scaffold a declarative Windows setup repo from seed data. Creates folder structure, bootstrap script, app catalog, profiles, config scripts, docs, and Copilot instructions."
agent: "agent"
argument-hint: "No arguments needed — reads seed files from the scaffolding folder"
---

Scaffold a complete declarative Windows setup repository in the current workspace root. Read the preserved seed data from `scaffolding/`, then create the generated setup files beside that folder. Do not move, delete, or overwrite the seed files.

## 1. Read seed data

Read these files from `scaffolding/` before generating anything:

| File                     | What to do with it                                                              |
| ------------------------ | ------------------------------------------------------------------------------- |
| `scaffolding/winget-packages.json`   | Parse the `Packages` array → create one app script per package in `setup/apps/` |
| `scaffolding/keyboard-manager.json`  | Copy to `setup/config/powertoys/keyboard-manager.json` as a reference file       |
| `scaffolding/fancyzones-layout.json` | Copy to `setup/config/powertoys/fancyzones-layout.json` as a reference file      |
| `scaffolding/README.md`              | Copy to `docs/SHORTCUTS.md` and rewrite its JSON links to generated paths       |

The `scaffolding/` directory is source/reference data and must remain unchanged.

## 2. Create folder structure

```
├── scaffolding/                 (existing seed files — preserve unchanged)
│   ├── winget-packages.json
│   ├── keyboard-manager.json
│   ├── fancyzones-layout.json
│   └── README.md
├── README.md
├── .gitignore
├── settings.example.json
├── bootstrap.ps1
├── setup/
│   ├── setup.ps1
│   ├── helpers.ps1
│   ├── profiles/
│   │   ├── default.ps1
│   │   └── fennec-windows.ps1
│   ├── apps/
│   │   └── (one .ps1 per app — see Step 5)
│   ├── config/
│   │   ├── environment.ps1
│   │   ├── git.ps1
│   │   ├── powershell-profile.ps1
│   │   ├── powershell-profile-content.ps1
│   │   └── powertoys/
│   │       ├── README.md
│   │       ├── fancyzones-layout.json
│   │       └── keyboard-manager.json
│   └── apps-config/
│       ├── vscode.ps1
│       └── terminal.ps1
├── unattend/
│   ├── autounattend.xml
│   └── README.md
├── docs/
│   ├── PROFILES.md
│   ├── APP-LIST.md
│   └── SHORTCUTS.md
└── .github/
    ├── copilot-instructions.md
    └── prompts/
        ├── scaffold-repo.prompt.md
        ├── review-prompt.prompt.md
        ├── add-app.prompt.md
        ├── add-profile.prompt.md
        └── update-docs.prompt.md
```

## 3. Generate `settings.example.json`, `.gitignore`

### `settings.example.json`

Template for per-machine identity. The user copies this to `settings.json` and fills it in per machine.

The example below targets `fennec-windows`, the gaming Windows OS on the FENNEC dual-boot machine. For another Windows machine, remove `fennec-windows` and keep only `default` until a dedicated host profile exists.

```json
{
  "hostname": "MY-PC",
  "username": "myuser",
    "profiles": ["default", "fennec-windows"],
  "excludeApps": []
}
```

Every managed Windows machine must explicitly select `default`. Add `fennec-windows` for the Windows OS on the FENNEC dual-boot gaming machine. Profile IDs are repository names; `hostname` is the actual Windows computer name and is not derived from the profile name. All scripts read `$Settings` from this file — never hardcode hostname or username.

### `.gitignore`

```gitignore
settings.json
setup.log
```

`settings.json` contains per-machine identity and is not committed. Users create it by copying `settings.example.json`.

## 4. Generate `setup/helpers.ps1`

Shared helper functions dot-sourced by all other scripts. Include:

### Log file setup

```powershell
$script:LogFile = Join-Path (Join-Path $PSScriptRoot "..") "setup.log"

function Start-Log {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $script:LogFile -Value "`n===== Setup started at $timestamp ====="
}
```

### Colored logging

All log functions write to both the console and `setup.log`.

```powershell
function Write-Info  { param([string]$Message) Write-Host "[setup] $Message" -ForegroundColor Green;  Add-Content -Path $script:LogFile -Value "[INFO]  $Message" }
function Write-Warn  { param([string]$Message) Write-Host "[setup] $Message" -ForegroundColor Yellow; Add-Content -Path $script:LogFile -Value "[WARN]  $Message" }
function Write-Err   { param([string]$Message) Write-Host "[setup] $Message" -ForegroundColor Red;    Add-Content -Path $script:LogFile -Value "[ERROR] $Message" }
```

### Confirm prompt

```powershell
function Confirm-Step {
    param([string]$Prompt)
    $answer = Read-Host "$Prompt [y/N]"
    return ($answer -eq 'y' -or $answer -eq 'Y')
}
```

### Settings loader

```powershell
function Get-Settings {
    $settingsPath = Join-Path (Join-Path $PSScriptRoot "..") "settings.json"
    if (-not (Test-Path $settingsPath)) {
        Write-Err "settings.json not found at $settingsPath"
        exit 1
    }
    return Get-Content $settingsPath -Raw | ConvertFrom-Json
}
```

### Timer

```powershell
function Start-SetupTimer { return [Diagnostics.Stopwatch]::StartNew() }
function Write-Elapsed {
    param([Diagnostics.Stopwatch]$Timer)
    $elapsed = $Timer.Elapsed
    Write-Info ("Total time: {0}m {1}s" -f [int]$elapsed.TotalMinutes, $elapsed.Seconds)
}
```

## 5. Generate per-app scripts in `setup/apps/`

For each package in `scaffolding/winget-packages.json`, plus the additional packages listed below, create a script file. Use lowercase-kebab naming derived from the package name (not the winget ID).

Additional packages not in `winget-packages.json` (add these to the app catalog as well):

- `Microsoft.PowerToys` — PowerToys (system utility; its seed files are reference-only)
- `Microsoft.VisualStudioCode` — Visual Studio Code (development editor)
- `Microsoft.WindowsTerminal` — Windows Terminal (modern terminal emulator)

### App script template

Every app script defines a single function `Get-App-<PascalName>` that returns a hashtable:

```powershell
# <App Display Name> — <one-line description>
#
# Category: <category>
# Winget ID: <PackageIdentifier>

function Get-App-<PascalName> {
    return @{
        Id           = "<PackageIdentifier>"
        Name         = "<App Display Name>"
        Category     = "<category>"
        ConfigScript = $null  # Path to apps-config script, or $null if none
    }
}
```

### ConfigScript linking

Apps that have a corresponding post-install config script in `setup/apps-config/` must set the `ConfigScript` path so `Step-RunConfigScripts` executes them:

- `Microsoft.VisualStudioCode` → `ConfigScript = "$PSScriptRoot/../apps-config/vscode.ps1"`
- `Microsoft.WindowsTerminal` → `ConfigScript = "$PSScriptRoot/../apps-config/terminal.ps1"`

### Categorization

Assign each package from `winget-packages.json` to a category:

| Category      | Winget IDs                                                                                                                                                     |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Browsers      | `Brave.Brave`                                                                                                                                                  |
| Communication | `Vencord.Vesktop`, `Beeper.Beeper`                                                                                                                             |
| Development   | `Microsoft.VisualStudioCode`                                                                                                                                   |
| Gaming        | `Valve.Steam`, `Ubisoft.Connect`, `ElectronicArts.EADesktop`, `HeroicGamesLauncher.HeroicGamesLauncher`, `CloneHeroTeam.CloneHero`, `beeradmoore.dlss-swapper` |
| Hardware      | `SteelSeries.SteelSeriesEngine`, `Logitech.GHUB`, `Logitech.OptionsPlus`, `Nanoleaf.NanoleafDesktop`, `Rem0o.FanControl`, `Guru3D.Afterburner`, `Guru3D.RTSS`  |
| Media         | `VideoLAN.VLC`, `Meltytech.Shotcut`                                                                                                                            |
| System        | `7zip.7zip`, `LizardByte.Sunshine`, `GermanCoding.SyncTrayzor`, `Microsoft.PowerToys`, `Microsoft.WindowsTerminal`                                             |

### File naming

Derive the filename from the app display name, lowercased and kebab-cased:

- `Brave.Brave` → `brave.ps1`
- `Valve.Steam` → `steam.ps1`
- `Guru3D.Afterburner` → `afterburner.ps1`
- `Guru3D.RTSS` → `rtss.ps1`
- `Logitech.OptionsPlus` → `logitech-options-plus.ps1`
- `Logitech.GHUB` → `logitech-ghub.ps1`
- `GermanCoding.SyncTrayzor` → `synctrayzor.ps1`
- `HeroicGamesLauncher.HeroicGamesLauncher` → `heroic.ps1`
- `beeradmoore.dlss-swapper` → `dlss-swapper.ps1`
- `CloneHeroTeam.CloneHero` → `clone-hero.ps1`
- `Rem0o.FanControl` → `fan-control.ps1`
- `ElectronicArts.EADesktop` → `ea-desktop.ps1`
- `Vencord.Vesktop` → `vesktop.ps1`
- `Beeper.Beeper` → `beeper.ps1`
- `SteelSeries.SteelSeriesEngine` → `steelseries-engine.ps1`
- `Nanoleaf.NanoleafDesktop` → `nanoleaf-desktop.ps1`
- `Meltytech.Shotcut` → `shotcut.ps1`
- `VideoLAN.VLC` → `vlc.ps1`
- `LizardByte.Sunshine` → `sunshine.ps1`
- `7zip.7zip` → `7zip.ps1`
- `Ubisoft.Connect` → `ubisoft-connect.ps1`
- `Microsoft.PowerToys` → `powertoys.ps1`
- `Microsoft.VisualStudioCode` → `vscode.ps1`
- `Microsoft.WindowsTerminal` → `windows-terminal.ps1`

### App function naming

Derive each app function name from its lowercase-kebab filename by PascalCasing every hyphen-separated part. Preserve established product acronyms such as `DLSS` and `RTSS`. For example, `dlss-swapper.ps1` defines `Get-App-DLSSSwapper`, and `fan-control.ps1` defines `Get-App-FanControl`.

## 6. Generate profile scripts in `setup/profiles/`

Profiles are standalone and do not dot-source one another. `default.ps1` is the minimum baseline for every managed Windows machine. `fennec-windows.ps1` contains additions for the Windows OS on the FENNEC dual-boot gaming machine. Group imports by category with comments.

### default.ps1 — Minimum Windows baseline

```powershell
# Default profile — minimum apps for every managed Windows machine

# System
. "$PSScriptRoot/../apps/7zip.ps1"
. "$PSScriptRoot/../apps/synctrayzor.ps1"
. "$PSScriptRoot/../apps/powertoys.ps1"
. "$PSScriptRoot/../apps/windows-terminal.ps1"

# Browsers
. "$PSScriptRoot/../apps/brave.ps1"

function Get-DefaultApps {
    return @(
        # System
        Get-App-7Zip
        Get-App-SyncTrayzor
        Get-App-PowerToys
        Get-App-WindowsTerminal
        # Browsers
        Get-App-Brave
    )
}
```

### fennec-windows.ps1 — Gaming Windows host additions

This profile is intentionally standalone and does not import `default.ps1`. Select it together with `default` in `settings.json`.

```powershell
# Fennec Windows profile — gaming, media, hardware, and development apps
#
# Host: fennec-windows (profile ID; actual hostname comes from settings.json)

# System
. "$PSScriptRoot/../apps/sunshine.ps1"

# Development
. "$PSScriptRoot/../apps/vscode.ps1"

# Communication
. "$PSScriptRoot/../apps/vesktop.ps1"
. "$PSScriptRoot/../apps/beeper.ps1"

# Media
. "$PSScriptRoot/../apps/vlc.ps1"
. "$PSScriptRoot/../apps/shotcut.ps1"

# Gaming
. "$PSScriptRoot/../apps/steam.ps1"
. "$PSScriptRoot/../apps/ea-desktop.ps1"
. "$PSScriptRoot/../apps/ubisoft-connect.ps1"
. "$PSScriptRoot/../apps/heroic.ps1"
. "$PSScriptRoot/../apps/clone-hero.ps1"
. "$PSScriptRoot/../apps/dlss-swapper.ps1"

# Hardware
. "$PSScriptRoot/../apps/steelseries-engine.ps1"
. "$PSScriptRoot/../apps/logitech-ghub.ps1"
. "$PSScriptRoot/../apps/logitech-options-plus.ps1"
. "$PSScriptRoot/../apps/nanoleaf-desktop.ps1"
. "$PSScriptRoot/../apps/fan-control.ps1"
. "$PSScriptRoot/../apps/afterburner.ps1"
. "$PSScriptRoot/../apps/rtss.ps1"

function Get-FennecWindowsApps {
    return @(
        # System
        Get-App-Sunshine
        # Development
        Get-App-VSCode
        # Communication
        Get-App-Vesktop
        Get-App-Beeper
        # Media
        Get-App-VLC
        Get-App-Shotcut
        # Gaming
        Get-App-Steam
        Get-App-EADesktop
        Get-App-UbisoftConnect
        Get-App-Heroic
        Get-App-CloneHero
        Get-App-DLSSSwapper
        # Hardware
        Get-App-SteelSeriesEngine
        Get-App-LogitechGHub
        Get-App-LogitechOptionsPlus
        Get-App-NanoleafDesktop
        Get-App-FanControl
        Get-App-Afterburner
        Get-App-RTSS
    )
}
```

## 7. Generate `bootstrap.ps1`

Interactive entry point. Structure:

```powershell
# bootstrap.ps1 — Entry point for declarative Windows setup
#
# Usage:
#   .\bootstrap.ps1
#   .\bootstrap.ps1 -DryRun

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
```

### Pre-flight checks

1. **OS check** — verify Windows (`$env:OS -eq 'Windows_NT'`)
2. **PowerShell version** — require 5.1+ (`$PSVersionTable.PSVersion.Major`)
3. **Admin check** — self-elevate if not running as admin (some apps require it)

### Self-elevation pattern

Detect the current PowerShell executable so the re-launch uses the same edition (5.1 or 7+):

```powershell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[setup] Restarting as administrator..." -ForegroundColor Yellow
    $psExe = (Get-Process -Id $PID).Path
    $argList = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $(if ($DryRun) { '-DryRun' })"
    Start-Process $psExe $argList -Verb RunAs
    exit
}
```

### Post-elevation checks

4. **winget availability** — run `Get-Command winget -ErrorAction SilentlyContinue`; if it is not found, print an error and stop. Then run `winget list --accept-source-agreements 2>&1 | Out-Null` to silently accept source agreements on first use without turning native stderr into a terminating PowerShell 5.1 error
5. **Network connectivity** — `Test-NetConnection cdn.winget.microsoft.com -Port 443 -InformationLevel Quiet` (winget requires internet)

### Profile selection

1. Set `$settingsPath = Join-Path $PSScriptRoot "settings.json"`. If it does not exist, print an error telling the user to copy `settings.example.json` to `settings.json`, then stop.
2. Load the file inside a `try`/`catch`: `$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json`. If parsing fails, print an invalid-JSON error and stop.
3. If the `profiles` array is set and non-empty, use those profiles
4. If it is missing or empty, show an interactive menu listing available profiles (scan `setup/profiles/` for `.ps1` files) with `default` selected initially. If `$DryRun` is set, state that profile selection only controls the preview and no changes will be made.
5. Require `default` in the final selection; stop with an error if the user removes it:

```powershell
if ($selectedProfiles -notcontains 'default') {
    Write-Host "[setup] ERROR: The default profile is required for every managed Windows machine." -ForegroundColor Red
    exit 1
}
```

6. Pass selected profiles to `setup/setup.ps1`

Use this pattern for the first two steps:

```powershell
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
```

### Invoke setup

Thread the `-DryRun` switch through to setup:

```powershell
& "$PSScriptRoot\setup\setup.ps1" -Profiles $selectedProfiles -DryRun:$DryRun
```

## 8. Generate `setup/setup.ps1`

Orchestrator that receives profile names, collects apps, deduplicates, installs, and runs config.

### Structure

```powershell
param(
    [Parameter(Mandatory)]
    [string[]]$Profiles,
    [switch]$DryRun
)

. "$PSScriptRoot\helpers.ps1"

Start-Log
$timer = Start-SetupTimer
$Settings = Get-Settings

Write-Info "Host:     $($Settings.hostname)"
Write-Info "Profiles: $($Profiles -join ', ')"
if ($DryRun) { Write-Warn "DRY RUN — no changes will be made" }
```

### Step functions

Implement as named `Step-*` functions called in sequence:

```powershell
function Step-CollectApps { ... }        # Dot-source profile, call Get-<Profile>Apps, dedup by Id, apply excludeApps
function Step-InstallApps { ... }        # winget install --id <Id> --accept-source-agreements --accept-package-agreements
function Step-ConfigureSystem { ... }    # Run config/ scripts in order: environment → git → ps-profile
function Step-RunConfigScripts { ... }   # For each app with ConfigScript != $null, run its post-install config
```

### Profile validation

In `Step-CollectApps`, validate each profile name against available `.ps1` files in `setup/profiles/` before loading:

```powershell
$availableProfiles = Get-ChildItem "$PSScriptRoot\profiles\*.ps1" | ForEach-Object { $_.BaseName }
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
```

### Dynamic profile loading

After validation, dynamically dot-source each profile and call its `Get-<Name>Apps` function:

```powershell
$allApps = @()
foreach ($p in $Profiles) {
    . "$PSScriptRoot\profiles\$p.ps1"
    # Convert a profile such as "fennec-windows" to "Get-FennecWindowsApps".
    $nameParts = $p -split '-'
    $functionSuffix = ($nameParts | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) }) -join ''
    $funcName = "Get-${functionSuffix}Apps"
    if (-not (Get-Command $funcName -CommandType Function -ErrorAction SilentlyContinue)) {
        Write-Err "Profile function '$funcName' was not found in '$p.ps1'"
        exit 1
    }
    $allApps += & $funcName
}
```

### Deduplication

When multiple standalone profiles happen to share an app, deduplicate by winget `Id` before installing:

```powershell
$seenIds = @{}
$apps = @(
    foreach ($app in $allApps) {
        if (-not $seenIds.ContainsKey($app.Id)) {
            $seenIds[$app.Id] = $true
            $app
        }
    }
)
```

### Exclusion filtering

After deduplicating, filter out any winget IDs listed in `$Settings.excludeApps` (optional array in `settings.json`):

```powershell
if ($Settings.PSObject.Properties['excludeApps'] -and $Settings.excludeApps.Count -gt 0) {
    $apps = $apps | Where-Object { $_.Id -notin $Settings.excludeApps }
    Write-Info "Excluded $($Settings.excludeApps.Count) app(s) per settings"
}
```

Exclusions apply globally, including apps from the `default` profile. This is intentional; users may exclude any app by winget ID.

### Install summary

After collecting and filtering, display the app list and confirm before proceeding:

```powershell
Write-Info "Apps to install ($($apps.Count)):"
foreach ($app in $apps) {
    Write-Info "  - $($app.Name) ($($app.Id))"
}
if (-not $DryRun -and -not (Confirm-Step "Proceed with installation?")) {
    Write-Warn "Aborted by user."
    exit 0
}
```

### App installation

For each app:

1. Check if already installed — `winget list` returns exit code 0 regardless, so parse stdout for the package ID:

```powershell
$listOutput = winget list --id $app.Id --accept-source-agreements 2>&1 | Out-String
$isInstalled = $listOutput -match "(?m)(^|\s)$([regex]::Escape($app.Id))(\s|$)"
```

2. If not installed and `$DryRun` is set, log `Would install: $($app.Name) ($($app.Id))` and skip the native command:

```powershell
if ($DryRun) {
    Write-Info "Would install: $($app.Name) ($($app.Id))"
    continue
}
```

3. If not installed and not in DryRun mode, install and check exit code:

```powershell
winget install --id $app.Id --accept-source-agreements --accept-package-agreements 2>&1
$installExitCode = $LASTEXITCODE
if ($installExitCode -ne 0) {
    Write-Warn "Failed to install $($app.Name) (exit code $installExitCode)"
} else {
    Write-Info "Installed $($app.Name)"
}
```

4. On failure: warn, add the app to a failure list, and continue (don't abort). After the loop, report the total number of failed installations.

Implement the installation loop with this behavior:

```powershell
function Step-InstallApps {
    $failures = @()
    foreach ($app in $apps) {
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
```

### Config script execution order

`Step-ConfigureSystem` must run config scripts in this specific order (later scripts may depend on earlier ones):

1. `setup/config/environment.ps1` — creates directories and sets PATH
2. `setup/config/git.ps1` — configures git (may need directories from step 1)
3. `setup/config/powershell-profile.ps1` — sets up PS profile

PowerToys reference files are not part of this sequence. Normal setup must never overwrite live PowerToys configuration. When `$DryRun` is set, print `Would execute: <script path>` for each config script instead of dot-sourcing it; do not execute the script.

Dot-source each config script (e.g., `. $PSScriptRoot\config\environment.ps1`) so it inherits `$Settings` and `$DryRun` from the caller's scope.

### End

```powershell
Write-Elapsed $timer
```

## 9. Generate config scripts

### `setup/config/environment.ps1`

System environment setup:

- Create standard directory structure (`~/git/`, `~/downloads/`, etc.)
- Create directories only when missing so repeated runs are idempotent
- Set environment variables if needed
- Add each PATH entry only if it is not already present
- **Hostname check**: compare `$env:COMPUTERNAME` with `$Settings.hostname` — if they differ, offer to rename via `Rename-Computer -NewName $Settings.hostname` (requires reboot). After a successful rename, log that a reboot is required for the change to take effect. If `$DryRun` is set, log "Would rename computer to $Settings.hostname" instead of calling `Rename-Computer`

### `setup/config/git.ps1`

Interactive git identity setup (mirrors infra-nix-config’s `postinstall.sh` step):
- Check if `git` is in PATH (`Get-Command git -ErrorAction SilentlyContinue`). If not found, warn and skip.
- If `$DryRun` is set, log current git config state and what would be changed, then return (skip all interactive prompts)
- Check current `git config --global user.name`
- If not set, suggest `$Settings.username` as default and prompt for confirmation or override
- If email not set, prompt for email
- Leave existing `user.name` and `user.email` values unchanged; only set missing values
- Set `git config --global init.defaultBranch main`
- Set `git config --global core.editor` to preferred editor

### `setup/config/powershell-profile.ps1`

Bootstrap the user's PowerShell profile:

- Check if `$PROFILE` exists
- `setup/config/powershell-profile-content.ps1` is created during scaffolding as an empty placeholder (user populates later with prompt customizations, aliases, etc.)
- Read the existing profile content and add a dot-source line that loads `powershell-profile-content.ps1` from this repo's absolute path only if that line is not already present
- Don't overwrite existing profile content; repeated runs must not append duplicate lines

### `setup/config/powertoys/` reference files

Copy `scaffolding/keyboard-manager.json` and `scaffolding/fancyzones-layout.json` into this generated directory as reference files. These files are not imported automatically and must not overwrite live PowerToys state.

Also create `setup/config/powertoys/README.md` with this prominent warning:

```markdown
# PowerToys reference files

[REFERENCE ONLY] These files document desired PowerToys configuration. Normal setup does not import, synchronize, or overwrite live PowerToys configuration. Any manual import must be performed by the user and validated against the installed PowerToys version.
```

Also create `setup/config/powertoys/README.md` with a prominent warning: these files are reference-only; normal setup does not import, synchronize, or overwrite live PowerToys configuration. Any manual import must be performed by the user and validated against the installed PowerToys version.

- `keyboard-manager.json` documents the Keyboard Manager remaps from the seed data.
- `fancyzones-layout.json` is a human-readable description of the desired layout, not a verified native PowerToys export.
- Do not generate an active importer for these files during scaffolding.
- Any future import procedure must be explicit, manual, and separately validated against the installed PowerToys version.

## 10. Generate app-config scripts

### `setup/apps-config/vscode.ps1`

Post-install VSCode configuration:

- Install extensions from a curated list (use `code --install-extension <id>`)
- Start with an empty extension list — user populates later
- Check if `code` is in PATH first

### `setup/apps-config/terminal.ps1`

Windows Terminal configuration:

- Placeholder for importing terminal settings JSON
- Check if Windows Terminal is installed

## 11. Generate documentation

### README.md (repo root)

Quick-start guide:

```markdown
# Windows Setup

Declarative Windows configuration via PowerShell + winget.

## Quick Start

1. Copy `settings.example.json` to `settings.json` and fill in your hostname, username, and desired profiles
2. Set execution policy (one-time): `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
3. Run: `.\\bootstrap.ps1`
4. Preview without changes: `.\\bootstrap.ps1 -DryRun`

Bootstrap supports PowerShell 5.1 and 7+. It re-elevates using the same PowerShell edition; PowerShell 7+ is recommended for new machines.

Every machine must explicitly select `default` plus any host-specific profiles, for example `["default", "fennec-windows"]`. Profiles are independent; setup deduplicates apps by winget ID when multiple profiles are selected.

## Profiles

See [docs/PROFILES.md](docs/PROFILES.md) for the full profile matrix.

| Profile        | Description                        |
| -------------- | ---------------------------------- |
| default        | Minimum apps for every Windows host |
| fennec-windows | Gaming Windows host additions      |

## Adding Apps

See [docs/APP-LIST.md](docs/APP-LIST.md) for the full app catalog.
To add a new app, use the `add-app` prompt or create a script in `setup/apps/`.

## Clean Install

For unattended Windows installation, see [`unattend/`](unattend/).

## Repo Structure

(include the folder tree — keep in sync with copilot-instructions and the scaffold prompt Step 2)
```

### docs/PROFILES.md

Profile matrix showing which apps are in each profile. Table format:

```markdown
| App        | default | fennec-windows |
| ---------- | ------- | -------------- |
| 7zip       | ✓       |                |
| Brave      | ✓       |                |
| PowerToys  | ✓       |                |
| Steam      |         | ✓              |
| VLC        |         | ✓              |
```

One row per app, sorted alphabetically. Check marks for each profile that includes it.

### docs/APP-LIST.md

Full app catalog with columns: App name, Winget ID, Category, Script path. One row per app, sorted alphabetically.

### docs/SHORTCUTS.md

Copy the shortcut documentation from `scaffolding/README.md` into this file. Rewrite the relative JSON links before writing it:

Find markdown links in the form `[text](filename)` for `keyboard-manager.json` and `fancyzones-layout.json`, and replace only their destinations with the corresponding paths below. Leave all other links unchanged.

- `keyboard-manager.json` → `../setup/config/powertoys/keyboard-manager.json`
- `fancyzones-layout.json` → `../setup/config/powertoys/fancyzones-layout.json`

Configuration files are reference-only. Normal setup does not auto-import them or overwrite live PowerToys configuration.

Keep the shortcut descriptions and tables, but do not claim the source README was copied unchanged.

## 12. Generate `unattend/` reference folder

Standalone reference for clean Windows installs. Not integrated with `bootstrap.ps1` — purely a grab-and-go artifact.

### `unattend/autounattend.xml`

Minimal Windows 11 answer file. Generate a valid XML answer file using the `urn:schemas-microsoft-com:unattend` namespace with these configuration passes:

**windowsPE pass** (`Microsoft-Windows-International-Core-WinPE`):
- `InputLocale` = `en-US` (placeholder)
- `SystemLocale` = `en-US`
- `UILanguage` = `en-US`
- `UserLocale` = `en-US`

**specialize pass** (`Microsoft-Windows-Shell-Setup`):
- `ComputerName` = `MY-PC` (placeholder — user replaces)
- `TimeZone` = `Eastern Standard Time` (placeholder)
- `RegisteredOwner` = blank

**oobeSystem pass** (`Microsoft-Windows-Shell-Setup`):
- `OOBE` settings:
  - `HideEULAPage` = `true`
  - `HideOnlineAccountScreens` = `true`
  - `HideWirelessSetupInOOBE` = `true`
  - `ProtectYourPC` = `3` (disables telemetry prompts)
- `UserAccounts` → `LocalAccounts`: create one local admin account with placeholder username and blank password
- `AutoLogon`: enable for the local account (first boot only, `LogonCount` = `1`)

Mark all placeholder values with XML comments `<!-- CHANGE THIS -->` so they're easy to find.

### `unattend/README.md`

```markdown
# Windows Unattended Install

Minimal `autounattend.xml` for a clean Windows 11 installation. Skips OOBE screens, creates a local account, and disables telemetry prompts.

## Usage

1. Create a Windows 11 USB installer (Media Creation Tool or Rufus)
2. Copy `autounattend.xml` to the **root** of the USB drive (alongside `setup.exe`)
3. Edit the placeholders marked `<!-- CHANGE THIS -->`: `ComputerName`, `TimeZone`, `UserAccounts`
4. Boot from the USB — Windows Setup picks up the answer file automatically
5. After install completes and you reach the desktop, clone this repo and run `bootstrap.ps1`

> **Tip:** Use the same `ComputerName` and local account username in the answer file as the `hostname` and `username` in your `settings.json`. This way `environment.ps1` won’t prompt to rename and `git.ps1` will pre-fill your identity.

## What this configures

| Setting                  | Value                                |
| ------------------------ | ------------------------------------ |
| OOBE screens             | All skipped                          |
| Microsoft account prompt | Skipped (local account created)      |
| Telemetry prompts        | Disabled                             |
| Default locale           | en-US (change in XML)                |
| Computer name            | MY-PC (change in XML)                |

## What this does NOT configure

- Disk partitioning (uses Windows defaults)
- Windows edition selection (installer still prompts)
- App installation (handled by `bootstrap.ps1` after install)
- Windows features (WSL, Hyper-V — enable via `bootstrap.ps1` or manually)

## Editing tools

- [Windows System Image Manager (SIM)](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/windows-system-image-manager-overview-topics) — official Microsoft tool (part of Windows ADK)
- Manual XML editing — the file is small enough to edit directly
```

## 13. Generate `.github/copilot-instructions.md`

Repository conventions and gotcha database for Copilot:

```markdown
# Windows Setup — Copilot Instructions

## Project Structure

- `settings.example.json` — template for per-machine identity (copy to `settings.json`)
- `.gitignore` — ignores `settings.json` and `setup.log`
- `bootstrap.ps1` — entry point (pre-flight checks, profile selection, runs setup; supports `-DryRun`)
- `setup/setup.ps1` — orchestrator (collect apps, validate profiles, dedup, exclude, install, configure; supports `-DryRun`)
- `setup/helpers.ps1` — shared functions (logging to console + file, confirm, timer, settings loader)
- `setup/profiles/` — standalone profile scripts (`default`, `fennec-windows`)
- `setup/apps/` — one script per app (defines a Get-App-\* function returning app metadata)
- `setup/config/` — system config scripts (environment, git, powershell-profile) and PowerToys reference files
- `setup/apps-config/` — post-install app configuration (vscode, terminal)
- `docs/` — documentation (PROFILES.md, APP-LIST.md, SHORTCUTS.md)
- `unattend/` — reference `autounattend.xml` for clean Windows installs (not part of bootstrap pipeline; maintained manually)
- `.github/prompts/` — Copilot prompt files (scaffold-repo, review-prompt, add-app, add-profile, update-docs)

## Conventions

### Settings

- All scripts read `$Settings` from `settings.json` via `Get-Settings` — never hardcode hostname or username
- `$Settings` is a PSCustomObject with properties: `hostname`, `username`, `profiles`, `excludeApps` (optional)
- `settings.json` is gitignored — users copy from `settings.example.json`
- `excludeApps` is an optional array of winget IDs to skip during install
- `excludeApps` applies globally, including apps from the `default` profile; this is intentional
- `hostname` is used by `environment.ps1` to check/rename the computer
- `username` is used by `git.ps1` as the default suggestion for git user.name

### App Scripts

- One script per app in `setup/apps/`
- File naming: lowercase-kebab (e.g., `fan-control.ps1`, `logitech-ghub.ps1`)
- Each script defines one function: `Get-App-<PascalName>` returning a hashtable with keys: `Id`, `Name`, `Category`, `ConfigScript`

### Profile Scripts

- `default.ps1` contains the minimum baseline for every managed Windows machine
- `fennec-windows.ps1` contains gaming, media, hardware, communication, and development additions for the Windows OS on the FENNEC dual-boot machine
- Profiles are fully standalone — they dot-source their own app scripts directly and do not inherit from one another
- Imports grouped by category comments: `# Browsers`, `# Communication`, `# Development`, `# Gaming`, `# Hardware`, `# Media`, `# System`
- Profile names use lowercase words separated by hyphens when needed (for example, `fennec-windows`)
- Every machine must explicitly select `default`; a host profile does not inherit it
- `FENNEC` in the Nix configuration identifies the Linux side of the dual-boot machine; `fennec-windows` is the Windows profile ID
- Profile function naming converts each hyphenated part to PascalCase (for example, `Get-FennecWindowsApps`)

### Helpers

- `setup/helpers.ps1` is dot-sourced by all scripts — it provides: `Start-Log`, `Write-Info`, `Write-Warn`, `Write-Err`, `Confirm-Step`, `Get-Settings`, `Start-SetupTimer`, `Write-Elapsed`
- All log functions write to both console and `setup.log` in the repo root
- Use `Write-Info` / `Write-Warn` / `Write-Err` instead of raw `Write-Host`
- Use `Confirm-Step` for interactive yes/no prompts

### Idempotency

- App install: parse `winget list --id <Id>` stdout for the package ID (exit code is always 0)
- Config scripts: check existing state before writing (e.g., don't overwrite existing git config, don't duplicate PATH entries)
- Running setup twice should produce no errors and no duplicate side effects

### Error Handling

- `$ErrorActionPreference = 'Stop'` at script entry
- App install failures: warn and continue to next app (don't abort entire run)
- Config failures: warn and continue

### Naming

- Files: lowercase-kebab (e.g., `fan-control.ps1`, `powershell-profile.ps1`)
- Functions: PascalCase (e.g., `Get-App-FanControl`, `Step-InstallApps`)
- Variables: PascalCase (e.g., `$Settings`, `$SelectedProfiles`)

### Documentation

- When adding a new app: create the app script AND add a row to `docs/APP-LIST.md`
- When adding a new profile: create the profile script AND add a column to `docs/PROFILES.md`
- When modifying profile membership: update the `docs/PROFILES.md` matrix
- When modifying folder structure: update the tree in `README.md`, the copilot-instructions Project Structure section, and the scaffold prompt Step 2

## Known Gotchas

- `winget list` returns exit code 0 even when no match — parse stdout for the package ID string
- Some winget installs require admin (drivers, system tools) — bootstrap.ps1 self-elevates using the current PS executable
- PowerToys config paths are stable since v0.60+: `$env:LOCALAPPDATA\Microsoft\PowerToys\<ModuleName>\` (no version subdirectories)
- `ConvertFrom-Json` in PowerShell 5.1 has a ~2MB limit — avoid large JSON files
- Use `@(...)` array coercion when a command might return a single item instead of an array
- Config scripts must run in order: `environment.ps1` → `git.ps1` → `powershell-profile.ps1`
- PowerToys JSON files are reference-only and are not imported or copied over live configuration by normal setup
- Native commands (winget, git) may write to stderr — `$ErrorActionPreference = 'Stop'` can convert this to terminating errors in PS 5.1. Use `2>&1` or locally set `$ErrorActionPreference = 'Continue'` around native command calls
- Config scripts are dot-sourced so they inherit `$Settings` and `$DryRun` from the caller's scope
```

## 14. Generate prompt files in `.github/prompts/`

### scaffold-repo.prompt.md

This file already exists in the repo — preserve it as-is. Do not overwrite or regenerate.

### review-prompt.prompt.md

This file already exists in the repo — preserve it as-is. Do not overwrite or regenerate.

### add-app.prompt.md

```markdown
---
description: "Add a new app to the Windows setup repo. Creates the app script and updates docs."
agent: "agent"
argument-hint: "App name, winget ID, category, and which profiles to add it to"
---

Add a new app following the conventions in [copilot-instructions.md](../copilot-instructions.md).

## 1. Gather requirements

If not provided, ask for:

- **App name** — display name (e.g., "Firefox", "Docker Desktop")
- **Winget ID** — full winget package identifier (e.g., "Mozilla.Firefox")
- **Category** — one of: Browsers, Communication, Development, Gaming, Hardware, Media, System
- **Profiles** — which profiles should include this app (e.g., `default`, `fennec-windows`)
- **Config script** — does this app need post-install configuration? (y/n)

## 2. Create app script

Create `setup/apps/<kebab-name>.ps1` following the app script template from the copilot instructions.

## 3. Add to profile(s)

For each target profile in `setup/profiles/<profile>.ps1`:

1. Add the dot-source import under the matching category comment
2. Add the `Get-App-*` call in the `Get-<Profile>Apps` function

## 4. Update documentation

- Add a row to `docs/APP-LIST.md` (sorted alphabetically)
- Add a check mark to `docs/PROFILES.md` for each profile that includes this app

## 5. Create config script (if needed)

If the app needs post-install configuration, create `setup/apps-config/<kebab-name>.ps1` and set the `ConfigScript` path in the app script.
```

### add-profile.prompt.md

```markdown
---
description: "Add a new setup profile. Creates the profile script and updates docs."
agent: "agent"
argument-hint: "Profile name, description, and which app categories to include"
---

Add a new profile following the conventions in [copilot-instructions.md](../copilot-instructions.md).

## 1. Gather requirements

If not provided, ask for:

- **Profile name** — lowercase identifier; hyphens are allowed (e.g., `fennec-windows`, `streaming-laptop`)
- **Description** — one-line purpose
- **App categories** — which categories to include from existing apps
- **Extra apps** — any specific apps beyond those categories

## 2. Create profile script

Create `setup/profiles/<name>.ps1` that:

1. Dot-sources individual app scripts grouped by category comments (standalone — no inheritance)
2. Defines `Get-<Name>Apps` in PascalCase, converting hyphenated parts (for example, `fennec-windows` becomes `Get-FennecWindowsApps`)
3. Does not dot-source `default.ps1`; users select `default` explicitly alongside this profile
4. Represents a Windows machine or a shared Windows baseline; do not add profiles for Linux hosts managed by `infra-nix-config`

## 3. Update documentation

- Add a column to the `docs/PROFILES.md` matrix
- Add a row to the profiles table in `README.md`
```

### update-docs.prompt.md

```markdown
---
description: "Audit documentation against actual repo state. Finds missing or stale entries in APP-LIST.md and PROFILES.md."
mode: "plan"
---

Audit the documentation against the actual repo contents.

## 1. Scan app scripts

List all `.ps1` files in `setup/apps/`. For each, dot-source the script, call its `Get-App-*` function, and read the `Id` and `Category` keys from the returned hashtable.

## 2. Compare with APP-LIST.md

- Flag apps in `setup/apps/` that are missing from `docs/APP-LIST.md`
- Flag entries in `docs/APP-LIST.md` that have no matching script in `setup/apps/`

## 3. Compare with PROFILES.md

- For each profile in `setup/profiles/`, check which apps it dot-sources
- Compare against the check marks in `docs/PROFILES.md`
- Flag mismatches (app in profile but not checked, or checked but not in profile)

## 4. Present findings

Show a table of discrepancies and propose fixes. Wait for approval before editing.
```

## 15. Preserve seed files

After all files are generated:

1. Keep the complete `scaffolding/` directory and all four source files unchanged
2. Do not move, delete, or overwrite any file under `scaffolding/`
3. Keep generated copies of the JSON references under `setup/config/powertoys/`
4. Create the generated quick-start guide at the repository root as `README.md`; do not replace `scaffolding/README.md`

## 16. Final summary

After scaffolding, print:

> Repository scaffolded. Next steps:
>
> 1. Copy `settings.example.json` to `settings.json` and fill in your machine's hostname, username, and desired profiles
> 2. Review the app assignments in `setup/profiles/` — move apps between profiles as needed
> 3. Run `.\bootstrap.ps1` to install everything (or `.\bootstrap.ps1 -DryRun` to preview)
> 4. Commit the generated structure to git
