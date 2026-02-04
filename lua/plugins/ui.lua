return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    config = function()
      require("onedarkpro").setup({})
      vim.cmd("colorscheme onedark")
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = '▏' }
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },
}