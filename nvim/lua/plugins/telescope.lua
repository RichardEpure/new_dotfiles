local is_neovim = require("config.utils").is_neovim

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-live-grep-args.nvim",
		"piersolenski/telescope-import.nvim",
		"natecraddock/telescope-zf-native.nvim",
	},
	version = "*",
	enabled = is_neovim,
	config = function()
		local lga_actions = require("telescope-live-grep-args.actions")

		local flash = function(prompt_bufnr)
			require("flash").jump({
				pattern = "^",
				label = { after = { 0, 0 } },
				search = {
					mode = "search",
					exclude = {
						function(win)
							return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
						end,
					},
				},
				action = function(match)
					local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
					picker:set_selection(match.pos[1] - 1)
				end,
			})
		end

		require("telescope").setup({
			defaults = {
				timeout = 1000,
				mappings = {
					n = { s = flash },
					i = { ["<c-s>"] = flash },
				},
			},
			pickers = {
				find_files = {
					mappings = {
						n = {
							["cd"] = function(prompt_bufnr)
								local selection = require("telescope.actions.state").get_selected_entry()
								local dir = vim.fn.fnamemodify(selection.path, ":p:h")
								require("telescope.actions").close(prompt_bufnr)
								-- Depending on what you want put `cd`, `lcd`, `tcd`
								vim.cmd(string.format("silent cd %s", dir))
							end,
						},
					},
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
				live_grep_args = {
					auto_quoting = true,
					mappings = {
						i = {
							["<C-k>"] = lga_actions.quote_prompt(),
							["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
						},
					},
				},
			},
		})

		require("telescope").load_extension("zf-native")
		require("telescope").load_extension("ui-select")
		require("telescope").load_extension("live_grep_args")
		require("telescope").load_extension("import")

		local builtin = require("telescope.builtin")

		local is_git_repo = {}
		local project_files = function()
			local opts = {}

			local cwd = vim.fn.getcwd()
			if is_git_repo[cwd] == nil then
				is_git_repo[cwd] = vim.fn.glob(".git") ~= ""
			end

			if is_git_repo[cwd] then
				builtin.git_files(opts)
			else
				builtin.find_files(opts)
			end
		end

		local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

		vim.keymap.set("n", "<leader>fa", builtin.find_files, { desc = "Find all files" })
		vim.keymap.set("n", "<leader>ff", project_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find old files" })
		vim.keymap.set("n", "<leader>fw", [[:Telescope live_grep_args<CR>]], { desc = "Find word via grep" })
		vim.keymap.set(
			"n",
			"<leader>fW",
			live_grep_args_shortcuts.grep_word_under_cursor,
			{ desc = "Find word under cursor" }
		)
		vim.keymap.set(
			"v",
			"<leader>fw",
			live_grep_args_shortcuts.grep_visual_selection,
			{ desc = "Find visual selection" }
		)
		vim.keymap.set("n", "<leader>fh", function()
			builtin.find_files({ hidden = true })
		end, { desc = "Find hidden files" })
		vim.keymap.set("n", "<leader>fqq", builtin.quickfix, { desc = "Find in quickfix list" })
		vim.keymap.set("n", "<leader>fqh", builtin.quickfixhistory, { desc = "Find quickfix history" })
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
		vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Find commands" })
		vim.keymap.set("n", "<leader>fr", builtin.registers, { desc = "Find registers" })
		vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Find marks" })
		vim.keymap.set("n", "<leader>fu", builtin.resume, { desc = "Resume last telescope search" })
		vim.keymap.set("n", "<leader>fe", builtin.buffers, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Find fuzzy in current buffer" })
		vim.keymap.set("n", "<leader>fg", builtin.git_status, { desc = "Find git status files" })
		vim.keymap.set("n", "<leader>fi", [[:Telescope import<CR>]], { desc = "Find & add import" })
		vim.keymap.set("n", "<leader>fx", builtin.command_history, { desc = "Find in command history" })
		vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Find treesitter symbols" })

		-- Custom functions
		local copy_register_to_clipboard_telescope = function()
			local copy = function(promp_bufnr)
				local actions = require("telescope.actions")
				local actions_state = require("telescope.actions.state")
				local selected = actions_state.get_selected_entry()
				vim.fn.setreg("+", vim.fn.getreg(selected.value))
				actions.close(promp_bufnr)
			end

			require("telescope.builtin").registers({
				attach_mappings = function(_, map)
					map("i", "<CR>", copy)
					map("n", "<CR>", copy)
					return true
				end,
			})
		end
		vim.keymap.set(
			"n",
			"<leader>jcr",
			copy_register_to_clipboard_telescope,
			{ desc = "Copy register to clipboard" }
		)
	end,
}
