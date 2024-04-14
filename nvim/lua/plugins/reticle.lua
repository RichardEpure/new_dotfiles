local is_neovim = require("config.utils").is_neovim
return {
	"tummetott/reticle.nvim",
	enabled = is_neovim,
	opts = {
		ignore = {
			cursorline = {
				"DressingInput",
				"FTerm",
				"NvimSeparator",
				"NvimTree",
				"TelescopePrompt",
				"Trouble",
				"toggleterm",
			},
		},
	},
}
