import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "./state"
import "./bar"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            property var modelData
            screen: modelData
        }
    }
}
