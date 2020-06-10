" --- Plugins (vim-plug) ---
"
"  :PlugStatus          - list configured plugins
"  :PlugInstall [name]  - install plugins
"  :PlugUpdate [name]   - update plugins to latest
"  :PlugUpgrade         - upgrade vim-plug itself
"  :PlugDiff            - View changes from previous to new
"
"  See :help vim-plug for more details.
"

if exists('g:vimrc_plugins')
    finish
endif
let g:vimrc_plugins = 1

if strlen($USERPROFILE)
    " On Windows force the plugins to be in C:\Users\<user>\vimfiles
    " to ensure that the directory is writable without needing to deal
    " with UAC, and to cope with work where $HOME is off on the network.
    let g:plugins_basedir = expand("$USERPROFILE/vimfiles")
    " deal with the non-standard location of vim-plug
    execute 'set runtimepath+=' . g:plugins_basedir
else
    " Elsewhere the plugins can live in ~/.vim as normal
    let g:plugins_basedir = expand(has('nvim') ?
                \ '~/.local/share/nvim/site' :
                \ '~/.vim')
endif

" where the plugins live
let g:plugins_bundledir = g:plugins_basedir . "/bundle"
if !isdirectory(g:plugins_bundledir)
    echoerr "Vim plugins directory is missing: " . g:plugins_bundledir
endif

" --- Plugin loader ---

try
    silent! call plug#begin(g:plugins_bundledir)
    let s:error = 0
catch /E117/
    let s:error = 1
endtry
if s:error
    " vim-plug should be in an autoload directory below g:plugins_basedir
    echoerr "Unable to find 'vim-plug' in " . g:plugins_basedir . "/autoload. "
                \. "Consider running vim -c 'call plugins#bootstrap()'"
    finish
endif

" basics
"
Plug 'tpope/vim-sensible'

" color schemes
"
Plug 'altercation/vim-colors-solarized'   " the original
Plug 'lifepillar/vim-solarized8'          " with truecolor support

" language and file format support
"
Plug 'chikamichi/mediawiki.vim', { 'for': 'mediwiki' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'peterhoeg/vim-qml', { 'for': 'qml' }
Plug 'plasticboy/vim-markdown'
Plug 'PProvost/vim-ps1', { 'for': 'ps1' }
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug (g:is_osx ? 'itspriddle/vim-marked' : 'iamcco/markdown-preview.vim'),
    \ { 'for': ['markdown', 'mkd'] }

" utilities
"
Plug 'alok/notational-fzf-vim', { 'on': 'NV' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all --no-update-rc' }
Plug 'kassio/neoterm'
Plug 'majutsushi/tagbar'
Plug 'severin-lemaignan/vim-minimap'
if executable('git')
    Plug 'tpope/vim-fugitive'
endif

" Autocompletion
"
Plug 'lifepillar/vim-mucomplete'

call plug#end()

" --- Plugin options ---

" ---- Color schemes ----

function! s:fixHighlights(yellow)
    highlight IncSearch term=reverse cterm=reverse ctermfg=Red ctermbg=NONE
    " PuTTY and Gnome Terminator treat 'Yellow' higlighting differently
    " so force 'LightYellow' for them irrespective of the argument
    let l:force_light_yellow = 0
    if !g:is_osx && !g:is_windows
        if strlen($DISPLAY) == 0 || strlen($TERMINATOR_UUID)
            let l:force_light_yellow = 1
        endif
    endif
    let l:yellow = l:force_light_yellow ? "LightYellow" : a:yellow
    let l:command = "highlight Search term=reverse cterm=reverse ctermfg=" 
                \. l:yellow . " ctermbg=Black guifg=#ffed6b guibg=#000000"
    exec l:command
endfunction

" Solarized
function! s:initSolarized()
    let g:solarized_termcolors = 256
    let g:solarized_termtrans = 1
    colorscheme solarized
    call s:fixHighlights("Yellow")
endfunction

function! s:initSolarized8()
    set termguicolors
    colorscheme solarized8_high
    call s:fixHighlights("Yellow")
endfunction

" TERM_PROGRAM=Apple_Terminal
" COLORTERM=truecolor
function! s:terminalSupportsTrueColor()
    if has("gui_running")
        return 0
    endif
    if !has("termguicolors")
        return 0
    endif
    if $TERM =~ '^screen'
        return 0
    endif
    " Not checking for Terminal.app as it seems broken.
    if $COLORTERM == "truecolor"
        return 1
    endif
    " Windows conhost.exe now supports 24-bit colour.
    if strlen($WSL)
        return 1
    endif
    " Assume ssh connections without DISPLAY forwarded have come from something
    " modern, probably a macOS client
    if strlen($SSH_CLIENT . $SSH_CONNECTION) && strlen($DISPLAY) == 0
        return 1
    endif
    return 0
endfunction

" Set initial color scheme
if s:terminalSupportsTrueColor()
    call s:initSolarized8()
else
    call s:initSolarized()
endif

" ---- Buffers and files ----

" Simple BufExplorer alternative
nnoremap <Leader>be :ls<CR>:b

" Netrw should ignore case in sort
let g:netrw_sort_options = "i"
" Use the long listing which includes time stamps and file size
let g:netrw_liststyle = 1
" Sort directories first, then files; setting this to empty would sort all
" files/directories by name alone
let g:netrw_sort_sequence = '[\/]$,*'

" Fuzzy finding with fzf
"
" :Find [PATTERN [STARTING DIRECTORY]]
" Like :find but with added fuzziness
function! s:fzf_find(bang, ...)
    let l:opts = {}
    let l:opts.options = []
    if len(a:000) > 0
        call extend(l:opts.options, ['--query', a:1])
    endif
    if len(a:000) > 1
        let l:opts.dir = a:2
    endif
    call fzf#run(fzf#wrap('find', l:opts, a:bang))
endfunction
command! -nargs=* -bang Find :call s:fzf_find(<bang>0, <f-args>)

" ---- Notes with notational-fzf-vim ----

let g:nv_search_paths = []
function! AddToNVSearchPath(dir)
    " expand(pattern, nosuffix, return-list)
    for l:dir in expand(a:dir, 0, 1)
        if isdirectory(l:dir)
            call add(g:nv_search_paths, l:dir)
        endif
    endfor
endfunction
function! RemoveFromNVSearchPath(dir)
    " expand(pattern, nosuffix, return-list)
    for l:dir in expand(a:dir, 0, 1)
        if isdirectory(l:dir)
            call filter(g:nv_search_paths, {idx,val -> val !~ l:dir})
        endif
    endfor
endfunction
call AddToNVSearchPath('$USERPROFILE/Dropbox/notes')
call AddToNVSearchPath('$HOME/Dropbox/notes')
call AddToNVSearchPath('$HOME/Desktop')

" ---- Autocompletion ----

set completeopt=""
set completeopt+=menuone
set completeopt+=longest
if has('patch-7.4.775')
    set completeopt+=noselect
    "  inoremap <expr> <c-e> mucomplete#popup_exit("\<c-e>")
    "  inoremap <expr> <c-y> mucomplete#popup_exit("\<c-y>")
    "  inoremap <expr>  <cr> mucomplete#popup_exit("\<cr>")
endif
set previewheight=5
if has('timers')
    let g:mucomplete#completion_delay = 100     " ms
    let g:mucomplete#reopen_immediately = 0
end
let g:mucomplete#enable_auto_at_startup = 0
" This adds 'tags' into upstream's default chain
let g:mucomplete#chains = {
            \ 'default' : ['path', 'omni', 'keyn', 'tags', 'dict', 'uspl'],
            \ }
" Enable short completion messages so MUcomplete can report the method
set shortmess+=c
call mucomplete#msg#set_notifications(1)    " equivalent to: MUcompleteNotify 1

" ---- Jedi for python intelligence ----

let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 2     " signatures in command line not popup
let g:jedi#smart_auto_mappings = 0      " disable auto-insertion of 'import'
let g:jedi#use_splits_not_buffers = "bottom"

" ---- ruby completion ----

let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1

" ---- Terminal management via neoterm ----

if executable("python3")
    let g:neoterm_repl_python = 'python3'
endif

let g:neoterm_autoscroll = 1
let g:neoterm_default_mod = 'belowright'
let g:neoterm_shell = &shell . ' --login'

" :TT <shell command>
" Open a new terminal if none, or reuse an existing one, and send the command.
" See https://github.com/kassio/neoterm/issues/148.
command! -range=0 -nargs=+ -complete=shellcmd TT
    \ Topen | T <args>
" :TT is a better :Shell command so replace it
delcommand Shell

" :Tvopen
" Open a new terminal in a vertical split.
command! -bar -range=0 Tvopen
    \ execute 'vertical ' . g:neoterm_default_mod . ' Topen'
" :TTV <shell command>
" Like :TT with a vertical split
command! -range=0 -nargs=+ -complete=shellcmd TTV
    \ Tvopen | T <args>

" <F5> sends the |text-objects| in normal mode
" <F5> sends the selection in visual mode
nnoremap <F5> <Plug>(neoterm-repl-send)
vnoremap <F5> <Plug>(neoterm-repl-send)
