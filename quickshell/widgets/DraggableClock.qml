import QtQuick

Item {
    id: root

    required property var screen

    width: clockWidget.implicitWidth
    height: clockWidget.implicitHeight

    Component.onCompleted: {
        x = 0
        y = 50
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

    Clock {
        id: clockWidget
    }
}
