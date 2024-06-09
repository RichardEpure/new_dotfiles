local is_neovim = require("config.utils").is_neovim

return {
	"MeanderingProgrammer/markdown.nvim",
	name = "render-markdown",
	ft = { "markdown" },
	cmd = { "RenderMarkdownToggle" },
	enabled = is_neovim,
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("render-markdown").setup({})
	end,
}
