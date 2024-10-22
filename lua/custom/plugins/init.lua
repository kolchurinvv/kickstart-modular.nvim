-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'leafoftree/vim-svelte-plugin',
    event = 'VeryLazy',
    ts = { 'svelte' },
    config = function()
      vim.g.vim_svelte_plugin_use_sass = 1
      -- vim.g.vim_svelte_plugin_load_full_syntax = 1
      vim.g.vim_svelte_plugin_use_typescript = 1
      -- vim.g.vim_svelte_plugin_debug = 1
    end,
  },
  {
    'nvimtools/none-ls.nvim',
    event = 'VeryLazy',
    opts = function()
      local none_ls = require 'null-ls'

      -- Define a function to run `biome lint` and capture diagnostics
      local biome_diagnostics = function(params, done)
        local command = { 'biome', 'lint', '--reporter=github', '--max-diagnostics=none', params.bufname }
        local output = {}

        -- Use `jobstart` to run the `biome lint` command
        vim.fn.jobstart(command, {
          on_stdout = function(_, data)
            --   -- print('stdout data' .. vim.inspect(data))
            --   -- Capture stdout data
            vim.list_extend(output, data)
          end,
          on_stderr = function(_, data)
            -- print('stderr data' .. vim.inspect(data))
            vim.list_extend(output, data)
          end,
          on_exit = function(_, code)
            -- if biome finds erors it outputs to stderr as well, which causes exit code to be 1
            -- if code == 0 then
            local diagnostics = {}
            for _, line in ipairs(output) do
              if line ~= '' then
                -- below is the summary that we have to skip
                if line:match '^lint ━━━━━━━━━' then
                  break
                end
                -- print('parsed line: ' .. vim.inspect(line))
                -- Parse the biome lint output
                local severity_str, rule, file, row, col, message =
                  line:match '::(%w+)%s+title=([^,]+),file=([^,]+),line=(%d+),endLine=%d+,col=(%d+),endColumn=%d+::(.+)'
                local severity_map = {
                  error = vim.diagnostic.severity.ERROR,
                  warning = vim.diagnostic.severity.WARN,
                  info = vim.diagnostic.severity.INFO,
                  hint = vim.diagnostic.severity.HINT,
                  note = vim.diagnostic.severity.HINT,
                }
                local severity = severity_map[severity_str] or vim.diagnostic.severity.ERROR
                -- print 'breakdown:\n'
                -- print('file ' .. file)
                -- print('row ' .. row)
                -- print('col ' .. col)
                -- print('severity ' .. severity_str)
                -- print('rule ' .. rule)
                -- print('message ' .. message)
                if file and row and col then
                  -- Add diagnostic to the list
                  table.insert(diagnostics, {
                    row = tonumber(row),
                    col = tonumber(col),
                    rule = rule,
                    message = message,
                    severity = severity,
                  })
                end
              end
            end
            done(diagnostics)
            -- else
            --   done {}
            -- end
          end,
        })
      end

      none_ls.register {
        name = 'biome',
        meta = {
          url = 'https://biome.dev',
          description = 'biome integration for linting',
        },
        method = none_ls.methods.DIAGNOSTICS,
        filetypes = { 'javascript', 'typescript' },
        generator = {
          fn = biome_diagnostics,
          async = true,
        },
      }

      none_ls.setup {
        sources = { none_ls.builtins.formatting.biome },
      }
    end,
  },

  {
    'simrat39/rust-tools.nvim',
    ft = 'rust',
    dependensies = 'mason-lspconfig',
  },

  {
    'saecki/crates.nvim',
    fs = { 'rust', 'toml' },
    config = function(_, opts)
      local crates = require 'crates'
      crates.setup(opts)
      require('cmp').setup.buffer {
        sources = { { name = 'crates' } },
      }
      crates.show()
    end,
  },
}
