# Profiles

Profiles are standalone. Every managed machine selects `default` explicitly, then may add a host-specific profile. Selecting both profiles is safe because setup deduplicates apps by winget ID.

`development` provides the general-purpose development tools. It includes VS Code, Git, GitHub CLI, fnm, Python, and uv; setup also installs the Windows OpenSSH Client capability. Restart PowerShell after setup and run `fnm install --lts` once to install Node.js LTS and npm.

`fennec-windows` is the gaming Windows profile for the Windows OS on the FENNEC dual-boot machine. The profile ID is not the computer name. The actual computer name comes from `settings.json`.

| App | default | development | fennec-windows |
| --- | --- | --- | --- |
| 7-Zip | ✓ | | |
| Beeper | | | ✓ |
| Brave | ✓ | | |
| Clone Hero | | | ✓ |
| DLSS Swapper | | | ✓ |
| EA Desktop | | | ✓ |
| Fan Control | | | ✓ |
| fnm (Fast Node Manager) | | ✓ | |
| Git | | ✓ | |
| GitHub CLI | | ✓ | |
| Heroic Games Launcher | | | ✓ |
| Logitech G HUB | | | ✓ |
| Logitech Options+ | | | ✓ |
| MSI Afterburner | | | ✓ |
| Nanoleaf Desktop | | | ✓ |
| OpenSSH Client | | ✓ | |
| PowerToys | ✓ | | |
| Python 3.14 | | ✓ | |
| RTSS | | | ✓ |
| Shotcut | | | ✓ |
| SteelSeries Engine | | | ✓ |
| Steam | | | ✓ |
| Sunshine | | | ✓ |
| SyncTrayzor | ✓ | | |
| Ubisoft Connect | | | ✓ |
| uv | | ✓ | |
| Vesktop | | | ✓ |
| VLC | | | ✓ |
| Visual Studio Code | | ✓ | ✓ |
| Windows Terminal | ✓ | | |
