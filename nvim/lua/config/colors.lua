local is_neovim = require("config.utils").is_neovim

local setColour = function(color)
    vim.cmd.colorscheme(color)
    vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#585858' })

    if vim.g.colors_name == "gruvbox-material" then
        local lualine_c_normal = vim.api.nvim_get_hl(0, { name = 'lualine_c_normal' })
        local orange = vim.api.nvim_get_hl(0, { name = 'Orange' })
        vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'lualine_c_normal' })
        vim.api.nvim_set_hl(0, 'FloatTitle', { fg = orange.fg, bg = lualine_c_normal.bg })
        vim.api.nvim_set_hl(0, 'FloatBorder', { fg = lualine_c_normal.bg, bg = lualine_c_normal.bg })
    end

    if (vim.g.colors_name == "gruvbox-material" and vim.g.gruvbox_material_background == "hard") or
        vim.g.colors_name == "alabaster" then
        vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#444444' })
    end
end

local setColourTelescope = function(prompt_bufnr)
    local actions = require("telescope.actions")
    local actions_state = require("telescope.actions.state")
    local selected = actions_state.get_selected_entry()
    setColour(selected.value)
    actions.close(prompt_bufnr)
end

if is_neovim() then
    vim.api.nvim_create_user_command("Colour",
        function()
            require("telescope.builtin").colorscheme({
                attach_mappings = function(_, map)
                    map("i", "<CR>", setColourTelescope)
                    map("n", "<CR>", setColourTelescope)
                    return true
                end,
            })
        end,
        { nargs = 0, }
    )

    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_transparent_background = 0

    setColour("gruvbox-material")
end
