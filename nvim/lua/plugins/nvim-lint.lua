local is_neovim = require("config.utils").is_neovim

return {
	"mfussenegger/nvim-lint",
	event = "VeryLazy",
	enabled = is_neovim,
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			python = { "mypy" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged", "TextChangedI" }, {
			callback = function()
				require("lint").try_lint(nil, { ignore_errors = true })
			end,
		})
	end,
}
