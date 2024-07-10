local is_neovim = require("config.utils").is_neovim

return {
	"stevearc/conform.nvim",
	enabled = is_neovim,
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				-- lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				-- python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				-- javascript = { { "prettierd", "prettier" } },

				gdscript = { "gdformat" },
				sh = { "shfmt" },
				lua = { "stylua" },
				vue = { "prettierd" },
				jsx = { "prettierd" },
				angular = { "prettierd" },
				typescript = { "prettierd" },
				javascript = { "prettierd" },
				scss = { "prettierd" },
				css = { "prettierd" },
				less = { "prettierd" },
				html = { "prettierd" },
				yaml = { "prettierd" },
				json = { "prettierd" },
				markdown = { "prettierd" },
				python = { "ruff" },
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 500, lsp_fallback = true }
			end,
		})

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting just for this buffer
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, { desc = "Disable autoformat-on-save", bang = true })

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, { desc = "Re-enable autoformat-on-save" })

		vim.api.nvim_create_user_command("FormatToggle", function(args)
			if args.bang then
				vim.b.disable_autoformat = not vim.b.disable_autoformat
			else
				vim.g.disable_autoformat = not vim.g.disable_autoformat
			end
		end, { desc = "Toggle autoformat-on-save" })

		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			conform.format({ async = true, lsp_fallback = true, range = range })
		end, { range = true })

		vim.keymap.set({ "n", "x" }, "<C-f>", [[:Format<CR>]], { silent = true })
	end,
}
