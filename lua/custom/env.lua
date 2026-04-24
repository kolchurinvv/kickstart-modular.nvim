local M = {}

function M.get(key)
  local env_path = vim.fn.stdpath('config') .. '/.env'
  local file = io.open(env_path, 'r')
  if not file then
    return os.getenv(key)
  end

  for line in file:lines() do
    local k, v = line:match('^([^=]+)=(.*)$')
    if k == key then
      file:close()
      -- Remove quotes if present
      return v:gsub('^["\']', ''):gsub('["\']$', '')
    end
  end

  file:close()
  return os.getenv(key)
end

return M
