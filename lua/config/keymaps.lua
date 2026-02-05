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

-- CompetiTest
map('n', '<leader>ta', ':CompetiTest add_testcase<CR>', { desc = 'Add Test Case', unpack(opts) })
map('n', '<leader>te', ':CompetiTest edit_testcase<CR>', { desc = 'Edit Test Case (Select in UI)', unpack(opts) })
map('n', '<leader>td', ':CompetiTest delete_testcase<CR>', { desc = 'Delete Test Case (Select in UI)', unpack(opts) })
map('n', '<leader>tr', ':CompetiTest run<CR>', { desc = 'Run Tests', unpack(opts) })
map('n', '<leader>tu', ':CompetiTest show_ui<CR>', { desc = 'Open UI', unpack(opts) })

-- 2. Specific Number Management (Manual Entry)
-- These leave the command line open so you can type the number (e.g., "3") and hit Enter
map('n', '<leader>tE', ':CompetiTest edit_testcase ', { desc = 'Edit specific test #', noremap = true, silent = false })
map('n', '<leader>tD', ':CompetiTest delete_testcase ', { desc = 'Delete specific test #', noremap = true, silent = false })

-- ===== RUN C++ (F1) =====
vim.keymap.set("n", "<F1>", function()
  vim.cmd("w")
  local cmd = 'split | terminal g++ -g -std=c++17 % -o main.exe && main.exe'
  vim.cmd(cmd)
  vim.cmd("startinsert")
end)