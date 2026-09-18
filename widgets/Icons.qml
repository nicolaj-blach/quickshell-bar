pragma Singleton
import QtQuick

// Nerd Font icons singleton
// Uses direct Unicode characters since String.fromCharCode doesn't work for codepoints > 0xFFFF
QtObject {
    // Battery icons
    readonly property string batteryFull: "󰁹"           // nf-md-battery U+F0079
    readonly property string battery90: "󰂂"             // nf-md-battery_90 U+F0082
    readonly property string battery70: "󰂁"             // nf-md-battery_70 U+F0081
    readonly property string battery50: "󰁿"             // nf-md-battery_50 U+F007F
    readonly property string battery30: "󰁾"             // nf-md-battery_30 U+F007E
    readonly property string battery20: "󰁼"             // nf-md-battery_20 U+F007C
    readonly property string batteryAlert: "󰂎"          // nf-md-battery_alert U+F008E
    readonly property string batteryCharging: "󰢄"       // nf-md-battery_charging U+F0084
    readonly property string batteryCharging20: "󰂆"     // nf-md-battery_charging_20 U+F0086
    readonly property string batteryCharging30: "󰂇"     // nf-md-battery_charging_30 U+F0087
    readonly property string batteryCharging50: "󰂈"     // nf-md-battery_charging_50 U+F0088
    readonly property string batteryCharging70: "󰂊"     // nf-md-battery_charging_70 U+F008A
    readonly property string batteryCharging90: "󰂋"     // nf-md-battery_charging_90 U+F008B
    readonly property string batteryCharging100: "󰂅"    // nf-md-battery_charging_100 U+F0085

    // Volume icons
    readonly property string volumeOff: "󰖁"             // nf-md-volume_off U+F0581
    readonly property string volumeLow: "󰕿"             // nf-md-volume_low U+F057F
    readonly property string volumeMedium: "󰖀"          // nf-md-volume_medium U+F0580
    readonly property string volumeHigh: "󰕾"            // nf-md-volume_high U+F057E

    // Bluetooth icons
    readonly property string bluetoothOff: "󰂲"          // nf-md-bluetooth_off U+F00B2
    readonly property string bluetooth: "󰂯"             // nf-md-bluetooth U+F00AF
    readonly property string bluetoothConnected: "󰂰"    // nf-md-bluetooth_connect U+F00B0

    // Wifi icons
    readonly property string ethernet: "󰈀"              // nf-md-ethernet U+F0200
    readonly property string wifiOff: "󰤮"               // nf-md-wifi_strength_off U+F092B
    readonly property string wifi1: "󰤡"                 // nf-md-wifi_strength_1 U+F0921
    readonly property string wifi2: "󰤢"                 // nf-md-wifi_strength_2 U+F0922
    readonly property string wifi3: "󰤥"                 // nf-md-wifi_strength_3 U+F0927
    readonly property string wifi4: "󰤨"                 // nf-md-wifi_strength_4 U+F0928
}
