import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "Theme.js" as Theme

RowLayout {
    id: root
    spacing: 5 // Tighter spacing for tray items
    property bool debug: false

    Component.onCompleted: {
        if (root.debug) {
            console.log("SystemTrayWidget loaded. Initial count: " + SystemTray.items.values.length);
            for (var i = 0; i < SystemTray.items.values.length; i++) {
                var item = SystemTray.items.values[i];
                console.log("Existing item: " + item.id);
            }
        }
    }

    Connections {
        target: SystemTray.items
        function onObjectInsertedPost(object, index) {
            if (root.debug) console.log("SystemTray: Item inserted at " + index + ": " + object.id);
        }
        function onObjectRemovedPost(object, index) {
            if (root.debug) console.log("SystemTray: Item removed from " + index);
        }
    }

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItemDelegate
            
            property var item: modelData // Access the SystemTrayItem
            
            color: Theme.background
            border.width: 2
            border.color: mouseArea.containsMouse ? Theme.green : "transparent"
            radius: 10

            Component.onCompleted: {
                if (root.debug) console.log("SystemTray: Added item " + item.id + " (Title: " + item.title + ")");
            }
            Component.onDestruction: {
                if (root.debug) console.log("SystemTray: Removed item " + item.id);
            }

            Layout.preferredWidth: 30
            Layout.fillHeight: true
            
            Image {
                anchors.centerIn: parent
                width: 18 // Typical tray icon size
                height: 18
                source: item.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // Menu Anchor for Right Click Context Menu
            QsMenuAnchor {
                id: menuAnchor
                menu: item.menu
                anchor.item: trayItemDelegate
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true

                onClicked: (mouse) => {
                    if (root.debug) console.log("SystemTray: Clicked " + item.id + " Button: " + mouse.button);
                    if (mouse.button === Qt.LeftButton) {
                        item.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (root.debug) console.log("SystemTray: Opening menu for " + item.id);
                        menuAnchor.open();
                    }
                }
            }
        }
    }
}
