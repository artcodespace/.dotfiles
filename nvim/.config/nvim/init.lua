-- ## INITIALISE
require("vim._core.ui2").enable({
	msg = { target = "msg" },
})
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
	status = {
		enabled = false, -- hide this status from the ruler
		format = function(counts)
			local parts = {}
			if counts[vim.diagnostic.severity.WARN] or 0 > 0 then
				table.insert(parts, "%#WarningFlag#▀W▀")
			end
			if counts[vim.diagnostic.severity.ERROR] or 0 > 0 then
				table.insert(parts, "%#ErrorFlag#▀E▀")
			end
			return table.concat(parts, "")
		end,
	},
})
vim.lsp.enable({ "lua_ls", "ts_ls", "biome", "eslint", "cssls", "expert", "nixd" })
vim.cmd("colorscheme pax")

-- ## PLUGINS.FZF-LUA
local fzf = require("fzf-lua")
local keymap = { builtin = { ["<C-d>"] = "preview-page-down", ["<C-u>"] = "preview-page-up" } }
local grep = { rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e" }
fzf.setup({ fzf_colors = true, keymap = keymap, grep = grep })
fzf.register_ui_select()
vim.keymap.set("n", "<leader><leader>", fzf.resume)
vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader>o", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>O", fzf.lsp_workspace_symbols)
vim.keymap.set("n", "<leader>d", fzf.lsp_document_diagnostics)

-- ## PLUGINS.CONFORM
require("conform").setup({
	formatters_by_ft = {
		javascript = { "biome", "prettierd", stop_after_first = true },
		typescript = { "biome", "prettierd", stop_after_first = true },
		javascriptreact = { "biome", "prettierd", stop_after_first = true },
		typescriptreact = { "biome", "prettierd", stop_after_first = true },
		jsonc = { "biome" },
		json = { "prettierd" },
		css = { "prettierd" },
		html = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		lua = { "stylua" },
		nix = { "alejandra" },
		go = { "gofmt" },
	},
	format_on_save = { quiet = true },
})

-- ## PLUGINS.VIM-TMUX-NAVIGATOR && PLUGINS.NVIM-SURROUND
vim.g.tmux_navigator_no_wrap = 1
require("nvim-surround").setup()

-- ## NVIM.GLOBALS
function SetTabSize(size) -- number | nil
	size = tonumber(size) or 2
	vim.opt.tabstop, vim.opt.shiftwidth, vim.opt.softtabstop = size, size, size
end
function WinBar()
	local cwd_tail = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	local parts = { "%#Normal#", cwd_tail, "/%<%f%* %=" }
	if vim.api.nvim_get_mode().mode == "n" then
		table.insert(parts, vim.diagnostic.status(0))
	end
	if vim.bo.modified then
		table.insert(parts, "%#UnsavedChangesFlag#▀+▀")
	end
	return table.concat(parts)
end
function StatusColumn()
	local is_current = vim.v.lnum == vim.fn.line(".")
	if is_current then
		return "%#Cursor#%l%#CursorLinePointer#"
	end
	return "%-4l   ▐"
end

-- ## NVIM.AUTOCMDS
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "eslint" then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				command = "LspEslintFixAll",
			})
		end
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
		vim.opt_local.winbar = "%#Normal#  %{b:netrw_curdir} %*"
		vim.keymap.set("n", "h", "-", { remap = true, buffer = true })
		vim.keymap.set("n", "l", "<cr>", { remap = true, buffer = true })
	end,
})

-- ## NVIM.KEYBINDS
local function super_tab(direction) -- "next" | "previous"
	return function()
		if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
			return "<cmd>c" .. direction .. "<CR>"
		end
		if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
			return "<cmd>l" .. direction .. "<CR>"
		end

		-- TODO extend this for the loclist, used by gO (capital o)
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
SetTabSize(2)
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.colorcolumn = "80"
vim.opt.completeopt = "fuzzy,menu,noselect,noinsert"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { wbr = "▀", vert = "█" } -- see unicode block
vim.opt.guicursor:append({ "a:Cursor" }) -- append hl-Cursor to all modes
vim.opt.ignorecase = true
vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.ruler = false
vim.opt.sidescrolloff = 7
vim.opt.signcolumn = "no"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.statuscolumn = "%{%v:lua.StatusColumn()%}"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.winbar = "%{%v:lua.WinBar()%}"
vim.opt.winborder = "rounded"

---@param name string the name for feedback and the qf list
---@param root_list string[] pattern for identifying project root
---@param command_list string[] the command to run
---@param efm string the error format string see :errorformat
local function async_to_qf(name, root_list, command_list, efm)
	local root = vim.fs.root(0, root_list)
	if not root then
		vim.notify(name .. ": no root found", vim.log.levels.ERROR)
		return
	end
	vim.notify(name .. ": running compiler from " .. root .. "...")
	vim.system(
		command_list,
		{ text = true, cwd = root },
		vim.schedule_wrap(function(o)
			local stdout = vim.trim(o.stdout or "")
			vim.fn.setqflist({}, " ", {
				title = name .. " output",
				lines = stdout ~= "" and vim.split(stdout, "\n") or {},
				efm = efm,
			})
			local items = vim.fn.getqflist()
			if vim.tbl_isempty(items) then
				vim.notify(name .. ": no errors")
				vim.cmd("cclose")
			else
				vim.notify(name .. ": " .. #items .. " error" .. (#items == 1 and "" or "s") .. " sent to qf.")
				vim.cmd("copen")
			end
		end)
	)
end

vim.api.nvim_create_user_command("Tsc", function()
	async_to_qf(
		"Tsc",
		{ "package.json" },
		{ "bun", "tsc", "--noEmit" },
		"%f(%l\\,%c): %trror %m,%f(%l\\,%c): %tarning %m,%-G%m"
	)
end, {})
