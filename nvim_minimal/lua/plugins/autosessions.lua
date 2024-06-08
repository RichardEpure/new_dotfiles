local is_neovim = require("config.utils").is_neovim
local read_exrc_file = require("config.utils").read_exrc_file

return {
	"rmagatti/auto-session",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	enabled = is_neovim,
	config = function()
		require("auto-session").setup({
			log_level = vim.log.levels.ERROR,
			auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			auto_session_use_git_branch = true,

			auto_session_enable_last_session = false,

			-- ⚠️ This will only work if Telescope.nvim is installed
			session_lens = {
				theme_conf = { border = true },
				previewer = false,
			},

			post_restore_cmds = {
				read_exrc_file,
				function()
					local nnp_enabled = vim.fn.bufname("no-neck-pain-left") ~= ""
					if nnp_enabled then
						vim.api.nvim_exec2("NoNeckPain", {})
					end
				end,
			},
		})

		-- Set mapping for searching a session.
		-- ⚠️ This will only work if Telescope.nvim is installed
		vim.keymap.set(
			"n",
			"<Leader>fs",
			require("auto-session.session-lens").search_session,
			{ noremap = true, desc = "Find session" }
		)
	end,
}
