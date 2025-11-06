return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'nvim-neotest/nvim-nio',
    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    -- inline eval-ed text
    'theHamsta/nvim-dap-virtual-text',
    -- go plugin for nvim-dap
    {
      'leoluz/nvim-dap-go',
      opts = {
        delve = {
          -- the path to the executable dlv which will be used for debugging.
          -- by default, this is the "dlv" executable on your PATH.
          path = 'dlv',
          -- time to wait for delve to initialize the debug session.
          -- default to 20 seconds
          initialize_timeout_sec = 20,
          -- a string that defines the port to start delve debugger.
          -- default to string "${port}" which instructs nvim-dap
          -- to start the process in a random available port.
          -- if you set a port in your debug configuration, its value will be
          -- assigned dynamically.
          port = '${port}',
          -- additional args to pass to dlv
          args = {},
          -- the build flags that are passed to delve.
          -- defaults to empty string, but can be used to provide flags
          -- such as "-tags=unit" to make sure the test suite is
          -- compiled during debugging, for example.
          -- passing build flags using args is ineffective, as those are
          -- ignored by delve in dap mode.
          -- avaliable ui interactive function to prompt for arguments get_arguments
          build_flags = {},
          -- whether the dlv process to be created detached or not. there is
          -- an issue on delve versions < 1.24.0 for Windows where this needs to be
          -- set to false, otherwise the dlv server creation will fail.
          -- avaliable ui interactive function to prompt for build flags: get_build_flags
          detached = vim.fn.has 'win32' == 0,
          -- the current working directory to run dlv from, if other than
          -- the current working directory.
          cwd = nil,
        },
        -- options related to running closest test
        tests = {
          -- enables verbosity when running the test.
          verbose = false,
        },
      },
    },
    {
      'igorlfs/nvim-dap-view',
      ---@module 'dap-view'
      ---@type dapview.Config
      opts = {
        winbar = {
          default_section = 'repl',
          sections = { 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl' },
        },
        windows = {
          terminal = {
            hide = { 'flutter', 'dart', 'go', 'pwa-node' },
          },
        },
      },
    },
  },
  config = function()
    local dap = require 'dap'
    local dap_virtual_text = require 'nvim-dap-virtual-text'
    local dapview = require 'dap-view'

    dap_virtual_text.setup {
      enabled = true, -- enable this plugin (the default)
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
      show_stop_reason = true, -- show stop reason when stopped for exceptions
      commented = false, -- prefix virtual text with comment string
      only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
      all_references = true, -- show virtual text on all all references of the variable (not only definitions)
      clear_on_continue = true, -- clear virtual text on "continue" (might cause flickering when stepping)
      --- A callback that determines how a variable is displayed or whether it should be omitted
      --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
      --- @param buf number
      --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
      --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
      --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
      --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
      display_callback = function(variable, buf, stackframe, node, options)
        -- by default, strip out new line characters
        if options.virt_text_pos == 'inline' then
          return ' = ' .. variable.value:gsub('%s+', ' ')
        else
          return variable.name .. ' = ' .. variable.value:gsub('%s+', ' ')
        end
      end,
      -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
      virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

      -- experimental features:
      all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
      virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
      virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
      -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    }

    vim.fn.sign_define('DapBreakpoint', {
      text = '❗', -- nerdfonts icon here
      texthl = 'DapBreakpointSymbol',
      linehl = 'DapBreakpoint',
      numhl = 'DapBreakpoint',
    })
    vim.fn.sign_define('DapStopped', {
      text = '🛑', -- nerdfonts icon here
      texthl = 'DapStoppedSymbol',
      linehl = 'DapBreakpoint',
      numhl = 'DapBreakpoint',
    })
    vim.fn.sign_define('DapLogPoint', {
      text = '💬', -- nerdfonts icon here
      texthl = 'DapLogPointSymbol',
      linehl = 'DapBreakpoint',
      numhl = 'DapBreakpoint',
    })
    vim.fn.sign_define('DapBreakpointCondition', {
      text = '❓', -- nerdfonts icon here
      texthl = 'DapBreakpointConditionSymbol',
      linehl = 'DapBreakpoint',
      numhl = 'DapBreakpoint',
    })
    vim.fn.sign_define('DapBreakpointRejected', {
      text = '❌', -- nerdfonts icon here
      texthl = 'DapBreakpointRejectedSymbol',
      linehl = 'DapBreakpoint',
      numhl = 'DapBreakpoint',
    })

    -- dap.defaults.fallback.exception_breakpoints = { 'uncaught' }

    for _, adapterType in ipairs { 'node', 'chrome', 'msedge' } do
      local pwaType = 'pwa-' .. adapterType

      dap.adapters[pwaType] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
            '${port}',
          },
        },
      }

      -- this allow us to handle launch.json configurations
      -- which specify type as "node" or "chrome" or "msedge"
      dap.adapters[adapterType] = function(cb, config)
        local nativeAdapter = dap.adapters[pwaType]

        config.type = pwaType

        if type(nativeAdapter) == 'function' then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    local enter_launch_url = function()
      local co = coroutine.running()
      return coroutine.create(function()
        vim.ui.input({ prompt = 'Enter URL: ', default = 'http://localhost:' }, function(url)
          if url == nil or url == '' then
            return
          else
            coroutine.resume(co, url)
          end
        end)
      end)
    end

    for _, language in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' } do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file using Deno (nvim-dap)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          runtimeExecutable = 'deno',
          runtimeArgs = { 'run', '--allow-all', '--unstable-cron', '--inspect-brk' },
          attachSimplePort = 9229,
          protocol = 'inspector',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process using Deno (nvim-dap)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          runtimeExecutable = 'deno',
          attachSimplePort = 9229,
          protocol = 'inspector',
          cwd = '${workspaceFolder}/pp-functions',
          pathMappings = {
            { localRoot = '${workspaceFolder}/pp-functions', remoteRoot = '/app' },
          },
          resolveSourceMapLocations = {
            '${workspaceFolder}/**',
            '!**/node_modules/**',
          },
          sourceMapPathOverrides = {
            ['file:///app/*'] = '${workspaceFolder}/pp-functions/*',
            ['file:///deno-dir/*'] = '${workspaceFolder}/.deno/*',
          },
          skipFiles = {
            '<node_internals>/**',
            '**/deno-dir/**',
          },
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file using Node.js (nvim-dap)',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process using Node.js (nvim-dap)',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        -- requires ts-node to be installed globally or locally
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file using Node.js with ts-node/register (nvim-dap)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          runtimeArgs = { '-r', 'ts-node/register' },
        },
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch Chrome (nvim-dap)',
          url = enter_launch_url,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          type = 'pwa-msedge',
          request = 'launch',
          name = 'Launch Edge (nvim-dap)',
          url = enter_launch_url,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
    end

    local convertArgStringToArray = function(config)
      local c = {}

      for k, v in pairs(vim.deepcopy(config)) do
        if k == 'args' and type(v) == 'string' then
          c[k] = require('dap.utils').splitstr(v)
        else
          c[k] = v
        end
      end

      return c
    end

    for key, _ in pairs(dap.configurations) do
      dap.listeners.on_config[key] = convertArgStringToArray
    end

    dap.listeners.before.attach.dapui_config = function()
      dapview.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapview.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapview.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapview.close()
    end

    -- Dap Keymaps
    vim.keymap.set('n', '<Leader>dt', dap.toggle_breakpoint, { desc = ' Toggle breakpoint' })
    vim.keymap.set('n', '<Leader>d?', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition/Log: ')
    end, { desc = ' Set conditional breakpoint' })
    vim.keymap.set('n', '<Leader>dbc', dap.clear_breakpoints, { desc = '󰗩 Clear all breakpoints' })
    vim.keymap.set('n', '<Leader>dbl', dap.list_breakpoints, { desc = ' List all breakpoints' })
    vim.keymap.set('n', '<Leader>dc', dap.continue, { desc = ' Continue' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = ' Step over' })
    vim.keymap.set('n', '<Leader>di', dap.step_into, { desc = ' Step into' })
    vim.keymap.set('n', '<Leader>do', dap.step_out, { desc = ' Step out' })
    vim.keymap.set('n', '<leader>dr', dap.run_last, { desc = ' Reload Session' })
    vim.keymap.set('n', '<Leader>dl', function()
      dap.set_breakpoint(null, null, vim.fn.input 'interpolated {variables} + message: ')
    end, { desc = 'Set Log Message' })
    vim.keymap.set('n', '<Leader>d_', dap.run_to_cursor, { desc = 'Run to cursor' })
    vim.keymap.set('n', '<Leader>dv', dapview.toggle, { desc = 'Toggle Debug [v]iew' })
  end,
}
