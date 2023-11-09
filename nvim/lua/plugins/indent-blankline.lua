local is_neovim = require("config.utils").is_neovim

return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    enabled = is_neovim,
    config = function()
        require("ibl").setup({
            indent = { char = "│" },
            scope = { enabled = false }
        })

        local hooks = require("ibl.hooks")
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#353535' })
        end)
    end
}

