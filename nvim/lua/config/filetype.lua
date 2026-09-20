vim.filetype.add({
	extension = {
		jinja = "jinja",
		jinja2 = "jinja",
		j2 = "jinja",
	},
})

local wrapping_filetypes = {
	markdown = true,
	typst = true,
}

-- Wrapping is window-local, so reapply it when a window displays another buffer.
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
	group = vim.api.nvim_create_augroup("filetype_wrapping", { clear = true }),
	desc = "Wrap only prose filetypes",
	callback = function()
		local wrap = wrapping_filetypes[vim.bo.filetype] == true
		vim.wo.wrap = wrap
		vim.wo.linebreak = wrap
	end,
})
