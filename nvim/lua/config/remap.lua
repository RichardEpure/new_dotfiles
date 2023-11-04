vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("v", "<leader>h", [[:sort<CR>]])
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set({ "n", "v" }, "&", "g_")
vim.keymap.set({ "n", "v" }, "£", "0")

if vim.g.vscode then
    local comment = {
        selected = function()
            vim.fn.VSCodeNotify("editor.action.commentLine")
        end
    }

    local file = {
        new = function()
            vim.fn.VSCodeNotify("workbench.explorer.fileView.focus")
            vim.fn.VSCodeNotify("explorer.newFile")
        end,

        save = function()
            vim.fn.VSCodeNotify("workbench.action.files.save")
        end,

        saveAll = function()
            vim.fn.VSCodeNotify("workbench.action.files.saveAll")
        end,

        close = function()
            vim.fn.VSCodeNotify("workbench.action.closeActiveEditor")
        end,

        format = function()
            vim.fn.VSCodeNotify("editor.action.formatDocument")
        end,

        showInExplorer = function()
            vim.fn.VSCodeNotify("workbench.files.action.showActiveFileInExplorer")
        end,

        rename = function()
            vim.fn.VSCodeNotify("workbench.files.action.showActiveFileInExplorer")
            vim.fn.VSCodeNotify("renameFile")
        end
    }

    local action = {
        quickOpen = function()
            vim.fn.VSCodeNotify("workbench.action.quickOpen")
        end,

        showCommands = function()
            vim.fn.VSCodeNotify("workbench.action.showCommands")
        end,

        toggleSidebarVisibility = function()
            vim.fn.VSCodeNotify("workbench.action.toggleSidebarVisibility")
        end,

        toggleCenteredLayout = function()
            vim.fn.VSCodeNotify("workbench.action.toggleCenteredLayout")
        end,

        focusLeftGroup = function()
            vim.fn.VSCodeNotify("workbench.action.focusLeftGroup")
        end,

        focusRightGroup = function()
            vim.fn.VSCodeNotify("workbench.action.focusRightGroup")
        end,

        focusAboveGoup = function()
            vim.fn.VSCodeNotify("workbench.action.focusAboveGroup")
        end,

        focusBelowGroup = function()
            vim.fn.VSCodeNotify("workbench.action.focusBelowGroup")
        end,

        navigateLeft = function()
            vim.fn.VSCodeNotify("workbench.action.navigateLeft")
        end,

        navigateRight = function()
            vim.fn.VSCodeNotify("workbench.action.navigateRight")
        end,

        navigateAbove = function()
            vim.fn.VSCodeNotify("workbench.action.navigateUp")
        end,

        navigateBelow = function()
            vim.fn.VSCodeNotify("workbench.action.navigateDown")
        end,

        moveEditorLeftInGroup = function()
            vim.fn.VSCodeNotify("workbench.action.moveEditorLeftInGroup")
        end,

        moveEditorRightInGroup = function()
            vim.fn.VSCodeNotify("workbench.action.moveEditorRightInGroup")
        end,

        gotoTab = function(index)
            vim.fn.VSCodeNotify("workbench.action.openEditorAtIndex" .. index)
        end,

        navigateForwardInEditLocations = function()
            vim.fn.VSCodeNotify("workbench.action.navigateForwardInEditLocations")
        end,

        navigatePreviousInEditLocations = function()
            vim.fn.VSCodeNotify("workbench.action.navigatePreviousInEditLocations")
        end,
    }

    local view = {
        explorer = function()
            vim.fn.VSCodeNotify("workbench.view.explorer")
        end
    }

    local markdown = {
        preview = function()
            vim.fn.VSCodeNotify("markdown.showPreview")
        end,

        showPreviewToSide = function()
            vim.fn.VSCodeNotify("markdown.showPreviewToSide")
        end
    }

    vim.g.mapleader = " "
    vim.keymap.set({ "n", "v" }, "<leader>/", comment.selected)

    vim.keymap.set({ "n", "v" }, "<leader>w", file.save)
    vim.keymap.set({ "n", "v" }, "<leader>q", file.close)
    vim.keymap.set({ "n", "v" }, "<leader>ea", file.showInExplorer)

    vim.keymap.set({ "n", "v" }, "<leader>ff", action.quickOpen)
    vim.keymap.set({ "n", "v" }, "<leader>fc", action.showCommands)
    vim.keymap.set({ "n", "v" }, "<leader>eq", action.toggleSidebarVisibility)
    vim.keymap.set({ "n", "v" }, "<leader>nn", action.toggleCenteredLayout)
    vim.keymap.set({ "n", "v" }, "<C-h>", action.navigateLeft)
    vim.keymap.set({ "n", "v" }, "<C-j>", action.navigateBelow)
    vim.keymap.set({ "n", "v" }, "<C-k>", action.navigateAbove)
    vim.keymap.set({ "n", "v" }, "<C-l>", action.navigateRight)

    vim.keymap.set({ "n", "v" }, "<leader>ee", view.explorer)

    vim.keymap.set({ "n", "v" }, "<leader>t", action.moveEditorRightInGroup)
    vim.keymap.set({ "n", "v" }, "<leader>T", action.moveEditorLeftInGroup)

    vim.keymap.set({ "n", "v" }, "<leader>mm", markdown.preview)
    vim.keymap.set({ "n", "v" }, "<leader>mv", markdown.showPreviewToSide)

    vim.keymap.set({ "n", "v" }, "<leader>o", action.navigatePreviousInEditLocations)
    vim.keymap.set({ "n", "v" }, "<leader>i", action.navigateForwardInEditLocations)
    vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<;-r><C-w>]])

    for i = 1, 9 do
        vim.keymap.set({ 'n', 'v' }, "<leader>" .. i, function()
            action.gotoTab(i)
        end)
    end
else
    -- ordinary Neovim
    vim.keymap.set("n", "<leader>w", vim.cmd.w, { desc = "Save current buffer" })
    vim.keymap.set("n", "<leader><C-q>", [[:tabclose<CR>]], { desc = "Close current tab" })
    vim.keymap.set("n", "<C-h>", "<C-w>h")
    vim.keymap.set("n", "<C-j>", "<C-w>j")
    vim.keymap.set("n", "<C-k>", "<C-w>k")
    vim.keymap.set("n", "<C-l>", "<C-w>l")
    vim.keymap.set("n", "-", "<C-w><")
    vim.keymap.set("n", "+", "<C-w>>")
    vim.keymap.set("n", "<C-->", "<C-w>-")
    vim.keymap.set("n", "<C-+>", "<C-w>+")
    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    vim.keymap.set("n", "n", "nzzzv")
    vim.keymap.set("n", "N", "Nzzzv")
    vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
    vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
    vim.keymap.set("n", "<leader>ot", [[:!wt.exe -d "%:p:h"<CR>]], { desc = "Open wt in this file's directory" })
    vim.keymap.set("n", "<leader>oe", [[:!explorer.exe "%:p:h"<CR>]], { desc = "Open explorer in this file's directory" })
    vim.keymap.set("n", "<leader>opt", [[:!wt.exe -d .<CR>]], { desc = "Open wt at cwd" })
    vim.keymap.set("n", "<leader>ope", [[:!explorer.exe .<CR>]], { desc = "Open explorer at cwd" })
    vim.keymap.set("n", "<C-w>t", [[:tabe %<CR>]], { desc = "Open current buffer in a new tab" })

    vim.api.nvim_create_user_command("Redir",
        [[:redir @" | silent <args> | redir END | enew | put"]],
        { nargs = 1, }
    )

    if vim.g.neovide then
        vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { desc = "Copy to clipboard" })
        vim.keymap.set({ "n", "v" }, "<C-x>", '"+x', { desc = "Cut to clipboard" })
        vim.keymap.set({ "n", "v" }, "<C-v>", '"+gP', { desc = "Paste from clipboard" })
        vim.keymap.set({ "i", 't' }, "<C-v>", '<esc>"+gp', { desc = "Paste from clipboard" })
    end
end

