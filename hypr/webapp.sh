#!/usr/bin/env bash
# A script to launch a browser in a website or focus it if it's already open.

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
    # Find default browser and launch as an app.
    # Note: The --app flag is specific to Chromium-based browsers.
    BROWSER_EXEC="google-chrome-stable" # Default fallback

    BROWSER_DESKTOP_FILE=$(xdg-settings get default-web-browser)
    if [[ -n "$BROWSER_DESKTOP_FILE" ]]; then
        # Heuristic: try to use the desktop file name as the executable name
        CANDIDATE_EXEC=${BROWSER_DESKTOP_FILE%.desktop}
        if command -v "$CANDIDATE_EXEC" &> /dev/null; then
            BROWSER_EXEC="$CANDIDATE_EXEC"
        fi
    fi
    
    hyprctl dispatch exec "$BROWSER_EXEC --app=$APP_URL"
fi