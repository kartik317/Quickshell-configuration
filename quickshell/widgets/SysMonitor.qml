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

    // Tucks 1px under the bar to hide the top border edge
    readonly property int panX: screen ? (screen.width - width) / 2 : (1920 - 400) / 2
    readonly property int panY: 29
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    property bool _closing: false

    visible: SysMonitorState.visible || _closing
    implicitWidth: 400
    implicitHeight: 320
    color: "transparent"

    IpcHandler {
        target: "systemMonitor-widget"
        function toggle() {
            SysMonitorState.toggle();
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-sysmonitor-noani"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
    }

    margins {
        top: root.panY
        left: root.panX
    }

    Connections {
        target: SysMonitorState
        function onVisibleChanged() {
            if (!SysMonitorState.visible) {
                root._closing = true;
                exitDelay.restart();
            }
        }
    }

    Timer {
        id: exitDelay
        interval: 220
        onTriggered: root._closing = false
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: SysMonitorState.hoveringWidget = true
        onExited: SysMonitorState.hoveringWidget = false
    }

    Rectangle {
        id: panel

        anchors.fill: parent
        color: Qt.alpha(Colors.colBg, 0.96)
        radius: 12
        topLeftRadius: 0
        topRightRadius: 0
        opacity: SysMonitorState.visible ? 1 : 0
        scale: SysMonitorState.visible ? 1 : 0.97
        transformOrigin: Item.Top

        Column {
            anchors.fill: parent
            spacing: 0
            topPadding: 16
            bottomPadding: 16

            // ── Gauge rings: CPU / RAM / Disk ──────────────
            RowLayout {
                width: parent.width
                height: 150
                spacing: 0

                Repeater {
                    model: 3

                    delegate: Item {
                        readonly property string lbl: ["CPU", "RAM", "Disk"][index]
                        readonly property string ico: ["󰻠", "󰍛", "󰋊"][index]
                        readonly property int val: [SystemState.cpuUsage, SystemState.memUsage, SystemState.diskUsage][index]

                        Layout.fillWidth: true
                        height: 150

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: ico
                                color: Qt.alpha(Colors.colFg, 0.96)
                                font.pixelSize: 14
                                font.family: root.monoFont
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

            // ── Gauge rings: CPU Temp / GPU Temp / Battery ──
            RowLayout {
                width: parent.width
                height: 150
                spacing: 0

                // CPU Temp
                Item {
                    Layout.fillWidth: true
                    height: 150

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰔏"
                            color: Qt.alpha(Colors.colFg, 0.96)
                            font.pixelSize: 14
                            font.family: root.monoFont
                        }

                        GaugeRing {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 90
                            height: 90
                            value: SystemState.cpuTemp
                            label: "CPU Temp"
                            unit: "°C"
                        }
                    }
                }

                // GPU Temp
                Item {
                    Layout.fillWidth: true
                    height: 150

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰢮"
                            color: Qt.alpha(Colors.colFg, 0.96)
                            font.pixelSize: 14
                            font.family: root.monoFont
                        }

                        GaugeRing {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 90
                            height: 90
                            value: SystemState.gpuTemp
                            label: "iGPU Temp"
                            unit: "°C"
                        }
                    }
                }

                // Battery
                Item {
                    Layout.fillWidth: true
                    height: 150

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: {
                                if (SystemState.batteryCharging)
                                    return "󰂄";
                                const l = SystemState.batteryLevel;
                                return l > 80 ? "󰁹" : l > 60 ? "󰁾" : l > 40 ? "󰁼" : l > 20 ? "󰁻" : "󰁺";
                            }
                            color: Qt.alpha(Colors.colFg, 0.96)
                            font.pixelSize: 14
                            font.family: root.monoFont
                        }

                        GaugeRing {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 90
                            height: 90
                            value: SystemState.batteryLevel
                            label: "Battery"
                            unit: "%"
                            useCustomColor: true
                            customArcColor: SystemState.batteryCharging ? Colors.colGreen : (SystemState.batteryLevel < 20 ? Colors.colRed : (SystemState.batteryLevel < 50 ? Colors.colYellow : Colors.colBlue))
                        }
                    }
                }
            }
        }

        transform: Translate {
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
