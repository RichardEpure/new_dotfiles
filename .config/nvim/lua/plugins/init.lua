local is_neovim = require('config.utils').is_neovim

return {
    'tpope/vim-repeat',
    {
        'kylechui/nvim-surround',
        config = function()
            require("nvim-surround").setup()
        end
    },
    { 'sainnhe/gruvbox-material',    enabled = is_neovim },
    {
        'lewis6991/gitsigns.nvim',
        enabled = is_neovim,
        config = function()
            require('gitsigns').setup()
        end
    },
    {
        'numToStr/Comment.nvim',
        enabled = is_neovim,
        config = function()
            require('Comment').setup()
        end
    },
    { 'nvim-tree/nvim-web-devicons', enabled = is_neovim },
    {
        'petertriho/nvim-scrollbar',
        enabled = is_neovim,
        config = function()
            require('scrollbar').setup()
        end
    },
    { 'Bekaboo/deadcolumn.nvim', enabled = is_neovim },
    {
        'folke/todo-comments.nvim',
        dependencies =
        {
            'nvim-lua/plenary.nvim'
        },
        enabled = is_neovim,
        config = function()
            require('todo-comments').setup()
        end
    },
    { 'github/copilot.vim',      enabled = is_neovim },
    { 'kevinhwang91/nvim-bqf',   ft = 'qf',       enabled = is_neovim },
    {
        'junegunn/fzf',
        build = function()
            vim.fn['fzf#install']()
        end,
        enabled = is_neovim
    }
}
