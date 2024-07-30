local function lsp_to_clipboard()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients { bufnr = bufnr }
  local output = {}

  if #clients == 0 then
    table.insert(output, 'No LSP clients attached to the current buffer.')
  else
    for _, client in ipairs(clients) do
      local client_info = 'LSP Client: ' .. client.name .. ' - Config: ' .. vim.inspect(client.config)
      table.insert(output, client_info)
    end
  end

  local output_str = table.concat(output, '\n')
  vim.fn.setreg('+', output_str)
  print 'LSP client info copied to clipboard!'
end

return { getLspConfig = lsp_to_clipboard }
