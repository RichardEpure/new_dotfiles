local is_neovim = require("config.utils").is_neovim

return {
	"mfussenegger/nvim-lint",
	event = "VeryLazy",
	enabled = is_neovim,
	config = function()
		require("lint").linters_by_ft = {
			python = { "mypy" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
			callback = function()
				require("lint").try_lint(nil, { ignore_errors = true })
			end,
		})
	end,
}
