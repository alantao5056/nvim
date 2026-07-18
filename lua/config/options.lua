vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }
vim.opt.cmdheight = 0
vim.opt.laststatus = 3

-- indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.signcolumn = "yes"
vim.opt.mouse = "a"

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- clipboard
vim.opt.clipboard:append("unnamedplus")

-- Disable autocomment on enter
vim.cmd([[autocmd FileType * set formatoptions-=ro]])
