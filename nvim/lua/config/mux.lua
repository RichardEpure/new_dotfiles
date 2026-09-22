local M = {}
local windows = vim.fn.has("win32") == 1
local executable = windows and "psmux" or "tmux"
---@type table<string, Terminal>
local viewers = {}
local last_history

local function notify(message)
	vim.notify(message, vim.log.levels.WARN, { title = "Mux" })
end

local function safe(fn)
	return function(...)
		local ok, err = pcall(fn, ...)
		if not ok then
			notify(tostring(err))
		end
	end
end

---@param args string[]
---@return string[]
function M.argv(args)
	if vim.fn.executable(executable) ~= 1 then
		error("Install " .. executable .. " and restart your terminal so it is on PATH.", 0)
	end
	return vim.list_extend({ executable }, args)
end

---@param message string
---@return boolean
function M.is_missing(message)
	return message:find("no server running", 1, true) ~= nil
		or message:find("no sessions", 1, true) ~= nil
		or message:find("No such file or directory", 1, true) ~= nil
		or message:find("can't find session", 1, true) ~= nil
		or message:find("can't find window", 1, true) ~= nil
		or message:find("can't find pane", 1, true) ~= nil
end

---@param args string[]
---@param allow_empty? boolean
---@return string
local function run(args, allow_empty)
	local result = vim.system(M.argv(args), { text = true }):wait(10000)
	if result.code ~= 0 then
		local err = vim.trim(result.stderr or "")
		if allow_empty and M.is_missing(err) then
			return ""
		end
		error(err ~= "" and err or (args[1] .. " failed (" .. result.code .. ")"), 0)
	end
	return ((result.stdout or ""):gsub("\r\n", "\n"):gsub("\n+$", ""))
end
M.run = run

local function records(output)
	local rows = {}
	for line in output:gmatch("[^\n]+") do
		rows[#rows + 1] = vim.split(line, "\t", { plain = true })
	end
	return rows
end

---@param path string
---@return string
local function canonical(path)
	path = vim.fs.normalize(vim.uv.fs_realpath(path) or path)
	return windows and path:lower() or path
end
M.canonical = canonical

---@return string root, string cwd
local function project()
	local cwd = vim.fn.getcwd()
	local result = vim.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, { text = true }):wait(5000)
	local root = result.code == 0 and vim.trim(result.stdout) or cwd
	return vim.fs.normalize(vim.uv.fs_realpath(root) or root), cwd
end
M.project = project

local function sessions()
	local items = {}
	local format = "#{session_id}\t#{session_name}\t#{session_windows}\t#{@dotfiles-root}\t#{@dotfiles-workflow}"
	for _, row in ipairs(records(run({ "list-sessions", "-F", format }, true))) do
		items[#items + 1] = {
			session = row[1],
			name = row[2],
			root = row[4],
			workflow = row[5],
			text = row[2] .. "  (" .. row[3] .. " windows)" .. (row[5] == "repo-shells" and "  [repo]" or ""),
		}
	end
	return items
end

local function repo_session(root, items)
	for _, item in ipairs(items or sessions()) do
		if item.workflow == "repo-shells" and item.root ~= "" and canonical(item.root) == canonical(root) then
			return item
		end
	end
end

local function current_session()
	-- Remembers the session this viewer attached to, not native session changes via mux.
	-- Use <leader>ts to switch sessions; native switching needs live client tracking.
	local id = vim.b.mux_session
	if id then
		return id
	end
	local root = project()
	local item = repo_session(root)
	if not item then
		error("No session for this repository. Use <leader>tn to create a window.", 0)
	end
	return item.session
end

local function window_items(session)
	local args = {
		"list-windows",
		"-F",
		"#{session_id}\t#{session_name}\t#{window_id}\t#{window_index}\t#{window_name}\t#{pane_current_command}",
	}
	vim.list_extend(args, session and { "-t", session } or { "-a" })
	local items = {}
	for _, row in ipairs(records(run(args, true))) do
		items[#items + 1] = {
			session = row[1],
			target = row[1] .. ":" .. row[3],
			name = row[5],
			text = row[2] .. "  " .. row[4] .. ": " .. row[5] .. "  " .. row[6],
		}
	end
	return items
end

local function shell_quote(value)
	return windows and ("'" .. value:gsub("'", "''") .. "'") or vim.fn.shellescape(value)
end

local function attach(session, target)
	local registered, err = pcall(require("config.mux_tasks").watch)
	if not registered then
		notify("Task viewer notifications unavailable: " .. tostring(err))
	end
	if target then
		run({ "select-window", "-t", target })
	end
	for id, term in pairs(viewers) do
		if id ~= session and term:is_open() then
			term:close()
		end
	end
	local term = viewers[session]
	if not term then
		local command = (windows and "& " or "")
			.. shell_quote(vim.fn.exepath(executable))
			.. " attach-session -t "
			.. shell_quote(session)
		term = require("toggleterm.terminal").Terminal:new({
			cmd = command,
			direction = "float",
			hidden = true,
			display_name = "Mux",
			close_on_exit = true,
			on_open = function(t)
				vim.b[t.bufnr].mux_session = session
				vim.keymap.set("n", "q", function()
					t:close()
				end, { buffer = t.bufnr, desc = "Hide mux viewer" })
				vim.cmd("startinsert!")
			end,
			on_exit = function(t, _, code)
				if viewers[session] == t then
					viewers[session] = nil
				end
				if code ~= 0 then
					notify("Mux client exited (" .. code .. "). Reopen with <leader>tv or <leader>ts.")
				end
			end,
		})
		viewers[session] = term
	end
	if term:is_open() then
		term:focus()
		vim.cmd("startinsert!")
	else
		term:open()
	end
end

---@class MuxWindow
---@field session string
---@field target string Window target
---@field pane string Full pane target
---@field pane_id string
---@field pid string

---Create a detached window; callers choose whether to attach or run a task.
---@param root string
---@param cwd string
---@param name string
---@param shell string[]
---@return MuxWindow
function M.create_window(root, cwd, name, shell)
	if vim.fn.executable(shell[1]) ~= 1 then
		error("Missing shell: " .. shell[1], 0)
	end
	local all = sessions()
	local item = repo_session(root, all)
	local args
	if item then
		args = { "new-window", "-d", "-t", item.session .. ":" }
	else
		local base = vim.fs.basename(root):gsub("[^%w_-]", "-")
		if base == "" then
			base = "repo"
		end
		local used = {}
		for _, existing in ipairs(all) do
			used[existing.name] = true
		end
		local session_name = base
		if used[session_name] then
			session_name = base .. "-" .. vim.fn.sha256(canonical(root)):sub(1, 8)
		end
		local suffix = 2
		local candidate = session_name
		while used[candidate] do
			candidate = session_name .. "-" .. suffix
			suffix = suffix + 1
		end
		args = { "new-session", "-d", "-s", candidate }
	end
	if name == "" then
		local used = {}
		for _, window in ipairs(item and window_items(item.session) or {}) do
			used[window.name] = true
		end
		local index = 1
		while used["shell-" .. index] do
			index = index + 1
		end
		name = "shell-" .. index
	end
	vim.list_extend(args, {
		"-c",
		cwd,
		"-n",
		name,
		"-P",
		"-F",
		"#{session_id}:#{window_id}\t#{pane_id}\t#{pane_pid}",
		"--",
	})
	vim.list_extend(args, shell)
	local response = run(args)
	-- psmux's creation response normalizes literal tabs to spaces.
	local target, pane, pid = response:match("^(%$%d+:@%d+)%s+(%%%d+)%s+(%d+)$")
	assert(target, "Invalid mux creation response: " .. response)
	local session = assert(target:match("^(%$%d+):"))
	if not item then
		local ok, err = pcall(function()
			run({ "set-option", "-t", session, "@dotfiles-root", root })
			run({ "set-option", "-t", session, "@dotfiles-workflow", "repo-shells" })
		end)
		if not ok then
			pcall(run, { "kill-window", "-t", target })
			error(err, 0)
		end
	end
	return { session = session, target = target, pane = target .. "." .. pane, pane_id = pane, pid = pid }
end

---@param session string
---@return boolean closed Whether the focused viewer was closed
function M.close_focused_view(session)
	local term = viewers[session]
	if term and term:is_open() and vim.api.nvim_get_current_buf() == term.bufnr then
		term:close()
		vim.cmd("stopinsert")
		return true
	end
	return false
end

function M.new_window()
	local root, cwd = project()
	local on_name = safe(function(name)
		if name == nil then
			return
		end
		name = vim.trim(name)
		if name:find("[%c]") then
			error("Window names cannot contain control characters.", 0)
		end
		local shell = windows and { "pwsh", "-NoLogo" } or { vim.fn.has("macunix") == 1 and "zsh" or "bash", "-i" }
		require("config.mux_tasks").in_project(root, function()
			local window = M.create_window(root, cwd, name, shell)
			attach(window.session, window.target)
		end)
	end)
	vim.ui.input({ prompt = "Window name (Enter = shell): " }, on_name)
end

function M.toggle()
	local session = current_session()
	local term = viewers[session]
	if term and term:is_open() then
		term:close()
	else
		attach(session)
	end
end

local function picker(kind, session, on_confirm)
	local initial_session = session
	local label = on_confirm and "History" or "Windows"
	local function title()
		return kind == "session" and "Sessions"
			or (label .. (session and " — current session" or " — all sessions"))
	end
	local function items()
		return kind == "session" and sessions() or window_items(session)
	end
	-- Query once before opening so missing executables/servers have a useful message.
	if #items() == 0 then
		notify("No " .. kind .. "s found.")
		return
	end
	local opts = {
		title = title(),
		finder = items,
		format = "text",
		layout = { preset = "select" },
		confirm = safe(function(p, item)
			if not item then
				return
			end
			p:close()
			vim.schedule(safe(function()
				if on_confirm then
					on_confirm(item)
				else
					attach(item.session, item.target)
				end
			end))
		end),
		actions = {
			kill_mux = safe(function(p)
				local item = p:current()
				if not item then
					return
				end
				local prompt = "Kill " .. kind .. " " .. item.text .. " and all its processes?"
				if vim.fn.confirm(prompt, "&Kill\n&Cancel", 2) ~= 1 then
					return
				end
				local ok, err = pcall(run, { "kill-" .. kind, "-t", item.target or item.session })
				if not ok then
					notify(tostring(err))
				end
				p:find()
			end),
		},
		win = {
			input = { keys = { ["<C-x>"] = { "kill_mux", mode = { "i", "n" }, desc = "Kill selected " .. kind } } },
			list = { keys = { ["<C-x>"] = "kill_mux" } },
		},
	}
	if kind == "window" then
		opts.actions.toggle_sessions = safe(function(p)
			session = session == nil and initial_session or nil
			p.title = title()
			p:refresh()
		end)
		opts.win.input.keys["<A-a>"] = { "toggle_sessions", mode = { "i", "n" }, desc = "Toggle all sessions" }
		opts.win.list.keys["<A-a>"] = { "toggle_sessions", desc = "Toggle all sessions" }
	end
	require("snacks").picker.pick(opts)
end

function M.sessions()
	picker("session")
end
function M.windows()
	picker("window", current_session())
end

---Keep native file lookup, but replace the output split with the editing window.
function M.output_keymaps()
	for _, key in ipairs({ "gf", "gF" }) do
		vim.keymap.set(
			"n",
			key,
			safe(function()
				local output = vim.api.nvim_get_current_win()
				local destination = vim.fn.win_getid(vim.fn.winnr("#"))
				-- Resolve first: a failed jump must leave the output available.
				vim.cmd.normal({ vim.v.count1 .. key, bang = true })
				if destination == output or not vim.api.nvim_win_is_valid(destination) then
					return
				end
				local buffer = vim.api.nvim_get_current_buf()
				local cursor = vim.api.nvim_win_get_cursor(0)
				vim.api.nvim_win_call(destination, function()
					vim.cmd.buffer(tostring(buffer))
					vim.api.nvim_win_set_cursor(0, cursor)
				end)
				vim.api.nvim_win_close(output, false)
				vim.api.nvim_set_current_win(destination)
			end),
			{ buffer = true, desc = "Open file and close output" }
		)
	end
end

local function capture_history(item)
	local pane = run({ "display-message", "-p", "-t", item.target, "#{pane_id}" })
	local output = run({ "capture-pane", "-p", "-J", "-S", "-50000", "-t", item.target .. "." .. pane })
	local term = viewers[item.session]
	if term and term:is_open() then
		term:close()
	end
	vim.cmd("botright new")
	vim.b.mux_session = item.session
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n", { plain = true }))
	vim.bo.modifiable = false
	vim.bo.filetype = "log"
	M.output_keymaps()
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close history snapshot" })
	vim.cmd("normal! G")
	last_history = item
end

function M.history()
	picker("window", current_session(), capture_history)
end

function M.last_history()
	if not last_history then
		notify("No window selected for history. Use <leader>th to pick one.")
		return
	end
	capture_history(last_history)
end

function M.setup()
	local tasks = require("config.mux_tasks")
	vim.api.nvim_create_user_command(
		"MuxTask",
		safe(function(opts)
			local command, cwd = tasks.parse(opts.args)
			tasks.launch(command, { cwd = cwd })
		end),
		{
			nargs = "+",
			complete = require("config.mux_completion").complete,
			desc = "Run a mux task: [--cwd <root-relative directory> --] <command>",
		}
	)
	vim.keymap.set("n", "<leader>tr", ":MuxTask ", { desc = "Run mux task" })
	for key, action in pairs({
		tn = { M.new_window, "New repository window" },
		tv = { M.toggle, "Toggle mux viewer" },
		ts = { M.sessions, "Mux sessions" },
		tw = { M.windows, "Mux windows" },
		th = { M.history, "Pick mux window history" },
		tH = { M.last_history, "Capture last selected window history" },
		to = { tasks.results, "Mux task results (newest first)" },
		tO = { tasks.last, "Last viewed mux task result" },
	}) do
		vim.keymap.set("n", "<leader>" .. key, safe(action[1]), { desc = action[2] })
	end
end

return M
