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
            \ 't'  : 'TERM',
            \ '!'  : 'SHELL',
            \ }

hi statusline_a         ctermfg=237 ctermbg=248 guifg=#343434 guibg=#a0a0a0
hi statusline_a_bold    term=bold cterm=bold ctermfg=237 ctermbg=248 
            \ gui=bold guifg=#202020 guibg=#a0a0a0
hi statusline_a_paste   ctermfg=160 ctermbg=248 guifg=#d70000 guibg=#a0a0a0
hi statusline_a_spell   ctermfg=199 ctermbg=248 guifg=#ff00af guibg=#a0a0a0
hi statusline_b         ctermfg=237 ctermbg=250 guifg=#343434 guibg=#b3b3b3
hi statusline_c         ctermfg=237 ctermbg=252 guifg=#343434 guibg=#c7c7c7
hi statusline_c_mod     ctermfg=237 ctermbg=216 guifg=#343434 guibg=#ffdbc7
hi statusline_c_mod_inactive
            \ ctermfg=203 ctermbg=251 guifg=#ff3535 guibg=#c7c7c7
hi statusline_x         ctermfg=237 ctermbg=252 guifg=#343434 guibg=#c7c7c7
hi statusline_y         ctermfg=237 ctermbg=250 guifg=#343434 guibg=#b3b3b3
hi statusline_z         ctermfg=237 ctermbg=248 guifg=#343434 guibg=#a0a0a0
hi statusline_z_bold    term=bold cterm=bold ctermfg=237 ctermbg=248 
            \ gui=bold guifg=#202020 guibg=#a0a0a0

hi statusline_inactive ctermfg=244 ctermbg=251 guifg=#777777 guibg=#c7c7c7

function! s:hi(name, active)
    let l:token = '%#statusline_'
    let l:token .= a:active ? a:name : 'inactive'
    let l:token .= '#'
    return l:token
endfunction

" Test a setting like &paste and if enabled return a colourised token like
" 'PASTE' with a preceding space, otherwise return an empty string
function! s:hi_setting(setting, section, active)
    if eval('&'.a:setting) == 0
        return ''
    endif
    let l:token = s:hi(a:section.'_'.a:setting, a:active)
    let l:token .= '%( ' . toupper(a:setting) . '%)'
    return l:token
endfunction

if !exists('s:callbacks_for_b')
    let s:callbacks_for_b = []
endif

" Hook for local.vim or other vim scripts or plugins.
function! StatusLineRegisterSectionBCallback(callback)
    if type(a:callback) != type(function('printf'))
        throw 'a:callback should be a Funcref, is type ' . type(a:callback)
    endif
    " avoid duplicating a:callback in the list
    call filter(s:callbacks_for_b, 'v:val != a:callback')
    call add(s:callbacks_for_b, a:callback)
    call sort(s:callbacks_for_b)
endfunction

function! StatusLineSectionB()
    " U+00B7 == Middle Dot
    let l:separator = &fileencoding == 'utf-8' ? "\u00b7" : ','
    let l:components = map(copy(s:callbacks_for_b), 'call(v:val, [])')
    return join(filter(l:components, 'len(v:val)'), l:separator)
endfunction

function! s:LocationListOrQuickFix()
    let l:winfolist = getwininfo(win_getid())
    let l:loclist = filter(l:winfolist, 'v:val.loclist')
    return empty(l:loclist) ? '[Quickfix]' : '[Location List]'
endfunction

" indexed by a:active (0: inactive, 1: active)
let s:section_c_hi = [
            \ { 'mod'   : '%#statusline_c_mod_inactive#',
            \   'nomod' : '%#statusline_inactive#' },
            \ { 'mod'   : '%#statusline_c_mod#',
            \   'nomod' : '%#statusline_c#' },
            \ ]

function! GetBufferName(id)
    let l:name = bufname(a:id)
    if empty(l:name)
        if &buftype == 'quickfix'
            let l:name = s:LocationListOrQuickFix()
        elseif &buftype == 'nofile'
            let l:name = '[Scratch]'
        else
            let l:name = '[No Name]'
        endif
    else
        let l:name = fnamemodify(l:name, ':~:.')
    endif
    return l:name
endfunction

function! StatusLineModified()
    return &modified && &buftype != 'terminal'
endfunction

function! StatusLineReadOnly()
    return (&readonly || &modifiable == 0) && &buftype != 'terminal'
endfunction

function! StatusLineSectionC()
    let l:name = GetBufferName(winbufnr(winnr()))
    let l:content = ' ' . l:name . ' '
    if &diff
        " diff mode marker plus buffer number for simple :diffget/:diffput
        let l:content .= '§' . winbufnr(winnr()) . ' '
    endif
    " Gutter (readonly, modified) -- nested inside Section C for grouping
    let l:content .= StatusLineModified() ? '+++ ' : ''
    let l:content .= StatusLineReadOnly() ? '[RO] ' : ''
    return l:content
endfunction

function! StatusLine(active)
    let l:statusline = ''
    "
    " Section A (mode, paste, spell)
    if a:active
        let l:statusline .= s:hi('a', a:active)
        let l:statusline .= '%( '
        let l:statusline .=   s:hi('a_bold', a:active)
        let l:statusline .=   '%{get(g:statusline_mode_map, mode(), "UNKNOWN")}'
        let l:statusline .=   s:hi_setting('paste', 'a', a:active)
        let l:statusline .=   s:hi_setting('spell', 'a', a:active)
        let l:statusline .= ' %)'
    endif
    "
    " Section B (wrap mode, local hook)
    let l:statusline .= s:hi('b', a:active)
    let l:statusline .= '%( %{StatusLineSectionB()} %)'
    "
    " Section C (filename)
    " Using the pattern from
    " https://github.com/vim/vim/issues/1697#issuecomment-380216189
    let l:statusline .= '%('
    let l:statusline .= '%<'
    let l:statusline .= s:section_c_hi[a:active].mod
    let l:statusline .= '%{ StatusLineModified() ? StatusLineSectionC() : "" }'
    let l:statusline .= s:section_c_hi[a:active].nomod
    let l:statusline .= '%{ StatusLineModified() ? "" : StatusLineSectionC() }'
    let l:statusline .= '%)'

    " Divider between left and right
    let l:statusline .= '%='
    "
    " Section X (filetype)
    let l:statusline .= s:hi('x', a:active)
    let l:statusline .= '%( %{&filetype} %)'
    "
    " Section Y (fileencoding, fileformat)
    let l:statusline .= s:hi('y', a:active)
    let l:statusline .= '%( '
    let l:statusline .=   '%{&fenc == "utf-8" ? "" : &fenc}'
    let l:statusline .=   '%{&ff == "unix" ? "" : "[" . &ff . "]"}'
    let l:statusline .= ' %)'
    "
    " Section Z (percentage, line number, column number)
    let l:statusline .= s:hi('z', a:active)
    let l:statusline .= '%( '
    let l:statusline .=   '%3p%% ' 
    let l:statusline .=   s:hi('z_bold', a:active)
    let l:statusline .=   '%4l'
    let l:statusline .=   s:hi('z', a:active) 
    let l:statusline .=   ':%2c'
    let l:statusline .= ' %)'
    return l:statusline
endfunction

set laststatus=2
set statusline=%!StatusLine(1)

augroup statusline_commands
    autocmd!
    " $VIMRUNTIME/ftplugin/qf.vim unconditionally changes &statusline
    autocmd FileType qf setlocal statusline=%!StatusLine(1)
    autocmd WinEnter * setlocal statusline=%!StatusLine(1)
    autocmd WinLeave * setlocal statusline=%!StatusLine(0)
augroup END
