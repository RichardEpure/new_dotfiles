local is_neovim = require("config.utils").is_neovim
local home = require("config.utils").home

return {
	"mfussenegger/nvim-dap",
	enabled = is_neovim,
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-telescope/telescope-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"leoluz/nvim-dap-go",
		"mxsdev/nvim-dap-vscode-js",
		{
			"microsoft/vscode-js-debug",
			version = "1.x",
			build = "npm i && npm run compile vsDebugServerBundle && mv dist out",
		},
	},
	keys = {
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
		},
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
		},
		{
			"<F11>",
			function()
				require("dap").step_into()
			end,
		},
		{
			"<F12>",
			function()
				require("dap").step_out()
			end,
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
			"<Leader>lh",
			function()
				require("dap.ui.widgets").hover()
			end,
			mode = { "n", "v" },
			desc = "Dap ui hover",
		},
		{
			"<Leader>lp",
			function()
				require("dap.ui.widgets").preview()
			end,
			mode = { "n", "v" },
			desc = "Dap ui preview",
		},
		{
			"<Leader>lf",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end,
			desc = "Dap ui float",
		},
		{
			"<Leader>ls",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end,
			desc = "Dap ui scopes",
		},
		{
			"<Leader>lu",
			function()
				require("dapui").toggle()
			end,
			desc = "Dap ui toggle",
		},
	},
	config = function()
		require("telescope").load_extension("dap")
		require("nvim-dap-virtual-text").setup()

		local dap = require("dap")
		local dapui = require("dapui")

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
		dap.configurations.rust = dap.configurations.cpp

		-- dapui
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open({ reset = true })
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
		dapui.setup()
	end,
}
