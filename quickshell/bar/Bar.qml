import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../state"

PanelWindow {
    id: root

    Process {
        id: appLauncherProcess
        command: ["qs", "ipc", "call", "applauncher", "toggle"]
    }

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 45 
    color: "transparent"

    // Config options
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property real pillRadius: 12
    readonly property color pillBg: Qt.alpha(Colors.colBg, 0.85)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        // Left Section: Logo, Workspaces
        Rectangle {
            Layout.fillHeight: true
            color: root.pillBg
            radius: root.pillRadius
            implicitWidth: leftRow.implicitWidth + 16

            RowLayout {
                id: leftRow
                anchors.centerIn: parent
                spacing: 8

                // Logo
		Rectangle {
		    Layout.preferredWidth: 20
		    Layout.preferredHeight: 20
		    color: "transparent"

		    Text {
			anchors.centerIn: parent
			text: "\udb82\udcc7"
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 22
			color: Colors.colFg
		    }

		    MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
			    appLauncherProcess.running = true;
			}
		    }
		}

                Separator {}

                // Workspaces
                Workspaces {
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                } 
            }
	}

	// App Shortcuts Pill
        Rectangle {
            Layout.fillHeight: true
            color: root.pillBg
            radius: root.pillRadius
            implicitWidth: shortcutsRow.implicitWidth + 16

            RowLayout {
                id: shortcutsRow
                anchors.centerIn: parent
                AppShortcuts {}
            }
        }
	
        // Center Spacer (Pushes left and right sections apart)
        Item {
            Layout.fillWidth: true
        }

        // Center Section: Media Controls
        Rectangle {
            Layout.fillHeight: true
            color: root.pillBg
            radius: root.pillRadius
            implicitWidth: mediaRow.implicitWidth

            RowLayout {
                id: mediaRow
                anchors.centerIn: parent
                MediaControls {}
            }
        } 
	
	// System info
	Rectangle {
	    Layout.fillHeight: true
	    Layout.preferredWidth: 320
	    color: root.pillBg
	    radius: root.pillRadius
	    RowLayout {
		id: sysInfoRow
		anchors.centerIn: parent
		spacing: 8
		SysInfo {
		    fontFamily: root.fontFamily
		    fontSize: root.fontSize
		}
	    }
	} 

        // Network, Battery & Clock Pill
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: statusRow.implicitWidth + 24
            color: root.pillBg
            radius: root.pillRadius

            RowLayout {
                id: statusRow
                anchors.centerIn: parent
                spacing: 8

                Network {}

                Separator {}

		Battery {}

		Separator {}

		Volume {}

                Separator {}

                Clock {}
            }
        }
    }
}
