#!/usr/bin/env bash
# Reload tmux-bar to sync with nvchad theme
# Call this from nvchad after theme change

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -n "$TMUX" ]]; then
  tmux source-file "$PLUGIN_DIR/tmux-bar.tmux"
fi
