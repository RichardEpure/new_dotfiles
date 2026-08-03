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
				local current_file = vim.api.nvim_buf_get_name(0)

				fyler.open({ kind = "split_left_most" })

				if current_file ~= "" then
					vim.schedule(function()
						local finder = require("fyler.finder").instance_get_or_nil()
						if finder then
							finder:follow({ target_path = current_file })
						end
					end)
				end
			end,
			desc = "Open Fyler View",
		},
	},
	opts = {
		follow_current_file = false,
		follow_root_dir = false,
		hooks = {
			on_highlight = function(hl_groups)
				hl_groups.FylerIndentGuide = { link = "SnacksIndent" }
			end,
		},
		integrations = {
			icon = "nvim_web_devicons",
		},
		extensions = {
			git = { enabled = true },
		},
		kind_presets = {
			split_left_most = {
				width = 70,
			},
		},
		mappings = {
			n = {
				["|"] = { action = "select", args = { vsplit = true } },
				["-"] = { action = "select", args = { split = true } },
				["^"] = { action = "visit", args = { parent = true } },
				["#"] = {
					action = function(finder)
						local state = require("fyler.state")

						finder.state:walk(function(node, depth)
							local entry = state.store[node.value]
							if depth > 0 and entry.type == "directory" then
								finder.state:toggle(entry.path, false)
							end
						end)
						finder:refresh()
					end,
				},
			},
		},
		ui = {
			indent_guides = true,
		},
		use_as_default_explorer = false,
	},
}
