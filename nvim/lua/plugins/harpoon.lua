local is_neovim = require("config.utils").is_neovim

return {
	"ThePrimeagen/harpoon",
	enabled = is_neovim,
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>a",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Add to Harpoon list",
		},
		{
			"<leader>sf",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Toggle Harpoon list",
		},
		{
			"<leader>sh",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "Select Harpoon list 1",
		},
		{
			"<leader>sj",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "Select Harpoon list 2",
		},
		{
			"<leader>sk",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "Select Harpoon list 3",
		},
		{
			"<leader>sl",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "Select Harpoon list 4",
		},
		{
			"<leader>s;",
			function()
				require("harpoon"):list():select(5)
			end,
			desc = "Select Harpoon list 5",
		},
		{
			"<leader>s'",
			function()
				require("harpoon"):list():select(6)
			end,
			desc = "Select Harpoon list 6",
		},

		{
			"<leader>sp",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Select previous in Harpoon list",
		},
		{
			"<leader>sn",
			function()
				require("harpoon"):list():next()
			end,
			desc = "Select next in Harpoon list",
		},
	},
	opts = {},
}
