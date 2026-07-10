import QtQuick
import Quickshell
import "../theme"

Text {
    text: Qt.formatDateTime(clock.date, "HH:mm")
    color: Colors.colCyan 

    font {
	family: "SF Mono"
	letterSpacing: -1
	pixelSize: 15
	weight: 600
    }

    SystemClock {
	id: clock
	precision: SystemClock.Minutes
    }

}
