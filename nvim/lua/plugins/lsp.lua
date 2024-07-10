local is_neovim = require("config.utils").is_neovim

return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	enabled = is_neovim,
	dependencies = {
		-- LSP Support
		{ "neovim/nvim-lspconfig" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },

		-- Autocompletion
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-cmdline",
				"hrsh7th/cmp-buffer",
				"saadparwaiz1/cmp_luasnip",
			},
		},
		{ "hrsh7th/cmp-nvim-lsp" },
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
		},

		-- Other
		{ "folke/neodev.nvim" },
		{ "folke/neoconf.nvim" },
	},
	config = function()
		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { 0 })
		end

		if vim.lsp.inlay_hint then
			vim.keymap.set("n", "<leader>jl", function()
				if vim.lsp.inlay_hint.is_enabled() then
					vim.lsp.inlay_hint.enable(false, { bufnr })
				else
					vim.lsp.inlay_hint.enable(true, { bufnr })
				end
			end, { desc = "Toggle inlay hints" })
		end

		-- Neoconf
		require("neoconf").setup({})

		local lsp_zero = require("lsp-zero")
		local mason_registry = require("mason-registry")

		require("mason").setup({})
		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls" },
			handlers = {
				lsp_zero.default_setup,
			},
		})

		-- LuaSnip
		local luasnip = require("luasnip")
		require("luasnip.loaders.from_vscode").lazy_load()

		-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
		require("neodev").setup()

		-- cmp
		local cmp = require("cmp")
		local cmp_format = require("lsp-zero").cmp_format()

		cmp.setup({
			enabled = function()
				-- disable completion in comments
				local context = require("cmp.config.context")
				-- keep command mode completion enabled when cursor is in a comment
				if vim.api.nvim_get_mode().mode == "c" then
					return true
				else
					return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
				end
			end,
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			formatting = cmp_format,
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),
				["<C-y>"] = cmp.mapping.confirm({
					behaviour = cmp.ConfirmBehavior.Replace,
					select = true,
				}),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					elseif require("copilot.suggestion").is_visible() then
						require("copilot.suggestion").accept()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = {
				{
					name = "nvim_lsp",
					option = {
						markdown_oxide = {
							keywords = [[\(\k\| \|\/\|#\)\+]],
						},
					},
				},
				{ name = "luasnip" },
			},
		})

		-- Auto completion for / search
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Auto completion of ex-commands
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{
					name = "cmdline",
					option = {
						ignore_cmds = { "Man", "!" },
					},
				},
			}, {
				{ name = "path" },
			}),
		})

		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

		-- Lsp Zero
		lsp_zero.setup_servers({
			"cssls",
			"lua_ls",
			"html",
			"jsonls",
		})

		lsp_zero.on_attach(function(client, bufnr)
			lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false })
			local opts = { buffer = bufnr }

			-- Lspsaga keymap overrides
			vim.keymap.set({ "n" }, "<F2>", [[:Lspsaga rename<CR>]], { desc = "Rename", silent = true, buffer = bufnr })
			vim.keymap.set(
				{ "n" },
				"<F4>",
				[[:Lspsaga code_action<CR>]],
				{ desc = "Code action", silent = true, buffer = bufnr }
			)

			-- vim.keymap.set({ 'n', 'x' }, '<leader>jl', function()
			--     vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
			-- end, opts)
		end)

		lsp_zero.setup()

		local lsp_config = require("lspconfig")

		lsp_config.lua_ls.setup({
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					hint = {
						enable = true,
					},
				},
			},
		})

		lsp_config.volar.setup({})

		lsp_config.gopls.setup({
			settings = {
				gopls = {
					hints = {
						rangeVariableTypes = true,
						parameterNames = true,
						constantValues = true,
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						functionTypeParameters = true,
					},
				},
			},
		})

		local vue_typescript_plugin = require("mason-registry").get_package("vue-language-server"):get_install_path()
			.. "/node_modules/@vue/language-server"
			.. "/node_modules/@vue/typescript-plugin"

		lsp_config.tsserver.setup({
			root_dir = require("lspconfig/util").root_pattern("package.json", ".git"),
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_typescript_plugin,
						languages = { "javascript", "typescript", "vue" },
					},
				},
			},
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
			},
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		lsp_config.rust_analyzer.setup({
			root_dir = require("lspconfig/util").root_pattern("cargo.toml", ".git"),
			settings = {
				["rust-analyzer"] = {
					checkOnSave = {
						command = "clippy",
					},
					diagnostics = {
						disabled = { "inactive-code" },
					},
					inlayHints = {
						bindingModeHints = {
							enable = false,
						},
						chainingHints = {
							enable = true,
						},
						closingBraceHints = {
							enable = true,
							minLines = 25,
						},
						closureReturnTypeHints = {
							enable = "never",
						},
						lifetimeElisionHints = {
							enable = "never",
							useParameterNames = false,
						},
						maxLength = 25,
						parameterHints = {
							enable = true,
						},
						reborrowHints = {
							enable = "never",
						},
						renderColons = true,
						typeHints = {
							enable = true,
							hideClosureInitialization = false,
							hideNamedConstructor = false,
						},
					},
				},
			},
		})

		lsp_config.clangd.setup({
			cmd = {
				"clangd",
				"--offset-encoding=utf-16",
			},
			settings = {
				clangd = {
					InlayHints = {
						Designators = true,
						Enabled = true,
						ParameterNames = true,
						DeducedTypes = true,
					},
					fallbackFlags = { "-std=c++20" },
				},
			},
		})

		lsp_config.powershell_es.setup({
			bundle_path = mason_registry.get_package("powershell-editor-services"):get_install_path(),
		})

		lsp_config.pylsp.setup({
			settings = {
				pylsp = {
					plugins = {
						pycodestyle = {
							enabled = false,
							ignore = {
								"E203",
							},
						},
						pylsp_mypy = { enabled = true },
					},
				},
			},
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
		-- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
		-- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
		capabilities.workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		}
		lsp_config.markdown_oxide.setup({
			capabilities = capabilities,
			on_attach = function(client, buffer)
				-- setup Markdown Oxide daily note commands
				if client.name == "markdown_oxide" then
					vim.api.nvim_create_user_command("Daily", function(args)
						local input = args.args

						vim.lsp.buf.execute_command({ command = "jump", arguments = { input } })
					end, { desc = "Open daily note", nargs = "*" })
				end
			end,
		})

		-- For Windows: use Nmap
		-- For WSL: doesn't work
		local cmd = vim.fn.has("linux") == 1 and vim.lsp.rpc.connect(vim.fn.hostname() .. ".local", 6005)
			or { "ncat", "localhost", "6005" }

		local pipe = vim.fn.has("linux") == 1 and "/tmp/godot.pipe" or [[\\.\pipe\godot.pipe]]

		lsp_config.gdscript.setup({
			cmd = cmd,
			filetypes = { "gd", "gdscript", "gdignore" },
			root_dir = require("lspconfig/util").root_pattern("project.godot", ".git"),
			on_attach = function(client, buffer)
				-- Godot external editor settings:
				-- Exec Path: nvim
				-- Linux - Exec Flags: --server /tmp/godot.pipe --remote-send "<esc>:n {file}<CR>:call cursor({line},{col})<CR>"
				-- Windows - Exec Flags: --server "\\\\.\\pipe\\godot.pipe" --remote-send "<C-\><C-N>:n {file}<CR>:call cursor({line},{col})<CR>"
				if vim.fn.has("linux") == 1 then
					vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
				else
					vim.api.nvim_command([[echo serverstart(']] .. pipe .. [[')]])
				end
			end,
		})
	end,
}
