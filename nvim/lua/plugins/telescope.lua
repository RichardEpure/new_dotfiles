local is_neovim = require('config.utils').is_neovim

return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    version = '*',
    enabled = is_neovim,
    config = function()
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
            }
        })

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

        vim.keymap.set('n', '<leader>fa', builtin.find_files)
        vim.keymap.set('n', '<leader>ff', project_files)
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles)
        vim.keymap.set('n', '<leader>fw', builtin.live_grep)
        vim.keymap.set('n', '<leader>fh', function() builtin.find_files({ hidden = true }) end)
    end
}

