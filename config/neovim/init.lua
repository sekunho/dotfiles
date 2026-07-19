vim.cmd.source(vim.fs.joinpath(vim.fn.stdpath('config'), 'old.vim'))

require("my-telescope")
require("my-lsp")
require("boring")

-- Making diagnostics prettier
require("trouble").setup {
  padding = false,
}

-- TODO comments
require("todo-comments").setup {}

vim.diagnostic.config({
  virtual_text = { current_line = true }
})

print("Good day, SEKUN.")
