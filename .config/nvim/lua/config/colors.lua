local is_neovim = require("config.utils").is_neovim
local palette = require("config.palette")

function SetColor(color)
    vim.cmd.colorscheme(color)
end

if is_neovim() then
    vim.g.gruvbox_material_background = "medium"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_transparent_background = 0

    SetColor("gruvbox-material")

    vim.api.nvim_set_hl(0, 'RainbowDelimiterRed', { fg = palette.red })
    vim.api.nvim_set_hl(0, 'RainbowDelimiterYellow', { fg = palette.yellow })
    vim.api.nvim_set_hl(0, 'RainbowDelimiterGreen', { fg = palette.green })
    vim.api.nvim_set_hl(0, 'RainbowDelimiterBlue', { fg = palette.blue })
    vim.api.nvim_set_hl(0, 'RainbowDelimiterOrange', { fg = palette.orange })
    vim.api.nvim_set_hl(0, 'RainbowDelimiterViolet', { fg = palette.purple })
end

