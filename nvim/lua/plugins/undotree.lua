local is_neovim = require("config.utils").is_neovim

return {
	"mbbill/undotree",
	enabled = is_neovim,
	config = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })
	end,
}
