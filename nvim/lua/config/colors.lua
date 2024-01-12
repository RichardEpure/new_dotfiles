local is_neovim = require("config.utils").is_neovim

local set_colour = function(color)
    vim.cmd.colorscheme(color)

    local lualine_c = vim.api.nvim_get_hl(0, { name = 'lualine_c_normal' })
    local orange = vim.api.nvim_get_hl(0, { name = 'Orange' })
    vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#585858' })
    vim.api.nvim_set_hl(0, 'lualine_c_normal', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'lualine_c_insert', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'lualine_c_visual', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'lualine_c_inactive', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'lualine_c_command', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'lualine_c_termial', { link = 'Normal' })

    if vim.g.colors_name == "gruvbox-material" then
        vim.api.nvim_set_hl(0, 'NormalFloat', { fg = lualine_c.fg, bg = lualine_c.bg })
        vim.api.nvim_set_hl(0, 'FloatTitle', { fg = orange.fg, bg = lualine_c.bg })
        vim.api.nvim_set_hl(0, 'FloatBorder', { fg = lualine_c.bg, bg = lualine_c.bg })
        vim.api.nvim_set_hl(0, 'BqfPreviewBorder', { link = 'TelescopeBorder' })
    end

    if (vim.g.colors_name == "gruvbox-material" and vim.g.gruvbox_material_background == "hard") or
        vim.g.colors_name == "alabaster" then
        vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#444444' })
    end
end

local set_colour_telescope = function(prompt_bufnr)
    local actions = require("telescope.actions")
    local actions_state = require("telescope.actions.state")
    local selected = actions_state.get_selected_entry()
    set_colour(selected.value)
    actions.close(prompt_bufnr)
end

if is_neovim() then
    vim.api.nvim_create_user_command("Colour",
        function()
            require("telescope.builtin").colorscheme({
                attach_mappings = function(_, map)
                    map("i", "<CR>", set_colour_telescope)
                    map("n", "<CR>", set_colour_telescope)
                    return true
                end,
            })
        end,
        { nargs = 0, }
    )

    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_transparent_background = 0

    set_colour("gruvbox-material")
end
