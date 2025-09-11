#!/usr/bin/env lua

-- Extract current NvChad base46 theme colors and output for tmux
local function get_nvchad_colors()
    -- Check if we can access base46
    local ok, base46 = pcall(require, "base46")
    if not ok then
        print("Error: base46 not found. Make sure you're running this from within NvChad.")
        os.exit(1)
    end
    
    -- Get current theme colors
    local base_30 = base46.get_theme_tb("base_30")
    local base_16 = base46.get_theme_tb("base_16")
    
    if not base_30 or not base_16 then
        print("Error: Could not get theme colors from base46")
        os.exit(1)
    end
    
    -- Map base46 colors to tmux bar color scheme
    local tmux_colors = {
        RED = base_16.base08 or base_30.red or "#fca5a5",
        GREEN = base_16.base0B or base_30.green or "#b5e8b0", 
        YELLOW = base_16.base0A or base_30.yellow or "#e8d4b0",
        BLUE = base_16.base0D or base_30.blue or "#bae6fd",
        PURPLE = base_16.base0E or base_30.purple or "#a5b4fc",
        GRAY = base_30.grey or base_30.light_grey or "#71798b",
        BG = base_30.black or base_16.base00 or "#182030",
        BLOCK_BG = base_30.one_bg or base_30.one_bg2 or "#323948",
        FG = base_30.white or base_16.base05 or "#e0e0e0"
    }
    
    -- Output in shell variable format
    for name, color in pairs(tmux_colors) do
        print(string.format("%s='%s'", name, color))
    end
end

get_nvchad_colors()