import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root
    property var modelData
    screen: modelData

    property int _lastVol: -1
    property bool _lastMuted: false
    property bool osdVisible: false
    property int vol: 0
    property bool muted: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-vol-osd-noanim"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: 0

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 100

    // magic code :)
    mask: Region {
        item: osdCard
    }

    color: "transparent"

    // ── Auto-hide ───────────────────────────────────────────────────────────
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.osdVisible = false
    }

    // ── Watchdog: revive pactl if it dies ──────────────────────────────────
    Timer {
        id: pactlRestartTimer
        interval: 1500
        onTriggered: {
            if (!pactlSub.running)
                pactlSub.running = true;
        }
    }

    // ── PipeWire event watcher (long-lived) ────────────────────────────────
    Process {
        id: pactlSub
        command: ["pactl", "subscribe"]
        running: true
        onRunningChanged: {
            if (!running)
                pactlRestartTimer.start();
        }
        stdout: SplitParser {
            onRead: data => {
                // "Event 'change' on sink #0"
                if (data.includes("change") && data.includes("sink") && !volQuery.running)
                    volQuery.running = true;
            }
        }
    }

    // ── Volume query (short-lived, re-run on each event) ───────────────────
    Process {
        id: volQuery
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                const newMuted = data.includes("[MUTED]");
                const m = data.match(/([\d.]+)/);
                if (!m)
                    return;
                const newVol = Math.round(parseFloat(m[1]) * 100);
                const volChanged = newVol !== root._lastVol;
                const muteChanged = newMuted !== root._lastMuted;
                root._lastVol = newVol;
                root._lastMuted = newMuted;
                root.vol = newVol;
                root.muted = newMuted;
                if (volChanged || muteChanged) {
                    root.osdVisible = true;
                    hideTimer.restart();
                }
            }
        }
    }

    // ── Slide-up animation ─────────────────────────────────────────────────
    property real slideOffset: osdVisible ? 0 : 80
    Behavior on slideOffset {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutExpo
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  OSD card
    // ═══════════════════════════════════════════════════════════════════════
    Rectangle {
        id: osdCard
        width: 240
        height: 56
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22

        transform: Translate {
            y: root.slideOffset
        }
        opacity: root.osdVisible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 220
            }
        }

        radius: 18
        color: Qt.rgba(Colors.colBg.r, Colors.colBg.g, Colors.colBg.b, 0.93)

        Rectangle {
            anchors.fill: parent
            z: 1
            radius: parent.radius
            color: "transparent"
            border.color: Qt.alpha(Colors.colFg, 0.10)
            border.width: 1
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 16
                rightMargin: 16
            }
            spacing: 12

            Text {
                text: root.muted ? "\uf026" : root.vol > 60 ? "\uf028" : root.vol > 0 ? "\uf027" : "\uf026"
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                color: root.muted ? Colors.colRed : Colors.colBlue
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 5
                radius: 3
                color: Qt.alpha(Colors.colFg, 0.12)
                Rectangle {
                    width: parent.width * Math.min(root.vol / 100.0, 1.0)
                    height: parent.height
                    radius: parent.radius
                    color: root.muted ? Colors.colRed : Colors.colBlue
                    Behavior on width {
                        NumberAnimation {
                            duration: 80
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }

            Text {
                text: root.muted ? "Muted" : root.vol + "%"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Colors.colFg
                Layout.preferredWidth: 44
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
