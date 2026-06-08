import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../state"

PanelWindow {
    id: root
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
                text:           SystemState.currentLayout
                color:          Colors.colFg
                font.pixelSize: fontSize
                font.family:    fontFamily
                font.bold:      true
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
                elide:              Text.ElideRight
                maximumLineCount:   1
            }
            

            // hover to show system monitor
            MouseArea {
                Layout.fillWidth: true
                implicitHeight: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    SysMonitorState.visible = true;
                    hideTimer.stop();
                }
                onExited: {
                    hideTimer.start();
                }

                Text {
                    anchors {
                        fill: parent
                        leftMargin: 8
                    }
                    //text: SystemState.activeWindow
                    color: Colors.colPurple
                    font.pixelSize: fontSize
                    font.family: fontFamily
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Timer {
                id: hideTimer
                interval: 300
                repeat: true
                onTriggered: {
                    // Only close if we're not hovering over the widget
                    if (!SysMonitorState.hoveringWidget) {
                        SysMonitorState.visible = false;
                        stop();
                    }
                }
            }

            Connections {
                target: SysMonitorState
                function onHoveringWidgetChanged() {
                    if (!SysMonitorState.hoveringWidget && SysMonitorState.visible && !hideTimer.running) {
                        hideTimer.start();
                    }
                }
            }

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
