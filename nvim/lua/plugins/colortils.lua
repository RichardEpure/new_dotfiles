local is_neovim = require("config.utils").is_neovim

return {
	"max397574/colortils.nvim",
	enabled = is_neovim(),
	cmd = "Colortils",
	keys = {
		{ "<leader>jp", [[:Colortils<CR>]], desc = "Colour picker", silent = true },
	},
	opts = {
		mappings = {
			set_register_default_format = "r",
			set_register_choose_format = "<C-r>",
			replace_default_format = "<CR>",
			replace_choose_format = "f",
		},
	},
}
