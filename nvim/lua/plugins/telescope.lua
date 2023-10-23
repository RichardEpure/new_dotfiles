local is_neovim = require('config.utils').is_neovim

return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    version = '*',
    enabled = is_neovim,
    config = function()
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>fa', builtin.find_files)
        vim.keymap.set('n', '<leader>ff', builtin.git_files)
        vim.keymap.set('n', '<leader>fw', builtin.live_grep)
        vim.keymap.set('n', '<leader>fh', function() builtin.find_files({ hidden = true }) end)
    end
}
