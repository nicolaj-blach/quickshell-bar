import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "widgets"

PanelWindow {
    id: bar

    required property var modelData
    required property var colors

    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 30
    implicitHeight: 30
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: colors.barBg

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: colors.barBorder
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Workspaces {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    colors: bar.colors
                    outputName: bar.screen.name
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Clock {
                    anchors.centerIn: parent
                    colors: bar.colors
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Battery { colors: bar.colors }
                    Volume { colors: bar.colors }
                    Bluetooth { colors: bar.colors }
                    Wifi { colors: bar.colors }
                }
            }
        }
    }
}
