import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: waveRoot

    property real barWidth: 4
    property real barSpacing: 4
    property real maxBarHeight: 36

    implicitWidth: barRow.implicitWidth
    implicitHeight: maxBarHeight

    opacity: NovaState.isSpeaking ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutSine
        }
    }

    RowLayout {
        id: barRow
        anchors.centerIn: parent
        spacing: waveRoot.barSpacing

        Repeater {
            model: NovaState.barCount

            Rectangle {
                width: waveRoot.barWidth
                radius: width / 2
                color: Colors.colCyan

                height: Math.max(6, (NovaState.barValues[index] || 0) / 100 * waveRoot.maxBarHeight)
                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                    NumberAnimation {
                        duration: 90
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}

