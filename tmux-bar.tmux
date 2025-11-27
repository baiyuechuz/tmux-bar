#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Store plugin directory for external tools (e.g., nvchad theme sync)
tmux set-option -gq @tmux_bar_dir "$CURRENT_DIR"

tmux_get() {
  local value
  value="$(tmux show -gqv "$1")"
  [ -n "$value" ] && echo "$value" || echo "$2"
}

tmux_set() {
  tmux set-option -gq "$1" "$2"
}

# Load colors from nvchad (single perl call for speed)
load_colors() {
  local colors_file="$HOME/.local/share/nvim/base46/colors"
  local stl_file="$HOME/.local/share/nvim/base46/statusline"
  
  if [[ -f "$colors_file" && -f "$stl_file" ]]; then
    eval "$(perl -e '
      open my $cf, "<", $ARGV[0] or die;
      binmode $cf;
      my $colors = do { local $/; <$cf> };
      close $cf;
      while ($colors =~ /([a-z_]+)\x0c(#[0-9A-Fa-f]{6})/gi) {
        my ($k, $v) = ($1, $2);
        print "RED=$v\n" if $k eq "red";
        print "GREEN=$v\n" if $k eq "green";
        print "BLUE=$v\n" if $k eq "blue";
        print "PURPLE=$v\n" if $k eq "purple";
        print "FG=$v\n" if $k eq "white";
      }
      open my $sf, "<", $ARGV[1] or die;
      binmode $sf;
      my $stl = do { local $/; <$sf> };
      close $sf;
      if ($stl =~ /fg\x0c(#[0-9A-Fa-f]{6})\x07bg\x0c(#[0-9A-Fa-f]{6})\x0fStatusLine/s) {
        print "GRAY=$1\n";
        print "BG=$2\n";
      }
      if ($stl =~ /fg\x0c#[0-9A-Fa-f]{6}\x07bg\x0c(#[0-9A-Fa-f]{6})\x0bSt_cwd/s) {
        print "BLOCK_BG=$1\n";
      }
    ' "$colors_file" "$stl_file")"
  fi

  # Tundra defaults (fallback)
  RED="${RED:-#FCA5A5}"
  GREEN="${GREEN:-#B5E8B0}"
  BLUE="${BLUE:-#A5B4FC}"
  PURPLE="${PURPLE:-#BDB0E4}"
  GRAY="${GRAY:-#5f6675}"
  BG="${BG:-#171e2d}"
  BLOCK_BG="${BLOCK_BG:-#323948}"
  FG="${FG:-#FFFFFF}"
}

load_colors

# Icons
rarrow=$(tmux_get '@tmux_bar_right_arrow_icon' '▌')
larrow=$(tmux_get '@tmux_bar_left_arrow_icon' '▐')
session_icon="$(tmux_get '@tmux_bar_session_icon' '')"
user_icon="$(tmux_get '@tmux_bar_user_icon' '󰀘')"
time_icon="$(tmux_get '@tmux_bar_time_icon' '󰔟')"
date_icon="$(tmux_get '@tmux_bar_date_icon' '')"
git_icon="$(tmux_get '@tmux_bar_git_icon' '')"
cwd_icon="$(tmux_get '@tmux_bar_cwd_icon' '')"

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
tmux_set window-status-format "#[fg=$GRAY] #W"
tmux_set window-status-current-format "#[fg=$BLUE,bold] #W"
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
