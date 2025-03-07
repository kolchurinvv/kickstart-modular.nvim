return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- You can disable the default background setting here by using 'transparent = true'
      require('tokyonight').setup {
        style = 'storm', -- or "night", "day"
        light_style = 'day',
        transparent = true, -- Enable transparency
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          -- sidebars = 'transparent', -- Optional: make sidebars transparent
          floats = 'normal', -- Optional: make floating windows transparent or dark or normal
        },

        --- You can override specific color groups to use other groups or a hex color
        --- function will be called with a ColorScheme table
        --- @param colors ColkrScheme
        on_colors = function(colors)
          -- You can override colors here if needed
        end,

        --- You can override specific highlights to use other groups or a hex color
        --- function will be called with a Highlights and ColorScheme table
        ---@param highlights tokyonight.Highlights
        ---@param colors ColorScheme
        on_highlights = function(highlights, colors)
          -- You can override highlights here if needed
          highlights.Comment = { italic = false } -- example of changing Comment highlight
        end,
        cache = true,
        plugins = {
          all = true,
          auto = true,
        },
      }
      vim.cmd.colorscheme 'tokyonight-storm'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
