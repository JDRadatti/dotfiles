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

vim.opt.smartindent = true

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
	end,
})
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)

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

	-- GIT GUTTER
	{
		src = "https://github.com/airblade/vim-gitgutter",
	},

	-- COLOR THEME: Gruvbox
	{
		src = "https://github.com/ellisonleao/gruvbox.nvim",
	},

	-- CONFORM
	{
		src = "https://github.com/stevearc/conform.nvim",
	},
})
local telescope = require("telescope")
local harpoon = require("harpoon")
local conform = require("conform")

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

-- GIT GUTTER
-- <Leader>hs == Stage Hunk
-- <Leader>hu == Undo Staged Hunk.
-- <Leader>hp == Preview Hunk

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
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- COLORSCHEME GRUVBOX
require("gruvbox").setup({
	terminal_colors = true,
	contrast = "soft", -- can be "hard", "soft" or empty string
	transparent_mode = true,
})

-- SET COLORSCHEME
-- vim.cmd("colorscheme gruvbox")
vim.cmd("colorscheme default")
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#FFFFFF", bg = "none" })
