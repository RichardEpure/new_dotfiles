local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
end)

lsp.setup_servers({
    'tsserver', 'volar', 'cssls', 'eslint', 'lua_ls', 'rust_analyzer', 'eslint', 'html', 'jsonls',
    'pylsp'
})

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

require('lspconfig').volar.setup {
    root_dir = require('lspconfig/util').root_pattern('package.json', '.git')
}

require('lspconfig').rust_analyzer.setup {
    root_dir = require('lspconfig/util').root_pattern('cargo.toml', '.git')
}

lsp.setup()
