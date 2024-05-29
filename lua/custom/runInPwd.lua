local function RunCommandInDir(cmd)
    -- Get the full path of the current file or directory in Netrw
    local current_path = vim.fn.expand('%:p')
    -- Determine if the current path is a directory
    local is_dir = vim.fn.isdirectory(current_path)
    local target_dir

    if is_dir == 1 then
        target_dir = current_path
    else
        -- If not a directory, use the parent directory of the current file
        target_dir = vim.fn.expand('%:p:h')
    end

    -- Change to the target directory and execute the command
    local full_cmd = "cd " .. vim.fn.shellescape(target_dir) .. " && " .. cmd
    vim.cmd('! ' .. full_cmd)
end

return { RunCommandInDir = RunCommandInDir }
