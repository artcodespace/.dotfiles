vim.g.netrw_banner = 0
vim.opt_local.colorcolumn = ""
vim.keymap.set("n", "<esc>", "<cmd>Rex<cr>", { remap = true, buffer = true })
vim.keymap.set("n", "h", "-", { remap = true, buffer = true })
vim.keymap.set("n", "l", "<cr>", { remap = true, buffer = true })
vim.keymap.del("n", "<C-l>", { buffer = true })
