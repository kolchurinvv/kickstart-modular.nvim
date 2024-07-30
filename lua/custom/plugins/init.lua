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
      local function biome_diagnostics(params, done)
        -- Define the Biome command for linting
        -- local command = 'node ~/.local/share/nvim/mason/packages/biome/node_modules/@biomejs/biome/bin/biome lint ' .. params.bufname
        local command = '/opt/homebrew/bin/biome lint ' .. params.bufname

        -- Run the command asynchronously
        local output = {}
        vim.fn.jobstart(command, {
          on_stdout = function(_, data)
            -- Collect data
            vim.list_extend(output, data)
          end,
          on_exit = function()
            -- Process collected output and then call done
            local diagnostics = {}
            for _, line in ipairs(output) do
              if line ~= '' then -- Make sure to skip empty lines or handle appropriately
                -- Parse line into diagnostics
                -- This is a placeholder; replace with actual parsing logic
                table.insert(diagnostics, {
                  row = 1,
                  col = 1,
                  message = line,
                  severity = vim.diagnostic.severity.ERROR,
                })
              end
            end
            done(diagnostics)
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
