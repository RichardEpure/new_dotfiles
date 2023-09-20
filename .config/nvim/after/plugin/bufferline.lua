vim.opt.termguicolors = true
BufferLine = require("bufferline")
BufferLine.setup {
    options = {
        diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or ""
            return " " .. icon .. count
        end
    }
}

local options = { noremap = true, silent = true }

for i = 1, 9 do
    vim.keymap.set({ 'n', 'v' }, "<leader>" .. i, '<cmd>lua require("bufferline").go_to_buffer('.. i ..', false)<cr>', options)
end

vim.keymap.set({ 'n', 'v' }, 'gt', [[:BufferLineCycleNext<cr>]], options)
vim.keymap.set({ 'n', 'v' }, 'gT', [[:BufferLineCyclePrev<cr>]], options)
vim.keymap.set({ 'n', 'v' }, '<leader>t', [[:BufferLineMoveNext<cr>]], options)
vim.keymap.set({ 'n', 'v' }, '<leader>T', [[:BufferLineMovePrev<cr>]], options)
