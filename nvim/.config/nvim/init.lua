-- SECTION: INTRO
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, " ", "<nop>", { silent = true })

-- SECTION: PLUGINS
local fzf = require("fzf-lua")
fzf.setup({
	keymap = {
		builtin = {
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
		},
	},
	files = { cwd_prompt = false },
	lsp = { jump_to_single_result = true },
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
	grep = { rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e" },
})

vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>o", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>O", fzf.lsp_live_workspace_symbols)
vim.keymap.set("n", "<leader>r", fzf.lsp_references)
vim.keymap.set("n", "<leader>d", fzf.lsp_definitions)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader>k", fzf.keymaps)
vim.keymap.set("n", "<leader><leader>", fzf.resume)

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
		lsp_fallback = true,
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

-- SECTION: NVIM
vim.lsp.config("*", {
	on_attach = function(client)
		if client.config.root_dir == nil then
			client.stop(client, true)
		end
	end,
})
vim.lsp.enable({ "lua_ls", "ts_ls", "eslint", "cssls", "nixd" })
vim.diagnostic.config({
	severity_sort = true,
	jump = { float = true },
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

-- Keep these below 6 in length, just saves us checking long lines.
local snippets_by_filetype = {
	lua = {
		fn = "function ${1:name}(${2:args})\n\t${0}\nend",
	},
	-- TODO handle all ecma file types in one entry
	ecma = {},
}

vim.api.nvim_create_autocmd("filetype", {
	pattern = "*",
	callback = function()
		local max_snippet_shortcut_length = 6
		local snippets = snippets_by_filetype[vim.bo.filetype] or {}
		if not snippets then
			return
		end

		vim.keymap.set("i", "<Tab>", function()
			if vim.snippet.active() then
				return vim.snippet.jump(1)
			end

			local current_col_num = vim.fn.col(".") - 1
			local current_line_content = vim.fn.getline(".")
			local start_col = math.max(1, current_col_num - max_snippet_shortcut_length)
			local target = current_line_content:sub(start_col, current_col_num)
			local matched_trigger = target:match("!(%w+)$")

			if not snippets[matched_trigger] then
				return vim.api.nvim_feedkeys("\t", "n", false)
			end

			local new_content = current_line_content:sub(1, start_col + max_snippet_shortcut_length - #matched_trigger)
				.. current_line_content:sub(start_col)
			vim.api.nvim_set_current_line(new_content)
			vim.schedule(function()
				vim.snippet.expand(snippets[matched_trigger])
			end)
		end, { buffer = true })
	end,
})

-- TODO move to snippets
-- add abbreviations to these filetypes
vim.api.nvim_create_autocmd("filetype", {
	-- TODO extract all these filetypes to be ECMA
	pattern = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
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

-- TODO extend this to handle loclist in the same way - if you use grr in 0.11, that
-- populates the qf, but using gO (capital o) populates the loclist.
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
-- TODO this is sort of like "super escape". May want to look at a "super tab", depending
-- on how snippets work, and it may be worthwhile due to the tab location (thumb cluster).
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
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })
-- TODO play around with this and vim.lsp.completion - this may allow us to get
-- autoimport in TS!
vim.keymap.set("i", "<C-j>", "<C-x><C-o>", { silent = true }) -- Lsp completion
-- TODO look at why this does not work for olympus.
vim.api.nvim_create_user_command("Tsc", function()
	local ts_root = vim.fs.root(0, "tsconfig") -- may need updating in a TS proj at work
	if ts_root == nil then
		return print("Unable to find tsconfig")
	end
	vim.cmd("compiler tsc | echo 'Building TypeScript...' | silent make! --noEmit | echo 'TypeScript built.' | copen")
end, {})

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

vim.cmd("colorscheme pax")
