# Windows Setup - Copilot Instructions

## Project Structure

- `settings.example.json` - template for per-machine identity (copy to `settings.json`)
- `.gitignore` - ignores `settings.json` and `setup.log`
- `bootstrap.ps1` - entry point (pre-flight checks, profile selection, runs setup; supports `-DryRun`)
- `setup/setup.ps1` - orchestrator (collect apps, validate profiles, dedup, exclude, install, configure; supports `-DryRun`)
- `setup/helpers.ps1` - shared functions (logging to console + file, confirm, timer, settings loader)
- `setup/profiles/` - standalone profile scripts (`default`, `fennec-windows`)
- `setup/apps/` - one script per app (defines a `Get-App-*` function returning app metadata)
- `setup/config/` - system config scripts (environment, git, powershell-profile) and PowerToys reference files
- `setup/apps-config/` - post-install app configuration (vscode, terminal)
- `docs/` - documentation (PROFILES.md, APP-LIST.md, SHORTCUTS.md)
- `unattend/` - reference `autounattend.xml` for clean Windows installs (not part of bootstrap pipeline; maintained manually)
- `.github/prompts/` - Copilot prompt files (scaffold-repo, review-prompt, add-app, add-profile, update-docs)

## Conventions

### Settings

- All scripts read `$Settings` from `settings.json` via `Get-Settings` - never hardcode hostname or username
- `$Settings` is a PSCustomObject with properties: `hostname`, `username`, `profiles`, `excludeApps` (optional)
- `settings.json` is gitignored - users copy from `settings.example.json`
- `excludeApps` is an optional array of winget IDs to skip during install
- `excludeApps` applies globally, including apps from the `default` profile; this is intentional
- `hostname` is used by `environment.ps1` to check/rename the computer
- `username` is used by `git.ps1` as the default suggestion for git user.name

### App Scripts

- One script per app in `setup/apps/`
- File naming: lowercase-kebab (for example, `fan-control.ps1`, `logitech-ghub.ps1`)
- Each script defines one function: `Get-App-<PascalName>` returning a hashtable with keys: `Id`, `Name`, `Category`, `ConfigScript`

### Profile Scripts

- `default.ps1` contains the minimum baseline for every managed Windows machine
- `fennec-windows.ps1` contains gaming, media, hardware, communication, and development additions for the Windows OS on the FENNEC dual-boot machine
- Profiles are fully standalone. They dot-source their own app scripts directly and do not inherit from one another
- Imports grouped by category comments: `# Browsers`, `# Communication`, `# Development`, `# Gaming`, `# Hardware`, `# Media`, `# System`
- Profile names use lowercase words separated by hyphens when needed (for example, `fennec-windows`)
- Every machine must explicitly select `default`; a host profile does not inherit it
- `FENNEC` in the Nix configuration identifies the Linux side of the dual-boot machine; `fennec-windows` is the Windows profile ID
- Profile function naming converts each hyphenated part to PascalCase (for example, `Get-FennecWindowsApps`)

### Helpers

- `setup/helpers.ps1` is dot-sourced by all scripts. It provides: `Start-Log`, `Write-Info`, `Write-Warn`, `Write-Err`, `Confirm-Step`, `Get-Settings`, `Start-SetupTimer`, `Write-Elapsed`
- All log functions write to both console and `setup.log` in the repo root
- Use `Write-Info` / `Write-Warn` / `Write-Err` instead of raw `Write-Host`
- Use `Confirm-Step` for interactive yes/no prompts

### Idempotency

- App install: parse `winget list --id <Id>` stdout for the package ID (exit code is always 0)
- Config scripts: check existing state before writing (for example, don't overwrite existing git config, don't duplicate PATH entries)
- Running setup twice should produce no errors and no duplicate side effects

### Error Handling

- `$ErrorActionPreference = 'Stop'` at script entry
- App install failures: warn and continue to next app (don't abort entire run)
- Config failures: warn and continue

### Naming

- Files: lowercase-kebab (for example, `fan-control.ps1`, `powershell-profile.ps1`)
- Functions: PascalCase (for example, `Get-App-FanControl`, `Step-InstallApps`)
- Variables: PascalCase (for example, `$Settings`, `$SelectedProfiles`)

### Documentation

- When adding a new app: create the app script and add a row to `docs/APP-LIST.md`
- When adding a new profile: create the profile script and add a column to `docs/PROFILES.md`
- When modifying profile membership: update the `docs/PROFILES.md` matrix
- When modifying folder structure: update the tree in `README.md`, the copilot-instructions Project Structure section, and the scaffold prompt Step 2

## Known Gotchas

- `winget list` returns exit code 0 even when no match. Parse stdout for the package ID string
- Some winget installs require admin (drivers, system tools). `bootstrap.ps1` self-elevates using the current PowerShell executable
- PowerToys config paths are stable since v0.60+: `$env:LOCALAPPDATA\Microsoft\PowerToys\<ModuleName>\` (no version subdirectories)
- `ConvertFrom-Json` in PowerShell 5.1 has a ~2MB limit. Avoid large JSON files
- Use `@(...)` array coercion when a command might return a single item instead of an array
- Config scripts must run in order: `environment.ps1` -> `git.ps1` -> `powershell-profile.ps1`
- PowerToys JSON files are reference-only and are not imported or copied over live configuration by normal setup
- Native commands (winget, git) may write to stderr. `$ErrorActionPreference = 'Stop'` can convert this to terminating errors in PS 5.1. Use `2>&1` or locally set `$ErrorActionPreference = 'Continue'` around native command calls
- Config scripts are dot-sourced so they inherit `$Settings` and `$DryRun` from the caller's scope
