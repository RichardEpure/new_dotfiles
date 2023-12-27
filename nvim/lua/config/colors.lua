local is_neovim = require("config.utils").is_neovim

local M = {}

local setColour = function(color)
    vim.cmd.colorscheme(color)
    vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#585858' })
end

M.setColour = setColour

if is_neovim() then
    vim.g.gruvbox_material_background = "medium"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_transparent_background = 0

    setColour("gruvbox-material")
end

return M

