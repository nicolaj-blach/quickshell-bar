import QtQuick
import QtQuick.Layouts

Row {
    id: workspaces

    required property var colors
    required property string outputName

    spacing: 0

    // Trigger re-evaluation when NiriIpc updates
    property int updateTrigger: NiriIpc.updateTrigger

    // Get workspaces for this output (only active or occupied)
    function getWorkspaceList() {
        var all = NiriIpc.getWorkspacesForOutput(outputName)
        var filtered = []
        for (var i = 0; i < all.length; i++) {
            var ws = all[i]
            // Show if active, focused, or has windows
            if (ws.isActive || ws.isFocused || NiriIpc.isOccupied(ws.id)) {
                filtered.push(ws)
            }
        }
        return filtered
    }

    // Monitor key indicator [1], [2], etc.
    Rectangle {
        id: monitorKey
        visible: NiriIpc.hasMultipleMonitors()
        
        width: monitorLabel.width + 8
        height: 24
        color: "transparent"

        Text {
            id: monitorLabel
            anchors.centerIn: parent
            text: "[" + NiriIpc.getMonitorNumber(workspaces.outputName) + "]"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
            color: NiriIpc.focusedOutput === workspaces.outputName ? colors.barRed : colors.barMuted
        }
    }

    Repeater {
        // Depend on updateTrigger to refresh
        model: workspaces.updateTrigger >= 0 ? workspaces.getWorkspaceList() : []

        Rectangle {
            id: wsButton

            required property var modelData

            width: wsLabel.width + 12
            height: 24
            color: mouseArea.containsMouse ? Qt.rgba(colors.barBorder.r, colors.barBorder.g, colors.barBorder.b, 0.5) : "transparent"

            property bool isActive: modelData.isActive
            property bool isFocused: modelData.isFocused
            property bool isOccupied: NiriIpc.isOccupied(modelData.id)

            Text {
                id: wsLabel
                anchors.centerIn: parent
                text: modelData.idx.toString()
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
                color: {
                    if (isActive && isFocused) return colors.barAccent
                    if (isActive && !isFocused) {
                        return isOccupied ? colors.barAccent2 : colors.barMuted
                    }
                    if (isOccupied) return colors.barAccent2
                    return colors.barMuted
                }
            }

            // Active indicator line
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 4
                height: 2
                visible: isActive
                color: isFocused ? colors.barAccent : colors.barMuted
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: NiriIpc.focusWorkspaceIdx(modelData.idx)
            }
        }
    }

    // Add workspace button (+)
    Rectangle {
        id: addButton

        width: addLabel.width + 12
        height: 24
        color: addMouseArea.containsMouse ? Qt.rgba(colors.barBorder.r, colors.barBorder.g, colors.barBorder.b, 0.5) : "transparent"

        Text {
            id: addLabel
            anchors.centerIn: parent
            text: "+"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
            color: colors.barMuted
        }

        MouseArea {
            id: addMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: NiriIpc.createWorkspace()
        }
    }
}
