import QtQuick
import Quickshell

Row {
    id: clock

    required property var colors

    spacing: 12

    property string currentTime: ""
    property string currentDate: ""
    property string currentDay: ""
    property string currentWeek: ""

    function updateTime() {
        var now = new Date()
        currentTime = now.toLocaleTimeString(Qt.locale(), "HH:mm")
    }

    function updateDate() {
        var now = new Date()
        currentDate = now.toLocaleDateString(Qt.locale(), "dd MMM")
        currentDay = now.toLocaleDateString(Qt.locale(), "ddd")

        // Calculate week number
        var startOfYear = new Date(now.getFullYear(), 0, 1)
        var days = Math.floor((now - startOfYear) / (24 * 60 * 60 * 1000))
        var weekNum = Math.ceil((days + startOfYear.getDay() + 1) / 7)
        currentWeek = "W" + weekNum.toString().padStart(2, "0")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateTime()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateDate()
    }

    Text {
        text: currentTime
        color: colors.barFg
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }

    Text {
        text: "|"
        color: colors.barBorder
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }

    Text {
        text: currentDate
        color: colors.barFg
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }

    Text {
        text: "|"
        color: colors.barBorder
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }

    Text {
        text: currentDay
        color: colors.barMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }

    Text {
        text: "|"
        color: colors.barBorder
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }

    Text {
        text: currentWeek
        color: colors.barMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        font.bold: true
    }
}
