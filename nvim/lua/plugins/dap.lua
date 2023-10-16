local is_neovim = require('config.utils').is_neovim
local home = require('config.utils').home

return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'mxsdev/nvim-dap-vscode-js',
        {
            'microsoft/vscode-js-debug',
            version = '1.x',
            build = 'npm i && npm run compile vsDebugServerBundle && mv dist out',
        },
    },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')

        -- JS & TS
        require("dap-vscode-js").setup({
            debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
            adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
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
                    processId = require 'dap.utils'.pick_process,
                    -- name of the debug action you have to select for this config
                    name = "Attach debugger to existing `node --inspect` process",
                    -- for compiled languages like TypeScript or Svelte.js
                    sourceMaps = true,
                    -- resolve source maps in nested locations while ignoring node_modules
                    resolveSourceMapLocations = {
                        "${workspaceFolder}/**",
                        "!**/node_modules/**" },
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
                language == "javascript" and {
                    -- use nvim-dap-vscode-js's pwa-node debug adapter
                    type = "pwa-node",
                    -- launch a new process to attach the debugger to
                    request = "launch",
                    -- name of the debug action you have to select for this config
                    name = "Launch file in new node process",
                    -- launch current file
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                } or nil,
            }
        end

        -- Godot
        dap.adapters.godot = {
            type = "server",
            host = '127.0.0.1',
            port = 6006,
        }

        dap.configurations.gdscript = {
            {
                type = "godot",
                request = "launch",
                name = "Launch scene",
                project = "${workspaceFolder}",
                launch_scene = true,
            }
        }

        -- PHP
        dap.adapters.php = {
            type = 'executable',
            command = 'node',
            args = { home .. '/projects/debuggers/vscode-php-debug/out/phpDebug.js' }
        }

        dap.configurations.php = {
            {
                type = 'php',
                request = 'launch',
                name = 'Listen for Xdebug',
                port = 9003,
                pathMappings = {
                    ['/var/www/html'] = '${workspaceFolder}'
                }
            },
            {
                type = 'php',
                request = 'launch',
                name = 'purplemashweb',
                port = 9003,
                pathMappings = {
                    ['/var/www/purplemashweb'] = '${workspaceFolder}'
                }
            },
        }

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

        -- mappings
        vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
        vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
        vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
        vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
        vim.keymap.set('n', '<Leader>lb', function() require('dap').toggle_breakpoint() end)
        vim.keymap.set('n', '<Leader>lB', function() require('dap').set_breakpoint() end)
        vim.keymap.set('n', '<Leader>lg',
            function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
        vim.keymap.set('n', '<Leader>lr', function() require('dap').repl.open() end)
        vim.keymap.set('n', '<Leader>ll', function() require('dap').run_last() end)
        vim.keymap.set({ 'n', 'v' }, '<Leader>lh', function()
            require('dap.ui.widgets').hover()
        end)
        vim.keymap.set({ 'n', 'v' }, '<Leader>lp', function()
            require('dap.ui.widgets').preview()
        end)
        vim.keymap.set('n', '<Leader>lf', function()
            local widgets = require('dap.ui.widgets')
            widgets.centered_float(widgets.frames)
        end)
        vim.keymap.set('n', '<Leader>ls', function()
            local widgets = require('dap.ui.widgets')
            widgets.centered_float(widgets.scopes)
        end)
        vim.keymap.set('n', '<Leader>lu', function()
            dapui.toggle()
        end)
    end,
    enabled = is_neovim,
}
