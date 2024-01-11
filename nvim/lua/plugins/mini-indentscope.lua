local is_neovim = require('config.utils').is_neovim

return {
    'echasnovski/mini.indentscope',
    version = false,
    enabled = is_neovim,
    config = function()
        local indentscope = require('mini.indentscope')

        indentscope.setup({
            draw = {
                delay = 0,
                animation = indentscope.gen_animation.none()
            },
            options = {
                try_as_border = true
            },
            symbol = '│'
        })

        -- Disable for certain filetypes
        vim.api.nvim_create_autocmd({ "FileType" }, {
            desc = "Disable indentscope for certain filetypes",
            callback = function()
                local ignore_filetypes = {
                    "aerial",
                    "dashboard",
                    "help",
                    "lazy",
                    "leetcode.nvim",
                    "mason",
                    "neo-tree",
                    "NvimTree",
                    "neogitstatus",
                    "notify",
                    "startify",
                    "toggleterm",
                    "Trouble",
                    "git",
                    "fugitive",
                    "log",
                    "txt",
                    "md",
                }
                if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
                    vim.b.miniindentscope_disable = true
                end
            end,
        })
    end
}

