return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", function()
            local found = false
            for buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    local tag = string.sub(vim.api.nvim_buf_get_name(buf), 1, 8)
                    if tag == "fugitive" then
                        found = true
                        vim.api.nvim_buf_delete(buf, { unload = true })
                    end
                end
            end
            if not found then vim.cmd('Git') end
        end)
        vim.keymap.set("n", "<leader>gd", vim.cmd.Gvdiffsplit)
    end
}
