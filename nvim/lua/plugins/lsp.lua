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
                'hrsh7th/cmp-buffer',
                'saadparwaiz1/cmp_luasnip',
            }
        },
        { 'hrsh7th/cmp-nvim-lsp' },
        {
            'L3MON4D3/LuaSnip',
            dependencies = { "rafamadriz/friendly-snippets" },
        },

        -- Other
        { 'abecodes/tabout.nvim' }
    },
    config = function()
        local lsp_zero = require('lsp-zero')
        local mason_registry = require('mason-registry')

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls' },
            handlers = {
                lsp_zero.default_setup,
            }
        })

        -- LuaSnip
        local luasnip = require('luasnip')
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup()

        -- cmp
        local cmp = require('cmp')
        local cmp_format = require('lsp-zero').cmp_format()

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            formatting = cmp_format,
            mapping = cmp.mapping.preset.insert({
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
                ['<CR>'] = cmp.mapping.confirm {
                    behaviour = cmp.ConfirmBehavior.Replace,
                    select = true,
                },
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    elseif require("copilot.suggestion").is_visible() then
                        require("copilot.suggestion").accept()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }
        })

        -- Auto completion for / search
        cmp.setup.cmdline('/', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        -- Auto completion of ex-commands
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

        -- Lsp Zero
        lsp_zero.setup_servers({
            'cssls', 'lua_ls', 'html', 'jsonls'
        })

        lsp_zero.on_attach(function(client, bufnr)
            lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false })
            local opts = { buffer = bufnr }

            -- vim.keymap.set({ 'n', 'x' }, '<leader>jl', function()
            --     vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
            -- end, opts)
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

        lsp_config.powershell_es.setup {
            bundle_path = mason_registry.get_package("powershell-editor-services"):get_install_path()
        }

        -- For Windows: use Nmap
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

        -- Tabout
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
