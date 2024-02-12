local is_neovim = require("config.utils").is_neovim

return {
	"sindrets/diffview.nvim",
	enabled = is_neovim,
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewLog",
		"DiffviewRefresh",
		"DiffviewFocusFiles",
		"DiffviewFileHistory",
		"DiffviewToggleFiles",
	},
	opts = {},
	config = function(opts)
		local diffview = require("diffview")
		diffview.setup(opts)
	end,
}
