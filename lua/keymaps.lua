-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Explore command remap
vim.keymap.set('n', '<leader>ls', vim.cmd.Ex)

--undo tree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndo Tree Toggle' })

-- Resize splits
-- NOTE: make sure tmux doesn't conflict (meta + arrow key seems to work)
vim.keymap.set('n', '<M-Up>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<M-Down>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-Right>', ':vertical resize +2<CR>', { silent = true })

-- Git (fugitive) -- git status
vim.keymap.set('n', '<leader>gst', vim.cmd.Git, { desc = '[G]it [S]tatus' })

-- Close buffer without closing the window
-- NOTE: This will close the current buffer and switch to the next one.
vim.keymap.set('n', '<leader>cb', ':bp<bar>sp<bar>bn<bar>bd<CR>', { desc = '[C]lose [B]uffer' })

-- NOTE: uses shift (that's why the letters are capital)
-- moves the selected (visual mode) lines up and down (!!)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Allow 'paste' to keep pasting whatever you copied
vim.keymap.set('n', 'p', '"0p')

local function copy_to_clipboard()
  vim.cmd 'noautocmd normal! "zy'
  local content = vim.fn.getreg 'z'
  vim.fn.setreg('+', content)
  vim.cmd 'echo "Yanked to System Clipboard"'
end
vim.keymap.set('v', '<leader>y', copy_to_clipboard, { desc = 'Yank to System Clipboard' })
-- TODO: these supposed to yank to system clipboard - not sure why there needs to be 3 of them...
-- vim.keymap.set('v', '<leader>y', "'+y")
-- vim.keymap.set('n', '<leader>Y', "'+Y")

local function search_selected()
  local _, csrow, cscol = unpack(vim.fn.getpos "'<")
  local _, cerow, cecol = unpack(vim.fn.getpos "'>")

  local lines = vim.fn.getline(csrow, cerow)
  if #lines == 0 then
    return
  end

  lines[1] = string.sub(lines[1], cscol)
  lines[#lines] = string.sub(lines[#lines], 1, cecol)

  local selection = table.concat(lines, ' ')
  selection = vim.fn.escape(selection, '\\/.*$^~[]')

  vim.fn.setreg('/', selection)
  vim.api.nvim_feedkeys('/\\V' .. selection .. '\n', 'n', false)
end

vim.keymap.set('v', '<S-e>', search_selected, { noremap = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
