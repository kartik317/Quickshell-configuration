pragma Singleton
import QtQuick
import Quickshell

QtObject {
    property bool launcherVisible: false
    // Most-recently-launched app IDs, newest first (persists within session)
    property var recentIds: []

    function toggle() {
        launcherVisible = !launcherVisible;
    }
    function show() {
        launcherVisible = true;
    }
    function hide() {
        launcherVisible = false;
    }

    function recordLaunch(id) {
        var list = recentIds.slice();
        var idx = list.indexOf(id);
        if (idx !== -1)
            list.splice(idx, 1);
        list.unshift(id);
        if (list.length > 12)
            list = list.slice(0, 12);
        recentIds = list;
    }
}
