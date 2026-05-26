#!/bin/bash

# Usage: ./adBat.sh [connected|disconnected]
# This script sends an IPC message to Quickshell to update the phone connection status.

STATUS=$1

# Dynamically find the active user ID and Name from loginctl
SESSION_ID=$(loginctl list-sessions --no-legend | awk '{print $1}' | head -n1)
USER_ID=$(loginctl show-session -p User --value $SESSION_ID)
TARGET_USER=$(loginctl show-session -p Name --value $SESSION_ID)

if [ -z "$TARGET_USER" ]; then
    USER_ID="1000" # Fallback to common UID
    TARGET_USER=$(id -un 1000) # Get username for UID 1000
fi

# Udev runs as root, so we must set the environment to talk to the user's session
export XDG_RUNTIME_DIR="/run/user/$USER_ID"

# Find the PID of the running quickshell instance
# We search for 'qs' or 'quickshell' processes owned by the user
QS_PID=$(pgrep -u $TARGET_USER -x "qs" || pgrep -u $TARGET_USER -x "quickshell" | head -n1)

if [ -z "$QS_PID" ]; then
    # Fallback: try pgrep with -f for arguments if exact match fails
    QS_PID=$(pgrep -u $TARGET_USER -f "quickshell" | head -n1)
fi

if [ -z "$QS_PID" ]; then
    echo "Error: No running Quickshell instance found."
    exit 1
fi

# Construct the Quickshell command
# Using --pid to target the specific running process ID
CMD="quickshell ipc --pid $QS_PID call bar setPhoneConnected"

if [ "$STATUS" == "connected" ]; then
    # Run the command as the specific user
    /usr/bin/sudo -u $TARGET_USER XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" $CMD true
elif [ "$STATUS" == "disconnected" ]; then
    /usr/bin/sudo -u $TARGET_USER XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" $CMD false
else
    echo "Usage: $0 [connected|disconnected]"
    exit 1
fi
