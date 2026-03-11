#!/usr/bin/env bash

# Number of persistent workspaces per monitor (default to 5 if not provided)
NUM_WS=${1:-5}

# Get list of monitor names
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

WS_INDEX=1
for mon in $MONITORS; do
    for ((i=1; i<=NUM_WS; i++)); do
        hyprctl keyword workspace "$WS_INDEX, monitor:$mon, persistent:true"
        ((WS_INDEX++))
    done
done
