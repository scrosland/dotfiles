" --- Basics --- {{{

set nocompatible
set redraw

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

syntax on
filetype on
filetype plugin on
filetype indent off

" Set up errorfile and makeef for :cf and :make commands
set errorfile=err
set makeef=err

" Move leader to something I can type
let mapleader="'"

" }}}

" --- MS Windows --- {{{

if has("win32")

  if exists("$VIMRUNTIME/mswin.vim")
    source $VIMRUNTIME/mswin.vim
  endif

  set directory=c:\tmp;c:\temp
  set viminfo=""

endif

" }}}

" --- Value added settings (spelling, tags, etc.) --- {{{

" Spell checking
set spelllang=en_gb
set spellfile=~/.vim/spellfile.utf-8.add
" Toggle spell checking with <F7>
nnoremap <silent> <F7> :setlocal spell!<CR><Bar>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

" Tags files may not be in current directory
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

" Add a :Shell command to run a command and read the stdout into a new buffer
command! -nargs=* -complete=shellcmd Shell enew | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

if has("autocmd")
  " vim/vimrc files should support folding based on markers
  augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
  augroup end
endif

" }}}

" --- Work linux things --- {{{

if isdirectory($HOME . "/work/misc")
  " Fix up grep to work with rsgrep
  set grepprg=rsgrep\ $*

  " Path to search for include files
  set path=$SOFTWARE/headers,$SOFTWARE/include,.,/usr/include

  " Local plugins
  source ~/work/misc/tools/vim/load_plugins.vim
  map <Leader>bk <Esc>:call Btkpr_Annotate()<cr>
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

  Bundle 'kien/ctrlp.vim'
  Bundle 'plasticboy/vim-markdown'

  filetype on                 " restore
endif

" }}}

" --- Plugin options --- {{{

" Ctrl-P ...
" ... BitKeeper root
let g:ctrlp_root_markers = ['BitKeeper/']
" ... various things to ignore
let g:ctrlp_custom_ignore = {
      \ 'dir': '\v([\/]BitKeeper|[\/]SCCS|_(debug|release))$',
      \ 'file': '\v(tags|\.exe|\.lib|\.a|\.so|\.dll)$',
      \ }
" ... start from current working directory (at least for now)
let g:ctrlp_working_path_mode = 'c'
" ... open first file in current window, then others in hidden buffers
let g:ctrlp_open_multiple_files = '1r'
let g:ctrlp_by_filename = 1


" Netrw should ignore case in sort
let g:netrw_sort_options = "i"

" }}}

" --- GUI options --- {{{

if has("gui_running")

  " Font
  set guifont=Monospace\ 10,Consolas:h11

  " Hide mouse in the GUI
  set mousehide

else

  " Mouse mode should work in a modern terminal
  " -- but breaks up X cut-n-paste and is generally not the vim-way :)
  " -- so disable it when not running a gui.
  set mouse=

endif

" }}}
