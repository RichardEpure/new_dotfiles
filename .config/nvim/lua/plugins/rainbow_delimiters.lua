local is_neovim = require('config.utils').is_neovim

return {
    'HiPhish/rainbow-delimiters.nvim',
    config = function()
        local rainbow = require 'rainbow-delimiters'

        vim.g.rainbow_delimiters = {
            strategy = {
                [''] = rainbow.strategy['global'],
                vim = rainbow.strategy['local'],
            },
            query = {
                [''] = 'rainbow-delimiters',
                lua = 'rainbow-blocks',
                vue = 'rainbow-delimiters-react'
            },
            highlight = {
                'RainbowDelimiterRed',
                'RainbowDelimiterYellow',
                'RainbowDelimiterGreen',
                'RainbowDelimiterBlue',
                'RainbowDelimiterOrange',
                'RainbowDelimiterViolet',
            },
        }
    end,
    enabled = is_neovim,
}
