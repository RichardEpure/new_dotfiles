local is_neovim = require('config.utils').is_neovim

return {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    version = '*',
    enabled = is_neovim,
    config = function()
        local buffer_line = require("bufferline")
        buffer_line.setup {
            options = {
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or ""
                    return " " .. icon .. count
                end,
                numbers = function(opts)
                    return string.format('%s', opts.ordinal)
                end,
            },
            highlights = {
                fill = {
                    bg = {
                        attribute = "bg",
                        highlight = "BufferLineBuffer"
                    }
                },
            }
        }

        local options = { noremap = true, silent = true }

        for i = 1, 9 do
            vim.keymap.set(
                { 'n', 'v' },
                "<leader>" .. i,
                '<cmd>lua require("bufferline").go_to_buffer(' .. i .. ', false)<cr>',
                options
            )
        end

        vim.keymap.set(
            { 'n', 'v' },
            "<leader>$",
            '<cmd>lua require("bufferline").go_to_buffer(-1, false)<cr>',
            options
        )

        vim.keymap.set({ 'n', 'v' }, '<up>', [[:BufferLineCycleNext<cr>]], options)
        vim.keymap.set({ 'n', 'v' }, '<down>', [[:BufferLineCyclePrev<cr>]], options)
        vim.keymap.set({ 'n', 'v' }, '<right>', [[:BufferLineMoveNext<cr>]], options)
        vim.keymap.set({ 'n', 'v' }, '<left>', [[:BufferLineMovePrev<cr>]], options)
    end
}

