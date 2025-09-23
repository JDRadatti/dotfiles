return {
    'nvim-telescope/telescope.nvim',

    tag = '0.1.5',

    dependencies = {
        'nvim-lua/plenary.nvim',
    },

    config = function()
        require('telescope').setup({
            defaults = {
                layout_config = {
                    horizontal = {
                        preview_cutoff = 0,
                        preview_width = 0.7,
                        width = 0.9,
                    },
                    center = {
                        height = 0.7,
                        width = 0.7,
                        prompt_position = "bottom",
                        previewer = false,
                    },
                },
            },
            pickers = {
                find_files = {
                    layout_strategy = "center",
                },
                git_files = {
                    layout_strategy = "center",
                },
                help_tags = {
                    layout_strategy = "center",
                },
                command_history = {
                    layout_strategy = "center",
                },
                live_grep = {
                    path_display = { "tail" },
                },
                grep_string = {
                    path_display = { "tail" },
                },
                lsp_workspace_symbols = {
                    path_display = { "tail" },
                }

            },
        })
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>gh', function()
            builtin.live_grep({ cwd = "/usr/local/.go/src/" })
        end)
        vim.keymap.set('n', '<leader>pc', builtin.command_history, {})
        vim.keymap.set('n', '<leader>ph', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>pm', builtin.man_pages, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.lsp_dynamic_workspace_symbols()
        end)
        vim.keymap.set('n', '<leader>pw', builtin.grep_string)
        vim.keymap.set('n', '<leader>pr', builtin.lsp_references)
        vim.keymap.set('n', '<leader>pa', builtin.git_bcommits)
    end

}
