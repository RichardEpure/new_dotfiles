vim.opt.hlsearch = false

if vim.g.vscode == nil then
    vim.opt.termguicolors = true
    vim.opt.nu = true
    vim.opt.relativenumber = true

    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true

    vim.opt.smartindent = true

    vim.opt.wrap = false

    vim.opt.swapfile = false
    vim.opt.backup = false

    if vim.fn.has("linux") then
        vim.opt.undodir = os.getenv("HOME") .. "/.vim.undodir"
    else
        vim.opt.undodir = os.getenv("USERPROFILE") .. "/.vim.undodir"
    end

    vim.opt.undofile = true

    vim.opt.incsearch = true

    vim.opt.termguicolors = true

    vim.opt.scrolloff = 10
    vim.opt.signcolumn = "yes"
    vim.opt.isfname:append("@-@")

    vim.opt.updatetime = 50
end
