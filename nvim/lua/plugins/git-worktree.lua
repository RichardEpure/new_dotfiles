local is_enabled = require("config.utils").is_neovim

return {
	"ThePrimeagen/git-worktree.nvim",
	enabled = is_enabled,
	config = function()
		local gwt = require("git-worktree")
		gwt.setup()

		local telescope = require("telescope")
		telescope.load_extension("git_worktree")

		-- <c-d> - deletes that worktree
		-- <c-f> - toggles forcing of the next deletion
		vim.keymap.set("n", "<Leader>ft", [[:Telescope git_worktree<CR>]], { desc = "Find git worktree" })
		vim.keymap.set(
			"n",
			"<Leader>gt",
			telescope.extensions.git_worktree.create_git_worktree,
			{ desc = "Create git worktree" }
		)
	end,
}
