import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "./state"
import "./bar"
import Quickshell.Io
import "widgets"

ShellRoot {
    IpcHandler {
      target: "clock-widget"

      function toggle() {
          ClockState.clockVisible = !ClockState.clockVisible
      }
    }

    Variants {
        model: Quickshell.screens
        Bar {
            property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: clockWindow
            property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            mask: Region { item: ClockState.clockVisible ? draggableClock : null }
            WlrLayershell.layer: WlrLayer.Bottom
            visible: ClockState.clockVisible
            DraggableClock {
                id: draggableClock
                screen: clockWindow.screen
            }
        }
    }

    Variants {
        model: Quickshell.screens
        SysMonitor {
            id: sysMonitor
            property var modelData
            screen: modelData
        }
    }
}
