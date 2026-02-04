return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("clangd", {
        cmd = { "C:/msys64/ucrt64/bin/clangd.exe" },
        init_options = {
          compilationDatabaseFallbackFlags = { "-std=c++17" },
        },
        capabilities = capabilities,
      })

      vim.lsp.enable("clangd")
    end,
  },

  -- Autocomplete (CMP)
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        window = {
          completion = {
            max_height = 10,
            max_width = 10,
            border = "rounded",
            scrollbar = true,
          },
          documentation = {
            border = "rounded",
          },
        },
        formatting = {
          fields = { "abbr", "kind" },
          format = function(entry, vim_item)
            vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, 30)
            local kind_icons = {
              Function = "ƒ", Method = "m", Variable = "𝓍", Field = "󰄶",
              Class = "C", Struct = "S", Enum = "E", Interface = "I",
              Module = "M", Constant = "π", Keyword = "K",
            }
            vim_item.kind = kind_icons[vim_item.kind] or ""
            return vim_item
          end,
        },
        
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.confirm({ select = true }) else fallback() end
          end),
        }),

        sources = {
          {
            name = "nvim_lsp",
            entry_filter = function(entry)
              return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Text
            end,
          },
          {
            name = "buffer",
            keyword_length = 3,
            entry_filter = function(entry)
              return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Text
            end,
          },
        },
      })
    end,
  },
}