#!/bin/bash

# Get the current layout
current_layout=$(hyprctl getoption general:layout | head -n 1 | awk '{print $2}')

# Toggle between layouts
if [ $current_layout == "dwindle" ]; then
  hyprctl keyword general:layout "master"
else
  hyprctl keyword general:layout "dwindle"
fi
