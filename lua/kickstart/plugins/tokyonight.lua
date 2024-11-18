return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      -- You can disable the default background setting here by using 'transparent = true'
      require('tokyonight').setup {
        style = 'night', -- or "night", "day"
        transparent = true, -- Enable transparency
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = 'transparent', -- Optional: make sidebars transparent
          floats = 'transparent', -- Optional: make floating windows transparent
        },
        on_colors = function(colors)
          -- You can override colors here if needed
        end,
        on_highlights = function(highlights, colors)
          -- You can override highlights here if needed
          highlights.Comment = { italic = true } -- example of changing Comment highlight
        end,
        cache = true,
        plugins = {
          all = true,
          auto = true,
        },
      }
    end,

    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
