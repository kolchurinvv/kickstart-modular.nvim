-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local print_me = function(state)
  local node = state.tree:get_node()
  print(node.name)
end
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal right<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    enable_git_status = true,
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        never_shoe = {
          '.DS_Store',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['?'] = print_me,
        },
      },
    },
  },
}
