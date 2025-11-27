#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux_get() {
  local value
  value="$(tmux show -gqv "$1")"
  [ -n "$value" ] && echo "$value" || echo "$2"
}

tmux_set() {
  tmux set-option -gq "$1" "$2"
}

# Theme presets
apply_theme() {
  local theme="$1"
  case "$theme" in
  catppuccin)
    RED="#f38ba8"
    GREEN="#a6e3a1"
    BLUE="#89b4fa"
    PURPLE="#cba6f7"
    GRAY="#6c7086"
    BG="#1e1e2e"
    BLOCK_BG="#313244"
    FG="#cdd6f4"
    ;;
  nord)
    RED="#bf616a"
    GREEN="#a3be8c"
    BLUE="#81a1c1"
    PURPLE="#b48ead"
    GRAY="#4c566a"
    BG="#2e3440"
    BLOCK_BG="#3b4252"
    FG="#eceff4"
    ;;
  gruvbox)
    RED="#fb4934"
    GREEN="#b8bb26"
    BLUE="#83a598"
    PURPLE="#d3869b"
    GRAY="#665c54"
    BG="#282828"
    BLOCK_BG="#3c3836"
    FG="#ebdbb2"
    ;;
  tokyonight)
    RED="#f7768e"
    GREEN="#9ece6a"
    BLUE="#7aa2f7"
    PURPLE="#bb9af7"
    GRAY="#565f89"
    BG="#1a1b26"
    BLOCK_BG="#24283b"
    FG="#c0caf5"
    ;;
  *)
    RED=$(tmux_get @tmux_bar_red "#fca5a5")
    GREEN=$(tmux_get @tmux_bar_green "#b5e8b0")
    BLUE=$(tmux_get @tmux_bar_blue "#bae6fd")
    PURPLE=$(tmux_get @tmux_bar_purple "#a5b4fc")
    GRAY=$(tmux_get @tmux_bar_gray "#71798b")
    BG=$(tmux_get @tmux_bar_bg "#182030")
    BLOCK_BG=$(tmux_get @tmux_bar_block_bg "#323948")
    FG=$(tmux_get @tmux_bar_fg "#e0e0e0")
    ;;
  esac
}

# Load theme
theme=$(tmux_get @tmux_bar_theme "default")
apply_theme "$theme"

# Icons
rarrow=$(tmux_get '@tmux_bar_right_arrow_icon' '▌')
larrow=$(tmux_get '@tmux_bar_left_arrow_icon' '▐')
session_icon="$(tmux_get '@tmux_bar_session_icon' '')"
user_icon="$(tmux_get '@tmux_bar_user_icon' '󰀘')"
time_icon="$(tmux_get '@tmux_bar_time_icon' '󰔟')"
date_icon="$(tmux_get '@tmux_bar_date_icon' '')"
git_icon="$(tmux_get '@tmux_bar_git_icon' '')"
prefix_icon="$(tmux_get '@tmux_bar_prefix_icon' ' 󱙝')"

# Display options
show_user="$(tmux_get @tmux_bar_show_user true)"
show_host="$(tmux_get @tmux_bar_show_host true)"
show_session="$(tmux_get @tmux_bar_show_session true)"
show_git="$(tmux_get @tmux_bar_show_git true)"
time_format=$(tmux_get @tmux_bar_time_format '%T')
date_format=$(tmux_get @tmux_bar_date_format '%F')
refresh_interval=$(tmux_get @tmux_bar_refresh_interval 1)

# Status options
tmux_set status-interval "$refresh_interval"
tmux_set status on

# Basic status bar colors (using status-style instead of deprecated status-attr)
tmux_set status-style "fg=$FG,bg=$BG"

# Left side of status bar
tmux_set status-left-length 150

LS=""

# Prefix indicator
LS="#[fg=$RED,bg=$BG]#{?client_prefix,$prefix_icon ,}"

# user@host
if "$show_user" && "$show_host"; then
  LS="$LS#[fg=$PURPLE,bg=$BLOCK_BG] $user_icon #(whoami)@#h #[fg=$BG,bg=$BG,nobold]$rarrow"
elif "$show_user"; then
  LS="$LS#[fg=$PURPLE,bg=$BLOCK_BG] $user_icon #(whoami) #[fg=$BG,bg=$BG,nobold]$rarrow"
elif "$show_host"; then
  LS="$LS#[fg=$PURPLE,bg=$BLOCK_BG] #h #[fg=$BG,bg=$BG,nobold]$rarrow"
fi

# Session
if "$show_session"; then
  LS="$LS#[fg=$GREEN,bg=$BG] $session_icon #S "
fi

# Git branch
if "$show_git"; then
  LS="$LS#[fg=$PURPLE,bg=$BG] $git_icon #(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-') "
fi

tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-length 150

RS=""

# Time and date
RS="$RS#[fg=$BG]$larrow#[fg=$GRAY,bg=$BG] $time_icon $time_format #[fg=$BG,bg=$BG]$larrow#[fg=$RED,bg=$BLOCK_BG] $date_icon $date_format "

tmux_set status-right "$RS"

# Window status with index
tmux_set window-status-format "#[fg=$GRAY] #W"
tmux_set window-status-current-format "#[fg=$BLUE,bold] #W"
tmux_set window-status-style "fg=$GRAY,bg=$BG"
tmux_set window-status-last-style "fg=$GRAY,bg=$BG,bold"
tmux_set window-status-activity-style "fg=$RED,bg=$BG,bold"
tmux_set window-status-bell-style "fg=$RED,bg=$BG,bold"
tmux_set window-status-separator " "

# Pane border
tmux_set pane-border-style "fg=$GRAY,bg=default"
tmux_set pane-active-border-style "fg=$BLUE,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$GRAY"
tmux_set display-panes-active-colour "$BLUE"

# Clock mode
tmux_set clock-mode-colour "$BLUE"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$FG,bg=$BG"
tmux_set message-command-style "fg=$FG,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$BLOCK_BG,fg=$FG"
