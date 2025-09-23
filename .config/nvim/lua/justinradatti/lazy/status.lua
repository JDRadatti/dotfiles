return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local colors = {
            blue   = '#576ddb',
            cyan   = '#2a9292',
            black  = '#080808',
            white  = '#c6c6c6',
            red    = '#955ae7',
            violet = '#955ae7',
            grey   = '#303030',
        }

        local theme = {
            normal = {
                a = { fg = colors.white },
                b = { fg = colors.white },
                c = { fg = colors.white },
                z = { fg = colors.grey, bg = colors.black },
            },

            insert = {},
            visual = {},
            replace = {},

            inactive = {
                a = { fg = colors.white, bg = colors.black },
                b = { fg = colors.white, bg = colors.black },
                c = { fg = colors.white },
            },
        }
        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = theme,
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                }
            },
            sections = {
                lualine_a = { 'branch' },
                lualine_b = { 'filename' },
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { 'progress' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {}
        }
    end

}
