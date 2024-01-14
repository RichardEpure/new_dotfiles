local is_neovim = require('config.utils').is_neovim

return {
    'echasnovski/mini.clue',
    version = false,
    enabled = is_neovim,
    config = function()
        local miniclue = require('mini.clue')
        miniclue.setup({
            triggers = {
                -- Leader triggers
                { mode = 'n', keys = '<Leader>' },
                { mode = 'x', keys = '<Leader>' },

                -- Built-in completion
                { mode = 'i', keys = '<C-x>' },

                -- `g` key
                { mode = 'n', keys = 'g' },
                { mode = 'x', keys = 'g' },

                -- Marks
                { mode = 'n', keys = "'" },
                { mode = 'n', keys = '`' },
                { mode = 'x', keys = "'" },
                { mode = 'x', keys = '`' },

                -- Registers
                { mode = 'n', keys = '"' },
                { mode = 'x', keys = '"' },
                { mode = 'i', keys = '<C-r>' },
                { mode = 'c', keys = '<C-r>' },

                -- Window commands
                { mode = 'n', keys = '<C-w>' },

                -- `z` key
                { mode = 'n', keys = 'z' },
                { mode = 'x', keys = 'z' },

                { mode = 'n', keys = ']' },
                { mode = 'x', keys = ']' },
                { mode = 'n', keys = '[' },
                { mode = 'x', keys = '[' },
            },

            clues = {
                -- Enhance this by adding descriptions for <Leader> mapping groups
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),

                -- Telescope
                { mode = 'n', keys = '<Leader>f',  desc = '+Find' },
                { mode = 'x', keys = '<Leader>f',  desc = '+Find' },
                { mode = 'n', keys = '<Leader>fq', desc = '+QuickFix' },

                -- Dap
                { mode = 'n', keys = '<Leader>l',  desc = '+Dap' },
                { mode = 'x', keys = '<Leader>l',  desc = '+Dap' },

                -- Refactoring
                { mode = 'n', keys = '<Leader>r',  desc = '+Refactor' },
                { mode = 'x', keys = '<Leader>r',  desc = '+Refactor' },

                -- No Neck Pain
                { mode = 'n', keys = '<Leader>n',  desc = '+NoNeckPain' },
                -- { mode = 'n', keys = '<Leader>nn', desc = 'Toggle NoNeckPain' },
                -- { mode = 'n', keys = '<Leader>n-', desc = 'Decrease buffer width' },
                -- { mode = 'n', keys = '<Leader>n=', desc = 'Increase buffer width' },

                -- Git
                { mode = 'n', keys = '<Leader>g',  desc = '+Git' },

                -- Neogen
                { mode = 'n', keys = '<Leader>ja', desc = '+Annotate' },

                -- ToggleTerm
                { mode = 'n', keys = '<Leader>t',  desc = '+Terminal' },

                -- ISwap
                { mode = 'n', keys = '<Leader>i',  desc = '+ISwap' },
                { mode = 'n', keys = '<Leader>in', desc = '+Swap node' },

                -- Other
                { mode = 'n', keys = '<Leader>o',  desc = '+Open' },
                { mode = 'n', keys = '<Leader>op', desc = '+Open at cwd' },
                { mode = 'n', keys = '<Leader>j',  desc = '+More Mappings' },
                { mode = 'x', keys = '<Leader>j',  desc = '+More Mappings' },
                { mode = 'n', keys = '<Leader>jc', desc = '+Copy stuff' },
                { mode = 'n', keys = '<Leader>js', desc = '+String manipulation' },
                { mode = 'x', keys = '<Leader>js', desc = '+String manipulation' },
            },
        })
    end
}

