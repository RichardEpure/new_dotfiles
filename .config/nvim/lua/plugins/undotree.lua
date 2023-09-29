local is_neovim = require('../config/functions').is_neovim

return {
    'mbbill/undotree',
    enabled = is_neovim,
    config = function()
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end
}
