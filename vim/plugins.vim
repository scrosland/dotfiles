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
  set runtimepath += s:basedir
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
    echom "Run ':PlugStatus to determine pluging status."
    return
  endif
  let vimplug = s:basedir.'/autoload/plug.vim'
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
Plug 'altercation/vim-colors-solarized'

" plugins

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'chikamichi/mediawiki.vim'
if g:is_osx
  Plug 'itspriddle/vim-marked'
else
  Plug 'iamcco/markdown-preview.vim'
endif
Plug 'plasticboy/vim-markdown'
Plug 'PProvost/vim-ps1'
" Only load NERDTree on open
Plug 'scrooloose/nerdtree', {'on': ['NERDTreeOpen', 'NERDTreeToggle']}
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
command! -nargs=0 SolarizedToggleContrast call s:solarizedToggleContrast()

" Set initial color scheme
call s:initSolarized()

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
