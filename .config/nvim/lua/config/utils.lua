local M = {}

local home = vim.fn.has("linux") == 1 and os.getenv("HOME") or os.getenv("USERPROFILE")
M.home = home

local is_neovim = function()
    return vim.g.vscode == nil
end
M.is_neovim = is_neovim

return M
