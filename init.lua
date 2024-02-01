-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- shizzle
vim.g.mapleader = " "
vim.opt.mouse = ""
vim.opt.list = true
vim.opt.lcs = "tab:> ,lead:.,trail:."
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
-- packages
require("lazy").setup({
	-- folke shizzle
	"folke/which-key.nvim",
	{
		"folke/neoconf.nvim",
		cmd = "Neoconf"
	},
	"folke/neodev.nvim",
	-- treesitter
	"nvim-treesitter/nvim-treesitter",
	-- telescope
	"nvim-telescope/telescope.nvim",
	"nvim-lua/plenary.nvim",
	-- lsp zero
	'VonHeikemen/lsp-zero.nvim',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'neovim/nvim-lspconfig',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/nvim-cmp',
	'L3MON4D3/LuaSnip',
	"VonHeikemen/lsp-zero.nvim",
	-- debugger
	"mfussenegger/nvim-dap",
	"rcarriga/nvim-dap-ui",
	"jay-babu/mason-nvim-dap.nvim",
	"nvim-telescope/telescope-dap.nvim",
	"theHamsta/nvim-dap-virtual-text",
	-- git
	"tpope/vim-fugitive",
	"lewis6991/gitsigns.nvim",
	-- other
	"stevearc/aerial.nvim",
	"stevearc/overseer.nvim",
	-- colourscheme
	"bluz71/vim-moonfly-colors",
})
-- treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = {"c", "lua", "vim", "vimdoc", "query"},
	sync_install = false,
	auto_install = true,
	ignore_install = { "javascript" },
	highlight = {
		enable = true,
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		additional_vim_regex_highlighting = false,
	},
})
-- telescope
require('telescope').setup({
	defaults = {
		layout_config = {
			bottom_pane = {
				height = 100,
				preview_cutoff = 120,
				prompt_position = "bottom"
			},
		},
		layout_strategy = "bottom_pane"
	}
})
require('telescope').load_extension('dap')
-- lsp zero
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
	local opts = {buffer = bufnr, remap = false}
	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vk", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vq", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>vc", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)
-- mason
require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {
		"clangd",
		"lua_ls",
		"bashls",
	},
	handlers = {
		lsp_zero.default_setup,
		lua_ls = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require("lspconfig").lua_ls.setup(lua_opts)
		end,
	}
})
-- cmp
local cmp = require("cmp")
local cmp_select = {behavior = cmp.SelectBehavior.Select}
cmp.setup({
	sources = {
		{name = "path"},
		{name = "nvim_lsp"},
		{name = "nvim_lua"},
		{name = "luasnip", keyword_length = 2},
		{name = "buffer", keyword_length = 3},
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-j>"] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping.complete(),
	}),
})
-- dap
local dap = require("dap")
require("dapui").setup({
	controls = {
		element = "repl",
		enabled = true,
		icons = {
			disconnect = "",
			pause = "",
			play = "",
			run_last = "",
			step_back = "",
			step_into = "",
			step_out = "",
			step_over = "",
			terminate = ""
		}
	},
	element_mappings = {},
	expand_lines = true,
	floating = {
		border = "single",
		mappings = {
			close = { "q", "<Esc>" }
		}
	},
	force_buffers = true,
	icons = {
		collapsed = "",
		current_frame = "",
		expanded = ""
	},
	layouts = {
		{
			elements = {
				{
					id = "console",
					size = 0.2
				},
				{
					id = "watches",
					size = 0.8
				},
				{
					id = "scopes",
					size = 0.3
				},
			},
			position = "left",
			size = 50
		},
	},
	mappings = {
		edit = "e",
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		repl = "r",
		toggle = "t"
	},
	render = {
		indent = 0,
		max_value_lines = 100
	}
})
local mason_dap = require("mason-nvim-dap")
mason_dap.setup({
	handlers = {
		function(config)
			mason_dap.default_setup(config)
		end
	}
})
require("nvim-dap-virtual-text").setup({
	commented = true,
})
-- gitsigns
require('gitsigns').setup {
	signs = {
		add          = { text = '+' },
		change       = { text = '~' },
		delete       = { text = '-' },
		topdelete    = { text = '-' },
		changedelete = { text = '~' },
		untracked    = { text = '/' },
	},
	signcolumn = true,
	numhl      = false,
	linehl     = false,
	word_diff  = false,
	watch_gitdir = {
		follow_files = true
	},
	auto_attach = true,
	attach_to_untracked = false,
	current_line_blame = false,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = 'eol',
		delay = 1000,
		ignore_whitespace = false,
		virt_text_priority = 100,
	},
	current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil,
	max_file_length = 40000,
	preview_config = {
		border = 'single',
		style = 'minimal',
		relative = 'cursor',
		row = 0,
		col = 1
	},
	yadm = {
		enable = false
	},
}
-- aerial
local aerial_size = 35
require("aerial").setup({
	backends = { "treesitter", "lsp", "markdown", "man" },
	layout = {
		max_width = aerial_size,
		width = aerial_size,
		min_width = aerial_size,
		default_direction = "prefer_left",
		placement = "edge",
		resize_to_content = false,
		preserve_equality = false,
	},
})
-- overseer
require("overseer").setup({
	templates = {"builtin", "user.run_script"},
})
-- tool window
local g_tool_flip = 0
function Tool_Flip()
	if g_tool_flip == 0 then
		vim.cmd[[AerialOpen!]]
		require("dapui").close()
		g_tool_flip = 1
	else
		vim.cmd[[AerialClose]]
		require("dapui").open()
		g_tool_flip = 0
	end
end
-- keymaps
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>a", "ggVG")
vim.keymap.set("n", "<leader>x", function() vim.cmd[[b#|bd#]] end)
vim.keymap.set("n", "<leader>ww", function() Tool_Flip() end)
vim.keymap.set("n", "<leader>wa", function() vim.cmd[[AerialToggle!]] end)
vim.keymap.set("n", "<leader>ee", function() vim.cmd[[Ex]] end)
vim.keymap.set("n", "<leader>qq", function() require("telescope.builtin").diagnostics() end)
vim.keymap.set("n", "<leader>fe", function() require("telescope.builtin").find_files() end)
vim.keymap.set("n", "<leader>ss", function() require("telescope.builtin").current_buffer_fuzzy_find() end)
vim.keymap.set("n", "<leader>sl", function() require("telescope.builtin").live_grep() end)
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").treesitter() end)
vim.keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end)
vim.keymap.set("n", "<leader>fc", function() require("telescope.builtin").commands() end)
vim.keymap.set("n", "<leader>fj", function() require("telescope.builtin").jumplist() end)
vim.keymap.set("n", "<leader>fr", function() require("telescope.builtin").registers() end)
vim.keymap.set("n", "<leader>bb", function() require("telescope.builtin").buffers() end)
vim.keymap.set("n", "<leader>dc", function() require("telescope").extensions.dap.commands() end)
vim.keymap.set("n", "<leader>dq", function() require("telescope").extensions.dap.configurations() end)
vim.keymap.set("n", "<leader>db", function() require("telescope").extensions.dap.list_breakpoints() end)
--vim.keymap.set("n", "<leader>dv", function() require("telescope").extensions.dap.variables() end)
vim.keymap.set("n", "<leader>df", function() require("telescope").extensions.dap.frames() end)
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end)
vim.keymap.set("n", "<leader>dl", function() require("dap").run_last() end)
vim.keymap.set("n", "<leader>dd", function() require("dap").continue() end)
vim.keymap.set("n", "<leader>dw", function() require("dapui").toggle() end)
vim.keymap.set("n", "<A-b>", function() require("dap").toggle_breakpoint() end)
vim.keymap.set("n", "<A-n>", function() require("dap").step_over() end)
vim.keymap.set("n", "<A-j>", function() require("dap").step_into() end)
vim.keymap.set("n", "<A-p>", function() require("dap").step_out() end)
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-Up>", function() vim.cmd[[resize -2]] end)
vim.keymap.set("n", "<C-Down>", function() vim.cmd[[resize +2]] end)
vim.keymap.set("n", "<C-Right>", function() vim.cmd[[vertical resize -2]] end)
vim.keymap.set("n", "<C-Left>", function() vim.cmd[[vertical resize +2]] end)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- colourscheme
vim.cmd [[colorscheme moonfly]]
vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalNC", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})
--vim.api.nvim_set_hl(0, "FloatBorder", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "EndOfBuffer", {bg = "none"})
