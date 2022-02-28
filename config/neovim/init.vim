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

" <leader>, by default is the backslash key.
" So to find_files, be in normal mode, and type:
" \ff
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fm <cmd>Telescope man_pages<cr>

set colorcolumn=80

tnoremap <esc> <C-\><C-N>

set list
set listchars=lead:·,trail:·,tab:>-

let g:airline_theme='base16_gruvbox_dark_medium'

" To hide the statusline
set noshowmode

nmap <esc> :noh <CR>

