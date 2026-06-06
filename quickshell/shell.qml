import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "./state"
import "./bar"
import Quickshell.Io
import "./widgets"

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
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
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

    // ── Control panel (volume + brightness, slides in from right) ──────────
    Variants {
        model: Quickshell.screens
        ControlPanel {
            property var modelData
            screen: modelData
        }
    }
}
