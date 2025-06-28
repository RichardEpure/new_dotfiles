local is_neovim = require("config.utils").is_neovim

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
	enabled = is_neovim,
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "rose-pine-alt",
				-- component_separators = { left = '', right = '' },
				-- section_separators = { left = '', right = '' },
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{ "branch" },
					{ "diff" },
					{ "diagnostics" },
					{ "filename", path = 1 },
				},
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
					{ "progress" },
					{ "location" },
				},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{ "filename", color = "Normal" },
				},
				lualine_x = {
					{ "location", color = "Normal" },
				},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = { "toggleterm" },
		})
	end,
}
