import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

RowLayout {
    id: root
    spacing: 10

    Process {
	id: youtubeProcess
	command: ["brave", "--app-id=agimnkijcaahngcdmfeangaknmldooml"]
    }
    Process {
	id: discordProcess
	command: ["discord"]
    }
    Process {
	id: githubProcess
	command: ["brave", "--app-id=mjoklplbddabcmpepnokjaffbmgbkkgg"]
    }
    Process {
	id: braveProcess
	command: ["brave"]
    }
    Process {
	id: telegramProcess
	command: ["org.telegram.desktop"]
    }
    Process {
	id: minecraftProcess
	command: ["mcpelauncher-ui-qt"]
    }
    Process {
	id: steamProcess
	command: ["steam"]
    }

    // YouTube
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"

	Text {
	    anchors.centerIn: parent
	    text: "\uf16a"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: youtubeProcess.running = true
	}
    }
    
    // Discord
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"
	Text {
	    anchors.centerIn: parent
	    text: "\uf1ff"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: discordProcess.running = true
	}
    }

    // Telegram
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"
	Text {
	    anchors.centerIn: parent
	    text: "\ue217"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: telegramProcess.running = true
	}
    }

    // Minecraft
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"
	Text {
	    anchors.centerIn: parent
	    text: "\udb80\udf73"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: minecraftProcess.running = true
	}
    }

    // Steam
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"
	Text {
	    anchors.centerIn: parent
	    text: "\uf1b7"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: steamProcess.running = true
	}
    } 
    
    // Brave(but with firefox icon) 
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"
	Text {
	    anchors.centerIn: parent
	    text: "\udb80\ude39"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 20
	    color: Colors.colFg
	}
	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: braveProcess.running = true
	}
    }

    // Github
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	color: "transparent"
	Text {
	    anchors.centerIn: parent
	    text: "\udb80\udea4"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 20
	    color: Colors.colFg
	}
	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: githubProcess.running = true
	}
    }
}
