pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

QtObject {
    id: root
    property bool panelVisible: false
    property int volumeLevel: 0
    property bool volumeMuted: false
    property int _previousVolume: 50

    property Process volProc: Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                const m = data.match(/Volume:\s*([\d.]+)/);
                if (m)
                    root.volumeLevel = Math.round(parseFloat(m[1]) * 100);
            }
        }
        Component.onCompleted: running = true
    }

    function setVolume(level) {
        const clampedLevel = Math.max(0, Math.min(100, level));
        const volumeFraction = (clampedLevel / 100).toFixed(2);
        const cmd = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volumeFraction];
        const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        proc.command = cmd;
        proc.running = true;
        volumeLevel = clampedLevel;
        if (clampedLevel > 0)
            volumeMuted = false;
        _previousVolume = clampedLevel;
    }

    function toggleMute() {
        if (volumeMuted) {
            setVolume(_previousVolume);
        } else {
            _previousVolume = volumeLevel;
            setVolume(0);
        }
        volumeMuted = !volumeMuted;
    }

    function toggle() { panelVisible = !panelVisible }
    function show()   { panelVisible = true }
    function hide()   { panelVisible = false }
}
