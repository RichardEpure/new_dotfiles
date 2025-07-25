return {
	"echasnovski/mini.indentscope",
	version = false,
	config = function()
		local indentscope = require("mini.indentscope")

		indentscope.setup({
			draw = {
				delay = 0,
				animation = indentscope.gen_animation.none(),
			},
			options = {
				try_as_border = true,
			},
			symbol = vim.g.vscode == nil and "│" or "",
		})

		-- Disable for certain filetypes
		vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
			desc = "Disable indentscope for certain filetypes",
			callback = function()
				local ignore_filetypes = {
					"",
					"aerial",
					"dashboard",
					"help",
					"lazy",
					"leetcode.nvim",
					"mason",
					"neo-tree",
					"NvimTree",
					"neogitstatus",
					"notify",
					"startify",
					"toggleterm",
					"Trouble",
					"git",
					"fugitive",
					"log",
					"txt",
					"md",
				}
				if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
					vim.b.miniindentscope_disable = true
				end
			end,
		})
	end,
}
