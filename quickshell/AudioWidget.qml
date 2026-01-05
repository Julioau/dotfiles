import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import "Theme.js" as Theme

// AudioWidget.qml: A component that displays audio output (speaker) and input (microphone) status.
// It allows controlling volume and mute state, and shows popups with device descriptions on hover.
RowLayout {
    property string globalFont: "SpaceMono Nerd Font Propo"

    // 2. Audio Output (Speaker) Widget
    Rectangle {
        color: Theme.background // Background color.
        radius: 10 // Rounded corners.
        Layout.fillHeight: true // Fills available height.
        Layout.preferredWidth: speakerText.implicitWidth + 20 // Width based on text content + padding.
        
        // Property to hold the audio object of the default sink, if available.
        property var audio: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio 
                            ? Pipewire.defaultAudioSink.audio 
                            : null
        
        Text {
            id: speakerText // Identifier for the speaker Text element.
            anchors.centerIn: parent // Centers text within its parent.
            // Text color changes if audio is muted.
            color: parent.audio && parent.audio.muted ? Theme.red : Theme.text
            font.family: globalFont // Uses global font.
            text: {
                if (!parent.audio) return "󰝟 --"; // Display 'no audio' icon if no audio object.
                
                var vol = Math.round(parent.audio.volume * 100); // Get volume percentage.
                var icon = "󰕾"; // Default speaker icon.
                
                if (parent.audio.muted) icon = "󰝟"; // Muted icon.
                else if (vol <= 0) icon = "󰝟"; // Muted icon for zero volume.
                else if (vol < 30) icon = "󰕿"; // Low volume icon.
                else if (vol < 70) icon = "󰖀"; // Medium volume icon.
                
                return icon + " " + vol + "%"; // Returns icon and volume percentage.
            }
        }

        MouseArea {
            id: speakerMa // Identifier for the speaker MouseArea.
            anchors.fill: parent // Fills the parent rectangle.
            hoverEnabled: true // Enables hover detection.
            // Toggles mute state on click.
            onClicked: {
                if (parent.audio) parent.audio.muted = !parent.audio.muted;
            }
            // Handles mouse wheel events for volume adjustment.
            onWheel: (wheel) => {
                if (!parent.audio) return;
                var change = 0.05; // Default volume change step.
                if (wheel.angleDelta.y < 0) change = -0.05; // Decrease volume on scroll down.
                
                var newVol = parent.audio.volume + change; // Calculate new volume.
                if (newVol < 0) newVol = 0; // Clamp volume to 0-1.
                if (newVol > 1.0) newVol = 1.0;
                
                parent.audio.volume = newVol; // Set new volume.
            }
            
            // Displays a popup on hover.
            PopupWindow {
                anchor.edges: Edges.Bottom // Anchors popup to the bottom edge.
                anchor.gravity: Edges.Bottom // Specifies gravity for bottom edge.
                anchor.item: speakerMa // Anchors relative to the speaker MouseArea.
                
                visible: speakerMa.containsMouse // Popup is visible only when mouse hovers.
                implicitWidth: volPopupContent.implicitWidth // Width matches content.
                implicitHeight: volPopupContent.implicitHeight // Height matches content.
                color: Theme.transparent // Transparent background for the popup window itself.
                
                Rectangle { // Content of the popup.
                    id: volPopupContent // Identifier for popup content background.
                    color: Theme.background // Background color.
                    radius: 5 // Rounded corners.
                    border.color: Theme.surface0 // Border color.
                    border.width: 1 // Border width.
                    
                    implicitWidth: volPopupText.implicitWidth + 16 // Width based on text + padding.
                    implicitHeight: volPopupText.implicitHeight + 16 // Height based on text + padding.
                    
                    Text {
                        id: volPopupText // Identifier for popup text.
                        anchors.centerIn: parent // Centers text.
                        // Displays the description of the audio sink or "No Output".
                        text: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.description : "No Output"
                        color: Theme.text // Text color.
                        font.family: globalFont // Uses global font.
                    }
                }
            }
        }
    }

    // 2.1 Audio Input (Mic) Widget - Similar in structure to the Audio Output widget.
    Rectangle {
        color: Theme.background // Background color.
        radius: 10 // Rounded corners.
        Layout.fillHeight: true // Fills available height.
        Layout.preferredWidth: micText.implicitWidth + 20 // Width based on text content + padding.
        
        visible: Pipewire.defaultAudioSource != null // Only visible if a default audio source is available.

        // Property to hold the audio object of the default source, if available.
        property var audio: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio 
                            ? Pipewire.defaultAudioSource.audio 
                            : null

        Text {
            id: micText // Identifier for the mic Text element.
            anchors.centerIn: parent // Centers text within its parent.
            // Text color changes if audio is muted.
            color: parent.audio && parent.audio.muted ? Theme.red : Theme.text
            font.family: globalFont // Uses global font.
            text: {
                if (!parent.audio) return "󰍭 --"; // Display 'no audio' icon if no audio object.
                
                var vol = Math.round(parent.audio.volume * 100); // Get volume percentage.
                var icon = parent.audio.muted ? "󰍭" : "󰍬"; // Muted or active mic icon.
                
                return icon + " " + vol + "%"; // Returns icon and volume percentage.
            }
        }

        MouseArea {
            id: micMa // Identifier for the mic MouseArea.
            anchors.fill: parent // Fills the parent rectangle.
            hoverEnabled: true // Enables hover detection.
            // Toggles mute state on click.
            onClicked: {
                if (parent.audio) parent.audio.muted = !parent.audio.muted;
            }
            // Handles mouse wheel events for volume adjustment.
            onWheel: (wheel) => {
                if (!parent.audio) return;
                var change = 0.05; // Default volume change step.
                if (wheel.angleDelta.y < 0) change = -0.05; // Decrease volume on scroll down.
                
                var newVol = parent.audio.volume + change; // Calculate new volume.
                if (newVol < 0) newVol = 0; // Clamp volume to 0-1.
                if (newVol > 1.0) newVol = 1.0;
                
                parent.audio.volume = newVol; // Set new volume.
            }

            // Displays a popup on hover.
            PopupWindow {
                anchor.edges: Edges.Bottom // Anchors popup to the bottom edge.
                anchor.gravity: Edges.Bottom // Specifies gravity for bottom edge.
                anchor.item: micMa // Anchors relative to the mic MouseArea.
                
                visible: micMa.containsMouse // Popup is visible only when mouse hovers.
                implicitWidth: micPopupContent.implicitWidth // Width matches content.
                implicitHeight: micPopupContent.implicitHeight // Height matches content.
                color: Theme.transparent // Transparent background for the popup window itself.
                
                Rectangle { // Content of the popup.
                    id: micPopupContent // Identifier for popup content background.
                    color: Theme.background // Background color.
                    radius: 5 // Rounded corners.
                    border.color: Theme.surface0 // Border color.
                    border.width: 1 // Border width.
                    
                    implicitWidth: micPopupText.implicitWidth + 16 // Width based on text + padding.
                    implicitHeight: micPopupText.implicitHeight + 16 // Height based on text + padding.
                    
                    Text {
                        id: micPopupText // Identifier for popup text.
                        anchors.centerIn: parent // Centers text.
                        // Displays the description of the audio source or "No Input".
                        text: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.description : "No Input"
                        color: Theme.text // Text color.
                        font.family: globalFont // Uses global font.
                    }
                }
            }
        }
    }
}