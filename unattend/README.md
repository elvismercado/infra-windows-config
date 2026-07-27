# Windows Unattended Install

Minimal `autounattend.xml` for a clean Windows 11 installation. Skips OOBE screens, creates a local account, and disables telemetry prompts.

## Usage

1. Create a Windows 11 USB installer (Media Creation Tool or Rufus)
2. Copy `autounattend.xml` to the **root** of the USB drive (alongside `setup.exe`)
3. Edit the placeholders marked `<!-- CHANGE THIS -->`: `ComputerName`, `TimeZone`, `UserAccounts`
4. Boot from the USB. Windows Setup picks up the answer file automatically
5. After install completes and you reach the desktop, clone this repo and run `bootstrap.ps1`

> **Tip:** Use the same `ComputerName` and local account username in the answer file as the `hostname` and `username` in your `settings.json`. This way `environment.ps1` won't prompt to rename and `git.ps1` will pre-fill your identity.

## What this configures

| Setting | Value |
| --- | --- |
| OOBE screens | All skipped |
| Microsoft account prompt | Skipped (local account created) |
| Telemetry prompts | Disabled |
| Default locale | en-US (change in XML) |
| Computer name | MY-PC (change in XML) |

## What this does NOT configure

- Disk partitioning (uses Windows defaults)
- Windows edition selection (installer still prompts)
- App installation (handled by `bootstrap.ps1` after install)
- Windows features (WSL, Hyper-V. Enable via `bootstrap.ps1` or manually)

## Editing tools

- [Windows System Image Manager (SIM)](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/windows-system-image-manager-overview-topics). Official Microsoft tool (part of Windows ADK)
- Manual XML editing. The file is small enough to edit directly
