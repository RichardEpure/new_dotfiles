local is_neovim = require('../config/functions').is_neovim

return {
    'tpope/vim-fugitive',
    enabled = is_neovim,
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        vim.keymap.set("n", "<leader>gb", [[:Telescope git_branches<CR>]])
        vim.keymap.set("n", "<leader>gc", [[:Telescope git_commits<CR>]])
    end
}
