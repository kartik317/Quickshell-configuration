import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../state"
import "../theme"

Item {
    id: root
    implicitWidth: layout.implicitWidth + 24
    implicitHeight: 36

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 10

        // Album art
        Rectangle {
            width: 30; height: 26
            radius: 6
            color: Colors.colBlack
            clip: true
            visible: MediaState.hasPlayer

            Image {
                anchors.fill: parent
                source: MediaState.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        // Title / artist
        ColumnLayout {
            spacing: 0
            Layout.maximumWidth: 160

            Text {
                text: MediaState.title
                color: Colors.colFg
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.maximumWidth: 160
            }
            Text {
                text: MediaState.artist
                color: Colors.colBrightBlack
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.maximumWidth: 160
                visible: MediaState.artist.length > 0
            }
        }

        // Previous
        Text {
            text: "󰒮"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            color: MediaState.canGoPrevious ? Colors.colFg : Colors.colBrightBlack
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { MediaState.previous(); }
            }
        }

        // Play/Pause
        Text {
            text: MediaState.isPlaying ? "󰏤" : "󰐊"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            color: Colors.colFg
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { MediaState.togglePlaying(); }
            }
        }

        // Next
        Text {
            text: "󰒭"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            color: MediaState.canGoNext ? Colors.colFg : Colors.colBrightBlack
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { MediaState.next(); }
            }
        }

        // Shuffle
        Text {
            text: "󰒝"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 17
            color: MediaState.shuffleOn ? Colors.colFg : Colors.colBrightBlack
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { MediaState.toggleShuffle(); }
            }
        }

	// Repeat (None / Playlist / Track)
	Text {
	    id: repeatIcon
	    text: MediaState.loopStatus === MprisLoopState.Track ? "󰑘" : "󰑖"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 17

	    color: MediaState.loopStatus !== MprisLoopState.None
	    ? Colors.colFg : Colors.colBrightBlack 

	    MouseArea {
		anchors.fill: parent
		anchors.margins: -4
		cursorShape: Qt.PointingHandCursor
		onClicked: function(event) { MediaState.cycleLoop(); }
	    }
	}
    }
}
