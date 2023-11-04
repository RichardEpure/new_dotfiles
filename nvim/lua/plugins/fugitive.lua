local is_neovim = require('config.utils').is_neovim

return {
    'tpope/vim-fugitive',
    enabled = is_neovim,
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })
        vim.keymap.set("n", "<leader>gb", [[:Telescope git_branches<CR>]], { desc = "Git branches" })
        vim.keymap.set("n", "<leader>gc", [[:Telescope git_commits<CR>]], { desc = "Git commits" })
    end
}

