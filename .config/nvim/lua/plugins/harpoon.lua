return {
    'theprimeagen/harpoon',
    enabled = neovim,
    config = function()
        require("harpoon").setup {}
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>z", mark.add_file)
        vim.keymap.set("n", "<C-z>", ui.toggle_quick_menu)

        vim.keymap.set("n", "<A-1>", function() ui.nav_file(1) end)
        vim.keymap.set("n", "<A-2>", function() ui.nav_file(2) end)
        vim.keymap.set("n", "<A-3>", function() ui.nav_file(3) end)
        vim.keymap.set("n", "<A-4>", function() ui.nav_file(4) end)
    end
}