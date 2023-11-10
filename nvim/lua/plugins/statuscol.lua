local is_neovim = require("config.utils").is_neovim

return {
    "luukvbaal/statuscol.nvim",
    enabled = is_neovim,
    config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
            foldfunc = "builtin",
            segments = {
                {
                    text = { "%s" },
                    click = "v:lua.ScSa"
                },
                {
                    text = { builtin.lnumfunc, " " },
                    condition = { true, builtin.not_empty },
                    click = "v:lua.ScLa",
                },
                {
                    text = { builtin.foldfunc, " " },
                    click = "v:lua.ScFa",
                },
            }
        })
    end,
}

