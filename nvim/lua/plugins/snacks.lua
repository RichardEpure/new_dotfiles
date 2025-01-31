local is_neovim = require("config.utils").is_neovim

return {
	"folke/snacks.nvim",
	enabled = is_neovim,
	lazy = false,
	keys = {
		{
			"<leader>fe",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fw",
			function()
				require("snacks").picker.grep({ live = true })
			end,
			desc = "Grep",
		},
		{
			"<leader>f:",
			function()
				require("snacks").picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>ff",
			function()
				require("snacks").picker.smart()
			end,
			desc = "Find Files (smart)",
		},
		{
			"<leader>fF",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fg",
			function()
				require("snacks").picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>fo",
			function()
				require("snacks").picker.recent()
			end,
			desc = "Recent",
		},
		{
			"<leader>gc",
			function()
				require("snacks").picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gC",
			function()
				require("snacks").picker.git_log_file()
			end,
			desc = "Git Log File",
		},
		{
			"<leader>g<C-c>",
			function()
				require("snacks").picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>fz",
			function()
				require("snacks").picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>f<c-w>",
			function()
				require("snacks").picker.grep_buffers()
			end,
			desc = "Grep Open Buffers",
		},
		{
			"<leader>fW",
			function()
				require("snacks").picker.grep_word({ live = true })
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		{
			"<leader>fr",
			function()
				require("snacks").picker.registers()
			end,
			desc = "Registers",
		},
		{
			"<leader>fa",
			function()
				require("snacks").picker.autocmds()
			end,
			desc = "Autocmds",
		},
		{
			"<leader>fc",
			function()
				require("snacks").picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>fd",
			function()
				require("snacks").picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>fD",
			function()
				require("snacks").picker.diagnostics_buffer()
			end,
			desc = "Diagnostics Buffer",
		},
		{
			"<leader>fj",
			function()
				require("snacks").picker.jumps()
			end,
			desc = "Jumps",
		},
		{
			"<leader>fk",
			function()
				require("snacks").picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>fl",
			function()
				require("snacks").picker.loclist()
			end,
			desc = "Location List",
		},
		{
			"<leader>fm",
			function()
				require("snacks").picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>fu",
			function()
				require("snacks").picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>fq",
			function()
				require("snacks").picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>fp",
			function()
				require("snacks").picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fP",
			function()
				require("snacks").picker.zoxide()
			end,
			desc = "Zoxide",
		},
		-- LSP
		-- {
		-- 	"gd",
		-- 	function()
		-- 		require("snacks").picker.lsp_definitions()
		-- 	end,
		-- 	desc = "Goto Definition",
		-- },
		-- {
		-- 	"gr",
		-- 	function()
		-- 		require("snacks").picker.lsp_references()
		-- 	end,
		-- 	nowait = true,
		-- 	desc = "References",
		-- },
		{
			"gI",
			function()
				require("snacks").picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		-- {
		-- 	"gy",
		-- 	function()
		-- 		require("snacks").picker.lsp_type_definitions()
		-- 	end,
		-- 	desc = "Goto T[y]pe Definition",
		-- },
		{
			"<leader>ft",
			function()
				require("snacks").picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader><leader>e",
			function()
				require("snacks").picker.explorer()
			end,
		},
	},
	opts = {
		indent = {
			animate = {
				enabled = false,
			},
			scope = {
				enabled = false,
			},
		},
		bigfile = {},
		picker = {},
		quickfile = {},
	},
}
