local neovim = function()
    return vim.g.vscode == nil
end

return {
    'tpope/vim-repeat',
    {
        'kylechui/nvim-surround',
        config = function()
            require("nvim-surround").setup()
        end
    },

    { 'sainnhe/gruvbox-material', enabled = neovim },
    {
        'lewis6991/gitsigns.nvim',
        enabled = neovim,
        config = function()
            require('gitsigns').setup()
        end
    },
    { 'm4xshen/autoclose.nvim',   enabled = neovim },
    {
        'numToStr/Comment.nvim',
        enabled = neovim,
        config = function()
            require('Comment').setup()
        end
    },
    { 'nvim-tree/nvim-web-devicons', enabled = neovim },
    {
        'petertriho/nvim-scrollbar',
        enabled = neovim,
        config = function()
            require('scrollbar').setup()
        end
    },
    { 'posva/vim-vue',               enabled = neovim },
    { 'windwp/nvim-ts-autotag',      version = '*',   enabled = neovim },
    { 'Bekaboo/deadcolumn.nvim',     enabled = neovim },
    {
        'folke/todo-comments.nvim',
        dependencies =
        {
            'nvim-lua/plenary.nvim'
        },
        enabled = neovim,
        config = function()
            require('todo-comments').setup()
        end
    },
    { 'github/copilot.vim', enabled = neovim }
}
