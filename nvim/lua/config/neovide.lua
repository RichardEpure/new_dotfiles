if vim.g.neovide then
    vim.opt.guifont = { "JetBrainsMono NF", ":h11" }
    vim.opt.linespace = 3
    vim.g.neovide_scale_factor = 1.0
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_refresh_rate = 120
    vim.g.neovide_refresh_rate_idle = 120
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_scroll_animation_length = 0.05
    vim.api.nvim_create_user_command("AnimationToggleNeovideScroll",
        function()
            local val = vim.g.neovide_scroll_animation_length
            print(val)
            if val == 0 then
                vim.g.neovide_scroll_animation_length = 0.05
                print("Scroll animation enabled")
            else
                vim.g.neovide_scroll_animation_length = 0
                print("Scroll animation disabled")
            end
        end,
        { nargs = 0, }
    )
end

