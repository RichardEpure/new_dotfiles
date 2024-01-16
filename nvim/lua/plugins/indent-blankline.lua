local is_neovim = require("config.utils").is_neovim

return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	enabled = is_neovim,
	config = function()
		local hooks = require("ibl.hooks")
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#353535" })
			if vim.g.colors_name == "alabaster" then
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#1b2628" })
			elseif vim.g.colors_name == "gruvbox-material" and vim.g.gruvbox_material_background == "hard" then
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2a2a2a" })
			end
		end)

		require("ibl").setup({
			indent = { char = "│" },
			scope = { enabled = false },
		})
	end,
}
