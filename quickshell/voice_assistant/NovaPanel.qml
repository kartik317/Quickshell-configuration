import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: novaPanel

    // Only anchor bottom -> wlr-layer-shell centers us horizontally
    anchors {
        bottom: true
    }

    // distance from the bottom edge when fully shown
    property real restingMargin: 24
    // how far below the screen it hides to
    property real hiddenOffset: maxBarHeight + restingMargin + 20

    property real maxBarHeight: 36

    // two-property pattern: reallyVisible drives the slide, visible
    // is delayed so the close animation gets to finish
    property bool reallyVisible: NovaState.isSpeaking
    visible: reallyVisible || hideTimer.running

    implicitWidth: wave.implicitWidth + 32
    implicitHeight: maxBarHeight + 24

    color: "transparent"

    WlrLayershell.namespace: "nova-wave"
    WlrLayershell.layer: WlrLayer.Overlay
    // exclusiveZone -1 so it floats over other surfaces/doesn't reserve space
    exclusiveZone: -1

    margins.bottom: reallyVisible ? restingMargin : -hiddenOffset

    Behavior on margins.bottom {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutSine
        }
    }

    Timer {
        id: hideTimer
        interval: 240 // slightly longer than the margin animation
        onTriggered: {}
    }

    onReallyVisibleChanged: {
        if (!reallyVisible) {
            hideTimer.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Colors.colBg
        opacity: 0.55
        border.color: Colors.colFg
        border.width: 1
        antialiasing: true
    }

    NovaWave {
        id: wave
        anchors.centerIn: parent
    }
}
