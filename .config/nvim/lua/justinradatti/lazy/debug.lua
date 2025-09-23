return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "leoluz/nvim-dap-go",
            'mfussenegger/nvim-dap-python',
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "williamboman/mason.nvim",
        },
        config = function()
            local dap = require "dap"
            local ui = require "dapui"

            ui.setup({
                layouts = { {
                    elements = { {
                        id = "watches",
                        size = 1
                    } },
                    position = "right",
                    size = 30
                }, },
                mappings = {
                    edit = "e",
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    repl = "r",
                    toggle = "t"
                },
            })

            require("nvim-dap-virtual-text").setup {
                display_callback = function(variable)
                    if #variable.value > 15 then
                        return " " .. string.sub(variable.value, 1, 15) .. "... "
                    end

                    return " " .. variable.value
                end,
            }

            require("dap-go").setup()
            vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint)
            vim.keymap.set('n', '<Leader>bc',
                function() require('dap').set_breakpoint(vim.fn.input('Condition: '), nil, nil) end)
            vim.keymap.set('n', '<Leader>dr', dap.repl.open)
            vim.keymap.set('n', '<Leader>dl', dap.run_last)

            require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = "Launch file",
                    program = "${file}",
                    console = "integratedTerminal",
                },
            }


            -- Eval var under cursor
            vim.keymap.set("n", "<space>?", function()
                ui.eval(nil, { enter = true })
            end)

            vim.keymap.set("n", "<F3>", dap.continue)
            vim.keymap.set("n", "<F4>", dap.step_into)
            vim.keymap.set("n", "<F5>", dap.step_over)
            vim.keymap.set("n", "<F6>", dap.step_out)
            vim.keymap.set("n", "<F7>", dap.step_back)
            vim.keymap.set("n", "<F8>", dap.restart)
            vim.keymap.set("n", "<F12>", dap.terminate)

            vim.keymap.set("n", "<leader>dt", function()
                ui.float_element('stacks', { enter = true })
            end)

            vim.keymap.set("n", "<leader>db", function()
                ui.float_element('breakpoints', { enter = true })
            end)

            vim.keymap.set("n", "<leader>ds", function()
                ui.float_element('scopes', { enter = true })
            end)

            dap.listeners.before.attach.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                ui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                ui.close()
            end
        end,
    },
}
