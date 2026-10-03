import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../theme"

// Root is a Scope (instead of WlSessionLock) because WlSessionLock only accepts
// a single child (its surface), and we need a Timer + Connections next to it.
Scope {
    id: root

    // ---- Exit animation tuning -------------------------------------------
    property int outDuration: 450   // how long each element takes to leave (ms)
    property int outStagger: 120    // delay between elements leaving (ms)
    readonly property int outroTotal: outStagger * 2 + outDuration

    // True while the exit animation plays (compositor lock is still held)
    property bool closing: false

    // We control lock.locked by hand so the compositor lock is only released
    // AFTER the exit animation has played.
    Connections {
        target: LockScreenState
        function onLockedChanged() {
            if (LockScreenState.locked) {
                // (Re)lock: cancel any pending release and make sure we're locked
                releaseTimer.stop()
                root.closing = false
                lock.locked = true
            } else if (lock.locked) {
                // Unlock requested: play the exit animation first, then release
                root.closing = true
                releaseTimer.restart()
            }
        }
    }

    // Releases the real lock once the exit animation is done.
    // This also acts as a safety net: the lock is ALWAYS released.
    Timer {
        id: releaseTimer
        interval: root.outroTotal + 80
        onTriggered: {
            lock.locked = false
            root.closing = false
        }
    }

    Component.onCompleted: lock.locked = LockScreenState.locked

    WlSessionLock {
        id: lock

        locked: false   // managed manually, see Connections/Timer above
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

                    // How far (px) the clock/avatar travel above their final spot,
                    // and how far the password field travels below its final spot.
                    property real dropDistance: 140
                    property real riseDistance: 140

                    // Shake offset. Entrance/exit transforms live on the child
                    // groups below, so they don't collide with this one.
                    transform: Translate { x: card.animOffsetX }

                    SequentialAnimation {
                        id: shakeAnim
                        loops: 1
                        NumberAnimation { target: card; property: "animOffsetX"; to: -12; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: 12; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: -8; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: 8; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: 0; duration: 50; easing.type: Easing.OutQuad }
                    }

                    // ---- Entrance: clock -> avatar -> field ----------------
                    ParallelAnimation {
                        id: introAnim

                        // 1) Clock + date DROP from the top
                        ParallelAnimation {
                            NumberAnimation {
                                target: clockShift; property: "y"; to: 0
                                duration: 700
                                easing.type: Easing.OutBack; easing.overshoot: 0.9
                            }
                            NumberAnimation {
                                target: clockGroup; property: "opacity"; to: 1
                                duration: 450; easing.type: Easing.OutCubic
                            }
                        }

                        // 2) Avatar DROPS from the top, slightly after the clock
                        SequentialAnimation {
                            PauseAnimation { duration: 120 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: avatarShift; property: "y"; to: 0
                                    duration: 700
                                    easing.type: Easing.OutBack; easing.overshoot: 0.9
                                }
                                NumberAnimation {
                                    target: avatar; property: "opacity"; to: 1
                                    duration: 450; easing.type: Easing.OutCubic
                                }
                            }
                        }

                        // 3) Password field SLIDES UP from the bottom, last
                        SequentialAnimation {
                            PauseAnimation { duration: 250 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: fieldShift; property: "y"; to: 0
                                    duration: 650; easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: fieldWrap; property: "opacity"; to: 1
                                    duration: 450; easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    // ---- Exit: the entrance in reverse ---------------------
                    // Reversed order (field -> avatar -> clock), reversed
                    // direction, and In* easings (the mirror of the Out* ones).
                    ParallelAnimation {
                        id: outroAnim

                        // 1) Password field slides DOWN first
                        ParallelAnimation {
                            NumberAnimation {
                                target: fieldShift; property: "y"; to: card.riseDistance
                                duration: root.outDuration; easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: fieldWrap; property: "opacity"; to: 0
                                duration: root.outDuration; easing.type: Easing.InCubic
                            }
                        }

                        // 2) Avatar goes UP
                        SequentialAnimation {
                            PauseAnimation { duration: root.outStagger }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: avatarShift; property: "y"; to: -card.dropDistance
                                    duration: root.outDuration
                                    easing.type: Easing.InBack; easing.overshoot: 0.9
                                }
                                NumberAnimation {
                                    target: avatar; property: "opacity"; to: 0
                                    duration: root.outDuration; easing.type: Easing.InCubic
                                }
                            }
                        }

                        // 3) Clock + date go UP last
                        SequentialAnimation {
                            PauseAnimation { duration: root.outStagger * 2 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: clockShift; property: "y"; to: -card.dropDistance
                                    duration: root.outDuration
                                    easing.type: Easing.InBack; easing.overshoot: 0.9
                                }
                                NumberAnimation {
                                    target: clockGroup; property: "opacity"; to: 0
                                    duration: root.outDuration; easing.type: Easing.InCubic
                                }
                            }
                        }
                    }

                    // Reset everything to its hidden start position, then play.
                    function playIntro() {
                        outroAnim.stop()
                        introAnim.stop()
                        clockShift.y = -dropDistance
                        avatarShift.y = -dropDistance
                        fieldShift.y = riseDistance
                        clockGroup.opacity = 0
                        avatar.opacity = 0
                        fieldWrap.opacity = 0
                        introAnim.start()
                    }

                    // Starts from wherever things currently are (no `from`), so it
                    // also behaves if unlock happens mid-entrance.
                    function playOutro() {
                        introAnim.stop()
                        outroAnim.restart()
                    }

                    Column {
                        id: contentColumn
                        width: parent.width
                        spacing: 4

                        // Clock + date
                        Column {
                            id: clockGroup
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4
                            opacity: 0
                            transform: Translate { id: clockShift; y: -card.dropDistance }

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
                                text: Qt.formatDate(clockText.currentTime, "dddd, MMMM d")
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Qt.rgba(1, 1, 1, 0.75)
                            }
                        }

                        Item { height: 16; width: 1 }

                        // Profile picture
                        Item {
                            id: avatar
                            width: 96
                            height: 96
                            anchors.horizontalCenter: parent.horizontalCenter
                            opacity: 0
                            transform: Translate { id: avatarShift; y: -card.dropDistance }

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                source: "file://" + Quickshell.env("HOME") + "/.face"
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 192
                                sourceSize.height: 192
                                smooth: true
                                asynchronous: true
                                visible: false // rendered through MultiEffect below
                            }

                            // Circular mask shape
                            Rectangle {
                                id: avatarMask
                                anchors.fill: parent
                                radius: width / 2
                                color: "black"
                                layer.enabled: true
                                visible: false
                            }

                            MultiEffect {
                                anchors.fill: parent
                                source: avatarImg
                                maskEnabled: true
                                maskSource: avatarMask
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                                visible: avatarImg.status === Image.Ready
                            }

                            // Fallback if no image is found
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Qt.rgba(0, 0, 0, 0.5)
                                visible: avatarImg.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: (Quickshell.env("USER") || "?").charAt(0).toUpperCase()
                                    font.pixelSize: 40
                                    font.weight: Font.Medium
                                    color: "#FFFFFF"
                                }
                            }

                            // Subtle ring
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.width: 2
                                border.color: Qt.rgba(1, 1, 1, 0.25)
                            }
                        }

                        Item { height: 12; width: 1 }

                        // Password field
                        Rectangle {
                            id: fieldWrap
                            width: parent.width
                            height: 50
                            radius: 14
                            color: Qt.rgba(0, 0, 0, 0.5)
                            opacity: 0
                            transform: Translate { id: fieldShift; y: card.riseDistance }

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
                                    enabled: !LockScreenState.authenticating && !root.closing
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
                        // Only the "locked again" direction matters here; the
                        // unlock direction is handled by root.closing below.
                        if (LockScreenState.locked) {
                            pwField.forceActiveFocus()
                            card.playIntro()
                        }
                    }
                }

                // Unlock requested -> play the exit animation
                Connections {
                    target: root
                    function onClosingChanged() {
                        if (root.closing) {
                            pwField.text = ""
                            card.playOutro()
                        }
                    }
                }

                Component.onCompleted: {
                    pwField.forceActiveFocus()
                    card.playIntro()
                }
            }
        }
    }
}

