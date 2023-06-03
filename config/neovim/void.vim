set background=dark

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name='void'

hi Whitespace ctermfg=240 guifg=Grey35
hi ColorColumn ctermbg=235 guibg=Grey15
hi Pmenu ctermfg=0 ctermbg=234 guibg=Grey11
hi PmenuSel ctermfg=236 ctermbg=0 guibg=Grey19
hi CursorLine cterm=underline guibg=Grey15
hi CursorColumn ctermbg=236 guibg=Grey19
hi Visual ctermbg=236 guibg=Grey19
