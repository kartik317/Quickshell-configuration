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
        target: LiveWallpaperState
        function onVisibleChanged() {
            if (LiveWallpaperState.visible)
                panel.reallyVisible = true;
        }
    }

    WlrLayershell.namespace: "qs-liveWallpaperSwitcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: LiveWallpaperState.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
	top: true
        bottom: true
        left: true
        right: true
    }

    mask: Region {
        item: LiveWallpaperState.visible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    implicitHeight: 240
    color: "transparent"

    MouseArea {
	anchors.fill: parent
	enabled: LiveWallpaperState.visible
	onClicked: LiveWallpaperState.hide()
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
            y: LiveWallpaperState.visible ? 0 : container.height + 40

            Behavior on y {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                    onFinished: {
                        if (!LiveWallpaperState.visible)
                            panel.reallyVisible = false;
                    }
                }
            }
        }

        focus: true
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Right) {
                LiveWallpaperState.selectedIndex = Math.min(LiveWallpaperState.selectedIndex + 1, LiveWallpaperState.wallpapers.length - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                LiveWallpaperState.selectedIndex = Math.max(LiveWallpaperState.selectedIndex - 1, 0);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                LiveWallpaperState.selectAndApply();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                LiveWallpaperState.hide();
                event.accepted = true;
            }
        }

        Component.onCompleted: forceActiveFocus()
        onVisibleChanged: if (visible) forceActiveFocus()

        ListView {
            id: strip
            anchors.fill: parent
            anchors.margins: 16
            orientation: ListView.Horizontal
            spacing: 12
            model: LiveWallpaperState.wallpapers
            currentIndex: LiveWallpaperState.selectedIndex
            highlightMoveDuration: 200
            onCurrentIndexChanged: strip.positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Item {
                id: thumb
                width: 160
                height: strip.height
                property bool isSelected: index === LiveWallpaperState.selectedIndex
                property bool isVideo: {
                    var s = String(modelData).toLowerCase();
                    return s.endsWith('.mp4') || s.endsWith('.webm') || s.endsWith('.mkv') || s.endsWith('.mov')
                }
                scale: isSelected ? 1.0 : 0.9
                opacity: isSelected ? 1.0 : 0.6
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.InOutSine } }
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.InOutSine } }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "transparent"
                    border.width: thumb.isSelected ? 3 : 0
                    border.color: Colors.colBlue

                    Image {
                        id: previewImage
                        anchors.fill: parent
                        anchors.margins: 3
                        visible: true
                        source: "file://" + LiveWallpaperState.thumbFor(modelData)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        sourceSize.width: 320
                        sourceSize.height: 200
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        visible: thumb.isVideo
                        color: Qt.rgba(0,0,0,0.15)
                        radius: 10

                        Text { anchors.centerIn: parent; text: "▶"; color: Colors.colFg; font.pixelSize: 28; opacity: 0.95 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        LiveWallpaperState.selectedIndex = index;
                        LiveWallpaperState.selectAndApply();
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
                    LiveWallpaperState.selectedIndex = Math.min(LiveWallpaperState.selectedIndex + 1, LiveWallpaperState.wallpapers.length - 1);
                } else if (wheel.angleDelta.y > 0) {
                    LiveWallpaperState.selectedIndex = Math.max(LiveWallpaperState.selectedIndex - 1, 0);
                }
                wheel.accepted = true;
            }
        }
    }
}
