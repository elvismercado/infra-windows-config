---
description: "Add a new setup profile. Creates the profile script and updates docs."
agent: "agent"
argument-hint: "Profile name, description, and which app categories to include"
---

Add a new profile following the conventions in [copilot-instructions.md](../copilot-instructions.md).

## 1. Gather requirements

If not provided, ask for:

- **Profile name** - lowercase identifier; hyphens are allowed (for example, `fennec-windows`, `streaming-laptop`)
- **Description** - one-line purpose
- **App categories** - which categories to include from existing apps
- **Extra apps** - any specific apps beyond those categories

## 2. Create profile script

Create `setup/profiles/<name>.ps1` that:

1. Dot-sources individual app scripts grouped by category comments (standalone - no inheritance)
2. Defines `Get-<Name>Apps` in PascalCase, converting hyphenated parts (for example, `fennec-windows` becomes `Get-FennecWindowsApps`)
3. Does not dot-source `default.ps1`; users select `default` explicitly alongside this profile
4. Represents a Windows machine or a shared Windows baseline; do not add profiles for Linux hosts managed by `infra-nix-config`

## 3. Update documentation

- Add a column to the `docs/PROFILES.md` matrix
- Add a row to the profiles table in `README.md`
