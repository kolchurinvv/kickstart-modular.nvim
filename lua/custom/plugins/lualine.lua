local function fugitive_diff_label()
  if not vim.wo.diff then
    return ''
  end

  -- Find all windows in this tab that are in diff mode
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local diff_wins = {}
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_option(win, 'diff') then
      table.insert(diff_wins, win)
    end
  end

  -- Sort by window position (left to right)
  table.sort(diff_wins, function(a, b)
    return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
  end)

  -- Assign labels based on split order
  local labels = { '[ours]', '[wc/base]', '[theirs]' }
  for idx, win in ipairs(diff_wins) do
    if win == vim.api.nvim_get_current_win() then
      return labels[idx] or ''
    end
  end

  return ''
end

vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.showmode = false

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      always_show_tabline = true,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
        refresh_time = 16, -- ~60fps
        events = {
          'WinEnter',
          'BufEnter',
          'BufWritePost',
          'SessionLoadPost',
          'FileChangedShellPost',
          'VimResized',
          'Filetype',
          'CursorMoved',
          'CursorMovedI',
          'ModeChanged',
        },
      },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { fugitive_diff_label, 'filename' },
      lualine_x = { 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { fugitive_diff_label, 'filename' },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
  },
}
