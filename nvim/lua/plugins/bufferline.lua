local is_neovim = require("config.utils").is_neovim

return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	version = "*",
	enabled = is_neovim,
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				style_preset = bufferline.style_preset.minimal,
				themable = true,
				separator_style = { "", "" },
				always_show_bufferline = false,
				indicator = {
					style = "none",
				},
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or ""
					return " " .. icon .. count
				end,
				numbers = function(opts)
					return string.format("%s", opts.ordinal)
				end,
			},
		})

		for i = 1, 9 do
			vim.keymap.set(
				{ "n", "v" },
				"<leader>" .. i,
				'<cmd>lua require("bufferline").go_to_buffer(' .. i .. ", false)<cr>",
				{ noremap = true, silent = true, desc = "Go to buffer " .. i }
			)
		end

		vim.keymap.set(
			{ "n", "v" },
			"<leader>$",
			'<cmd>lua require("bufferline").go_to_buffer(-1, false)<cr>',
			{ noremap = true, silent = true, desc = "Go to last buffer" }
		)

		vim.keymap.set(
			{ "n", "v" },
			"<up>",
			[[:BufferLineCycleNext<cr>]],
			{ noremap = true, silent = true, desc = "Go to next buffer" }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<down>",
			[[:BufferLineCyclePrev<cr>]],
			{ noremap = true, silent = true, desc = "Go to previous buffer" }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<right>",
			[[:BufferLineMoveNext<cr>]],
			{ noremap = true, silent = true, desc = "Move buffer to next position" }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<left>",
			[[:BufferLineMovePrev<cr>]],
			{ noremap = true, silent = true, desc = "Move buffer to previous position" }
		)
	end,
}
