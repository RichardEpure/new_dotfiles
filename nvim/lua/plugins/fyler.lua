local is_neovim = require("config.utils").is_neovim

return {
	"A7Lavinraj/fyler.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	enabled = is_neovim,
	lazy = false,
	init = function()
		vim.g.loaded_netrwPlugin = 1
	end,
	keys = {
		{
			"<leader>e",
			function()
				local fyler = require("fyler")
				local cwd = vim.fn.getcwd()
				local current_file = vim.api.nvim_buf_get_name(0)
				local target_file = current_file ~= "" and vim.fs.relpath(cwd, current_file) or nil

				fyler.open({ kind = "split_left_most" })

				if target_file then
					vim.defer_fn(function()
						fyler.navigate(target_file)
					end, 0)
				end
			end,
			desc = "Open Fyler View",
		},
	},
	opts = {
		hooks = {
			on_highlight = function(hl_groups)
				hl_groups.FylerIndentMarker = { link = "SnacksIndent" }
			end,
		},
		integrations = {
			icon = "nvim_web_devicons",
		},
		views = {
			finder = {
				follow_current_file = false,
				win = {
					kinds = {
						split_left_most = {
							width = 70,
						},
					},
				},
				mappings = {
					["q"] = "CloseView",
					["<CR>"] = "Select",
					["<C-t>"] = "SelectTab",
					["|"] = "SelectVSplit",
					["-"] = "SelectSplit",
					["^"] = "GotoParent",
					["="] = "GotoCwd",
					["."] = "GotoNode",
					["#"] = "CollapseAll",
					["<BS>"] = "CollapseNode",
				},
			},
		},
	},
}
