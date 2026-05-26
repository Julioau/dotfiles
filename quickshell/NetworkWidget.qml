import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "Theme.js" as Theme

// NetworkWidget.qml: Native implementation using Quickshell.Networking
Rectangle {
    id: root
    property string globalFont: "SpaceMono Nerd Font Propo"
    property color widgetColor: Theme.background
    property color textColor: widgetColor === Theme.background ? Theme.text : Theme.background

    // Property to signal if the parent window is visible (kept for API compatibility)
    property bool windowVisible: false

    color: widgetColor
    radius: 10
    
    border.width: 2
    border.color: netMa.containsMouse ? Theme.green : Theme.transparent

    Layout.fillHeight: true
    Layout.preferredWidth: netRow.implicitWidth + 20
    
    // Logic to find the primary Wi-Fi device
    property var wifiDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi) return devs[i];
        }
        return null;
    }

    // Logic to find the currently connected network on the Wi-Fi device
    property var activeNetwork: {
        if (!root.wifiDevice) return null;
        var nets = root.wifiDevice.networks.values;
        for (var i = 0; i < nets.length; i++) {
            if (nets[i].connected) return nets[i];
        }
        return null;
    }

    property bool isConnected: root.activeNetwork !== null
    property int signalStrength: root.isConnected ? root.activeNetwork.signalStrength : 0
    property string ssid: root.isConnected ? root.activeNetwork.name : "Disconnected"

    Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: iconText
            color: root.textColor
            font.family: root.globalFont
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.isConnected) return "󰤭"; // Disconnected
                
                var signal = root.signalStrength;
                if (signal >= 80) return "󰤨";      // 4 bars
                if (signal >= 60) return "󰤥";      // 3 bars
                if (signal >= 40) return "󰤢";      // 2 bars
                if (signal >= 20) return "󰤟";      // 1 bar
                return "󰤯";                        // 0 bars
            }
        }

        Text {
            id: netText
            anchors.verticalCenter: parent.verticalCenter
            color: textColor
            font.family: root.globalFont
            text: root.ssid
        }
    }

    MouseArea {
        id: netMa
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            Quickshell.execDetached(["plasmawindowed", "org.kde.plasma.networkmanagement"])
        }
    }
}
