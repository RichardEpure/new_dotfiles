local M = {}

local is_neovim = function()
    return vim.g.vscode == nil
end

M.is_neovim = is_neovim

return M
