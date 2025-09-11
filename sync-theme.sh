#!/usr/bin/env bash

# Sync tmux bar theme with current NvChad base46 theme
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$HOME/.cache/tmux-bar-colors"

sync_theme() {
    # Extract colors from NvChad using nvim in headless mode
    if command -v nvim >/dev/null 2>&1; then
        # Run the lua script through nvim to access base46
        nvim --headless --clean -c "luafile $SCRIPT_DIR/nvchad-colors.lua" -c "qa" > "$COLORS_FILE" 2>/dev/null
        
        if [ $? -eq 0 ] && [ -s "$COLORS_FILE" ]; then
            echo "✓ NvChad colors extracted successfully"
            
            # Source the colors and reload tmux
            if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
                source "$COLORS_FILE"
                
                # Set tmux variables with extracted colors
                tmux set-option -g @tmux_power_c0_red "$RED" 2>/dev/null
                tmux set-option -g @tmux_power_c0_green "$GREEN" 2>/dev/null
                tmux set-option -g @tmux_power_c0_yellow "$YELLOW" 2>/dev/null
                tmux set-option -g @tmux_power_c0_blue "$BLUE" 2>/dev/null
                tmux set-option -g @tmux_power_c0_purple "$PURPLE" 2>/dev/null
                tmux set-option -g @tmux_power_c0_gray "$GRAY" 2>/dev/null
                tmux set-option -g @tmux_power_c0_bg "$BG" 2>/dev/null
                tmux set-option -g @tmux_power_c0_block_bg "$BLOCK_BG" 2>/dev/null
                tmux set-option -g @tmux_power_c0_fg "$FG" 2>/dev/null
                
                # Reload tmux config
                tmux source-file "$SCRIPT_DIR/tmux-bar.tmux" 2>/dev/null
                echo "✓ Tmux theme synchronized"
            else
                echo "⚠ Tmux not running, colors cached for next session"
            fi
        else
            echo "✗ Failed to extract colors from NvChad"
            return 1
        fi
    else
        echo "✗ nvim not found"
        return 1
    fi
}

# Auto-detect if we should sync
if [ "$1" = "--auto" ]; then
    # Only sync if colors file doesn't exist or is older than 1 minute
    if [ ! -f "$COLORS_FILE" ] || [ $(find "$COLORS_FILE" -mmin +1 2>/dev/null | wc -l) -gt 0 ]; then
        sync_theme
    fi
else
    sync_theme
fi