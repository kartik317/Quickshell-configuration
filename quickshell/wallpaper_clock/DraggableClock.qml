import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    property int posX: 0
    property int posY: 50
    required property var screen

    IpcHandler {
        target: "clock-widget"
        function toggle() {
            ClockState.toggle()
        }
    }

    width: clockWidget.implicitWidth
    height: clockWidget.implicitHeight

    Component.onCompleted: {
        x = posX;
        y = posY;
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeAllCursor
        drag.target: root
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: root.screen.width - root.width
        drag.maximumY: root.screen.height - root.height
    }

    WallpaperClock {
        id: clockWidget
    }
}
