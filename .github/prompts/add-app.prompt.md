---
description: "Add a new app to the Windows setup repo. Creates the app script and updates docs."
agent: "agent"
argument-hint: "App name, winget ID, category, and which profiles to add it to"
---

Add a new app following the conventions in [copilot-instructions.md](../copilot-instructions.md).

## 1. Gather requirements

If not provided, ask for:

- **App name** - display name (for example, "Firefox", "Docker Desktop")
- **Winget ID** - full winget package identifier (for example, "Mozilla.Firefox")
- **Category** - one of: Browsers, Communication, Development, Gaming, Hardware, Media, System
- **Profiles** - which profiles should include this app (for example, `default`, `fennec-windows`)
- **Config script** - does this app need post-install configuration? (y/n)

## 2. Create app script

Create `setup/apps/<kebab-name>.ps1` following the app script template from the Copilot instructions.

## 3. Add to profile(s)

For each target profile in `setup/profiles/<profile>.ps1`:

1. Add the dot-source import under the matching category comment
2. Add the `Get-App-*` call in the `Get-<Profile>Apps` function

## 4. Update documentation

- Add a row to `docs/APP-LIST.md` (sorted alphabetically)
- Add a check mark to `docs/PROFILES.md` for each profile that includes this app

## 5. Create config script (if needed)

If the app needs post-install configuration, create `setup/apps-config/<kebab-name>.ps1` and set the `ConfigScript` path in the app script.
