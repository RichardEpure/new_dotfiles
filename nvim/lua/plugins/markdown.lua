local is_neovim = require("config.utils").is_neovim

return {
	{
		"MeanderingProgrammer/markdown.nvim",
		name = "render-markdown",
		cmd = { "RenderMarkdownToggle" },
		ft = { "markdown" },
		enabled = is_neovim,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("render-markdown").setup({})
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		opts = {},
	},
}
