require('telescope').setup {
  pickers = {
    find_files = {
      hidden = true,
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
      disable_devicons = true,
      theme = "dropdown",
    },
    treesitter = { theme = "dropdown", previewer = false },
    lsp_code_actions = { theme = "dropdown", previewer = false }
  }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
