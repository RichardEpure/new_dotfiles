local is_neovim = require("config.utils").is_neovim

return {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    enabled = is_neovim,
    config = function()
        local neogen = require("neogen")
        neogen.setup({
            enabled = true,
            snippet_engine = "luasnip"
        })

        vim.keymap.set(
            "n",
            "<Leader>aan",
            neogen.generate,
            {
                noremap = true,
                silent = true,
                desc = "Generate annotation"
            }
        )
        vim.keymap.set(
            "n",
            "<Leader>aaf",
            neogen.generate,
            {
                noremap = true,
                silent = true,
                desc = "Generate file annotation"
            }
        )
        vim.keymap.set(
            "n",
            "<Leader>aam",
            neogen.generate,
            {
                noremap = true,
                silent = true,
                desc = "Generate method annotation"
            }
        )
        vim.keymap.set(
            "n",
            "<Leader>aac",
            neogen.generate,
            {
                noremap = true,
                silent = true,
                desc = "Generate class annotation"
            }
        )
        vim.keymap.set(
            "n",
            "<Leader>aat",
            neogen.generate,
            {
                noremap = true,
                silent = true,
                desc = "Generate type annotation"
            }
        )
    end,
}

