import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects // Built-in Qt 6 replacement for FastBlur

import "../state"

WlSessionLock {
    id: lock

    locked: LockScreenState.locked
    onLockedChanged: {
        if (LockScreenState.locked !== locked) {
            LockScreenState.locked = locked
        }
    }

    WlSessionLockSurface {
        id: surface

        Rectangle {
            id: mainContainer
            anchors.fill: parent
            color: "#000000"

            // Main surface fade-in / fade-out animation
            opacity: LockScreenState.locked ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }

            // Background Wallpaper
            Image {
                id: wallpaper
                anchors.fill: parent
                source: "file://" + Quickshell.env("HOME") + "/.cache/wallpaper_frame.png"
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: false
                cache: true

                sourceSize.width: surface.width
                sourceSize.height: surface.height

                visible: false // Hidden so MultiEffect can render the blurred version
            }

            // Modern Qt 6 Blur Effect
            MultiEffect {
                id: blurredWallpaper
                anchors.fill: wallpaper
                source: wallpaper
                blurEnabled: true
                blur: 0.8
                blurMax: 32

                visible: wallpaper.status === Image.Ready
            }

            // Dark overlay for contrast
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.45
            }

            // Lock Card UI
            Item {
                id: card
                width: 320
                height: contentColumn.height
                anchors.centerIn: parent

                property real baseX: (parent.width - width) / 2
                property real animOffsetX: 0

                transform: Translate { x: card.animOffsetX }

                // Smooth scale and subtle vertical float transition
                opacity: LockScreenState.locked ? 1 : 0
                scale: LockScreenState.locked ? 1.0 : 0.92
                y: LockScreenState.locked ? (parent.height - height) / 2 : (parent.height - height) / 2 + 15
                
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on scale { 
                    NumberAnimation { 
                        duration: 350
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    } 
                }
                Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                SequentialAnimation {
                    id: shakeAnim
                    loops: 1
                    NumberAnimation { target: card; property: "animOffsetX"; to: -12; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: 12; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: -8; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: 8; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: 0; duration: 50; easing.type: Easing.OutQuad }
                }

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: 20

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Text {
                            id: clockText
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatTime(currentTime, "hh:mm")
                            font.pixelSize: 80
                            font.weight: Font.Thin
                            color: "#FFFFFF"

                            property date currentTime: new Date()

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: clockText.currentTime = new Date()
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: Qt.rgba(1, 1, 1, 0.75)
                        }
                    }

                    Item { height: 12; width: 1 }

                    Rectangle {
                        id: fieldWrap
                        width: parent.width
                        height: 50
                        radius: 14
                        color: Qt.rgba(0, 0, 0, 0.5)
                        border.width: pwField.activeFocus ? 2 : (LockScreenState.authFailed ? 2 : 1)
                        border.color: LockScreenState.authFailed 
                            ? Colors.colRed 
                            : (pwField.activeFocus ? Colors.colFg : Qt.rgba(1, 1, 1, 0.15))

                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 10

                            TextField {
                                id: pwField
                                Layout.fillWidth: true
                                echoMode: TextInput.Password
                                enabled: !LockScreenState.authenticating
                                placeholderText: LockScreenState.authenticating ? "Verifying..." : "Enter Password"
                                placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                                color: "#FFFFFF"
                                background: null
                                font.pixelSize: 15
                                verticalAlignment: TextInput.AlignVCenter

                                onAccepted: {
                                    if (text.length > 0)
                                        LockScreenState.authenticate(text)
                                }
                            }

                            BusyIndicator {
                                visible: LockScreenState.authenticating
                                running: LockScreenState.authenticating
                                implicitWidth: 18
                                implicitHeight: 18
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Incorrect password"
                        color: Colors.colRed
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        opacity: LockScreenState.authFailed ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }

            Connections {
                target: LockScreenState
                function onAuthFailedChanged() {
                    if (LockScreenState.authFailed) {
                        shakeAnim.start()
                        pwField.text = ""
                        pwField.forceActiveFocus()
                    }
                }
                function onLockedChanged() {
                    if (!LockScreenState.locked) {
                        pwField.text = ""
                    } else {
                        pwField.forceActiveFocus()
                    }
                }
            }

            Component.onCompleted: pwField.forceActiveFocus()
        }
    }
}