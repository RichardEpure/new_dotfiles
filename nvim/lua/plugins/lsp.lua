local is_neovim = require("config.utils").is_neovim

return {
	"neovim/nvim-lspconfig",
	enabled = is_neovim,
	dependencies = {
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
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

		local mason_registry = require("mason-registry")

		require("mason").setup({})
		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls" },
		})

		-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
		require("neodev").setup()

		-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

		local lsp_config = require("lspconfig")
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, {
			textDocument = {
				foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				},
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				-- stuff
			end,
		})

		lsp_config.lua_ls.setup({
			capabilities = capabilities,
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

		lsp_config.intelephense.setup({
			capabilities = capabilities,
		})

		lsp_config.volar.setup({
			capabilities = capabilities,
		})

		lsp_config.cssls.setup({
			capabilities = capabilities,
		})

		lsp_config.html.setup({
			capabilities = capabilities,
		})

		lsp_config.jsonls.setup({
			capabilities = capabilities,
		})

		lsp_config.taplo.setup({
			capabilities = capabilities,
		})

		lsp_config.mesonlsp.setup({
			capabilities = capabilities,
		})

		lsp_config.gopls.setup({
			capabilities = capabilities,
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

		lsp_config.templ.setup({
			capabilities = capabilities,
		})

		local vue_typescript_plugin = require("mason-registry").get_package("vue-language-server"):get_install_path()
			.. "/node_modules/@vue/language-server"
			.. "/node_modules/@vue/typescript-plugin"

		lsp_config.ts_ls.setup({
			capabilities = capabilities,
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
			capabilities = capabilities,
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

		lsp_config.glsl_analyzer.setup({
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				-- https://github.com/nolanderc/glsl_analyzer/issues/68
				local function custom_cancel_request(client, request_id)
					-- Do nothing, effectively ignoring cancel requests
				end
				client.cancel_request = custom_cancel_request
			end,
		})

		lsp_config.clangd.setup({
			capabilities = capabilities,
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
			capabilities = capabilities,
			bundle_path = mason_registry.get_package("powershell-editor-services"):get_install_path(),
		})

		lsp_config.pylsp.setup({
			capabilities = capabilities,
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

		lsp_config.ruff.setup({
			capabilities = capabilities,
		})

		lsp_config.tinymist.setup({
			capabilities = capabilities,
		})

		lsp_config.markdown_oxide.setup({
			capabilities = vim.tbl_deep_extend("force", capabilities, {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = true,
					},
				},
			}),
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
			capabilities = capabilities,
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
