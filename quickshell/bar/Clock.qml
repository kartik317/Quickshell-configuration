import QtQuick
import "../theme"

Text {
    property string fontFamily
    property int fontSize

    text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    color: Colors.colCyan
    font.pixelSize: fontSize
    font.family: fontFamily
    font.bold: true

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    }
}
