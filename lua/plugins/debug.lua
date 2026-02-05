return {
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

    -- ==========================================================
    -- UCRT64 toolchain paths (EDIT if your MSYS2 is elsewhere)
    -- ==========================================================
    local ucrt64_root = vim.fn.has("win32") == 1 and "C:/msys64/ucrt64" or "/ucrt64"
    local ucrt64_gdb  = ucrt64_root .. "/bin/gdb.exe"
    local ucrt64_gpp  = ucrt64_root .. "/bin/g++.exe"

    -- If you launch Neovim *inside* MSYS2 UCRT64 shell, these may already be on PATH.
    -- These fallbacks make it work either way.
    if vim.fn.executable(ucrt64_gdb) == 0 then
      local p = vim.fn.exepath("gdb")
      if p ~= "" then ucrt64_gdb = p end
    end
    if vim.fn.executable(ucrt64_gpp) == 0 then
      local p = vim.fn.exepath("g++")
      if p ~= "" then ucrt64_gpp = p end
    end

    -- 1. Setup Mason (only used to install cpptools adapter here)
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

    -- ==========================================================
    -- SAVE/RESTORE full UI layout + keep dapui + restore nvim-tree
    -- ==========================================================
    local ui_state = {
      session_file = nil,
      old_sessionoptions = nil,
      nvimtree_was_open = false,
      code_buf = nil,
    }

    local function is_nvim_tree_open()
      local ok_api, api = pcall(require, "nvim-tree.api")
      if ok_api and api.tree and api.tree.is_visible then
        return api.tree.is_visible()
      end

      local ok_view, view = pcall(require, "nvim-tree.view")
      if ok_view and view.is_visible then
        return view.is_visible()
      end

      return false
    end

    local function close_nvim_tree()
      pcall(function()
        require("nvim-tree.api").tree.close()
      end)
    end

    local function open_nvim_tree()
      pcall(function()
        require("nvim-tree.api").tree.open()
      end)
    end

    local function save_ui_layout()
      if ui_state.session_file then return end

      ui_state.code_buf = vim.api.nvim_get_current_buf()

      ui_state.nvimtree_was_open = is_nvim_tree_open()
      close_nvim_tree()

      ui_state.session_file = vim.fn.tempname() .. ".vim"
      ui_state.old_sessionoptions = vim.opt.sessionoptions:get()

      -- Capture tabs/splits/etc (and terminals, if you want "ANY window")
      vim.opt.sessionoptions = {
        "buffers",
        "curdir",
        "folds",
        "globals",
        "help",
        "tabpages",
        "terminal",
        "winsize",
      }

      vim.cmd("silent! mksession! " .. vim.fn.fnameescape(ui_state.session_file))
    end

    local function collapse_to_code_only()
      -- Close tree first so it doesn't "win" the layout
      close_nvim_tree()

      vim.cmd("silent! tabonly")
      vim.cmd("silent! only")
    end

    local function focus_code_window()
      -- Prefer the exact buffer you were in when you started debugging
      if ui_state.code_buf and vim.api.nvim_buf_is_valid(ui_state.code_buf) then
        local wins = vim.fn.win_findbuf(ui_state.code_buf)
        for _, w in ipairs(wins) do
          if vim.api.nvim_win_is_valid(w) then
            vim.api.nvim_set_current_win(w)
            return
          end
        end
      end

      -- Fallback: pick any "normal" file window (not NvimTree / help / terminal)
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(w)
        local bt = vim.bo[buf].buftype
        local ft = vim.bo[buf].filetype
        if bt == "" and ft ~= "NvimTree" then
          vim.api.nvim_set_current_win(w)
          return
        end
      end
    end

    local function restore_ui_layout()
      if not ui_state.session_file then return end

      local session = ui_state.session_file
      ui_state.session_file = nil

      -- Restore user sessionoptions
      if ui_state.old_sessionoptions then
        vim.opt.sessionoptions = ui_state.old_sessionoptions
        ui_state.old_sessionoptions = nil
      end

      if vim.fn.filereadable(session) == 1 then
        vim.cmd("silent! source " .. vim.fn.fnameescape(session))
        pcall(vim.fn.delete, session)
      end

      -- Reopen tree if it was open before debugging started
      if ui_state.nvimtree_was_open then
        open_nvim_tree()
      end

      focus_code_window()
    end

    -- Hook into DAP lifecycle:
    dap.listeners.after.event_initialized["layout_guard"] = function()
      save_ui_layout()
      collapse_to_code_only()

      -- IMPORTANT: open your debug UI AFTER collapsing
      pcall(function() require("dapui").open() end)
    end

    local function end_debug_restore()
      -- close dap-ui *before* restoring layout
      pcall(function() require("dapui").close() end)
      restore_ui_layout()
    end

    dap.listeners.before.event_terminated["layout_guard"] = end_debug_restore
    dap.listeners.before.event_exited["layout_guard"] = end_debug_restore
    dap.listeners.before.disconnect["layout_guard"] = end_debug_restore

    -- 3. Adapter Definition (cpptools)
    local extension_path =
      vim.fn.stdpath("data")
      .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7.exe"

    dap.adapters.cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = extension_path,
      options = { detached = false },
    }

    -- 4. C++ Config (force UCRT64 gdb)
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
        MIMode = "gdb",
        miDebuggerPath = ucrt64_gdb, -- <<< THIS is the key change
        setupCommands = {
          {
            text = "-enable-pretty-printing",
            description = "enable pretty printing",
            ignoreFailures = false,
          },
        },
      },
    }
    dap.configurations.c = dap.configurations.cpp

    -- ==========================================================
    -- CUSTOM FUNCTIONS
    -- ==========================================================

    -- F2: Compile then Start Debugging (force UCRT64 g++)
    local function compile_and_debug()
      vim.cmd("w")
      local file = vim.fn.expand("%")
      local output = "main.exe"
      local compile_cmd = string.format('"%s" -g -std=c++17 "%s" -o "%s"', ucrt64_gpp, file, output)

      local result = vim.fn.system(compile_cmd)
      if vim.v.shell_error ~= 0 then
        print("Compilation failed:\n" .. result)
      else
        dap.continue()
      end
    end

    -- Keymaps
    vim.keymap.set("n", "<F2>", compile_and_debug, { desc = "Compile and Debug" })
    vim.keymap.set("n", "<F5>", function()
      if dap.session() then
        dap.continue()
      else
        print("No active debug session. Press F2 to start.")
      end
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<F10>", dap.step_over, { noremap = true, silent = true })
    vim.keymap.set("n", "<F11>", dap.step_into, { noremap = true, silent = true })
    vim.keymap.set("n", "<F12>", dap.step_out, { noremap = true, silent = true })

    vim.keymap.set("n", "<F3>", function()
      local killed_something = false
      if dap.session() then
        dap.terminate()
        dapui.close()
        print("Debugger Stopped.")
        killed_something = true
      end
      if not killed_something then
        print("Nothing is currently running.")
      end
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>B", function()
      vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
        if condition then dap.set_breakpoint(condition) end
      end)
    end, { desc = "Set conditional breakpoint" })

    vim.keymap.set("n", "<leader>dw", function()
      vim.ui.input({ prompt = "Watch global variable: " }, function(expr)
        if expr then
          require("dapui").elements.watches.add(expr)
        end
      end)
    end, { desc = "Add global watch" })

    vim.keymap.set("n", "<leader>du", dapui.toggle, { noremap = true, silent = true })
  end,
}
