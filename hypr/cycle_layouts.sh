#!/usr/bin/env bash

# Define the layouts available in Hyprland 0.54
LAYOUTS=("dwindle" "master" "scrolling" "monocle")

# Get the layout of the currently active workspace
CURRENT_LAYOUT=$(hyprctl -j activeworkspace | jq -r '.tiledLayout')

# Default index in case something goes wrong
CURRENT_INDEX=0

# Find the index of the current layout
for i in "${!LAYOUTS[@]}"; do
    if [[ "${LAYOUTS[$i]}" == "$CURRENT_LAYOUT" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Calculate the next index depending on direction
if [[ "$1" == "prev" ]]; then
    NEXT_INDEX=$(( (CURRENT_INDEX - 1 + ${#LAYOUTS[@]}) % ${#LAYOUTS[@]} ))
else
    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#LAYOUTS[@]} ))
fi

NEXT_LAYOUT="${LAYOUTS[$NEXT_INDEX]}"

# Get the current workspace ID
WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')

# Apply the new layout to the current workspace
hyprctl keyword workspace "$WORKSPACE_ID,layout:$NEXT_LAYOUT"
