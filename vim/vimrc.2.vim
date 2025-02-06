" --- Basic configuration for sensible vim builds ---
"
" The rest of startup for builds of vim with sensible features.

if !has("eval")
    " This is likely to be Debian's vim-tiny or an ancient version
    " either way trying anything 'clever' would be pointless.
    throw "Missing 'eval' feature - bailing out!"
    finish
endif

syntax on
filetype on
filetype plugin on
filetype indent off

" A place for my global config
let g:user = {}

" --- System Detection ---

function! s:detect_wsl()
    let l:release = trim(system('uname -r'))
    if l:release =~ '-Microsoft$' || l:release =~ 'microsoft-standard-WSL2$'
        return 1
    endif
    return 0
endfunction

let g:user.system = {}
let g:user.system.mac = (has("mac") || has("macunix") || has("gui_macvim"))
let g:user.system.unix = has("unix")
let g:user.system.windows = (has("win32") || has("win64"))
let g:user.system.wsl = (!g:user.system.mac && !g:user.system.windows && s:detect_wsl())
let g:user.system.type = g:user.system.mac ? 'mac'
                \ : g:user.system.windows ? 'windows'
                \ : g:user.system.wsl ? 'wsl'
                \ : 'unix'

function! s:find_directories(choices)
    return filter(copy(a:choices), 'isdirectory(expand(v:val))')
endfunction

function! s:source_if_readable(filename)
    let l:filename = expand(a:filename)
    if filereadable(l:filename)
        execute "source " . l:filename
        return 1
    endif
    return 0
endfunction

" --- MS Windows ---

if g:user.system.windows
    " Get the system defaults
    call s:source_if_readable("$VIMRUNTIME/mswin.vim")

    " Find a temporary directory for swap files.
    function! s:configure_temp_directory()
        let l:defaults = ['c:\tmp', 'c:\temp']
        let l:directories = s:find_directories(l:defaults)
        if empty(l:directories)
            echom "Cannot find any of " .
                    \ string(l:defaults) . ": directory is unset!"
            5 sleep
        else
            let &directory=join(l:directories, ",")
        end
    endfunction
    call s:configure_temp_directory()

    " Don't save viminfo files
    set viminfo=""
endif

" --- Value added settings (spelling, tags, etc.) ---

set background=light
set mousehide
" behaviour is overridden in gvimrc
behave xterm

if executable("sgrep")
    set grepprg=sgrep
elseif executable("rg")
    set grepprg=rg\ --vimgrep
endif

" Clipboard, select mode and mouse settings need to be after sourcing mswin.vim
if !has("mac")
    " On macOS autoselect usually results in me pasting the wrong thing.
    " Instead use Option-click to cut/paste from/to the system clipboard.
    set clipboard+=autoselect
endif
" Using unnamed allows easy yank into the clipboard.
" Counterintuitively in iTerm2 this requires _unchecking_
" the "Applications in terminal may access clipboard" option in
"   Preferences > General > Selection
" That setting enables iTerm's special ANSI escape sequences for clipboard
" integration which isn't what is wanted. See:
"   https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
set clipboard+=unnamed
" Disable the awful Select mode
set selectmode=""
" Mouse in normal, visual, command and prompts.
" Visual has to be included otherwise drag to select does not work.
set mouse=nvcr

" Digraphs - CTRL-K plus two characters
if has("digraphs") && has("multi_byte")
    " EN DASH U+2013
    digraphs n- 8211
    " EM DASH U+2014
    digraphs m- 8212
endif

if has("wildmenu")
    " Improved wildcard expansion.
    " First <tab> populates with longest match, and pops up a menu if needed.
    " Second <tab> selects first thing in menu.
    " <C-N> and <C-P> navigate the menu.
    if exists("+wildignorecase")
        set wildignorecase
    endif
    let s:suffixes = [
                \ ".a",
                \ ".d2",
                \ ".dll",
                \ ".exe",
                \ ".lib",
                \ ".o",
                \ ".so",
                \ ]
    for s:suffix in s:suffixes
        execute 'set wildignore+=*' . s:suffix
    endfor
    set wildmenu
    set wildmode=longest:full,full
endif

" Spell checking
set spelllang=en_gb
if exists('+spelloptions')
    " patch-8.2.0953 adds spelloptions with support for CamelCase words
    " https://github.com/vim/vim/commit/362b44bd4aa87a2aef0f8fd5a28d68dd09a7d909
    set spelloptions+=camel
end
set spellsuggest=5
if g:user.system.windows
    set spellfile=~/vimfiles/spellfile.utf-8.add
else
    set spellfile=~/.vim/spellfile.utf-8.add
end
" Toggle spell checking with <F7>
nnoremap <silent> <F7> :setlocal spell!<CR><Bar>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

" Tags files may not be in current directory
if has('path_extra')
    " The ; has special significance see 'help file-searching'.
    setglobal tags-=./tags tags-=./tags; tags^=./tags;
else
    set tags=./tags,./../tags,./../../tags,./../../../tags,tags
end

if strlen($VIM_CDPATH)
    let &cdpath = substitute(substitute($VIM_CDPATH, ':', ',', 'g'), '^.,', ',', '')
endif

" This works with &formatprg to format the file. The previous version used
" &equalprg which is rarely set to something useful.
command! -nargs=0 -bar ReformatFile normal gggqG

" Add a :Shell command to run a command and read the stdout into a new buffer
command! -nargs=+ -complete=shellcmd Shell 
            \ enew |
            \ setlocal buftype=nofile bufhidden=hide noswapfile |
            \ r !<args>

if has("terminal")
    command! -nargs=* -complete=shellcmd Term rightbelow term ++noclose <args>
    command! -nargs=* -complete=shellcmd Vterm vertical rightbelow term ++noclose <args>
endif

" --- Wrap mode ---

" Horizontal scrolling for nowrap windows
" See https://stackoverflow.com/a/59950870
" An alternative would be to define a sidescroll submode with
" https://github.com/kana/vim-submode
nnoremap <silent> zh :call HorizontalScrollMode('h')<CR>
nnoremap <silent> zl :call HorizontalScrollMode('l')<CR>
nnoremap <silent> zH :call HorizontalScrollMode('H')<CR>
nnoremap <silent> zL :call HorizontalScrollMode('L')<CR>
set sidescroll=1

function! HorizontalScrollMode(call_char)
    if &wrap
        return
    endif
    echohl Title
    let l:typed_char = a:call_char
    while index( [ 'h', 'l', 'H', 'L' ], l:typed_char ) != -1
        execute 'normal! z'.l:typed_char
        redrawstatus
        echon '-- Horizontal scrolling mode (h/l/H/L) --'
        let l:typed_char = nr2char(getchar())
    endwhile
    echohl None | echo '' | redrawstatus
endfunction

function! s:no_wrap()
    setlocal nowrap nolinebreak
    setlocal textwidth=0
endfunction
command! -nargs=0 WrapNone call s:no_wrap()

function! s:soft_wrap_enable()
    setlocal wrap linebreak
    setlocal textwidth=0
    " fix up motion keys to move between displayed lines, not real lines
    " ... beginning and end of line ...
    nnoremap <buffer> <silent> $ g$
    nnoremap <buffer> <silent> 0 g0
    vnoremap <buffer> <silent> $ g$
    vnoremap <buffer> <silent> 0 g0
    " ... up and down lines ...
    nnoremap <buffer> <silent> j gj
    nnoremap <buffer> <silent> k gk
    vnoremap <buffer> <silent> j gj
    vnoremap <buffer> <silent> k gk
endfunction
command! -nargs=0 WrapSoft call s:soft_wrap_enable()

function! s:hard_wrap_enable(column)
    call s:wrap_default()
    execute 'setlocal textwidth=' . (a:column > 0 ? a:column : 74)
endfunction
command! -count WrapHard call s:hard_wrap_enable(<count>)

function! s:wrap_default()
    setlocal wrap< linebreak<
    setlocal textwidth<
    try
        " fix up motion keys to move up down displayed lines in the buffer
        " ... beginning and end of line ...
        nunmap <buffer> $
        nunmap <buffer> 0
        vunmap <buffer> $
        vunmap <buffer> 0
        " ... up and down lines ...
        nunmap <buffer> j
        nunmap <buffer> k
        vunmap <buffer> j
        vunmap <buffer> k
    catch
    endtry
endfunction
command! -nargs=0 WrapDefault call s:wrap_default()

function! WrapDescribeForStatusLine()
    return (&wrap && &linebreak) ? "soft"
                \ : (&wrap && &fo =~ "t" && &tw != 0) ? "tw=" . &textwidth
                \ : ""
endfunction

" --- File type handling ---

function! s:set_shift_width(width)
    let &l:softtabstop = a:width
    let &l:shiftwidth = a:width
endfunction
command! -nargs=1 SetShiftWidth call s:set_shift_width(<q-args>)

if has("autocmd")
    " Open the quickfix or location line window after any grep command
    augroup quickfix_mapping
        autocmd!
        autocmd QuickFixCmdPost grep*,*[^l]grep*,make* copen | redraw!
        autocmd QuickFixCmdPost *lgrep* lopen | redraw!
    augroup end
endif " has autocmd

" --- other vimrc files ---

let s:vimrc = resolve(expand("<sfile>:p"))
let s:scripts = resolve(fnamemodify(s:vimrc, ":h"))
execute 'set rtp^=' . s:scripts
" Force plugins.vim to load now so we can rely on them in other plugin scripts
runtime! plugin/plugins.vim
execute 'set rtp+=' . s:scripts . '/after'

let s:ghostty = resolve(expand("$GHOSTTY_RESOURCES_DIR/../vim/vimfiles"))
if isdirectory(s:ghostty)
    execute 'set rtp+=' . s:ghostty
endif

" --- local options ---

" Add local options to an after/ plugin called local.vim
"   Unix: ~/.vim/after/plugin/local.vim
"   Windows: $HOME/vimfiles/after/plugin/local.vim or $USERPROFILE/...
if g:user.system.windows
    set rtp+=$USERPROFILE/vimfiles/after
endif
