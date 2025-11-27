#!/usr/bin/env bash

tmux_get() {
  local value
  value="$(tmux show -gqv "$1")"
  [ -n "$value" ] && echo "$value" || echo "$2"
}

tmux_set() {
  tmux set-option -gq "$1" "$2"
}

# Icons
rarrow=$(tmux_get '@tmux_power_right_arrow_icon' '▌')
larrow=$(tmux_get '@tmux_power_left_arrow_icon' '▐')
session_icon="$(tmux_get '@tmux_power_session_icon' '')"
user_icon="$(tmux_get '@tmux_power_user_icon' '󰀘 ')"
time_icon="$(tmux_get '@tmux_power_time_icon' '')"
date_icon="$(tmux_get '@tmux_power_date_icon' '')"

# Display options
show_user="$(tmux_get @tmux_power_show_user true)"
show_host="$(tmux_get @tmux_power_show_host true)"
show_session="$(tmux_get @tmux_power_show_session true)"
time_format=$(tmux_get @tmux_power_time_format '%T')
date_format=$(tmux_get @tmux_power_date_format '%F')

# Colors
RED=$(tmux_get @tmux_power_red "#fca5a5")
GREEN=$(tmux_get @tmux_power_green "#b5e8b0")
BLUE=$(tmux_get @tmux_power_blue "#bae6fd")
PURPLE=$(tmux_get @tmux_power_purple "#a5b4fc")
GRAY=$(tmux_get @tmux_power_gray "#71798b")
BG=$(tmux_get @tmux_power_bg "#182030")
BLOCK_BG=$(tmux_get @tmux_power_block_bg "#323948")
FG=$(tmux_get @tmux_power_fg "#e0e0e0")

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-bg "$BG"
tmux_set status-fg "$FG"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$FG,bg=$BLOCK_BG,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$FG]#[bg=$BLOCK_BG]$larrow#[bg=$FG]#[fg=$BLOCK_BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$FG]#[bg=$BLOCK_BG]$rarrow"

# Left side of status bar
tmux_set status-left-bg "$BLOCK_BG"
tmux_set status-left-length 150

LS=""
if "$show_user" && "$show_host"; then
  LS="#[fg=$PURPLE,bg=$BLOCK_BG] $user_icon $(whoami)@#h #[fg=$BG,bg=$BG,nobold]$rarrow"
elif "$show_user"; then
  LS="#[fg=$PURPLE,bg=$BLOCK_BG] $user_icon $(whoami) #[fg=$BG,bg=$BG,nobold]$rarrow"
elif "$show_host"; then
  LS="#[fg=$PURPLE,bg=$BLOCK_BG] #h #[fg=$BG,bg=$BG,nobold]$rarrow"
fi

if "$show_session"; then
  LS="$LS#[fg=$GREEN,bg=$BG] $session_icon #S "
fi

tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$BLOCK_BG"
tmux_set status-right-length 150
tmux_set status-right "#[fg=$BG]$larrow#[fg=$GRAY,bg=$BG] $time_icon $time_format #[fg=$BG,bg=$BG]$larrow#[fg=$RED,bg=$BLOCK_BG] $date_icon $date_format "

# Window status
tmux_set window-status-format "#[fg=$GRAY]   #W"
tmux_set window-status-current-format "#[fg=$BLUE]   #W"
tmux_set window-status-style "fg=$GRAY,bg=$BG,none"
tmux_set window-status-last-style "fg=$GRAY,bg=$BG,bold"
tmux_set window-status-activity-style "fg=$GRAY,bg=$BG,bold"
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=$GRAY,bg=default"
tmux_set pane-active-border-style "fg=$FG,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$FG"
tmux_set display-panes-active-colour "$BG"

# Clock mode
tmux_set clock-mode-colour "$BG"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$FG,bg=$BG"
tmux_set message-command-style "fg=$FG,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$BG,fg=$FG"
