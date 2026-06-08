import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "./state"
import "./bar"
import Quickshell.Io
import "widgets"

ShellRoot {
    // ── Bar ────────────────────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens
        Bar {
            property var modelData
            screen: modelData
        }
    }

    // ── Draggable clock overlay ────────────────────────────────────────────
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: clockWindow
            property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            mask: Region {
                item: ClockState.clockVisible ? draggableClock : null
            }
            WlrLayershell.layer: WlrLayer.Bottom
            visible: ClockState.clockVisible
            DraggableClock {
                id: draggableClock
                screen: clockWindow.screen
            }
        }
    }

    // ── System monitor ─────────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens
        SysMonitor {
            id: sysMonitor
            property var modelData
            screen: modelData
        }
    }

    // ── Control panel (manual toggle, slides from right) ───────────────────
    Variants {
        model: Quickshell.screens
        Vol_Bri_Controls {
            property var modelData
            screen: modelData
        }
    }

    // ── Volume OSD (auto-shows on PipeWire sink events) ────────────────────
    Variants {
        model: Quickshell.screens
        VolumeOSD {
            property var modelData
            screen: modelData
        }
    }

    // ── Power menu overlay ─────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens
        PowerMenu {
            property var modelData
            screen: modelData
        }
    }
}

