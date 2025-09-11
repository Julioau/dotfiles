if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
end

function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (echo $argv[1] | trim-right /)
        set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

if functions --query _natural_selection
  bind escape            '_natural_selection end-selection'
  bind ctrl-r            '_natural_selection history-pager'
  bind up                '_natural_selection up-or-search'
  bind down              '_natural_selection down-or-search'
  bind left              '_natural_selection backward-char'
  bind right             '_natural_selection forward-char'
  bind shift-left        '_natural_selection backward-char --is-selecting'
  bind shift-right       '_natural_selection forward-char --is-selecting'
  # bind super-left        '_natural_selection beginning-of-line'
  # bind super-right       '_natural_selection end-of-line'
  # bind super-shift-left  '_natural_selection beginning-of-line --is-selecting'
  # bind super-shift-right '_natural_selection end-of-line --is-selecting'
  bind alt-left          '_natural_selection backward-word'
  bind alt-right         '_natural_selection forward-word'
  bind alt-shift-left    '_natural_selection backward-word --is-selecting'
  bind alt-shift-right   '_natural_selection forward-word --is-selecting'
  bind delete            '_natural_selection delete-char'
  bind backspace         '_natural_selection backward-delete-char'
  # bind super-delete      '_natural_selection kill-line'
  # bind super-backspace   '_natural_selection backward-kill-line'
  bind alt-backspace     '_natural_selection backward-kill-word'
  bind alt-delete        '_natural_selection kill-word'
  bind ctrl-c           '_natural_selection copy-to-clipboard'
  bind ctrl-x           '_natural_selection cut-to-clipboard'
  bind ctrl-v           '_natural_selection paste-from-clipboard'
  bind ctrl-a           '_natural_selection select-all'
  bind ctrl-z           '_natural_selection undo'
  bind ctrl-shift-z     '_natural_selection redo'
  bind ''                kill-selection end-selection self-insert
end