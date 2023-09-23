return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    enabled = neovim,
    dependencies = {
        -- LSP Support
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
    },
    config = function()
        local lsp_zero = require('lsp-zero')

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                'tsserver', 'volar', 'cssls',
                'lua_ls', 'rust_analyzer',
                'html', 'jsonls', 'pylsp'
            },
            handlers = {
                lsp_zero.default_setup,
            }
        })

        local cmp = require('cmp')
        local cmp_format = require('lsp-zero').cmp_format()

        cmp.setup({
            formatting = cmp_format,
            mapping = cmp.mapping.preset.insert({
                -- scroll up and down the documentation window
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
            }),
        })

        lsp_zero.setup_servers({
            'tsserver', 'volar', 'cssls',
            'lua_ls', 'rust_analyzer', 'html',
            'jsonls', 'pylsp'
        })

        lsp_zero.on_attach(function(client, bufnr)
            lsp_zero.default_keymaps({ buffer = bufnr })
            local opts = { buffer = bufnr }

            vim.keymap.set({ 'n', 'x' }, '<leader>j', function()
                vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
            end, opts)
        end)

        lsp_zero.setup()

        local lsp_config = require('lspconfig')

        lsp_config.lua_ls.setup(lsp_zero.nvim_lua_ls())

        lsp_config.volar.setup {
            root_dir = require('lspconfig/util').root_pattern('package.json', '.git')
        }

        lsp_config.tsserver.setup {
            root_dir = require('lspconfig/util').root_pattern('package.json', '.git')
        }

        lsp_config.rust_analyzer.setup {
            root_dir = require('lspconfig/util').root_pattern('cargo.toml', '.git')
        }
    end
}
