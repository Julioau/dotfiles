#!/bin/bash

player_status=$(playerctl status)

if [[ "$player_status" == "Playing" ]]; then
    title=$(playerctl metadata --format '{{title}}')
    artist=$(playerctl metadata --format '{{artist}}')

    title="${title%(*}"  # Remove from last '(' to end
    title="${title%% (*}" # Remove from first ' (' to end

    # Remove "ft." and anything after it from the title
    title="${title%% ft.*}"

    #Remove leading/trailing whitespace from title
    title="${title#"${title%%[^[:space:]]*}"}" #remove leading
    title="${title%"${title##*[![:space:]]*}"}" #remove trailing
    echo "$title 󰎈  $artist" 
else 
    echo "󰎊"
fi
