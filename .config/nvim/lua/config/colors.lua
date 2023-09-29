local is_neovim = require("functions").is_neovim

function SetColor(color)
    vim.cmd.colorscheme(color)
end

if is_neovim() then
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_transparent_background = 0

    SetColor("gruvbox-material")
end
