import QtQuick
import "../theme"

Item {
    id: clockRoot 
    implicitWidth: 510
    implicitHeight: 130

    property color textColor: Colors.colCyan

    Behavior on textColor { ColorAnimation { duration: 800; easing.type: Easing.OutCubic } }

    property string dayOfWeek: Qt.formatDateTime(new Date(), "dddd").toUpperCase()
    property string fullDate: Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
    property string timeStr: Qt.formatDateTime(new Date(), "HH:mm")

    // Calculate adaptive font size to exactly match widget width
    property real dayFontSize: {
        if (clockRoot.width <= 0 || dayOfWeek.length === 0) return 50
        
        // Letter spacing is 0.11 of font size per character
        // Total width = base text width + (letter spacing * number of gaps)
        // At font size F: total width = F * char_width_factor * length + F * 0.11 * (length - 1)
        // Simplified: total width ≈ F * length * (char_width_factor + 0.11)
        
        // For Anurati font, approximate character width is 0.7 of font size
        var charWidthFactor = 0.7
        var letterSpacingFactor = 0.11
        var totalWidthFactor = (charWidthFactor + letterSpacingFactor) * dayOfWeek.length
        
        // Target 95% of widget width
        var targetWidth = clockRoot.width * 0.95
        var widthBasedSize = targetWidth / totalWidthFactor
        
        // Also respect height constraint
        var maxHeightSize = clockRoot.height * 0.47
        
        return Math.min(widthBasedSize, maxHeightSize)
    }

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            dayOfWeek = Qt.formatDateTime(new Date(), "dddd").toUpperCase()
            fullDate  = Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
            timeStr   = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 12
        width: clockRoot.width

        // Day of week
        Item {
            width: parent.width
            height: clockRoot.dayFontSize * 1.2  // Height based on actual font size
            
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

        // Date
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

        // Time
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
