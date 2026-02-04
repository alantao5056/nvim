return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup({
        ensure_installed = { "cpp", "c", "vim", "lua" },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
      })
    end,
  }
}