return {
	"mizlan/iswap.nvim",
	event = "VeryLazy",
	keys = {
		{ "<leader>is", [[:ISwap<CR>]], desc = "Swap" },
		{ "<leader>il", [[:ISwapWithRight<CR>]], desc = "Swap with right" },
		{ "<leader>ih", [[:ISwapWithLeft<CR>]], desc = "Swap with left" },
		{ "<leader>iw", [[:ISwapWith<CR>]], desc = "Swap with" },
		{ "<leader>ins", [[:ISwapNode<CR>]], desc = "Swap node" },
		{ "<leader>inl", [[:ISwapNodeWithRight<CR>]], desc = "Swap node with right" },
		{ "<leader>inh", [[:ISwapNodeWithLeft<CR>]], desc = "Swap node with left" },
		{ "<leader>inw", [[:ISwapNodeWith<CR>]], desc = "Swap node with" },
	},
	opts = {
		flash_style = false,
	},
}
