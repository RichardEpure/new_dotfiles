return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			config = function()
				require("nvim-treesitter-textobjects").setup({
					select = {
						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,
						-- You can choose the select mode (default is charwise 'v')
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * method: eg 'v' or 'o'
						-- and should return the mode ('v', 'V', or '<c-v>') or a table
						-- mapping query_strings to modes.
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
						-- If you set this to `true` (default is `false`) then any textobject is
						-- extended to include preceding or succeeding whitespace. Succeeding
						-- whitespace has priority in order to act similarly to eg the built-in
						-- `ap`.
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * selection_mode: eg 'v'
						-- and should return true of false
						include_surrounding_whitespace = false,
					},
					move = {
						-- whether to set jumps in the jumplist
						set_jumps = true,
					},
				})
				-- Select
				vim.keymap.set({ "x", "o" }, "af", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "if", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ac", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ic", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "as", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
				end)

				local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
				vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
				vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
				vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
				vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
				vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
				vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
			end,
		},
		{

			"daliusd/incr.nvim",
			opts = {
				incr_key = "<Tab>",
				decr_key = "<S-Tab>",
			},
		},
	},
	config = function()
		local ts = require("nvim-treesitter")

		local available = {}
		for _, lang in ipairs(ts.get_available()) do
			available[lang] = true
		end

		local installed = {}
		for _, lang in ipairs(ts.get_installed("parsers")) do
			installed[lang] = true
		end

		local installing = {}
		local pending_by_lang = {}
		local no_indent = {}
		local regex_highlighting = {
			python = true,
			gdscript = true,
		}

		local function setup_buffer_features(bufnr, ft, lang)
			if vim.treesitter.highlighter.active[bufnr] == nil then
				local ok = pcall(vim.treesitter.start, bufnr, lang)
				if not ok then
					return
				end
			end

			if not no_indent[ft] then
				vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end

			if regex_highlighting[ft] then
				vim.bo[bufnr].syntax = "ON"
			end
		end

		local function attach_or_install(bufnr)
			if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
				return
			end

			if vim.bo[bufnr].buftype ~= "" then
				return
			end

			local ft = vim.bo[bufnr].filetype
			if ft == "" then
				return
			end

			local lang = vim.treesitter.language.get_lang(ft) or ft
			if not lang or not available[lang] then
				return
			end

			if installed[lang] then
				setup_buffer_features(bufnr, ft, lang)
				return
			end

			pending_by_lang[lang] = pending_by_lang[lang] or {}
			pending_by_lang[lang][bufnr] = true

			if installing[lang] then
				return
			end

			installing[lang] = true
			local install_task = ts.install({ lang }, { summary = true })
			install_task:await(function()
				installing[lang] = nil
				installed[lang] = vim.tbl_contains(ts.get_installed("parsers"), lang)

				local pending_buffers = pending_by_lang[lang]
				pending_by_lang[lang] = nil
				if not installed[lang] or not pending_buffers then
					return
				end

				vim.schedule(function()
					for pending_bufnr, _ in pairs(pending_buffers) do
						if vim.api.nvim_buf_is_valid(pending_bufnr) and vim.api.nvim_buf_is_loaded(pending_bufnr) then
							attach_or_install(pending_bufnr)
						end
					end
				end)
			end)
		end

		vim.api.nvim_create_autocmd("FileType", {
			desc = "Auto-install and start treesitter",
			callback = function(ctx)
				attach_or_install(ctx.buf)
			end,
		})
	end,
}
