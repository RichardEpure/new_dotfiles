local is_neovim = require("config.utils").is_neovim

return {
	"chomosuke/typst-preview.nvim",
	enabled = is_neovim,
	ft = "typst",
	version = "0.3.*",
	build = function()
		require("typst-preview").update()
	end,
}
