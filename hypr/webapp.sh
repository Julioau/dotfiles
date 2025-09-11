#!/usr/bin/env bash
# A script to launch Chrome in a website or focus it if it's already open.

# boilerplate
if [[ $# -ne 2 ]]; then
    # Send a desktop notification about the error.
    # notify-send "Script Error" "Usage: $0 \"<URL>\" \"<Window Title>\""
    exit 1
fi

APP_URL="$1"
WINDOW_TITLE="$2"

# Use jq to find the window address based on its title.
WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg title "$WINDOW_TITLE" '.[] | select(.title == $title) | .address')

# If a window address was found, focus it. Otherwise, launch the new app.
if [[ -n "$WINDOW_ADDRESS" ]]; then
    hyprctl dispatch focuswindow address:"$WINDOW_ADDRESS"
else
    hyprctl dispatch exec "google-chrome-stable --app="$APP_URL""
fi
