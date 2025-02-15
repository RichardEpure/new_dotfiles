local is_neovim = require("config.utils").is_neovim

return {
	"bassamsdata/namu.nvim",
	keys = {
		{ "<leader>fa", [[:Namu symbols<CR>]], desc = "Namu Symbols", { "n" } },
	},
	enabled = is_neovim,
	config = function()
		require("namu").setup({
			namu_symbols = {
				enable = true,
				options = {},
			},
			colorscheme = {
				enable = false,
				options = {
					-- NOTE: if you activate persist, then please remove any vim.cmd("colorscheme ...") in your config, no needed anymore
					persist = true, -- very efficient mechanism to Remember selected colorscheme
					write_shada = false, -- If you open multiple nvim instances, then probably you need to enable this
				},
			},
			ui_select = { enable = false }, -- vim.ui.select() wrapper
		})
	end,
}
