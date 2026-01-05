import Quickshell // Core Quickshell utilities.
import Quickshell.Io // Input/Output related functionalities, like Process.
import Quickshell.Hyprland // Hyprland-specific integrations.
import Quickshell.Services.Pipewire // Services for Pipewire audio management.
import Quickshell.Services.UPower // Services for UPower (battery, power profiles) management.
import QtQuick // Core QML types and elements.
import QtQuick.Layouts // Provides layout managers like RowLayout.
import QtQuick.Controls // Provides UI controls like PopupWindow.
import "Theme.js" as Theme // Import the custom Theme JS library.
import "AudioWidget.qml" // Import the modular AudioWidget component.
import "BatteryWidget.qml" // Import the modular BatteryWidget component.
import "NetworkWidget.qml" // Import the modular NetworkWidget component.

Scope { // The root element of this QML file, defining the scope for properties and functions.
    id: root // Identifier for the Scope, allowing other elements to reference it.

    property bool isBarVisible: true // A property to control the overall visibility of the bar.
    property bool phoneConnected: false // Controlled by external udev rule via IPC

    // IpcHandler allows external processes to interact with this QML component.
    IpcHandler {
        target: "bar" // This handler responds to IPC messages targeted at "bar".
        // A function to toggle the 'isBarVisible' property, effectively showing/hiding the bar.
        function toggle() {
            root.isBarVisible = !root.isBarVisible
        }
        // Function to set phone connection status, called by udev script
        function setPhoneConnected(connected: bool): void {
            root.phoneConnected = connected;
        }
    }

    // Displays the title of the currently active window in Hyprland.
    property string windowTitle: Hyprland.activeToplevel // Accesses the active toplevel from Hyprland singleton.
                             ? Hyprland.activeToplevel.title // If an active toplevel exists, get its title. 
                             : "" // Otherwise, the title is empty.                                          

    // Helper function to check if the "eDP-1" monitor (common laptop display name) is currently connected.
    property bool hasEdp: {
        var screens = Quickshell.screens; // Gets a list of all connected screens via Quickshell.
        for (var i = 0; i < screens.length; i++) { // Loops through each screen.
            if (screens[i].name == "eDP-1") return true; // If "eDP-1" is found, return true.
        }
        return false; // If not found after checking all screens, return false.
    }

    // Variants component iterates over a model and instantiates its delegate for each item.
    // Here, it creates a PanelWindow for each screen reported by Quickshell.
    Variants {
        model: Quickshell.screens // The model is the list of connected screens.

        PanelWindow { // Delegate for each screen, representing a panel/bar on that screen.
            property var modelData // 'modelData' holds the data for the current screen in the iteration.
            screen: modelData // Binds the screen property of PanelWindow to the current modelData (screen object).

            id: window // Identifier for this PanelWindow instance.
            
            color: "transparent"
            
            anchors {
                top: true
                left: true
                right: true 
            }
            
            margins {
                top: 5
                left: 5
                right: 5
                bottom: 0
            }

            // Properties to determine if this panel should be shown on a primary or secondary display.
            property bool isPrimary: modelData.name == "eDP-1" // True if the screen is "eDP-1".
            property bool isSecondary: modelData.name == "HDMI-A-1" // True if the screen is "HDMI-A-1".
            // Determines visibility: primary always shown, secondary shown only if primary is NOT connected.
            property bool shouldShow: isPrimary || (isSecondary && !root.hasEdp)
            
            property string globalFont: "SpaceMono Nerd Font Propo" // Defines a global font to be used in children.

            visible: shouldShow && root.isBarVisible // Panel is visible if 'shouldShow' is true and the bar is generally visible.

            // Sets the exclusive zone (area reserved by the panel) at the top of the screen.
            // This prevents other windows from overlapping the panel.
            exclusiveZone: (shouldShow && root.isBarVisible) ? (clockContainer.height) : 0
            implicitHeight: clockContainer.height // Sets the preferred height of the panel to match the clock.

            // PwObjectTracker is used to bind and track Pipewire objects (like audio sinks/sources).
            // It keeps the QML properties updated with the state of the Pipewire objects.
            // Bind the default audio sink to track its volume and mute state.
            PwObjectTracker {
                objects: [Pipewire.defaultAudioSink] // Tracks the system's default audio output sink.
            }

            // Bind the default audio source to track its microphone volume and mute state.
            PwObjectTracker {
                objects: [Pipewire.defaultAudioSource] // Tracks the system's default audio input source.
            }

            // Clock Widget
            Rectangle {
                id: clockContainer // Identifier for the clock's background container.
                
                // Anchors the clock container to the left and top of its parent.
                anchors.left: parent.left
                anchors.top: parent.top
                
                height: 36 // Fixed height for the clock container.
                width: clock.implicitWidth + 30 // Width is based on the clock text's content plus padding.
                
                color: Theme.background // Background color of the clock container.
                radius: 10 // Rounded corners for the clock container.

                Text {
                    id: clock // Identifier for the clock Text element.
                    anchors.centerIn: parent // Centers the text within its parent (clockContainer).
                    color: Theme.text // Text color.
                    font.family: window.globalFont // Uses the global font defined in the PanelWindow.
                    text: Qt.formatDateTime(new Date(), "hh:mm ddd MMM dd") // Formats current date/time natively.
                    Timer { // A timer to periodically update the clock display.
                        interval: 60000 // Updates every 60000 milliseconds (1 minute).
                        running: true // Timer starts immediately.
                        repeat: true // Repeats indefinitely.
                        triggeredOnStart: true // Ensures the text is set immediately upon start.
                        // On trigger, updates the parent (clock Text) with the new formatted time.
                        onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm ddd MMM dd")
                    }
                }
            }

            // --- Workspaces Widget (Right of Clock) ---
            // Includes the Workspaces component, which visualizes Hyprland workspaces and their windows.
            Workspaces {
                id: workspacesWidget // Identifier for the Workspaces component instance.
                anchors.left: clockContainer.right // Positions it to the right of the clock container.
                anchors.leftMargin: 5 // Adds a 5-pixel margin to the left.
                anchors.top: parent.top 
                height: clockContainer.height 
            }

            // Window Title Widget
            Rectangle {
                id: titleContainer 
                anchors.horizontalCenter: parent.horizontalCenter 
                anchors.top: parent.top 
                height: clockContainer.height 
                
                visible: root.windowTitle !== "" // Only visible if there's an active window title to display.
                
                // Sets the width, clamped to a maximum of one-third of the window's width.
                width: Math.min(titleText.implicitWidth + 30, window.width / 3) 
                
                color: Theme.background
                radius: 10

                Text {
                    id: titleText
                    anchors.centerIn: parent
                    width: parent.width - 20
                    
                    color: Theme.text
                    text: root.windowTitle // Binds the text to the active window title.
                    font.family: window.globalFont // Uses the global font. (not yet working!)
                    
                    elide: Text.ElideRight // Truncates text with "..." at the end if it's too long.
                    horizontalAlignment: Text.AlignHCenter // Centers the text horizontally.
                }
            }

            // Right Panel
            RowLayout { // A RowLayout to group and arrange widgets
                anchors.right: parent.right // Anchors to the right edge of its parent.
                anchors.top: parent.top 
                height: clockContainer.height 
                spacing: 5 // Spacing between items in this RowLayout.

                // Caffeine (Idle Inhibitor) Button: Prevents the system from going idle.
                Rectangle {
                    id: caffeineBtn // Identifier for the caffeine button's background.
                    color: Theme.background // Background color.
                    radius: 10 // Rounded corners.
                    
                    border.width: 2 // Border width.
                    // Border color changes on hover.
                    border.color: caffeineMa.containsMouse ? Theme.green : Theme.transparent

                    Layout.fillHeight: true // Fills available height in the RowLayout.
                    Layout.preferredWidth: caffeineText.implicitWidth + 20 // Width based on text content plus padding.
                    
                    // property 'isCaffeinated' indicates if the idle inhibitor is active.
                    property bool isCaffeinated: false
                    
                    Text {
                        id: caffeineText // Identifier for the caffeine Text element.
                        anchors.centerIn: parent // Centers the text within its parent (caffeineBtn).
                        text: "☕" // Displays a coffee cup emoji.
                        // Text color changes based on 'isCaffeinated' state.
                        color: caffeineBtn.isCaffeinated ? Theme.green : Theme.orange 
                        font.family: window.globalFont // Uses the global font. (not yet working!)
                    }

                    MouseArea {
                        id: caffeineMa // Identifier for the MouseArea controlling interactions.
                        hoverEnabled: true // Enables hover detection.
                        anchors.fill: parent // Fills the entire parent (caffeineBtn).
                        // Toggles 'isCaffeinated' when clicked.
                        onClicked: {
                            caffeineBtn.isCaffeinated = !caffeineBtn.isCaffeinated
                        }
                    }

                    Process {
                        id: inhibitor // Identifier for the Process that runs the systemd inhibitor.
                        // Command to run systemd-inhibit, blocking idle actions indefinitely.
                        command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=caffeine", "--mode=block", "sleep", "infinity"]
                        running: caffeineBtn.isCaffeinated // Process runs only when 'isCaffeinated' is true.
                    }
                }

                // 2. Audio Widgets (Speaker and Mic) - Now encapsulated in AudioWidget.
                AudioWidget {
                    id: audioWidgets // Identifier for the AudioWidget instance.
                    globalFont: window.globalFont // Pass the global font to the AudioWidget.
                }

                // 3, 4, 5. Battery Widgets - Now encapsulated in BatteryWidget.
                BatteryWidget {
                    id: batteryWidgets // Identifier for the BatteryWidget instance.
                    globalFont: window.globalFont // Pass the global font.
                    mainBattery: window.mainBattery // Pass the identified main battery object.
                    phoneConnected: root.phoneConnected // Pass the phone connection status.
                    windowVisible: window.visible // Pass the window visibility.
                }

                // 6. Power Profiles Cycler: Allows cycling through power profiles (e.g., Power Saver, Balanced, Performance).
                Rectangle {
                    color: Theme.background // Background color.
                    radius: 10 // Rounded corners.
                    
                    border.width: 2 // Border width.
                    border.color: profileMa.containsMouse ? Theme.green : Theme.transparent // Border color changes on hover.

                    Layout.fillHeight: true // Fills available height.
                    Layout.preferredWidth: profileText.implicitWidth + 20 // Width based on text content + padding.
                    
                    Text {
                        id: profileText // Identifier for the profile Text element.
                        anchors.centerIn: parent // Centers text within its parent.
                        color: Theme.text // Text color.
                        font.family: window.globalFont // Uses global font.
                        text: { // Displays the current power profile.
                            switch (PowerProfiles.profile) {
                                case PowerProfile.PowerSaver: return "Pwr: Saver";
                                case PowerProfile.Balanced: return "Pwr: Bal";
                                case PowerProfile.Performance: return "Pwr: Perf";
                                default: return "?" + PowerProfiles.profile; 
                            }
                        }
                    }

                    MouseArea {
                        id: profileMa // Identifier for the profile MouseArea.
                        hoverEnabled: true // Enables hover detection.
                        anchors.fill: parent // Fills the parent rectangle.
                        // Cycles through power profiles on click.
                        onClicked: {
                            if (PowerProfiles.profile === PowerProfile.PowerSaver) {
                                PowerProfiles.profile = PowerProfile.Balanced;
                            } else if (PowerProfiles.profile === PowerProfile.Balanced) {
                                if (PowerProfiles.hasPerformanceProfile) { // Check if performance profile is available.
                                    PowerProfiles.profile = PowerProfile.Performance;
                                } else {
                                    PowerProfiles.profile = PowerProfile.PowerSaver; // Cycle back if no performance profile.
                                }
                            } else {
                                PowerProfiles.profile = PowerProfile.PowerSaver; // Cycle back to power saver.
                            }
                        }
                    }
                }

                // 7. Network Indicator (Rightmost) - Now encapsulated in NetworkWidget.
                NetworkWidget {
                    id: networkWidget // Identifier for the NetworkWidget instance.
                    globalFont: window.globalFont // Pass the global font.
                    windowVisible: window.visible // Pass the visibility state of the parent window.
                }
            }



        }
    }
}
