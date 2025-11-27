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

# Parse color from nvchad base46 cache
parse_nvchad_color() {
  local color_name="$1"
  local colors_file="$HOME/.local/share/nvim/base46/colors"
  if [[ -f "$colors_file" ]]; then
    grep -oP "${color_name}#[0-9A-Fa-f]{6}" "$colors_file" | head -1 | grep -oP '#[0-9A-Fa-f]{6}'
  fi
}

# Load colors from nvchad or use tundra defaults
load_colors() {
  local nvchad_colors="$HOME/.local/share/nvim/base46/colors"
  
  if [[ -f "$nvchad_colors" ]]; then
    RED=$(parse_nvchad_color "red")
    GREEN=$(parse_nvchad_color "green")
    BLUE=$(parse_nvchad_color "blue")
    PURPLE=$(parse_nvchad_color "purple")
    GRAY=$(parse_nvchad_color "grey")
    BG=$(parse_nvchad_color "black")
    BLOCK_BG=$(parse_nvchad_color "one_bg3")
    FG=$(parse_nvchad_color "white")
  fi

  # Tundra defaults (fallback)
  RED="${RED:-#FCA5A5}"
  GREEN="${GREEN:-#B5E8B0}"
  BLUE="${BLUE:-#A5B4FC}"
  PURPLE="${PURPLE:-#BDB0E4}"
  GRAY="${GRAY:-#3e4554}"
  BG="${BG:-#111827}"
  BLOCK_BG="${BLOCK_BG:-#323948}"
  FG="${FG:-#FFFFFF}"
}

load_colors

# Icons
rarrow=$(tmux_get '@tmux_bar_right_arrow_icon' '▌')
larrow=$(tmux_get '@tmux_bar_left_arrow_icon' '▐')
session_icon="$(tmux_get '@tmux_bar_session_icon' '')"
user_icon="$(tmux_get '@tmux_bar_user_icon' '󰀘')"
time_icon="$(tmux_get '@tmux_bar_time_icon' '󰔟')"
date_icon="$(tmux_get '@tmux_bar_date_icon' '')"
git_icon="$(tmux_get '@tmux_bar_git_icon' '')"
cwd_icon="$(tmux_get '@tmux_bar_cwd_icon' '')"

# Display options
show_user="$(tmux_get @tmux_bar_show_user true)"
show_host="$(tmux_get @tmux_bar_show_host true)"
show_session="$(tmux_get @tmux_bar_show_session true)"
show_git="$(tmux_get @tmux_bar_show_git false)"
show_cwd="$(tmux_get @tmux_bar_show_cwd true)"
time_format=$(tmux_get @tmux_bar_time_format '%T')
date_format=$(tmux_get @tmux_bar_date_format '%F')
refresh_interval=$(tmux_get @tmux_bar_refresh_interval 1)

# Status options
tmux_set status-interval "$refresh_interval"
tmux_set status on

# Basic status bar colors
tmux_set status-style "fg=$FG,bg=$BG"

# Left side of status bar
tmux_set status-left-length 150

LS=""

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

# Current directory
if "$show_cwd"; then
  RS="$RS#[fg=$BLUE,bg=$BG] $cwd_icon #{b:pane_current_path} "
fi

# Time and date
RS="$RS#[fg=$BG]$larrow#[fg=$GRAY,bg=$BG] $time_icon $time_format #[fg=$BG,bg=$BG]$larrow#[fg=$RED,bg=$BLOCK_BG] $date_icon $date_format "

tmux_set status-right "$RS"

# Window status
tmux_set window-status-format "#[fg=$GRAY] #W"
tmux_set window-status-current-format "#[fg=$BLUE,bold] #W"
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
