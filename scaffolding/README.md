# Windows — Unified Window Tiling Shortcuts via PowerToys

Reference configuration for matching the unified **Win+Alt** tiling
shortcuts on Windows using [Microsoft PowerToys](https://github.com/microsoft/PowerToys).

## Shortcut Scheme

| Action       | Shortcut              |
| ------------ | --------------------- |
| Left half    | Win + Alt + ←         |
| Right half   | Win + Alt + →         |
| Top half     | Win + Alt + ↑         |
| Bottom half  | Win + Alt + ↓         |
| Top-left     | Win + Alt + U         |
| Top-right    | Win + Alt + I         |
| Bottom-left  | Win + Alt + J         |
| Bottom-right | Win + Alt + K         |
| Center       | Win + Alt + C         |
| Maximize     | Win + Alt + Enter     |
| Restore      | Win + Alt + Backspace |

## Setup

### 1. Install PowerToys

```powershell
winget install Microsoft.PowerToys
```

### 2. Keyboard Manager — Halves, Maximize, Restore

PowerToys **Keyboard Manager** remaps Win+Alt+Arrow to Win+Arrow
(Windows native Snap), plus maximize and restore:

1. Open PowerToys → **Keyboard Manager** → **Remap a shortcut**
2. Import or manually add the remaps from
   [`keyboard-manager.json`](keyboard-manager.json)

| From                  | To      | Notes                |
| --------------------- | ------- | -------------------- |
| Win + Alt + ←         | Win + ← | Snap left half       |
| Win + Alt + →         | Win + → | Snap right half      |
| Win + Alt + ↑         | Win + ↑ | Maximize             |
| Win + Alt + ↓         | Win + ↓ | Restore / minimize   |
| Win + Alt + Enter     | Win + ↑ | Maximize (alt combo) |
| Win + Alt + Backspace | Win + ↓ | Restore (alt combo)  |

### 3. FancyZones — Quarters and Center

FancyZones handles quarter tiling and centering which Windows Snap
doesn't support natively:

1. Open PowerToys → **FancyZones** → **Launch layout editor**
2. Create a **Custom** layout with the zones described in
   [`fancyzones-layout.json`](fancyzones-layout.json)
3. Assign zone activation shortcuts:

| Shortcut      | Zone         |
| ------------- | ------------ |
| Win + Alt + U | Top-left     |
| Win + Alt + I | Top-right    |
| Win + Alt + J | Bottom-left  |
| Win + Alt + K | Bottom-right |
| Win + Alt + C | Center       |

> **Note:** FancyZones does not support per-zone shortcut activation
> natively. Use **Keyboard Manager** to remap Win+Alt+U/I/J/K/C to
> Win+Ctrl+Alt+1/2/3/4/5, then configure FancyZones to use those as
> zone activation keys, or use the FancyZones "Override Windows Snap"
> feature combined with custom grid layouts.
