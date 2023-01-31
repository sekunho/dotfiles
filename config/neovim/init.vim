" Has a leading backslash cause vim will think of it as a normal
" string. Also, not a fan of the forwardslash for the leader key.
let mapleader = "\<Space>"

set mouse=a
syntax on
set number relativenumber
set hidden
set title
set encoding=utf-8

" Indents
set smartindent
set tabstop=2
set expandtab
set shiftwidth=2

" Themes
set termguicolors
set background=dark
colorscheme gruvbox

" I'm tired of dealing with separate yanks/pastes
set clipboard+=unnamedplus

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SIGN COLUMN

" Set the bg of the gutter similar to the line number column.
highlight clear SignColumn

" Show it all the time cause I hate the sudden movement when it shows
" up out of nowhere.
set signcolumn=yes

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Because I'm blind

set cursorcolumn
set cursorline

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" LSP commands
nnoremap <leader>ld <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>

" Telescope"
" <leader>, by default is the backslash key.
" So to find_files, be in normal mode, and type:
" <Space>.
nnoremap <leader>. <cmd>Telescope find_files<cr>
nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>bb <cmd>Telescope buffers<cr>
nnoremap <leader>bk <cmd>:bd <cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>
nnoremap <leader>tm <cmd>Telescope man_pages<cr>
nnoremap <leader>tk <cmd>Telescope keymaps<cr>
nnoremap <leader>pp <cmd>:lua require'telescope.builtin'.treesitter{}<cr>

" Rust
nnoremap <leader>cr <cmd>Cargo run<cr>
nnoremap <leader>cc <cmd>Cargo check<cr>
nnoremap <leader>cb <cmd>Cargo build<cr>
nnoremap <leader>cx <cmd>Cargo clean<cr>
nnoremap <leader>ct <cmd>Cargo test<cr>
nnoremap <leader>cz <cmd>:! RUST_BACKTRACE=1 cargo run<cr>

" Trouble
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

set colorcolumn=80

tnoremap <esc> <C-\><C-N>

set list
set listchars=lead:·,trail:·,tab:>-

let g:airline_theme='base16_gruvbox_dark_medium'

" To hide the statusline
set noshowmode

nmap <esc> :noh <CR>

autocmd BufWritePre * :%s/\s\+$//e

set timeoutlen=500

