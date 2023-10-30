local is_neovim = require('config.utils').is_neovim

return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-frecency.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        'nvim-telescope/telescope-live-grep-args.nvim',
    },
    version = '*',
    enabled = is_neovim,
    config = function()
        local lga_actions = require("telescope-live-grep-args.actions")

        require('telescope').setup({
            pickers = {
                find_files = {
                    mappings = {
                        n = {
                            ["cd"] = function(prompt_bufnr)
                                local selection = require("telescope.actions.state").get_selected_entry()
                                local dir = vim.fn.fnamemodify(selection.path, ":p:h")
                                require("telescope.actions").close(prompt_bufnr)
                                -- Depending on what you want put `cd`, `lcd`, `tcd`
                                vim.cmd(string.format("silent cd %s", dir))
                            end
                        }
                    }
                },
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {}
                },
                frecency = {
                    show_unindexed = false
                },
                live_grep_args = {
                    auto_quoting = true,
                    mappings = {
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                        },
                    },
                }
            }
        })

        require('telescope').load_extension('frecency')
        require('telescope').load_extension('ui-select')
        require("telescope").load_extension("live_grep_args")

        local builtin = require('telescope.builtin')

        -- We cache the results of "git rev-parse"
        -- Process creation is expensive in Windows, so this reduces latency
        local is_inside_work_tree = {}
        local project_files = function()
            local opts = {} -- define here if you want to define something

            local cwd = vim.fn.getcwd()
            if is_inside_work_tree[cwd] == nil then
                vim.fn.system("git rev-parse --is-inside-work-tree")
                is_inside_work_tree[cwd] = vim.v.shell_error == 0
            end

            if is_inside_work_tree[cwd] then
                builtin.git_files(opts)
            else
                builtin.find_files(opts)
            end
        end

        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

        vim.keymap.set('n', '<leader>fa', builtin.find_files)
        vim.keymap.set('n', '<leader>ff', project_files)
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles)
        vim.keymap.set('n', '<leader>fj', [[:Telescope frecency workspace=CWD<CR>]])
        vim.keymap.set('n', '<leader>fw', [[:Telescope live_grep_args<CR>]])
        vim.keymap.set("n", "<leader>f<C-w>", live_grep_args_shortcuts.grep_word_under_cursor)
        vim.keymap.set('n', '<leader>fh', function() builtin.find_files({ hidden = true }) end)
        vim.keymap.set('n', '<leader>fqq', builtin.quickfix)
        vim.keymap.set('n', '<leader>fqh', builtin.quickfixhistory)
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics)
        vim.keymap.set('n', '<leader>fc', builtin.commands)
        vim.keymap.set('n', '<leader>fr', builtin.registers)
        vim.keymap.set('n', '<leader>fm', builtin.marks)
        vim.keymap.set('n', '<leader>fu', builtin.resume)
    end
}

