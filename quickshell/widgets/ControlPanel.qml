import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../state"
import "../theme"

// Toggle: qs ipc call controlpanel toggle
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    property bool open: false
    property int  brightnessValue: 50
    property int  maxBrightness:   1000

    // ── IPC ────────────────────────────────────────────────────────────────
    IpcHandler {
        target: "controlpanel"
        function toggle() {
            root.open = !root.open
        }
    }

    // ── Layer shell ────────────────────────────────────────────────────────
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace:     "qs-controlpanel-noanim"
    WlrLayershell.exclusiveZone: 0

    anchors.right:  true
    anchors.top:    true
    anchors.bottom: true

    width: root.open ? 160 : 1
    color: "transparent"

    // ── Slide ──────────────────────────────────────────────────────────────
    property real slideOffset: open ? 0 : panelCard.width + 16
    Behavior on slideOffset {
        NumberAnimation { duration: 340; easing.type: Easing.OutExpo }
    }

    // ── Read brightness once at startup ────────────────────────────────────
    // brightnessctl -m  →  "device,max,current,current%,"
    Process {
        id: brightnessInit
        command: ["brightnessctl", "-m"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(",")
                if (parts.length >= 3) {
                    const mx  = parseInt(parts[1])
                    const cur = parseInt(parts[2])
                    if (!isNaN(mx) && mx > 0) {
                        root.maxBrightness   = mx
                        root.brightnessValue = Math.round(cur / mx * 100)
                    }
                }
            }
        }
    }

    function setBrightness(percent) {
        root.brightnessValue = percent
        const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        proc.command = ["brightnessctl", "set", percent + "%"]
        proc.running = true
    }

    // ── Dismiss on click-outside ───────────────────────────────────────────
   MouseArea {
        anchors.fill: parent
        z: -1
        enabled: root.open
        hoverEnabled: root.open     // optional, prevents cursor fighting
    
        onClicked: mouse => {
            const p = mapToItem(panelCard, mouse.x, mouse.y)
            if (!panelCard.contains(p))
             root.open = false
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  Panel card
    // ═══════════════════════════════════════════════════════════════════════
    Rectangle {
        id: panelCard

        width:  140
        height: 340
        anchors.verticalCenter: parent.verticalCenter
        x: root.slideOffset + 8

        color:   Qt.rgba(Colors.colBg.r, Colors.colBg.g, Colors.colBg.b, 0.93)
        radius:  16
        opacity: root.open ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        // Border
        Rectangle {
            anchors.fill: parent; radius: parent.radius; z: 1
            color: "transparent"
            border.color: Qt.alpha(Colors.colFg, 0.10)
            border.width: 1
        }

        RowLayout {
            anchors { fill: parent; margins: 18 }
            spacing: 12

            // ── Volume ─────────────────────────────────────────────────────
            VSliderBlock {
                Layout.fillHeight: true
                Layout.fillWidth:  true

                iconText:    SystemState.volumeMuted         ? "\uf026"
                             : SystemState.volumeLevel > 60  ? "\uf028"
                             :                                 "\uf027"
                label:       "Vol"
                sliderValue: SystemState.volumeLevel
                muted:       SystemState.volumeMuted

                onSlide:   val => SystemState.setVolume(val)
                onIconTap: SystemState.toggleMute()
            }

            Rectangle {
                width: 1; Layout.fillHeight: true
                color: Qt.alpha(Colors.colFg, 0.08)
            }

            // ── Brightness ─────────────────────────────────────────────────
            VSliderBlock {
                Layout.fillHeight: true
                Layout.fillWidth:  true

                iconText:    root.brightnessValue < 30 ? "\uf185"
                             : root.brightnessValue < 70 ? "\uf185"
                             :                             "\uf185"
                label:       "Bri"
                sliderValue: root.brightnessValue
                muted:       false

                onSlide:   val => root.setBrightness(val)
                onIconTap: {}
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  VSliderBlock  —  fully custom, no Qt Quick Controls
    // ═══════════════════════════════════════════════════════════════════════
    component VSliderBlock: ColumnLayout {
        id: block

        property string iconText:    ""
        property string label:       ""
        property int    sliderValue: 50
        property bool   muted:       false

        signal slide(int value)
        signal iconTap()

        spacing: 8

        // Icon button
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 34; height: 34; radius: 10
            color: block.muted ? Qt.alpha(Colors.colRed,  0.25)
                               : Qt.alpha(Colors.colBlue, 0.18)
            Behavior on color { ColorAnimation { duration: 180 } }

            Text {
                anchors.centerIn: parent
                text: block.iconText; font.pixelSize: 16
                color: block.muted ? Colors.colRed : Colors.colBlue
                Behavior on color { ColorAnimation { duration: 180 } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    block.iconTap()
            }
        }

        // Value readout
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: block.sliderValue + "%"
            font.pixelSize: 11
            color: Colors.colBrightBlack
        }

        // ── Custom vertical slider ─────────────────────────────────────────
        // Plain Item + MouseArea — avoids all Qt Quick Controls drag quirks.
        // Top = 100 (max), Bottom = 0 (min).
        Item {
            id: sliderItem
            Layout.fillHeight: true
            Layout.alignment:  Qt.AlignHCenter
            implicitWidth:     40    // wide enough for comfortable touch/drag

            // Effective slider height (leave room for handle overhang)
            readonly property int trackH:    height - handle.height
            // 0..1 fill fraction, clamped
            readonly property real fraction: Math.max(0, Math.min(1, block.sliderValue / 100.0))

            // Track background
            Rectangle {
                id: track
                width:  4
                height: sliderItem.trackH
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                radius: 2
                color: Qt.alpha(Colors.colBlack, 0.7)

                // Fill — grows from bottom
                Rectangle {
                    width:          parent.width
                    height:         sliderItem.fraction * parent.height
                    anchors.bottom: parent.bottom
                    radius:         parent.radius
                    color:          block.muted ? Colors.colBlack : Colors.colBlue
                    Behavior on height { NumberAnimation { duration: 40  } }
                    Behavior on color  { ColorAnimation  { duration: 200 } }
                }
            }

            // Handle
            Rectangle {
                id: handle
                width: 16; height: 16; radius: 8
                anchors.horizontalCenter: parent.horizontalCenter
                // fraction=1 → y=0 (top);  fraction=0 → y=trackH (bottom)
                y: (1.0 - sliderItem.fraction) * sliderItem.trackH
                color: dragArea.pressed ? Colors.colPurple
                       : block.muted    ? Colors.colBlack
                       :                  Colors.colBlue
                scale: dragArea.pressed ? 1.25 : 1.0
                Behavior on color { ColorAnimation  { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 90  } }
                // No Behavior on y — instant follow during drag feels right
            }

            // Drag / click — covers the full item width for easy interaction
            MouseArea {
                id: dragArea
                anchors.fill: parent

                function valueFromY(my) {
                    // Clamp mouseY to usable track range
                    const clamped = Math.max(handle.height / 2,
                                    Math.min(sliderItem.height - handle.height / 2, my))
                    const ratio   = 1.0 - (clamped - handle.height / 2) / sliderItem.trackH
                    return Math.round(ratio * 100)
                }

                onPressed:         mouse => block.slide(valueFromY(mouse.y))
                onPositionChanged: mouse => { if (pressed) block.slide(valueFromY(mouse.y)) }
            }
        }

        // Label
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: block.label; font.pixelSize: 11; font.weight: Font.Medium
            color: Colors.colBrightBlack
        }
    }
}
