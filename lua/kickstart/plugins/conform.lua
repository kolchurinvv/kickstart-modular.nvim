-- Setup default format on save if you wish
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' },
  callback = function()
    require('conform').format { lsp_fallback = true }
  end,
})

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },

    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { 'prettierd', 'prettier', stop_after_first = true },
      -- typescript = { 'prettierd', 'prettier', stop_after_first = true },

      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = function(bufnr)
          -- Helper: looks up from current file to project root for file matches
          local function has_prettier_config(bufnr)
            local config_patterns = {
              '.prettierrc',
              '.prettierrc.json',
              '.prettierrc.js',
              'prettier.config.js',
              '.prettierrc.yml',
              '.prettierrc.yaml',
            }
            local Path = require 'plenary.path'
            local cwd = vim.fn.getcwd()
            local filepath = vim.api.nvim_buf_get_name(bufnr)

            -- check for config in file dir and upwards
            local p = Path:new(filepath):parent()
            while tostring(p) ~= cwd and tostring(p) ~= '/' do
              for _, pattern in ipairs(config_patterns) do
                if Path:new(p, pattern):exists() then
                  return true
                end
              end
              p = p:parent()
            end

            -- check project root too
            for _, pattern in ipairs(config_patterns) do
              if Path:new(cwd, pattern):exists() then
                return true
              end
            end

            return false
          end
          if has_prettier_config(bufnr) then
            return { 'prettierd', 'prettier', stop_after_first = true }
          else
            return { 'biome' }
          end
        end,
        typescript = function(bufnr)
          -- Helper: looks up from current file to project root for file matches
          local function has_prettier_config(bufnr)
            local config_patterns = {
              '.prettierrc',
              '.prettierrc.json',
              '.prettierrc.js',
              'prettier.config.js',
              '.prettierrc.yml',
              '.prettierrc.yaml',
            }
            local Path = require 'plenary.path'
            local cwd = vim.fn.getcwd()
            local filepath = vim.api.nvim_buf_get_name(bufnr)

            -- check for config in file dir and upwards
            local p = Path:new(filepath):parent()
            while tostring(p) ~= cwd and tostring(p) ~= '/' do
              for _, pattern in ipairs(config_patterns) do
                if Path:new(p, pattern):exists() then
                  return true
                end
              end
              p = p:parent()
            end

            -- check project root too
            for _, pattern in ipairs(config_patterns) do
              if Path:new(cwd, pattern):exists() then
                return true
              end
            end

            return false
          end
          if has_prettier_config(bufnr) then
            return { 'prettierd', 'prettier', stop_after_first = true }
          else
            return { 'biome' }
          end
        end,
        -- Add more extensions/types as needed!
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
