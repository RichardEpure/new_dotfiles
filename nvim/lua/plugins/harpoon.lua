local is_neovim = require("config.utils").is_neovim

return {
	"ThePrimeagen/harpoon",
	enabled = is_neovim,
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon.setup({})

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():append()
		end, { desc = "Add to Harpoon list" })
		vim.keymap.set("n", "<leader>sf", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Toggle Harpoon list" })

		vim.keymap.set("n", "<leader>sh", function()
			harpoon:list():select(1)
		end, { desc = "Select Harpoon list 1" })
		vim.keymap.set("n", "<leader>sj", function()
			harpoon:list():select(2)
		end, { desc = "Select Harpoon list 2" })
		vim.keymap.set("n", "<leader>sk", function()
			harpoon:list():select(3)
		end, { desc = "Select Harpoon list 3" })
		vim.keymap.set("n", "<leader>sl", function()
			harpoon:list():select(4)
		end, { desc = "Select Harpoon list 4" })
		vim.keymap.set("n", "<leader>s;", function()
			harpoon:list():select(5)
		end, { desc = "Select Harpoon list 5" })
		vim.keymap.set("n", "<leader>s'", function()
			harpoon:list():select(6)
		end, { desc = "Select Harpoon list 6" })

		vim.keymap.set("n", "<leader>sp", function()
			harpoon:list():prev()
		end, { desc = "Select previous in Harpoon list" })
		vim.keymap.set("n", "<leader>sn", function()
			harpoon:list():next()
		end, { desc = "Select next in Harpoon list" })
	end,
}
