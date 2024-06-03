vim.o.guicursor = vim.o.guicursor .. ",a:Cursor" -- append hl-Cursor to all modes
vim.opt.background = "dark"
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "80"
vim.opt.completeopt = "longest,menu"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.jumpoptions = "stack"
vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.rulerformat = "%40(%=%{%v:lua.GetRulerFlags()%}%{%v:lua.GetRulerIcon()%}%#CustomRulerFile# %t %)"
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
vim.opt.undofile = true
vim.opt.wildmode = "longest:full,full"

vim.cmd("colorscheme pax_zero")

vim.diagnostic.config({
	float = { border = "rounded", severity_sort = true },
	severity_sort = true,
	virtual_text = false,
	jump = { float = true }, -- see https://github.com/neovim/neovim/pull/29067
})

function GetRulerFlags()
	local errors = vim.diagnostic.count(0)[vim.diagnostic.severity.ERROR] or 0
	return errors > 0 and "%#DiagnosticError# " or ""
end
function GetRulerIcon()
	local icon = vim.bo.modified and "" or ""
	return "%#CustomRulerSeparator#%#CustomRulerIcon#" .. icon .. " "
end

-- IDEA OUTLINE >
-- Winbar is the horizontal divider
--  - when active, fg = cursor, bg = vert separator
--  - when inactive, fg = vert separator, bg = vert separator
--  - this means we can toggle hl groups to show / hide the character
-- Vertical separator is the vertical divider
--  - just basic empty character to start with, bg = separator colour
--  progress from just win bar changing => top and bottom winbars changing
--  => side bars changing
vim.opt.winbar = "%="
vim.opt.fillchars = { eob = " ", wbr = "▄", vert = " " }
--up    ▀
--down  ▄
--full  █
--left  ▌
--right ▐
-- utils: nvim_win_get_position, fillchars

-- vim.api.nvim_create_autocmd({ "WinEnter", "VimEnter" }, {
-- 	callback = function(args)
-- 		vim.opt_local.fillchars = { eob = " ", vert = "▌", wbr = "▄", horizdown = "▄" }
-- 	end,
-- })
--
-- vim.api.nvim_create_autocmd({ "WinLeave" }, {
-- 	callback = function(args)
-- 		vim.opt_local.fillchars = { eob = " ", vert = "▐", horiz = "&", wbr = " ", horizdown = "▄" }
-- 	end,
-- })
