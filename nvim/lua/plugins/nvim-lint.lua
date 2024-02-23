local is_neovim = require("config.utils").is_neovim

return {
	"mfussenegger/nvim-lint",
	event = "VeryLazy",
	enabled = false,
	config = function()
		require("lint").linters_by_ft = {}

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				require("lint").try_lint(nil, { ignore_errors = true })
			end,
		})
	end,
}
