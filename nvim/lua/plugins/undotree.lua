local is_neovim = require("config.utils").is_neovim

return {
	"mbbill/undotree",
	enabled = is_neovim,
	config = function()
		vim.keymap.set("n", "<leader>u", function()
			vim.cmd.UndotreeToggle()
			vim.cmd.UndotreeFocus()
		end, { desc = "Toggle undotree" })

		if vim.fn.has("win32") == 1 then
			vim.g.undotree_DiffCommand = "FC"
		end
	end,
}
