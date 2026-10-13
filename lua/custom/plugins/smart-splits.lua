-- <C-hjkl> walks Neovim splits and tmux panes as one grid: it moves between
-- Neovim windows until there are none left in that direction, then hands off
-- to tmux. The tmux half is in ~/.config/tmux/tmux.conf (the "Smart pane
-- navigation" block), which sends <C-hjkl> to this pane while the backend
-- keeps the pane-local `@pane-is-vim` option set, and moves tmux panes
-- otherwise. `move.at_edge` is left at its default ('wrap'), matching tmux's
-- own select-pane wrapping. Check it with `:checkhealth smart-splits`.
local function move(dir)
  return function()
    require('smart-splits')['move_cursor_' .. dir]()
  end
end

return {
  'smart-splits-nvim/smart-splits.nvim',
  version = '^3.0.0',
  -- Must not be lazy-loaded: tmux only learns that this pane runs Neovim when
  -- the backend loads, and until then tmux swallows <C-hjkl>.
  lazy = false,
  dependencies = {
    { 'smart-splits-nvim/backend-tmux', main = 'smart-splits-backend-tmux' },
  },
  opts = {
    mux = { backend = 'smart-splits-backend-tmux' },
  },
  keys = {
    { '<C-h>', move 'left', desc = 'Move focus to the left window/tmux pane' },
    { '<C-j>', move 'down', desc = 'Move focus to the lower window/tmux pane' },
    { '<C-k>', move 'up', desc = 'Move focus to the upper window/tmux pane' },
    { '<C-l>', move 'right', desc = 'Move focus to the right window/tmux pane' },
  },
}
