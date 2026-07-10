pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root
    property bool visible: false
    function toggle() {
        visible = !visible;
    }
}
