import "../state"
import "../theme"
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool _closing: false
    property int panX: screen ? (screen.width - width) / 2 : (1920 - 460) / 2
    // 29 instead of 30 — tucks 1px under the bar, hides the top border edge
    property int panY: 29

    visible: SysMonitorState.visible || _closing
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    implicitWidth: 460
    implicitHeight: 372 // 420 - 48 (header removed)
    color: "transparent"

    Connections {
        function onVisibleChanged() {
            if (!SysMonitorState.visible) {
                root._closing = true;
                exitDelay.restart();
            }
        }

        target: SysMonitorState
    }

    Timer {
        id: exitDelay

        interval: 220
        onTriggered: root._closing = false
    }

    anchors {
        top: true
        left: true
    }

    margins {
        top: root.panY
        left: root.panX
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: SysMonitorState.hoveringWidget = true
        onExited: SysMonitorState.hoveringWidget = false
    }

    Rectangle {
        //border.color: Qt.alpha(Colors.colBrightBlack, 0.5)
        //border.width: 1

        id: panel

        anchors.fill: parent
        color: Qt.alpha(Colors.colBg, 0.85)
        radius: 12
        // Zero out top corners — flush connection with the bar
        topLeftRadius: 0
        topRightRadius: 0
        // ── Visibility animations ──────────────────────────────
        opacity: SysMonitorState.visible ? 1 : 0
        scale: SysMonitorState.visible ? 1 : 0.97
        transformOrigin: Item.Top

        Column {
            anchors.fill: parent
            spacing: 0

            // ═══════════════════════════════════════════════
            //  Gauge rings: CPU / RAM / Disk
            // ═══════════════════════════════════════════════
            Item {
                width: parent.width
                height: 16
            }

            RowLayout {
                width: parent.width
                height: 150
                spacing: 0

                Repeater {
                    model: 3

                    delegate: Item {
                        readonly property string lbl: ["CPU", "RAM", "Disk"][index]
                        readonly property string ico: ["󰻠", "󰍛", "󰋊"][index]
                        readonly property int val: index === 0 ? SystemState.cpuUsage : index === 1 ? SystemState.memUsage : SystemState.diskUsage

                        Layout.fillWidth: true
                        height: 150

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: ico
                                color: Qt.alpha(Colors.colFg, 0.5)

                                font {
                                    pixelSize: 14
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            GaugeRing {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 90
                                height: 90
                                value: val
                                label: lbl
                            }
                        }
                    }
                }
            }

            // Divider
            Item {
                width: parent.width
                height: 6
            }

            Rectangle {
                width: parent.width - 32
                x: 16
                height: 1
                color: Qt.alpha(Colors.colBrightBlack, 0.4)
            }

            Item {
                width: parent.width
                height: 6
            }

            // ═══════════════════════════════════════════════
            //  Volume + Battery
            // ═══════════════════════════════════════════════
            Item {
                width: parent.width
                height: 70

                RowLayout {
                    spacing: 12

                    anchors {
                        fill: parent
                        leftMargin: 16
                        rightMargin: 16
                    }

                    // ── Volume ──────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        height: 70
                        color: Qt.alpha(Colors.colBg, 0.7)
                        radius: 10

                        RowLayout {
                            spacing: 10

                            anchors {
                                fill: parent
                                margins: 12
                            }

                            Text {
                                text: SystemState.volumeLevel === 0 ? "󰝟" : SystemState.volumeLevel < 50 ? "󰕿" : "󰕾"
                                color: Colors.colPurple

                                font {
                                    pixelSize: 22
                                    family: "JetBrainsMono Nerd Font"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SystemState.toggleMute()
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: "Volume"
                                        Layout.fillWidth: true
                                        color: Qt.alpha(Colors.colFg, 0.6)

                                        font {
                                            pixelSize: 10
                                            family: "JetBrainsMono Nerd Font"
                                        }
                                    }

                                    Text {
                                        text: SystemState.volumeLevel + "%"
                                        color: Colors.colFg

                                        font {
                                            pixelSize: 12
                                            bold: true
                                            family: "JetBrainsMono Nerd Font"
                                        }
                                    }
                                }

                                // ── Slider track (no clip so thumb can overflow) ──
                                Item {
                                    width: parent.width
                                    height: 16 // tall enough to absorb the thumb height

                                    // Track background
                                    Rectangle {
                                        id: volTrack

                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        height: 5
                                        radius: 3
                                        color: Qt.alpha(Colors.colBrightBlack, 0.3)

                                        // Fill
                                        Rectangle {
                                            id: volFill

                                            width: volTrack.width * SystemState.volumeLevel / 100
                                            height: parent.height
                                            radius: parent.radius
                                            color: Colors.colPurple

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: 100
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }

                                    // Thumb ball
                                    Rectangle {
                                        id: volThumb

                                        width: 13
                                        height: 13
                                        radius: 7
                                        color: Colors.colFg
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: (volTrack.width * SystemState.volumeLevel / 100) - width / 2
                                        z: 2

                                        Behavior on x {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }

                                    // Hit area (vertically generous so thumb is easy to grab)
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: {
                                            const newLevel = Math.max(0, Math.min(100, Math.round(mouseX / volTrack.width * 100)));
                                            SystemState.setVolume(newLevel);
                                        }
                                        onPositionChanged: {
                                            if (pressed) {
                                                const newLevel = Math.max(0, Math.min(100, Math.round(mouseX / volTrack.width * 100)));
                                                SystemState.setVolume(newLevel);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Battery ─────────────────────────────
                    Rectangle {
                        id: batCard

                        readonly property color batCol: SystemState.batteryCharging ? Colors.colGreen : SystemState.batteryLevel > 20 ? Colors.colYellow : Colors.colRed

                        Layout.fillWidth: true
                        height: 70
                        color: Qt.alpha(Colors.colBg, 0.7)
                        radius: 10

                        RowLayout {
                            spacing: 10

                            anchors {
                                fill: parent
                                margins: 12
                            }

                            Text {
                                text: {
                                    if (SystemState.batteryCharging)
                                        return "󰂄";

                                    var l = SystemState.batteryLevel;
                                    return l > 80 ? "󰁹" : l > 60 ? "󰁾" : l > 40 ? "󰁼" : l > 20 ? "󰁻" : "󰁺";
                                }
                                color: batCard.batCol

                                font {
                                    pixelSize: 22
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: SystemState.batteryCharging ? "Charging" : "Battery"
                                        Layout.fillWidth: true
                                        color: Qt.alpha(Colors.colFg, 0.6)

                                        font {
                                            pixelSize: 10
                                            family: "JetBrainsMono Nerd Font"
                                        }
                                    }

                                    Text {
                                        text: SystemState.batteryLevel + "%"
                                        color: Colors.colFg

                                        font {
                                            pixelSize: 12
                                            bold: true
                                            family: "JetBrainsMono Nerd Font"
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 5
                                    radius: 3
                                    color: Qt.alpha(Colors.colBrightBlack, 0.3)

                                    Rectangle {
                                        width: parent.width * SystemState.batteryLevel / 100
                                        height: parent.height
                                        radius: parent.radius
                                        color: batCard.batCol

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 300
                                                easing.type: Easing.OutCubic
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 400
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════
            //  System info row
            // ═══════════════════════════════════════════════
            Item {
                width: parent.width
                height: 12
            }

            Item {
                width: parent.width
                height: 78

                Rectangle {
                    color: Qt.alpha(Colors.colBg, 0.7)
                    radius: 10

                    anchors {
                        fill: parent
                        leftMargin: 16
                        rightMargin: 16
                    }

                    ColumnLayout {
                        spacing: 8

                        anchors {
                            fill: parent
                            margins: 12
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: "󰖲"
                                color: Colors.colCyan

                                font {
                                    pixelSize: 12
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Text {
                                text: "win"
                                color: Qt.alpha(Colors.colFg, 0.6)

                                font {
                                    pixelSize: 10
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Text {
                                text: SystemState.activeWindow
                                color: Colors.colFg
                                Layout.fillWidth: true
                                elide: Text.ElideRight

                                font {
                                    pixelSize: 11
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: "󰕰"
                                color: Colors.colYellow

                                font {
                                    pixelSize: 12
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Text {
                                text: SystemState.currentLayout
                                color: Colors.colFg

                                font {
                                    pixelSize: 11
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "󰌽"
                                color: Colors.colCyan

                                font {
                                    pixelSize: 12
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Text {
                                text: SystemState.kernelVersion
                                color: Colors.colFg

                                font {
                                    pixelSize: 11
                                    family: "JetBrainsMono Nerd Font"
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 16
            }
        }

        transform: Translate {
            id: slideY

            y: SysMonitorState.visible ? 0 : -10

            Behavior on y {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }
}
