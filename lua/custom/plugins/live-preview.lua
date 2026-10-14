-- Browser preview for markdown/html/asciidoc/svg with live updates and scroll sync; pure Lua, no Node/Deno.
-- Usage: `:LivePreview start` / `:LivePreview close`
return {
  'brianhuster/live-preview.nvim',
  cmd = 'LivePreview',
  keys = {
    { '<leader>mp', '<cmd>LivePreview start<cr>', desc = '[M]arkdown [P]review in browser' },
  },
}
