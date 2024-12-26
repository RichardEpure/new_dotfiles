local is_neovim = require("config.utils").is_neovim

return {
	"folke/snacks.nvim",
	enabled = is_neovim,
	opts = {
		indent = {
			animate = {
				enabled = false,
			},
			scope = {
				enabled = false,
			},
		},
		bigfile = {},
	},
}
