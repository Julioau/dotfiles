import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Theme.js" as Theme

RowLayout {
    spacing: 5
    property string globalFont: "SpaceMono Nerd Font Propo"
    property bool debug: false

    // --- Temperature ---
    Rectangle {
        id: tempRect
        color: Theme.rainbow[5] // Rainbow Index 5 (Sky)
        radius: 10
        Layout.fillHeight: true
        Layout.preferredWidth: tempText.implicitWidth + 20

        // Robust path finding for coretemp
        property string tempPath: "" 

        Process {
            id: findTempPath
            // Find hwmon directory with name "coretemp" and append /temp2_input
            // Uses sh -c for piping.
            command: ["sh", "-c", "grep -l 'coretemp' /sys/class/hwmon/hwmon*/name | head -n 1 | xargs dirname | xargs -I {} echo {}/temp2_input"]
            running: true
            
            onRunningChanged: if (running && parent.debug) console.log("SystemStats: Starting path finding process...")

            stdout: StdioCollector {
                onStreamFinished: {
                    var p = text.trim();
                    if (parent.debug) console.log("SystemStats: Path finder stdout: '" + p + "'");
                    if (p !== "") tempRect.tempPath = p;
                }
            }
            stderr: StdioCollector {
                onStreamFinished: {
                    if (text.length > 0 && parent.debug) console.log("SystemStats: Path finder stderr: " + text);
                }
            }
        }

        FileView {
            id: tempFile
            path: tempRect.tempPath
            // If path is empty, it unloads. When path is set, it loads.
        }
        
        property string tempContent: ""

        Connections {
            target: tempFile
            function onTextChanged() {
                tempRect.tempContent = tempFile.text()
            }
        }
        
        Timer {
            interval: 2000
            running: tempRect.tempPath !== ""
            repeat: true
            triggeredOnStart: true
            onTriggered: tempFile.reload()
        }

        Text {
            id: tempText
            anchors.centerIn: parent
            font.family: globalFont
            color: Theme.background
            text: {
                if (tempRect.tempContent === "") return "...";
                var temp = parseInt(tempRect.tempContent) / 1000;
                return Math.round(temp) + "°C "
            }
        }
    }

    // --- Memory ---
    Rectangle {
        id: memRect
        color: Theme.rainbow[6] // Rainbow Index 6 (Green)
        radius: 10
        Layout.fillHeight: true
        Layout.preferredWidth: memText.implicitWidth + 20

        FileView {
            id: memFile
            path: "/proc/meminfo"
        }
        
        property string memContent: ""

        Connections {
            target: memFile
            function onTextChanged() {
                memRect.memContent = memFile.text()
            }
        }
        
        Timer {
            interval: 5000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: memFile.reload()
        }

        Text {
            id: memText
            anchors.centerIn: parent
            font.family: globalFont
            color: Theme.background
            text: {
                if (memRect.memContent === "") return "...";
                var lines = memRect.memContent.split("\n");
                var total = 0;
                var available = 0;
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].startsWith("MemTotal:")) {
                        total = parseInt(lines[i].match(/\d+/)[0]);
                    } else if (lines[i].startsWith("MemAvailable:")) {
                        available = parseInt(lines[i].match(/\d+/)[0]);
                    }
                }
                if (total === 0) return "...";
                var used = (total - available) / 1024 / 1024; // KB -> GB
                return used.toFixed(1) + " GiB"
            }
        }
    }
}