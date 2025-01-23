local is_enabled = require("config.utils").is_neovim

return {
	"ThePrimeagen/git-worktree.nvim",
	enabled = is_enabled,
	keys = {
		-- <c-d> - deletes that worktree
		-- <c-f> - toggles forcing of the next deletion
		-- { "<leader>gt", [[:Telescope git_worktree<CR>]], desc = "Find git worktree" },
		-- {
		-- 	"<leader>gT",
		-- 	function()
		-- 		require("telescope").extensions.git_worktree.create_git_worktree()
		-- 	end,
		-- 	desc = "Create git worktree",
		-- },
	},
	config = function()
		local gwt = require("git-worktree")
		gwt.setup()

		-- local telescope = require("telescope")
		-- telescope.load_extension("git_worktree")
	end,
}
