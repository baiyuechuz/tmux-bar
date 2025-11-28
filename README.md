# Tmux-bar

A minimal tmux status bar with NvChad theme synchronization.

## Features

- Auto-sync colors with NvChad theme
- Prefix key indicator
- Git branch display
- Current directory display
- User/host/session info
- Pomodoro timer with auto-advance
- Customizable icons (Nerd Fonts)
- Tundra theme as default fallback

## Requirements

- tmux >= 3.0
- Perl (for color parsing)
- [Nerd Fonts](https://www.nerdfonts.com/) (for icons)
- NvChad (optional, for theme sync)

## Installation

### Using TPM

Add to your `tmux.conf`:

```bash
set -g @plugin 'baiyuechuz/tmux-bar'
```

Then press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/baiyuechuz/tmux-bar ~/.tmux/plugins/tmux-bar
```

Add to `tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-bar/tmux-bar.tmux
```

## Configuration

Add options to your `tmux.conf` before the plugin is loaded.

### Display Options

| Option                   | Default | Description            |
| ------------------------ | ------- | ---------------------- |
| `@tmux_bar_show_user`    | `true`  | Show username          |
| `@tmux_bar_show_host`    | `true`  | Show hostname          |
| `@tmux_bar_show_session`  | `true`  | Show session name      |
| `@tmux_bar_show_git`      | `true`  | Show git branch        |
| `@tmux_bar_show_cwd`      | `false` | Show current directory |
| `@tmux_bar_show_pomodoro` | `false` | Show pomodoro timer    |

### Format Options

| Option                       | Default | Description                       |
| ---------------------------- | ------- | --------------------------------- |
| `@tmux_bar_time_format`      | `%T`    | Time format (strftime)            |
| `@tmux_bar_date_format`      | `%F`    | Date format (strftime)            |
| `@tmux_bar_refresh_interval` | `1`     | Status refresh interval (seconds) |

### Icons

| Option                       | Default | Description            |
| ---------------------------- | ------- | ---------------------- |
| `@tmux_bar_session_icon`     | ``     | Session icon           |
| `@tmux_bar_user_icon`        | `󰀘`     | User icon              |
| `@tmux_bar_time_icon`        | `󰔟`     | Time icon              |
| `@tmux_bar_date_icon`        | ``     | Date icon              |
| `@tmux_bar_git_icon`         | ``     | Git branch icon        |
| `@tmux_bar_cwd_icon`         | ``     | Current directory icon |
| `@tmux_bar_prefix_icon`      | `󰊠`     | Prefix indicator icon  |
| `@tmux_bar_pomodoro_icon`    | ``     | Pomodoro timer icon    |
| `@tmux_bar_right_arrow_icon` | `▌`     | Right separator        |
| `@tmux_bar_left_arrow_icon`  | `▐`     | Left separator         |

### Example Configuration

```bash
# Display options
set -g @tmux_bar_show_user true
set -g @tmux_bar_show_host true
set -g @tmux_bar_show_session true
set -g @tmux_bar_show_git true
set -g @tmux_bar_show_cwd false

# Format
set -g @tmux_bar_time_format '%H:%M'
set -g @tmux_bar_date_format '%Y-%m-%d'

# Custom icons
set -g @tmux_bar_prefix_icon '󰊠'
set -g @tmux_bar_git_icon ''
```

## Pomodoro Timer

tmux-bar includes a built-in Pomodoro timer to help you manage your work sessions.

### Features

- 25-minute work sessions
- 5-minute short breaks
- 15-minute long breaks (every 4 pomodoros)
- Auto-advance to next session
- Pause/resume support
- Visual countdown in status bar

### Usage

Enable the Pomodoro timer in your `tmux.conf`:

```bash
set -g @tmux_bar_show_pomodoro true
```

### Key Bindings

Default key bindings (can be customized):

| Key         | Action                           | Option                             |
| ----------- | -------------------------------- | ---------------------------------- |
| `prefix + p` | Start/pause/resume timer        | `@tmux_bar_pomodoro_key_toggle`    |
| `prefix + P` | Stop timer                      | `@tmux_bar_pomodoro_key_stop`      |
| `prefix + o` | Skip to next session            | `@tmux_bar_pomodoro_key_skip`      |

### Customizing Key Bindings

```bash
set -g @tmux_bar_pomodoro_key_toggle 'p'
set -g @tmux_bar_pomodoro_key_stop 'P'
set -g @tmux_bar_pomodoro_key_skip 'o'
```

### Timer States

- 🍅 **Work session**: 25 minutes of focused work
- ☕ **Break**: 5 or 15 minutes rest
- ⏸ **Paused**: Timer is paused

The timer automatically advances to the next session when time runs out.

## NvChad Theme Sync

tmux-bar automatically syncs with NvChad theme colors by reading from `~/.local/share/nvim/base46/`.

### Auto-sync Setup

Add to your NvChad config (`~/.config/nvim/lua/`):

**1. Create `tmux_sync.lua`:**

```lua
-- lua/custom/tmux_sync.lua
local M = {}

local function sync_tmux()
  if not vim.env.TMUX then return end
  local plugin_dir = vim.fn.system("tmux show -gqv @tmux_bar_dir"):gsub("%s+$", "")
  if plugin_dir ~= "" then
    os.execute("tmux run-shell '" .. plugin_dir .. "/tmux-bar.tmux' &")
  end
end

M.setup = function()
  local stl_file = vim.fn.stdpath("data") .. "/base46/statusline"
  local w = vim.uv.new_fs_event()
  if w then
    w:start(stl_file, {}, vim.schedule_wrap(function()
      sync_tmux()
    end))
  end
end

return M
```

**2. Add to your `init.lua`:**

```lua
require("custom.tmux_sync").setup()
```

Now when you change NvChad theme, tmux-bar will automatically update.

## Default Colors (Tundra)

When NvChad cache is not available, tmux-bar uses Tundra theme colors:

| Color      | Hex       |
| ---------- | --------- |
| Red        | `#FCA5A5` |
| Green      | `#B5E8B0` |
| Blue       | `#A5B4FC` |
| Purple     | `#BDB0E4` |
| Gray       | `#5f6675` |
| Background | `#182030` |
| Block BG   | `#323948` |
| Foreground | `#FFFFFF` |

## License

MIT
