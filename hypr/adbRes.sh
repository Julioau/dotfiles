#!/bin/bash

# A script to change android resolution with adb

# Wofi menu
chosen=$(printf "Thether\nSet 1080p\nReset Resolution" | wofi --dmenu --prompt "Android Resolution" --style wofi-style.css --width 250 --height 100)

# Thether connection
if [ "$chosen" == "Thether" ]; then
    adb shell svc usb setFunctions rndis
# Set resolution
elif [ "$chosen" == "Set 1080p" ]; then
    adb shell wm size 1080x1920
# Reset resolution
elif [ "$chosen" == "Reset Resolution" ]; then
    adb shell wm size reset
fi
