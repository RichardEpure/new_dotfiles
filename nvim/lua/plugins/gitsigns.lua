local is_neovim = require("config.utils").is_neovim

return {
	"lewis6991/gitsigns.nvim",
	enabled = is_neovim,
	config = function()
		local gitsigns = require("gitsigns")
		gitsigns.setup({
			on_attach = function(bufnr)
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end)

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end)

				-- Actions
				map("n", "<leader>-", gitsigns.stage_hunk, { desc = "Stage hunk" })
				map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
				map("v", "<leader>-", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Stage hunk" })
				map("v", "<leader>hr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Reset hunk" })
				map("n", "<leader>ha", gitsigns.stage_buffer, { desc = "Stage buffer" })
				map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
				map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
				map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
				map("n", "<leader>hb", function()
					gitsigns.blame_line({ full = true })
				end, { desc = "Blame line" })
				map("n", "<leader>htb", gitsigns.toggle_current_line_blame, { desc = "Toggle blame line" })
				map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff this" })
				map("n", "<leader>hD", function()
					gitsigns.diffthis("~")
				end, { desc = "Diff this" })
				map("n", "<leader>htd", gitsigns.toggle_deleted, { desc = "Toggle deleted" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
			end,
		})
	end,
}
