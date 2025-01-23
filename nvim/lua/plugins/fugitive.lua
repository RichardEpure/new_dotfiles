local is_neovim = require("config.utils").is_neovim

return {
	"tpope/vim-fugitive",
	enabled = is_neovim,
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })
	end,
}
