import QtQuick
import Quickshell
import "../theme"

Item {
    id: clockRoot
    implicitWidth: 510
    implicitHeight: 130
    property color textColor: Colors.colCyan
    Behavior on textColor { ColorAnimation { duration: 800; easing.type: Easing.OutCubic } }

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    property string dayOfWeek: Qt.formatDateTime(sysClock.date, "dddd").toUpperCase()
    property string fullDate: Qt.formatDateTime(sysClock.date, "dd MMMM, yyyy").toUpperCase()
    property string timeStr: Qt.formatDateTime(sysClock.date, "HH:mm")

    property real dayFontSize: {
        if (clockRoot.width <= 0 || dayOfWeek.length === 0) return 50
        var charWidthFactor = 0.7
        var letterSpacingFactor = 0.11
        var totalWidthFactor = (charWidthFactor + letterSpacingFactor) * dayOfWeek.length
        var targetWidth = clockRoot.width * 0.95
        var widthBasedSize = targetWidth / totalWidthFactor
        var maxHeightSize = clockRoot.height * 0.47
        return Math.min(widthBasedSize, maxHeightSize)
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 12
        width: clockRoot.width

        Item {
            width: parent.width
            height: clockRoot.dayFontSize * 1.2
            Text {
                text: clockRoot.dayOfWeek
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                font.family: "Anurati"
                font.pixelSize: clockRoot.dayFontSize
                color: clockRoot.textColor
                font.letterSpacing: clockRoot.dayFontSize * 0.11
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Item {
            width: parent.width
            height: 36
            Text {
                text: clockRoot.fullDate
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                font.family: "Orbitron"
                font.pixelSize: 22
                color: clockRoot.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Item {
            width: parent.width
            height: 40
            Text {
                text: clockRoot.timeStr
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                font.family: "Orbitron"
                font.pixelSize: 26
                color: clockRoot.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
