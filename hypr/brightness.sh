#!/bin/bash

# --- CONFIGURE YOUR DISPLAYS HERE ---
# Internal laptop display
LAPTOP_DEVICE="intel_backlight" # Found with 'brightnessctl -l'
LAPTOP_MAX_BRIGHTNESS=100       # The dimmest display (usually 100%)

# First external monitor (the 23" in your case)
MONITOR1_BUS=10                 # Bus number from 'ddcutil detect'
MONITOR1_MAX_BRIGHTNESS=85      # The middle brightness (e.g., 85% of its max)

# Second external monitor (the 27" in your case)
MONITOR2_BUS=9                  # Bus number from 'ddcutil detect'
MONITOR2_MAX_BRIGHTNESS=70      # The brightest display, so we cap it lower (e.g., 70%)

# The percentage step for each key press
STEP=5
# --- END CONFIGURATION ---

# Get current brightness percentage of the laptop display
CURRENT_PERCENT=$(brightnessctl -m -d "$LAPTOP_DEVICE" | awk -F, '{print substr($4, 0, length($4)-1)}')

# Calculate the new target percentage
if [ "$1" == "up" ]; then
  NEW_PERCENT=$((CURRENT_PERCENT + STEP))
else
  NEW_PERCENT=$((CURRENT_PERCENT - STEP))
fi

# Clamp the new percentage between 0 and 100
if (( NEW_PERCENT > 100 )); then NEW_PERCENT=100; fi
if (( NEW_PERCENT < 0 )); then NEW_PERCENT=0; fi

# 1. Set internal display brightness
brightnessctl -q -d "$LAPTOP_DEVICE" set "${NEW_PERCENT}%"

# 2. Calculate and set brightness for the first external monitor
MONITOR1_VALUE=$((MONITOR1_MAX_BRIGHTNESS * NEW_PERCENT / 100))
ddcutil --bus "$MONITOR1_BUS" setvcp 0x10 "$MONITOR1_VALUE"

# 3. Calculate and set brightness for the second external monitor
MONITOR2_VALUE=$((MONITOR2_MAX_BRIGHTNESS * NEW_PERCENT / 100))
ddcutil --bus "$MONITOR2_BUS" setvcp 0x10 "$MONITOR2_VALUE"