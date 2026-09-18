import QtQuick
import QtQuick.Layouts

Row {
    id: workspaces

    required property var colors
    required property string outputName

    spacing: 0

    // Re-evaluate when workspaces change
    property int wsCount: NiriIpc.workspaces.length

    // Get workspaces for this output, or all if single monitor
    function getWorkspaceList() {
        var forOutput = NiriIpc.getWorkspacesForOutput(outputName)
        if (forOutput.length > 0) return forOutput
        
        // Fallback: if no match, maybe output name differs - show all workspaces
        if (NiriIpc.workspaces.length > 0) {
            // Check if this might be the primary output
            var allOutputs = []
            for (var i = 0; i < NiriIpc.workspaces.length; i++) {
                var out = NiriIpc.workspaces[i].output
                if (allOutputs.indexOf(out) === -1) allOutputs.push(out)
            }
            // If single output in niri, show all
            if (allOutputs.length === 1) {
                return NiriIpc.getWorkspacesForOutput(allOutputs[0])
            }
        }
        return []
    }

    Repeater {
        // Depend on wsCount to trigger re-evaluation
        model: workspaces.wsCount > 0 ? workspaces.getWorkspaceList() : []

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
                text: modelData.name !== "" ? modelData.name : modelData.idx.toString()
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
                onClicked: NiriIpc.focusWorkspace(modelData.id)
            }
        }
    }
}
