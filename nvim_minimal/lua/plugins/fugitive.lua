return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })
		vim.keymap.set("n", "<leader>gb", [[:Telescope git_branches<CR>]], { desc = "Git branches" })
		vim.keymap.set("n", "<leader>gc", [[:Telescope git_commits<CR>]], { desc = "Git commits" })
	end,
}
