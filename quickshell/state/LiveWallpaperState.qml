pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool visible: false
    property string wallpaperDir: "/home/kartik/Videos/LiveWallpapers"
    property var wallpapers: []
    property int selectedIndex: 0
    property string currentWallpaper: ""
    property string thumbDir: "/home/kartik/.cache/live_wallpaper_thumbs"

    function thumbFor(path) {
        if (!path) return ""
        var parts = String(path).split('/')
        var base = parts[parts.length-1]
        var name = base.replace(/\.[^/.]+$/, '')
        return thumbDir + '/' + name + '.png'
    }

    function show() { scanProcess.running = false; scanProcess.running = true; root.visible = true }
    function hide() { root.visible = false }
    function toggle() { if (root.visible) hide(); else show() }

    Process {
        id: scanProcess
        command: ["bash", "-c", "/home/kartik/.config/quickshell/scripts/generate_live_thumbs.sh '" + root.wallpaperDir + "'"]
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
        // shell-escape single quotes in path
        var safe = String(path).replace(/'/g, "'\"'\"'")
        var script = "wp='" + safe + "'\n"
        script += "pkill -x mpvpaper 2>/dev/null\n"
        script += "pkill -x hyprpaper 2>/dev/null\n"
        script += "ext=\${wp##*.}\n"
        script += "ext=$(echo \"$ext\" | tr '[:upper:]' '[:lower:]')\n"
        script += "wallpaper_frame=\"$HOME/.cache/wallpaper_frame.png\"\n"
        script += "if [[ \"$ext\" == \"mp4\" || \"$ext\" == \"webm\" || \"$ext\" == \"mkv\" || \"$ext\" == \"mov\" ]]; then\n"
        script += "  ffmpeg -y -i \"$wp\" -frames:v 1 \"$wallpaper_frame\" >/dev/null 2>&1 || true\n"
        script += "  awww img \"$wallpaper_frame\" --transition-type wipe --transition-angle 45 --transition-duration 2.5 --transition-fps 60 --transition-bezier 0.65,0.05,0.36,1\n"
        script += "  sleep 2.8\n"
        script += "  nohup mpvpaper -o \"no-audio loop hwdec=auto vo=gpu --profile=fast\" \"*\" \"$wp\" >/dev/null 2>&1 &\n"
        script += "  disown\n"
        script += "  wallust run \"$wallpaper_frame\"\n"
        script += "  echo \"$wp\" > ~/.cache/current_wallpaper\n"
        script += "  echo \"video\" > ~/.cache/current_wallpaper_type\n"
        script += "  pkill swaync || true\n"
        script += "else\n"
        script += "  cp \"$wp\" \"$wallpaper_frame\" 2>/dev/null || true\n"
        script += "  awww img \"$wp\" --transition-type wipe --transition-angle 45 --transition-duration 2.5 --transition-fps 60 --transition-bezier 0.65,0.05,0.36,1\n"
        script += "  sleep 2.8\n"
        script += "  nohup mpvpaper -o \"no-audio loop hwdec=auto vo=gpu --profile=fast\" \"*\" \"$wp\" >/dev/null 2>&1 &\n"
        script += "  disown\n"
        script += "  wallust run \"$wallpaper_frame\"\n"
        script += "  echo \"$wp\" > ~/.cache/current_wallpaper\n"
        script += "  echo \"image\" > ~/.cache/current_wallpaper_type\n"
        script += "  pkill swaync || true\n"
        script += "fi\n"
        

        applyProcess.command = ["bash", "-c", script]
        applyProcess.running = false
        applyProcess.running = true
    }

    function selectAndApply() {
        if (wallpapers.length === 0) return
        applyWallpaper(wallpapers[selectedIndex])
        hide()
    }

    IpcHandler {
        target: "live-wallpaper-switcher"
        function toggle() { root.toggle() }
        function show() { root.show() }
        function hide() { root.hide() }
    }
}
