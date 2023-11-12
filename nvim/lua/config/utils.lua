local M = {}

local home = vim.fn.has("linux") == 1 and os.getenv("HOME") or os.getenv("USERPROFILE")
M.home = home

local is_neovim = function()
    return vim.g.vscode == nil
end
M.is_neovim = is_neovim

local read_exrc_file = function()
    local result = vim.secure.read(".nvim.lua")
    if result ~= nil then
        local should_source = vim.fn.input("Source .nvim.lua? (y/n) ") == "y"
        if should_source then
            vim.cmd("source .nvim.lua")
        end
    end
end
M.read_exrc_file = read_exrc_file

return M

