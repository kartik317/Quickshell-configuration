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

    readonly property int panX: screen ? (screen.width - width) / 2 : (1920 - 400) / 2
    readonly property int panY: 29
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    // ── Slide offset ───────────────────
    property real slideOffset: SysMonitorState.visible ? 0 : (implicitHeight + 8)
    Behavior on slideOffset {
        NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
    }

    visible: true
    implicitWidth: 400
    implicitHeight: 320
    color: "transparent"

    IpcHandler {
        target: "systemMonitor-widget"
        function toggle() {
            SysMonitorState.toggle()
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

    mask: Region {
        item: SysMonitorState.visible ? panel : null
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: SysMonitorState.visible
        onEntered: SysMonitorState.hoveringWidget = true
        onExited: SysMonitorState.hoveringWidget = false
    }

    Rectangle {
	id: panel

	anchors.fill: parent
	color: Qt.alpha(Colors.colBg, 0.85)
	radius: 12
	topLeftRadius: 0
	topRightRadius: 0

	transform: Translate {
	    y: -root.slideOffset
	}

        Column {
            anchors.fill: parent
            spacing: 0
            topPadding: 16
            bottomPadding: 16

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

            RowLayout {
                width: parent.width
                height: 150
                spacing: 0

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
    }
}
