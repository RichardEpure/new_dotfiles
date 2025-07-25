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

		-- Use local mypy if available
		local venv_dir = os.getenv("VIRTUAL_ENV")
		if venv_dir then
			local py_cmd = venv_dir
			local mypy_cmd = venv_dir
			if vim.fn.has("win32") == 1 and mypy_cmd then
				py_cmd = py_cmd .. "\\Scripts\\python"
				mypy_cmd = mypy_cmd .. "\\Scripts\\mypy"
			elseif vim.fn.has("linux") and mypy_cmd then
				py_cmd = py_cmd .. "/bin/python"
				mypy_cmd = mypy_cmd .. "/bin/mypy"
			end

			local local_mypy = {}
			for k, v in pairs(lint.linters.mypy) do
				local_mypy[k] = v
			end

			local_mypy.cmd = mypy_cmd
			local_mypy.args = {
				"--show-column-numbers",
				"--show-error-end",
				"--hide-error-codes",
				"--hide-error-context",
				"--no-color-output",
				"--no-error-summary",
				"--no-pretty",
				"--python-executable",
				py_cmd,
			}
			lint.linters.local_mypy = local_mypy
			-- lint.linters_by_ft.python = { "local_mypy" }
		end

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
