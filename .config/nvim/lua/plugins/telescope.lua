return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    version = '*',
    enabled = neovim,
    config = function()
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>fa', builtin.find_files, {})
        vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
        vim.keymap.set('n', '<leader>fw', builtin.live_grep, {})
    end
}
