import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: volume

    required property var colors

    width: volumeRow.width + 8
    height: 24
    color: mouseArea.containsMouse ? Qt.rgba(colors.barBorder.r, colors.barBorder.g, colors.barBorder.b, 0.5) : "transparent"

    property int vol: 0
    property bool muted: false

    function volumeIcon() {
        if (muted || vol === 0) return Icons.volumeOff
        if (vol >= 66) return Icons.volumeHigh
        if (vol >= 33) return Icons.volumeMedium
        return Icons.volumeLow
    }

    // Poll volume status via wpctl
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProc.running = true
    }

    Process {
        id: checkProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                // Output: "Volume: 0.40" or "Volume: 0.40 [MUTED]"
                var line = data.trim()
                volume.muted = line.indexOf("[MUTED]") !== -1
                var match = line.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    volume.vol = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
    }

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: volumeIcon()
            color: colors.barOrange
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            text: vol + "%"
            color: colors.barFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: launchAudio.running = true
    }

    Process {
        id: launchAudio
        command: ["sh", "-c", "$HOME/.local/bin/tui-audio"]
        running: false
    }
}
