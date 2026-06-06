import QtQuick
import "../theme"

Item {
    id: root

    width: 100
    height: 100

    property real value: 0  // 0–100
    property string label: ""
    property string unit: "%"
    property int strokeWidth: 7
    property color customArcColor: Qt.rgba(0, 0, 0, 0)
    property bool useCustomColor: false

    // Smooth animated fill
    property real animFill: 0
    Behavior on animFill {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }
    }
    onValueChanged: animFill = value
    Component.onCompleted: animFill = value

    readonly property color arcColor: useCustomColor ? customArcColor : (value < 50 ? Colors.colBlue : value < 80 ? Colors.colYellow : Colors.colRed)

    Canvas {
        id: cv
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var cx = width / 2;
            var cy = height / 2;
            var r = Math.min(cx, cy) - root.strokeWidth / 2 - 2;
            var s = -Math.PI / 2;
            var e = s + (root.animFill / 100) * 2 * Math.PI;

            // Background track
            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
            ctx.strokeStyle = Qt.rgba(Colors.colBrightBlack.r, Colors.colBrightBlack.g, Colors.colBrightBlack.b, 0.25);
            ctx.lineWidth = root.strokeWidth;
            ctx.stroke();

            // Value arc
            if (root.animFill > 0.5) {
                ctx.beginPath();
                ctx.arc(cx, cy, r, s, e);
                ctx.strokeStyle = root.arcColor.toString();
                ctx.lineWidth = root.strokeWidth;
                ctx.lineCap = "round";
                ctx.stroke();
            }
        }

        Connections {
            target: root
            function onAnimFillChanged() {
                if (cv.visible)
                    cv.requestPaint();
            }
            function onArcColorChanged() {
                if (cv.visible)
                    cv.requestPaint();
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.value) + root.unit
            font {
                pixelSize: 16
                bold: true
                family: "JetBrainsMono Nerd Font"
            }
            color: root.arcColor
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font {
                pixelSize: 9
                family: "JetBrainsMono Nerd Font"
            }
            color: Qt.alpha(Colors.colFg, 0.6)
        }
    }
}
