" --- Basics --- {{{

set nocompatible
set redraw

" Debugging on Windows: uncomment the next line to preserve cmd.exe windows
" after commands finish in order to see what the output was. Useful if
" git throws errors as Vundle's error handling is suspect.
"
" set shellcmdflag=/k

" Move leader to something I can type
let mapleader="'"
let maplocalleader="'"

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

set path=.,,**
" set g:ruby_path to prevent the ruby ftplugin messing with &path
let g:ruby_path = &path

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
  "set listchars=eol:◆
  set listchars=eol:←
endif

" highlight search and a mapping to hide the highlight
set incsearch
set hlsearch
nnoremap <Leader>q :silent nohlsearch<CR>

" disable :X encryption
nnoremap :X :echo "Encryption disabled"<CR>

syntax on
filetype on
filetype plugin on
filetype indent off

" }}}

" --- System Detection --- {{{

function! s:getSystemType()
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
  throw "s:getSystemType(): unknown system type"
endfunction

let g:system_type = s:getSystemType()
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
if g:is_windows
  set spellfile=~/vimfiles/spellfile.utf-8.add
else
  set spellfile=~/.vim/spellfile.utf-8.add
end
" Toggle spell checking with <F7>
nnoremap <silent> <F7> :setlocal spell!<CR><Bar>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

" Tags files may not be in current directory
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

" Add a :Shell command to run a command and read the stdout into a new buffer
command! -nargs=+ -complete=shellcmd Shell 
  \ enew | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

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
  return (&wrap && &linebreak) ? "soft"
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
    autocmd FileType text      WrapSoft
  augroup end

  " Open the quickfix window after any grep command
  " add mappings to the quickfix window
  "   <S-O> : jump to the location and close the QuickFix window
  augroup quickfix_mapping
    autocmd!
    autocmd QuickFixCmdPost *grep* copen | redraw!
    autocmd BufReadPost quickfix nnoremap <buffer> <S-O> <CR><BAR>:cclose<CR>
  augroup END

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
  Plugin 'VundleVim/Vundle.vim'

  " color schemes
  Plugin 'altercation/vim-colors-solarized'

  " plugins

  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'
  Plugin 'chikamichi/mediawiki.vim'
  if g:is_osx
    Plugin 'itspriddle/vim-marked'
  else
    Plugin 'iamcco/markdown-preview.vim'
  endif
  Plugin 'plasticboy/vim-markdown'
  Plugin 'PProvost/vim-ps1'
  Plugin 'scrooloose/nerdtree'
  Plugin 'scrosland/nvsimple.vim'

  call vundle#end()

  filetype on                 " restore
endif

" }}}

" --- Plugin options --- {{{

" Color schemes

function! s:fixHighlights(yellow)
  highlight IncSearch term=reverse cterm=reverse ctermfg=Red ctermbg=NONE
  let l:command = "highlight Search term=reverse cterm=reverse ctermfg=" 
    \. a:yellow . " ctermbg=Black"
  exec l:command
endfunction

" Solarized
function! s:dropSolarizedOptions()
  if exists(":SolarizedOptions")
    delcommand SolarizedOptions
  endif
  if has("autocmd")
    " add a group to re-do it later if the colorscheme is reloaded
    if !exists("#DropSolarizedOptions")
      augroup DropSolarizedOptions
        autocmd!
        autocmd ColorScheme * call s:dropSolarizedOptions()
      augroup END
    endif
  endif
endfunction
function! s:setSolarized(contrast)
  " Use the 256 colour mode so the terminal can remain in default colours.
  let g:solarized_termcolors = 256
  " Don't mess with the terminal background.
  let g:solarized_termtrans = 1
  " With a light background, high contrast often works best for me.
  let g:solarized_contrast = a:contrast
  " Turn it on ...
  colorscheme solarized
  " ... and drop the annoying options command
  call s:dropSolarizedOptions()
  let l:yellow = (a:contrast == "high") ? "Yellow" : "LightYellow"
  call s:fixHighlights(l:yellow)
endfunction
function! s:initSolarized()
  "let l:contrast = has("gui_running") ? "normal" : "high"
  let l:contrast = "high"
  call s:setSolarized(l:contrast)
endfunction
function! s:solarizedToggleContrast()
  let l:contrast = (g:solarized_contrast == "normal") ? "high" : "normal"
  call s:setSolarized(l:contrast)
endfunction
command! -nargs=0 Solarized call s:initSolarized()
command! -nargs=0 SolarizedToggleContrast call s:solarizedToggleContrast()

" Set initial color scheme
Solarized

" Other plugins

" Airline
function! AirlineSectionB()
  let l:parts = []
  call add(l:parts, WrapDescribeForAirline())
  " Hook for .vimrc.local
  if exists('*LocalPartsForAirline')
    let l:parts += LocalPartsForAirline()
  endif
  " This should use airline#util#append() but that seems to insert a two
  " space prefix instead of a single space prefix which is annoying.
  let l:value = join(
                    \ map(
                        \ filter(l:parts, 'len(v:val)'),
                        \ 'airline#util#wrap(v:val, 0)'
                        \ ),
                    \ ' > '
                    \ )
  return l:value
endfunction

function! s:initAirline()
  " sol         - quiet, but colourful
  let g:airline_theme = 'sol'
  " Disable trailing whitespace checks (too noisy). The default is:
  "   let g:airline#extensions#whitespace#checks = [ 'indent', 'trailing' ]
  let g:airline#extensions#whitespace#checks = [ 'indent' ]
  " Define a part for section 'b' and use it
  call airline#parts#define_function('section-b', 'AirlineSectionB')
  let g:airline_section_b = airline#section#create(['section-b'])
endfunction
if has("autocmd")
  augroup InitAirline
    autocmd!
    autocmd User AirlineAfterInit call s:initAirline()
  augroup END
endif
" Turn on the status bar everywhere.
set laststatus=2

" Simple BufExplorer alternative
nnoremap <Leader>be :ls<CR>:b

" NERDTree
" mapping to (re)open NERDTree and load the directory of the current file
nnoremap <C-n> :NERDTreeToggle %:.:h<CR>
" mapping to reopen existing NERDTree, or open it first time and load the cwd
" <Esc>n === <M-n> in a more reliable way on linux at least.
nnoremap <Esc>n :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

" Netrw should ignore case in sort
let g:netrw_sort_options = "i"

" nvSimple notes directory
if exists('$USERPROFILE/Dropbox/notes')
  let g:nvsimple_notes_directory = '$USERPROFILE/Dropbox/notes'
elseif exists('$HOME/Dropbox/notes')
  let g:nvsimple_notes_directory = '$HOME/Dropbox/notes'
endif
nnoremap <Leader>nv :Nv<CR>
nnoremap <Leader>no :Nvopen<CR>

" }}}

" --- GUI options --- {{{

if has("gui_running")

  " Light background please
  set background=light

  " Font
  set guifont=DejaVu\ Sans\ Mono:h10,Consolas:h11,Monospace:h10

  " Hide mouse in the GUI
  set mousehide

  " Disable the awful Select mode
  set selectmode=""

  " Enable autoselect
  set guioptions+=a

  " Initial window size
  set columns=80
  set lines=42

else

  " Mouse mode should work in a modern terminal
  set mouse=a
  behave xterm

  " Enable autoselect
  set clipboard+=autoselect

endif

" --- other vimrc files --- {{{

" This needs to be a file scope, otherwise it returns a pathname ending
" .../function which isn't helpful.
let s:vimrc = resolve(expand("<sfile>:p"))

function! s:load_vimrc_extras()
  let l:pattern = resolve(fnamemodify(s:vimrc, ":h")) . '/vim/*.vim'
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
