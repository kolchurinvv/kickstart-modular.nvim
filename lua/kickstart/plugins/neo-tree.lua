-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local print_me = function(state)
  local node = state.tree:get_node()
  print(node.name)
end

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = true,
  keys = {
    { '\\', ':Neotree reveal right<CR>', desc = 'NeoTree reveal', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    enable_git_status = true,
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        never_show = {
          '.DS_Store',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['?'] = print_me,
          ['p'] = 'image_ghostty',
        },
      },
      commands = {
        image_ghostty = function(state)
          local node = state.tree:get_node()
          if node.type == 'file' then require('image_preview').PreviewImage(node.path) end
        end,
      },
    },
  },
}
