-- ===== BASIC SETTINGS =====
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.o.smartindent = true
vim.opt.signcolumn = "yes"
vim.o.mouse = "a"

-- Disable autocomment on enter
vim.cmd([[autocmd FileType * set formatoptions-=ro]])

-- Keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal mode
vim.api.nvim_set_keymap("n", "<C-a>", "ggVG", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-c>", "ggVG\"+y", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-x>", "ggVG\"+d", { noremap = true, silent = true })

-- Visual mode
vim.api.nvim_set_keymap("v", "<C-c>", "\"+y", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-x>", "\"+d", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-a>", "<Esc>ggVG", { noremap = true, silent = true })

-- Insert mode (escape to normal mode temporarily)
vim.api.nvim_set_keymap("i", "<C-a>", "<Esc>ggVG", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "<C-H>", "<C-W>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S>", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-S>", "<Esc>:w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "E", "$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "B", "^", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Z>", "u", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-Z>", "<Esc>u", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { noremap = true, silent = true })

-- ===== LAZY.NVIM BOOTSTRAP =====
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===== PLUGINS =====
require("lazy").setup({
  -- Theme
  --[[
  {
    "loctvl842/monokai-pro.nvim",
    name = "monokai-pro",
    config = function()
      require("monokai-pro").setup({ filter = "pro" })
      vim.cmd.colorscheme "monokai-pro"
    end
  },
  ]]

  {
    "olimorris/onedarkpro.nvim",
    name = "onedarkpro",
    priority=1000,
    config = function()
      require("onedarkpro").setup({ })
      vim.cmd("colorscheme onedark")
    end
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = {
        char = '▏'
      }
    },
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  -- Tree-sitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup({
        ensure_installed = { "cpp", "c" },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
      })
    end,
  },

  -- LSP
  --[[
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      lspconfig.clangd.setup({
      --vim.lsp.config("clangd", {
        cmd = { "C:/Program Files/LLVM/bin/clangd.exe" },
        init_options = {
          compilationDatabaseFallbackFlags = { "-std=c++17" },
        },
        --capabilities = require("cmp_nvim_lsp").default_capabilities(),
        capabilities = capabilities,
      })
    end,
  },
  ]]
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("clangd", {
        cmd = { "C:/Program Files/LLVM/bin/clangd.exe" },
        init_options = {
          compilationDatabaseFallbackFlags = { "-std=c++17" },
        },
        capabilities = capabilities,
      })

      vim.lsp.enable("clangd")
    end,
  },

  -- Autocomplete
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

            -- TODO add more and better icons
            local kind_icons = {
              Function = "ƒ",
              Method = "m",
              Variable = "𝓍",
              Field = "󰄶",
              Class = "C",
              Struct = "S",
              Enum = "E",
              Interface = "I",
              Module = "M",
              Constant = "π",
              Keyword = "K",
            }

            vim_item.kind = kind_icons[vim_item.kind] or ""
            return vim_item
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
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

  -- ===== DEBUGGER (MINIMAL UI) =====
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 1. Setup Mason
      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "cpptools" },
        automatic_installation = true,
      })

      -- 2. Setup MINIMAL UI
      dapui.setup({
        controls = { enabled = false },
        
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.6 }, 
              { id = "watches", size = 0.4 }, 
            },
            size = 0.30,
            position = "left",
          },
        },
      })

      -- Auto UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- 3. Adapter Definition
      local extension_path = vim.fn.stdpath("data") .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7.exe"
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = "executable",
        command = extension_path,
        options = { detached = false }
      }

      -- 4. C++ Config
      dap.configurations.cpp = {
        {
          name = "Launch main.exe",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.getcwd() .. "/main.exe"
          end,
          cwd = vim.fn.getcwd(),
          stopAtEntry = false,
          MIMode = 'gdb',
          miDebuggerPath = 'gdb',
          setupCommands = {
            {
              text = "-enable-pretty-printing",
              description = "enable pretty printing",
              ignoreFailures = false
            },
          },
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- ==========================================================
      -- CUSTOM FUNCTIONS FOR YOUR REQUESTS
      -- ==========================================================

      -- 1. F2: Compile then Start Debugging
      local function compile_and_debug()
        vim.cmd("w")
        local file = vim.fn.expand("%")
        local output = "main.exe"
        local compile_cmd = string.format('g++ -g -std=c++17 "%s" -o "%s"', file, output)

        local result = vim.fn.system(compile_cmd)
        if vim.v.shell_error ~= 0 then
          print("Compilation failed:\n" .. result)
        else
          --require("dap").run(dap.configurations.cpp[1])
          dap.continue()
        end
      end

      -- Keymaps
      vim.keymap.set('n', '<F2>', compile_and_debug, { desc = "Compile and Debug" })
      vim.keymap.set('n', '<F5>', function()
        if dap.session() then
          dap.continue()
        else
          print("No active debug session. Press F2 to start.")
        end
      end, { noremap = true, silent = true })
      vim.keymap.set('n', '<F10>', dap.step_over, { noremap = true, silent = true })
      vim.keymap.set('n', '<F11>', dap.step_into, { noremap = true, silent = true })
      vim.keymap.set('n', '<F12>', dap.step_out, { noremap = true, silent = true })
      vim.keymap.set('n', '<F3>', function()
        local dap = require("dap")
        local killed_something = false

        -- 1. Stop Debugger if active
        if dap.session() then
          dap.terminate()
          require("dapui").close()
          print("Debugger Stopped.")
          killed_something = true
        end

        if not killed_something then
          print("Nothing is currently running.")
        end
      end, { noremap = true, silent = true })

      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { noremap = true, silent = true })

      vim.keymap.set('n', '<leader>B', function()
        local dap = require("dap")
        vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
          if condition then
            dap.set_breakpoint(condition)
          end
        end)
      end, { desc = "Set conditional breakpoint" })

      vim.keymap.set("n", "<leader>dw", function()
        vim.ui.input({ prompt = "Watch global variable: " }, function(expr)
          if expr then
            require("dapui").elements.watches.add(expr)
          end
        end)
      end, { desc = "Add global watch" })
      
      -- Toggle UI manually if needed
      vim.keymap.set('n', '<leader>du', dapui.toggle, { noremap = true, silent = true })
    end
  },
})

-- ===== RUN C++ =====
vim.keymap.set("n", "<F1>", function()
  vim.cmd("w")
  vim.cmd('split | terminal g++ -g -std=c++17 % -o main.exe && main.exe')
  vim.cmd("startinsert")
end)

