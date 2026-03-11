#!/usr/bin/env bash

# The number of persistent workspaces per monitor
NUM_WS=${1:-5}

# Function to run the setup script
setup_workspaces() {
    /home/juli/dotfiles/hypr/persistent_workspaces.sh "$NUM_WS"
}

# Run once at startup
setup_workspaces

# Listen to the Hyprland socket for monitor events and react
while read -r line; do
    # When a monitor is added or removed, re-trigger the setup
    case "$line" in
        monitoradded*)
            setup_workspaces
            ;;
        monitorremoved*)
            setup_workspaces
            ;;
    esac
done < <(socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock)
