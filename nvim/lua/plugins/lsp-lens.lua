local is_neovim = require("config.utils")

return {
	"VidocqH/lsp-lens.nvim",
	enabled = is_neovim,
	opts = {
		sections = {
			definition = true,
			references = true,
			implements = true,
			git_authors = false,
		},
	},
}
