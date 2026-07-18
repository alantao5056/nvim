return {
  {
    "numToStr/Comment.nvim",
    opts = {},
    keys = {
      -- Normal mode
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
      -- Visual / visual-line mode
      {
        "<C-/>",
        "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
        mode = "x",
        desc = "Toggle comment for selection",
      },
      {
        "<C-_>", -- terminal compatibility
        "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
        mode = "x",
        desc = "Toggle comment for selection",
      },
      -- Insert mode
      {
        "<C-/>",
        function()
          require("Comment.api").toggle.linewise.current()
        end,
        mode = "i",
        desc = "Toggle comment line",
      },
      {
        "<C-_>", -- terminal compatibility
        function()
          require("Comment.api").toggle.linewise.current()
        end,
        mode = "i",
        desc = "Toggle comment line",
      },
    },
  },
}