import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../theme"

Item {
    property string fontFamily
    property int fontSize

    implicitWidth: 9 * 20
    implicitHeight: 30
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: 9
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: parent.height
                color: "transparent"

                property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                property bool hasWindows: (workspace?.toplevels?.values?.length ?? 0) > 0

                Text {
                    text: index + 1
                    color: (parent.isActive || parent.hasWindows) ? Colors.colFg : Colors.colBrightBlack
                    font.pixelSize: fontSize
                    font.family: fontFamily
                    font.bold: true
                    anchors.centerIn: parent
                }

                Rectangle {
                    width: 20
                    height: 3
                    color: parent.isActive ? Colors.colPurple : Colors.colBg
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (index + 1) + " })")
                }
            }
        }
    }
}
