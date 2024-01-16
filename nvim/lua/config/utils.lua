local M = {}

M.home = vim.fn.has("linux") == 1 and os.getenv("HOME") or os.getenv("USERPROFILE")

M.is_neovim = function()
	return vim.g.vscode == nil
end

M.read_exrc_file = function()
	local result = vim.secure.read(".nvim.lua")
	if result ~= nil then
		local should_source = vim.fn.confirm("Source .nvim.lua?", "&Yes\n&No") == 1
		if should_source then
			vim.cmd("source .nvim.lua")
		end
	end
end

return M
