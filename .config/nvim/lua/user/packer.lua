-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

local neovim = function()
    return vim.g.vscode == nil
end

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use "tpope/vim-repeat"
    use { 'kylechui/nvim-surround', tag = "*" }
    use "ggandor/leap.nvim"
    use "ggandor/flit.nvim"

    use {
    	'VonHeikemen/lsp-zero.nvim',
    	branch = 'v2.x',
    	requires = {
    	    -- LSP Support
    	    {'neovim/nvim-lspconfig'},             -- Required
    	    {                                      -- Optional
	    	'williamboman/mason.nvim',
	    	run = function()
		    	pcall(vim.cmd, 'MasonUpdate')
	    	end,
    	    },
    	    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    	    -- Autocompletion
    	    {'hrsh7th/nvim-cmp'},     -- Required
    	    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    	    {'L3MON4D3/LuaSnip'},     -- Required
    	},
    	cond = neovim
    }
    use {
	    'nvim-telescope/telescope.nvim', tag = '0.1.3',
	    requires = { {'nvim-lua/plenary.nvim'} },
	    cond = neovim
    }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', cond = neovim }
    use { 'sainnhe/gruvbox-material', cond = neovim }
    use { 'lewis6991/gitsigns.nvim', cond = neovim }
    use { 'm4xshen/autoclose.nvim', cond = neovim }
    use { 'mbbill/undotree', cond = neovim }
    use { 'numToStr/Comment.nvim', cond = neovim }
    use { 'nvim-tree/nvim-web-devicons', cond = neovim }
    use { 'petertriho/nvim-scrollbar', cond = neovim }
    use { 'posva/vim-vue', cond = neovim }
    use { 'rmagatti/auto-session', cond = neovim }
    use { 'stevearc/oil.nvim', cond = neovim }
    use { 'theprimeagen/harpoon', cond = neovim }
    use { 'tpope/vim-fugitive', cond = neovim }
    use { 'windwp/nvim-ts-autotag', cond = neovim }
    use { 'Bekaboo/deadcolumn.nvim', cond = neovim }
    use { "folke/todo-comments.nvim", requires = "nvim-lua/plenary.nvim", cond = neovim }
    use {
        'akinsho/bufferline.nvim',
        tag = "*",
        requires = 'nvim-tree/nvim-web-devicons',
        cond = neovim
    }
    use {'shortcuts/no-neck-pain.nvim', tag = "*", cond = neovim }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true },
        cond = neovim
    }
    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
        cond = neovim
    }
    use { 'github/copilot.vim', cond = neovim }
end)

