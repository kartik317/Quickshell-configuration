import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../state"

PanelWindow {
    id: root
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: Qt.alpha(Colors.colBg, 0.6)

    // Font config — adjust here only
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int    fontSize:   14

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.colBg, 0.6)

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item { width: 8 }

            // Logo
            Rectangle {
                Layout.preferredWidth:  24
                Layout.preferredHeight: 24
                color: "transparent"
                Image {
                    anchors.fill: parent
                    source: "../icons/arch.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Item { width: 8 }

            // Workspaces
            Workspaces {
                fontFamily: root.fontFamily
                fontSize:   root.fontSize
            }

            Separator {}

            // Layout mode
            Text {
                text:           SystemState.currentLayout
                color:          Colors.colFg
                font.pixelSize: fontSize
                font.family:    fontFamily
                font.bold:      true
                Layout.leftMargin:  5
                Layout.rightMargin: 5
            }

            Separator {}

            // Active window (fills remaining space)
            Text {
                text:           SystemState.activeWindow
                color:          Colors.colPurple
                font.pixelSize: fontSize
                font.family:    fontFamily
                font.bold:      true
                Layout.fillWidth:   true
                Layout.leftMargin:  8
                elide:              Text.ElideRight
                maximumLineCount:   1
            }

            // Right side: stats + clock
            SysStats { fontFamily: root.fontFamily; fontSize: root.fontSize }
            Clock    { fontFamily: root.fontFamily; fontSize: root.fontSize; Layout.rightMargin: 8 }

            Item { width: 8 }
        }
    }
}
