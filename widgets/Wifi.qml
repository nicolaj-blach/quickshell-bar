import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: wifi

    required property var colors

    width: wifiRow.width + 8
    height: 24
    color: mouseArea.containsMouse ? Qt.rgba(colors.barBorder.r, colors.barBorder.g, colors.barBorder.b, 0.5) : "transparent"

    property bool isWired: false
    property int strength: 0
    property string ssid: ""

    function wifiIcon() {
        if (isWired) return Icons.ethernet
        if (strength >= 75) return Icons.wifi4
        if (strength >= 50) return Icons.wifi3
        if (strength >= 25) return Icons.wifi2
        if (strength > 0) return Icons.wifi1
        return Icons.wifiOff
    }

    // Poll network status via nmcli
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkProc.running = true
        }
    }

    Process {
        id: checkProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                var lines = data.trim().split("\n")
                var foundWired = false
                var foundWifi = false
                
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts.length >= 3) {
                        var type = parts[0]
                        var state = parts[1]
                        var conn = parts[2]
                        
                        if (type === "ethernet" && state === "connected") {
                            foundWired = true
                            wifi.isWired = true
                            wifi.ssid = ""
                            break
                        } else if (type === "wifi" && state === "connected") {
                            foundWifi = true
                            wifi.isWired = false
                            wifi.ssid = conn
                        }
                    }
                }
                
                if (!foundWired && !foundWifi) {
                    wifi.isWired = false
                    wifi.ssid = ""
                    wifi.strength = 0
                } else if (foundWifi) {
                    strengthProc.running = true
                }
            }
        }
    }

    Process {
        id: strengthProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                var lines = data.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts.length >= 2 && parts[0] === "*") {
                        wifi.strength = parseInt(parts[1]) || 0
                        break
                    }
                }
            }
        }
    }

    Row {
        id: wifiRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: wifiIcon()
            color: colors.barAccent2
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            text: ssid
            color: colors.barMuted
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
            visible: !isWired && ssid !== ""
            leftPadding: 2
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            launchWifi.running = true
        }
    }

    Process {
        id: launchWifi
        command: ["sh", "-c", "$HOME/.local/bin/tui-wifi"]
        running: false
    }
}
