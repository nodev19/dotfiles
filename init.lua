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
vim.g.mapleader = " "
vim.g.zig_fmt_autosave = 0
vim.o.clipboard = "unnamedplus"
vim.opt.mouse = ""
vim.opt.list = true
vim.opt.lcs = "tab:> ,lead:.,trail:."
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.preserveindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
require("lazy").setup({
	"folke/which-key.nvim",
	{
		"folke/neoconf.nvim",
		cmd = "Neoconf"
	},
	"folke/neodev.nvim",
	"folke/trouble.nvim",
	"nvim-treesitter/nvim-treesitter",
	"nvim-telescope/telescope.nvim",
	"nvim-lua/plenary.nvim",
	"LukasPietzschmann/telescope-tabs",
	"VonHeikemen/lsp-zero.nvim",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/nvim-cmp",
	'L3MON4D3/LuaSnip',
	"VonHeikemen/lsp-zero.nvim",
	"mfussenegger/nvim-dap",
	"rcarriga/nvim-dap-ui",
	"nvim-neotest/nvim-nio",
	"nvim-telescope/telescope-dap.nvim",
	"ThePrimeagen/harpoon",
	"tpope/vim-fugitive",
	"lewis6991/gitsigns.nvim",
	"stevearc/aerial.nvim",
	"RaafatTurki/hex.nvim",
	"nvim-tree/nvim-web-devicons",
	"bluz71/vim-moonfly-colors",
	"patstockwell/vim-monokai-tasty",
})
require("trouble").setup()
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
require("telescope").setup({
	defaults = {
		layout_config = {
			bottom_pane = {
				height = 100,
				preview_cutoff = 100,
				prompt_position = "bottom"
			},
		},
		layout_strategy = "bottom_pane",
		border = true
	}
})
require("telescope").load_extension("dap")
require("telescope").load_extension("aerial")
require("telescope").load_extension("telescope-tabs")
require("telescope").load_extension("harpoon")
require("telescope-tabs").setup()
local lsp_zero = require("lsp-zero")
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
local cmp = require("cmp")
local cmp_select = {behavior = cmp.SelectBehavior.Select}
cmp.setup({
	sources = {
		--{name = "path"},
		--{name = "buffer"},
		--{name = "nvim_lua"},
		--{name = "luasnip"},
		{name = "nvim_lsp"},
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-l>"] = cmp.mapping.confirm({ select = true }),
		["<C-;>"] = cmp.mapping.confirm({ select = true }),
		["<C-Enter>"] = cmp.mapping.complete(),
	}),
})
local dap = require("dap")
--[[
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "-i", "dap" }
}
--]]
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = "/home/adam/src/codelldb/extension/adapter/codelldb",
		args = {"--port", "${port}"},
	}
}
dap.configurations.c = {
	--[[
	{
		name = "GDB Native",
		type = "gdb",
		request = "launch",
		program = function()
			return vim.fn.input("Target: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopAtBeginningOfMainSubprogram = false,
	},
	--]]
	{
		name = "CodeLLDB",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Target: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}
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
					id = "scopes",
					size = 0.5
				},
				{
					id = "watches",
					size = 0.5
				},
			},
			position = "bottom",
			size = 16
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
require("harpoon").setup({
	menu = {
		width = 100,
		height = 20,
	}
})
require("gitsigns").setup({
	signs = {
		add          = { text = '+' },
		change       = { text = '~' },
		delete       = { text = '-' },
		topdelete    = { text = '_' },
		changedelete = { text = ':' },
		untracked    = { text = '/' },
	},
})
local aerial_size = 35
require("aerial").setup({
	backends = {"treesitter", "lsp", "markdown", "man"},
	layout = {
		max_width = aerial_size,
		width = aerial_size,
		min_width = aerial_size,
		default_direction = "left",
		placement = "window",
		resize_to_content = false,
		preserve_equality = false,
	},
})
require("hex").setup()
require("nvim-web-devicons").setup()
vim.keymap.set("n", "`", "<nop>")
vim.keymap.set("v", "`", "<nop>")
vim.keymap.set("t", "`", "<nop>")
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>a", "ggVG")
vim.keymap.set("n", "<leader>hh", function() require("harpoon.ui").toggle_quick_menu() end)
vim.keymap.set("n", "<leader>hf", function() vim.cmd[[Telescope harpoon marks]] end)
vim.keymap.set("n", "<leader>hn", function() require("harpoon.ui").nav_next() end)
vim.keymap.set("n", "<leader>hp", function() require("harpoon.ui").nav_prev() end)
vim.keymap.set("n", "<leader>ha", function() require("harpoon.mark").add_file() end)
vim.keymap.set("n", "<leader>1", function() require("harpoon.ui").nav_file(1) end)
vim.keymap.set("n", "<leader>2", function() require("harpoon.ui").nav_file(2) end)
vim.keymap.set("n", "<leader>3", function() require("harpoon.ui").nav_file(3) end)
vim.keymap.set("n", "<leader>4", function() require("harpoon.ui").nav_file(4) end)
vim.keymap.set("n", "<leader>5", function() require("harpoon.ui").nav_file(5) end)
vim.keymap.set("n", "<leader>6", function() require("harpoon.ui").nav_file(6) end)
vim.keymap.set("n", "<leader>7", function() require("harpoon.ui").nav_file(7) end)
vim.keymap.set("n", "<leader>8", function() require("harpoon.ui").nav_file(8) end)
vim.keymap.set("n", "<leader>9", function() require("harpoon.ui").nav_file(9) end)
vim.keymap.set("n", "<leader>;;", function() vim.cmd[[wa]] vim.cmd[[make]] end)
vim.keymap.set("n", "<leader>;o", function() vim.cmd[[copen]] end)
vim.keymap.set("n", "<leader>;x", function() vim.cmd[[cclose]] end)
vim.keymap.set("n", "<leader>qq", function() require("telescope.builtin").diagnostics() end)
vim.keymap.set("n", "<leader>qw", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>ss", function() require("telescope.builtin").current_buffer_fuzzy_find() end)
vim.keymap.set("n", "<leader>s_", function() require("telescope.builtin").live_grep() end)
vim.keymap.set("n", "<leader>sl", function() require("telescope.builtin").grep_string({search = vim.fn.input(": ")}) end)
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").lsp_document_symbols() end)
vim.keymap.set("n", "<leader>fk", function() require("telescope.builtin").lsp_workspace_symbols() end)
vim.keymap.set("n", "<leader>fa", function() require("telescope").extensions.aerial.aerial() end)
vim.keymap.set("n", "<leader>fo", function() require("telescope.builtin").find_files() end)
vim.keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end)
vim.keymap.set("n", "<leader>fc", function() require("telescope.builtin").commands() end)
vim.keymap.set("n", "<leader>fj", function() require("telescope.builtin").jumplist() end)
vim.keymap.set("n", "<leader>fr", function() require("telescope.builtin").registers() end)
vim.keymap.set("n", "<leader>ft", function() require("telescope.builtin").treesitter() end)
vim.keymap.set("n", "<leader>bb", function() require("telescope.builtin").buffers() end)
vim.keymap.set("n", "<leader>bn", function() vim.cmd[[enew]] end)
vim.keymap.set("n", "<leader>bx", function() vim.cmd[[b#|bd!#]] end)
vim.keymap.set("n", "<leader>tt", function() require("telescope-tabs").list_tabs() end)
vim.keymap.set("n", "<leader>tn", function() vim.cmd[[tab split]] end)
vim.keymap.set("n", "<leader>to", function() vim.cmd[[tab split]] end)
vim.keymap.set("n", "<leader>tx", function() vim.cmd[[tabclose]] end)
vim.keymap.set("n", "<leader>gg", function() vim.cmd[[Git]] end)
vim.keymap.set("n", "<leader>gp", function() vim.cmd[[Git push]] end)
vim.keymap.set("n", "<leader>gd", function() vim.cmd[[Gdiffsplit]] end)
vim.keymap.set("n", "<leader>dv", function() require("telescope").extensions.dap.variables() end)
vim.keymap.set("n", "<leader>df", function() require("telescope").extensions.dap.frames() end)
vim.keymap.set("n", "<leader>dc", function() require("telescope").extensions.dap.commands() end)
vim.keymap.set("n", "<leader>db", function() require("telescope").extensions.dap.list_breakpoints() end)
vim.keymap.set("n", "<leader>dq", function() require("telescope").extensions.dap.configurations() end)
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end)
vim.keymap.set("n", "<leader>dl", function() require("dap").run_last() end)
vim.keymap.set("n", "<leader>dd", function() require("dap").continue() end)
vim.keymap.set("n", "<leader>dx", function() vim.cmd[[DapTerminate]] end)
vim.keymap.set("n", "<leader>dw", function() require("dapui").toggle() end)
vim.keymap.set("n", "<A-b>", function() require("dap").toggle_breakpoint() end)
vim.keymap.set("n", "<A-n>", function() require("dap").step_over() end)
vim.keymap.set("n", "<A-j>", function() require("dap").step_into() end)
vim.keymap.set("n", "<A-p>", function() require("dap").step_out() end)
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-n>", function() vim.cmd[[AerialNext]] end)
vim.keymap.set("n", "<C-p>", function() vim.cmd[[AerialPrev]] end)
vim.keymap.set("n", "<C-Up>", function() vim.cmd[[resize -1]] end)
vim.keymap.set("n", "<C-Down>", function() vim.cmd[[resize +1]] end)
vim.keymap.set("n", "<C-Right>", function() vim.cmd[[vertical resize -1]] end)
vim.keymap.set("n", "<C-Left>", function() vim.cmd[[vertical resize +1]] end)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.cmd [[colorscheme vim-monokai-tasty]]
vim.api.nvim_set_hl(0, "Normal", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "NormalNC", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "NormalFloat", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "FloatBorder", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "EndOfBuffer", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "ColorColumn", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "LineNr", {fg = "none", bg = "none"})
vim.api.nvim_set_hl(0, "SignColumn", {fg = "none", bg = "none"})
