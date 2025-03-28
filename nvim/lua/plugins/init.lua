local is_neovim = require("config.utils").is_neovim

return {
	-- shared
	"tpope/vim-repeat",
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
	},

	-- neovim
	{ "tpope/vim-rhubarb", enabled = is_neovim },
	{
		"sainnhe/gruvbox-material",
		enabled = is_neovim,
		opts = true,
		config = function()
			vim.g.gruvbox_material_background = "hard"
			vim.g.gruvbox_material_foreground = "material"
			vim.g.gruvbox_material_transparent_background = 0
		end,
	},
	{
		"rose-pine/neovim",
		enabled = is_neovim,
		name = "rose-pine",
		opts = {
			styles = {
				italic = false,
				transparency = false,
			},
		},
	},
	{
		"numToStr/Comment.nvim",
		enabled = is_neovim,
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},
	{ "nvim-tree/nvim-web-devicons", enabled = is_neovim },
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		enabled = is_neovim,
		config = function()
			require("todo-comments").setup()
		end,
	},
	{ "kevinhwang91/nvim-bqf", ft = "qf", enabled = is_neovim },
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
		enabled = is_neovim,
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
	{ "folke/twilight.nvim", opts = true, enabled = is_neovim },
	{
		"folke/zen-mode.nvim",
		keys = {
			{ "<Leader>z", [[:ZenMode<CR>]], desc = "Toggle zen-mode", silent = true },
		},
		opts = {
			window = {
				backdrop = 1,
			},
			plugins = {
				twilight = { enabled = false },
				gitsigns = { enabled = true },
			},
		},
		enabled = is_neovim,
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		enabled = is_neovim,
		config = function()
			require("ts_context_commentstring").setup({})
			vim.g.skip_ts_context_commentstring_module = true
		end,
	},
}
