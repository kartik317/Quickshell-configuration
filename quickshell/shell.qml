import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "./state"
import "./bar"
import Quickshell.Io
import "widgets"

ShellRoot {
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
          mask: Region { item: draggableClock }
          WlrLayershell.layer: WlrLayer.Bottom

        DraggableClock {
            id: draggableClock
            screen: clockWindow.screen
          }
        }
    }
}

