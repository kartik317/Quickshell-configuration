# Quickshell Configuration

A modern [Quickshell](https://quickshell.outfoxxed.me/) setup for Hyprland-style desktop workflows, featuring a polished top bar, live system monitoring, quick controls, and a compact app launcher.

![status](https://img.shields.io/badge/status-actively--developed-blue)
![shell](https://img.shields.io/badge/compositor-Hyprland-informational)



https://github.com/user-attachments/assets/7263ef3d-22f9-47f9-aa4e-f966d1e7af2f



[video explaination](https://youtu.be/P4uzfNuSL5E)

---

## Table of Contents

- [Quickshell Configuration](#quickshell-configuration)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Project Structure](#project-structure)
  - [Core Components](#core-components)
    - [Bar and Shell](#bar-and-shell)
    - [State and Monitoring](#state-and-monitoring)
    - [Controls and Overlays](#controls-and-overlays)
    - [Visual Theme](#visual-theme)
  - [Requirements](#requirements)
  - [Getting Started](#getting-started)
  - [IPC Commands \& Keybinds](#ipc-commands--keybinds)
  - [Customization Tips](#customization-tips)
  - [Troubleshooting](#troubleshooting)
  - [License](#license)

---

## Features

- **Top bar** — workspace, layout, active window, network, battery, and clock info
- **Draggable clock overlay** for quick access to the full clock panel
- **System monitor popup** — CPU, RAM, disk, temperature, and battery gauges
- **Slide-in volume & brightness panel** with live scroll/drag controls
- **PipeWire-driven volume OSD** with transient on-change feedback
- **Power menu** — lock, suspend, hibernate, reboot, and shutdown actions
- **App launcher** — searchable, with recent-app tracking and keyboard navigation
- **Live wallpaper switcher** — thumbnail strip with scroll navigation and wallust theming
- **Voice assistant panel** (optional) — lightweight waveform feedback widget

---

## Project Structure

```text
quickshell/
├── bar/
│   ├── Bar.qml
│   ├── Battery.qml
│   ├── Clock.qml
│   ├── Network.qml
│   ├── Separator.qml
│   └── Workspaces.qml
├── icons/
│   └── arch.png
├── scripts/
│   └── generate_live_thumbs.sh
├── shell.qml
├── state/
│   ├── AppLauncherState.qml
│   ├── LiveWallpaperState.qml
│   ├── PowerMenuState.qml
│   ├── SysMonitorState.qml
│   ├── SystemState.qml
│   ├── Vol_Bri_Controls_State.qml
│   └── WallpaperState.qml
├── theme/
│   └── Colors.qml
├── voice_assistant/
│   ├── cava-nova.conf
│   ├── NovaPanel.qml
│   ├── NovaState.qml
│   └── NovaWave.qml
├── wallpaper_clock/
│   ├── ClockState.qml
│   ├── DraggableClock.qml
│   └── WallpaperClock.qml
└── widgets/
    ├── AppLauncher.qml
    ├── GaugeRing.qml
    ├── LiveWallpaperSwitcher.qml
    ├── PowerMenu.qml
    ├── SysMonitor.qml
    ├── Vol_Bri_Controls.qml
    ├── VolumeOSD.qml
    └── WallpaperSwitcher.qml
```

---

## Core Components

### Bar and Shell
| File | Purpose |
|---|---|
| [`quickshell/shell.qml`](quickshell/shell.qml) | Wires together the bar, overlays, widgets, and panels for each screen |
| [`quickshell/bar/Bar.qml`](quickshell/bar/Bar.qml) | Defines the top bar layout and places the main widgets |

### State and Monitoring
| File | Purpose |
|---|---|
| [`quickshell/state/SystemState.qml`](quickshell/state/SystemState.qml) | Collects live system info — CPU usage, memory, disk, volume, battery, active window, layout state |
| [`quickshell/widgets/SysMonitor.qml`](quickshell/widgets/SysMonitor.qml) | Renders a detailed popup for system health and power info |

### Controls and Overlays
| File | Purpose |
|---|---|
| [`quickshell/widgets/Vol_Bri_Controls.qml`](quickshell/widgets/Vol_Bri_Controls.qml) | Slide-out volume and brightness UI |
| [`quickshell/widgets/VolumeOSD.qml`](quickshell/widgets/VolumeOSD.qml) | Transient audio feedback when volume changes |
| [`quickshell/widgets/PowerMenu.qml`](quickshell/widgets/PowerMenu.qml) | Quick power actions (lock, suspend, hibernate, reboot, shutdown) |
| [`quickshell/widgets/AppLauncher.qml`](quickshell/widgets/AppLauncher.qml) | Searchable app picker with recent-app support |
| [`quickshell/widgets/WallpaperSwitcher.qml`](quickshell/widgets/WallpaperSwitcher.qml) / [`LiveWallpaperSwitcher.qml`](quickshell/widgets/LiveWallpaperSwitcher.qml) | Wallpaper picker with live thumbnails |

### Visual Theme
| File | Purpose |
|---|---|
| [`quickshell/theme/Colors.qml`](quickshell/theme/Colors.qml) | Centralizes the color palette used across the shell |

---

## Requirements

This setup expects a working Quickshell environment with the following tools available:

- [Quickshell](https://quickshell.outfoxxed.me/)
- Hyprland (or a compatible Wayland compositor)
- PipeWire + WirePlumber (for volume control via `wpctl`)
- `brightnessctl` (for brightness changes)
- `jq` (for parsing Hyprland window data)
- A Nerd Font, e.g. JetBrainsMono Nerd Font

---

## Getting Started

1. Make sure Quickshell is installed and running.
2. Copy or symlink this repository into your Quickshell configuration directory.
3. Adjust any paths or commands in the QML files to match your system's tool locations.
4. Restart Quickshell to load the updated configuration.

```bash
# example: symlink into the default config location
ln -s /path/to/this/repo ~/.config/quickshell
```

---

## IPC Commands & Keybinds

Every widget exposes an IPC handler for toggling:

```bash
qs ipc call applauncher toggle
qs ipc call clock-widget toggle
qs ipc call controlpanel toggle
qs ipc call systemMonitor-widget toggle
qs ipc call powermenu toggle
```

Example Hyprland (Lua config) keybinds:

```lua
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("qs ipc call clock-widget toggle"))
hl.bind(mainMod .. " + A",       hl.dsp.exec_cmd("qs ipc call controlpanel toggle"))
hl.bind(mainMod .. " + D",       hl.dsp.exec_cmd("qs ipc call systemMonitor-widget toggle"))
hl.bind(mainMod .. " + Escape",  hl.dsp.exec_cmd("qs ipc call powermenu toggle"))
```

---

## Customization Tips

- **Colors** — edit [`quickshell/theme/Colors.qml`](quickshell/theme/Colors.qml) to change the shell palette globally.
- **Bar layout** — modify [`quickshell/bar/Bar.qml`](quickshell/bar/Bar.qml) to reorder or remove bar widgets.
- **Overlays/panels** — tune behavior in the files under [`quickshell/widgets/`](quickshell/widgets).
- **System metrics** — update polling/behavior in [`quickshell/state/SystemState.qml`](quickshell/state/SystemState.qml).
- **Wallpaper paths** — update `wallpaperDir` and `thumdir` in **both** [`quickshell/state/WallpaperState.qml`](quickshell/state/WallpaperState.qml) and [`quickshell/state/LiveWallpaperState.qml`](quickshell/state/LiveWallpaperState.qml) — they must match.

---

## Troubleshooting

This configuration is actively customized and may depend on specific desktop tools and system paths. If a feature doesn't work, check:

- [ ] Required CLI tools are installed (`wpctl`, `brightnessctl`, `jq`, etc.)
- [ ] The correct audio backend (PipeWire) is active
- [ ] Hyprland/Quickshell is running with the expected permissions
- [ ] File paths in state files (e.g. wallpaper directories) match your system

---

## License

Provided as-is for personal use.
