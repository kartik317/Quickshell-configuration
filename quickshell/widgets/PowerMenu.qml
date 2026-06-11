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

    // ── Keyboard selection state ─────────────────────────────────────────────
    property int selectedIndex: -1
    readonly property int buttonCount: 5

    function activateSelected() {
        switch (selectedIndex) {
            case 0: runAndClose(procLock); break;
            case 1: runAndClose(procSuspend); break;
            case 2: runAndClose(procHibernate); break;
            case 3: runAndClose(procReboot); break;
            case 4: runAndClose(procShutdown); break;
        }
    }

    // Reset selection / grab focus on visibility change
    Connections {
        target: PowerMenuState
        function onPowerVisibleChanged() {
            if (PowerMenuState.powerVisible)
                powerCard.forceActiveFocus()
            else
                root.selectedIndex = -1
        }
    }

    IpcHandler {
        target: "powermenu"
        function toggle() {
            PowerMenuState.toggle();
        }
    }

    // ── Layer / geometry ─────────────────────────────────────────────────────
    anchors {
        top: true
        bottom: true
        left: true
    }

    implicitWidth: 208

    mask: Region {
        item: powerCard
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "qs-powermenu-noanim"

    // ── Slide offset ─────────────────────────────────────────────────────────
    property real slideOffset: PowerMenuState.powerVisible ? 0 : powerCard.width + 8
    Behavior on slideOffset {
        NumberAnimation { duration: 300; easing.type: Easing.InOutSine }
    }

    // ── Process runners ──────────────────────────────────────────────────────
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

    // ── Menu card ────────────────────────────────────────────────────────────
    Rectangle {
        id: powerCard

        focus: true

        // ── Key handling (must be on an Item, not PanelWindow) ───────────────
        Keys.onPressed: function(event) {
            if (!PowerMenuState.powerVisible) return;
            if (event.key === Qt.Key_Up) {
                root.selectedIndex = (root.selectedIndex - 1 + root.buttonCount) % root.buttonCount;
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.selectedIndex = (root.selectedIndex + 1) % root.buttonCount;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.selectedIndex >= 0) root.activateSelected();
                event.accepted = true;
            }
        }
        Keys.onEscapePressed: PowerMenuState.hide()

        anchors.verticalCenter: parent.verticalCenter

        x: -root.slideOffset

        width: 200
        height: menuCol.implicitHeight + 32

        topLeftRadius: 0
        bottomLeftRadius: 0
        topRightRadius: 18
        bottomRightRadius: 18

        color: Qt.rgba(Colors.colBg.r, Colors.colBg.g, Colors.colBg.b, 0.95)

        opacity: PowerMenuState.powerVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.InOutSine } }

        // Border overlay
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

        // Eat clicks so background doesn't dismiss on card clicks
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

            Text {
                Layout.fillWidth: true
                text: "POWER"
                color: Qt.rgba(Colors.colFg.r, Colors.colFg.g, Colors.colFg.b, 0.35)
                font.pixelSize: 10
                font.letterSpacing: 3
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredHeight: 4 }

            PowerButton {
                label: "Lock"
                icon: "󰌾"
                hoverColor: Colors.colCyan
                selected: root.selectedIndex === 0
                onActivated: root.runAndClose(procLock)
            }
            PowerButton {
                label: "Suspend"
                icon: "󰒲"
                hoverColor: Colors.colBlue
                selected: root.selectedIndex === 1
                onActivated: root.runAndClose(procSuspend)
            }
            PowerButton {
                label: "Hibernate"
                icon: "󰋊"
                hoverColor: Colors.colPurple
                selected: root.selectedIndex === 2
                onActivated: root.runAndClose(procHibernate)
            }
            PowerButton {
                label: "Reboot"
                icon: "󰜉"
                hoverColor: Colors.colYellow
                selected: root.selectedIndex === 3
                onActivated: root.runAndClose(procReboot)
            }
            PowerButton {
                label: "Shutdown"
                icon: "󰐥"
                hoverColor: Colors.colRed
                selected: root.selectedIndex === 4
                onActivated: root.runAndClose(procShutdown)
            }

            Item { Layout.preferredHeight: 2 }
        }
    }

    // ── Inner component: one menu row ────────────────────────────────────────
    component PowerButton: Rectangle {
        id: btn
        required property string label
        required property string icon
        required property color hoverColor
        property bool selected: false
        signal activated

        Layout.fillWidth: true
        height: 44
        radius: 10

        color: (ma.containsMouse || selected)
               ? Qt.rgba(hoverColor.r, hoverColor.g, hoverColor.b, 0.15)
               : "transparent"

        Behavior on color { ColorAnimation { duration: 140 } }

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: (ma.containsMouse || btn.selected) ? 3 : 0
            height: 22
            radius: 2
            color: btn.hoverColor
            Behavior on width {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
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
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    }
}
