local home = require('config.utils').home

vim.opt.hlsearch = false

if vim.g.vscode == nil then
    vim.o.exrc = true

    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    vim.opt.termguicolors = true
    vim.opt.nu = true
    vim.opt.relativenumber = true
    vim.opt.cursorline = false

    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true

    vim.opt.smartindent = true

    vim.opt.wrap = false

    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = home .. "/.vim.undodir"

    vim.opt.undofile = true

    vim.opt.incsearch = true

    vim.opt.termguicolors = true

    vim.opt.scrolloff = 10
    vim.opt.signcolumn = "yes"
    vim.opt.isfname:append("@-@")

    vim.opt.updatetime = 50

    if vim.fn.has("win32") then
        vim.opt.shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell"
        vim.opt.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
        vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
        vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
        vim.opt.shellquote = ""
        vim.opt.shellxquote = ""
    end
end
