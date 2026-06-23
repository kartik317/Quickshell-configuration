import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell.Io
import "../theme"

RowLayout {
    id: root
    spacing: 6

    Process {
        id: nmProcess
        command: ["kitty", "-e", "nmtui"]
    }

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null 

    readonly property real signal: active ? active.signalStrength : 0

    readonly property string icon: {
        if (!Networking.wifiEnabled) return String.fromCodePoint(0xF05AA)
        if (!active) return String.fromCodePoint(0xF092D)

        let tier = signal >= 0.75 ? 4
            : signal >= 0.5 ? 3
            : signal >= 0.25 ? 2
            : 1
        
        return String.fromCodePoint(0xF091F + (tier - 1) * 3)
    }

    Text {
        text: root.icon
        color: Networking.wifiEnabled ? Colors.colFg: Colors.colBg

        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 14
        }
    }

    Text {
        text: {
            if (!Networking.wifiEnabled) return "Off "
            if (!root.active) return "Disconnected "
            return root.active.name + "  "
        }
        color: Networking.wifiEnabled ? Colors.colFg : Colors.colBg

        font {
            family: "SF Pro Display"
            pixelSize: 14
            weight: 500
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                nmProcess.running = true
            }
        }
    }
}
