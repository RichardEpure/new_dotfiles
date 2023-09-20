function SetColor(color)
    vim.cmd.colorscheme(color)
end

vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.g.gruvbox_material_transparent_background = 0

SetColor("gruvbox-material")
