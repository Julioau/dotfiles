#!/usr/bin/bash

cliphist list | SHELL=/bin/bash fzf \
    --no-sort \
    -d $'	' \
    --with-nth 2 \
    --bind "esc:abort+execute(kitty icat --clear)" \
    --bind "enter:accept+execute(kitty icat --clear)" \
    --preview '
        id=$(echo {} | cut -f1)
        if echo {} | grep -q "\[\[ binary data"; then
            exec cliphist decode "$id" | kitty +kitten icat --clear --transfer-mode=memory --stdin=yes --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0
        else
            # Use printf to send the raw "clear image" escape code and the decoded
            # text in a single, atomic command.
            printf "\x1b_Ga=d,d=A\x1b\\%s" "$(cliphist decode "$id")"
        fi
    ' \
    --preview-window 'right:50%:wrap' | cut -f1 -d $'	' | xargs -r cliphist decode | wl-copy

# Forcefully close the kitty window this script is running in.
# This is needed because of a lingering `kitten` process that prevents auto-closing.
if [ -n "$KITTY_WINDOW_ID" ]; then
    kitty @ close-window --match "id:$KITTY_WINDOW_ID"
fi
