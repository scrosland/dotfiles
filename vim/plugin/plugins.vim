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

let s:error = 0

" where the plugins live
let g:plugins_bundledir = g:plugins_basedir . "/bundle"

if !isdirectory(g:plugins_bundledir)
    echoerr "Vim plugins directory is missing: " . g:plugins_bundledir
    let s:error = 1
elseif glob(g:plugins_bundledir . '/*', 0, 1) == []
    echoerr "Vim plugins directory is empty: " . g:plugins_bundledir
    let s:error = 1
endif

" --- Plugin loader ---

try
    silent! call plug#begin(g:plugins_bundledir)
catch /E117/
    let s:error = 1
    " vim-plug should be in an autoload directory below g:plugins_basedir
    echoerr "Unable to find 'vim-plug' in " . g:plugins_basedir . "/autoload. "
                \. "Consider running vim -c 'call plugins#bootstrap()'"
    finish
endtry

" basics
"
Plug 'tpope/vim-sensible'

" color schemes
"
Plug 'altercation/vim-colors-solarized'   " the original
Plug 'lifepillar/vim-solarized8'          " with truecolor support
Plug 'sonph/onehalf', { 'rtp': 'vim' }

" language and file format support
"
" LSP
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

"Plug 'chikamichi/mediawiki.vim', { 'for': 'mediwiki' }
"Plug 'davidhalter/jedi-vim', { 'for': 'python' }
"Plug 'fatih/vim-go', { 'for': 'go' }
"Plug 'peterhoeg/vim-qml', { 'for': 'qml' }
Plug 'plasticboy/vim-markdown'
"Plug 'PProvost/vim-ps1', { 'for': 'ps1' }
Plug 'vim-python/python-syntax'
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'iamcco/markdown-preview.vim', { 'for': ['markdown', 'mkd'] }
Plug 'z0mbix/vim-shfmt'

" utilities
"
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all --no-update-rc' }
Plug 'kassio/neoterm'
Plug 'majutsushi/tagbar'
Plug 'severin-lemaignan/vim-minimap'
if executable('git')
    Plug 'tpope/vim-fugitive'
endif
" vim-eunuch: automated chmod on new scripts with #! and some helpful commands
Plug 'tpope/vim-eunuch'

" Autocompletion
"
Plug 'lifepillar/vim-mucomplete'

call plug#end()

if s:error != 0
    finish
endif

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
    colorscheme solarized8
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
    set termguicolors
    "call s:initSolarized8()
else
    "call s:initSolarized()
endif
colorscheme onehalflight

" ---- vim-plug -----

" Open vim-plug commands in a new tab, close with 'q'
let g:plug_window = 'tabnew'
" Open the preview window from :PlugDiff in an equal split
let g:plug_pwindow = 'above new'

augroup filetype_vimplug
    autocmd!
    autocmd FileType vim-plug nmap <buffer> <F12> <Plug>(plug-preview)
    " Override vim-plug mappings: open commit and focus the preview window
    autocmd FileType vim-plug nmap <buffer> <cr>
                \ :execute "normal \<F12>"<bar>wincmd P<cr>
    autocmd FileType vim-plug nmap <buffer> o <cr>
augroup end

" ---- EditorConfig ----

let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" ---- Files and directories ----

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

" ---- lsp-vim and lsp-vim-settings ----

let g:lsp_use_native_client = 1
let g:lsp_diagnostics_virtual_text_align = 'right'
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_float_cursor = 1

" See |g:lsp_document_symbol_detail| documentation for more details
" let g:lsp_document_symbol_detail = 1

if has('patch-9.0.0167')
    let g:lsp_inlay_hints_enabled = 1
endif

" The sign column is 2 characters wide, and a 1 character sign is left justified
" which looks better than having the sign running into the code.
"
" Interesting single character symbols: ✗ ✨ 💡 ✦ ! ‼ ℹ ✎ ⟳ » →
let g:lsp_diagnostics_signs_error = {'text': '‼'}
let g:lsp_diagnostics_signs_warning = {'text': '!'}
let g:lsp_diagnostics_signs_information = {'text': 'ℹ'}
let g:lsp_diagnostics_signs_hint = {'text': '✨'}
" Disable the default code action signs – can still use :LspCodeAction
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_document_code_action_signs_hint = { 'text': '»' }

let g:lsp_settings_enable_suggestions = 0

" Force a particular LSP server for a filetype
let g:lsp_settings_filetype_ruby = [ 'ruby-lsp' ]

" Add BitKeeper to the default list of root markers
let g:lsp_settings_root_markers = [
\   '.git',
\   '.git/',
\   '.bk/',
\   'BitKeeper/',
\   '.svn',
\   '.hg',
\   '.bzr'
\ ]

" Disable McCabe complexity checker.
" Prefer Black, installed separately, for formatting.
" Disable all the formatters except pycodestyle which lsp requires, and
" configure pycodestyle to be compatible with Black.
let g:lsp_settings = {
\   'pylsp-all': {
\     'workspace_config': {
\       'pylsp': {
\         'plugins': {
\           'pycodestyle': {
\             'maxLineLength' : 80,
\             'ignore': 'E203,E701',
\           },
\           'autopep8': { 'enabled': v:false },
\           'mccabe': { 'enabled': v:false },
\           'yapf': { 'enabled': v:false },
\         }
\       },
\       'ruby-lsp': {
\         'initialization_options': {
\           'excluded_patterns': ['**/spec/**/*.rb'],
\         },
\       },
\     }
\   },
\   'clangd': {
\     'cmd': {server_info -> [lsp_settings#exec_path('clangd')]+s:clangd_args()},
\     'disabled': v:true,
\   },
\}

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    let g:lsp_format_sync_timeout = 1000
    " Do not format on save by default
    "autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled (set the lsp shortcuts) when an lsp server
    " is registered for a buffer.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" ---- clangd LSP helpers ----

let s:clangd_format_definitions = {
\   'legacy': '{ BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4, ColumnLimit: 0, BreakConstructorInitializers: BeforeComma, AccessModiferOffset: -2, IncludeBlocks: Preserve, SortIncludes: Never }',
\   'modern': 'Google',
\}

" {root_path -> format}
let s:clangd_format_cache = {}

function! s:clangd_format()
    let l:root = lsp_settings#root_path([])
    if len(l:root) == 0
        return 'modern'
    endif
    let l:format = get(s:clangd_format_cache, l:root, '')
    if len(l:format) != 0
        return l:format
    endif
    if isdirectory(l:root . '/.bk') || isdirectory(l:root . '/BitKeeper')
        let l:format = 'legacy'
    else
        let l:format = 'modern'
    endif
    let s:clangd_format_cache[l:root] = l:format
    return l:format
endfunction

function! s:clangd_args()
    let l:format = s:clangd_format()
    let l:format_string = get(s:clangd_format_definitions, l:format, '')
    return [ '--fallback-style=' . l:format_string ]
endfunction

" ---- Jedi for python intelligence ----

let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 2     " 0: off, 1: popup, 2: command line
let g:jedi#smart_auto_mappings = 0      " disable auto-insertion of 'import'
let g:jedi#use_splits_not_buffers = "bottom"

" ---- python syntax ----

let g:python_highlight_string_formatting = 1
let g:python_highlight_string_format = 1
let g:python_highlight_string_templates = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 1
let g:python_highlight_class_vars = 1
let g:python_highlight_file_headers_as_comments = 0

" ---- ruby completion ----

let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1

" ---- Terminal management via neoterm ----

if has('patch-8.0.1108')
    tnoremap <C-W><C-S-Up>      <C-W>:tabprev<CR>
    tnoremap <C-W><C-S-Down>    <C-W>:tabnext<CR>
endif

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
