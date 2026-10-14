-- return {
--   'MeanderingProgrammer/render-markdown.nvim',
--   dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
--   dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
--   dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
--   ---@module 'render-markdown'
--   ---@type render.md.UserConfig
--   opts = {
--     ft = { 'markdown' },
--   },
-- }
return {
  'OXY2DEV/markview.nvim',
  lazy = false,
  ft = { 'markdown', 'quarto', 'rmd' },

  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },

  config = function()
    require('markview').setup {
      preview = {
        enable = true,
        hybrid_modes = { 'n' },
        -- Un-render only the cursor line; the default clears the whole node, so a table goes raw as soon as the cursor enters it
        linewise_hybrid_mode = true,
      },
    }

    -- markview only partially renders tables under `wrap` (see markview.nvim-markdown.txt), so keep markdown windows unwrapped
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'markdown', 'quarto', 'rmd' },
      callback = function() vim.opt_local.wrap = false end,
    })
    vim.opt.linebreak = true
  end,
}
