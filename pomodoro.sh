#!/usr/bin/env bash

# Pomodoro timer for tmux-bar
# State stored in tmux environment variables

WORK_DURATION=1500     # 25 minutes in seconds
SHORT_BREAK=300        # 5 minutes
LONG_BREAK=900         # 15 minutes
POMODOROS_UNTIL_LONG=4 # Number of pomodoros before long break

# Icons
TOMATO_ICON=" "
BREAK_ICON="󰒲 "
PAUSE_ICON="⏸"

tmux_get() {
  local value
  value="$(tmux show -gqv "$1")"
  [ -n "$value" ] && echo "$value" || echo "$2"
}

tmux_set() {
  tmux set-option -gq "$1" "$2"
}

get_state() {
  local state=$(tmux_get "@pomodoro_state" "idle")
  echo "$state"
}

get_start_time() {
  local start=$(tmux_get "@pomodoro_start" "0")
  echo "$start"
}

get_duration() {
  local duration=$(tmux_get "@pomodoro_duration" "$WORK_DURATION")
  echo "$duration"
}

get_pomodoro_count() {
  local count=$(tmux_get "@pomodoro_count" "0")
  echo "$count"
}

format_time() {
  local seconds=$1
  if [ "$seconds" -lt 0 ]; then
    seconds=0
  fi
  local mins=$((seconds / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d" "$mins" "$secs"
}

get_remaining() {
  local state=$(get_state)
  local start=$(get_start_time)
  local duration=$(get_duration)
  local now=$(date +%s)

  if [ "$state" = "idle" ]; then
    echo "0"
    return
  fi

  local elapsed=$((now - start))
  local remaining=$((duration - elapsed))

  if [ "$remaining" -lt 0 ]; then
    remaining=0
  fi

  echo "$remaining"
}

start_work() {
  tmux_set "@pomodoro_state" "work"
  tmux_set "@pomodoro_start" "$(date +%s)"
  tmux_set "@pomodoro_duration" "$WORK_DURATION"
  tmux display-message " Pomodoro started - 25 minutes of focus!"
}

start_short_break() {
  tmux_set "@pomodoro_state" "break"
  tmux_set "@pomodoro_start" "$(date +%s)"
  tmux_set "@pomodoro_duration" "$SHORT_BREAK"
  tmux display-message "󰒲 Short break - 5 minutes to rest"
}

start_long_break() {
  tmux_set "@pomodoro_state" "break"
  tmux_set "@pomodoro_start" "$(date +%s)"
  tmux_set "@pomodoro_duration" "$LONG_BREAK"
  tmux display-message "  Long break - 15 minutes to rest"
}

toggle() {
  local state=$(get_state)
  local remaining=$(get_remaining)

  if [ "$state" = "idle" ]; then
    start_work
  elif [ "$state" = "paused" ]; then
    # Resume from pause
    local pause_duration=$(tmux_get "@pomodoro_pause_duration" "0")
    local new_start=$(($(date +%s) - pause_duration))
    tmux_set "@pomodoro_start" "$new_start"
    tmux_set "@pomodoro_state" "$(tmux_get '@pomodoro_paused_state' 'work')"
    tmux display-message "▶ Resumed"
  elif [ "$remaining" -le 0 ]; then
    # Timer finished, start next phase
    if [ "$state" = "work" ]; then
      local count=$(($(get_pomodoro_count) + 1))
      tmux_set "@pomodoro_count" "$count"

      if [ $((count % POMODOROS_UNTIL_LONG)) -eq 0 ]; then
        start_long_break
      else
        start_short_break
      fi
    else
      start_work
    fi
  else
    # Pause
    local start=$(get_start_time)
    local now=$(date +%s)
    local pause_duration=$((now - start))
    tmux_set "@pomodoro_pause_duration" "$pause_duration"
    tmux_set "@pomodoro_paused_state" "$state"
    tmux_set "@pomodoro_state" "paused"
    tmux display-message "⏸ Paused"
  fi
}

stop() {
  tmux_set "@pomodoro_state" "idle"
  tmux_set "@pomodoro_start" "0"
  tmux_set "@pomodoro_duration" "$WORK_DURATION"
  tmux display-message "⏹ Pomodoro stopped"
}

skip() {
  local state=$(get_state)

  if [ "$state" = "work" ]; then
    local count=$(($(get_pomodoro_count) + 1))
    tmux_set "@pomodoro_count" "$count"

    if [ $((count % POMODOROS_UNTIL_LONG)) -eq 0 ]; then
      start_long_break
    else
      start_short_break
    fi
  elif [ "$state" = "break" ]; then
    start_work
  else
    start_work
  fi
}

status() {
  local state=$(get_state)
  local remaining=$(get_remaining)
  local count=$(get_pomodoro_count)

  if [ "$state" = "idle" ]; then
    echo ""
    return
  fi

  local icon=""
  local time_str=$(format_time "$remaining")

  case "$state" in
  work)
    icon="$TOMATO_ICON"
    ;;
  break)
    icon="$BREAK_ICON"
    ;;
  paused)
    icon="$PAUSE_ICON"
    local paused_state=$(tmux_get "@pomodoro_paused_state" "work")
    [ "$paused_state" = "work" ] && icon="$PAUSE_ICON$TOMATO_ICON" || icon="$PAUSE_ICON$BREAK_ICON"
    local duration=$(get_duration)
    local pause_duration=$(tmux_get "@pomodoro_pause_duration" "0")
    remaining=$((duration - pause_duration))
    time_str=$(format_time "$remaining")
    ;;
  esac

  # Auto-advance when timer hits 0
  if [ "$remaining" -le 0 ] && [ "$state" != "paused" ]; then
    if [ "$state" = "work" ]; then
      count=$((count + 1))
      tmux_set "@pomodoro_count" "$count"

      if [ $((count % POMODOROS_UNTIL_LONG)) -eq 0 ]; then
        start_long_break
      else
        start_short_break
      fi
    else
      start_work
    fi
    remaining=$(get_remaining)
    time_str=$(format_time "$remaining")
  fi

  echo "$icon $time_str"
}

case "$1" in
start)
  start_work
  ;;
toggle)
  toggle
  ;;
stop)
  stop
  ;;
skip)
  skip
  ;;
status)
  status
  ;;
*)
  echo "Usage: $0 {start|toggle|stop|skip|status}"
  exit 1
  ;;
esac
