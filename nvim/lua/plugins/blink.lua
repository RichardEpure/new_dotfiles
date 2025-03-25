local is_neovim = require("config.utils").is_neovim

return {
	"saghen/blink.cmp",
	enabled = is_neovim,
	version = "*",
	dependencies = "rafamadriz/friendly-snippets",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		cmdline = {
			enabled = true,

			completion = {
				list = {
					selection = {
						preselect = false,
						auto_insert = true,
					},
				},
				menu = {
					auto_show = true,
				},
			},
		},

		enabled = function()
			local disabled_filetypes = { "snacks_picker_input", "gitcommit" }
			return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype) and vim.b.completion ~= false
		end,

		-- 'default' for mappings similar to built-in completion
		-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
		-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
		-- See the full "keymap" documentation for information on defining your own keymap.
		keymap = {
			preset = "default",
			["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
		},

		appearance = {
			-- Sets the fallback highlight groups to nvim-cmp's highlight groups
			-- Useful for when your theme doesn't support blink.cmp
			-- Will be removed in a future release
			use_nvim_cmp_as_default = true,
			-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 0,
			},
			list = {
				selection = {
					preselect = false,
					auto_insert = true,
				},
			},
			menu = {
				auto_show = true,
			},
		},

		-- Too laggy sometimes
		-- signature = {
		-- 	enabled = true,
		-- },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = function()
				local success, node = pcall(vim.treesitter.get_node)
				if
					success
					and node
					and vim.tbl_contains({
						"comment_content",
						"comment",
						"line_comment",
						"block_comment",
					}, node:type())
				then
					return {}
				else
					return {
						"lsp",
						"path",
						"snippets",
						"buffer",
					}
				end
			end,
		},
	},
}
