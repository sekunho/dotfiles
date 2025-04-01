-- Making diagnostics prettier
-- require("trouble").setup {
--   padding = false,
-- }

-- require("fidget").setup{}

-- TODO comments
require("todo-comments").setup {}

-- Tree Sitter
require("nvim-treesitter.configs").setup {
  highlight = {
    enable = false,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    -- additional_vim_regex_highlighting = true,
  },
}

-- require'nvim-web-devicons'.setup {}

-- Telescope
-- require('telescope').setup {
--   pickers = {
--     find_files = {
--       hidden = true,
--       find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
--       disable_devicons = true,
--     },
--     treesitter = { theme = "dropdown", previewer = false },
--     -- lsp_code_actions = { theme = "dropdown", previewer = false }
--   }
-- }

-- Which key
-- require("which-key").setup {
--   win = { winblend = 1 }
-- }

-- require("catppuccin").setup({
--     flavour = "mocha", -- latte, frappe, macchiato, mocha
--     background = { -- :h background
--         light = "latte",
--         dark = "mocha",
--     },
--     transparent_background = false, -- disables setting the background color.
--     show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
--     term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
--     dim_inactive = {
--         enabled = false, -- dims the background color of inactive window
--         shade = "dark",
--         percentage = 0.15, -- percentage of the shade to apply to the inactive window
--     },
--     no_italic = false, -- Force no italic
--     no_bold = false, -- Force no bold
--     no_underline = false, -- Force no underline
--     styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
--         comments = { "italic" }, -- Change the style of comments
--         conditionals = { "italic" },
--         loops = {},
--         functions = {},
--         keywords = {},
--         strings = {},
--         variables = {},
--         numbers = {},
--         booleans = {},
--         properties = {},
--         types = {},
--         operators = {},
--     },
--     color_overrides = {},
--     custom_highlights = {},
--     integrations = {
--         cmp = true,
--         gitsigns = true,
--         nvimtree = true,
--         treesitter = true,
--         notify = false,
--         mini = {
--             enabled = true,
--             indentscope_color = "",
--         },
--         -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
--     },
-- })

-- setup must be called before loading
-- vim.cmd.colorscheme "catppuccin"

print("Good day, SEKUN.")
