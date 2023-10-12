local is_neovim = require('config.utils').is_neovim

return {
    'mfussenegger/nvim-dap',
    config = function()
        local dap = require('dap')

        dap.adapters.godot = {
            type = "server",
            host = '127.0.0.1',
            port = 6006,
        }
    end,
    enabled = is_neovim,
}
