local is_neovim = require('config.utils').is_neovim

return {
    'akinsho/toggleterm.nvim',
    version = "*",
    enable = is_neovim,
    config = function()
        local tt = require('toggleterm')
        tt.setup({
            open_mapping = [[<C-\>]],
        })

        function _G.set_terminal_keymaps()
            local opts = { buffer = 0 }
            -- vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            vim.keymap.set('t', '<C-w>', [[<C-\><C-n>]], opts)
        end

        vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

        local Terminal = require('toggleterm.terminal').Terminal

        local lazygit  = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            hidden = true,
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
            end,
            on_close = function(term)
                vim.cmd("startinsert!")
            end,
        })
        function _lazygit_toggle()
            lazygit:toggle()
        end

        local yazi = Terminal:new({
            cmd = "yazi",
            direction = "float",
            hidden = true,
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
            end,
            on_close = function(term)
                vim.cmd("startinsert!")
            end,
        })
        function _yazi_toggle()
            yazi:toggle()
        end

        vim.api.nvim_set_keymap(
            "n",
            "<leader>tl",
            "<cmd>lua _lazygit_toggle()<CR>",
            { noremap = true, silent = true, desc = "Lazygit" }
        )
        vim.api.nvim_set_keymap(
            "n",
            "<leader>te",
            "<cmd>lua _yazi_toggle()<CR>",
            { noremap = true, silent = true, desc = "Yazi" }
        )
    end
}

