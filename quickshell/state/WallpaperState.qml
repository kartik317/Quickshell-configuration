pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool visible: false
    property string wallpaperDir: "/home/kartik/Pictures/Wallpapers" 
    property var wallpapers: []
    property int selectedIndex: 0
    property string currentWallpaper: ""

    function show() {
        scanProcess.running = false
        scanProcess.running = true
        root.visible = true
    }

    function hide() {
        root.visible = false
    }

    function toggle() {
        if (root.visible) hide()
        else show()
    }

    Process {
        id: scanProcess
        command: ["bash", "-c",
            "find '" + root.wallpaperDir + "' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \\) | sort"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = text.trim().length > 0 ? text.trim().split("\n") : []
                root.wallpapers = list
                const idx = list.indexOf(root.currentWallpaper)
                root.selectedIndex = idx >= 0 ? idx : 0
            }
        }
    }

    Process {
        id: applyProcess
        command: ["bash", "-c", ""]
    }

    function applyWallpaper(path) {
        if (!path) return
        root.currentWallpaper = path

        const script = `
pkill -x mpvpaper 2>/dev/null
awww img "${path}" \\
    --transition-type wipe \\
    --transition-angle 45 \\
    --transition-duration 2.5 \\
    --transition-fps 60 \\
    --transition-bezier 0.65,0.05,0.36,1
wallust run "${path}"
pkill swaync
echo "${path}" > ~/.cache/current_wallpaper
echo "image" > ~/.cache/current_wallpaper_type
cp "${path}" ~/.cache/wallpaper_frame.png
`
        applyProcess.command = ["bash", "-c", script]
        applyProcess.running = false
        applyProcess.running = true
    }

    function selectAndApply() {
        if (wallpapers.length === 0) return
        applyWallpaper(wallpapers[selectedIndex])
        hide()
    }

    // optional: lets a Hyprland keybind toggle this instead of launching yazi
    IpcHandler {
        target: "wallpaper-switcher"
        function toggle() { root.toggle() }
        function show() { root.show() }
        function hide() { root.hide() }
    }
}