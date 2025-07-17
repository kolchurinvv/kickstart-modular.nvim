local M = {}

local function has_deno_config(dir)
  local deno_json = dir .. '/deno.json'
  local deno_jsonc = dir .. '/deno.jsonc'
  return (vim.fn.filereadable(deno_jsonc) == 1 or vim.fn.filereadable(deno_json) == 1)
end

local function is_root_dir(dir)
  local git_dir = dir .. '/.git/index'
  return vim.fn.filereadable(git_dir) == 1
end

-- function M.should_attach_ts_ls(root_dir)
--   local current_dir = root_dir
--   while current_dir do
--     if has_deno_config(current_dir) then
--       print 'found deno config'
--       return false
--     end
--     if is_root_dir(current_dir) then
--       break
--     end
--     local parent_dir = current_dir:match '(.*)/'
--     if parent_dir then
--       current_dir = parent_dir
--     else
--       break
--     end
--   end
--   return true
-- end

function M.should_attach_ts_ls(root_dir)
  local function find_git_root(dir)
    while dir do
      if is_root_dir(dir) then
        return dir
      end
      local parent_dir = dir:match '(.*)/'
      if parent_dir == dir or not parent_dir then
        break
      end
      dir = parent_dir
    end
    return nil
  end

  local git_root = find_git_root(root_dir)
  local current_dir = root_dir
  while current_dir and git_root and current_dir:find(git_root, 1, true) == 1 do
    if has_deno_config(current_dir) then
      print('found deno config at ' .. current_dir)
      return false
    end
    if current_dir == git_root then
      break
    end
    local parent_dir = current_dir:match '(.*)/'
    if parent_dir == current_dir or not parent_dir then
      break
    end
    current_dir = parent_dir
  end
  return true
end

return M
