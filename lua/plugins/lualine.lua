return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local theme = require("lualine.themes.onedark")
      for _, mode in pairs(theme) do
        if mode.c then mode.c.bg = "None" end
        if mode.x then mode.x.bg = "None" end
      end
      return {
        options = { theme = theme },
      }
    end,
  },
}
