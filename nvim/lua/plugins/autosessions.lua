local is_neovim = require('config.utils').is_neovim

return {
    'rmagatti/auto-session',
    enabled = is_neovim,
    config = function()
        require('auto-session').setup {
            log_level = vim.log.levels.ERROR,
            auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            auto_session_use_git_branch = false,

            auto_session_enable_last_session = false,

            -- ⚠️ This will only work if Telescope.nvim is installed
            session_lens = {
                theme_conf = { border = true },
                previewer = false,
            },
        }

        -- Set mapping for searching a session.
        -- ⚠️ This will only work if Telescope.nvim is installed
        vim.keymap.set(
            "n",
            "<Leader>fs",
            require("auto-session.session-lens").search_session,
            { noremap = true }
        )
    end
}
