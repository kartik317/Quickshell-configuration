pragma Singleton
import Quickshell
import QtQuick

QtObject {
    id: root

    property bool powerVisible: false

    function toggle() { powerVisible = !powerVisible }
    function show()   { powerVisible = true }
    function hide()   { powerVisible = false }
}
