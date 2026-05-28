# Quickshell Configuration

A modern, customizable shell configuration for Quickshell with a feature-rich status bar and system monitoring.

## Project Structure

```
quickshell/
├── shell.qml                 # Main shell configuration
├── bar/
│   ├── Bar.qml              # Main status bar component
│   ├── Clock.qml            # Time/date display widget
│   ├── Separator.qml        # Visual separator component
│   ├── SysStats.qml         # System statistics display
│   └── Workspaces.qml       # Workspace switcher
├── icons/                   # Icon assets
├── state/
│   └── SystemState.qml      # System state management
└── theme/
    └── Colors.qml           # Color scheme and theming
```

## Features

- **Status Bar** - Customizable top-level bar with multiple widgets
- **Clock Widget** - Real-time clock and date display
- **System Statistics** - Monitor CPU, memory, and system metrics
- **Workspace Switcher** - Quick workspace navigation
- **Theme Support** - Centralized color scheme management
- **Modular Design** - Clean separation of concerns for easy customization

## Components

### Bar
The main status bar interface with integrated widgets:
- **Bar.qml** - Primary bar container and layout manager
- **Clock.qml** - Time display with formatting options
- **SysStats.qml** - Real-time system monitoring
- **Workspaces.qml** - Active workspace indicator
- **Separator.qml** - Visual spacing between widgets

### State Management
- **SystemState.qml** - Centralized state for system information and updates

### Theme
- **Colors.qml** - Global color palette and theme definitions

## Getting Started

1. Ensure Quickshell is installed on your system
2. Clone this repository or copy to your Quickshell configuration directory
3. Configure `shell.qml` with your preferred settings
4. Customize `theme/Colors.qml` to match your color scheme
5. Restart Quickshell to apply changes

## Customization

### Changing Colors
Edit [theme/Colors.qml](theme/Colors.qml) to modify the color scheme across all components.

### Adding New Widgets
1. Create a new `.qml` file in the `bar/` directory
2. Import it in [bar/Bar.qml](bar/Bar.qml)
3. Add it to the bar layout

### Modifying Bar Layout
Edit [bar/Bar.qml](bar/Bar.qml) to rearrange, add, or remove widgets.

## Configuration Files

- **shell.qml** - Main entry point and shell configuration
- **bar/Bar.qml** - Bar layout and widget composition
- **theme/Colors.qml** - Global color definitions
- **state/SystemState.qml** - Application state management

## Requirements

- Quickshell (latest version recommended)
- QML runtime environment

## License

This configuration is provided as-is for personal use.