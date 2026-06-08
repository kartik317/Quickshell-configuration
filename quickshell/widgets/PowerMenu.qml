import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../state"

PanelWindow {
    id: root

    property var screen

    IpcHandler {
        target: "powermenu"
        function toggle() {
            PowerMenuState.toggle();
        }
    }

    // ── Layer / geometry ────────────────────────────────────────────────────
    anchors {
        top: true
        bottom: true
        left: true
    }

    // Window is always present — just 1px wide when closed
    implicitWidth: PowerMenuState.powerVisible ? 208 : 1

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "qs-powermenu-noanim"

    // ── Slide offset ────────────────────────────────────────────────────────
    // 0 = flush with left edge (open); card.width = fully off-screen (closed)
    property real slideOffset: PowerMenuState.powerVisible ? 0 : card.width + 8
    Behavior on slideOffset {
        NumberAnimation { duration: 600; easing.type: Easing.InOutSine }
    }

    // ── Process runners ─────────────────────────────────────────────────────
    Process {
        id: procLock
        command: ["loginctl", "lock-session"]
    }
    Process {
        id: procSuspend
        command: ["systemctl", "suspend"]
    }
    Process {
        id: procHibernate
        command: ["systemctl", "hibernate"]
    }
    Process {
        id: procReboot
        command: ["systemctl", "reboot"]
    }
    Process {
        id: procShutdown
        command: ["systemctl", "poweroff"]
    }

    function runAndClose(proc) {
        PowerMenuState.hide();
        proc.running = true;
    }

    // ── Invisible click-outside dismissal ───────────────────────────────────
    MouseArea {
        anchors.fill: parent
        z: -1
        enabled: PowerMenuState.powerVisible
        onClicked: PowerMenuState.hide()
    }

    // ── Menu card ───────────────────────────────────────────────────────────
    Rectangle {
        id: card

        anchors.verticalCenter: parent.verticalCenter

        // Slide: negative x moves card left off-screen
        x: -root.slideOffset

        width: 200
        height: menuCol.implicitHeight + 32

        topLeftRadius: 0
        bottomLeftRadius: 0
        topRightRadius: 18
        bottomRightRadius: 18

        // Translucent background
        color: Qt.rgba(Colors.colBg.r, Colors.colBg.g, Colors.colBg.b, 0.95)

        opacity: PowerMenuState.powerVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 560; easing.type: Easing.InOutSine } }

        // Border overlay — skips the flush left edge visually
        Rectangle {
            anchors.fill: parent
            z: 1
            color: "transparent"
            topLeftRadius: 0
            bottomLeftRadius: 0
            topRightRadius: parent.topRightRadius
            bottomRightRadius: parent.bottomRightRadius
            border.color: Qt.rgba(Colors.colFg.r, Colors.colFg.g, Colors.colFg.b, 0.08)
            border.width: 1
        }

        // Eat clicks so the background MouseArea doesn't dismiss on card clicks
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: menuCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 16
                topMargin: 16
            }
            spacing: 6

            // ── Title ──────────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: "POWER"
                color: Qt.rgba(Colors.colFg.r, Colors.colFg.g, Colors.colFg.b, 0.35)
                font.pixelSize: 10
                font.letterSpacing: 3
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.preferredHeight: 4
            }

            // ── Buttons ────────────────────────────────────────────────────
            PowerButton {
                label: "Lock"
                icon: "󰌾"
                hoverColor: Colors.colCyan
                onActivated: root.runAndClose(procLock)
            }
            PowerButton {
                label: "Suspend"
                icon: "󰒲"
                hoverColor: Colors.colBlue
                onActivated: root.runAndClose(procSuspend)
            }
            PowerButton {
                label: "Hibernate"
                icon: "󰋊"
                hoverColor: Colors.colPurple
                onActivated: root.runAndClose(procHibernate)
            }
            PowerButton {
                label: "Reboot"
                icon: "󰜉"
                hoverColor: Colors.colYellow
                onActivated: root.runAndClose(procReboot)
            }
            PowerButton {
                label: "Shutdown"
                icon: "󰐥"
                hoverColor: Colors.colRed
                onActivated: root.runAndClose(procShutdown)
            }

            Item {
                Layout.preferredHeight: 2
            }
        }
    }

    // ── Dismiss on Escape ───────────────────────────────────────────────────
    //Keys.onEscapePressed: PowerMenuState.hide()

    // ── Inner component: one menu row ───────────────────────────────────────
    component PowerButton: Rectangle {
        id: btn
        required property string label
        required property string icon
        required property color hoverColor
        signal activated

        Layout.fillWidth: true
        height: 44
        radius: 10
        color: ma.containsMouse ? Qt.rgba(hoverColor.r, hoverColor.g, hoverColor.b, 0.15) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: ma.containsMouse ? 3 : 0
            height: 22
            radius: 2
            color: btn.hoverColor
            Behavior on width {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 14
            }
            spacing: 12

            Text {
                text: btn.icon
                // ── Changed: Icon is now always blue ─────────────────────
                color: Colors.colBlue
                font.pixelSize: 18
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: btn.label
                color: Colors.colBlue
                font.pixelSize: 14
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }

        scale: ma.pressed ? 0.96 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }
}
