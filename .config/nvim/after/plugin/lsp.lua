local lsp_zero = require('lsp-zero').preset({})

lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

lsp_zero.setup_servers({
    'tsserver', 'volar', 'cssls', 'eslint', 'lua_ls', 'rust_analyzer', 'eslint', 'html', 'jsonls',
    'pylsp'
})

lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
    local opts = { buffer = bufnr }

    vim.keymap.set({ 'n', 'x' }, '<leader>j', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)
end)

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

lsp_zero.setup()
