" --- Basics ---

set nocompatible
set redraw        " vi only

" Debugging on Windows: uncomment the next line to preserve cmd.exe windows
" after commands finish in order to see what the output was. Useful for
" diagnosing git errors.
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

" --- System Detection ---

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
let g:is_osx      = (g:system_type == "osx")
let g:is_unix     = (g:system_type == "unix")
let g:is_windows  = (g:system_type == "windows")
lockvar g:system_type g:is_osx g:is_unix g:is_windows

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

if g:is_windows
  " Get the system defaults
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

" --- GUI options ---

if has("gui_running")
  " Light background please
  set background=light
  " Font
  set guifont=DejaVu\ Sans\ Mono:h10,Consolas:h11,Monospace:h10
  " Hide mouse in the GUI
  set mousehide
  " Mouse right-click does popup in GUIs
  set mousemodel=popup_setpos
  if has("unix")
    " Enable autoselect on platforms with two clipboards
    set guioptions+=a
  end
  " Initial window size
  set columns=80
  set lines=42
else
  behave xterm
endif

" --- Value added settings (spelling, tags, etc.) ---

" Clipboard, select mode and mouse settings need to be after sourcing mswin.vim
set clipboard+=unnamed
set clipboard+=autoselect
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

" Insert mode completion
" Also CTRL-N and CTRL-P are available based on options in 'complete'.
inoremap ^] ^X^]  " Tag completion. Hides 'trigger abbreviation'. i_CTRL-].
inoremap ^F ^X^F  " Filename completion. Hides reindent current line. i_CTRL-F.
inoremap ^L ^X^L  " (Previous) Line completion. Hides useless i_CTRL-L.
inoremap ^O ^X^O  " Omni completion. Hides execute single command. i_CTRL-O.

" --- Wrap mode and and file type handling ---

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
  function! s:init_markdown()
    setlocal nofoldenable
    setlocal conceallevel=2
    setlocal softtabstop=4
    setlocal shiftwidth=4
  endfunction
  augroup filetype_markdown
    autocmd!
    autocmd FileType markdown call s:init_markdown()
    autocmd FileType mkd      call s:init_markdown()
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

" --- other vimrc files ---

" This needs to be at file scope, otherwise it returns a pathname ending
" .../function which isn't helpful.
let s:vimrc = resolve(expand("<sfile>:p"))

function! s:load_vimrc_extras()
  let l:pattern = resolve(fnamemodify(s:vimrc, ":h")) . '/vim/*.vim'
  let l:files = sort(split(glob(l:pattern), "\n"))
  " load plugins.vim first
  let l:matches = filter(copy(l:files), 'v:val =~? "plugins\.vim"')
  let l:plugins_vim = get(l:matches, 0, '')
  call s:source_if_readable(l:plugins_vim)
  " then load the rest
  " this is lazy and relies on the fact that plugins.vim will not let itself
  " be reloaded, so we can just load every file in the list
  call map(l:files, 's:source_if_readable(v:val)')
endfunction
call s:load_vimrc_extras()

" --- local options ---

let s:vimrc_local = g:is_windows ?
                      \ "$USERPROFILE/vimfiles/vimrc.local" :
                      \ "$HOME/.vimrc.local"
call s:source_if_readable(s:vimrc_local)
