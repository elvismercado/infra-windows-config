# Windows Setup

Declarative Windows configuration via PowerShell + winget.

## Quick Start

1. Copy `settings.example.json` to `settings.json` and fill in your hostname, username, and desired profiles
2. Set execution policy (one-time): `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
3. Run: `.\bootstrap.ps1`
4. Preview without changes: `.\bootstrap.ps1 -DryRun`

Bootstrap supports PowerShell 5.1 and 7+. It re-elevates using the same PowerShell edition; PowerShell 7+ is recommended for new machines.

Every machine must explicitly select `default` plus any host-specific profiles, for example `["default", "fennec-windows"]`. Profiles are independent; setup deduplicates apps by winget ID when multiple profiles are selected.

## Profiles

See [docs/PROFILES.md](docs/PROFILES.md) for the full profile matrix.

| Profile | Description |
| --- | --- |
| default | Minimum apps for every Windows host |
| fennec-windows | Gaming Windows host additions |

## Adding Apps

See [docs/APP-LIST.md](docs/APP-LIST.md) for the full app catalog.
To add a new app, use the `add-app` prompt or create a script in `setup/apps/`.

## Clean Install

For unattended Windows installation, see [`unattend/`](unattend/).

## Repo Structure

```text
windows-config/
├── .github/
│   ├── copilot-instructions.md
│   └── prompts/
│       ├── add-app.prompt.md
│       ├── add-profile.prompt.md
│       ├── review-prompt.prompt.md
│       ├── scaffold-repo.prompt.md
│       └── update-docs.prompt.md
├── .gitignore
├── README.md
├── bootstrap.ps1
├── docs/
│   ├── APP-LIST.md
│   ├── PROFILES.md
│   └── SHORTCUTS.md
├── scaffolding/
│   ├── fancyzones-layout.json
│   ├── keyboard-manager.json
│   ├── README.md
│   └── winget-packages.json
├── settings.example.json
├── setup/
│   ├── apps/
│   │   ├── 7zip.ps1
│   │   ├── afterburner.ps1
│   │   ├── beeper.ps1
│   │   ├── brave.ps1
│   │   ├── clone-hero.ps1
│   │   ├── dlss-swapper.ps1
│   │   ├── ea-desktop.ps1
│   │   ├── fan-control.ps1
│   │   ├── heroic.ps1
│   │   ├── logitech-ghub.ps1
│   │   ├── logitech-options-plus.ps1
│   │   ├── nanoleaf-desktop.ps1
│   │   ├── powertoys.ps1
│   │   ├── rtss.ps1
│   │   ├── shotcut.ps1
│   │   ├── steelseries-engine.ps1
│   │   ├── steam.ps1
│   │   ├── sunshine.ps1
│   │   ├── synctrayzor.ps1
│   │   ├── ubisoft-connect.ps1
│   │   ├── vesktop.ps1
│   │   ├── vlc.ps1
│   │   ├── vscode.ps1
│   │   └── windows-terminal.ps1
│   ├── apps-config/
│   │   ├── terminal.ps1
│   │   └── vscode.ps1
│   ├── config/
│   │   ├── environment.ps1
│   │   ├── git.ps1
│   │   ├── powershell-profile-content.ps1
│   │   ├── powershell-profile.ps1
│   │   └── powertoys/
│   │       ├── fancyzones-layout.json
│   │       ├── keyboard-manager.json
│   │       └── README.md
│   ├── helpers.ps1
│   ├── profiles/
│   │   ├── default.ps1
│   │   └── fennec-windows.ps1
│   └── setup.ps1
└── unattend/
    ├── autounattend.xml
    └── README.md
```

PowerToys files under `setup/config/powertoys/` are reference-only. Normal setup never imports or overwrites live PowerToys configuration.
