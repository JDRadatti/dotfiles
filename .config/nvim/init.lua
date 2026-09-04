---
--- GENERAL CONFIG
---

vim.opt.background = "dark"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true

-- Always line up new lines with the first character of the previous line.
-- Disables context-sensitive indentation set by filetype indent plugins.
vim.api.nvim_create_augroup("PlainAutoindent", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "PlainAutoindent",
	pattern = "*",
	callback = function()
		vim.bo.smartindent = false
		vim.bo.cindent = false
		vim.bo.autoindent = true
		vim.bo.indentexpr = ""
	end,
})

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.laststatus = 3 -- Global status bar
vim.opt.statusline = "%-t"

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

--
--  REMAPS
--

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste without overwriting current buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- copy to system clipboard: asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>k", ":wincmd k<CR>")
vim.keymap.set("n", "<leader>j", ":wincmd j<CR>")
vim.keymap.set("n", "<leader>h", ":wincmd h<CR>")
vim.keymap.set("n", "<leader>l", ":wincmd l<CR>")
vim.keymap.set("n", "<leader>v", ":wincmd v<CR>")

--
--  LSP
--

-- RUST
vim.lsp.config["rust_analyzer"] = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "Cargo.lock", ".git" },
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
			},
			checkOnSave = true,
		},
	},
}
vim.lsp.enable("rust_analyzer")

-- CLANG
vim.lsp.config["clangd"] = {
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_markers = {
		{ "compile_commands.json", "compile_flags.txt" },
		".git",
	},
	settings = {},
}
vim.lsp.enable("clangd")

-- PYTHON
vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
	},
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
			},
		},
	},
}
vim.lsp.enable("pyright")

-- LSP WINDOW DISPLAY
vim.diagnostic.config({
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- LSP KEYBINDS
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

--
-- PLUGINS
--

vim.pack.add({

	-- PLENARY (common dependency)
	{
		src = "https://github.com/nvim-lua/plenary.nvim",
		name = "plenary",
	},

	-- TELESCOPE
	{
		src = "https://github.com/nvim-telescope/telescope.nvim",
		name = "telescope",
	},

	-- HARPOON
	{
		src = "https://github.com/theprimeagen/harpoon",
		version = "harpoon2",
	},

	-- UNDOTREE
	{
		src = "https://github.com/mbbill/undotree",
	},

	-- VIM FUGITIVE
	{
		src = "https://github.com/tpope/vim-fugitive",
	},

	-- GITSIGNS
	{
		src = "https://github.com/lewis6991/gitsigns.nvim",
	},

	-- COLOR THEME: Black Metal
	{
      src = "https://github.com/metalelf0/black-metal-theme-neovim",
      name = "black-metal"
    },

	-- CONFORM
	{
		src = "https://github.com/stevearc/conform.nvim",
	},

    -- TROUBLE
    {
        src = "https://github.com/folke/trouble.nvim",
    },
})
local telescope = require("telescope")
local harpoon = require("harpoon")
local conform = require("conform")
local trouble = require("trouble")

-- HARPOON
harpoon:setup()
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-h>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
vim.keymap.set("n", "<C-j>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-k>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-l>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-;>", function()
	harpoon:list():select(4)
end)

-- TELESCOPE
local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", telescope_builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>pg", telescope_builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>pb", telescope_builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>ph", telescope_builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>pc", telescope_builtin.command_history, {})
vim.keymap.set("n", "<leader>o", function()
	telescope_builtin.lsp_dynamic_workspace_symbols()
end)

-- UNDOTREE
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- FUGITIVE
vim.keymap.set("n", "<leader>gs", function()
	local found = false
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local tag = string.sub(vim.api.nvim_buf_get_name(buf), 1, 8)
			if tag == "fugitive" then
				found = true
				vim.api.nvim_buf_delete(buf, { unload = true })
			end
		end
	end
	if not found then
		vim.cmd("Git")
	end
end)
vim.keymap.set("n", "<leader>gd", vim.cmd.Gvdiffsplit)
vim.keymap.set("n", "<leader>gm", ":Gvdiffsplit!<CR>") 
vim.keymap.set('n', 'g<', ':diffget //2<CR>', { desc = 'Diff get from Left (Target)' })
vim.keymap.set('n', 'g>', ':diffget //3<CR>', { desc = 'Diff get from Right (Remote)' })

-- CONFORM
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		json = { "prettier" },
		jsonc = { "prettier" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
	},
	formatters = {
		["clang-format"] = {
			prepend_args = { "--style=Google" },
		},
	},
})

-- GITSIGNS
local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
  gitsigns.setup({})
end
vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next hunk" })
vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous hunk" })
vim.keymap.set("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })

-- TROUBLE
trouble.setup({
  win = { position = "left" },
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set("n", "<leader>cr", "<cmd>Trouble lsp toggle focus=false<cr>", { desc = "LSP References (Trouble)" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
vim.keymap.set("n", "<leader>xh", function()
  vim.cmd("Gitsigns setqflist all")
  vim.cmd("Trouble qflist toggle")
end, { desc = "Git Hunks (Trouble)" })
vim.keymap.set("n", "<leader>xb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle Git Blame" })

-- COLORSCHEME BLACK METAL BATHORY
require("black-metal").setup({
  theme = "bathory",
})

-- SET COLORSCHEME
require("black-metal").load()
