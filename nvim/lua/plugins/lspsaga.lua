local is_neovim = require("config.utils").is_neovim

return {
	"nvimdev/lspsaga.nvim",
	enabled = is_neovim,
	event = "LspAttach",
	keys = {
		{
			"<leader>ad",
			[[:Lspsaga peek_definition<CR>]],
			desc = "Peek definition",
			silent = true,
		},
		{
			"<leader>at",
			[[:Lspsaga peek_type_definition<CR>]],
			desc = "Peek type definition",
			silent = true,
		},
		{
			"<leader>af",
			[[:Lspsaga finder<CR>]],
			desc = "Finder",
			silent = true,
		},
		{
			"<leader>ab",
			[[:Lspsaga show_buf_diagnostics<CR>]],
			desc = "Buffer diagnostics",
			silent = true,
		},
		{
			"<leader>aD",
			[[:Lspsaga show_workspace_diagnostics<CR>]],
			desc = "Workspace diagnostics",
			silent = true,
		},
		{
			"<leader>al",
			[[:Lspsaga show_line_diagnostics<CR>]],
			desc = "Line diagnostics",
			silent = true,
		},
		{
			"<F2>",
			[[:Lspsaga rename<CR>]],
			desc = "Rename",
			silent = true,
		},
	},
	opts = {
		symbol_in_winbar = {
			enable = false,
		},
		finder = {
			keys = {
				toggle_or_open = "<CR>",
			},
		},
		rename = {
			keys = {
				quit = "q",
			},
		},
		lightbulb = {
			enable = false,
		},
	},
}
