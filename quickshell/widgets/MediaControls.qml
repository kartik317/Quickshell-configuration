import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../state" as State
import "../theme" as Theme

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
            width: 26; height: 26
            radius: 6
            color: Theme.Colors.colBlack
            clip: true
            visible: State.MediaState.hasPlayer

            Image {
                anchors.fill: parent
                source: State.MediaState.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        // Title / artist
        ColumnLayout {
            spacing: 0
            Layout.maximumWidth: 160

            Text {
                text: State.MediaState.title
                color: Theme.Colors.colFg
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.maximumWidth: 160
            }
            Text {
                text: State.MediaState.artist
                color: Theme.Colors.colBrightBlack
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.maximumWidth: 160
                visible: State.MediaState.artist.length > 0
            }
        }

        // Previous
        Text {
            text: "󰒮"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            color: State.MediaState.canGoPrevious ? Theme.Colors.colFg : Theme.Colors.colBrightBlack
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { State.MediaState.previous(); }
            }
        }

        // Play/Pause
        Text {
            text: State.MediaState.isPlaying ? "󰏤" : "󰐊"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 17
            color: Theme.Colors.colCyan
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { State.MediaState.togglePlaying(); }
            }
        }

        // Next
        Text {
            text: "󰒭"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            color: State.MediaState.canGoNext ? Theme.Colors.colFg : Theme.Colors.colBrightBlack
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { State.MediaState.next(); }
            }
        }

        // Shuffle
        Text {
            text: "󰒝"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            color: State.MediaState.shuffleOn ? Theme.Colors.colCyan : Theme.Colors.colBrightBlack
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { State.MediaState.toggleShuffle(); }
            }
        }

        // Repeat (none / track / playlist)
        Text {
            id: repeatIcon
            text: "󰑖"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            color: State.MediaState.loopStatus !== MprisLoopState.None
                   ? Theme.Colors.colCyan : Theme.Colors.colBrightBlack

            // small "1" badge overlay when looping a single track
            Text {
                visible: State.MediaState.loopStatus === MprisLoopState.Track
                text: "1"
                font.pixelSize: 7
                color: Theme.Colors.colBg
                anchors.bottom: parent.bottom
                anchors.right: parent.right
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function(event) { State.MediaState.cycleLoop(); }
            }
        }
    }
}
