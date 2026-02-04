return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 1. Setup UI (No Mason required)
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

      -- Auto-open UI listeners
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- 2. Adapter Definition: DIRECT GDB (Pure MSYS2)
      -- GDB 14+ supports DAP natively with the "-i dap" flag
      dap.adapters.gdb = {
        type = "executable",
        command = "C:/msys64/ucrt64/bin/gdb.exe",
        args = { "-i", "dap" }
      }

      -- 3. C++ Configuration
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.getcwd() .. "/main.exe"
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
      }
      -- Use the same config for C
      dap.configurations.c = dap.configurations.cpp

      -- ==========================================
      -- CUSTOM COMPILE & DEBUG FUNCTION
      -- ==========================================
      local function compile_and_debug()
        vim.cmd("w")
        local file = vim.fn.expand("%")
        local output = "main.exe"
        local compiler = "C:/msys64/ucrt64/bin/g++.exe"
        
        -- Compile command
        local compile_cmd = string.format('%s -g -std=c++17 "%s" -o "%s"', compiler, file, output)

        local result = vim.fn.system(compile_cmd)
        
        if vim.v.shell_error ~= 0 then
          print("Compilation failed:\n" .. result)
        else
          print("Compiled successfully. Starting GDB...")
          dap.continue()
        end
      end

      -- Keymaps
      vim.keymap.set('n', '<F2>', compile_and_debug, { desc = "Compile and Debug" })
      vim.keymap.set('n', '<F5>', function()
        if dap.session() then dap.continue() else print("No active debug session. Press F2.") end
      end, { noremap = true, silent = true })

      vim.keymap.set('n', '<F10>', dap.step_over)
      vim.keymap.set('n', '<F11>', dap.step_into)
      vim.keymap.set('n', '<F12>', dap.step_out)

      vim.keymap.set('n', '<F3>', function()
        dap.terminate()
        dapui.close()
      end)

      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint)
      vim.keymap.set("n", "<leader>dw", function()
        vim.ui.input({ prompt = "Watch expression: " }, function(expr)
          if expr then require("dapui").elements.watches.add(expr) end
        end)
      end)
    end
  },
}