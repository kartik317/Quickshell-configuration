import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../state"
import "../voice_assistant"

PanelWindow {
    id: root

    Process {
        id: appLauncherProcess
        command: ["qs", "ipc", "call", "applauncher", "toggle"]
    }

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 30
    color: Qt.alpha(Colors.colBg, 0.85)

    // Font config — adjust here only
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.colBg, 0.85)

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                width: 8
            }

            // Logo
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                color: "transparent"
                Image {
                    anchors.fill: parent
                    source: "../icons/arch.png"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        appLauncherProcess.running = true;
                    }
                }
            }

            Item {
                width: 8
            }

            // Workspaces
            Workspaces {
                fontFamily: root.fontFamily
                fontSize: root.fontSize
            }

            Separator {}

            // Layout mode
            Text {
                text: SystemState.currentLayout
                color: Colors.colFg
                font.pixelSize: fontSize
                font.family: fontFamily
                font.bold: true
                Layout.rightMargin: 5
            }

            Separator {}

            // Active window
            Text {
                text: SystemState.activeWindow
                color: Colors.colPurple
                font.pixelSize: fontSize
                font.family: fontFamily
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.maximumWidth: 800
                Layout.preferredWidth: implicitWidth < maximumWidth ? implicitWidth : maximumWidth
            }

            Item {
                Layout.fillWidth: true
            }

            Network {}

            Separator {}

            Battery {}

            Separator {}

            Clock {
                fontFamily: root.fontFamily
                fontSize: root.fontSize
                Layout.rightMargin: 8
            }

            Item {
                width: 8
            }
        }
    }
}
