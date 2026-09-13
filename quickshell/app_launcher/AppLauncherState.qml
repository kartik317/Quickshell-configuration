pragma Singleton
import QtQuick
import QtCore
import Quickshell

QtObject {
    id: root

    property bool launcherVisible: false
    property var recentIds: []

    property var _settings: Settings {
        category: "AppLauncher"
        property string recentIdsSerialized: "[]"
    }

    Component.onCompleted: {
        recentIds = JSON.parse(_settings.recentIdsSerialized)
    }

    function toggle() { launcherVisible = !launcherVisible }
    function show()   { launcherVisible = true }
    function hide()   { launcherVisible = false }

    function recordLaunch(id) {
        var list = recentIds.slice()
        var idx  = list.indexOf(id)
        if (idx !== -1) list.splice(idx, 1)
        list.unshift(id)
        if (list.length > 12) list = list.slice(0, 12)
        recentIds = list
        _settings.recentIdsSerialized = JSON.stringify(list)
    }

    function clearRecents() {
        recentIds = []
        _settings.recentIdsSerialized = "[]"
    }
}
