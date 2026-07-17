return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local tree = require("nvim-tree")
    local api = require("nvim-tree.api")

    tree.setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
      renderer = {
        icons = {
          glyphs = {
            git = {
              unstaged = "M",
              staged = "S",
              unmerged = "U",
              renamed = "R",
              untracked = "?",
              deleted = "D",
              ignored = "I",
            },
          },
        },
      },
    })

    vim.keymap.set("n", "<leader>e", api.tree.focus, { desc = "Focus file tree" })
  end,
}
