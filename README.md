# Quickshell Configuration

A modern Quickshell setup for Hyprland-style desktop workflows with a polished top bar, live system monitoring, quick controls, and a compact app launcher.

## What this config includes

- A custom top bar with workspace, layout, active window, network, battery, and clock information
- A draggable clock overlay for quick access to the clock panel
- A system monitor popup with CPU, RAM, disk, temperature, and battery gauges
- A slide-in volume and brightness control panel
- A PipeWire-driven volume OSD
- A power menu with lock, suspend, hibernate, reboot, and shutdown actions
- An app launcher with recent-app tracking and keyboard navigation
- A lightweight voice assistant panel for wave feedback

## Project structure

```text
quickshell/
├── shell.qml                  # Main shell entry point
├── bar/
│   ├── Bar.qml                # Main top bar layout
│   ├── Battery.qml            # Battery status widget
│   ├── Clock.qml              # Clock display component
│   ├── Network.qml            # Network status widget
│   ├── Separator.qml          # Visual separator
│   └── Workspaces.qml         # Workspace switcher
├── icons/                     # Static icon assets
├── state/
│   ├── AppLauncherState.qml   # App launcher visibility + recent apps state
│   ├── ClockState.qml         # Clock overlay visibility state
│   ├── PowerMenuState.qml     # Power menu visibility state
│   ├── SysMonitorState.qml    # System monitor popup state
│   └── SystemState.qml        # Live system metrics and helpers
├── theme/
│   └── Colors.qml             # Shared color palette
├── voice_assistant/
│   ├── NovaPanel.qml          # Voice assistant widget panel
│   ├── NovaState.qml          # Voice assistant state
│   └── NovaWave.qml           # Wave visualization component
└── widgets/
    ├── AppLauncher.qml        # Full-screen app launcher UI
    ├── Clock.qml              # Draggable clock overlay widget
    ├── DraggableClock.qml     # Clock drag surface
    ├── GaugeRing.qml          # Circular gauge component
    ├── PowerMenu.qml          # Power actions menu
    ├── SysMonitor.qml         # System monitor popup UI
    ├── Vol_Bri_Controls.qml   # Volume/brightness control panel
    └── VolumeOSD.qml          # On-screen volume display
```

## Core components

### Bar and shell
- [quickshell/shell.qml](quickshell/shell.qml) wires together the bar, overlays, widgets, and panels for each screen.
- [quickshell/bar/Bar.qml](quickshell/bar/Bar.qml) defines the top bar layout and places the main widgets.

### State and monitoring
- [quickshell/state/SystemState.qml](quickshell/state/SystemState.qml) collects live system information such as CPU usage, memory, disk usage, volume, battery, active window, and layout state.
- [quickshell/widgets/SysMonitor.qml](quickshell/widgets/SysMonitor.qml) renders a detailed popup for system health and power info.

### Controls and overlays
- [quickshell/widgets/Vol_Bri_Controls.qml](quickshell/widgets/Vol_Bri_Controls.qml) provides the slide-out volume and brightness UI.
- [quickshell/widgets/VolumeOSD.qml](quickshell/widgets/VolumeOSD.qml) shows transient audio feedback when the volume changes.
- [quickshell/widgets/PowerMenu.qml](quickshell/widgets/PowerMenu.qml) offers quick power actions.
- [quickshell/widgets/AppLauncher.qml](quickshell/widgets/AppLauncher.qml) provides a searchable app picker with recent app support.

### Visual theme
- [quickshell/theme/Colors.qml](quickshell/theme/Colors.qml) centralizes the color palette used across the shell.

### How to use
every widget has ipc handler to use them run:
    
`qs ipc call applauncher toggle`

`qs ipc call clock-widget toggle`
    
`qs ipc call controlpanel toggle`

`qs ipc call systemMonitor-widget toggle`
    
`qs ipc call powermenu toggle`

Bind keys in hyprland

`hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("qs ipc call clock-widget toggle"))`

`hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs ipc call controlpanel toggle"))`

`hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs ipc call systemMonitor-widget toggle"))`

`hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("qs ipc call powermenu toggle"))`

---

## Requirements

This setup expects a working Quickshell environment with the following tools available:

- Quickshell
- Hyprland-compatible environment
- PipeWire + WirePlumber for volume control via `wpctl`
- `brightnessctl` for brightness changes
- `jq` for parsing Hyprland window data
- A Nerd Font such as JetBrainsMono Nerd Font

## Getting started

1. Make sure Quickshell is installed and running.
2. Copy or link this repository into your Quickshell configuration directory.
3. Adjust any paths or commands in the QML files if your system uses different tool locations.
4. Restart Quickshell to load the updated configuration.

## Customization tips

- Edit [quickshell/theme/Colors.qml](quickshell/theme/Colors.qml) to change the shell palette globally.
- Modify [quickshell/bar/Bar.qml](quickshell/bar/Bar.qml) to reorder or remove bar widgets.
- Tune the behavior of overlays and panels in the files under [quickshell/widgets](quickshell/widgets).
- Update the state logic in [quickshell/state/SystemState.qml](quickshell/state/SystemState.qml) if you want different system metrics or polling behavior.

## Notes

This configuration is actively customized and may depend on specific desktop tools and system paths. If a feature does not appear to work, the first things to check are:

- whether the required CLI tools are installed,
- whether the correct audio backend is active,
- and whether Hyprland/Quickshell is running with the expected permissions.

## License

This configuration is provided as-is for personal use.
