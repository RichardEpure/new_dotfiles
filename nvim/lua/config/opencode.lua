local M = {}
local utils = require("config.utils")

---@class OpencodeInsertOpts
---@field strategy? "cursor"|"replace_until_comment"
---@field replace_until_comment? OpencodeReplaceUntilCommentOpts
---@field row? integer
---@field win? integer

---@class OpencodeReplaceUntilCommentOpts
---@field confirm_replace? string|false
---@field confirm_replace_changed? string|false

---@class OpencodeResult
---@field errors string[]
---@field session_id? string
---@field text_parts string[]

---@class OpencodeGenerateOpts
---@field bufnr? integer
---@field cwd? string
---@field title? string
---@field timeout? integer
---@field insert? false|OpencodeInsertOpts
---@field on_start? fun()
---@field on_success? fun(text: string, result: OpencodeResult)
---@field on_error? fun(message: string, result?: vim.SystemCompleted)
---@field on_exit? fun(result: vim.SystemCompleted, parsed: OpencodeResult)
---@field before_insert? fun(text: string): boolean?

---@class OpencodeJob
---@field autocmd? integer
---@field cwd string
---@field opts OpencodeGenerateOpts
---@field proc? vim.SystemObj
---@field session_id? string
---@field session_title string

---@class OpencodeSession
---@field id? string
---@field title? string

---@type table<integer, OpencodeJob>
local active_jobs = {}
local augroup = vim.api.nvim_create_augroup("opencode_commands", { clear = true })

local default_timeout_ms = 120000

---@param message string
---@param level? integer
local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "OpenCode" })
end

---@param session_id? string
---@param cwd string
---@param opts OpencodeGenerateOpts
local function delete_session(session_id, cwd, opts)
	if not session_id then
		return
	end

	vim.system(
		{ "opencode", "session", "delete", session_id },
		{ cwd = cwd, text = true },
		vim.schedule_wrap(function(result)
			if result.code == 0 then
				return
			end

			notify(utils.error_with_fallback(result, "Failed to delete OpenCode session"), vim.log.levels.WARN)
		end)
	)
end

---@param title? string
---@param cwd string
---@param opts OpencodeGenerateOpts
local function delete_session_by_title(title, cwd, opts)
	if not title then
		return
	end

	vim.system(
		{ "opencode", "session", "list", "--format", "json", "--max-count", "50" },
		{ cwd = cwd, text = true },
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				notify(utils.error_with_fallback(result, "Failed to list OpenCode sessions"), vim.log.levels.WARN)
				return
			end

			local ok, sessions = pcall(vim.json.decode, result.stdout or "[]")
			if not ok or type(sessions) ~= "table" then
				return
			end

			for _, session in ipairs(sessions) do
				---@cast session OpencodeSession
				if type(session) == "table" and session.title == title and type(session.id) == "string" then
					delete_session(session.id, cwd, opts)
				end
			end
		end)
	)
end

---@param bufnr integer
---@param kill boolean
---@param delete_session_data boolean
local function cleanup_job(bufnr, kill, delete_session_data)
	local job = active_jobs[bufnr]
	if not job then
		return
	end

	if job.autocmd then
		pcall(vim.api.nvim_del_autocmd, job.autocmd)
	end

	if kill and job.proc then
		pcall(function()
			job.proc:kill(15)
		end)
	end

	if delete_session_data then
		if job.session_id then
			delete_session(job.session_id, job.cwd, job.opts)
		else
			delete_session_by_title(job.session_title, job.cwd, job.opts)
		end
	end

	active_jobs[bufnr] = nil
end

---@param text string
---@return string
local function strip_ansi(text)
	return (text:gsub("\27%[[0-?]*[ -/]*[@-~]", ""))
end

---@param text? string
---@return string
local function clean_output(text)
	text = strip_ansi(text or "")
	text = text:gsub("^%s*```[%w_-]*%s*\n", "")
	text = text:gsub("\n```%s*$", "")
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	return text
end

---@param output? string
---@return OpencodeResult
local function parse_output(output)
	local ret = {
		errors = {},
		session_id = nil,
		text_parts = {},
	}

	for line in (output or ""):gmatch("[^\r\n]+") do
		local ok, event = pcall(vim.json.decode, line)
		if not ok or type(event) ~= "table" then
			table.insert(ret.errors, line)
		else
			if type(event.sessionID) == "string" then
				ret.session_id = event.sessionID
			end

			if event.type == "text" and type(event.part) == "table" and type(event.part.text) == "string" then
				table.insert(ret.text_parts, event.part.text)
			elseif event.type == "error" then
				table.insert(ret.errors, vim.inspect(event.error or event))
			end
		end
	end

	return ret
end

---@param text string
---@return string[]
local function output_lines(text)
	local lines = vim.split(clean_output(text), "\n", { plain = true })
	while #lines > 0 and lines[#lines]:match("^%s*$") do
		table.remove(lines)
	end
	return lines
end

---@param lines string[]
---@return integer
local function first_comment_line(lines)
	for index, line in ipairs(lines) do
		if line:match("^#") then
			return index - 1
		end
	end

	return #lines
end

---@param bufnr integer
---@return boolean
local function has_content_before_comment(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for index = 1, first_comment_line(lines) do
		if lines[index]:match("%S") then
			return true
		end
	end

	return false
end

---@param insert? false|OpencodeInsertOpts
---@return OpencodeInsertOpts?
local function replace_until_comment_insert(insert)
	if insert ~= false and insert and insert.strategy == "replace_until_comment" then
		return insert
	end
end

---@param message string
---@return boolean
local function confirm_replace(message)
	return vim.fn.confirm(message, "&Yes\n&No", 2) == 1
end

---@param insert OpencodeInsertOpts
---@return OpencodeReplaceUntilCommentOpts
local function replace_until_comment_opts(insert)
	return insert.replace_until_comment or {}
end

---@param bufnr integer
---@return integer?
local function find_window(bufnr)
	local current_win = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_buf(current_win) == bufnr then
		return current_win
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return win
		end
	end
end

---@param bufnr integer
---@param text string
---@param insert? OpencodeInsertOpts
---@return string? error
local function insert_output(bufnr, text, insert)
	insert = insert or {}
	local strategy = insert.strategy or "cursor"
	local lines = output_lines(text)

	if #lines == 0 then
		return "OpenCode returned empty output"
	end

	if strategy == "replace_until_comment" then
		local existing = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local replacement = vim.list_extend({}, lines)
		table.insert(replacement, "")
		vim.api.nvim_buf_set_lines(bufnr, 0, first_comment_line(existing), false, replacement)
		return
	end

	local row = insert.row
	if not row then
		local win = insert.win or find_window(bufnr)
		row = win and (vim.api.nvim_win_get_cursor(win)[1] - 1) or vim.api.nvim_buf_line_count(bufnr)
	end

	vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
end

---@param prompt string
---@param opts? OpencodeGenerateOpts
---@return boolean started
function M.generate(prompt, opts)
	opts = opts or {}
	local bufnr = opts.bufnr == 0 and vim.api.nvim_get_current_buf() or opts.bufnr or vim.api.nvim_get_current_buf()
	local cwd = opts.cwd or vim.fn.getcwd()
	local title = opts.title or "OpenCode"
	local session_title = title .. " " .. bufnr .. "-" .. vim.uv.hrtime()

	if active_jobs[bufnr] then
		notify("OpenCode is already generating output", vim.log.levels.WARN)
		return false
	end

	if vim.fn.executable("opencode") ~= 1 then
		notify("opencode executable not found", vim.log.levels.ERROR)
		return false
	end

	local replace_insert = replace_until_comment_insert(opts.insert)
	local replace_opts = replace_insert and replace_until_comment_opts(replace_insert)
	local had_content_before_comment = replace_insert and has_content_before_comment(bufnr)
	if had_content_before_comment and replace_opts.confirm_replace ~= false then
		local message = replace_opts.confirm_replace or "Replace existing content?"
		if not confirm_replace(message) then
			return false
		end
	end

	local job = {
		cwd = cwd,
		opts = opts,
		session_title = session_title,
	}
	active_jobs[bufnr] = job

	job.autocmd = vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = augroup,
		buffer = bufnr,
		desc = "Stop OpenCode generation",
		once = true,
		callback = function()
			cleanup_job(bufnr, true, true)
		end,
	})

	if opts.on_start then
		opts.on_start()
	else
		notify("Generating output with OpenCode...")
	end

	local ok, proc = pcall(
		vim.system,
		{ "opencode", "run", "--format", "json", "--title", session_title, prompt },
		{
			cwd = cwd,
			text = true,
			timeout = opts.timeout or default_timeout_ms,
		},
		vim.schedule_wrap(function(result)
			if active_jobs[bufnr] ~= job then
				return
			end

			local parsed = parse_output(result.stdout)
			job.session_id = parsed.session_id

			cleanup_job(bufnr, false, false)
			if parsed.session_id then
				delete_session(parsed.session_id, cwd, opts)
			else
				delete_session_by_title(session_title, cwd, opts)
			end

			if opts.on_exit then
				opts.on_exit(result, parsed)
			end

			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			if result.code ~= 0 then
				local message
				if result.code == 124 then
					message = "OpenCode generation timed out"
				else
					local stderr = result.stderr or ""
					local errors = table.concat(parsed.errors, "\n")
					message = stderr ~= "" and stderr or errors ~= "" and errors or "OpenCode failed to generate output"
				end

				if opts.on_error then
					opts.on_error(message, result)
				else
					notify(message, result.code == 124 and vim.log.levels.WARN or vim.log.levels.ERROR)
				end
				return
			end

			local text = clean_output(table.concat(parsed.text_parts, "\n"))
			if text == "" then
				local message = "OpenCode returned empty output"
				if opts.on_error then
					opts.on_error(message, result)
				else
					notify(message, vim.log.levels.WARN)
				end
				return
			end

			if opts.before_insert and opts.before_insert(text) == false then
				return
			end

			if
				replace_insert
				and not had_content_before_comment
				and has_content_before_comment(bufnr)
				and replace_opts.confirm_replace_changed ~= false
			then
				local message = replace_opts.confirm_replace_changed
					or "Content changed while OpenCode was running. Replace it?"
				if not confirm_replace(message) then
					return
				end
			end

			if opts.insert ~= false then
				local err = insert_output(bufnr, text, opts.insert)
				if err then
					if opts.on_error then
						opts.on_error(err, result)
					else
						notify(err, vim.log.levels.WARN)
					end
					return
				end
			end

			if opts.on_success then
				opts.on_success(text, parsed)
			elseif opts.insert ~= false then
				notify("Inserted OpenCode output")
			else
				notify("Generated output with OpenCode")
			end
		end)
	)

	if not ok then
		cleanup_job(bufnr, false, false)
		notify(tostring(proc), vim.log.levels.ERROR)
		return false
	end

	job.proc = proc
	return true
end

---@param bufnr? integer
function M.cancel(bufnr)
	bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr or vim.api.nvim_get_current_buf()
	cleanup_job(bufnr, true, true)
end

return M
