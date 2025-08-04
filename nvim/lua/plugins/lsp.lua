local is_neovim = require("config.utils").is_neovim

return {
	"neovim/nvim-lspconfig",
	enabled = is_neovim,
	dependencies = {
		{ "mason-org/mason.nvim" },
		{ "mason-org/mason-lspconfig.nvim" },
		{ "folke/neodev.nvim" },
		{ "folke/neoconf.nvim" },
	},
	config = function()
		-- if vim.lsp.inlay_hint then
		-- 	vim.lsp.inlay_hint.enable(true, { 0 })
		-- end

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

		local disabled_servers = {}

		require("mason").setup({})
		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls" },
			automatic_enable = {
				exclude = disabled_servers,
			},
		})

		-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
		require("neodev").setup()

		-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

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
				vim.keymap.set("n", "gl", function()
					vim.diagnostic.open_float()
				end)
			end,
		})

		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					},
					completion = {
						callSnippet = "Replace",
					},
					hint = {
						enable = true,
					},
				},
			},
		})

		vim.lsp.config("intelephense", {
			capabilities = capabilities,
		})

		vim.lsp.config("cssls", {
			capabilities = capabilities,
		})

		vim.lsp.config("html", {
			capabilities = capabilities,
		})

		vim.lsp.config("jsonls", {
			capabilities = capabilities,
		})

		vim.lsp.config("taplo", {
			capabilities = capabilities,
		})

		vim.lsp.config("mesonlsp", {
			capabilities = capabilities,
		})

		vim.lsp.config("nginx_language_server", {
			capabilities = capabilities,
		})

		vim.lsp.config("dockerls", {
			capabilities = capabilities,
		})

		vim.lsp.config("terraformls", {
			capabilities = capabilities,
		})

		vim.lsp.config("ansiblels", {
			capabilities = capabilities,
		})

		vim.lsp.config("yamlls", {
			capabilities = capabilities,
		})

		vim.lsp.config("gopls", {
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

		vim.lsp.config("templ", {
			capabilities = capabilities,
		})

		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.expand(
							"$MASON/packages/vue-language-server/node_modules/@vue/language-server"
						),
						languages = { "vue" },
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

		vim.lsp.config("vue_ls", {
			capabilities = capabilities,
			init_options = {
				vue = {
					hybridMode = true,
				},
			},
			settings = {
				typescript = {
					inlayHints = {
						enumMemberValues = {
							enabled = true,
						},
						functionLikeReturnTypes = {
							enabled = true,
						},
						propertyDeclarationTypes = {
							enabled = true,
						},
						parameterTypes = {
							enabled = true,
							suppressWhenArgumentMatchesName = true,
						},
						variableTypes = {
							enabled = true,
						},
					},
				},
			},
		})

		vim.lsp.config("rust_analyzer", {
			capabilities = capabilities,
			settings = {
				["rust-analyzer"] = {
					checkOnSave = true,
					check = {
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

		vim.lsp.config("glsl_analyzer", {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				-- https://github.com/nolanderc/glsl_analyzer/issues/68
				local function custom_cancel_request(client, request_id)
					-- Do nothing, effectively ignoring cancel requests
				end
				client.cancel_request = custom_cancel_request
			end,
		})

		vim.lsp.config("clangd", {
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

		vim.lsp.config("powershell_es", {
			capabilities = capabilities,
			bundle_path = vim.fn.expand("$MASON/packages/powershell-editor-services"),
		})

		vim.lsp.config("pylsp", {
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

		vim.lsp.config("ruff", {
			capabilities = capabilities,
		})

		vim.lsp.config("tinymist", {
			capabilities = capabilities,
		})

		vim.lsp.config("markdown_oxide", {
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

		vim.lsp.config("gdscript", {
			capabilities = capabilities,
			cmd = cmd,
			filetypes = { "gd", "gdscript", "gdignore" },
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
