#!/bin/bash
#
# A smarter OCR script that conditionally resizes small images for better accuracy.
# Handles different system locales and uses modern ImageMagick 7 syntax.
#
# Dependencies: grim, slurp, imagemagick, tesseract, wl-copy

# --- CONFIGURATION ---
RESIZE_THRESHOLD=1200
DEFAULT_LANG="eng"

# --- SCRIPT LOGIC ---
LANG=${1:-$DEFAULT_LANG}
echo $LANG

# 1. Capture the screen geometry.
geometry=$(slurp -d)

# 2. If slurp was cancelled, exit.
if [ -z "$geometry" ]; then
    exit 0
fi

# 3. Extract the width from the geometry string.
width=$(echo "$geometry" | cut -d'x' -f1)

# 4. FIX #1: Sanitize the width to handle locales that use a comma decimal separator.
# This removes the comma and anything after it (e.g., "1493,238" becomes "1493").
width=${width%%,*}

# 5. Prepare the resize options.
resize_opts=()
if [ "$width" -lt "$RESIZE_THRESHOLD" ]; then
    resize_opts=(-resize 200%)
fi

# 6. Run the full pipeline.
# FIX #2: Use `magick` for modern ImageMagick v7+ instead of the deprecated `convert`.
grim -g "$geometry" - | \
magick png:- -colorspace gray -normalize "${resize_opts[@]}" png:- | \
tesseract stdin stdout -l "$LANG" --psm 6 2>/dev/null | \
sed -E ':a;N;$!ba;s/\n+/\n/g' | \
sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//' | \
wl-copy