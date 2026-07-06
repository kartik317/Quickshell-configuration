pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isSpeaking: false
    readonly property int barCount: 12 // keep in sync with "bars =" in cava-nova.conf
    property var barValues: Array(barCount).fill(0)

    function setSpeaking(speaking) {
        isSpeaking = speaking;

        if (speaking) {
            // Process needs an explicit false -> true toggle to (re)start
            cava.running = false;
            cava.running = true;
        } else {
            cava.running = false;
            barValues = Array(barCount).fill(0);
        }
    }

    Process {
        id: cava
        // adjust path to wherever you keep cava-nova.conf
        command: ["cava", "-p", "/home/kartik/.config/quickshell/voice_assistant/cava-nova.conf"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.split(";").filter(function (s) {
                    return s.length > 0;
                });

                if (parts.length === root.barCount) {
                    root.barValues = parts.map(function (v) {
                        return parseInt(v, 10);
                    });
                }
            }
        }
    }

    // speak.py calls: qs ipc call nova setSpeaking true/false
    IpcHandler {
        target: "nova"

        function setSpeaking(speaking: bool): void {
            root.setSpeaking(speaking);
        }
    }
}

