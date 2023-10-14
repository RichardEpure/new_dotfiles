local is_neovim = require('config.utils').is_neovim

return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    enabled = is_neovim,
    dependencies = {
        -- LSP Support
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },

        -- Autocompletion
        {
            'hrsh7th/nvim-cmp',
            dependencies = {
                'hrsh7th/cmp-cmdline',
                'hrsh7th/cmp-buffer'
            }
        },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },

        -- Other
        { 'abecodes/tabout.nvim' }
    },
    config = function()
        local lsp_zero = require('lsp-zero')

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                'tsserver', 'volar', 'cssls',
                'lua_ls', 'rust_analyzer',
                'html', 'jsonls', 'pylsp',
                'clangd'
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

        cmp.setup.cmdline('/', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                {
                    name = 'cmdline',
                    option = {
                        ignore_cmds = { 'Man', '!' }
                    }
                }
            })
        })

        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
        )

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

        lsp_config.clangd.setup {
            cmd = {
                "clangd",
                "--offset-encoding=utf-16"
            }
        }

        -- For Windows: scoop install nmap
        -- For WSL: doesn't work
        local cmd = vim.fn.has('linux') == 1 and
            vim.lsp.rpc.connect(vim.fn.hostname() .. '.local') or
            { 'ncat', 'localhost', '6005' }

        local pipe = vim.fn.has('linux') == 1 and
            '/tmp/godot.pipe' or
            [[\\.\pipe\godot.pipe]]

        lsp_config.gdscript.setup {
            cmd = cmd,
            filetypes = { 'gd', 'gdscript', 'gdignore' },
            root_dir = require('lspconfig/util').root_pattern('project.godot', '.git'),
            on_attach = function(client, buffer)
                -- Godot external editor settings:
                -- Exec Path: nvim
                -- Linux - Exec Flags: --server /tmp/godot.pipe --remote-send "<esc>:n {file}<CR>:call cursor({line},{col})<CR>"
                -- Windows - Exec Flags: --server "\\\\.\\pipe\\godot.pipe" --remote-send "<C-\><C-N>:n {file}<CR>:call cursor({line},{col})<CR>"
                if vim.fn.has('linux') == 1 then
                    vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
                else
                    vim.api.nvim_command([[echo serverstart(']] .. pipe .. [[')]])
                end
            end
        }

        require('tabout').setup {
            tabkey = '<C-Tab>',           -- key to trigger tabout, set to an empty string to disable
            backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
            act_as_tab = false,           -- shift content if tab out is not possible
            act_as_shift_tab = false,     -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
            default_tab = '<C-t>',        -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
            default_shift_tab = '<C-d>',  -- reverse shift default action,
            enable_backwards = true,      -- well ...
            completion = true,            -- if the tabkey is used in a completion pum
            tabouts = {
                { open = "'", close = "'" },
                { open = '"', close = '"' },
                { open = '`', close = '`' },
                { open = '(', close = ')' },
                { open = '[', close = ']' },
                { open = '{', close = '}' }
            },
            ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
            exclude = {} -- tabout will ignore these filetypes
        }
    end
}
