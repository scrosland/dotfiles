"
" A simple statusline with support for in/active windows.
" Colour scheme based on the airline 'sol' theme.
"
" Active window:
"+-----------------------------------------------------------------------------+
"| A | B | C ... [gutter]                                          | X | Y | Z |
"+-----------------------------------------------------------------------------+
"
" Inactive window:
"+-----------------------------------------------------------------------------+
"| B | C ... [gutter]                                              | X | Y | Z |
"+-----------------------------------------------------------------------------+
"
"  section  contents
"  ---------------------------------------------------------------------------
"  A        mode, paste, spell
"  B        wrap mode, local part-b function
"  C        filename
"  Gutter   readonly, modified
"  X        filetype
"  Y        fileencoding, fileformat (if not utf8 or unix)
"  Z        percentage, line number, column number

" see the list at 'help mode()'
let g:statusline_mode_map = {
    \ 'n'  : 'NORMAL',  'no' : 'NORMAL',
    \ 'v'  : 'VISUAL',  'V'  : 'VISUAL',  "\<C-V>" : 'VISUAL',
    \ 's'  : 'SELECT',  'S'  : 'SELECT',  "<\C-S>" : 'SELECT',
    \ 'i'  : 'INSERT',
    \ 'R'  : 'REPLACE', 'Rv' : 'REPLACE',
    \ 'c'  : 'COMMAND', 'cv' : 'COMMAND', 'ce' : 'COMMAND',
    \ 'r'  : 'PROMPT',  'rm' : 'PROMPT',  'r?' : 'PROMPT',
    \ '!'  : 'SHELL',
    \ }

hi statusline_a         ctermfg=237 ctermbg=248 guifg=#343434 guibg=#a0a0a0
hi statusline_a_bold    term=bold cterm=bold ctermfg=237 ctermbg=248 gui=bold
hi statusline_b         ctermfg=237 ctermbg=250 guifg=#343434 guibg=#b3b3b3
hi statusline_c         ctermfg=237 ctermbg=252 guifg=#343434 guibg=#c7c7c7
hi statusline_c_mod     ctermfg=237 ctermbg=216 guifg=#343434 guibg=#ffdbc7
hi statusline_c_mod_inactive
                      \ ctermfg=203 ctermbg=251 guifg=#ff3535 guibg=#c7c7c7
hi statusline_x         ctermfg=237 ctermbg=252 guifg=#343434 guibg=#c7c7c7
hi statusline_y         ctermfg=237 ctermbg=250 guifg=#343434 guibg=#b3b3b3
hi statusline_z         ctermfg=237 ctermbg=248 guifg=#343434 guibg=#a0a0a0
hi statusline_z_bold    term=bold cterm=bold ctermfg=237 ctermbg=248 gui=bold

hi statusline_inactive  ctermfg=244 ctermbg=251 guifg=#777777 guibg=#c7c7c7

function! statusline#fenc()
  return &fileencoding == 'utf-8' ? '' : &fileencoding
endfunction

function! statusline#ff()
  return &fileformat == 'unix' ? '' : '[' . &fileformat . ']'
endfunction

function! statusline#hi(name, active)
  let l:token = '%#statusline_'
  let l:token .= a:active ? a:name : 'inactive'
  let l:token .= '#'
  return l:token
endfunction

function! statusline#section_b()
  let l:parts = []
  call add(l:parts, WrapDescribeForStatusLine())
  " Hook for .vimrc.local
  if exists('*LocalPartsForStatusLine')
    let l:parts += LocalPartsForStatusLine()
  endif
  return join(filter(l:parts, 'len(v:val)'), ' > ')
endfunction

" indexed by a:active (0: inactive, 1: active)
let s:section_c_hi = [
    \ { 'mod'   : '%#statusline_c_mod_inactive#',
      \ 'nomod' : '%#statusline_inactive#' },
    \ { 'mod'   : '%#statusline_c_mod#',
      \ 'nomod' : '%#statusline_c#' },
    \ ]

function! statusline#section_c()
  let l:name = bufname(winbufnr(winnr()))
  if empty(l:name)
    if &buftype == 'quickfix'
      let l:name = '[Quickfix]'
    elseif &buftype == 'nofile'
      let l:name = '[Scratch]'
    else
      let l:name = '[No Name]'
    endif
  else
    let l:name = fnamemodify(l:name, ':~:.')
  endif
  let l:content = ' ' . l:name . ' '
  " Gutter (readonly, modified) -- nested inside Section C for grouping
  let l:content .= (&readonly || &modifiable == 0) ? '[RO] ' : ''
  let l:content .= &modified ? '+++ ' : ''
  return l:content
endfunction

function! StatusLine(active)
  let l:statusline = ''
  "
  " Section A (mode, paste, spell)
  if a:active
    let l:statusline .= statusline#hi('a', a:active)
    let l:statusline .= '%( '
    let l:statusline .=   statusline#hi('a_bold', a:active)
    let l:statusline .=   '%{get(g:statusline_mode_map, mode(), "UNKNOWN")}'
    let l:statusline .=   statusline#hi('a', a:active)
    let l:statusline .=   '%( %{&paste ? "PASTE" : ""}%)'
    let l:statusline .=   '%( %{&spell ? "SPELL" : ""}%)'
    let l:statusline .= ' %)'
  endif
  "
  " Section B (wrap mode, local hook)
  let l:statusline .= statusline#hi('b', a:active)
  let l:statusline .= '%( %{statusline#section_b()} %)'
  "
  " Section C (filename)
  " Using the pattern from
  " https://github.com/vim/vim/issues/1697#issuecomment-380216189
  let l:statusline .= '%('
  let l:statusline .= '%<'
  let l:statusline .= s:section_c_hi[a:active].mod
  let l:statusline .= '%{ &modified ? statusline#section_c() : "" }'
  let l:statusline .= s:section_c_hi[a:active].nomod
  let l:statusline .= '%{ &modified ? "" : statusline#section_c() }'
  let l:statusline .= '%)'

  " Divider between left and right
  let l:statusline .= '%='
  "
  " Section X (filetype)
  let l:statusline .= statusline#hi('x', a:active)
  let l:statusline .= '%( %{&filetype} %)'
  "
  " Section Y (fileencoding, fileformat)
  let l:statusline .= statusline#hi('y', a:active)
  let l:statusline .= '%( %{statusline#fenc()}%{statusline#ff()} %)'
  "
  " Section Z (percentage, line number, column number)
  let l:statusline .= statusline#hi('z', a:active)
  let l:statusline .= '%( '
  let l:statusline .=   '%3p%% ' 
  let l:statusline .=   statusline#hi('z_bold', a:active)
  let l:statusline .=   '%4l'
  let l:statusline .=   statusline#hi('z', a:active) 
  let l:statusline .=   ':%3c'
  let l:statusline .= '%)'
  return l:statusline
endfunction

set laststatus=2
set statusline=%!StatusLine(1)

augroup statusline_commands
  autocmd!
  autocmd WinEnter * setlocal statusline=%!StatusLine(1)
  autocmd WinLeave * setlocal statusline=%!StatusLine(0)
augroup END
