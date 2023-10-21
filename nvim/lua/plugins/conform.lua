local is_neovim = require('config.utils').is_neovim

return {
    'stevearc/conform.nvim',
    enabled = function()
        return is_neovim
    end,
    config = function()
        local conform = require('conform')

        conform.setup({
            formatters_by_ft = {
                -- lua = { "stylua" },
                -- Conform will run multiple formatters sequentially
                -- python = { "isort", "black" },
                -- Use a sub-list to run only the first available formatter
                -- javascript = { { "prettierd", "prettier" } },

                gdscript = { 'gdformat' }
            },
        })

        vim.keymap.set({ 'n', 'x' }, '<leader>jj', function()
            require('conform').format()
        end)
    end
}
