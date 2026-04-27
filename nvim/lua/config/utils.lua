local M = {}

M.home = vim.fn.has("linux") == 1 and os.getenv("HOME") or os.getenv("USERPROFILE")

M.is_neovim = function()
	return vim.g.vscode == nil
end

M.read_exrc_file = function()
	local result = vim.secure.read(".nvim.lua")
	if result ~= nil then
		vim.cmd("source .nvim.lua")
	end
end

---@param result vim.SystemCompleted
---@param fallback string
---@return string
M.error_with_fallback = function(result, fallback)
	local stderr = result.stderr or ""
	return stderr ~= "" and stderr or fallback
end

return M
