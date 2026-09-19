local M = {}
local windows = vim.fn.has("win32") == 1

local function quote(path)
	if not path:find("[^%w_./~:\\-]") then
		return path
	end
	if vim.startswith(path, "~/") then
		path = vim.fn.expand("~") .. path:sub(2)
	end
	return windows and ("'" .. path:gsub("'", "''") .. "'") or vim.fn.shellescape(path)
end

---@param lead string
---@param line? string
---@param cursor? integer
---@return string[]
function M.complete(lead, line, cursor)
	local base, directories = vim.fn.getcwd(), false
	local text = line and line:sub(1, cursor):match("^%s*MuxTask%s+(.*)")
	if text then
		if text:match("^%s*%-%-cwd$") then
			return {}
		end
		local tasks = require("config.mux_tasks")
		local ok, command, cwd, directory_end = pcall(tasks.parse, text, true)
		if not ok then
			return {}
		end
		if cwd then
			local root = require("config.mux").project()
			if command == nil then
				if directory_end and directory_end < #text then
					return {}
				end
				base, lead, directories = root, cwd, true
			else
				local _, resolved = tasks.context({ root = root, cwd = cwd })
				base = resolved
			end
		end
	end
	if vim.fn.isdirectory(base) == 0 then
		return {}
	end
	if not directories then
		lead = lead:gsub("^['\"]", ""):gsub("['\"]$", "")
	end
	if windows then
		lead = lead:gsub("\\", "/")
	end
	local explicit = lead:find("[/\\]") or lead:match("^[~.]") or lead:match("^%a:")
	local absolute = vim.fn.isabsolutepath(lead) == 1 or lead:match("^~")
	local prefix = vim.fs.normalize(base):gsub("/+$", "") .. "/"
	local query = explicit and lead or ""
	local paths = vim.fn.getcompletion(absolute and query or prefix .. query, directories and "dir" or "file")
	for i, path in ipairs(paths) do
		if windows then
			path = path:gsub("\\", "/")
		end
		paths[i] = absolute and path or path:sub(#prefix + 1)
	end
	if not directories and not explicit and vim.fn.executable("git") == 1 then
		local result = vim.system({
			"git",
			"ls-files",
			"--cached",
			"--others",
			"--exclude-standard",
			"--deduplicate",
			"-z",
			"--",
			":/",
		}, { cwd = base }):wait(1000)
		if result.code == 0 then
			vim.list_extend(paths, vim.split(result.stdout, "\0", { plain = true, trimempty = true }))
		end
	end
	local candidates, seen = {}, {}
	for _, path in ipairs(paths) do
		if windows then
			path = path:gsub("\\", "/")
		end
		if not explicit and not vim.startswith(path, "../") then
			path = "./" .. path
		end
		if not seen[path] and not path:find("[%c]") then
			seen[path] = true
			candidates[#candidates + 1] = path
		end
	end
	if not explicit and lead ~= "" then
		candidates = vim.fn.matchfuzzy(candidates, lead)
	end
	return vim.tbl_map(quote, candidates)
end

---Find the shell argument at the cursor, keeping quoted spaces inside it.
local function argument(line, cursor)
	local start, stop, quoted, escaped = 1, #line, nil, false
	for i = 1, #line do
		local char = line:sub(i, i)
		if escaped then
			escaped = false
		elseif char == (windows and "`" or "\\") and quoted ~= "'" then
			escaped = true
		elseif quoted then
			if char == quoted then
				quoted = nil
			end
		elseif char == "'" or char == '"' then
			quoted = char
		elseif char:match("%s") then
			if i > cursor then
				stop = i - 1
				break
			end
			start = i + 1
		end
	end
	return start - 1, stop, line:sub(start, cursor)
end

---Blink's generic custom-command source prepends keyword prefixes to results.
---MuxTask instead replaces the entire shell argument with the completed path.
function M.get_completions(context, callback)
	local start, stop, lead = argument(context.line, context.cursor[2])
	local items = {}
	for _, path in ipairs(M.complete(lead, context.line, context.cursor[2])) do
		items[#items + 1] = {
			label = path,
			kind = 17, -- CompletionItemKind.File
			textEdit = {
				newText = path,
				range = {
					start = { line = context.cursor[1] - 1, character = start },
					["end"] = { line = context.cursor[1] - 1, character = stop },
				},
			},
		}
	end
	callback({ items = items, is_incomplete_forward = true, is_incomplete_backward = true })
end

return M
