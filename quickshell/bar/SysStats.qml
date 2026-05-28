import QtQuick
import QtQuick.Layouts
import "../theme"
import "../state"

RowLayout {
    spacing: 0

    property string fontFamily
    property int    fontSize

    // helper to avoid repetition
    component StatText: Text {
        font.pixelSize: fontSize
        font.family:    fontFamily
        font.bold:      true
        Layout.rightMargin: 8
    }

    StatText { text: SystemState.kernelVersion; color: Colors.colRed }
    Separator {}
    StatText { text: "CPU: " + SystemState.cpuUsage + "%"; color: Colors.colYellow }
    Separator {}
    StatText { text: "Mem: "  + SystemState.memUsage + "%"; color: Colors.colCyan }
    Separator {}
    StatText { text: "Disk: " + SystemState.diskUsage + "%"; color: Colors.colBlue }
    Separator {}
    StatText { text: "Vol: "  + SystemState.volumeLevel + "%"; color: Colors.colPurple }
    Separator {}
    StatText {
        text:  "Bat: " + SystemState.batteryLevel + (SystemState.batteryCharging ? "" : "%")
        color: Colors.colYellow
    }
    Separator {}
}
