require("config.options")
require("config.keymaps")
require("config.lazy")

-- startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
    vim.cmd("wincmd p")
  end,
})