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
      },
    }

    vim.opt.wrap = true
    vim.opt.linebreak = true
  end,
}
