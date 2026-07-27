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
