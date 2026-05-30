-- Making diagnostics prettier
-- require("trouble").setup {
--   padding = false,
-- }

-- require("fidget").setup{}

-- TODO comments
require("todo-comments").setup {}

-- require'nvim-web-devicons'.setup {}

vim.diagnostic.config({
  virtual_text = { current_line = true }
})

vim.api.nvim_set_hl(0, "Comment", { fg = "#999999"})
vim.api.nvim_set_hl(0, "@comment", { link = "Comment"})

print("Good day, SEKUN.")
