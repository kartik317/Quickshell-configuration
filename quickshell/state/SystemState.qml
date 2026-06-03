pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QtObject {
    id: root

    property string kernelVersion: "Linux"
    property int    cpuUsage:      0
    property int    memUsage:      0
    property int    diskUsage:     0
    property int    volumeLevel:   0
    property int    batteryLevel:  0
    property bool   batteryCharging: false
    property string activeWindow:  "Window"
    property string currentLayout: "Tile"
    property bool   volumeMuted:   false
    property int    _previousVolume: 50

    // CPU tracking (internal)
    property var _lastCpuIdle:  0
    property var _lastCpuTotal: 0

    property list<QtObject> _processes: [
        Process {
            command: ["uname", "-r"]
            stdout: SplitParser { onRead: data => { if (data) root.kernelVersion = data.trim() } }
            Component.onCompleted: running = true
        },
        Process {
            id: cpuProc
            command: ["sh", "-c", "head -1 /proc/stat"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    const p = data.trim().split(/\s+/)
                    const user    = parseInt(p[1]) || 0
                    const nice    = parseInt(p[2]) || 0
                    const system  = parseInt(p[3]) || 0
                    const idle    = parseInt(p[4]) || 0
                    const iowait  = parseInt(p[5]) || 0
                    const irq     = parseInt(p[6]) || 0
                    const softirq = parseInt(p[7]) || 0

                    const total    = user + nice + system + idle + iowait + irq + softirq
                    const idleTime = idle + iowait

                    if (root._lastCpuTotal > 0) {
                        const dt = total - root._lastCpuTotal
                        const di = idleTime - root._lastCpuIdle
                        if (dt > 0) root.cpuUsage = Math.round(100 * (dt - di) / dt)
                    }
                    root._lastCpuTotal = total
                    root._lastCpuIdle  = idleTime
                }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: memProc
            command: ["sh", "-c", "free | grep Mem"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    const p = data.trim().split(/\s+/)
                    root.memUsage = Math.round(100 * (parseInt(p[2]) || 0) / (parseInt(p[1]) || 1))
                }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: diskProc
            command: ["sh", "-c", "df / | tail -1"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    const p = data.trim().split(/\s+/)
                    root.diskUsage = parseInt((p[4] || "0%").replace('%', '')) || 0
                }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: volProc
            command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    const m = data.match(/Volume:\s*([\d.]+)/)
                    if (m) root.volumeLevel = Math.round(parseFloat(m[1]) * 100)
                }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: batLevelProc
            command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1"]
            stdout: SplitParser {
                onRead: data => { if (data) root.batteryLevel = parseInt(data.trim()) || 0 }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: batStatusProc
            command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1"]
            stdout: SplitParser {
                onRead: data => { if (data) root.batteryCharging = data.trim() === "Charging" }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: windowProc
            command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
            stdout: SplitParser {
                onRead: data => { if (data && data.trim()) root.activeWindow = data.trim() }
            }
            Component.onCompleted: running = true
        },
        Process {
            id: layoutProc
            command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
            stdout: SplitParser {
                onRead: data => { if (data && data.trim()) root.currentLayout = data.trim() }
            }
            Component.onCompleted: running = true
        }
    ]

    // Slow poll: system stats
    property Timer _slowTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running     = true
            memProc.running     = true
            diskProc.running    = true
            volProc.running     = true
            batLevelProc.running  = true
            batStatusProc.running = true
        }
    }

    // Fast poll: window / layout
    property Timer _fastTimer: Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true
            layoutProc.running = true
        }
    }

    // Event-driven updates
    property Connections _hyprConn: Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
            layoutProc.running = true
        }
    }

    function setVolume(level) {
        const clampedLevel = Math.max(0, Math.min(100, level))
        const volumeFraction = (clampedLevel / 100).toFixed(2)
        const cmd = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volumeFraction]
        const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        proc.command = cmd
        proc.running = true
        volumeLevel = clampedLevel
        if (clampedLevel > 0) volumeMuted = false
        _previousVolume = clampedLevel
    }

    function toggleMute() {
        if (volumeMuted) {
            setVolume(_previousVolume)
        } else {
            _previousVolume = volumeLevel
            setVolume(0)
        }
        volumeMuted = !volumeMuted
    }
}
