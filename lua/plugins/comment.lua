return {
  {
    "numToStr/Comment.nvim",
    opts = {},
    keys = {
      {
        "<C-/>",
        function()
          require("Comment.api").toggle.linewise.current()
        end,
        mode = "n",
        desc = "Toggle comment line",
      },
      {
        "<C-_>", -- terminal compatibility
        function()
          require("Comment.api").toggle.linewise.current()
        end,
        mode = "n",
        desc = "Toggle comment line",
      },
    },
  },
}