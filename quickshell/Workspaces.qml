import QtQuick // Core QML types and elements.
import QtQuick.Layouts // Provides layout managers like RowLayout.
import Quickshell // Quickshell core utilities.
import Quickshell.Hyprland // Hyprland-specific integrations for Quickshell.
import Quickshell.Widgets // Custom Quickshell widgets, such as IconImage.
import "Theme.js" as Theme // Import the custom Theme JS library.

RowLayout { // The root element, arranges items horizontally.
    id: root // Identifier for the RowLayout, allowing other elements to reference it.
    property int mon_workspaces: 3
    property bool debug: false
    spacing: 5 // Spacing between items in the RowLayout.

        // property 'updating' controls a "burst" update mechanism for smooth animations.
        // It's set to true when an event occurs and stays true for a short duration.
        property bool updating: false

        // Timer to stop the high-speed updating after a period of inactivity.
        Timer {
        id: stopTimer // Identifier for this timer.
        interval: 1000 // Sets the timer to trigger after 1000 milliseconds (1 second).
        onTriggered: root.updating = false // When triggered, sets 'updating' back to false.
    }

        // High-speed timer to continuously refresh toplevels while 'updating' is true,
        // ensuring smooth visual feedback during window movements or changes.
        Timer {
        interval: 33 // ~30fps (1000ms / 33ms ≈ 30 frames per second).
        running: root.updating // This timer runs only when 'updating' is true.
        repeat: true // The timer repeats continuously while running.
        onTriggered: Hyprland.refreshToplevels() // Forces Hyprland to update window data.
    }

        // Listens for raw IPC events from Hyprland to detect window changes.
        Connections {
        target: Hyprland // Specifies that this object listens to signals from the Hyprland singleton.
        // This function is called whenever Hyprland emits a rawEvent.
        function onRawEvent(event) {
            // Defines an array of event names that should trigger a refresh.
            const events = ["movewindow", "openwindow", "closewindow", "changefloatingmode", "fullscreen", "workspace", "activewindow", "activewindowv2", "urgent"];
            // Checks if the received event's name is in the list of events to watch for.
            if (events.includes(event.name)) {
                Hyprland.refreshToplevels(); // Forces a refresh of Hyprland window data.
                root.updating = true; // Sets the 'updating' flag to true to enable high-speed refreshes.
                stopTimer.restart(); // Restarts the timer that will eventually stop the high-speed refreshes.
            }
        }
    }

    // Function to determine the appropriate icon for a given client (window).
    function getIcon(clientData) {
        if (!clientData) return "";
        var cls = clientData.class || "";
        var apps = DesktopEntries.applications.values;
        
        // Check if an icon exists in the Quickshell icon theme for the class directly.
        if (Quickshell.iconPath(cls, true) !== "") return cls;

        // Iterate through all desktop entries to find a match.
        for (var i = 0; i < apps.length; i++) {
            var app = apps[i];

            // Standard match: The application's startup class matches the client's class.
            if (app.startupClass === cls && app.icon) {
                return app.icon;
            }
            
            // Loose match for Flatpaks/Java apps where WMClass differs from StartupWMClass
            // e.g. cls: "com.stremio.stremio", startupClass: "stremio"
            if (app.startupClass && cls.toLowerCase().endsWith(app.startupClass.toLowerCase()) && app.icon) {
                 if (root.debug) {
                     console.log("Workspaces: Found loose match for " + cls + " -> " + app.startupClass + " Icon: " + app.icon);
                 }
                 return app.icon;
            }

            // Chrome Web App Heuristic:
            // Chrome apps often don't set StartupWMClass correctly in the window,
            // but the window title usually contains the application name.
            if (cls.startsWith("chrome-") && app.name) {
                var appName = app.name.toLowerCase();
                var windowTitle = clientData.title ? clientData.title.toLowerCase() : "";

                // Check if the Window Title contains the App Name (e.g. "Discord" in "(1) Discord")
                if (windowTitle.includes(appName)) {
                    return app.icon;
                }
            }
        }

        return "";
    }

    // Repeater to create a visual representation for each Hyprland workspace.
    Repeater {
        model: Hyprland.workspaces // The model provides the list of workspaces from Hyprland.

        delegate: Rectangle { // Each workspace is represented by a Rectangle.
            id: workspaceDelegate // Identifier for each individual workspace rectangle.
            property var workspace: modelData // Accesses the workspace data for this delegate.
            // Determines the monitor associated with this workspace, falling back to the first available monitor.
            property var monitor: workspace.monitor || (Hyprland.monitors.values.length > 0 ? Hyprland.monitors.values[0] : null)
            property int monitorTransform: (monitor && monitor.lastIpcObject) ? (monitor.lastIpcObject.transform || 0) : 0
            property bool isVertical: monitorTransform % 2 !== 0

            Layout.fillHeight: true // Makes the rectangle fill the available height within its parent RowLayout.
            // Adds a margin after every 'mon_workspaces' workspaces to separate monitors, excluding the last set.
            Layout.rightMargin: (workspace.id % root.mon_workspaces === 0 && workspace.id < (Hyprland.monitors.values.length * root.mon_workspaces)) ? 10 : 0
            
            property bool isSpecial: workspace.name.startsWith("special:") // Checks if the workspace is a "special" (scratchpad) workspace.


            visible: !isSpecial // Special workspaces are not shown.

            // Dynamic sizing logic: Adjusts the size of the workspace representation.
            // It tries to make empty workspaces square, and occupied ones match the true workspace bounds.
                // Checks if the workspace has no open windows.
                property bool isEmpty: workspace.toplevels.values.length === 0
                // Calculates the aspect ratio of the associated monitor, defaults to 16:9.
                property real monitorRatio: monitor ? (isVertical ? (monitor.height / monitor.width) : (monitor.width / monitor.height)) : (16 / 9)
                
                // Calculate true workspace bounds (ignoring floating windows)
                property real minX: {
                    var mX = monitor ? monitor.x : 0;
                    if (isEmpty) return mX;
                    var res = mX;
                    for (var i = 0; i < workspace.toplevels.values.length; i++) {
                        var clientData = workspace.toplevels.values[i].lastIpcObject;
                        if (clientData && !clientData.floating && clientData.at) res = Math.min(res, clientData.at[0]);
                    }
                    return res;
                }
                property real maxX: {
                    var monW = monitor ? (isVertical ? monitor.height : monitor.width) : 1920;
                    var monX = monitor ? monitor.x : 0;
                    if (isEmpty) return monX + monW;
                    var res = monX + monW;
                    for (var i = 0; i < workspace.toplevels.values.length; i++) {
                        var clientData = workspace.toplevels.values[i].lastIpcObject;
                        if (clientData && !clientData.floating && clientData.at && clientData.size) res = Math.max(res, clientData.at[0] + clientData.size[0]);
                    }
                    return res;
                }
                property real minY: {
                    var mY = monitor ? monitor.y : 0;
                    if (isEmpty) return mY;
                    var res = mY;
                    for (var i = 0; i < workspace.toplevels.values.length; i++) {
                        var clientData = workspace.toplevels.values[i].lastIpcObject;
                        if (clientData && !clientData.floating && clientData.at) res = Math.min(res, clientData.at[1]);
                    }
                    return res;
                }
                property real maxY: {
                    var monH = monitor ? (isVertical ? monitor.width : monitor.height) : 1080;
                    var monY = monitor ? monitor.y : 0;
                    if (isEmpty) return monY + monH;
                    var res = monY + monH;
                    for (var i = 0; i < workspace.toplevels.values.length; i++) {
                        var clientData = workspace.toplevels.values[i].lastIpcObject;
                        if (clientData && !clientData.floating && clientData.at && clientData.size) res = Math.max(res, clientData.at[1] + clientData.size[1]);
                    }
                    return res;
                }
                property real totalWidth: Math.max(1, maxX - minX)
                property real totalHeight: Math.max(1, maxY - minY)
                property real boundsRatio: totalWidth / totalHeight

                // Sets the target aspect ratio: 1.0 (square) if empty, or boundsRatio if it has windows.
                property real targetRatio: isEmpty ? 1.0 : boundsRatio
                
                property real currentRatio: targetRatio // The actual ratio being used, can be animated.
                // Animates changes to 'currentRatio' for a smooth visual transition.
                Behavior on currentRatio { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

            // Sets the preferred width based on height and currentRatio, making it invisible if not shown.
            Layout.preferredWidth: visible ? height * currentRatio : 0

            radius: 10 // Rounded corners for the workspace rectangle.
            // Background color changes based on whether the workspace is active.
            color: workspace.active ? Theme.surface1 : Theme.surface0 // Surface1 if active, Surface0 otherwise.
            border.width: 2 // We keep border width to reserve space, but make it transparent.
            border.color: Theme.transparent
                
            property bool isFocused: wsMouse.containsMouse || (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace.id === workspace.id)
                
            // Viewport Indicator
            Rectangle {
                z: 1000 // Ensure it renders above windows
                property real monW: monitor ? (isVertical ? monitor.height : monitor.width) : 1920
                property real monH: monitor ? (isVertical ? monitor.width : monitor.height) : 1080
                property real monX: monitor ? monitor.x : 0
                property real monY: monitor ? monitor.y : 0
                
                // Calculate the target layout dimensions to avoid animation chasing during parent resize
                property real targetInnerDelegateWidth: (workspaceDelegate.height * workspaceDelegate.targetRatio) - (2 * workspaceDelegate.border.width)
                property real targetInnerDelegateHeight: workspaceDelegate.height - (2 * workspaceDelegate.border.width)
                
                x: workspaceDelegate.border.width + ((monX - workspaceDelegate.minX) / workspaceDelegate.totalWidth) * targetInnerDelegateWidth
                y: workspaceDelegate.border.width + ((monY - workspaceDelegate.minY) / workspaceDelegate.totalHeight) * targetInnerDelegateHeight
                width: (monW / workspaceDelegate.totalWidth) * targetInnerDelegateWidth
                height: (monH / workspaceDelegate.totalHeight) * targetInnerDelegateHeight
                
                color: "transparent"
                border.width: 2
                border.color: workspaceDelegate.workspace.urgent ? Theme.red : (workspaceDelegate.isFocused ? Theme.green : (workspaceDelegate.workspace.active ? Theme.blue : Theme.transparent))
                radius: 10

                // Smooth transition for Viewport Indicator
                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            }
                
                MouseArea { // Allows interaction (clicking, hovering) with the workspace representation.
                id: wsMouse // Identifier for the MouseArea.
                anchors.fill: parent // Makes the MouseArea cover the entire parent (workspaceDelegate).
                hoverEnabled: true // Enables hover detection.
                onClicked: workspace.activate() // When clicked, activates the corresponding Hyprland workspace.
            }

                // Repeater to display individual windows (toplevels) within each workspace.
                Repeater {
                model: workspace.toplevels // The model provides the list of toplevels (windows) for the current workspace.

                delegate: Rectangle { // Each window is represented by a Rectangle.
                    id: winRect // Identifier for each individual window rectangle.
                        property bool ready: false
                        Component.onCompleted: {
                            ready = true
                        }
                        property var client: modelData // Accesses the client (window) data for this delegate.
                        // The 'lastIpcObject' contains raw data from Hyprland IPC, including geometry.
                        property var clientData: client.lastIpcObject

                        // Reference to the monitor to calculate relative positions.
                        property var mon: workspaceDelegate.monitor

                        // Geometry calculations: Extracts and processes window position and size.
                        // Hyprland 'at' and 'size' properties are global coordinates.
                        property real globalX: clientData && clientData.at ? clientData.at[0] : 0
                        property real globalY: clientData && clientData.at ? clientData.at[1] : 0
                        property real w: clientData && clientData.size ? clientData.size[0] : 0
                        property real h: clientData && clientData.size ? clientData.size[1] : 0

                        // Use true workspace bounds from workspaceDelegate instead of monitor.
                        property real totalW: workspaceDelegate.totalWidth
                        property real totalH: workspaceDelegate.totalHeight

                        // Calculate window position relative to the workspace's top-left corner.
                        property real relX: globalX - workspaceDelegate.minX
                        property real relY: globalY - workspaceDelegate.minY

                        // Calculate the target layout dimensions to avoid animation chasing during parent resize
                        property real targetInnerDelegateWidth: (workspaceDelegate.height * workspaceDelegate.targetRatio) - (2 * workspaceDelegate.border.width)
                        property real targetInnerDelegateHeight: workspaceDelegate.height - (2 * workspaceDelegate.border.width)
                        property real winGap: 1 // Defines a small gap between windows within the delegate.

                        // Calculate target X, Y, Width, Height for the scaled window rectangle,
                        // adjusted for delegate borders and window gaps.
                        property real targetX: Math.round((workspaceDelegate.border.width) + ((relX / totalW) * targetInnerDelegateWidth) + winGap)
                        property real targetY: Math.round((workspaceDelegate.border.width) + ((relY / totalH) * targetInnerDelegateHeight) + winGap)
                        property real targetW: Math.round(((w / totalW) * targetInnerDelegateWidth) - (2 * winGap))
                        property real targetH: Math.round(((h / totalH) * targetInnerDelegateHeight) - (2 * winGap))

                    x: targetX // Set the X position of the window rectangle.
                    y: targetY // Set the Y position of the window rectangle.
                    width: targetW // Set the width of the window rectangle.
                    height: targetH // Set the height of the window rectangle.

                        // Smooth transitions for window position and size changes.
                        Behavior on x { enabled: ready; NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        Behavior on y { enabled: ready; NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        Behavior on width { enabled: ready; NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        Behavior on height { enabled: ready; NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (clientData && clientData.address) {
                                    var addr = clientData.address;
                                    if (!addr.startsWith("0x")) addr = "0x" + addr;
                                    Hyprland.dispatch("hl.dsp.focus({ window = 'address:" + addr + "' })");
                                }
                            }
                        }

                        transformOrigin: Item.Center
                        scale: 0
                        NumberAnimation {
                            id: popInAnimation
                            target: winRect
                            property: "scale"
                            to: 1
                            duration: 200
                            easing.type: Easing.OutBack
                            running: true
                        }

                    // Z-order: Tiled back, floating front, recently focused floating on top
                    z: {
                        if (client.active) return 1000;
                        var isFloating = clientData ? clientData.floating : false;
                        var baseZ = isFloating ? 100 : 0;
                        var focusHistory = (clientData && clientData.focusHistoryID !== undefined) ? clientData.focusHistoryID : 99;
                        var focusOffset = Math.max(0, 50 - focusHistory);
                        return baseZ + focusOffset;
                    }

                    // Visibility: Hide the window rectangle if the client data indicates it's hidden (e.g., inactive tab).
                    visible: clientData ? !clientData.hidden : true

                    // Background color changes based on whether the window is active.
                    color: client.active ? Theme.mauve : Theme.surface2 // Mauve if active, Surface2 otherwise..
                    radius: 8 // Rounded corners for the window rectangle.

                        // Icon: Displays the application icon within the window rectangle.
                        IconImage {
                        anchors.centerIn: parent // Centers the icon within its parent (the window rectangle).
                        // Sets the width and height of the icon to be 80% of the smaller dimension of its parent.
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width // Keeps the icon square.

                        // Sets the icon source using the getIcon function defined earlier.
                        // Provides a fallback icon ("application-x-executable") if a specific one isn't found.
                        source: Quickshell.iconPath(root.getIcon(winRect.clientData), "application-x-executable")

                        // Only shows the icon if the window rectangle is large enough to display it clearly.
                        visible: width > 8
                    }
                }
            }
        }
    }
}   
