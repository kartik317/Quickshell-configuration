import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

RowLayout {
    id: root
    spacing: 8

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property real cpuUsage: 0
    property real ramUsage: 0
    property int cpuTemp: 0

    Process {
        id: sysInfoProc
        command: ["bash", "-c",
            "read -r _ u1 n1 s1 i1 w1 ir1 soft1 st1 _ < /proc/stat; " +
            "sleep 0.5; " +
            "read -r _ u2 n2 s2 i2 w2 ir2 soft2 st2 _ < /proc/stat; " +
            "tot1=$((u1+n1+s1+i1+w1+ir1+soft1+st1)); tot2=$((u2+n2+s2+i2+w2+ir2+soft2+st2)); " +
            "idle1=$((i1+w1)); idle2=$((i2+w2)); " +
            "cpu=$(awk -v t1=$tot1 -v t2=$tot2 -v i1=$idle1 -v i2=$idle2 'BEGIN { dt=t2-t1; didle=i2-i1; print (dt>0) ? sprintf(\"%.0f\", 100*(dt-didle)/dt) : 0 }'); " +
            "mem=$(free | awk '/Mem:/{printf \"%d\", $3/$2*100}'); " +
            "temp=$(sensors 2>/dev/null | awk '/Package id 0:/ {print $4}' | tr -dc '0-9.' | awk '{print int($1)}'); " +
            "echo \"$cpu $mem ${temp:-0}\""
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/);
                if (parts.length === 3) {
                    root.cpuUsage = parseInt(parts[0]) || 0;
                    root.ramUsage = parseInt(parts[1]) || 0;
                    root.cpuTemp = parseInt(parts[2]) || 0;
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: sysInfoProc.running = true
    }

    RowLayout {
        Text {
            text: "CPU 󰘚"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: Colors.colFg
        }
        Text {
            text: root.cpuUsage + "%"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: Colors.colFg
        }
    }

    Separator {}

    RowLayout {
        Text {
            text: "Mem 󰍛"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: Colors.colFg
        }
        Text {
            text: root.ramUsage + "%"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: Colors.colFg
        }
    }

    Separator {}

    RowLayout {
        Text {
            text: "Temps \uf2c9"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: root.cpuTemp >= 80 ? "#e06c75" : Colors.colFg
        }
        Text {
            text: root.cpuTemp + "°"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: root.cpuTemp >= 80 ? "#e06c75" : Colors.colFg
        }
    }
}
