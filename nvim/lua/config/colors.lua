local is_neovim = require("config.utils").is_neovim

local set_colour = function(color)
	vim.cmd.colorscheme(color)

	local lualine_c = vim.api.nvim_get_hl(0, { name = "lualine_c_normal" })
	local orange = vim.api.nvim_get_hl(0, { name = "Orange" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { link = "LineNr" })
	vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#585858" })
	vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#353535" })
	if vim.g.colors_name == "alabaster" then
		vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#1b2628" })
	elseif vim.g.colors_name == "gruvbox-material" and vim.g.gruvbox_material_background == "hard" then
		vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#2a2a2a" })
	elseif vim.g.colors_name == "rose-pine" then
		vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#242032" })
	end

	if vim.g.colors_name == "gruvbox-material" then
		vim.api.nvim_set_hl(0, "FlashLabel", { link = "Substitute" })
		vim.api.nvim_set_hl(0, "NormalFloat", { fg = lualine_c.fg, bg = lualine_c.bg })
		vim.api.nvim_set_hl(0, "FloatTitle", { fg = orange.fg, bg = lualine_c.bg })
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = lualine_c.bg, bg = lualine_c.bg })
		vim.api.nvim_set_hl(0, "BqfPreviewBorder", { link = "TelescopeBorder" })
	end

	if
		(vim.g.colors_name == "gruvbox-material" and vim.g.gruvbox_material_background == "hard")
		or vim.g.colors_name == "alabaster"
	then
		vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#444444" })
	end

	if vim.g.colors_name == "rose-pine" then
		vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#3c3757" })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#232037" })
	end
end

if is_neovim() then
	set_colour("rose-pine")
end
