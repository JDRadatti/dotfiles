return {
    'MagicDuck/grug-far.nvim',
    config = function()
        require('grug-far').setup({});
        vim.keymap.set("n", "<leader>fr", vim.cmd.GrugFar)
    end
}
