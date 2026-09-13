import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"
import "../state"

PanelWindow {
    id: panel

    property bool reallyVisible: false
    visible: reallyVisible

    exclusiveZone: 0

    Connections {
        target: WallpaperState
        function onVisibleChanged() {
            if (WallpaperState.visible)
                panel.reallyVisible = true;
        }
    }

    WlrLayershell.namespace: "qs-wallpaperSwitcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WallpaperState.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
	top: true
	bottom: true
	left: true
	right: true
    }

    mask: Region {
        item: WallpaperState.visible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    implicitHeight: 240
    color: "transparent"

    MouseArea {
	anchors.fill: parent
	enabled: WallpaperState.visible
	onClicked: WallpaperState.hide()
    }

    Rectangle {
        id: container
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1220
        height: 220
        topLeftRadius: 18
        topRightRadius: 18
        bottomLeftRadius: 0
        bottomRightRadius: 0
        color: Qt.rgba(Colors.colBg.r, Colors.colBg.g, Colors.colBg.b, 0.85)
        border.color: Qt.alpha(Colors.colFg, 0.10)
        border.width: 1

        transform: Translate {
            id: slideTransform
            y: WallpaperState.visible ? 0 : container.height + 40

            Behavior on y {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                    onFinished: {
                        if (!WallpaperState.visible)
                            panel.reallyVisible = false;
                    }
                }
            }
        }

        focus: true
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Right) {
                WallpaperState.selectedIndex = Math.min(WallpaperState.selectedIndex + 1, WallpaperState.wallpapers.length - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                WallpaperState.selectedIndex = Math.max(WallpaperState.selectedIndex - 1, 0);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                WallpaperState.selectAndApply();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                WallpaperState.hide();
                event.accepted = true;
            }
        }

        Component.onCompleted: forceActiveFocus()
        onVisibleChanged: if (visible)
            forceActiveFocus()

        ListView {
            id: strip
            anchors.fill: parent
            anchors.margins: 16
            orientation: ListView.Horizontal
            spacing: 12
            model: WallpaperState.wallpapers
            currentIndex: WallpaperState.selectedIndex
            highlightMoveDuration: 200
            onCurrentIndexChanged: strip.positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Item {
                id: thumb
                width: 160
                height: strip.height
                property bool isSelected: index === WallpaperState.selectedIndex
                scale: isSelected ? 1.0 : 0.9
                opacity: isSelected ? 1.0 : 0.6
                Behavior on scale {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.InOutSine
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.InOutSine
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "transparent"
                    border.width: thumb.isSelected ? 3 : 0
                    border.color: Colors.colBlue

                    Image {
                        anchors.fill: parent
                        anchors.margins: 3
                        source: "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        sourceSize.width: 320
                        sourceSize.height: 200
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        WallpaperState.selectedIndex = index;
                        WallpaperState.selectAndApply();
                    }
                }
            }
        }

        MouseArea {
            id: wheelOverlay
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function (wheel) {
                if (wheel.angleDelta.y < 0) {
                    WallpaperState.selectedIndex = Math.min(WallpaperState.selectedIndex + 1, WallpaperState.wallpapers.length - 1);
                } else if (wheel.angleDelta.y > 0) {
                    WallpaperState.selectedIndex = Math.max(WallpaperState.selectedIndex - 1, 0);
                }
                wheel.accepted = true;
            }
        }
    }
}

