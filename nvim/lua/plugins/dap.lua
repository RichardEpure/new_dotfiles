local is_neovim = require("config.utils").is_neovim
local home = require("config.utils").home

return {
	"mfussenegger/nvim-dap",
	enabled = is_neovim,
	dependencies = {
		"nvim-neotest/nvim-nio",
		{
			"igorlfs/nvim-dap-view",
			---@module 'dap-view'
			---@type dapview.Config
			opts = {
				windows = {
					terminal = {
						-- Use the actual names for the adapters you want to hide
						hide = { "go" }, -- `go` is known to not use the terminal.
					},
				},
			},
		},
		"theHamsta/nvim-dap-virtual-text",
		"leoluz/nvim-dap-go",
		"mxsdev/nvim-dap-vscode-js",
		{
			"microsoft/vscode-js-debug",
			version = "1.x",
			build = "npm install --ignore-scripts && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
		},
	},
	keys = {
		{
			"<leader>lc",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
		},
		{
			"<leader>lo",
			function()
				require("dap").step_over()
			end,
			desc = "Step over",
		},
		{
			"<leader>li",
			function()
				require("dap").step_into()
			end,
			desc = "Step into",
		},
		{
			"<leader>lt",
			function()
				require("dap").step_out()
			end,
			desc = "Step out",
		},
		{
			"<leader>lb",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle breakpoint",
		},
		{
			"<leader>lB",
			function()
				require("dap").set_breakpoint()
			end,
			desc = "Set breakpoint",
		},
		{
			"<leader>lg",
			function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end,
			desc = "Set breakpoint with log",
		},
		{
			"<leader>lr",
			function()
				require("dap").repl.open()
			end,
			desc = "Repl open",
		},
		{
			"<leader>ll",
			function()
				require("dap").run_last()
			end,
			desc = "Run last",
		},
		{
			"<Leader>lu",
			[[:DapViewToggle<CR>]],
			desc = "Dap ui toggle",
		},
	},
	config = function()
		require("nvim-dap-virtual-text").setup({})

		local dap = require("dap")

		-- JS & TS
		require("dap-vscode-js").setup({
			debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
		})

		for _, language in ipairs({ "typescript", "javascript", "vue" }) do
			dap.configurations[language] = {
				-- attach to a node process that has been started with
				-- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
				-- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
				{
					-- use nvim-dap-vscode-js's pwa-node debug adapter
					type = "pwa-node",
					-- attach to an already running node process with --inspect flag
					-- default port: 9222
					request = "attach",
					-- allows us to pick the process using a picker
					processId = require("dap.utils").pick_process,
					-- name of the debug action you have to select for this config
					name = "Attach debugger to existing `node --inspect` process",
					-- for compiled languages like TypeScript or Svelte.js
					sourceMaps = true,
					-- resolve source maps in nested locations while ignoring node_modules
					resolveSourceMapLocations = {
						"${workspaceFolder}/**",
						"!**/node_modules/**",
					},
					-- path to src in vite based projects (and most other projects as well)
					cwd = "${workspaceFolder}/src",
					-- we don't want to debug code inside node_modules, so skip it!
					skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
				},
				{
					type = "pwa-chrome",
					name = "Launch Chrome to debug client",
					request = "launch",
					url = "http://localhost:5173",
					sourceMaps = true,
					protocol = "inspector",
					port = 9222,
					webRoot = "${workspaceFolder}/src",
					-- skip files from vite's hmr
					skipFiles = { "**/node_modules/**/*", "**/@vite/*", "**/src/client/*", "**/src/*" },
				},
				-- only if language is javascript, offer this debug action
				language == "javascript"
						and {
							-- use nvim-dap-vscode-js's pwa-node debug adapter
							type = "pwa-node",
							-- launch a new process to attach the debugger to
							request = "launch",
							-- name of the debug action you have to select for this config
							name = "Launch file in new node process",
							-- launch current file
							program = "${file}",
							cwd = "${workspaceFolder}",
						}
					or nil,
			}
		end

		-- Godot
		dap.adapters.godot = {
			type = "server",
			host = "127.0.0.1",
			port = 6006,
		}

		dap.configurations.gdscript = {
			{
				type = "godot",
				request = "launch",
				name = "Launch scene",
				project = "${workspaceFolder}",
				launch_scene = true,
			},
		}

		-- PHP
		dap.adapters.php = {
			type = "executable",
			command = "node",
			args = { home .. "/projects/debuggers/vscode-php-debug/out/phpDebug.js" },
		}

		dap.configurations.php = {
			{
				type = "php",
				request = "launch",
				name = "Listen for Xdebug",
				port = 9003,
				pathMappings = {
					["/var/www/html"] = "${workspaceFolder}",
				},
			},
			{
				type = "php",
				request = "launch",
				hostname = "0.0.0.0",
				name = "purplemashweb",
				port = 9003,
				pathMappings = {
					["/var/www/purplemashweb"] = "${workspaceFolder}",
				},
			},
		}

		-- Golang
		require("dap-go").setup({
			-- Additional dap configurations can be added.
			-- dap_configurations accepts a list of tables where each entry
			-- represents a dap configuration. For more details do:
			-- :help dap-configuration
			dap_configurations = {
				{
					-- Must be "go" or it will be ignored by the plugin
					type = "go",
					name = "Attach remote",
					mode = "remote",
					request = "attach",
				},
			},
			-- delve configurations
			delve = {
				-- the path to the executable dlv which will be used for debugging.
				-- by default, this is the "dlv" executable on your PATH.
				path = vim.fn.exepath("dlv"),
				-- time to wait for delve to initialize the debug session.
				-- default to 20 seconds
				initialize_timeout_sec = 20,
				-- a string that defines the port to start delve debugger.
				-- default to string "${port}" which instructs nvim-dap
				-- to start the process in a random available port
				port = "${port}",
				-- additional args to pass to dlv
				args = {},
				-- the build flags that are passed to delve.
				-- defaults to empty string, but can be used to provide flags
				-- such as "-tags=unit" to make sure the test suite is
				-- compiled during debugging, for example.
				-- passing build flags using args is ineffective, as those are
				-- ignored by delve in dap mode.
				build_flags = "",
			},
		})

		-- C / C++ / Rust
		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = vim.fn.exepath("OpenDebugAD7"),
			options = {
				detached = vim.fn.has("linux") == 1 and true or false,
			},
		}

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.exepath("codelldb"),
				args = { "--port", "${port}" },
				detached = vim.fn.has("linux") == 1 and true or false,
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
				setupCommands = {
					{
						text = "-enable-pretty-printing",
						description = "enable pretty printing",
						ignoreFailures = false,
					},
				},
			},
			{
				name = "Attach to gdbserver :1234",
				type = "cppdbg",
				request = "launch",
				MIMode = "gdb",
				miDebuggerServerAddress = "localhost:1234",
				miDebuggerPath = "/usr/bin/gdb",
				cwd = "${workspaceFolder}",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				setupCommands = {
					{
						text = "-enable-pretty-printing",
						description = "enable pretty printing",
						ignoreFailures = false,
					},
				},
			},
		}

		dap.configurations.c = dap.configurations.cpp

		dap.configurations.rust = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}

		-- Python
		local python_venv_path = os.getenv("VIRTUAL_ENV")
		if vim.fn.has("win32") == 1 and python_venv_path then
			python_venv_path = python_venv_path .. "/Scripts/python"
		elseif vim.fn.has("linux") and python_venv_path then
			python_venv_path = python_venv_path .. "/bin/python"
		end

		local python_absolute_path = vim.fn.exepath("python")

		dap.adapters.python = function(cb, config)
			if config.request == "attach" then
				---@diagnostic disable-next-line: undefined-field
				local port = (config.connect or config).port
				---@diagnostic disable-next-line: undefined-field
				local host = (config.connect or config).host or "127.0.0.1"
				cb({
					type = "server",
					port = assert(port, "`connect.port` is required for a python `attach` configuration"),
					host = host,
					options = {
						source_filetype = "python",
					},
				})
			else
				cb({
					type = "executable",
					command = vim.fn.exepath("debugpy-adapter"),
					args = { "-m", "debugpy.adapter" },
					options = {
						source_filetype = "python",
					},
				})
			end
		end

		dap.configurations.python = {
			{
				-- The first three options are required by nvim-dap
				type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
				request = "launch",
				name = "Launch file",

				-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

				program = "${file}", -- This configuration will launch the current file if used.
				pythonPath = function()
					-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
					if python_venv_path then
						return python_venv_path
					else
						return python_absolute_path
					end
				end,
			},
		}
	end,
}
