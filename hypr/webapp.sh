#!/usr/bin/env bash
# A script to launch Chrome in a website or focus it if it's already open.

# boilerplate
if [[ $# -ne 1 ]]; then
    # Send a desktop notification about the error.
    # notify-send "Script Error" "Usage: $0 \"<URL>\""
    exit 1
fi

APP_URL="$1"
# Generate the window title using sed.
# 1. Remove "https://".
# 2. Replace the first "/" with "_/".
WINDOW_TITLE=$(echo "$APP_URL" | sed -e 's/https:\/\///' -e 's/\//_\//')

# Use jq to find the window address based on its title.
WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg initialTitle "$WINDOW_TITLE" '.[] | 
select(.initialTitle == $initialTitle) | .address')

# If a window address was found, focus it. Otherwise, launch the new app.
if [[ -n "$WINDOW_ADDRESS" ]]; then
    hyprctl dispatch focuswindow address:"$WINDOW_ADDRESS"
else
    hyprctl dispatch exec "google-chrome-stable --app=$APP_URL"
fi