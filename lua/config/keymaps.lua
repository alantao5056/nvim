vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Windows Style Copy/Paste
map("n", "<C-a>", "ggVG", opts)
map("n", "<C-c>", "ggVG\"+y", opts)
map("n", "<C-x>", "ggVG\"+d", opts)

map("v", "<C-c>", "\"+y", opts)
map("v", "<C-x>", "\"+d", opts)
map("v", "<C-a>", "<Esc>ggVG", opts)

map("i", "<C-a>", "<Esc>ggVG", opts)

-- Window/Buffer navigation
map("i", "<C-H>", "<C-W>", opts)
map("n", "<C-S>", ":w<CR>", opts)
map("i", "<C-S>", "<Esc>:w<CR>", opts)
map("n", "E", "$", opts)
map("n", "B", "^", opts)

-- Undo
map("n", "<C-Z>", "u", opts)
map("i", "<C-Z>", "<Esc>u", opts)

-- Diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

-- ===== RUN C++ (F1) =====
vim.keymap.set("n", "<F1>", function()
  vim.cmd("w")
  local cmd = 'split | terminal g++ -g -std=c++17 % -o main.exe && main.exe'
  vim.cmd(cmd)
  vim.cmd("startinsert")
end)