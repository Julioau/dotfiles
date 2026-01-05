import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Theme.js" as Theme

// NetworkWidget.qml: A component that displays the active network connection name.
// It uses an external process to fetch network status and allows opening a network manager.
Rectangle {
    id: root // Identifier for the root element.
    // Exposes a property to receive the global font from the parent.
    property string globalFont: "SpaceMono Nerd Font Propo"
    // Exposes a property to signal if the parent window is visible, to control process running.
    property bool windowVisible: false

    color: Theme.background // Background color.
    radius: 10 // Rounded corners.
    
    border.width: 2 // Border width.
    border.color: netMa.containsMouse ? Theme.green : Theme.transparent // Border color changes on hover.

    Layout.fillHeight: true // Fills available height.
    Layout.preferredWidth: netText.implicitWidth + 20 // Width based on text content + padding.
    
    Text {
        id: netText // Identifier for the network Text element.
        anchors.centerIn: parent // Centers text within its parent.
        color: Theme.text // Text color.
        font.family: root.globalFont // Uses global font.
        text: "Net" // Initial text display.
    }

    MouseArea {
        id: netMa // Identifier for the network MouseArea.
        hoverEnabled: true // Enables hover detection.
        anchors.fill: parent // Fills the parent rectangle.
        // On click, executes an external command to open Plasma's network management widget.
        onClicked: {
            Quickshell.execDetached(["plasmawindowed", "org.kde.plasma.networkmanagement"])
        }
    }
    
    // 1. Fetcher Process: Gets the actual connection name.
    Process { 
        id: netProc 
        command: ["sh", "-c", "nmcli -t -f name connection show --active | head -n1"]
        running: false // Triggered by monitorProc
        stdout: StdioCollector {
            onStreamFinished: { 
                var txt = text.trim();
                netText.text = txt === "" ? "Disconnected" : txt;
            }
        }
    }

    // 2. Monitor Process: Listens for network changes events.
    // Instead of polling, we wait for nmcli to tell us something changed.
    Process {
        id: monitorProc
        command: ["nmcli", "monitor"]
        running: root.windowVisible // Keep running while bar is visible
        
        // When nmcli monitor prints anything (state change), trigger an update.
        stdout: StdioCollector {
            onTextChanged: {
                if (text.length > 0) {
                    netProc.running = true;
                    // Clear buffer to ensure onTextChanged triggers again for new data
                    reset(); 
                }
            }
        }
    }
    
    // Initial fetch on load
    Component.onCompleted: netProc.running = true
}