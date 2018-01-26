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
if exists('*vundle#begin')
  " old-style with Vundle
  finish
endif

if exists('g:vimrc_plugins')
  finish
endif
let g:vimrc_plugins = 1

if strlen($USERPROFILE)
  " On Windows force the plugins to be in C:\Users\<user>\vimfiles
  " to ensure that the directory is writable without needing to deal
  " with UAC, and to cope with work where $HOME is off on the network.
  let s:basedir = expand("$USERPROFILE/vimfiles")
  " deal with the non-standard location of vim-plug
  execute 'set runtimepath+='.s:basedir
else
  " Elsewhere the plugins can live in ~/.vim as normal
  let s:basedir = expand(has('nvim') ? '~/.local/share/nvim/site' : '~/.vim')
endif
" where the plugins live
let s:bundledir = finddir('bundle', s:basedir)

" --- Plugin bootstrap ---

function! plugins#bootstrap()
  if exists('*plug#begin')
    echom "Plugin bootstrap skipped: vim-plug is already installed."
    echom "Run ':PlugStatus to determine plugin status."
    return
  endif
  let vimplug = expand(s:basedir.'/autoload/plug.vim')
  if g:is_windows
    let url = 'https://github.com/junegunn/vim-plug'
    echom "See instructions at ".url." and save as '".vimplug."'"
    return
  endif
  let url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  echo "Downloading vim-plug to ".vimplug." ..."
  redraw
  try
    let out = system(printf('curl -fLo %s --create-dirs %s', vimplug, url))
    if v:shell_error
      echoerr "Error downloading vim-plug: ".out
      return
    endif
  endtry
  try
    let out = system(printf('mkdir -p %s', s:bundledir))
    if v:shell_error
      echoerr "Error creating bundle directory: ".out
      return
    endif
  endtry
  echom "vim-plug installed. Restart vim and run :PlugStatus and :PlugInstall"
endfunction

" --- Plugin loader ---

try
  call plug#begin(s:bundledir)
  let s:error = 0
catch /E117/
  let s:error = 1
endtry
if s:error
  " vim-plug should be in an autoload directory below s:basedir
  echoerr "Unable to find 'vim-plug' in ".s:basedir."/autoload. "
    \. "Consider running vim -c 'call plugins#bootstrap()'"
  finish
endif

" color schemes
Plug 'altercation/vim-colors-solarized'   " the original
Plug 'lifepillar/vim-solarized8'          " with truecolor support
Plug 'icymind/NeoSolarized'               " also with truecolor support

" plugins

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'chikamichi/mediawiki.vim'
if g:is_osx
  Plug 'itspriddle/vim-marked'
else
  Plug 'iamcco/markdown-preview.vim'
endif
Plug 'lifepillar/vim-mucomplete'
Plug 'plasticboy/vim-markdown'
Plug 'PProvost/vim-ps1'
Plug 'tpope/vim-sensible'
Plug 'vim-ruby/vim-ruby'
Plug 'scrosland/nvsimple.vim'

call plug#end()

" --- Plugin options ---

" Color schemes

function! s:fixHighlights(yellow)
  highlight IncSearch term=reverse cterm=reverse ctermfg=Red ctermbg=NONE
  let l:command = "highlight Search term=reverse cterm=reverse ctermfg=" 
    \. a:yellow . " ctermbg=Black"
  exec l:command
endfunction

" Solarized
function! s:setSolarized()
  let g:solarized_termcolors = 256
  let g:solarized_termtrans = 1
  colorscheme solarized
  call s:fixHighlights("Yellow")
endfunction
function! s:initSolarized()
  call s:setSolarized()
endfunction

function! s:initSolarized8()
  set termguicolors
  colorscheme solarized8_light_high
  call s:fixHighlights("Yellow")
endfunction

" TERM_PROGRAM=Apple_Terminal
" COLORTERM=truecolor
function! s:terminalSupportsTrueColor()
  if has("gui_running")
    return 0
  end
  if !has("termguicolors")
    return 0
  end
  " Not checking for Terminal.app as it seems broken.
  if $COLORTERM == "truecolor"
    return 1
  end
  return 0
endfunction

" Set initial color scheme
if s:terminalSupportsTrueColor()
  call s:initSolarized8()
else
  call s:initSolarized()
end

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

let g:airline_theme = 'sol'
" Disable trailing whitespace checks (too noisy). The default is:
"   let g:airline#extensions#whitespace#checks = [ 'indent', 'trailing' ]
let g:airline#extensions#whitespace#checks = [ 'indent' ]
" Define a part for section 'b' and use it
call airline#parts#define_function('section-b', 'AirlineSectionB')
let g:airline_section_b = airline#section#create(['section-b'])
" Turn on the status bar everywhere.
set laststatus=2

" Simple BufExplorer alternative
nnoremap <Leader>be :ls<CR>:b

" Netrw should ignore case in sort
let g:netrw_sort_options = "i"
" Use the long listing which includes time stamps and file size
let g:netrw_liststyle = 1
" Sort directories first, then files; setting this to empty would sort all
" files/directories by name alone
let g:netrw_sort_sequence = '[\/]$,*'

" nvSimple notes directory
if exists('$USERPROFILE/Dropbox/notes')
  let g:nvsimple_notes_directory = '$USERPROFILE/Dropbox/notes'
elseif exists('$HOME/Dropbox/notes')
  let g:nvsimple_notes_directory = '$HOME/Dropbox/notes'
endif
nnoremap <Leader>nv :Nv<CR>
nnoremap <Leader>no :Nvopen<CR>

" Completion
set completeopt=""
set completeopt+=menuone
set completeopt+=longest
if has('patch-7.4.775')
  " Configure completion auto-popup
  set completeopt+=noinsert
  inoremap <expr> <c-e> mucomplete#popup_exit("\<c-e>")
  inoremap <expr> <c-y> mucomplete#popup_exit("\<c-y>")
  inoremap <expr>  <cr> mucomplete#popup_exit("\<cr>")
  " The auto complete is broken under MacVim.
  " Disable everywhere as the popup can be distracting: it's easy to enable.
  let g:mucomplete#enable_auto_at_startup = 0
end
" The mucomplete 'path' completion requires the four argument glob() that
" arrived in patch-7.4.654, so it doesn't work on Debian Jessie
let s:file_or_path = has('patch-7.4.654') ? 'path' : 'file'
let g:mucomplete#chains = {
    \ 'default' : [s:file_or_path, 'omni', 'keyn', 'tags', 'uspl'],
    \ 'vim'     : [s:file_or_path, 'cmd', 'keyn']
    \ }
" Disable completion messages
"set shortmess+=c
" map <CR> to accept the current completion in the menu, or insert <CR>
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u<CR>"
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1

