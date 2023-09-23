return {
    'mbbill/undotree',
    enabled = neovim,
    config = function()
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end
}