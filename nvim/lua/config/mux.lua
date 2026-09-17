local M = {}
local windows = vim.fn.has("win32") == 1
local executable = windows and "psmux" or "tmux"
local viewers = {}

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

local function run(args, allow_empty)
	if vim.fn.executable(executable) ~= 1 then
		error("Install " .. executable .. " and restart your terminal so it is on PATH.", 0)
	end
	local result = vim.system(vim.list_extend({ executable }, args), { text = true }):wait(10000)
	if result.code ~= 0 then
		local err = vim.trim(result.stderr or "")
		if
			allow_empty
			and (
				err:find("no server running", 1, true)
				or err:find("no sessions", 1, true)
				or err:find("No such file or directory", 1, true)
				or err:find("can't find session", 1, true)
			)
		then
			return ""
		end
		error(err ~= "" and err or (args[1] .. " failed (" .. result.code .. ")"), 0)
	end
	return (result.stdout or ""):gsub("\r\n", "\n"):gsub("\n+$", "")
end

local function records(output)
	local rows = {}
	for line in output:gmatch("[^\n]+") do
		rows[#rows + 1] = vim.split(line, "\t", { plain = true })
	end
	return rows
end

local function canonical(path)
	path = vim.fs.normalize(vim.uv.fs_realpath(path) or path)
	return windows and path:lower() or path
end

local function project()
	local cwd = vim.fn.getcwd()
	local result = vim.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, { text = true }):wait(5000)
	local root = result.code == 0 and vim.trim(result.stdout) or cwd
	return vim.fs.normalize(vim.uv.fs_realpath(root) or root), cwd
end

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
	-- ponytail: fixed attachment scope; use our session picker, or track client state if native session switching is needed.
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
		local all = sessions()
		local item = repo_session(root, all)
		local shell = windows and { "pwsh", "-NoLogo" } or { vim.fn.has("macunix") == 1 and "zsh" or "bash", "-i" }
		if vim.fn.executable(shell[1]) ~= 1 then
			error("Missing shell: " .. shell[1], 0)
		end
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
		vim.list_extend(args, { "-c", cwd, "-n", name, "-P", "-F", "#{session_id}:#{window_id}", "--" })
		vim.list_extend(args, shell)
		local target = run(args)
		local session = target:match("^(%$%d+):@%d+$")
		assert(session, "Invalid mux creation response: " .. target)
		if not item then
			run({ "set-option", "-t", session, "@dotfiles-root", root })
			run({ "set-option", "-t", session, "@dotfiles-workflow", "repo-shells" })
		end
		attach(session, target)
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

local function picker(kind, session)
	local function items()
		return kind == "session" and sessions() or window_items(session)
	end
	-- Query once before opening so missing executables/servers have a useful message.
	if #items() == 0 then
		notify("No " .. kind .. "s found.")
		return
	end
	local opts = {
		title = kind == "session" and "Sessions"
			or (session and "Windows — current session" or "Windows — all sessions"),
		finder = items,
		format = "text",
		layout = { preset = "select" },
		confirm = safe(function(p, item)
			if not item then
				return
			end
			p:close()
			vim.schedule(safe(function()
				attach(item.session, item.target)
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
	require("snacks").picker.pick(opts)
end

function M.sessions()
	picker("session")
end
function M.windows()
	picker("window", current_session())
end
function M.all_windows()
	picker("window")
end

function M.history()
	local session = current_session()
	local pane = run({ "display-message", "-p", "-t", session .. ":", "#{pane_id}" })
	local output = run({ "capture-pane", "-p", "-J", "-S", "-50000", "-t", session .. ":." .. pane })
	local term = viewers[session]
	if term and term:is_open() then
		term:close()
	end
	vim.cmd("botright new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n", { plain = true }))
	vim.bo.modifiable = false
	vim.bo.filetype = "log"
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close history snapshot" })
	vim.cmd("normal! G")
end

function M.setup()
	for key, action in pairs({
		tn = { M.new_window, "New repository window" },
		tv = { M.toggle, "Toggle mux viewer" },
		ts = { M.sessions, "Mux sessions" },
		tw = { M.windows, "Mux windows" },
		tW = { M.all_windows, "All mux windows" },
		th = { M.history, "Capture pane history" },
	}) do
		vim.keymap.set("n", "<leader>" .. key, safe(action[1]), { desc = action[2] })
	end
end

return M
