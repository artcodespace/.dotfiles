-- ## TODOS
-- fix the hl+ hl group not working in the pax theme!
-- add the ability to start neovim with/without lsp using a flag -- see line 71

-- ## INTRO
vim.g.vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, " ", "<nop>", { silent = true })

-- ## PLUGINS.FZF-LUA
local fzf = require("fzf-lua")
fzf.setup({
	fzf_colors = { true, ["hl+"] = { "fg", { "PmenuSel" }, "italic", "underline" } },
	keymap = {
		builtin = {
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
		},
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096",
	},
})

vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader>o", fzf.treesitter)

-- ## PLUGINS.CONFORM
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
		timeout_ms = 500,
	},
})

-- ## PLUGINS.NVIM-TREESITTER
-- required for nix compatibility, see https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#advanced-setup
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitter"
vim.opt.runtimepath:append(parser_install_dir)
local parsers = { "comment", "css", "javascript", "lua", "typescript", "tsx", "vim", "vimdoc", "nix" }

require("nvim-treesitter.configs").setup({
	parser_install_dir = parser_install_dir,
	ensure_installed = parsers,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

-- ## PLUGINS.VIM-TMUX-NAVIGATOR && PLUGINS.NVIM-SURROUND
vim.g.tmux_navigator_no_wrap = 1
require("nvim-surround").setup()

-- ## NVIM.LSP
vim.lsp.enable({ "lua_ls", "ts_ls", "eslint", "cssls", "nixd" })
-- TODO >>> add a function to turn off and disable all clients, or alternatively
-- start with them off and add a function to turn them all _on_.
-- ALSO >>> sort out the lua rc file so that we get completion!
-- ## NVIM.AUTOCOMMANDS
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if next(vim.fn.argv()) == nil then
			require("fzf-lua").files() -- open fzf if started with no args
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "netrw", "qf", "help" }, -- no visual columns in these files
	callback = function()
		vim.opt_local.colorcolumn = ""
		vim.opt_local.cursorcolumn = false
	end,
})

-- ## NVIM.NETRW see https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30
vim.g.netrw_altfile = 1 -- make <C-6> go back to prev file, not netrw
vim.g.netrw_localcopydircmd = "cp -r" -- allow whole folder copying
function NetrwWinBar()
	return "%#Normal#  %t %*%=%#Normal# 󰋞 " .. vim.fn.getcwd() .. " "
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.opt_local.winbar = "%{%v:lua.NetrwWinBar()%}"
		vim.keymap.set("n", "h", "-", { remap = true, buffer = true })
		vim.keymap.set("n", "l", "<cr>", { remap = true, buffer = true })
		vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { remap = true, buffer = true })
	end,
})

-- ## NVIM.KEYBINDS
function SetTabSize(size) -- number | nil
	size = size or 4
	vim.opt.tabstop = size
	vim.opt.shiftwidth = size
	vim.opt.softtabstop = size
end
local function super_tab(direction) -- "next" | "previous"
	if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
		return "<cmd>" .. "c" .. direction .. "<CR>"
	end

	return direction == "next" and "<Tab>" or "<S-Tab>"
end
local function super_escape()
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
end
vim.keymap.set("n", "<Esc>", super_escape, { silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Ex<cr>", { silent = true })
vim.keymap.set("n", "<leader>t", [[:lua SetTabSize()<Left>]], { noremap = true })
vim.keymap.set("n", "<Tab>", function()
	return super_tab("next")
end, { noremap = true, expr = true, silent = true })
vim.keymap.set("n", "<S-Tab>", function()
	return super_tab("previous")
end, { noremap = true, expr = true, silent = true })

-- ## NVIM.OPTIONS
SetTabSize()
vim.o.guicursor = vim.o.guicursor .. ",a:Cursor" -- append hl-Cursor to all modes
vim.o.winborder = "rounded"
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "80"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { wbr = "▀", vert = "█" } -- see unicode block
vim.opt.ignorecase = true
vim.opt.jumpoptions = "stack"
vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.ruler = false
vim.opt.sidescrolloff = 7
vim.opt.signcolumn = "no"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.undofile = true
function WinBar()
	local icon = vim.bo.modified and "" or ""
	return "%*%=%#Normal# " .. icon .. " %t %*%="
end

vim.opt.winbar = "%{%v:lua.WinBar()%}"

vim.cmd("colorscheme pax")
