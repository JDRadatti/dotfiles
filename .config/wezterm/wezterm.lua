local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'rose-pine'
config.color_schemes = {
    ['rose-pine'] = {
        background = 'black',
    },
}

config.window_padding = {
    left = 10,
    right = 4,
    top = 10,
    bottom = "0",
}

config.font_size = 24
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

wezterm.on('update-right-status', function(window, pane)
    window:set_right_status(window:active_workspace())
end)

-- Keymaps designed to mirror tmux
config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {

    -- Full Screen
    {
        key = 'f',
        mods = 'CMD|CTRL',
        action = wezterm.action.ToggleFullScreen,
    },

    -- Command Pallete
    {
        key = 'P',
        mods = 'LEADER',
        action = wezterm.action.ActivateCommandPalette,
    },

    -- Copy Mode
    {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action.ActivateCopyMode
    },

    -- Paste From Clipboard
    {
        key = ']',
        mods = 'LEADER',
        action = wezterm.action.PasteFrom 'Clipboard'
    },

    -- Close pane
    {
        key = 'x',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },

    -- Split panes
    {
        mods   = "LEADER",
        key    = "_",
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    {
        mods   = "LEADER",
        key    = "-",
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },

    -- Spawn Tab (Tmux window)
    {
        key = 't',
        mods = 'CMD',
        action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },
    -- Show Tab Navigator
    {
        key = 't',
        mods = 'LEADER',
        action = wezterm.action.ShowTabNavigator
    },
    -- Previous Tab
    {
        key = '{',
        mods = 'CMD',
        action = wezterm.action.ActivateTabRelative(-1)
    },
    -- Next Tab
    {
        key = '}',
        mods = 'CMD',
        action = wezterm.action.ActivateTabRelative(1)
    },
    -- Resize panes
    {
        key = 'H',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize { 'Left', 10 },
    },
    {
        key = 'J',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize { 'Down', 10 },
    },
    {
        key = 'K',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize { 'Up', 10 }
    },
    {
        key = 'L',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize { 'Right', 10 },
    },
    -- Select Panes
    {
        key = 'f',
        mods = 'LEADER',
        action = wezterm.action.PaneSelect
    },
    -- Navigate Panes
    {
        key = 'h',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Down',
    },
    -- Zoom
    {
        mods = 'LEADER',
        key = 'z',
        action = wezterm.action.TogglePaneZoomState
    },
    -- Switch to the default workspace
    {
        key = 'y',
        mods = 'LEADER',
        action = wezterm.action.SwitchToWorkspace {
            name = 'default',
        },
    },
    -- Switch to a monitoring workspace, which will have `top` launched into it
    {
        key = 'u',
        mods = 'LEADER',
        action = wezterm.action.SwitchToWorkspace {
            name = 'monitoring',
            spawn = {
                args = { 'top' },
            },
        },
    },
    -- Create a new workspace and prompt for name (TMUX Session)
    {
        key = 'i',
        mods = 'LEADER',
        action = wezterm.action.PromptInputLine {
            description = wezterm.format {
                { Attribute = { Intensity = 'Bold' } },
                { Foreground = { AnsiColor = 'Blue' } },
                { Text = 'Enter name for new workspace' },
            },
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(
                        wezterm.action.SwitchToWorkspace {
                            name = line,
                        },
                        pane
                    )
                end
            end),
        },

    },
    -- Show the launcher
    {
        key = '/',
        mods = 'LEADER',
        action = wezterm.action.ShowLauncher
    },
    -- Show the launcher with the workspaces filter
    {
        key = 's',
        mods = 'LEADER',
        action = wezterm.action.ShowLauncherArgs {
            flags = 'WORKSPACES',
        },
    },
    -- Rename Tab (Tmux Window)
    {
        key = ",",
        mods = "LEADER",
        action = wezterm.action.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },
    -- Rename Workspace (Tmux Session)
    {
        key = "<",
        mods = "LEADER",
        action = wezterm.action.PromptInputLine {
            description = 'Enter new name for workspace',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
                end
            end),
        },
    },
    -- Reload Config
    {
        key = 'r',
        mods = 'LEADER',
        action = wezterm.action.ReloadConfiguration,
    },
}

return config
