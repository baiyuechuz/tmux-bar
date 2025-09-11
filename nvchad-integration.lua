-- NvChad integration for automatic tmux theme syncing
-- Add this to your NvChad config (e.g., ~/.config/nvim/lua/configs/tmux-sync.lua)

local M = {}

-- Path to the sync script
local sync_script = vim.fn.expand("~") .. "/Projects/tmux-bar/sync-theme.sh"

-- Function to sync tmux theme
local function sync_tmux_theme()
    -- Run sync script asynchronously
    vim.fn.jobstart({ sync_script, "--auto" }, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                vim.notify("Tmux theme synchronized", vim.log.levels.INFO, { title = "Theme Sync" })
            end
        end,
    })
end

-- Set up autocommand for theme changes
local function setup_autocmds()
    local group = vim.api.nvim_create_augroup("TmuxThemeSync", { clear = true })
    
    -- Sync when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
            -- Small delay to ensure base46 has updated
            vim.defer_fn(sync_tmux_theme, 100)
        end,
    })
    
    -- Also sync on NvChad theme switch (if using base46 directly)
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "Base46ThemeChange",
        callback = function()
            vim.defer_fn(sync_tmux_theme, 100)
        end,
    })
end

-- Command to manually sync
vim.api.nvim_create_user_command("TmuxSyncTheme", sync_tmux_theme, {
    desc = "Sync tmux theme with current NvChad theme"
})

-- Setup function
function M.setup()
    -- Check if sync script exists
    if vim.fn.executable(sync_script) == 1 then
        setup_autocmds()
        
        -- Initial sync when Neovim starts
        vim.defer_fn(sync_tmux_theme, 500)
    else
        vim.notify("Tmux sync script not found at: " .. sync_script, vim.log.levels.WARN)
    end
end

return M