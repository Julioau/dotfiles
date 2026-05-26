import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "Theme.js" as Theme

// BatteryWidget.qml: A component that displays various battery statuses.
// Includes phone battery (if enabled), extra UPower devices, and the main laptop battery.
RowLayout {
    id: root // Identifier for the root element.
    // Exposes a property to receive the global font from the parent.
    property string globalFont: "SpaceMono Nerd Font Propo"
    property bool debug: false
    property color widgetColor: Theme.background
    property color textColor: widgetColor === Theme.background ? Theme.text : Theme.background

    // Property to signal if the parent window is visible, to control process running.
    property bool windowVisible: false
    // Property to signal if the phone is connected (set by parent via IPC).
    property bool phoneConnected: false
    
    // Reset battery level when phone disconnects
    onPhoneConnectedChanged: {
        if (!phoneConnected) {
            root.phoneBatLevel = -1;
            adbProc.running = false; // Ensure process stops immediately
        }
    }

    // 1. Phone Battery Logic (ADB)
    // Internal property to store the phone battery level.
    property int phoneBatLevel: -1

    Process {
        id: adbProc
        // Timeout ensures we don't accumulate stuck processes if ADB is unresponsive.
        command: ["timeout", "2s", "adb", "shell", "dumpsys", "battery"] 
        running: false // Controlled manually by timer and IPC
        
        // Debug logging for process start
        onRunningChanged: if (running && root.debug) console.log("ADB Process Started")

        stdout: StdioCollector {
            onStreamFinished: {
                // Debug raw output (first 50 chars to avoid spam)
                if (root.debug) console.log("ADB Output received: " + text.substring(0, 50) + "...")

                // Split the output into individual lines for line-by-line processing.
                var lines = text.split("\n");
                var foundLevel = false;
                
                // Iterate through each line to find the one starting with "level:".
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.startsWith("level:")) {
                        // Extract the part after "level:"
                        var levelStr = line.substring(line.indexOf(":") + 1).trim();
                        var val = parseInt(levelStr);
                        
                        // If it's a valid number, update the property.
                        if (!isNaN(val)) {
                            if (root.debug) console.log("ADB Battery Level Found: " + val);
                            root.phoneBatLevel = val;
                            foundLevel = true;
                            break; // Stop looking after finding the level.
                        } else {
                            if (root.debug) console.log("ADB Parse Error: level is NaN");
                        }
                    }
                }
                
                // If "level:" wasn't found (e.g. adb error or wrong output), reset to -1.
                if (!foundLevel) {
                    if (root.debug) console.log("ADB Level not found in output.");
                    root.phoneBatLevel = -1;
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0 && root.debug) console.log("ADB Error: " + text);
            }
        }
    }

    Timer {
        interval: 60000 // Check every 60s
        // Only run if the phone is connected AND the bar is visible.
        running: root.phoneConnected && root.windowVisible
        repeat: true
        triggeredOnStart: true
        // Trigger the process to fetch battery level.
        onTriggered: adbProc.running = true
    }

    // 2. Main Laptop Battery Identification logic moved here.
    property var mainBattery: {
        var devs = UPower.devices.values; // Gets all UPower devices.
        // First pass: look specifically for a device marked as a laptop battery.
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].isLaptopBattery) return devs[i];
        }
        // Second pass: if no specific laptop battery, look for any device of type Battery.
        for (var j = 0; j < devs.length; j++) {
            if (devs[j].type === UPowerDeviceType.Battery) return devs[j];
        }
        return null; // If no battery found, return null.
    }

    // 3. Phone Battery (Dynamic) Widget: Displays the phone's battery level.
    Rectangle {
        visible: root.phoneBatLevel >= 0 // Only visible if a valid battery level is available.
        color: widgetColor // Background color.
        radius: 10 // Rounded corners.
        Layout.fillHeight: true // Fills available height.
        Layout.preferredWidth: phoneText.implicitWidth + 20 // Width based on text content + padding.
        
        Text {
            id: phoneText // Identifier for the phone battery Text element.
            anchors.centerIn: parent // Centers text within its parent.
            color: textColor // Text color.
            font.family: root.globalFont // Uses global font.
            text: " " + root.phoneBatLevel + "%" // Displays phone icon and battery percentage.
        }
    }

    // 4. Extra UPower Devices (Dynamic Repeater): Displays battery levels for other connected devices.
    Repeater {
        model: { // The model is dynamically constructed based on UPower devices.
            var devs = UPower.devices.values; // Get all UPower devices.
            var list = []; // Initialize an empty list for devices to display.
            for(var i=0; i<devs.length; i++) { // Loop through all devices.
                var d = devs[i];
                // Exclude the main laptop battery, as it's handled separately.
                if (d === root.mainBattery) continue; 
                
                // Include devices of specific types (Battery, Mouse, Keyboard, Headset, Headphones).
                if (d.type === UPowerDeviceType.Battery || 
                    d.type === UPowerDeviceType.Mouse || 
                    d.type === UPowerDeviceType.Keyboard || 
                    d.type === UPowerDeviceType.Headset || 
                    d.type === UPowerDeviceType.Headphones) {
                    list.push(d); // Add the device to the list if it matches criteria.
                }
            }
            return list; // Returns the filtered list of devices.
        }
        
        Rectangle { // Delegate for each extra UPower device.
            color: widgetColor // Background color.
            radius: 10 // Rounded corners.
            Layout.fillHeight: true // Fills available height.
            Layout.preferredWidth: extraBatText.implicitWidth + 20 // Width based on text content + padding.
            
            Text {
                id: extraBatText // Identifier for the extra battery Text element.
                anchors.centerIn: parent // Centers text within its parent.
                color: textColor // Text color.
                font.family: root.globalFont // Uses global font.
                text: { // Dynamically generated text with icon and percentage.
                    var icon = ""; // Default generic device icon.
                    if (modelData.type === UPowerDeviceType.Mouse) icon = "󰍽"; // Mouse icon.
                    if (modelData.type === UPowerDeviceType.Keyboard) icon = "󰌌"; // Keyboard icon.
                    if (modelData.type === UPowerDeviceType.Headset || modelData.type === UPowerDeviceType.Headphones) icon = "󰋋"; // Headset/Headphones icon.
                    // Fallback for secondary batteries not caught by mainBattery logic.
                    if (modelData.type === UPowerDeviceType.Battery) icon = "󰁹"; // Battery icon.
                    
                    return icon + " " + Math.round(modelData.percentage * 100) + "%"; // Returns icon and percentage.
                }
            }
        }
    }

    // 5. Main Battery Indicator: Displays status of the primary laptop battery.
    Rectangle {
        color: widgetColor // Background color.
        radius: 10 // Rounded corners.
        Layout.fillHeight: true // Fills available height.
        Layout.preferredWidth: batText.implicitWidth + 20 // Width based on text content + padding.
        
        visible: root.mainBattery != null // Only visible if a main battery was identified.
        
        Text {
            id: batText // Identifier for the main battery Text element.
            anchors.centerIn: parent // Centers text within its parent.
            font.family: root.globalFont // Uses global font.
            color: { // Text color changes based on battery level and state.
                var bat = root.mainBattery;
                if (!bat) return textColor; // Default if no battery.
                var p = bat.percentage * 100; // Get percentage.
                if (p < 20 && bat.state !== 1) return Theme.red; // Red if low and not charging.
                return textColor; // Default otherwise.
            }
            text: { // Dynamically generated text with icon and percentage.
                var bat = root.mainBattery;
                if (!bat) return ""; // Empty string if no battery.
                var icon = "󰁹"; // Default battery icon.
                if (bat.state === 1) icon = "󰂄"; // Charging icon.
                else if (bat.state === 4) icon = "󰂄"; // Full/Plugged icon.
                return icon + " " + Math.round(bat.percentage * 100) + "%"; // Returns icon and percentage.
            }
        }
    }
}