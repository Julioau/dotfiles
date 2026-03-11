#!/usr/bin/env bash

# Number of workspaces to generate keybindings for (default: 5)
NUM_WS=${1:-5}

CONF_FILE="$(dirname "$0")/workspace_binds.conf"

echo "# Generated Workspace Binds (Num: $NUM_WS)" > "$CONF_FILE"
echo "" >> "$CONF_FILE"

for ((i=1; i<=NUM_WS; i++)); do
    key=$i
    if [ "$i" -eq 10 ]; then
        key=0
    fi
    # Only map keys 1-9 and 0 (for 10)
    if [ "$i" -gt 10 ]; then
        break
    fi
    echo "bind = \$mainMod, $key, workspace, r~$i" >> "$CONF_FILE"
done

echo "" >> "$CONF_FILE"

for ((i=1; i<=NUM_WS; i++)); do
    key=$i
    if [ "$i" -eq 10 ]; then
        key=0
    fi
    if [ "$i" -gt 10 ]; then
        break
    fi
    echo "bind = \$mainMod SHIFT, $key, movetoworkspace, r~$i" >> "$CONF_FILE"
done

echo "Workspace keybinds for $NUM_WS workspaces generated in $CONF_FILE"
