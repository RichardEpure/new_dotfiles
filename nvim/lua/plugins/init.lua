local is_neovim = require('config.utils').is_neovim

return {
    -- shared
    'tpope/vim-repeat',
    {
        'kylechui/nvim-surround',
        config = function()
            require("nvim-surround").setup()
        end
    },

    -- neovim
    { 'tpope/vim-rhubarb',           enabled = is_neovim },
    {
        'sainnhe/gruvbox-material',
        enabled = is_neovim,
        config = function()
            vim.g.gruvbox_material_enable_italic = 1
        end
    },
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
            require('Comment').setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
            })
        end
    },
    { 'nvim-tree/nvim-web-devicons', enabled = is_neovim },
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
    { 'kevinhwang91/nvim-bqf', ft = 'qf',   enabled = is_neovim },
    {
        'junegunn/fzf',
        build = function()
            vim.fn['fzf#install']()
        end,
        enabled = is_neovim
    },
    {
        'kazhala/close-buffers.nvim',
        opts = true,
        config = function()
            vim.keymap.set("n", "<leader>q", [[:BDelete this<CR>]], { silent = true, desc = "Close buffer" })
            vim.keymap.set("n", "<leader>Q", [[:BDelete! this<CR>]], { silent = true, desc = "Force close buffer" })
        end,
        enabled = is_neovim,
    },
    {
        'echasnovski/mini.splitjoin',
        version = '*',
        opts = true,
        enabled = is_neovim
    },
    {
        'echasnovski/mini.ai',
        version = false,
        opts = {
            mappings = {
                goto_left = 'gp',
                goto_right = 'gn'
            }
        },
        enabled = is_neovim
    },
    {
        'echasnovski/mini.indentscope',
        version = false,
        config = function()
            local indentscope = require('mini.indentscope')
            indentscope.setup({
                draw = {
                    delay = 0,
                    animation = indentscope.gen_animation.none()
                },
                options = {
                    try_as_border = true
                },
                symbol = '│'
            })
        end,
        enabled = is_neovim
    },
    { "folke/twilight.nvim",   opts = true, enabled = is_neovim }
}

