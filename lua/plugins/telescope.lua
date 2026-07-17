return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>fp",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Find in Project",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Find in Current File",
      }
    },
  },
}