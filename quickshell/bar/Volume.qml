import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: root
    spacing: 7

    property var sink: Pipewire.defaultAudioSink

    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

    readonly property string icon: {
        if (!ready) return String.fromCodePoint(0xF0581)
        if (muted) return "\udb81\udd81"

        if (vol === 0) return String.fromCodePoint(0xF0581)
        if (vol < 34) return String.fromCodePoint(0xF057F)
        if (vol < 67) return String.fromCodePoint(0xF0580)

        return String.fromCodePoint(0xF057E)
    }

    Text {
        text: root.icon
        color: Colors.colFg
        font {
            family: "JetBrainsMono Nerd Font Propo"
            pixelSize: 18
        }
    }

    Text {
        text: {
            if (!root.ready) return "_"
            if (root.muted) return "Muted"

            return root.vol + "%"
        }

        color: root.muted ? Colors.colCyan : Colors.colFg

        font {
            family: "SF Pro Display"
            weight: 500
        }
    }

    MouseArea {
        anchors.fill: parent
        
        onWheel: (wheel) => {
            if (!root.ready) return;

            // Volume adjustment step (0.05 = 5%)
            let step = 0.01;
            let currentVol = root.sink.audio.volume;

            if (wheel.angleDelta.y > 0) {
                // Scroll up: Increase volume, cap at 1.0 (100%)
                root.sink.audio.volume = Math.min(1.0, currentVol + step);
            } else if (wheel.angleDelta.y < 0) {
                // Scroll down: Decrease volume, limit at 0.0 (0%)
                root.sink.audio.volume = Math.max(0.0, currentVol - step);
            }
        }

        // Left click to mute/unmute
        onClicked: {
            if (root.ready) {
                root.sink.audio.muted = !root.sink.audio.muted;
            }
        }
    }

    PwObjectTracker {
        objects: [root.sink]
    }
}
