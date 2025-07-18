vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to clipboard" })
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("x", "<leader>jk", [[:sort<CR>]], { desc = "Sort lines" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole register" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to clipboard" })
vim.keymap.set({ "n", "x" }, "&", "g_")
vim.keymap.set({ "n", "x" }, "£", "0")
vim.keymap.set({ "n", "v" }, "<leader>/", "/\\c", { desc = "Forwards search case insensitive" })
vim.keymap.set({ "n", "v" }, "<leader>?", "?\\c", { desc = "Backwards search case insensitive" })
vim.keymap.set({ "n", "v" }, "<leader>#", [[:b#<CR>]], { silent = true, desc = "Switch to alternate buffer" })
vim.keymap.set("n", "<leader>jcf", function()
	local path = vim.fn.expand("%")
	vim.fn.setreg('"', path)
	print("Copied " .. path .. ' to register "')
end, { desc = "Copy current buffer path to anonymous register" })
vim.keymap.set("x", "<leader>jsi", [[:s/^\s*\zs\ze\S/]], { desc = "Prepend to lines" })
vim.keymap.set("x", "<leader>jsa", [[:s/\S\zs$/]], { desc = "Append to lines" })
vim.keymap.set("n", "<leader>ot", [[:!wt.exe -d "%:p:h"<CR>]], { desc = "Open wt at this file's directory" })
vim.keymap.set("n", "<leader>oe", [[:!explorer.exe "%:p:h"<CR>]], { desc = "Open explorer at this file's directory" })
vim.keymap.set("n", "<leader>opt", [[:!wt.exe -d .<CR>]], { desc = "Open wt at cwd" })
vim.keymap.set("n", "<leader>ope", [[:!explorer.exe .<CR>]], { desc = "Open explorer at cwd" })

if vim.g.vscode then
	local vscode = require("vscode-neovim")

	local comment = {
		selected = function()
			vim.fn.VSCodeNotify("editor.action.commentLine")
		end,
	}

	local file = {
		new = function()
			vim.fn.VSCodeNotify("workbench.explorer.fileView.focus")
			vim.fn.VSCodeNotify("explorer.newFile")
		end,

		save = function()
			vim.fn.VSCodeNotify("workbench.action.files.save")
		end,

		saveAll = function()
			vim.fn.VSCodeNotify("workbench.action.files.saveAll")
		end,

		close = function()
			vim.fn.VSCodeNotify("workbench.action.closeActiveEditor")
		end,

		format = function()
			vim.fn.VSCodeNotify("editor.action.formatDocument")
		end,

		showInExplorer = function()
			vim.fn.VSCodeNotify("workbench.files.action.showActiveFileInExplorer")
		end,

		rename = function()
			vim.fn.VSCodeNotify("workbench.files.action.showActiveFileInExplorer")
			vim.fn.VSCodeNotify("renameFile")
		end,
	}

	local action = {
		quickOpen = function()
			vim.fn.VSCodeNotify("workbench.action.quickOpen")
		end,

		showCommands = function()
			vim.fn.VSCodeNotify("workbench.action.showCommands")
		end,

		toggleSidebarVisibility = function()
			vim.fn.VSCodeNotify("workbench.action.toggleSidebarVisibility")
		end,

		toggleCenteredLayout = function()
			vim.fn.VSCodeNotify("workbench.action.toggleCenteredLayout")
		end,

		navigateLeft = function()
			vim.fn.VSCodeNotify("workbench.action.navigateLeft")
		end,

		navigateRight = function()
			vim.fn.VSCodeNotify("workbench.action.navigateRight")
		end,

		navigateAbove = function()
			vim.fn.VSCodeNotify("workbench.action.navigateUp")
		end,

		navigateBelow = function()
			vim.fn.VSCodeNotify("workbench.action.navigateDown")
		end,

		moveEditorLeftInGroup = function()
			vim.fn.VSCodeNotify("workbench.action.moveEditorLeftInGroup")
		end,

		moveEditorRightInGroup = function()
			vim.fn.VSCodeNotify("workbench.action.moveEditorRightInGroup")
		end,

		gotoTab = function(index)
			vim.fn.VSCodeNotify("workbench.action.openEditorAtIndex" .. index)
		end,

		navigateForwardInEditLocations = function()
			vim.fn.VSCodeNotify("workbench.action.navigateForwardInEditLocations")
		end,

		navigatePreviousInEditLocations = function()
			vim.fn.VSCodeNotify("workbench.action.navigatePreviousInEditLocations")
		end,
	}

	local view = {
		explorer = function()
			vim.fn.VSCodeNotify("workbench.view.explorer")
		end,
	}

	local markdown = {
		preview = function()
			vim.fn.VSCodeNotify("markdown.showPreview")
		end,

		showPreviewToSide = function()
			vim.fn.VSCodeNotify("markdown.showPreviewToSide")
		end,
	}

	vim.g.mapleader = " "
	vim.keymap.set({ "n", "x" }, "gc", comment.selected)

	vim.keymap.set({ "n", "x" }, "<leader>w", file.save)
	vim.keymap.set({ "n", "x" }, "<leader>q", file.close)
	vim.keymap.set({ "n", "x" }, "<leader>ea", file.showInExplorer)

	vim.keymap.set({ "n", "x" }, "<leader>ff", action.quickOpen)
	vim.keymap.set({ "n", "x" }, "<leader>fc", action.showCommands)
	vim.keymap.set({ "n", "x" }, "<leader>eq", action.toggleSidebarVisibility)
	vim.keymap.set({ "n", "x" }, "<leader>nn", action.toggleCenteredLayout)
	vim.keymap.set({ "n", "x" }, "<C-h>", action.navigateLeft)
	vim.keymap.set({ "n", "x" }, "<C-j>", action.navigateBelow)
	vim.keymap.set({ "n", "x" }, "<C-k>", action.navigateAbove)
	vim.keymap.set({ "n", "x" }, "<C-l>", action.navigateRight)

	vim.keymap.set({ "n", "x" }, "<leader>ee", view.explorer)

	vim.keymap.set({ "n", "x" }, "<right>", action.moveEditorRightInGroup)
	vim.keymap.set({ "n", "x" }, "<left>", action.moveEditorLeftInGroup)
	vim.keymap.set({ "n", "x" }, "<up>", [[:norm gt<CR>]])
	vim.keymap.set({ "n", "x" }, "<down>", [[:norm gT<CR>]])

	vim.keymap.set({ "n", "x" }, "<leader>mm", markdown.preview)
	vim.keymap.set({ "n", "x" }, "<leader>mv", markdown.showPreviewToSide)

	vim.keymap.set({ "n", "x" }, "<leader>o", action.navigatePreviousInEditLocations)
	vim.keymap.set({ "n", "x" }, "<leader>i", action.navigateForwardInEditLocations)
	vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<;-r><C-w>]])

	for i = 1, 9 do
		vim.keymap.set({ "n", "v" }, "<leader>" .. i, function()
			action.gotoTab(i)
		end)
	end
else
	-- ordinary Neovim
	vim.keymap.set("n", "<LeftDrag>", "<Nop>")
	vim.keymap.set("n", "<LeftRelease>", "<Nop>")
	vim.keymap.set({ "n", "v", "i" }, "<RightMouse>", "<Nop>")
	vim.keymap.set("n", "<MiddleMouse>", "<Nop>")

	vim.keymap.set("n", "<leader>w", vim.cmd.w, { desc = "Save current buffer" })
	vim.keymap.set("n", "<leader><C-q>", [[:tabclose<CR>]], { silent = true, desc = "Close current tab" })
	vim.keymap.set("n", "<C-h>", "<C-w>h")
	vim.keymap.set("n", "<C-j>", "<C-w>j")
	vim.keymap.set("n", "<C-k>", "<C-w>k")
	vim.keymap.set("n", "<C-l>", "<C-w>l")
	vim.keymap.set("n", "-", "<C-w><")
	vim.keymap.set("n", "+", "<C-w>>")
	vim.keymap.set("n", "<M-->", "<C-w>-")
	vim.keymap.set("n", "<M-+>", "<C-w>+")
	vim.keymap.set("n", "<C-d>", "<C-d>zz")
	vim.keymap.set("n", "<C-u>", "<C-u>zz")
	vim.keymap.set("n", "n", "nzzzv")
	vim.keymap.set("n", "N", "Nzzzv")
	vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>")
	vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
	vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
	vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
	vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
	vim.keymap.set(
		"n",
		"<leader>jss",
		[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
		{ desc = "Replace word under cursor" }
	)
	vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
	vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
	vim.keymap.set("n", "<C-w>t", [[:tabe %<CR>]], { silent = true, desc = "Open current buffer in a new tab" })
	vim.keymap.set("n", "<leader>c", "<C-w>c", { desc = "Close window" })

	local swap_buffers = function(direction)
		local prev_window = vim.api.nvim_get_current_win()
		local prev_buffer = vim.api.nvim_get_current_buf()
		local pos = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>" .. direction, true, false, true), "n", true)
		vim.schedule(function()
			local next_buffer = vim.api.nvim_get_current_buf()
			vim.api.nvim_set_current_buf(prev_buffer)
			vim.api.nvim_win_set_buf(prev_window, next_buffer)
			vim.api.nvim_win_set_cursor(0, pos)
		end)
	end

	vim.keymap.set("n", "<M-h>", function()
		swap_buffers("h")
	end)
	vim.keymap.set("n", "<M-j>", function()
		swap_buffers("j")
	end)
	vim.keymap.set("n", "<M-k>", function()
		swap_buffers("k")
	end)
	vim.keymap.set("n", "<M-l>", function()
		swap_buffers("l")
	end)

	vim.keymap.set("n", "<leader>jeu", [[:e ++ff=unix<CR>]], { desc = "Set unix line endings" })
	vim.keymap.set("n", "<leader>jed", [[:e ++ff=dos<CR>]], { desc = "Set dos line endings" })

	vim.api.nvim_create_user_command("Redir", [[:redir @" | silent <args> | redir END | enew | put"]], { nargs = 1 })

	if vim.g.neovide then
		vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { desc = "Copy to clipboard" })
		-- vim.keymap.set({ "n", "v" }, "<C-x>", '"+x', { desc = "Cut to clipboard" })
		vim.keymap.set({ "n", "v" }, "<C-v>", '"+gP', { desc = "Paste from clipboard" })
		vim.keymap.set({ "i", "t" }, "<C-v>", '<esc>"+gp', { desc = "Paste from clipboard" })
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "markdown", "typst" },
		callback = function(event)
			vim.keymap.set({ "n", "v" }, "j", "gj", { buffer = event.buf })
			vim.keymap.set({ "n", "v" }, "k", "gk", { buffer = event.buf })
		end,
	})

	-- Plugins
	vim.api.nvim_create_user_command("SnacksNotifierHistory", require("snacks").notifier.show_history, { nargs = 0 })
end
