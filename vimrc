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

" }}}

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

if has("autocmd")
  function! s:enable_wrap()
    setlocal wrap linebreak
    setlocal textwidth=0
  endfunction

  " markdown files should start unfolded
  augroup filetype_markdown
    autocmd!
    autocmd FileType mkd setlocal nofoldenable
  augroup end

  " mediawiki buffer setup
  function! s:mediawiki_setup()
    call s:enable_wrap()
  endfunction
  augroup filetype_mediawiki
    autocmd!
    autocmd FileType mediawiki call s:mediawiki_setup()
  augroup end

  " taskpaper files should use hard tabs
  function! s:taskpaper_setup()
    setlocal softtabstop=0
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal noexpandtab
    setlocal nosmarttab
    call s:enable_wrap()
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
endif

" }}}

" --- Bundles (vundle) --- {{{
"
"  :BundleList          - list configured bundles
"  :BundleInstall(!)    - install(update) bundles (then u for changelog)
"
"  see :help vundle for more details
"  NOTE: comments after Bundle commands are not allowed..
"

if strlen($USERPROFILE)
  " On Windows force the bundles to be in C:\Users\<user>\vimfiles
  " to ensure that the directory is writable without needing to deal
  " with UAC.
  let $BUNDLEDIR = expand("$USERPROFILE/vimfiles/bundle")
else
  " Elsewhere the bundles can live in &runtimepath as normal.
  let $BUNDLEDIR = finddir('bundle', &runtimepath)
endif
let $VUNDLEDIR = finddir('vundle', $BUNDLEDIR)
if strlen($VUNDLEDIR)
  filetype off                " otherwise Vundle won't load corrcetly

  " setup
  set runtimepath+=$VUNDLEDIR
  call vundle#rc($BUNDLEDIR)

  " Vundle manages Vundle
  Bundle 'gmarik/vundle'

  Bundle 'chikamichi/mediawiki.vim'
  Bundle 'davidoc/taskpaper.vim'
  if g:is_osx
    Bundle 'itspriddle/vim-marked'
  endif
  Bundle 'jlanzarotta/bufexplorer'
  Bundle 'kien/ctrlp.vim'
  Bundle 'plasticboy/vim-markdown'
  Bundle 'scrooloose/nerdtree'
  Bundle 'scrosland/nvsimple.vim'

  filetype on                 " restore
endif

" }}}

" --- Plugin options --- {{{

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
let g:vimrc_extras_dir = g:vimrc_dir . '/vim'
lockvar g:vimrc_extras_dir

function! s:load_vimrc_extras()
  let l:pattern = g:vimrc_extras_dir . '/*.vim'
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
