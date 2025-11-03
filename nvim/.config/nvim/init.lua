-- ## INITIALISE
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, " ", "<nop>", { silent = true })
vim.diagnostic.config({
	severity_sort = true,
	signs = {
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsgReverse",
			[vim.diagnostic.severity.WARN] = "WarningMsgReverse",
		},
	},
})
vim.cmd("colorscheme pax")
vim.lsp.enable({ "lua_ls", "ts_ls", "eslint", "cssls", "nixd" })
local base_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
	on_attach = function(client, bufnr)
		if not base_on_attach then
			return
		end
		base_on_attach(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "LspEslintFixAll",
		})
	end,
})

-- ## PLUGINS.FZF-LUA
local fzf = require("fzf-lua")
local keymap = { builtin = { ["<C-d>"] = "preview-page-down", ["<C-u>"] = "preview-page-up" } }
local grep = { rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e" }
fzf.setup({ fzf_colors = true, keymap = keymap, grep = grep })
fzf.register_ui_select()
vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader>o", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>O", fzf.lsp_workspace_symbols)
vim.keymap.set("n", "<leader>d", fzf.lsp_document_diagnostics)
vim.keymap.set("n", "<leader>D", fzf.lsp_workspace_diagnostics)

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
	format_on_save = { quiet = true },
})

-- ## PLUGINS.VIM-TMUX-NAVIGATOR && PLUGINS.NVIM-SURROUND
vim.g.tmux_navigator_no_wrap = 1
require("nvim-surround").setup()

-- ## NVIM.GLOBALS
function SetTabSize(size) -- number | nil
	size = tonumber(size) or 4
	vim.opt.tabstop, vim.opt.shiftwidth, vim.opt.softtabstop = size, size, size
end
function WinBar()
	local icon = vim.bo.modified and "" or ""
	return "%=%#Normal# " .. icon .. " %t %*%="
end
function NetrwWinBar()
	return "%#Normal#  %t %*%=%#Normal# 󰋞 " .. vim.fn.getcwd() .. " "
end
function Ruler()
	if vim.api.nvim_get_mode().mode ~= "n" then
		return ""
	end

	local counts = vim.diagnostic.count(0)
	local error_count = counts[vim.diagnostic.severity.ERROR] or 0
	local warning_count = counts[vim.diagnostic.severity.WARN] or 0
	local error_string = error_count > 0 and "%#ErrorMsgReverse#    " or "    "
	local warning_string = warning_count > 0 and "%#WarningMsgReverse#    " or "    "
	return "%=" .. warning_string .. error_string
end

-- ## NVIM.AUTOCOMMANDS
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
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.opt_local.winbar = "%{%v:lua.NetrwWinBar()%}"
		vim.keymap.set("n", "h", "-", { remap = true, buffer = true })
		vim.keymap.set("n", "l", "<cr>", { remap = true, buffer = true })
	end,
})

-- ## NVIM.KEYBINDS
local function super_tab(direction) -- "next" | "previous"
	return function()
		if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
			return "<cmd>" .. "c" .. direction .. "<CR>"
		end

		return direction == "next" and "<Tab>" or "<S-Tab>"
	end
end
local function super_escape()
	if vim.v.hlsearch == 1 then
		vim.cmd("nohls")
	elseif vim.bo.filetype == "qf" or vim.bo.filetype == "help" then
		vim.cmd("close")
	elseif vim.bo.filetype == "netrw" then
		vim.cmd("Rex")
	end
end
vim.keymap.set("n", "<Esc>", super_escape, { silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Ex<cr>", { silent = true })
vim.keymap.set("n", "<Tab>", super_tab("next"), { noremap = true, expr = true, silent = true })
vim.keymap.set("n", "<S-Tab>", super_tab("previous"), { noremap = true, expr = true, silent = true })

-- ## NVIM.OPTIONS
SetTabSize(4)
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "80"
vim.opt.completeopt = "fuzzy,menu,noselect,noinsert"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { wbr = "▀", vert = "█" } -- see unicode block
vim.opt.guicursor:append({ "a:Cursor" }) -- append hl-Cursor to all modes
vim.opt.ignorecase = true
vim.opt.jumpoptions = "stack"
vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.rulerformat = "%{%v:lua.Ruler()%}"
vim.opt.sidescrolloff = 7
vim.opt.signcolumn = "no"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.winbar = "%{%v:lua.WinBar()%}"
vim.opt.winborder = "rounded"
