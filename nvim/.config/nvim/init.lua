-- SECTION: INTRO
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, " ", "<nop>", { silent = true })

-- SECTION: PLUGINS
local fzf = require("fzf-lua")
fzf.setup({
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
	keymap = {
		builtin = {
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
		},
	},
	files = {
		cwd_prompt = false,
		winopts = {
			height = 7,
			width = 0.5,
			row = 2,
			col = 1,
			preview = { hidden = true },
			title_pos = "left",
			title_flags = false,
		},
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e",
		winopts = {
			split = "belowright new",
			title_pos = "left",
			title_flags = false,
			preview = { wrap = true },
		},
	},
	helptags = {
		winopts = {
			split = "belowright new",
			title_pos = "left",
			title_flags = false,
		},
	},
})

vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader>o", fzf.treesitter)

-- PLUGINS.VIM-TMUX-NAVIGATOR
vim.g.tmux_navigator_no_wrap = 1

-- PLUGINS.NVIM-SURROUND
require("nvim-surround").setup()

-- PLUGINS.CONFORM
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

-- PLUGINS.NVIM-TREESITTER
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

-- NVIM.AUTOCOMMANDS
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

-- TODO extend this to handle loclist - grr does qflist in 0.11, gO populates loclist
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

-- NVIM.KEYBINDS
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

-- NVIM.OPTIONS
vim.o.guicursor = vim.o.guicursor .. ",a:Cursor" -- append hl-Cursor to all modes
vim.o.winborder = "rounded"
vim.opt.background = "dark"
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
vim.opt.shiftwidth = 0 -- follow vim.opt.tabstop
vim.opt.showcmd = false
vim.opt.sidescrolloff = 7
vim.opt.signcolumn = "no"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
-- TODO create way to toggle this easily, as lots of TS projects use 2.
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undofile = true
function WinBar()
	local icon = vim.bo.modified and "" or ""
	return "%*%=%#Normal# " .. icon .. " %t %*%="
end
vim.opt.winbar = "%{%v:lua.WinBar()%}"

vim.cmd("colorscheme pax")
