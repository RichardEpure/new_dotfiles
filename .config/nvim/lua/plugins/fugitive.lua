return {
    'tpope/vim-fugitive',
    enabled = neovim,
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
    end
}
