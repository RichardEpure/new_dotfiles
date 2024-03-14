return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{
			"<leader>re",
			function()
				require("refactoring").refactor("Extract Function")
			end,
			desc = "Extract Function",
			mode = "x",
		},
		{
			"<leader>rf",
			function()
				require("refactoring").refactor("Extract Function To File")
			end,
			desc = "Extract function to file",
			mode = "x",
		},
		-- Extract function supports only visual mode
		{
			"<leader>re",
			function()
				require("refactoring").refactor("Extract Variable")
			end,
			desc = "Extract variable",
			mode = "x",
		},
		-- Extract variable supports only visual mode
		{
			"<leader>rI",
			function()
				require("refactoring").refactor("Inline Function")
			end,
			desc = "Inline function",
		},
		-- Inline func supports only normal
		{
			"<leader>ri",
			function()
				require("refactoring").refactor("Inline Variable")
			end,
			desc = "Inline variable",
			mode = { "n", "x" },
		},
		-- Inline var supports both normal and visual mode

		{
			"<leader>rb",
			function()
				require("refactoring").refactor("Extract Block")
			end,
			desc = "Extract block",
		},
		{
			"<leader>rbf",
			function()
				require("refactoring").refactor("Extract Block To File")
			end,
			desc = "Extract block to file",
		},
		{
			"<leader>rp",
			function()
				-- You can also use below = true here to to change the position of the printf
				-- statement (or set two remaps for either one). This remap must be made in normal mode.
				require("refactoring").debug.printf({ below = true })
			end,
			desc = "Print variable (insert below)",
		},
		{
			"<leader>rP",
			function()
				require("refactoring").debug.printf({ below = false })
			end,
			desc = "Print variable (insert above)",
		},
		{
			"<leader>rv",
			function()
				require("refactoring").debug.print_var({ below = true })
			end,
			desc = "Print variable (insert below)",
			mode = { "n", "x" },
		},
		{
			"<leader>rV",
			function()
				require("refactoring").debug.print_var({ below = false })
			end,
			desc = "Print variable (insert above)",
			mode = { "n", "x" },
		},
		{
			"<leader>rc",
			function()
				require("refactoring").debug.cleanup({})
			end,
			desc = "Refactor cleanup",
		},
		{
			"<leader>rr",
			function()
				if vim.g.vscode == nil then
					require("telescope").extensions.refactoring.refactors()
				end
			end,
			desc = "Refactor",
			mode = { "n", "x" },
		},
	},
	config = function()
		require("refactoring").setup()

		if vim.g.vscode == nil then
			require("telescope").load_extension("refactoring")
		end
	end,
}
