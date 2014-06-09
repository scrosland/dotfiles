" --- Basics --- {{{

set nocompatible
set redraw

" Move leader to something I can type
let mapleader="'"

set visualbell
set noerrorbells
set showmode

set autoindent
set smartindent

set shiftwidth=2
set softtabstop=2

set notextmode
set expandtab
set smarttab

set ignorecase
set smartcase

set pastetoggle=<F10>

" disable screen restoration on exit
set norestorescreen
set t_ti=
set t_te=

if &t_Co == 16
  if &term == "xterm-debian" || &term == "gnome-terminal"
    " gnome-terminal has broken detection :(
    set t_Co=256
  endif
endif

if has("multi_byte")
  " UI encoding
  set encoding=utf-8
  " encoding detection
  set fileencodings=ucs-bom,utf-8,default,latin1
  " default for new files
  setglobal fileencoding=utf-8
  "set listchars=eol:¶
  set listchars=eol:←
endif

" highlight search and a mapping to hide the highlight
set incsearch
set hlsearch
nnoremap 'q :silent nohlsearch<CR>

" disable :X encryption
nnoremap :X :echo "Encryption disabled"<CR>

syntax on
filetype on
filetype plugin on
filetype indent off

" }}}

" --- System Detection --- {{{

function! GetSystemType()
  if has("win32") || has("win64")
    return "windows"
  endif
  if has("mac") || has("macunix") || has("gui_macvim")
    return "osx"
  endif
  if has("unix")
    " case insensitive regex comparison
    if system('uname') =~? 'Darwin'
      return "osx"
    else
      return "unix"
    endif
  endif
  throw "GetSystemType(): unknown system type"
endfunction

let g:system_type = GetSystemType()
lockvar g:system_type
let g:is_osx      = (g:system_type == "osx")
lockvar g:is_osx
let g:is_unix     = (g:system_type == "unix")
lockvar g:is_unix
let g:is_windows  = (g:system_type == "windows")
lockvar g:is_windows

let g:path_separator = g:is_windows ? '\' : '/'
lockvar g:path_separator

" }}}

function! g:path_join(...)
  return join(a:000, g:path_separator)
endfunction

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

" --- MS Windows --- {{{

if g:is_windows

  call s:source_if_readable("$VIMRUNTIME/mswin.vim")

  " Find a temporary directory for swap files.
  function! s:configure_temp_directory()
    let l:defaults = ['c:\tmp', 'c:\temp']
    let l:directories = s:find_directories(l:defaults)
    if empty(l:directories)
      echom "Cannot find any of " . string(l:defaults) . ": directory is unset!"
      5 sleep
    else
      let &directory=join(l:directories, ",")
    end
  endfunction

  call s:configure_temp_directory()

  " Don't save viminfo files
  set viminfo=""

endif

" }}}

" --- Value added settings (spelling, tags, etc.) --- {{{

" Digraphs - CTRL-K plus two characters
if has("digraphs") && has("multi_byte")
  " EN DASH U+2013
  digraphs n- 8211
  " EM DASH U+2014
  digraphs m- 8212
endif

" Improved wildcard expansion.
" First <tab> populates with longest match, and pops up a menu if needed.
" Second <tab> selects first thing in menu.
" <C-N> and <C-P> navigate the menu.
set wildmenu
set wildmode=longest:full,full

" Spell checking
set spelllang=en_gb
set spellfile=~/.vim/spellfile.utf-8.add
" Toggle spell checking with <F7>
nnoremap <silent> <F7> :setlocal spell!<CR><Bar>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

" Tags files may not be in current directory
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

" Add a :Grep wrapper to :grep
command! -nargs=+ -complete=shellcmd Grep execute 'silent grep <args>' | copen

" Add a :Shell command to run a command and read the stdout into a new buffer
command! -nargs=+ -complete=shellcmd Shell enew | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

" }}}


" --- Wrap mode and and file type handling --- {{{

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

function! s:hard_wrap_enable()
  call s:wrap_default()
  setlocal textwidth=74
endfunction
command! -nargs=0 WrapHard call s:hard_wrap_enable()

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

function! WrapDescribeForAirline()
  return (&wrap && &linebreak) ? "SOFT"
      \ : (&wrap && &fo =~ "t" && &tw != 0) ? "tw=" . &textwidth
      \ : ""
endfunction

" --- File type handling ---

if has("autocmd")
  " markdown files should start unfolded
  augroup filetype_markdown
    autocmd!
    autocmd FileType markdown setlocal nofoldenable
    autocmd FileType mkd      setlocal nofoldenable
  augroup end

  " taskpaper files should use hard tabs
  function! s:taskpaper_setup()
    setlocal softtabstop=0
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal noexpandtab
    setlocal nosmarttab
  endfunction
  augroup filetype_taskpaper
    autocmd!
    autocmd FileType taskpaper call s:taskpaper_setup()
  augroup end

  " vim/vimrc files should support folding based on markers, but start unfolded
  augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker nofoldenable
  augroup end

  " use soft wrap for text-like files
  augroup wrapping
    autocmd!
    autocmd FileType markdown  WrapSoft
    autocmd FileType mkd       WrapSoft
    autocmd FileType mediawiki WrapSoft
    autocmd FileType taskpaper WrapSoft
    autocmd FileType text      WrapSoft
  augroup end
endif

" }}}

" --- Plugins (vundle) --- {{{
"
"  :PluginList          - list configured plugins
"  :PluginInstall(!)    - install(update) plugins (then u for changelog)
"
"  See :help vundle for more details.
"  NOTE: Comments after Bundle commands are not allowed.
"        They are after Plugin commands.
"

if strlen($USERPROFILE)
  " On Windows force the plugins to be in C:\Users\<user>\vimfiles
  " to ensure that the directory is writable without needing to deal
  " with UAC.
  let $BUNDLEDIR = expand("$USERPROFILE/vimfiles/bundle")
else
  " Elsewhere the bundles can live in &runtimepath as normal.
  let $BUNDLEDIR = finddir('bundle', &runtimepath)
endif
" Find vundle itself
let $VUNDLEDIR = finddir('Vundle.vim', $BUNDLEDIR)
if strlen($VUNDLEDIR)
  filetype off                " otherwise Vundle won't load corrcetly

  " setup
  set runtimepath+=$VUNDLEDIR
  call vundle#begin($BUNDLEDIR)

  " Vundle manages Vundle
  Plugin 'gmarik/Vundle.vim'

  Plugin 'bling/vim-airline'
  Plugin 'chikamichi/mediawiki.vim'
  Plugin 'davidoc/taskpaper.vim'
  if g:is_osx
    Plugin 'itspriddle/vim-marked'
  endif
  Plugin 'jlanzarotta/bufexplorer'
  Plugin 'kien/ctrlp.vim'
  Plugin 'plasticboy/vim-markdown'
  Plugin 'PProvost/vim-ps1'
  Plugin 'scrooloose/nerdtree'
  Plugin 'scrosland/nvsimple.vim'
  "Plugin 'file:///C:/Users/scrosland/Documents/GitHub/nvsimple.vim',
  "  \ {'name': 'nvsimple.local'}

  call vundle#end()

  filetype on                 " restore
endif

" }}}

" --- Plugin options --- {{{

" Airline
"   monochrome  - a touch dark
"   lucius      - quite good, but a little subtle
"   sol         - quiet, but colourful
let g:airline_theme = 'sol'
let g:airline_section_b = '%{WrapDescribeForAirline()}'
" Disable trailing whitespace checks (too noisy). The default is:
"   let g:airline#extensions#whitespace#checks = [ 'indent', 'trailing' ]
let g:airline#extensions#whitespace#checks = [ 'indent' ]
set laststatus=2

" BufExplorer
let g:bufExplorerShowNoName = 1
let g:bufExplorerSplitOutPathName = 0

" Ctrl-P ...
" ... BitKeeper root
let g:ctrlp_root_markers = ['BitKeeper/']
" ... various things to ignore
let g:ctrlp_custom_ignore = {
      \ 'dir': '\v([\/]BitKeeper|[\/]SCCS|_(debug|release))$',
      \ 'file': '\v(tags|\.exe|\.lib|\.a|\.so|\.dll)$',
      \ }
" ... working path mode
let g:ctrlp_working_path_mode = 'a'
" ... open first file in current window, then others in hidden buffers
let g:ctrlp_open_multiple_files = '1r'
let g:ctrlp_by_filename = 1
" ... map the buffer explorer
nnoremap <Leader>bb :CtrlPBuffer<CR>

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

" Netrw should ignore case in sort
let g:netrw_sort_options = "i"

" nvSimple notes directory
if exists('$USERPROFILE/Dropbox/notes')
  let g:nvsimple_notes_directory = '$USERPROFILE/Dropbox/notes'
elseif exists('$HOME/Dropbox/notes')
  let g:nvsimple_notes_directory = '$HOME/Dropbox/notes'
endif
nnoremap 'nv :Nv<CR>
nnoremap 'no :Nvopen<CR>

" }}}

" --- GUI options --- {{{

if has("gui_running")

  " Font
  set guifont=DejaVu\ Sans\ Mono:h10,Consolas:h11,Monospace:h10

  " Hide mouse in the GUI
  set mousehide

  " Initial window size
  set columns=80
  set lines=42

else

  " Mouse mode should work in a modern terminal
  " -- but breaks up X cut-n-paste and is generally not the vim-way :)
  " -- so disable it when not running a gui.
  set mouse=

endif

" --- other vimrc files --- {{{

let g:vimrc = resolve(expand("<sfile>:p"))
lockvar g:vimrc
let g:vimrc_dir = resolve(fnamemodify(g:vimrc, ":h"))
lockvar g:vimrc_dir
let g:vimrc_extras_dir = g:path_join(g:vimrc_dir, 'vim')
lockvar g:vimrc_extras_dir

function! s:load_vimrc_extras()
  let l:pattern = g:path_join(g:vimrc_extras_dir, '*.vim')
  let l:files = split(glob(l:pattern), "\n")
  call map(l:files, 's:source_if_readable(v:val)')
endfunction
call s:load_vimrc_extras()

" }}}

" --- local options --- {{{

let s:vimrc_local = g:is_windows ?
                      \ "$USERPROFILE/vimfiles/vimrc.local" :
                      \ "$HOME/.vimrc.local"
call s:source_if_readable(s:vimrc_local)

" }}}
