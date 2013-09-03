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

" disable :X encryption
nnoremap :X :echo "Encryption disabled"<CR>

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

  " Find a temporary directory for swap files.
  function! s:configure_temp_directory()
    let l:defaults = ['c:\tmp', 'c:\temp']
    let l:directories = []
    for l:dir in l:defaults
      if isdirectory(l:dir)
        call add(l:directories, l:dir)
      endif
    endfor
    if empty(l:directories)
      echom "Cannot find any of " . string(l:defaults) . ": directory is unset!"
      5 sleep
    else
      let &directory=join(l:directories, ",")
    end
  endfunction

  call s:configure_temp_directory()

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

" --- Work linux things --- {{{

if isdirectory($HOME . "/work/misc")
  " Fix up grep to work with rsgrep
  set grepprg=rsgrep\ $*

  " Path to search for include files
  set path=$SOFTWARE/headers,$SOFTWARE/include,.,/usr/include

  " Local plugins
  source ~/work/misc/tools/vim/load_plugins.vim
  map <Leader>bk <Esc>:call Btkpr_Annotate()<CR>
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
  Bundle 'kien/ctrlp.vim'
  Bundle 'plasticboy/vim-markdown'
  Bundle 'scrooloose/nerdtree'

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
" ... working path mode
let g:ctrlp_working_path_mode = 'a'
" ... open first file in current window, then others in hidden buffers
let g:ctrlp_open_multiple_files = '1r'
let g:ctrlp_by_filename = 1


" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>


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
