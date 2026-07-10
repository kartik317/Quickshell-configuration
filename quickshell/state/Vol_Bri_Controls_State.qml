pragma Singleton
import Quickshell
import QtQuick

QtObject {
    id: root

    property bool panelVisible: false

    function toggle() { panelVisible = !panelVisible }
    function show()   { panelVisible = true }
    function hide()   { panelVisible = false }
}

