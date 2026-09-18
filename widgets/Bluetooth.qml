import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: bluetooth

    required property var colors

    width: btIcon.width + 8
    height: 24
    color: mouseArea.containsMouse ? Qt.rgba(colors.barBorder.r, colors.barBorder.g, colors.barBorder.b, 0.5) : "transparent"
    visible: hasAdapter

    property bool hasAdapter: false
    property bool powered: false
    property bool connected: false
    property string lastOutput: ""

    function bluetoothIcon() {
        if (!powered) return Icons.bluetoothOff
        if (connected) return Icons.bluetoothConnected
        return Icons.bluetooth
    }

    function parseOutput(data) {
        var hasCtrl = data.indexOf("Controller") !== -1
        var hasPower = data.indexOf("Powered: yes") !== -1
        var hasConnected = data.indexOf("---CONNECTED---") !== -1
        
        if (hasCtrl) {
            bluetooth.hasAdapter = true
            bluetooth.powered = hasPower
            bluetooth.connected = hasConnected
        }
    }

    Component.onCompleted: {
        checkProc.running = true
    }

    // Poll bluetooth status via bluetoothctl
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            checkProc.running = true
        }
    }

    Process {
        id: checkProc
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null && bluetoothctl devices Connected 2>/dev/null | grep -q Device && echo '---CONNECTED---'; true"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                bluetooth.lastOutput = data
                bluetooth.parseOutput(data)
            }
        }
    }

    Text {
        id: btIcon
        anchors.centerIn: parent
        text: bluetoothIcon()
        color: powered ? colors.barAccent : colors.barMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        font.bold: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            launchBluetooth.running = true
        }
    }

    Process {
        id: launchBluetooth
        command: ["sh", "-c", "$HOME/.local/bin/tui-bluetooth"]
        running: false
    }
}
