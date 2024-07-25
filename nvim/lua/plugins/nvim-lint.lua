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

		local linting_enabled = true

		vim.api.nvim_create_user_command("NvimLintToggle", function()
			linting_enabled = not linting_enabled
		end, {})

		vim.api.nvim_create_user_command("NvimLintDisable", function()
			linting_enabled = false
		end, {})

		vim.api.nvim_create_user_command("NvimLintEnable", function()
			linting_enabled = true
		end, {})

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged", "TextChangedI" }, {
			callback = function()
				if not linting_enabled then
					return
				end
				lint.try_lint(nil, { ignore_errors = true })
			end,
		})
	end,
}
