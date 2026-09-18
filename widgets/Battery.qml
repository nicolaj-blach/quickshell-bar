import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: battery

    required property var colors

    width: batteryRow.width + 8
    height: 24
    color: "transparent"
    visible: isPresent

    property bool isPresent: false
    property int percentage: 0
    property bool charging: false
    property bool isLow: percentage <= 20 && !charging

    function batteryIcon() {
        var p = percentage
        if (charging) {
            if (p >= 90) return Icons.batteryCharging100
            if (p >= 80) return Icons.batteryCharging90
            if (p >= 60) return Icons.batteryCharging70
            if (p >= 40) return Icons.batteryCharging50
            if (p >= 20) return Icons.batteryCharging30
            if (p >= 10) return Icons.batteryCharging20
            return Icons.batteryCharging
        }
        if (p >= 90) return Icons.batteryFull
        if (p >= 80) return Icons.battery90
        if (p >= 60) return Icons.battery70
        if (p >= 40) return Icons.battery50
        if (p >= 20) return Icons.battery30
        if (p >= 10) return Icons.battery20
        return Icons.batteryAlert
    }

    Component.onCompleted: {
        checkProc.running = true
    }

    // Poll battery status
    Timer {
        id: pollTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkProc.running = true
    }

    // Find battery, read values, and check AC status
    Process {
        id: checkProc
        command: ["sh", "-c", 
            "for bat in /sys/class/power_supply/BAT*; do " +
            "  if [ -f \"$bat/capacity\" ]; then " +
            "    cap=$(cat \"$bat/capacity\"); " +
            "    stat=$(cat \"$bat/status\"); " +
            "    ac=0; " +
            "    for ac_path in /sys/class/power_supply/AC* /sys/class/power_supply/ACAD*; do " +
            "      [ -f \"$ac_path/online\" ] && ac=$(cat \"$ac_path/online\") && break; " +
            "    done; " +
            "    echo \"$cap\"; echo \"$stat\"; echo \"$ac\"; " +
            "    exit 0; " +
            "  fi; " +
            "done; exit 1"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                var lines = data.trim().split("\n")
                if (lines.length >= 2) {
                    battery.isPresent = true
                    battery.percentage = parseInt(lines[0]) || 0
                    var status = lines[1].toLowerCase()
                    var acOnline = lines.length >= 3 && lines[2] === "1"
                    // Show as charging if actively charging OR if plugged in (AC online)
                    battery.charging = (status === "charging") || acOnline
                }
            }
        }
    }

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: batteryIcon()
            color: isLow ? colors.barRed : colors.barGreen
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            text: percentage + "%"
            color: isLow ? colors.barRed : colors.barFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
        }
    }
}
