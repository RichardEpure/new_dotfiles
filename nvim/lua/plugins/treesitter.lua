return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			config = function()
				-- When in diff mode, we want to use the default
				-- vim text objects c & C instead of the treesitter ones.
				local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
				local configs = require("nvim-treesitter.configs")
				for name, fn in pairs(move) do
					if name:find("goto") == 1 then
						move[name] = function(q, ...)
							if vim.wo.diff then
								local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
								for key, query in pairs(config or {}) do
									if q == query and key:find("[%]%[][cC]") then
										vim.cmd("normal! " .. key)
										return
									end
								end
							end
							return fn(q, ...)
						end
					end
				end
			end,
		},
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			-- A list of parser names, or "all" (the five listed parsers should always be installed)
			ensure_installed = { "markdown", "markdown_inline" },

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			-- List of parsers to ignore installing (for "all")
			-- ignore_install = { "javascript" },

			---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
			-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

			highlight = {
				enable = true,

				-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
				-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
				-- the name of the parser)
				-- list of language that will be disabled
				-- disable = { "c", "rust" },
				-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files

				custom_captures = {
					-- ["selectors"] = "Special",
				},
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = { "python", "gdscript" },

				-- disable = function(lang, buf)
				-- 	local max_filesize = 100 * 1024 -- 100 KB
				-- 	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				-- 	if ok and stats and stats.size > max_filesize then
				-- 		return true
				-- 	end
				-- end,
			},

			indent = {
				enable = true,
			},

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-s>",
					scope_incremental = "<C-s>",
					node_incremental = "<TAB>",
					node_decremental = "<S-TAB>",
				},
			},

			markdown = {
				enable = true,
			},

			textobjects = {
				select = {
					enable = true,

					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,

					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						-- You can optionally set descriptions to the mappings (used in the desc parameter of
						-- nvim_buf_set_keymap) which plugins like which-key display
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
						-- You can also use captures from other query groups like `locals.scm`
						["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
					},
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
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]m"] = "@function.outer",
						-- ["]c"] = { query = "@class.outer", desc = "Next class start" },
						["]a"] = "@parameter.outer",
						--
						-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
						["]o"] = "@loop.*",
						-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
						--
						-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
						-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
						["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
						["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						-- ["]C"] = "@class.outer",
						["]A"] = "@parameter.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						-- ["[c"] = "@class.outer",
						["[a"] = "@parameter.outer",
						-- ["[["] = "@attribute.outer",
						--
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						-- ["[C"] = "@class.outer",
						["[A"] = "@parameter.outer",
					},
					-- Below will go to either the start or the end, whichever is closer.
					-- Use if you want more granular movements
					-- Make it even more gradual by adding multiple queries and regex.
					goto_next = {
						["]d"] = "@conditional.outer",
					},
					goto_previous = {
						["[d"] = "@conditional.outer",
					},
				},
			},
		})

		local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

		-- Repeat movement with ; and ,
		-- ensure ; goes forward and , goes backward regardless of the last direction
		vim.keymap.set({ "n", "x", "o" }, "]]", ts_repeat_move.repeat_last_move_next)
		vim.keymap.set({ "n", "x", "o" }, "[[", ts_repeat_move.repeat_last_move_previous)

		vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
		vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
		vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
		vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
	end,
}
-- NOTE: Parsers bugged for now
-- return {
-- 	"nvim-treesitter/nvim-treesitter",
-- 	lazy = false,
-- 	branch = "main",
-- 	build = ":TSUpdate",
-- 	dependencies = {
-- 		{
-- 			"nvim-treesitter/nvim-treesitter-textobjects",
-- 			branch = "main",
-- 			config = function()
-- 				require("nvim-treesitter-textobjects").setup({
-- 					select = {
-- 						-- Automatically jump forward to textobj, similar to targets.vim
-- 						lookahead = true,
-- 						-- You can choose the select mode (default is charwise 'v')
-- 						--
-- 						-- Can also be a function which gets passed a table with the keys
-- 						-- * query_string: eg '@function.inner'
-- 						-- * method: eg 'v' or 'o'
-- 						-- and should return the mode ('v', 'V', or '<c-v>') or a table
-- 						-- mapping query_strings to modes.
-- 						selection_modes = {
-- 							["@parameter.outer"] = "v", -- charwise
-- 							["@function.outer"] = "V", -- linewise
-- 							["@class.outer"] = "<c-v>", -- blockwise
-- 						},
-- 						-- If you set this to `true` (default is `false`) then any textobject is
-- 						-- extended to include preceding or succeeding whitespace. Succeeding
-- 						-- whitespace has priority in order to act similarly to eg the built-in
-- 						-- `ap`.
-- 						--
-- 						-- Can also be a function which gets passed a table with the keys
-- 						-- * query_string: eg '@function.inner'
-- 						-- * selection_mode: eg 'v'
-- 						-- and should return true of false
-- 						include_surrounding_whitespace = false,
-- 					},
-- 					move = {
-- 						-- whether to set jumps in the jumplist
-- 						set_jumps = true,
-- 					},
-- 				})
-- 				-- Select
-- 				vim.keymap.set({ "x", "o" }, "af", function()
-- 					require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
-- 				end)
-- 				vim.keymap.set({ "x", "o" }, "if", function()
-- 					require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
-- 				end)
-- 				vim.keymap.set({ "x", "o" }, "ac", function()
-- 					require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
-- 				end)
-- 				vim.keymap.set({ "x", "o" }, "ic", function()
-- 					require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
-- 				end)
-- 				vim.keymap.set({ "x", "o" }, "as", function()
-- 					require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
-- 				end)
--
-- 				local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
-- 				vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
-- 				vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
-- 				vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
-- 				vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
-- 				vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
-- 				vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
-- 			end,
-- 		},
-- 		{
--
-- 			"daliusd/incr.nvim",
-- 			opts = {
-- 				incr_key = "<C-s>",
-- 				decr_key = "<S-s>",
-- 			},
-- 		},
-- 	},
-- 	opts = true,
-- 	config = function()
-- 		vim.api.nvim_create_autocmd("FileType", {
-- 			desc = "Enable treesitter highlighting",
-- 			callback = function(ctx)
-- 				-- highlights
-- 				local hasStarted = pcall(vim.treesitter.start) -- errors for filetypes with no parser
-- 				print("hasStarted: " .. tostring(hasStarted))
-- 				-- indent
-- 				-- local noIndent = {}
-- 				-- if hasStarted and not vim.list_contains(noIndent, ctx.match) then
-- 				-- 	vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
-- 				-- end
-- 			end,
-- 		})
-- 	end,
-- }
