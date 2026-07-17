return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>gs",
        "<cmd>LazyGit<cr>",
        desc = "LazyGit",
      },
    },
  }
}