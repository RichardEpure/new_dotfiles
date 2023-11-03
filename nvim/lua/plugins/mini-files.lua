local is_neovim = require('config.utils').is_neovim

return {
    'echasnovski/mini.files',
    version = false,
    config = function()
        local MiniFiles = require('mini.files')

        MiniFiles.setup({
            options = {
                use_as_default_explorer = false
            }
        })

        local map_split = function(buf_id, lhs, direction)
            local rhs = function()
                -- Make new window and set it as target
                local new_target_window
                vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
                    vim.cmd(direction .. ' split')
                    new_target_window = vim.api.nvim_get_current_win()
                end)

                MiniFiles.set_target_window(new_target_window)
            end

            -- Adding `desc` will result into `show_help` entries
            local desc = 'Split ' .. direction
            vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
        end

        vim.api.nvim_create_autocmd('User', {
            pattern = 'MiniFilesBufferCreate',
            callback = function(args)
                local buf_id = args.data.buf_id
                -- Tweak keys to your liking
                map_split(buf_id, 'gs', 'belowright horizontal')
                map_split(buf_id, 'gv', 'belowright vertical')
            end,
        })

        local files_set_cwd = function(path)
            -- Works only if cursor is on the valid file system entry
            local cur_entry_path = MiniFiles.get_fs_entry().path
            local cur_directory = vim.fs.dirname(cur_entry_path)
            vim.fn.chdir(cur_directory)
        end

        vim.api.nvim_create_autocmd('User', {
            pattern = 'MiniFilesBufferCreate',
            callback = function(args)
                vim.keymap.set('n', 'g~', files_set_cwd, { buffer = args.data.buf_id })
            end,
        })

        local minifiles_toggle = function(path)
            if not MiniFiles.close() then MiniFiles.open(path) end
        end

        vim.keymap.set(
            'n',
            '<leader>e',
            function() minifiles_toggle(vim.fn.expand("%:.")) end,
            { silent = true }
        )

        vim.g.loaded_netrwPlugin = 1
    end,
    enabled = is_neovim
}

