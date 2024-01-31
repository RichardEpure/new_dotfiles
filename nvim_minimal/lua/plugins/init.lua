return {
	"tpope/vim-repeat",
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
	},
	{
		"sainnhe/gruvbox-material",
		opts = true,
		config = function()
			vim.g.gruvbox_material_background = "hard"
			vim.g.gruvbox_material_foreground = "material"
			vim.g.gruvbox_material_transparent_background = 0
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			styles = {
				italic = false,
				transparency = false,
			},
		},
        config = function()
            vim.cmd.colorscheme("rose-pine")
        end
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"numToStr/Comment.nvim",
        opts = true,
	},
	{
		"kazhala/close-buffers.nvim",
		config = function()
			require("close_buffers").setup()
			vim.keymap.set("n", "<leader>q", [[:BDelete this<CR>]], { silent = true, desc = "Close buffer" })
			vim.keymap.set("n", "<leader>Q", [[:BDelete! this<CR>]], { silent = true, desc = "Force close buffer" })
			vim.keymap.set("n", "<leader>C", "<CMD>BDelete this<CR><C-w>c", { desc = "Close window & buffer" })
			vim.keymap.set(
				"n",
				"<leader><C-c>",
				"<CMD>BDelete! this<CR><C-w>c",
				{ desc = "Force close window & buffer" }
			)
		end,
	},
	{
		"echasnovski/mini.splitjoin",
		version = "*",
		opts = true,
	},
	{
		"echasnovski/mini.ai",
		version = false,
		opts = {
			mappings = {
				goto_left = "gp",
				goto_right = "gn",
			},
		},
	},
}
