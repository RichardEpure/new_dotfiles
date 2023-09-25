return {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    version = '*',
    enabled = neovim,
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
            }
        }

        local options = { noremap = true, silent = true }

        for i = 1, 9 do
            vim.keymap.set({ 'n', 'v' }, "<leader>" .. i,
                '<cmd>lua require("bufferline").go_to_buffer(' .. i .. ', false)<cr>',
                options)
        end

        vim.keymap.set({ 'n', 'v' }, '<C-up>', [[:BufferLineCycleNext<cr>]], options)
        vim.keymap.set({ 'n', 'v' }, '<C-down>', [[:BufferLineCyclePrev<cr>]], options)
        vim.keymap.set({ 'n', 'v' }, '<C-right>', [[:BufferLineMoveNext<cr>]], options)
        vim.keymap.set({ 'n', 'v' }, '<C-left>', [[:BufferLineMovePrev<cr>]], options)
    end
}
