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
  call plug#begin(g:plugins_bundledir)
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

" color schemes
Plug 'altercation/vim-colors-solarized'   " the original
Plug 'lifepillar/vim-solarized8'          " with truecolor support
Plug 'icymind/NeoSolarized'               " also with truecolor support

" plugins

Plug 'chikamichi/mediawiki.vim'
if g:is_osx
  Plug 'itspriddle/vim-marked'
else
  Plug 'iamcco/markdown-preview.vim'
endif
Plug 'lifepillar/vim-mucomplete'
Plug 'plasticboy/vim-markdown'
Plug 'PProvost/vim-ps1'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'vim-ruby/vim-ruby'

Plug 'scrosland/gitignore'
Plug 'scrosland/nvsimple.vim'

call plug#end()

" --- Plugin options ---

" Color schemes

function! s:fixHighlights(yellow)
  highlight IncSearch term=reverse cterm=reverse ctermfg=Red ctermbg=NONE
  " PuTTY and Gnome Terminator treat 'Yellow' higlighting differently
  " so force 'LightYellow' for them irrespective of the argument
  let l:force_light_yellow = 0
  if !g:is_osx && !g:is_windows
    if strlen($DISPLAY) == 0 || strlen($TERMINATOR_UUID)
      let l:force_light_yellow = 1
    end
  end
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
  " Windows conhost.exe now supports 24-bit colour.
  if strlen($WSL)
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
  set completeopt+=noinsert
"  inoremap <expr> <c-e> mucomplete#popup_exit("\<c-e>")
"  inoremap <expr> <c-y> mucomplete#popup_exit("\<c-y>")
"  inoremap <expr>  <cr> mucomplete#popup_exit("\<cr>")
end
let g:mucomplete#enable_auto_at_startup = 0
let g:mucomplete#chains = {
    \ 'default' : ['path', 'omni', 'keyn', 'tags', 'dict', 'uspl'],
    \ 'vim'     : ['path', 'cmd', 'keyn']
    \ }
" Disable completion messages
"set shortmess+=c
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1

