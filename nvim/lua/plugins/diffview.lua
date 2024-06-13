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
	keys = {
		{ "<leader>gdo", "<cmd>DiffviewOpen<CR>", desc = "Diff view open", silent = true },
		{ "<leader>gdc", "<cmd>DiffviewClose<CR>", desc = "Diff view close", silent = true },
		{ "<leader>gdr", "<cmd>DiffviewRefresh<CR>", desc = "Diff view refresh", silent = true },
		{ "<leader>gdh", "<cmd>DiffviewFileHistory<CR>", desc = "Diff view file history", silent = true },
	},
	opts = {},
}
