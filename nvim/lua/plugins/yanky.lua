return {
	"gbprod/yanky.nvim",
	dependencies = { { "kkharji/sqlite.lua", enabled = not jit.os:find("Windows") } },
	keys = {
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
		{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
		{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
		{ "<C-p>", "<Plug>(YankyPreviousEntry)" },
		{ "<C-n>", "<Plug>(YankyNextEntry)" },
	},
	opts = {
		highlight = {
			on_put = false,
			on_yank = false,
		},
		ring = { storage = jit.os:find("Windows") and "shada" or "sqlite" },
	},
}
