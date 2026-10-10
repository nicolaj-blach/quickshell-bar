import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property string colorsPath: Quickshell.env("HOME") + "/.config/quickshell/colors.json"

    property color barBg: "#282c34"
    property color barFg: "#abb2bf"
    property color barBorder: "#3e4451"
    property color barAccent: "#61afef"
    property color barAccent2: "#c678dd"
    property color barMuted: "#565c64"
    property color barRed: "#e06c75"
    property color barGreen: "#98c379"
    property color barCyan: "#56b6c2"
    property color barOrange: "#d19a66"

    FileView {
        id: colorsFile
        path: root.colorsPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.loadColors()
    }

    function loadColors() {
        const text = colorsFile.text()
        if (!text) return
        try {
            const colors = JSON.parse(text)
            if (colors.bar_bg) root.barBg = colors.bar_bg
            if (colors.bar_fg) root.barFg = colors.bar_fg
            if (colors.bar_border) root.barBorder = colors.bar_border
            if (colors.bar_accent) root.barAccent = colors.bar_accent
            if (colors.bar_accent2) root.barAccent2 = colors.bar_accent2
            if (colors.bar_muted) root.barMuted = colors.bar_muted
            if (colors.bar_red) root.barRed = colors.bar_red
            if (colors.bar_green) root.barGreen = colors.bar_green
            if (colors.bar_cyan) root.barCyan = colors.bar_cyan
            if (colors.bar_orange) root.barOrange = colors.bar_orange
        } catch (e) {
            console.error("Failed to parse colors.json:", e)
        }
    }

    property string configPath: Quickshell.env("HOME") + "/.config/quickshell/config.json"
    property var systemMenuCmd: []
    property var wifiCmd: []
    property var bluetoothCmd: []
    property var audioCmd: []

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.loadConfig()
    }

    function loadConfig() {
        const text = configFile.text()
        if (!text) return
        try {
            const config = JSON.parse(text)
            root.systemMenuCmd = Array.isArray(config.system_menu_cmd) ? config.system_menu_cmd : []
            root.wifiCmd = Array.isArray(config.wifi_cmd) ? config.wifi_cmd : []
            root.bluetoothCmd = Array.isArray(config.bluetooth_cmd) ? config.bluetooth_cmd : []
            root.audioCmd = Array.isArray(config.audio_cmd) ? config.audio_cmd : []
        } catch (e) {
            console.error("Failed to parse config.json:", e)
        }
    }

    // `quickshell ipc -p <bar path> call bar hide|unhide|toggle`
    property bool barVisible: true

    IpcHandler {
        target: "bar"
        function hide(): void { root.barVisible = false }
        function unhide(): void { root.barVisible = true }
        function toggle(): void { root.barVisible = !root.barVisible }
    }

    Variants {
        model: Quickshell.screens
        Bar { colors: root; shell: root; visible: root.barVisible }
    }
}
