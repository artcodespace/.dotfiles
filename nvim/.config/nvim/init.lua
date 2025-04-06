-- SECTION: INTRO
-- This file is intentionally large to make it easier to maintain usability of
-- the exact same repo between both 'stow' and nix dotfile use cases.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, " ", "<nop>", { silent = true })

-- SECTION: PLUGIN CONFIGURATION AND KEYBINDINGS
-- PLUGIN: fzf
local fzf = require("fzf-lua")
local function configure_finder(title, opts)
	return vim.tbl_deep_extend("keep", opts or {}, {
		prompt = title .. "  ",
		winopts = {
			title = "┤ " .. title .. " ├",
			title_pos = "center",
		},
	})
end

fzf.setup({
	defaults = {
		file_icons = false,
		git_icons = false,
	},
	keymap = {
		builtin = {
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
		},
		fzf = {
			["ctrl-q"] = "select-all+accept",
		},
	},
	fzf_opts = {
		["--info"] = "default",
		["--pointer"] = "",
		["--marker"] = "",
	},
	fzf_colors = {
		["fg"] = { "fg", { "Comment" } },
		["hl"] = { "fg", { "Normal" } },
		["fg+"] = { "fg", { "PmenuSel" } },
		["bg+"] = { "bg", { "PmenuSel" } },
		["gutter"] = "-1",
		["hl+"] = { "fg", { "PmenuSel" }, "italic", "underline" },
		["query"] = { "fg", { "Cursor" } },
		["info"] = { "fg", { "Comment" } },
		["border"] = { "fg", { "Normal" } },
		["separator"] = { "fg", { "Comment" } },
		["prompt"] = { "fg", { "Normal" } },
		["pointer"] = { "fg", { "PmenuSel" } },
		["marker"] = { "fg", { "Pmenu" } },
		["header"] = { "fg", { "Normal" } },
	},
	files = configure_finder("Finder", { cwd_prompt = false }),
	buffers = configure_finder("Buffers"),
	grep = configure_finder(
		"Ripgrep",
		{ rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e" }
	),
	diagnostics = configure_finder("Diagnostics", { severity_limit = "error" }),
	lsp = {
		jump_to_single_result = true,
		prompt_postfix = "  ",
		symbols = configure_finder("Symbol"),
	},
	helptags = configure_finder("Help"),
})

vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>d", fzf.lsp_document_diagnostics)
vim.keymap.set("n", "<leader>o", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>O", fzf.lsp_live_workspace_symbols)
vim.keymap.set("n", "gr", fzf.lsp_references)
vim.keymap.set("n", "gd", fzf.lsp_definitions)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader><leader>", fzf.resume)

-- PLUGIN: nvim-lspconfig
require("lspconfig.ui.windows").default_options = { border = "rounded" }
local lspconfig = require("lspconfig")

-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations
lspconfig.ts_ls.setup({})
lspconfig.eslint.setup({
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})
lspconfig.lua_ls.setup({
	-- stop the lua lsp complaining about calling `vim`
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
lspconfig.cssls.setup({})
lspconfig.nixd.setup({})

-- Use LspAttach to set mapping after the language server attaches
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		-- these could potentially be guarded, see :h lsp-config
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, opts)
		vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
	end,
})

-- PLUGIN: vim-tmux-navigator
vim.g.tmux_navigator_no_wrap = 1

-- PLUGIN: nvim-surround
require("nvim-surround").setup()

-- PLUGIN: conform.nvim
require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd" },
		css = { "prettierd" },
		html = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		lua = { "stylua" },
		nix = { "alejandra" },
	},
	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 500,
	},
})

-- PLUGIN: nvim-treesitter
local parsers = { "comment", "css", "javascript", "lua", "typescript", "tsx", "vim", "vimdoc", "nix" }
-- required for nix compatibility, see https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#advanced-setup
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitter"
vim.opt.runtimepath:append(parser_install_dir)

require("nvim-treesitter.configs").setup({
	parser_install_dir = parser_install_dir,
	ensure_installed = parsers,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

-- SECTION: AUTOCOMMANDS
-- Start neovim with fzf open if no arguments passed
vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	callback = function()
		if next(vim.fn.argv()) == nil then
			require("fzf-lua").files()
		end
	end,
})
-- Don't show columns in these filetypes
vim.api.nvim_create_autocmd("filetype", {
	pattern = { "netrw", "qf", "help" },
	callback = function()
		vim.opt_local.colorcolumn = ""
		vim.opt_local.cursorcolumn = false
	end,
})
-- add abbreviations to these filetypes
vim.api.nvim_create_autocmd("filetype", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function()
		vim.cmd("iab <buffer> tbitd toBeInTheDocument()")
		vim.cmd("iab <buffer> fna () => {}")
	end,
})
-- What was previously in /after/ftplugin/netrw.lua
vim.api.nvim_create_autocmd("filetype", {
	pattern = "netrw",
	callback = function()
		-- https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
		vim.g.netrw_banner = 0
		vim.g.netrw_winsize = 30
		vim.g.netrw_altfile = 1 -- make <C-6> go back to prev file, not netrw
		vim.g.netrw_localcopydircmd = "cp -r" -- allow whole folder copying
		function NetrwWinBar()
			return "%#Normal#  %t %*%=%#Normal# 󰋞 " .. vim.fn.getcwd() .. " "
		end
		vim.opt_local.winbar = "%{%v:lua.NetrwWinBar()%}"
		vim.keymap.set("n", "h", "-", { remap = true, buffer = true })
		vim.keymap.set("n", "l", "<cr>", { remap = true, buffer = true })
		vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { remap = true, buffer = true })
	end,
})
-- What was previously in /after/ftplugin/qf.lua
vim.api.nvim_create_autocmd("filetype", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "<C-n>", "<cmd>cnext | wincmd p<cr>", { remap = true, buffer = true })
		vim.keymap.set("n", "<C-p>", "<cmd>cprev | wincmd p<cr>", { remap = true, buffer = true })
		vim.keymap.set("n", "x", function()
			-- use x to filter __highlighted__ entries from the qf list
			local qf = vim.fn.getqflist({ idx = 0, items = 0 })
			local current_idx = qf.idx

			local new_qf_list = {}

			for k, v in pairs(qf.items) do
				if k ~= current_idx then
					table.insert(new_qf_list, v)
				end
			end

			vim.fn.setqflist(new_qf_list)
		end, { remap = true, buffer = true })
		vim.cmd("wincmd K")
	end,
})

-- SECTION: KEYBINDS
local ERROR = { severity = vim.diagnostic.severity.ERROR }
vim.keymap.set("n", "<Esc>", function()
	local filetype = vim.bo.filetype
	local is_netrw = filetype == "netrw"
	local is_qf_or_help = filetype == "qf" or filetype == "help"
	local has_highlights = vim.v.hlsearch == 1

	if has_highlights then
		vim.cmd("nohls")
	elseif is_qf_or_help then
		vim.cmd("close")
	elseif is_netrw then
		vim.cmd("Rex")
	end
end, { silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Ex<cr>", { silent = true })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { silent = true })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { silent = true })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev(ERROR)
end, { silent = true })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next(ERROR)
end, { silent = true })
vim.keymap.set("i", "<C-j>", "<C-x><C-o>", { silent = true }) -- Lsp completion
vim.api.nvim_create_user_command("Tsc", function()
	local ts_root = vim.fs.root(0, "tsconfig") -- may need updating in a TS proj at work
	if ts_root == nil then
		return print("Unable to find tsconfig")
	end
	vim.cmd("compiler tsc | echo 'Building TypeScript...' | silent make! --noEmit | echo 'TypeScript built.' | copen")
end, {})

-- SECTION: OPTIONS
vim.o.guicursor = vim.o.guicursor .. ",a:Cursor" -- append hl-Cursor to all modes
vim.o.winborder = "rounded"
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "80"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " ", wbr = "▀", vert = "█" } -- see unicode block
vim.opt.ignorecase = true
vim.opt.jumpoptions = "stack"
vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.ruler = false
vim.opt.shiftwidth = 4
vim.opt.showcmd = false
vim.opt.sidescrolloff = 7
vim.opt.signcolumn = "no"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undofile = true

vim.diagnostic.config({
	float = { border = "rounded", severity_sort = true },
	severity_sort = true,
	virtual_text = false,
	jump = { float = true }, -- see https://github.com/neovim/neovim/pull/29067
	signs = {
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsgReverse",
			[vim.diagnostic.severity.WARN] = "WarningMsgReverse",
		},
	},
})

function WinBar()
	local icon = vim.bo.modified and "" or ""
	local has_errors = vim.diagnostic.count(0)[vim.diagnostic.severity.ERROR] or 0 > 0
	local error_string = has_errors and "▜▛▜▛▜▛" or ""
	return error_string .. "%*%=%#Normal# " .. icon .. " %t %*%=" .. error_string
end
vim.opt.winbar = "%{%v:lua.WinBar()%}"

-- SECTION: INITIALISE
vim.opt.background = "dark"
vim.cmd("colorscheme pax")
