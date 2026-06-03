pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root
    property bool visible: false
    property bool hoveringWidget: false
    function toggle() {
        visible = !visible;
    }
}
