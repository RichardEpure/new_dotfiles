local is_neovim = require("config.utils").is_neovim

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		name = "render-markdown",
		cmd = { "RenderMarkdownToggle" },
		ft = { "markdown" },
		enabled = is_neovim,
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
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
