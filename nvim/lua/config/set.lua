local home = require("config.utils").home

vim.opt.hlsearch = false

if vim.g.vscode == nil then
	vim.o.exrc = true

	vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

	vim.o.foldcolumn = "1"
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.foldenable = true

	vim.opt.termguicolors = true
	vim.opt.nu = true
	vim.opt.relativenumber = true
	vim.opt.cursorline = false

	vim.opt.tabstop = 4
	vim.opt.softtabstop = 4
	vim.opt.shiftwidth = 4
	vim.opt.expandtab = true

	vim.opt.smartindent = true

	vim.opt.wrap = false

	vim.opt.swapfile = false
	vim.opt.backup = false
	vim.opt.undodir = home .. "/.vim.undodir"

	vim.opt.undofile = true

	vim.opt.incsearch = true

	vim.opt.termguicolors = true

	vim.opt.scrolloff = 10
	vim.opt.signcolumn = "yes"
	vim.opt.isfname:append("@-@")

	vim.opt.updatetime = 50

	if vim.fn.has("wsl") == 1 then
		vim.g.clipboard = {
			name = "WslClipboard",
			copy = {
				["+"] = "clip.exe",
				["*"] = "clip.exe",
			},
			paste = {
				["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
				["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
			},
			cache_enabled = 0,
		}
	end
end
