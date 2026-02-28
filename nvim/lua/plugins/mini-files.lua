local is_neovim = require("config.utils").is_neovim

return {
	"echasnovski/mini.files",
	version = false,
	config = function()
		local MiniFiles = require("mini.files")

		MiniFiles.setup({
			options = {
				use_as_default_explorer = false,
			},
		})

		local map_split = function(buf_id, lhs, direction)
			local rhs = function()
				-- Make new window and set it as target
				local new_target_window
				vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
					vim.cmd(direction .. " split")
					new_target_window = vim.api.nvim_get_current_win()
				end)

				MiniFiles.set_target_window(new_target_window)
			end

			-- Adding `desc` will result into `show_help` entries
			local desc = "Split " .. direction
			vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id
				-- Tweak keys to your liking
				map_split(buf_id, "gs", "belowright horizontal")
				map_split(buf_id, "gv", "belowright vertical")
			end,
		})

		local files_set_cwd = function(path)
			-- Works only if cursor is on the valid file system entry
			local cur_entry_path = MiniFiles.get_fs_entry().path
			local cur_directory = vim.fs.dirname(cur_entry_path)
			vim.fn.chdir(cur_directory)
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				vim.keymap.set("n", "g~", files_set_cwd, { buffer = args.data.buf_id })
			end,
		})

		local minifiles_toggle = function(path)
			if not MiniFiles.close() then
				MiniFiles.open(path)
			end
		end

		vim.keymap.set("n", "<leader>e", function()
			minifiles_toggle(vim.fn.expand("%:."))
		end, {
			desc = "Open file explorer at current buffer path",
			silent = true,
		})

		vim.keymap.set("n", "<leader>E", function()
			minifiles_toggle()
		end, {
			desc = "Open file explorer at root of cwd",
			silent = true,
		})

		vim.keymap.set("n", "<leader><C-e>", function()
			MiniFiles.open(MiniFiles.get_latest_path())
		end, { desc = "Open file explorer at the last path" })

		local function get_path(obj, path)
			local current = obj
			for _, key in ipairs(path) do
				if current[key] == nil then
					return nil
				end
				current = current[key]
			end
			return current
		end

		local handle_lsp_rename = function(client, args)
			if get_path(client, { "server_capabilities", "workspace", "fileOperations", "willRename" }) == nil then
				return
			end

			local success, resp = pcall(function()
				return client:request_sync("workspace/willRenameFiles", {
					files = {
						{
							oldUri = vim.uri_from_fname(args.data.from),
							newUri = vim.uri_from_fname(args.data.to),
						},
					},
				}, 10000)
			end)

			if success and resp and resp.result ~= nil then
				vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
			end
		end

		-- Integrate with LSP
		vim.api.nvim_create_autocmd("User", {
			pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
			callback = function(args)
				for _, client in ipairs(vim.lsp.get_clients({ method = "workspace/willRenameFiles" })) do
					handle_lsp_rename(client, args)
				end
			end,
		})

		vim.g.loaded_netrwPlugin = 1
	end,
	enabled = is_neovim,
}
