local M = {}
local mux = require("config.mux")
local uv = vim.uv
local windows = vim.fn.has("win32") == 1
local directory = vim.fn.stdpath("state") .. "/mux-tasks"

---@alias MuxTaskStatus 'running'|'succeeded'|'failed'|'terminated'|'unknown'|'unavailable'
---@class MuxTask
---@field id string
---@field root string Canonical repository identity
---@field cwd string
---@field command string
---@field started number Unix timestamp
---@field finished? number Exit timestamp, or discovery time when the backend lacks it
---@field observed? number High-resolution discovery time, breaking equal exit timestamps
---@field status MuxTaskStatus
---@field code? number
---@field signal? string
---@field detail? string
---@field session string
---@field pane string Full mux pane target
---@field marker string Session option identifying this particular run
---@field holder_pid string Detect a launch interrupted before respawn
---@field pid? string Unix task process; psmux may omit this after respawn
---@field cleaned boolean Output saved and pane removed (or pane already missing)
---@field cleanup_verified? boolean Older records marked cleanup complete without checking mux

---@type table<string, boolean>
local pending, busy = {}, {}
---@type table<string, string>
local errors = {}
---@type uv.uv_timer_t?
local timer
---@type string?
local owner

---@return number
local function now()
	local seconds, micros = uv.gettimeofday()
	return seconds + micros / 1000000
end

---A unique local Neovim endpoint identifies this lifetime, unlike reusable PIDs.
---@return string
local function identity()
	if not owner then
		local address = vim.fn.tempname()
		if windows then
			address = "\\\\.\\pipe\\nvim-mux-" .. vim.fn.sha256(address .. tostring(uv.hrtime()))
		end
		owner = vim.fn.serverstart(address)
	end
	return owner
end

---@param address string
---@return integer? channel Nil only when the endpoint is definitely gone
local function connect(address)
	local ok, channel = pcall(vim.fn.sockconnect, "pipe", address, { rpc = true })
	if ok and channel > 0 then
		return channel
	end
	local err = tostring(channel):lower()
	if not err:find("connection refused", 1, true) and not err:find("no such file", 1, true) then
		error(channel, 0)
	end
end

---@param address string
---@return boolean
local function alive(address)
	if address == owner then
		return true
	end
	local channel = connect(address)
	if channel then
		vim.fn.chanclose(channel)
		return true
	end
	return false
end

---@param message string
---@param level? integer
local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Mux task" })
end

---@param id string
---@param extension string
---@return string
local function path(id, extension)
	assert(id:match("^%x+$"), "Invalid task ID")
	return directory .. "/" .. id .. extension
end

---Replace a file only after the complete new contents have been flushed.
---@param filename string
---@param contents string
local function write(filename, contents)
	local temporary = filename .. "." .. uv.os_getpid() .. ".tmp"
	local fd = assert(uv.fs_open(temporary, "w", 384))
	local ok, err = pcall(function()
		assert(uv.fs_write(fd, contents, 0) == #contents, "Incomplete write: " .. filename)
		assert(uv.fs_fsync(fd))
	end)
	uv.fs_close(fd)
	if ok then
		local renamed
		renamed, err = uv.fs_rename(temporary, filename)
		ok = renamed == true
	end
	if not ok then
		uv.fs_unlink(temporary)
		error(err, 0)
	end
end

---@param task MuxTask
local function save(task)
	write(path(task.id, ".json"), vim.json.encode(task))
end

---@param id string
---@return MuxTask
local function load(id)
	local task = vim.json.decode(table.concat(vim.fn.readfile(path(id, ".json")), "\n"))
	assert(type(task) == "table" and task.id == id, "Invalid task record: " .. id)
	for _, field in ipairs({ "root", "cwd", "command", "session", "pane", "marker", "holder_pid", "status" }) do
		assert(type(task[field]) == "string", "Invalid task field: " .. field)
	end
	assert(type(task.started) == "number" and type(task.cleaned) == "boolean", "Invalid task record: " .. id)
	assert(task.finished == nil or type(task.finished) == "number", "Invalid task completion time")
	assert(task.pane:match("^%$%d+:@%d+%.%%%d+$"), "Invalid task pane")
	assert(task.marker:match("^@dotfiles%-task%-%d+$"), "Invalid task marker")
	return task
end

---Claim one task/project across Neovim instances. Hard-link a fully written owner file,
---so a crash cannot leave a lock with no owner. Dead owners keep their slot;
---contenders advance together rather than racing to unlink a replacement lock.
---@param id string
---@return function? release
local function claim(id)
	local candidate = path(id, ".owner-" .. uv.os_getpid())
	write(candidate, identity())
	local slot = 0
	while true do
		local lock = path(id, ".lock-" .. slot)
		local linked, err, code = uv.fs_link(candidate, lock)
		if linked then
			uv.fs_unlink(candidate)
			return function()
				uv.fs_unlink(lock)
			end
		end
		if code ~= "EEXIST" then
			uv.fs_unlink(candidate)
			error(err, 0)
		end
		local ok, lines = pcall(vim.fn.readfile, lock)
		if ok then
			if not lines[1] or alive(lines[1]) then
				uv.fs_unlink(candidate)
				return
			end
			slot = slot + 1
		else
			local _, _, reason = uv.fs_stat(lock)
			if reason ~= "ENOENT" then
				uv.fs_unlink(candidate)
				error(lines, 0)
			end
		end
	end
end

---@async
---@param args string[]
---@param allow_missing? boolean
---@return string? output Nil means the addressed mux object no longer exists
local function request(args, allow_missing)
	local thread = assert(coroutine.running())
	vim.system(mux.argv(args), { text = true, timeout = 10000 }, function(result)
		vim.schedule(function()
			local ok, err = coroutine.resume(thread, result)
			if not ok then
				notify(tostring(err), vim.log.levels.ERROR)
			end
		end)
	end)
	---@type vim.SystemCompleted
	local result = coroutine.yield()
	if result.code ~= 0 then
		local message = vim.trim(result.stderr or "")
		if allow_missing and mux.is_missing(message) then
			return nil
		end
		error(message ~= "" and message or (args[1] .. " failed (" .. result.code .. ")"), 0)
	end
	return ((result.stdout or ""):gsub("\r\n", "\n"):gsub("\n+$", ""))
end

---@param task MuxTask
---@return string
local function label(task)
	if task.status == "unknown" then
		return "finished — result unknown"
	elseif task.status == "failed" then
		return "failed (exit " .. task.code .. ")"
	elseif task.status == "terminated" then
		return "terminated (signal " .. task.signal .. ")"
	end
	return task.status
end

---@param root string
---@return string
local function last_path(root)
	return directory .. "/last-" .. vim.fn.sha256(root)
end

---Remove the retained-pane footer and its blank screen rows, when present.
---@param lines string[]
---@return string[]
local function clean_output(lines)
	if lines[#lines] and lines[#lines]:find("Pane is dead (", 1, true) then
		lines[#lines] = nil
		while #lines > 0 and lines[#lines]:match("^%s*$") do
			lines[#lines] = nil
		end
	end
	return lines
end

---@param task MuxTask
local function open(task)
	local lines = {
		"Command: " .. task.command,
		"Directory: " .. task.cwd,
		"Result: " .. label(task),
		"Started: " .. os.date("%Y-%m-%d %H:%M:%S", task.started),
		"Finished: " .. os.date("%Y-%m-%d %H:%M:%S", task.finished),
		"",
	}
	if task.status == "unavailable" then
		lines[#lines + 1] = task.detail or "The task pane disappeared before its output could be saved."
	else
		vim.list_extend(lines, clean_output(vim.fn.readfile(path(task.id, ".log"))))
	end
	write(last_path(task.root), task.id)
	vim.cmd("botright new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.b.mux_task_root = task.root
	vim.b.mux_task_id = task.id
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.modifiable = false
	vim.bo.filetype = "log"
	mux.output_keymaps()
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close task output" })
	vim.cmd("normal! G")
end

---Called locally or by a peer before removing a pane that was being displayed.
---@param id string
---@param session string
function M.present(id, session)
	if mux.close_focused_view(session) then
		open(load(id))
	end
end

---@param task MuxTask
local function present_viewers(task)
	M.present(task.id, task.session)
	for name in vim.fs.dir(directory) do
		if name:match("^%x+%.viewer$") then
			local filename = directory .. "/" .. name
			local address = vim.fn.readfile(filename)[1]
			if address and address ~= owner then
				local channel = connect(address)
				if channel then
					vim.rpcnotify(
						channel,
						"nvim_exec_lua",
						[[require("config.mux_tasks").present(...)]],
						{ task.id, task.session }
					)
					-- Allow the queued notification to flush without waiting on another editor.
					vim.defer_fn(function()
						pcall(vim.fn.chanclose, channel)
					end, 1000)
				else
					uv.fs_unlink(filename)
				end
			end
		end
	end
end

---@class MuxTaskPane
---@field dead boolean
---@field code? number
---@field signal? string
---@field exited? number
---@field pid string
---@field active boolean
---@field single boolean
---@field last_window boolean

---@async
---@param task MuxTask
---@return MuxTaskPane?
local function inspect(task)
	local output = request({
		"display-message",
		"-p",
		"-t",
		task.pane,
		"#{"
			.. task.marker
			.. "}\t#{pane_dead}\t#{pane_dead_status}\t#{pane_dead_signal}"
			.. "\t#{pane_dead_time}\t#{pane_pid}\t#{window_active}\t#{pane_active}"
			.. "\t#{session_id}:#{window_id}.#{pane_id}\t#{window_panes}\t#{session_windows}",
	}, true)
	if not output then
		return nil
	end
	local row = vim.split(output, "\t", { plain = true })
	-- IDs can be reused after a mux server restarts. Never capture/kill by ID alone.
	-- tmux display-message can fall back to the active pane for a missing target.
	if row[1] ~= task.id or row[9] ~= task.pane or (task.pid and row[6] ~= task.pid) then
		return nil
	end
	return {
		dead = row[2] == "1",
		code = not windows and tonumber(row[3]) or nil,
		signal = not windows and row[4] ~= "" and row[4] ~= "0" and row[4] or nil,
		exited = not windows and tonumber(row[5]) or nil,
		pid = row[6],
		active = row[7] == "1" and row[8] == "1",
		single = row[10] == "1",
		last_window = row[11] == "1",
	}
end

---Serialize the final inspection/deletion with repository window creation.
---@async
---@param task MuxTask
---@return boolean removed
local function remove(task)
	local release = claim(vim.fn.sha256("project:" .. task.root))
	if not release then
		return false
	end
	local ok, removed = pcall(function()
		local row = inspect(task)
		if not row then
			return true
		end
		if not row.dead and row.pid ~= task.holder_pid then
			return false
		end
		if row.active then
			present_viewers(task)
		end
		if windows and row.single and row.last_window then
			-- psmux's kill-window leaves the final retained dead pane in place.
			request({ "kill-session", "-t", task.session }, true)
		elseif row.single then
			request({ "kill-window", "-t", assert(task.pane:match("^(.-)%.%%")) }, true)
		else
			request({ "kill-pane", "-t", task.pane }, true)
		end
		assert(not inspect(task), "Task pane still exists after cleanup: " .. task.pane)
		return true
	end)
	release()
	if not ok then
		error(removed, 0)
	end
	return removed
end

---@async
---@param task MuxTask
local function reconcile(task)
	if task.cleaned and task.cleanup_verified then
		return
	end
	local row = inspect(task)
	if task.cleaned then
		-- Recheck legacy claims once. Never remove a pane now running another command.
		if not row or not row.dead then
			task.cleanup_verified = true
			save(task)
			return
		end
		task.cleaned = false
		save(task)
	end
	local newly_finished = task.status == "running"
	if row and not windows and not task.pid and row.pid ~= task.holder_pid then
		task.pid = row.pid
		save(task)
	end
	if row and not row.dead and row.pid ~= task.holder_pid then
		return
	end
	if newly_finished then
		task.observed = now()
		task.finished = task.observed
		if not row or row.pid == task.holder_pid then
			task.status = "unavailable"
			task.detail = row and "Task launch was interrupted before the command started."
				or "The task pane disappeared before its output could be saved."
		else
			local output = assert(request({ "capture-pane", "-p", "-J", "-S", "-50000", "-t", task.pane }))
			write(path(task.id, ".log"), table.concat(clean_output(vim.split(output, "\n", { plain = true })), "\n"))
			local ended = row.exited
			if ended and ended > 0 then
				task.finished = ended
			end
			task.code = row.code
			task.signal = row.signal
			task.status = task.signal and "terminated"
				or (task.code == 0 and "succeeded" or (task.code and "failed" or "unknown"))
		end
		save(task)
		local level = (task.status == "failed" or task.status == "terminated" or task.status == "unavailable")
				and vim.log.levels.WARN
			or vim.log.levels.INFO
		notify(
			vim.fs.basename(task.root) .. ": " .. task.command .. " — " .. label(task) .. " (<leader>to: results)",
			level
		)
	end
	if remove(task) then
		task.cleaned = true
		task.cleanup_verified = true
		save(task)
	end
end

local function poll()
	for id in pairs(pending) do
		if not busy[id] then
			busy[id] = true
			coroutine.wrap(function()
				local release
				local ok, err = pcall(function()
					release = claim(id)
					if not release then
						return
					end
					local task = load(id)
					reconcile(task)
					if task.cleaned and task.cleanup_verified then
						pending[id] = nil
					end
				end)
				if release then
					release()
				end
				busy[id] = nil
				if not ok and errors[id] ~= tostring(err) then
					errors[id] = tostring(err)
					notify("Task retained; archival/cleanup will retry: " .. tostring(err), vim.log.levels.ERROR)
				elseif ok then
					errors[id] = nil
				end
			end)()
		end
	end
	if not next(pending) and timer then
		timer:stop()
		timer:close()
		timer = nil
	end
end

---Serialize session discovery/creation for both interactive windows and tasks.
---@param root string
---@param action function
function M.in_project(root, action)
	vim.fn.mkdir(directory, "p")
	local release = claim(vim.fn.sha256("project:" .. mux.canonical(root)))
	if not release then
		vim.defer_fn(function()
			local ok, err = pcall(M.in_project, root, action)
			if not ok then
				notify(tostring(err), vim.log.levels.ERROR)
			end
		end, 100)
		return
	end
	local ok, err = pcall(action)
	release()
	if not ok then
		error(err, 0)
	end
end

---Discover unfinished work only on task-related actions, not on every timer tick.
---@return MuxTask[] tasks
local function resume()
	local tasks = {}
	if uv.fs_stat(directory) then
		for name, kind in vim.fs.dir(directory) do
			local id = kind == "file" and name:match("^(%x+)%.json$") or nil
			if id then
				local ok, task = pcall(load, id)
				if ok then
					tasks[#tasks + 1] = task
					if not task.cleaned or not task.cleanup_verified then
						pending[id] = true
					end
				elseif errors[id] ~= tostring(task) then
					errors[id] = tostring(task)
					notify(tostring(task), vim.log.levels.ERROR)
				end
			end
		end
	end
	if next(pending) and not timer then
		timer = assert(uv.new_timer())
		timer:start(0, 1000, vim.schedule_wrap(poll))
	end
	return tasks
end

---@param command string
---@param context? {root: string, cwd: string} Saved execution context when rerunning a task
function M.launch(command, context)
	command = vim.trim(command)
	assert(command ~= "" and not command:find("[%c]"), "Enter a single-line task command.")
	local root, cwd
	if context then
		root, cwd = context.root, context.cwd
	else
		root, cwd = mux.project()
	end
	local stat = uv.fs_stat(cwd)
	assert(stat and stat.type == "directory", "Task directory is unavailable: " .. cwd)
	resume()
	local id = vim.fn.sha256(vim.fn.tempname() .. tostring(uv.hrtime())):sub(1, 32)
	M.in_project(root, function()
		local window, recorded, release
		local ok, err = pcall(function()
			release = assert(claim(id), "Could not claim new task")
			local shell = windows and "pwsh" or (vim.fn.has("macunix") == 1 and "zsh" or "bash")
			local holder = windows and { shell, "-NoLogo", "-NoProfile", "-Command", "Start-Sleep 86400" }
				or { shell, "-c", "sleep 86400" }
			window = mux.create_window(root, cwd, "task: " .. command, holder)
			local marker = "@dotfiles-task-" .. window.pane_id:sub(2)
			mux.run({ "set-option", "-p", "-t", window.pane, "remain-on-exit", "on" })
			mux.run({ "set-option", "-t", window.session, marker, id })
			---@type MuxTask
			local task = {
				id = id,
				root = mux.canonical(root),
				cwd = cwd,
				command = command,
				started = now(),
				status = "running",
				cleaned = false,
				session = window.session,
				pane = window.pane,
				marker = marker,
				holder_pid = window.pid,
			}
			save(task)
			recorded = true
			local argv = windows
					and {
						shell,
						"-NoLogo",
						"-EncodedCommand",
						vim.base64.encode(assert(vim.iconv(command, "utf-8", "utf-16le"))),
					}
				or { shell, "-ic", command }
			-- psmux forwards respawn arguments as unquoted text to its server.
			local respawn_cwd = windows and ('"' .. vim.fs.normalize(cwd) .. '"') or cwd
			mux.run(vim.list_extend({ "respawn-pane", "-k", "-t", window.pane, "-c", respawn_cwd, "--" }, argv))
			if not windows then
				task.pid = mux.run({ "display-message", "-p", "-t", window.pane, "#{pane_pid}" })
				save(task)
			end
			notify("Started " .. command)
		end)
		if window and not recorded then
			local removed, remove_err = pcall(mux.run, { "kill-window", "-t", window.target })
			if not removed then
				err = tostring(err) .. "; holder cleanup failed: " .. tostring(remove_err)
			end
		end
		if release then
			release()
		end
		resume()
		if not ok then
			error(err, 0)
		end
	end)
end

---Register this editor for watched-pane transitions, including native mux navigation.
function M.watch()
	vim.fn.mkdir(directory, "p")
	write(path(vim.fn.sha256(identity()), ".viewer"), identity())
	resume()
end

---@return string
local function current_root()
	return vim.b.mux_task_root or mux.canonical(mux.project())
end

---@param root string
---@return MuxTask[]
local function completed(root)
	local tasks = vim.tbl_filter(function(task)
		return task.root == root
			and task.finished ~= nil
			and (task.status == "unavailable" or uv.fs_stat(path(task.id, ".log")) ~= nil)
	end, resume())
	table.sort(tasks, function(a, b)
		if a.finished ~= b.finished then
			return a.finished > b.finished
		elseif a.observed ~= b.observed then
			return (a.observed or a.started) > (b.observed or b.started)
		elseif a.started ~= b.started then
			return a.started > b.started
		end
		return a.id > b.id
	end)
	return tasks
end

function M.results()
	local root = current_root()
	local function items()
		return vim.tbl_map(function(task)
			return {
				task = task,
				text = os.date("%Y-%m-%d %H:%M:%S", task.finished) .. "  [" .. label(task) .. "]  " .. task.command,
			}
		end, completed(root))
	end
	if #items() == 0 then
		notify("No saved task results for this repository.")
		return
	end
	require("snacks").picker.pick({
		title = "Task results — newest first",
		finder = items,
		format = "text",
		layout = { preset = "select" },
		-- Fuzzy matching filters; relevance must not reorder the chronology.
		sort = { fields = { "idx" } },
		actions = {
			rerun_task = function(p)
				local item = p:current()
				if not item then
					return
				end
				local task = item.task
				p:close()
				vim.schedule(function()
					local ok, err = pcall(M.launch, task.command, { root = task.root, cwd = task.cwd })
					if not ok then
						notify(tostring(err), vim.log.levels.ERROR)
					end
				end)
			end,
		},
		win = {
			input = { keys = { ["<C-e>"] = { "rerun_task", mode = { "i", "n" }, desc = "Rerun selected task" } } },
			list = { keys = { ["<C-e>"] = "rerun_task" } },
		},
		confirm = function(p, item)
			if item then
				p:close()
				vim.schedule(function()
					local ok, err = pcall(open, item.task)
					if not ok then
						notify(tostring(err), vim.log.levels.ERROR)
					end
				end)
			end
		end,
	})
end

function M.last()
	local root = current_root()
	local tasks = completed(root)
	local ok, lines = pcall(vim.fn.readfile, last_path(root))
	for _, task in ipairs(tasks) do
		if ok and task.id == lines[1] then
			open(task)
			return
		end
	end
	if tasks[1] then
		open(tasks[1])
	else
		notify("No saved task results for this repository. Pending tasks will be checked in the background.")
	end
end

return M
