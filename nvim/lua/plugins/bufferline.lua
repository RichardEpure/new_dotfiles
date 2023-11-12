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
                        highlight = "Normal"
                    }
                },
                buffer_visible = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                },
                background = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                tab = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                tab_selected = {
                    fg = {
                        attribute = "fg",
                        highlight = "Yellow"
                    },
                },
                tab_separator = {
                    fg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                tab_separator_selected = {
                    fg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                tab_close = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                close_button = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                close_button_visible = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                },
                numbers = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
                numbers_visible = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                },
                modified = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                },
                duplicate_selected = {
                    fg = {
                        attribute = "fg",
                        highlight = "Normal"
                    },
                },
                duplicate_visible = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                },
                duplicate = {
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                },
                separator = {
                    fg = {
                        attribute = "bg",
                        highlight = "Normal"
                    },
                    bg = {
                        attribute = "bg",
                        highlight = "Normal"
                    }
                },
            }
        }

        for i = 1, 9 do
            vim.keymap.set(
                { 'n', 'v' },
                "<leader>" .. i,
                '<cmd>lua require("bufferline").go_to_buffer(' .. i .. ', false)<cr>',
                { noremap = true, silent = true, desc = "Go to buffer " .. i }
            )
        end

        vim.keymap.set(
            { 'n', 'v' },
            "<leader>$",
            '<cmd>lua require("bufferline").go_to_buffer(-1, false)<cr>',
            { noremap = true, silent = true, desc = "Go to last buffer" }
        )

        vim.keymap.set(
            { 'n', 'v' },
            '<up>',
            [[:BufferLineCycleNext<cr>]],
            { noremap = true, silent = true, desc = "Go to next buffer" }
        )
        vim.keymap.set(
            { 'n', 'v' },
            '<down>',
            [[:BufferLineCyclePrev<cr>]],
            { noremap = true, silent = true, desc = "Go to previous buffer" }
        )
        vim.keymap.set(
            { 'n', 'v' },
            '<right>',
            [[:BufferLineMoveNext<cr>]],
            { noremap = true, silent = true, desc = "Move buffer to next position" }
        )
        vim.keymap.set(
            { 'n', 'v' },
            '<left>',
            [[:BufferLineMovePrev<cr>]],
            { noremap = true, silent = true, desc = "Move buffer to previous position" }
        )
    end
}

