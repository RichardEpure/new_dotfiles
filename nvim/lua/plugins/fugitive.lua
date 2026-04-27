local utils = require("config.utils")

return {
	"tpope/vim-fugitive",
	enabled = utils.is_neovim,
	config = function()
		local opencode = require("config.opencode")
		local augroup = vim.api.nvim_create_augroup("fugitive_ai_commit", { clear = true })

		local function notify(message, level)
			vim.notify(message, level or vim.log.levels.INFO, { title = "Git Commit AI" })
		end

		---@return string
		local function get_worktree()
			local ok, worktree = pcall(vim.fn.FugitiveWorkTree)
			if ok and type(worktree) == "string" and worktree ~= "" then
				return worktree
			end

			return vim.fn.getcwd()
		end

		---@param args string[]
		---@param cwd string
		---@param callback fun(result: vim.SystemCompleted)
		local function git(args, cwd, callback)
			vim.system(
				vim.list_extend({ "git" }, args),
				{ cwd = cwd, text = true },
				vim.schedule_wrap(function(result)
					callback(result)
				end)
			)
		end

		---@param diffstat string
		---@param diff string
		---@param truncated boolean
		---@return string
		local function build_commit_prompt(diffstat, diff, truncated)
			local prompt = [[Generate a git commit message for the staged changes below.

Requirements:
- Return only the commit message text.
- Use imperative mood.
- Keep the first line concise and under 72 characters.
- Include a blank line and a short body only if it adds useful context.
- Do not use markdown fences.
- Do not explain your reasoning.
- Do not run commands or edit files.]]

			if truncated then
				prompt = prompt .. "\n- The diff was truncated, so summarize from the available context."
			end

			return prompt .. "\n\nStaged diffstat:\n" .. diffstat .. "\n\nStaged diff:\n" .. diff
		end

		---@param bufnr? integer
		local function generate_commit_message(bufnr)
			bufnr = bufnr or vim.api.nvim_get_current_buf()

			local cwd = get_worktree()
			git({ "diff", "--cached", "--stat", "--no-color" }, cwd, function(stat_result)
				if stat_result.code ~= 0 then
					notify(
						utils.error_with_fallback(stat_result, "Failed to read staged diffstat"),
						vim.log.levels.ERROR
					)
					return
				end

				git({ "diff", "--cached", "--no-ext-diff", "--no-color" }, cwd, function(diff_result)
					if diff_result.code ~= 0 then
						notify(
							utils.error_with_fallback(diff_result, "Failed to read staged diff"),
							vim.log.levels.ERROR
						)
						return
					end

					local diff = diff_result.stdout or ""
					if diff:match("^%s*$") then
						notify("No staged changes found", vim.log.levels.WARN)
						return
					end

					local max_diff_chars = 120000
					local truncated = #diff > max_diff_chars
					if truncated then
						diff = diff:sub(1, max_diff_chars)
					end

					opencode.generate(build_commit_prompt(stat_result.stdout or "", diff, truncated), {
						bufnr = bufnr,
						cwd = cwd,
						insert = {
							strategy = "replace_until_comment",
							replace_until_comment = {
								confirm_replace = "Replace existing commit message?",
								confirm_replace_changed = "Commit message changed while OpenCode was running. Replace it?",
							},
						},
						title = "Git commit message",
					})
				end)
			end)
		end

		vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })

		vim.api.nvim_create_autocmd("FileType", {
			group = augroup,
			pattern = "gitcommit",
			desc = "Configure OpenCode commit message generation",
			callback = function(event)
				vim.api.nvim_buf_create_user_command(event.buf, "GitCommitAI", function()
					generate_commit_message(event.buf)
				end, { desc = "Generate commit message with OpenCode" })

				vim.keymap.set("n", "<leader>gm", function()
					generate_commit_message(event.buf)
				end, { buffer = event.buf, desc = "Generate commit message" })
			end,
		})
	end,
}
