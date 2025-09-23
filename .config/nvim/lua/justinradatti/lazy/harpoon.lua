return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<c-h>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<c-j>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<c-k>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<c-l>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<c-;>", function() harpoon:list():select(4) end)
        end
    },
}
